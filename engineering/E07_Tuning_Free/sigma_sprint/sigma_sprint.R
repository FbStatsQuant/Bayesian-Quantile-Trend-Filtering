# E-07 sigma evidence sprint (Felipe via HQ, 2026-11-23). Felipe's ORIGINAL sampler exactly as in the paper (E-05 copy; the only edit
# there is the configurable metric cap, left at the paper's 1e8), the paper's priors and run lengths per signal. The ONLY change between
# arms is the sigma treatment:
#   L = learned sigma ~ IG(0.1, 0.1) (paper default)
#   F = sigma fixed at 1.1 sigma_bar, sigma_bar = tau(1-tau) / min_u f_u(q_u) (oracle, known law), via draw_sigma returning the constant
# Grid: VS, S x Normal, Beta, Mixed x tau in {0.05, 0.5, 0.95} x seeds 1-5, n = 500; same data across arms (paper simulate_data).
E07 <- Sys.getenv("E07_DIR"); E02 <- Sys.getenv("E02_DIR"); E05 <- Sys.getenv("E05_DIR"); OUT <- file.path(Sys.getenv("E07_OUT"), "sigma_sprint")
dir.create(OUT, recursive = TRUE, showWarnings = FALSE)
pl <- readLines(file.path(E05, "Individual_Sampler_PMALA_Augmented_E05copy.R")); pl <- pl[seq_len(grep("^# ---- Main", pl)[1] - 1L)]
PAPER <- new.env(parent = globalenv())
local({ commandArgs <- function(trailingOnly = FALSE) if (trailingOnly) character(0) else c("R", paste0("--file=", file.path(E02, "Individual_Sampler_PMALA_Augmented.R"))) }, envir = PAPER)
eval(parse(text = pl), envir = PAPER); PAPER$load_prox_cpp(file.path(E02, "prox_admm_metric.cpp"))
paper_cfg <- function(bl) if (bl == "VS") list(b0 = 1e-3, asis = TRUE, it = 30000L, burn = 10000L) else list(b0 = 5e-4, asis = FALSE, it = 20000L, burn = 5000L)
sigma_bar <- function(noise, tau, n = 500L) {                     # tau(1-tau) / min_i f_{u_i}(q_{u_i}), u_i = i/n (the paper's design)
  u <- seq_len(n) / n
  f <- switch(noise,
    Normal = dnorm(qnorm(tau)) / ((1 + u^2) / 4),
    Beta   = { b <- 11 - 10 * u; dbeta(qbeta(tau, 1, b), 1, b) },
    Mixed  = sapply(u, function(xi) { q <- uniroot(function(t) xi * pnorm(t, -.2, sqrt(.5)) + (1 - xi) * pnorm(t, .2, sqrt(.5)) - tau, c(-10, 10), tol = 1e-12)$root
                                      xi * dnorm(q, -.2, sqrt(.5)) + (1 - xi) * dnorm(q, .2, sqrt(.5)) }))
  tau * (1 - tau) / min(f)
}
PHASE <- Sys.getenv("SPRINT_PHASE", "LF")
tasks <- if (PHASE == "LF") expand.grid(arm = c("L", "F"), bl = c("VS", "S"), noise = c("Normal", "Beta", "Mixed"), tau = c(0.05, 0.5, 0.95), seed = 1:5, stringsAsFactors = FALSE) else
  expand.grid(arm = c("EB1", "EB025", "TH"), bl = c("VS", "S"), noise = c("Normal", "Beta", "Mixed"), tau = c(0.05, 0.5, 0.95), seed = 1:3, stringsAsFactors = FALSE)
