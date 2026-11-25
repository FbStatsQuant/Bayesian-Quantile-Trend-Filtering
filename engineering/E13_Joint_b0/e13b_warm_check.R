# E-13a phase 2: short check of the warm start with the fixes (accurate warm solves, data-based start, sigma guard), comparing the
# lambda rule during the warm sweeps: "hold" (lambda fixed at its start, the phase-2 default) vs "draw" (conjugate draw given the warm
# MAP theta, the pre-E-13a rule).  VS, Normal, n = 500, data seed 1, b0 = 1e-5, new move, chain seed 1001, 700 sweeps (200 warm).
# Usage: Rscript e13b_warm_check.R ind|joint hold|draw [iter]     (env E13_ROOT = code tree holding method/; default ".")
`%||%` <- function(a, b) if (is.null(a) || length(a) == 0 || is.na(a)) b else a
args <- commandArgs(TRUE); which <- args[1]; wl <- args[2]; iter <- as.integer(args[3] %||% 700)
ROOT <- normalizePath(Sys.getenv("E13_ROOT", "."))
if (which == "ind") {
  code <- file.path(ROOT, "method/individual"); L <- readLines(file.path(code, "Individual_Sampler_PMALA_Augmented.R"))
  owd <- setwd(code); eval(parse(text = L[seq_len(grep("^# ---- Main", L)[1] - 1L)]), envir = globalenv()); setwd(owd)
  load_prox_cpp(file.path(code, "prox_admm_metric.cpp"))
  dat <- simulate_data(1, 500L, 0.75, "VS", "Normal"); set.seed(1001)
  fit <- gibbs_pmala_aug(dat$y, 0.75, 2L, 1, 1e-5, 0.1, 0.1, iter, iter - 200L, delta_init, lambda_init, adapt_target, adapt_gain,
    adapt_kappa, delta_bounds, tf_control, metric = metric, c_fixed = c_metric, rho = admm_rho, iters = admm_iter, mh = TRUE, adapt = TRUE,
    init = theta_init, warm = warm_sweeps, gamma_warm = gamma_warm, K = 1L, asis = TRUE, tol = 0, prior_scale = "none", kappa = kappa_metric,
    asis_q = "fixed", verbose = FALSE, warm_lam = wl)
  cat(which, wl, "sigma0", fit$sigma0, "| fallbacks", sum(fit$warm_fallback), "ipm bad", sum(fit$warm_ipm_unconverged), "guard", sum(fit$sigma_guard), "\n")
  ix <- c(1, 2, 5, 20, 100, 200, 201, 210, 250, 300, 400, 500, iter)
  print(rbind(sweep = ix, lambda = signif(fit$lambda[ix], 3), sigma = signif(fit$sigma[ix], 3), acc = round(fit$acc[ix], 2)))
  cat("acc post", fit$acc_post, " mse", mean((colMeans(fit$theta) - dat$truth)^2), "\n")
} else {
  owd <- setwd(file.path(ROOT, "method/joint")); L <- readLines("Joint_Sampler_PMALA_Augmented.R")
  eval(parse(text = L[seq_len(grep("^# ---- Main", L)[1] - 1L)]), envir = globalenv()); load_box_cpp(); setwd(owd)
  TAUS <- c(.3, .5, .7, .9); dat <- simulate_data(1, 500L, TAUS, "VS", "Normal"); set.seed(1001)
  fit <- gibbs_joint_pmala(dat$y, TAUS, 2L, 1, 1e-5, 0.1, 0.1, iter, iter - 200L, delta_init, NULL, adapt_target, adapt_gain,
    adapt_kappa, delta_bounds, metric = "curv", c_fixed = 0, rho = NULL, iters = admm_iter, mh = TRUE, adapt = TRUE, warm = warm_sweeps,
    gamma_warm = gamma_warm, kappa = kappa_metric, adapt_all = TRUE, K = 1L, asis = TRUE, tol = 0, zeta_scale = zeta_scale, ctrl = box_ctrl,
    asis_q = "fixed", verbose = FALSE, warm_lam = wl)
  cat(which, wl, "sigma0", signif(fit$sigma0, 3), "| fallbacks", colSums(fit$warm_fallback), "ipm bad", colSums(fit$warm_ipm_unconverged), "guard", colSums(fit$sigma_guard), "\n")
  ix <- c(1, 2, 5, 20, 100, 200, 201, 210, 250, 300, 400, 500, iter)
  cat("lambda\n"); print(cbind(ix, signif(fit$lambda[ix, ], 3))); cat("sigma\n"); print(cbind(ix, signif(fit$sigma[ix, ], 3)))
  cat("acc post", round(fit$acc_post, 2), " mse", signif(colMeans((apply(fit$theta, c(2, 3), mean) - dat$truth)^2), 3), "min", fit$seconds / 60, "\n")
}
