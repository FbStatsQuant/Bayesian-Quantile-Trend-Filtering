# E-02 free check: learned (lambda, sigma) BQTF, production config. Usage: Rscript run_free_check.R [time|full] [n8000seed1]
args <- commandArgs(TRUE); mode <- if (length(args)) args[1] else "full"
root <- "/home/fb31/Bayesian-Quantile-Trend-Filtering/method/individual"
outd <- "/home/fb31/BQTF_runs/E02/free_check"; dir.create(outd, recursive = TRUE, showWarnings = FALSE)
setwd(root)
L <- readLines("Individual_Sampler_PMALA_Augmented.R")
L <- L[seq_len(grep("^# ---- Main", L)[1] - 1L)]
eval(parse(text = L), envir = globalenv())
load_prox_cpp(file.path(root, "prox_admm_metric.cpp"))
suppressPackageStartupMessages(library(coda))

run_one <- function(baseline, tau, n, seed, iters_total, burn, noise = "Normal", tag = "", a0 = 1, b0 = 0.01) {
  dat <- simulate_data(seed, n, tau, baseline, noise)
  set.seed(seed + 1000)
  fit <- gibbs_pmala_aug(dat$y, tau, 2L, a0, b0, 0.1, 0.1, iters_total, burn, 0.2, NULL,
    0.5, 1, 0.6, c(1e-8, 100), list(max_iter = 2000L, obj_tol = 1e-8),
    metric = "curv", c_fixed = 1e4, rho = NULL, iters = 150L, mh = TRUE, adapt = TRUE, init = "y",
    warm = 200L, gamma_warm = 1e4, prior_scale = "none", cmap = FALSE, kappa = 3, adapt_all = TRUE,
    K = 1L, asis = TRUE, tol = 0, lamjump = FALSE, lamjump_s = 0.3, verbose = FALSE)
  post <- (burn + 1):iters_total; m <- n - 3L
  lam <- fit$lambda[post]; sg <- fit$sigma[post]; SD <- fit$SD[post]
  th <- colMeans(fit$theta)
  L0 <- mean(rho_tau(dat$y - dat$truth, tau)); Lh <- mean(rho_tau(dat$y - th, tau))
  h <- length(lam) %/% 2
  res <- list(baseline = baseline, noise = noise, tau = tau, n = n, seed = seed, iters = iters_total, burn = burn,
    a0 = a0, b0 = b0, CAP = (a0 + m) / b0, lam_mean = mean(lam), lam_med = median(lam), kappa = mean(dnorm(qnorm(tau)) / ((1 + (seq_len(n) / n)^2) / 4)) / mean(sg), lam_q = quantile(lam, c(.025, .975)), sig_mean = mean(sg),
    lamsig = mean(lam) * mean(sg), mean_lamsig_draw = mean(lam * sg),
    L0 = L0, Lhat = Lh, sig_L0 = mean(sg) / L0, sig_Lhat = mean(sg) / Lh,
    lamSD_m = mean(lam * SD / m), ess_loglam = as.numeric(effectiveSize(log(lam))), ess_sig = as.numeric(effectiveSize(sg)),
    drift = mean(log(lam[(h + 1):length(lam)])) - mean(log(lam[1:h])),
    drift_sig = mean(sg[(h + 1):length(sg)]) - mean(sg[1:h]),
    mse = mean((th - dat$truth)^2), acc_post = fit$acc_post, seconds = fit$seconds,
    lambda = fit$lambda, sigma = fit$sigma, SD = fit$SD, theta_hat = th)
  if (nzchar(tag)) saveRDS(res, file.path(outd, paste0(tag, ".rds")))
  res
}

if (mode == "time") {
  for (n in c(500L, 8000L)) { t0 <- proc.time()[3]
    r <- run_one("VS", 0.5, n, 1L, 1000L, 300L); cat(n, "n 1000 sweeps wall", proc.time()[3] - t0, "s; lam", r$lam_mean, "\n") }
  quit("no")
}
g1 <- expand.grid(baseline = c("VS", "S"), tau = c(.5, .9), n = c(500L, 2000L), seed = 1:2, stringsAsFactors = FALSE)
g1$a0 <- 1; g1$b0 <- 0.01
g2 <- data.frame(baseline = c("VS", "VS", "VS", "VS"), tau = c(.5, .9, NA, NA), n = 8000L, seed = 1L, a0 = 1, b0 = 0.01)[1:2, ]
g3 <- expand.grid(cfg = 1:3, seed = 1:2); g3 <- data.frame(baseline = c("VS", "S", "VS")[g3$cfg], tau = .5, n = 500L, seed = g3$seed,
  a0 = 1, b0 = c(1e-3, 5e-4, 1)[g3$cfg])
grid <- rbind(g2, g1, g3)
grid <- grid[order(-grid$n), ]
cores <- as.integer(Sys.getenv("OWLS_JOB_CORES", "2"))
t0 <- proc.time()[3]
out <- parallel::mclapply(seq_len(nrow(grid)), function(i) {
  g <- grid[i, ]; tag <- sprintf("%s_tau%.1f_n%d_b%g_s%d", g$baseline, g$tau, g$n, g$b0, g$seed)
  f <- file.path(outd, paste0(tag, ".rds")); if (file.exists(f)) return(TRUE)
  b <- if (g$n <= 2000L) c(15000L, 3000L) else c(12000L, 3000L)
  tryCatch({ run_one(g$baseline, g$tau, g$n, g$seed, b[1], b[2], tag = tag, a0 = g$a0, b0 = g$b0); TRUE }, error = function(e) conditionMessage(e))
}, mc.cores = cores, mc.preschedule = FALSE)
cat("done; wall", proc.time()[3] - t0, "\n"); print(unlist(out))
