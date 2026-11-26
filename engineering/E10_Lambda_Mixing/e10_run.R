# E-10 calibration of the q rule of the generalised ASIS lambda move: one chain per call.
# Usage: Rscript e10_run.R <task index 0-based>   (env: E10_CODE = folder with the sampler + kernel, E10_OUT = output folder)
# Design: n in {500, 2000, 5000} x baseline {VS, S, PC} x tau {0.5, 0.75, 0.95}, Normal noise, data seed 1, chains 1001/1002,
# order 2, lambda ~ Gamma(1, 1e-5), sigma ~ IG(0.1, 0.1), canonical settings otherwise, 30k sweeps / 10k burn-in.
# Variants (asis_q rule): poly = the current sampler (Felipe's standard); fixed, n_prop, n16, geo = candidate q grids.
# At n = 500 all four candidate grids are {10, 20, 40}, so only "fixed" runs there.
suppressPackageStartupMessages(library(coda))
code <- Sys.getenv("E10_CODE", "method/individual"); out <- Sys.getenv("E10_OUT", "engineering/E10_Lambda_Mixing/out")
dir.create(out, showWarnings = FALSE, recursive = TRUE)

tasks <- function() {
  g <- list()
  for (n in c(5000L, 2000L, 500L))                                  # longest first
    for (v in if (n == 500L) c("poly", "fixed") else c("poly", "fixed", "n_prop", "n16", "geo"))
      for (b in c("VS", "S", "PC")) for (tau in c(0.5, 0.75, 0.95)) for (ch in 1:2)
        g[[length(g) + 1L]] <- data.frame(n = n, variant = v, baseline = b, tau = tau, chain = ch)
  do.call(rbind, g)
}
TK <- tasks()
args <- commandArgs(trailingOnly = TRUE)
if (length(args) && args[1] == "count") { cat(nrow(TK), "\n"); quit(save = "no") }
idx <- as.integer(args[1]) + 1L; tk <- TK[idx, ]
id <- sprintf("n%d_%s_t%03d_%s_c%d", tk$n, tk$baseline, round(100 * tk$tau), tk$variant, tk$chain)
if (file.exists(file.path(out, paste0(id, ".rds")))) { cat("exists:", id, "\n"); quit(save = "no") }

src <- file.path(code, "Individual_Sampler_PMALA_Augmented.R")
lines <- readLines(src); main_at <- grep("^# ---- Main", lines)[1]
owd <- setwd(code); eval(parse(text = lines[seq_len(main_at - 1)]), envir = globalenv()); setwd(owd)
load_prox_cpp(file.path(code, "prox_admm_metric.cpp"))

order <- 2L; a0 <- 1; b0 <- 1e-5; a_sigma <- 0.1; b_sigma <- 0.1
if (nzchar(Sys.getenv("E10_SMOKE"))) { gibbs_iter <- 300L; gibbs_burn <- 150L; warm_sweeps <- 50L }   # smoke test only
dat <- simulate_data(1, tk$n, tk$tau, tk$baseline, "Normal")
set.seed(1000 + tk$chain)
fit <- gibbs_pmala_aug(dat$y, tk$tau, order, a0, b0, a_sigma, b_sigma,
                       gibbs_iter, gibbs_burn, delta_init, lambda_init,
                       adapt_target, adapt_gain, adapt_kappa, delta_bounds, tf_control,
                       metric = metric, c_fixed = c_metric, rho = admm_rho, iters = admm_iter,
                       mh = mh_correct, adapt = adapt_delta, init = theta_init, warm = warm_sweeps, gamma_warm = gamma_warm,
                       K = K_theta, asis = TRUE, tol = admm_tol, prior_scale = "none", cmap = FALSE,
                       kappa = kappa_metric, adapt_all = adapt_all, asis_q = tk$variant, verbose = FALSE)
post <- (gibbs_burn + 1):gibbs_iter; TH <- fit$theta; H <- nrow(TH) %/% 2
est <- colMeans(TH); lo <- apply(TH, 2, quantile, .025); hi <- apply(TH, 2, quantile, .975)
ess_th <- apply(TH, 2, function(v) as.numeric(effectiveSize(v)))
pts <- round(tk$n * c(0.1, 0.3, 0.5, 0.7, 0.9))
res <- list(task = tk, id = id, q_grid = fit$asis_q_grid, seconds = fit$seconds, acc_post = fit$acc_post, sweeps = gibbs_iter, burn = gibbs_burn,
            lambda = fit$lambda, sigma = fit$sigma, theta_pts = TH[, pts], pts = pts,
            est = est, lo = lo, hi = hi, truth = dat$truth, y = dat$y, ess_th = ess_th,
            half_mean = cbind(colMeans(TH[1:H, ]), colMeans(TH[(H + 1):(2 * H), ])),            # split R-hat of theta across chains
            half_var  = cbind(apply(TH[1:H, ], 2, var), apply(TH[(H + 1):(2 * H), ], 2, var)), half_len = H,
            mse = mean((est - dat$truth)^2), coverage = mean(dat$truth >= lo & dat$truth <= hi), width = mean(hi - lo),
            lam_ess = as.numeric(effectiveSize(fit$lambda[post])), sig_ess = as.numeric(effectiveSize(fit$sigma[post])))
saveRDS(res, file.path(out, paste0(id, ".tmp.rds"))); file.rename(file.path(out, paste0(id, ".tmp.rds")), file.path(out, paste0(id, ".rds")))
cat(sprintf("%s | %.1f min | lambda ESS %.1f (%.2f/min) | theta ESS median %.0f | MSE %.5f | cov %.3f | grid %s\n", id, fit$seconds / 60,
            res$lam_ess, res$lam_ess / (fit$seconds / 60), median(ess_th), res$mse, res$coverage, paste(fit$asis_q_grid, collapse = ",")))
