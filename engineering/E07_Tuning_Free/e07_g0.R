# E-07 G0 (PROPOSAL section 4): exactness and speed of the new sampler.
#  Part A (same target): VS, S x Normal x tau in {0.05, 0.5, 0.95} x seeds 1-3, at the PAPER's priors and data
#    O = paper sampler (E-05 copy, cap 1e8 = paper), paper settings (VS: b0 1e-3, ASIS, 30k/10k; S: b0 5e-4, no ASIS, 20k/5k)
#    N = new sampler, move "exact" (raw scale, paper priors, stopping rule)
#    H = new sampler, move "hybrid" (paper P-MALA theta move + collapsed block)
#  Part B (E-05 trap): sin, N(0, 0.5^2), tau 0.5, n = 2000, b0 = n^-2, seeds 1-3 (the E-02 pvg data); N must match the Gibbs lambda-bar.
#  Part C: the new DEFAULT (standardised, Gamma(2, s_y n^-5/2)) on the Part A cells, for timing and a first look.
args <- commandArgs(trailingOnly = TRUE)
E07 <- Sys.getenv("E07_DIR"); E02 <- Sys.getenv("E02_DIR"); E05 <- Sys.getenv("E05_DIR"); OUT <- Sys.getenv("E07_OUT")
source(file.path(E02, "e02_lib.R")); source(file.path(E07, "sampler", "e07_sampler.R"))
e07_load(file.path(E07, "sampler"), Sys.getenv("E07_CACHE")); load_kernel()
pl <- readLines(file.path(E05, "Individual_Sampler_PMALA_Augmented_E05copy.R")); pl <- pl[seq_len(grep("^# ---- Main", pl)[1] - 1L)]
PAPER <- new.env(parent = globalenv())
local({ commandArgs <- function(trailingOnly = FALSE) if (trailingOnly) character(0) else c("R", paste0("--file=", file.path(E02, "Individual_Sampler_PMALA_Augmented.R"))) }, envir = PAPER)
eval(parse(text = pl), envir = PAPER); PAPER$load_prox_cpp(file.path(E02, "prox_admm_metric.cpp"))
dir.create(file.path(OUT, "g0"), recursive = TRUE, showWarnings = FALSE)
paper_cfg <- function(bl) if (bl == "VS") list(b0 = 1e-3, asis = TRUE, it = 30000L, burn = 10000L) else list(b0 = 5e-4, asis = FALSE, it = 20000L, burn = 5000L)
A <- expand.grid(arm = c("O", "N", "H", "D"), bl = c("VS", "S"), tau = c(0.05, 0.5, 0.95), seed = 1:3, stringsAsFactors = FALSE)
A$part <- ifelse(A$arm == "D", "C", "A")
B <- data.frame(arm = "N", bl = "sinB", tau = 0.5, seed = 1:3, part = "B", stringsAsFactors = FALSE)
tasks <- rbind(A, B); tasks$file <- file.path(OUT, "g0", sprintf("%s_%s_%s_t%03d_s%d.rds", tasks$part, tasks$arm, tasks$bl, round(100 * tasks$tau), tasks$seed))
tasks <- tasks[!file.exists(tasks$file), ]
tasks <- tasks[order(match(tasks$arm, c("O", "H", "N", "D")), tasks$part != "B"), ]
cat(sprintf("[%s] G0: %d tasks, %s cores\n", format(Sys.time()), nrow(tasks), Sys.getenv("SLURM_CPUS_PER_TASK")))
summ <- function(est, lo, hi, truth) c(mse = mean((est - truth)^2), mad = mean(abs(est - truth)), mciw = mean(hi - lo), cover = mean(truth >= lo & truth <= hi))
res <- parallel::mclapply(seq_len(nrow(tasks)), function(i) {
  tk <- tasks[i, ]
  r <- tryCatch({
    if (tk$part == "B") { n <- 2000; d <- make_data("sin", "gauss", 0.5, n, tk$seed); y <- d$y; truth <- d$theta_star; b0 <- n^-2 }
    else { d <- PAPER$simulate_data(tk$seed, 500L, tk$tau, tk$bl, "Normal"); y <- d$y; truth <- d$truth; b0 <- paper_cfg(tk$bl)$b0 }
    set.seed(tk$seed + 1000L)
    if (tk$arm == "O") {
      pc <- paper_cfg(tk$bl); options(bqtf.metric_cap = 1e8)
      fit <- PAPER$gibbs_pmala_aug(y, tk$tau, 2L, a0 = 1, b0 = pc$b0, a_sigma = 0.1, b_sigma = 0.1, gibbs_iter = pc$it, gibbs_burn = pc$burn,
               delta_init = 0.2, lambda_init = NULL, adapt_target = 0.5, adapt_gain = 1, adapt_kappa = 0.6, delta_bounds = c(1e-8, 100),
               control = PAPER$tf_control, metric = "curv", c_fixed = 1e4, rho = NULL, iters = 150L, mh = TRUE, adapt = TRUE, init = "y",
               warm = 200L, gamma_warm = 1e4, prior_scale = "none", cmap = FALSE, kappa = 3, adapt_all = TRUE, K = 1L, asis = pc$asis, tol = 0,
               lamjump = FALSE, verbose = FALSE)
      post <- (pc$burn + 1):pc$it; TH <- fit$theta; lam <- fit$lambda[post]; sig <- fit$sigma[post]
      est <- colMeans(TH); lo <- apply(TH, 2, quantile, 0.025); hi <- apply(TH, 2, quantile, 0.975); med <- apply(TH, 2, median)
      row <- data.frame(tk[1:5], sweeps = pc$it, chains = 1, seconds = fit$seconds, lam_geo = exp(mean(log(lam))), sig_mean = mean(sig),
                        ess_loglam = as.numeric(coda::effectiveSize(log(lam))), rhat_max = NA, converged = NA, t(summ(est, lo, hi, truth)))
    } else {
      fit <- if (tk$arm == "D") bqtf_tf(y, tk$tau)
             else bqtf_tf(y, tk$tau, move = if (tk$arm == "H") "hybrid" else "exact", standardize = FALSE, a0 = 1, b0 = b0, b_s = 0.1, paper_env = PAPER)
      est <- fit$mean; lo <- fit$lo; hi <- fit$hi; med <- fit$median
      row <- data.frame(tk[1:5], sweeps = fit$sweeps, chains = fit$chains, seconds = fit$seconds, lam_geo = exp(mean(log(fit$lambda))), sig_mean = mean(fit$sigma),
                        ess_loglam = fit$ess_loglam, rhat_max = fit$rhat_max, converged = fit$converged, t(summ(est, lo, hi, truth)))
    }
    row$ess_loglam_per_s <- row$ess_loglam / row$seconds
    saveRDS(list(row = row, mean = est, median = med, lo = lo, hi = hi, truth = truth, y = y), tk$file); "ok"
  }, error = function(e) paste("ERROR", conditionMessage(e)))
  if (r != "ok") cat(sprintf("task %s failed: %s\n", basename(tk$file), r)); r
}, mc.cores = as.integer(Sys.getenv("SLURM_CPUS_PER_TASK", "2")), mc.preschedule = FALSE)
cat(sprintf("[%s] done: %d ok, %d failed\n", format(Sys.time()), sum(unlist(res) == "ok"), sum(unlist(res) != "ok")))
R <- do.call(rbind, lapply(list.files(file.path(OUT, "g0"), full.names = TRUE), function(f) readRDS(f)$row))
options(width = 220); R <- R[order(R$part, R$bl, R$tau, R$seed, R$arm), ]
print(R, digits = 4, row.names = FALSE)
cat("\nPart A means over seeds (same target): O vs N vs H\n")
print(aggregate(cbind(lam_geo, sig_mean, mse, mciw, cover, seconds, ess_loglam_per_s, sweeps) ~ arm + bl + tau, R[R$part %in% c("A", "C"), ], mean), digits = 4)
cat("\nPart B (E-05 trap; Gibbs lambda-bar 3.15e6 / 3.88e6 / 3.89e6 for seeds 1-3):\n"); print(R[R$part == "B", c("seed", "lam_geo", "sweeps", "converged", "seconds", "mse")], digits = 4)
