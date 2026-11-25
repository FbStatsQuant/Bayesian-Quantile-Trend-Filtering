# E-13a phase 2: short check of the warm start with the fixes (accurate warm solves, data-based start, sigma guard), comparing the
# lambda rule during the warm sweeps: "hold" (lambda fixed at its start, the phase-2 default) vs "draw" (conjugate draw given the warm
# MAP theta, the pre-E-13a rule).  VS, Normal, n = 500, data seed 1, b0 = 1e-5, new move, chain seed 1001, 1500 sweeps (200 warm).
# Individual only: each warm-start solve is also re-solved by glmgen (an independent trend-filtering solver; the warm problem is
# weighted trend filtering with weights a (1 + 1/gamma) and response (gamma r + x)/(gamma + 1)) and the two are compared.
# Usage: Rscript e13b_warm_check.R ind|joint hold|draw [iter]     (env E13_ROOT = code tree holding method/; default ".")
`%||%` <- function(a, b) if (is.null(a) || length(a) == 0 || is.na(a)) b else a
args <- commandArgs(TRUE); which <- args[1]; wl <- args[2]; iter <- as.integer(args[3] %||% 1500)
ROOT <- normalizePath(Sys.getenv("E13_ROOT", "."))
if (which == "ind") {
  code <- file.path(ROOT, "method/individual"); L <- readLines(file.path(code, "Individual_Sampler_PMALA_Augmented.R"))
  owd <- setwd(code); eval(parse(text = L[seq_len(grep("^# ---- Main", L)[1] - 1L)]), envir = globalenv()); setwd(owd)
  load_prox_cpp(file.path(code, "prox_admm_metric.cpp"))
  acc_rec <- list(); wp0 <- warm_prox
  warm_prox <- function(x, a, r, lambda, gamma, order, lower, upper, iters) {       # same call, plus an independent re-solve (no RNG)
    out <- wp0(x, a, r, lambda, gamma, order, lower, upper, iters)
    w <- a * (1 + 1 / gamma); yt <- (gamma * r + x) / (gamma + 1)
    ref <- as.numeric(glmgen::trendfilter(seq_along(x), yt, weights = w, k = order, lambda = lambda, thinning = FALSE,
                                          control = glmgen::trendfilter.control.list(max_iter = 20000L, obj_tol = 1e-12))$beta[, 1])
    f <- function(th) sum(w * (th - yt)^2) / 2 + lambda * sum(abs(diff(th, differences = order + 1L)))
    acc_rec[[length(acc_rec) + 1L]] <<- c(fallback = out$fallback, rel_gap = (f(out$theta) - f(ref)) / abs(f(ref)), max_abs_diff = max(abs(out$theta - ref)),
                                          theta_scale = diff(range(ref)))
    out
  }
  dat <- simulate_data(1, 500L, 0.75, "VS", "Normal"); set.seed(1001)
  fit <- gibbs_pmala_aug(dat$y, 0.75, 2L, 1, 1e-5, 0.1, 0.1, iter, iter - 200L, delta_init, lambda_init, adapt_target, adapt_gain,
    adapt_kappa, delta_bounds, tf_control, metric = metric, c_fixed = c_metric, rho = admm_rho, iters = admm_iter, mh = TRUE, adapt = TRUE,
    init = theta_init, warm = warm_sweeps, gamma_warm = gamma_warm, K = 1L, asis = TRUE, tol = 0, prior_scale = "none", kappa = kappa_metric,
    asis_q = "fixed", verbose = FALSE, warm_lam = wl)
  cat(which, wl, "sigma0", fit$sigma0, "| fallbacks", sum(fit$warm_fallback), "ipm bad", sum(fit$warm_ipm_unconverged), "guard", sum(fit$sigma_guard), "\n")
  ix <- c(1, 2, 5, 20, 100, 200, 201, 210, 250, 300, 400, 500, iter)
  print(rbind(sweep = ix, lambda = signif(fit$lambda[ix], 3), sigma = signif(fit$sigma[ix], 3), acc = round(fit$acc[ix], 2)))
  cat("acc post", fit$acc_post, " mse", mean((colMeans(fit$theta) - dat$truth)^2), " lambda hold until", fit$lambda_hold_until, "\n")
  A <- do.call(rbind, acc_rec)
  cat(sprintf("warm solves vs glmgen (%d solves): objective rel gap (ours - glmgen) min %.2e median %.2e max %.2e | max |theta diff| %.2e (theta range %.2f)\n",
              nrow(A), min(A[, "rel_gap"]), median(A[, "rel_gap"]), max(A[, "rel_gap"]), max(A[, "max_abs_diff"]), median(A[, "theta_scale"])))
  ix2 <- c(201, 250, 300, 400, 401, 410, 450, 500, 700, 1000, iter)
  print(rbind(sweep = ix2, lambda = signif(fit$lambda[ix2], 3), acc_window = round(sapply(ix2, function(i) mean(fit$acc[max(201, i - 49):i])), 2)))
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
  ix2 <- c(201, 250, 300, 400, 401, 410, 450, 500, 700, 1000, iter)
  cat("lambda after warm\n"); print(cbind(ix2, signif(fit$lambda[ix2, ], 3)))
  cat("acceptance, 50-sweep window ending at\n"); print(cbind(ix2, round(t(sapply(ix2, function(i) colMeans(fit$acc[max(201, i - 49):i, , drop = FALSE]))), 2)))
  cat("acc post", round(fit$acc_post, 2), " mse", signif(colMeans((apply(fit$theta, c(2, 3), mean) - dat$truth)^2), 3), "min", fit$seconds / 60, "\n")
}
