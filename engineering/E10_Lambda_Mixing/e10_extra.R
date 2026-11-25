# E-10 follow-up runs (HQ, 2026-11-25 ~09:00): one chain per call.
# Usage: Rscript e10_extra.R <task index 0-based> | count     (env: E10_CODE = sampler folder, E10_OUT = output folder)
# Part A "delta": n = 2000, data seed 1, the cells where the new move's theta split R-hat is bad (S 0.5, S 0.75, VS 0.5, VS 0.75)
#   plus VS 0.95, old (poly) and new (fixed {10,20,40}), chains 1001/1002 -- the same seeds as the calibration chains, so these
#   reproduce those chains draw for draw and add what the calibration files did not keep: the delta trace, the P-MALA acceptance
#   trace, the SD trace, and the log posterior at thinned kept states.
# Part B "pcseed": PC baseline, tau 0.5 / 0.75, old vs new, chain 1001, extra data seeds: n = 500 seeds 2-11, n = 2000 and
#   n = 5000 seeds 2-6 -- is the higher PC MSE of the new move at n = 2000 (seed 1) noise or real?
# Settings as e10_run.R: order 2, lambda ~ Gamma(1, 1e-5), sigma ~ IG(0.1, 0.1), 30k sweeps / 10k burn-in.
suppressPackageStartupMessages(library(coda))
code <- Sys.getenv("E10_CODE", "method/individual"); out <- Sys.getenv("E10_OUT", "engineering/E10_Lambda_Mixing/out_extra")
dir.create(out, showWarnings = FALSE, recursive = TRUE)

tasks <- function() {
  g <- list()
  for (n in c(5000L, 2000L)) for (s in 2:6) for (tau in c(0.5, 0.75)) for (v in c("poly", "fixed"))          # longest first
    g[[length(g) + 1L]] <- data.frame(part = "pcseed", n = n, seed = s, baseline = "PC", tau = tau, variant = v, chain = 1L)
  for (cl in list(c("S", .5), c("S", .75), c("VS", .5), c("VS", .75), c("VS", .95))) for (v in c("poly", "fixed")) for (ch in 1:2)
    g[[length(g) + 1L]] <- data.frame(part = "delta", n = 2000L, seed = 1L, baseline = cl[1], tau = as.numeric(cl[2]), variant = v, chain = ch)
  for (s in 2:11) for (tau in c(0.5, 0.75)) for (v in c("poly", "fixed"))
    g[[length(g) + 1L]] <- data.frame(part = "pcseed", n = 500L, seed = s, baseline = "PC", tau = tau, variant = v, chain = 1L)
  do.call(rbind, g)
}
TK <- tasks()
args <- commandArgs(trailingOnly = TRUE)
if (length(args) && args[1] == "count") { cat(nrow(TK), "\n"); quit(save = "no") }
tk <- TK[as.integer(args[1]) + 1L, ]
id <- sprintf("%s_n%d_s%d_%s_t%03d_%s_c%d", tk$part, tk$n, tk$seed, tk$baseline, round(100 * tk$tau), tk$variant, tk$chain)
if (file.exists(file.path(out, paste0(id, ".rds")))) { cat("exists:", id, "\n"); quit(save = "no") }

src <- file.path(code, "Individual_Sampler_PMALA_Augmented.R")
lines <- readLines(src); main_at <- grep("^# ---- Main", lines)[1]
owd <- setwd(code); eval(parse(text = lines[seq_len(main_at - 1)]), envir = globalenv()); setwd(owd)
load_prox_cpp(file.path(code, "prox_admm_metric.cpp"))

order <- 2L; a0 <- 1; b0 <- 1e-5; a_sigma <- 0.1; b_sigma <- 0.1
dat <- simulate_data(tk$seed, tk$n, tk$tau, tk$baseline, "Normal")
set.seed(1000 + tk$chain)
fit <- gibbs_pmala_aug(dat$y, tk$tau, order, a0, b0, a_sigma, b_sigma,
                       gibbs_iter, gibbs_burn, delta_init, lambda_init,
                       adapt_target, adapt_gain, adapt_kappa, delta_bounds, tf_control,
                       metric = metric, c_fixed = c_metric, rho = admm_rho, iters = admm_iter,
                       mh = mh_correct, adapt = adapt_delta, init = theta_init, warm = warm_sweeps, gamma_warm = gamma_warm,
                       K = K_theta, asis = TRUE, tol = admm_tol, lamjump = FALSE, prior_scale = "none", cmap = FALSE,
                       kappa = kappa_metric, adapt_all = adapt_all, asis_q = tk$variant, verbose = FALSE)
post <- (gibbs_burn + 1):gibbs_iter; TH <- fit$theta; H <- nrow(TH) %/% 2
est <- colMeans(TH); lo <- apply(TH, 2, quantile, .025); hi <- apply(TH, 2, quantile, .975)
res <- list(task = tk, id = id, q_grid = fit$asis_q_grid, seconds = fit$seconds, acc_post = fit$acc_post, delta_final = fit$delta_final,
            est = est, lo = lo, hi = hi, sd = apply(TH, 2, sd), truth = dat$truth,
            mse = mean((est - dat$truth)^2), coverage = mean(dat$truth >= lo & dat$truth <= hi), width = mean(hi - lo),
            lam_ess = as.numeric(effectiveSize(fit$lambda[post])), lambda_mean = mean(fit$lambda[post]))
if (tk$part == "delta") {
  m <- tk$n - order - 1L
  thin <- seq(1, nrow(TH), by = 20)
  lp <- t(sapply(thin, function(i) { it <- gibbs_burn + i; th <- TH[i, ]; sg <- fit$sigma[it]; lam <- fit$lambda[it]
    ll <- sum(log(tk$tau * (1 - tk$tau) / sg) - rho_tau(dat$y - th, tk$tau) / sg); SD <- sum(abs(diff(th, differences = order + 1L)))
    c(sweep = it, loglik = ll, SD = SD, log_joint = ll + (m + a0 - 1) * log(lam) - lam * SD - b0 * lam - (a_sigma + 1) * log(sg) - b_sigma / sg) }))
  res <- c(res, list(lambda = fit$lambda, sigma = fit$sigma, delta = fit$delta, acc = fit$acc, SD = fit$SD, logpost = lp,
                     theta_thin = TH[seq(1, nrow(TH), by = 50), ], y = dat$y, final = fit$final))
}
saveRDS(res, file.path(out, paste0(id, ".tmp.rds"))); file.rename(file.path(out, paste0(id, ".tmp.rds")), file.path(out, paste0(id, ".rds")))
cat(sprintf("%s | %.1f min | acc %.3f | delta_final %.3e | lambda mean %.0f | MSE %.5f | cov %.3f | width %.3f\n", id, fit$seconds / 60,
            fit$acc_post, fit$delta_final, res$lambda_mean, res$mse, res$coverage, res$width))