# Arm set 2 (HQ/Felipe 11-23): sigma fixed at 1.1 sigma_bar, lambda LEARNED under an automatic Gamma(a0, b0) with centre lambda_c set from the
# same dataset's L run (the learned-sigma pilot): EBk: a0 = k m, b0 = k m / lambda_c, lambda_c = mean(lambda sigma | L) / sigma_F (k = 1, 0.25);
# TH: a0 = m, b0 = m / lambda_c, lambda_c = n^{5/2} / V_hat, V_hat = n^2 ||D^3 theta_hat_L||_1 (theta_hat_L = L posterior mean).
tasks$file <- file.path(OUT, sprintf("%s_%s_%s_t%03d_s%d.rds", tasks$arm, tasks$bl, tasks$noise, round(100 * tasks$tau), tasks$seed))
tasks <- tasks[!file.exists(tasks$file), ]
tasks <- tasks[order(tasks$bl != "VS", tasks$seed), ]                                  # VS (30k sweeps) first
K <- as.integer(Sys.getenv("SLURM_ARRAY_TASK_COUNT", "1")); k <- as.integer(Sys.getenv("SLURM_ARRAY_TASK_ID", "0"))
if (K > 1) tasks <- tasks[(seq_len(nrow(tasks)) - 1L) %% K == (k %% K), ]
cat(sprintf("[%s] sigma sprint: %d tasks here, %s cores\n", format(Sys.time()), nrow(tasks), Sys.getenv("SLURM_CPUS_PER_TASK")))
res <- parallel::mclapply(seq_len(nrow(tasks)), function(i) {
  tk <- tasks[i, ]
  r <- tryCatch({
    d <- PAPER$simulate_data(tk$seed, 500L, tk$tau, tk$bl, tk$noise); pc <- paper_cfg(tk$bl); sb <- sigma_bar(tk$noise, tk$tau)
    a0 <- 1; b0 <- pc$b0; lam_c <- NA; m <- length(d$y) - 3L
    if (tk$arm != "L") { sfix <- 1.1 * sb; PAPER$draw_sigma <- function(...) sfix }        # forked child: affects this task only
    if (tk$arm %in% c("EB1", "EB025", "TH")) {
      Lp <- readRDS(file.path(OUT, sprintf("L_%s_%s_t%03d_s%d.rds", tk$bl, tk$noise, round(100 * tk$tau), tk$seed)))
      lam_c <- if (tk$arm == "TH") length(d$y)^2.5 / (length(d$y)^2 * sum(abs(diff(Lp$mean, differences = 3L)))) else Lp$row$lamsig_mean / sfix
      kap <- c(EB1 = 1, EB025 = 0.25, TH = 1)[[tk$arm]]; a0 <- kap * m; b0 <- kap * m / lam_c
    }
    options(bqtf.metric_cap = 1e8); set.seed(tk$seed + 1000L)
    fit <- PAPER$gibbs_pmala_aug(d$y, tk$tau, 2L, a0 = a0, b0 = b0, a_sigma = 0.1, b_sigma = 0.1, gibbs_iter = pc$it, gibbs_burn = pc$burn,
             delta_init = 0.2, lambda_init = NULL, adapt_target = 0.5, adapt_gain = 1, adapt_kappa = 0.6, delta_bounds = c(1e-8, 100),
             control = PAPER$tf_control, metric = "curv", c_fixed = 1e4, rho = NULL, iters = 150L, mh = TRUE, adapt = TRUE, init = "y",
             warm = 200L, gamma_warm = 1e4, prior_scale = "none", cmap = FALSE, kappa = 3, adapt_all = TRUE, K = 1L, asis = pc$asis, tol = 0,
             lamjump = FALSE, verbose = FALSE)
    post <- (pc$burn + 1):pc$it; TH <- fit$theta; lam <- fit$lambda[post]; sig <- fit$sigma[post]
    est <- colMeans(TH); med <- apply(TH, 2, median); lo <- apply(TH, 2, quantile, 0.025); hi <- apply(TH, 2, quantile, 0.975)
    row <- data.frame(tk[1:5], sigma_bar = sb, a0 = a0, b0 = b0, lam_c = lam_c, sweeps = pc$it, seconds = fit$seconds, acc = mean(fit$acc[post], na.rm = TRUE),
                      lam_mean = mean(lam), sig_mean = mean(sig), lamsig_mean = mean(lam * sig),
                      ess_loglam = as.numeric(coda::effectiveSize(log(lam))), ess_sig = if (tk$arm == "L") as.numeric(coda::effectiveSize(sig)) else NA,
                      mse = mean((est - d$truth)^2), mad = mean(abs(est - d$truth)), mse_med = mean((med - d$truth)^2),
                      mciw = mean(hi - lo), cover = mean(d$truth >= lo & d$truth <= hi), stringsAsFactors = FALSE)
    saveRDS(list(row = row, y = d$y, truth = d$truth, mean = est, median = med, lo = lo, hi = hi), tk$file); "ok"
  }, error = function(e) paste("ERROR", conditionMessage(e)))
  if (r != "ok") cat(sprintf("task %s failed: %s\n", basename(tk$file), r)); r
}, mc.cores = as.integer(Sys.getenv("SLURM_CPUS_PER_TASK", "2")), mc.preschedule = FALSE)
cat(sprintf("[%s] done: %d ok, %d failed\n", format(Sys.time()), sum(unlist(res) == "ok"), sum(unlist(res) != "ok")))
