# Theory's method variants (Route A, HQ-approved pilots, alignment budget). Felipe's ORIGINAL sampler (R1 copy = E-05 copy + numeric-init
# hook, unused here), paper settings (VS: b0 1e-3, ASIS, 30k/10k; S: b0 5e-4, no ASIS, 20k/5k; sigma ~ IG(0.1, 0.1)).
#   V1: lambda FIXED at kappa n^{5/2}, kappa = 4.909e-4 (geometric mean of his learned lambda over the 18 sprint cells / 500^{5/2});
#       fixed inside his code by a0 = 1e9, b0 = 1e9 / lambda_fix (lambda | theta = Gamma(1e9 + m, .) sits at lambda_fix to 1e-4).
#       n = 500, 18 sprint cells x seeds 1-3; paired against the sprint L fits.
#   V2 pilot: b0_n = b0 (500/n)^{5/2} ("V2") vs his constant b0 ("C") at the same n; 2 chains each (seed + 1000, seed + 1500);
#       n = 1000: VS, S x Normal x tau {0.05, 0.5, 0.95}; n = 2000: VS, S x Normal x tau 0.5; seed 1.
E07 <- Sys.getenv("E07_DIR"); E02 <- Sys.getenv("E02_DIR"); OUT <- file.path(Sys.getenv("E07_OUT"), "variants"); dir.create(OUT, recursive = TRUE, showWarnings = FALSE)
pl <- readLines(file.path(E07, "Individual_Sampler_PMALA_Augmented_E07R1copy.R")); pl <- pl[seq_len(grep("^# ---- Main", pl)[1] - 1L)]
PAPER <- new.env(parent = globalenv())
local({ commandArgs <- function(trailingOnly = FALSE) if (trailingOnly) character(0) else c("R", paste0("--file=", file.path(E02, "Individual_Sampler_PMALA_Augmented.R"))) }, envir = PAPER)
eval(parse(text = pl), envir = PAPER); PAPER$load_prox_cpp(file.path(E02, "prox_admm_metric.cpp"))
paper_cfg <- function(bl) if (bl == "VS") list(b0 = 1e-3, asis = TRUE, it = 30000L, burn = 10000L) else list(b0 = 5e-4, asis = FALSE, it = 20000L, burn = 5000L)
KAPPA <- 4.909e-4
g <- function(arm, n, bl, noise, tau, seeds, chain = 1L) expand.grid(arm = arm, n = n, bl = bl, noise = noise, tau = tau, seed = seeds, chain = chain, stringsAsFactors = FALSE)
tasks <- rbind(g("V1", 500, c("VS", "S"), c("Normal", "Beta", "Mixed"), c(0.05, 0.5, 0.95), 1:3),
               g(c("C", "V2"), 1000, c("VS", "S"), "Normal", c(0.05, 0.5, 0.95), 1, 1:2),
               g(c("C", "V2"), 2000, c("VS", "S"), "Normal", 0.5, 1, 1:2))
tasks$file <- file.path(OUT, sprintf("%s_n%05d_%s_%s_t%03d_s%d_c%d.rds", tasks$arm, tasks$n, tasks$bl, tasks$noise, round(100 * tasks$tau), tasks$seed, tasks$chain))
tasks <- tasks[!file.exists(tasks$file), ]; tasks <- tasks[order(-tasks$n, tasks$bl != "VS"), ]
cat(sprintf("[%s] variants: %d tasks, %s cores\n", format(Sys.time()), nrow(tasks), Sys.getenv("SLURM_CPUS_PER_TASK")))
res <- parallel::mclapply(seq_len(nrow(tasks)), function(i) {
  tk <- tasks[i, ]
  r <- tryCatch({
    d <- PAPER$simulate_data(tk$seed, tk$n, tk$tau, tk$bl, tk$noise); pc <- paper_cfg(tk$bl); m <- tk$n - 3L
    a0 <- 1; b0 <- pc$b0
    if (tk$arm == "V1") { lf <- KAPPA * tk$n^2.5; a0 <- 1e9; b0 <- 1e9 / lf }
    if (tk$arm == "V2") b0 <- pc$b0 * (500 / tk$n)^2.5
    options(bqtf.metric_cap = 1e8); set.seed(tk$seed + 1000L + 500L * (tk$chain - 1L))
    fit <- PAPER$gibbs_pmala_aug(d$y, tk$tau, 2L, a0 = a0, b0 = b0, a_sigma = 0.1, b_sigma = 0.1, gibbs_iter = pc$it, gibbs_burn = pc$burn,
             delta_init = 0.2, lambda_init = NULL, adapt_target = 0.5, adapt_gain = 1, adapt_kappa = 0.6, delta_bounds = c(1e-8, 100),
             control = PAPER$tf_control, metric = "curv", c_fixed = 1e4, rho = NULL, iters = 150L, mh = TRUE, adapt = TRUE, init = "y",
             warm = 200L, gamma_warm = 1e4, prior_scale = "none", cmap = FALSE, kappa = 3, adapt_all = TRUE, K = 1L, asis = pc$asis, tol = 0,
             lamjump = FALSE, verbose = FALSE)
    post <- (pc$burn + 1):pc$it; TH <- fit$theta; lam <- fit$lambda[post]; sig <- fit$sigma[post]
    est <- colMeans(TH); lo <- apply(TH, 2, quantile, 0.025); hi <- apply(TH, 2, quantile, 0.975)
    row <- data.frame(tk[1:7], b0 = b0, a0 = a0, sweeps = pc$it, seconds = fit$seconds, lam_mean = mean(lam), lam_med = median(lam), sig_mean = mean(sig), sig_med = median(sig),
                      lamsig_mean = mean(lam * sig), ess_loglam = as.numeric(coda::effectiveSize(log(lam))), mse = mean((est - d$truth)^2),
                      mciw = mean(hi - lo), cover = mean(d$truth >= lo & d$truth <= hi), stringsAsFactors = FALSE)
    saveRDS(list(row = row, lam_trace = fit$lambda[seq(1, pc$it, by = 10)], mean = est, lo = lo, hi = hi, y = d$y, truth = d$truth), tk$file); "ok"
  }, error = function(e) paste("ERROR", conditionMessage(e)))
  if (r != "ok") cat(sprintf("task %s failed: %s\n", basename(tk$file), r)); r
}, mc.cores = as.integer(Sys.getenv("SLURM_CPUS_PER_TASK", "2")), mc.preschedule = FALSE)
cat(sprintf("[%s] done: %d ok, %d failed\n", format(Sys.time()), sum(unlist(res) == "ok"), sum(unlist(res) != "ok")))
