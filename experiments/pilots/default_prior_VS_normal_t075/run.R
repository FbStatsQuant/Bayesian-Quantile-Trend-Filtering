# Single-seed diagnostic run of the individual Bayesian-PMALA sampler (Felipe, 2026-11-25).
# Settings: order = 2 (k = 2, third differences), lambda ~ Gamma(1, 1e-5), sigma ~ IG(0.1, 0.1),
# baseline VS, Normal noise, tau = 0.75, n = 500, seed 1; every other setting = the canonical sampler's settings block.
# Run from the repo root:  owls_run -j 1 -- Rscript experiments/pilots/default_prior_VS_normal_t075/run.R

suppressPackageStartupMessages(library(coda))
src     <- "method/individual/Individual_Sampler_PMALA_Augmented.R"

# Load the canonical sampler (everything above its "# ---- Main" block), unchanged.
lines <- readLines(src)
main_at <- grep("^# ---- Main", lines)[1]
setwd(dirname(src)); eval(parse(text = lines[seq_len(main_at - 1)]), envir = globalenv()); setwd("../..")
out_dir <- "experiments/pilots/default_prior_VS_normal_t075"   # after the eval, which defines its own out_dir

# Requested settings
order <- 2L; a0 <- 1; b0 <- 1e-5; a_sigma <- 0.1; b_sigma <- 0.1
baseline_id <- "VS"; noise_id <- "Normal"; tau <- 0.75; seed <- 1; n <- 500L

load_prox_cpp(cpp_src)
dat <- simulate_data(seed, n, tau, baseline_id, noise_id)
set.seed(seed + 1000)
fit <- gibbs_pmala_aug(dat$y, tau, order, a0, b0, a_sigma, b_sigma,
                       gibbs_iter, gibbs_burn, delta_init, lambda_init,
                       adapt_target, adapt_gain, adapt_kappa, delta_bounds, tf_control,
                       metric = metric, c_fixed = c_metric, rho = admm_rho, iters = admm_iter,
                       mh = mh_correct, adapt = adapt_delta, init = theta_init, warm = warm_sweeps, gamma_warm = gamma_warm,
                       K = K_theta, asis = asis_lambda, tol = admm_tol, lamjump = lamjump, lamjump_s = lamjump_s,
                       prior_scale = prior_scale, cmap = FALSE, kappa = kappa_metric, adapt_all = adapt_all)
saveRDS(list(fit = fit, dat = dat), file.path(tempdir(), "fit.rds"))

post <- (gibbs_burn + 1):gibbs_iter
lam  <- fit$lambda[post]; sig <- fit$sigma[post]; TH <- fit$theta
est  <- colMeans(TH); med <- apply(TH, 2, median)
lo   <- apply(TH, 2, quantile, 0.025); hi <- apply(TH, 2, quantile, 0.975)
idx  <- round(c(0.1, 0.3, 0.5, 0.7, 0.9) * n)

ess_th <- apply(TH, 2, function(v) as.numeric(effectiveSize(v)))
split_rhat <- function(v, k = 4) {               # split-R-hat over k equal segments of one chain
  m <- matrix(v[seq_len(k * (length(v) %/% k))], ncol = k)
  W <- mean(apply(m, 2, var)); B <- nrow(m) * var(colMeans(m))
  sqrt(((nrow(m) - 1) / nrow(m) * W + B / nrow(m)) / W)
}
rh_th <- apply(TH, 2, split_rhat)
half  <- function(v) { h <- length(v) %/% 2; c(first = mean(v[1:h]), second = mean(v[(h + 1):length(v)])) }
sec   <- fit$seconds

summ <- data.frame(
  quantity = c("MSE (posterior mean)", "MSE (posterior median)", "MAD", "coverage of 95% bands", "mean 95% band width",
               "acceptance (post burn-in)", "final step size delta", "run time (s)", "sweeps / burn-in",
               "lambda: posterior mean", "lambda: 95% interval", "lambda: ESS", "lambda: ESS per minute", "lambda: Geweke z", "lambda: split R-hat",
               "lambda: half-chain means",
               "sigma: posterior mean", "sigma: 95% interval", "sigma: ESS", "sigma: ESS per minute", "sigma: Geweke z", "sigma: split R-hat",
               "sigma: half-chain means", "sigma reference s*phi(Phi^-1(tau)) avg",
               "theta: ESS min / median / max (500 coords)", "theta: ESS per minute (median)", "theta: split R-hat max",
               sprintf("theta[%d]: ESS", idx)),
  value = c(sprintf("%.5f", mean((est - dat$truth)^2)), sprintf("%.5f", mean((med - dat$truth)^2)),
            sprintf("%.4f", mean(abs(est - dat$truth))), sprintf("%.3f", mean(dat$truth >= lo & dat$truth <= hi)),
            sprintf("%.4f", mean(hi - lo)), sprintf("%.3f", fit$acc_post), sprintf("%.3g", fit$delta_final),
            sprintf("%.0f", sec), sprintf("%d / %d", gibbs_iter, gibbs_burn),
            sprintf("%.4g", mean(lam)), sprintf("[%.4g, %.4g]", quantile(lam, .025), quantile(lam, .975)),
            sprintf("%.0f", effectiveSize(lam)), sprintf("%.1f", effectiveSize(lam) / (sec / 60)),
            sprintf("%.2f", geweke.diag(mcmc(lam))$z), sprintf("%.3f", split_rhat(lam)),
            paste(sprintf("%.4g", half(lam)), collapse = " / "),
            sprintf("%.4f", mean(sig)), sprintf("[%.4f, %.4f]", quantile(sig, .025), quantile(sig, .975)),
            sprintf("%.0f", effectiveSize(sig)), sprintf("%.1f", effectiveSize(sig) / (sec / 60)),
            sprintf("%.2f", geweke.diag(mcmc(sig))$z), sprintf("%.3f", split_rhat(sig)),
            paste(sprintf("%.4f", half(sig)), collapse = " / "),
            sprintf("%.4f", mean((1 + (dat$x / n)^2) / 4 * dnorm(qnorm(tau)))),
            sprintf("%.0f / %.0f / %.0f", min(ess_th), median(ess_th), max(ess_th)),
            sprintf("%.1f", median(ess_th) / (sec / 60)), sprintf("%.3f", max(rh_th)),
            sprintf("%.0f", ess_th[idx])))
print(summ, right = FALSE)
write.csv(summ, file.path(out_dir, "diagnostics.csv"), row.names = FALSE)

# ---- Plots ------------------------------------------------------------------
png(file.path(out_dir, "fit.png"), width = 1500, height = 750, res = 140)
plot(dat$x, dat$y, pch = 16, cex = 0.4, col = "grey70", xlab = "index", ylab = "y",
     main = sprintf("VS, Normal noise, tau = %.2f, seed 1 | MSE %.5f | coverage %.3f", tau,
                    mean((est - dat$truth)^2), mean(dat$truth >= lo & dat$truth <= hi)))
polygon(c(dat$x, rev(dat$x)), c(lo, rev(hi)), col = adjustcolor("firebrick", 0.25), border = NA)
lines(dat$x, dat$truth, lwd = 2); lines(dat$x, est, col = "firebrick", lwd = 2, lty = 2)
legend("topright", c("true quantile", "posterior mean", "95% band"), lwd = c(2, 2, 8), lty = c(1, 2, 1),
       col = c("black", "firebrick", adjustcolor("firebrick", 0.25)), bty = "n")
dev.off()

png(file.path(out_dir, "traces_hyper.png"), width = 1600, height = 1100, res = 140)
par(mfrow = c(3, 2), mar = c(4, 4, 2.5, 1))
plot(fit$lambda, type = "l", log = "y", main = "lambda, all sweeps (log scale)", xlab = "sweep", ylab = "lambda"); abline(v = gibbs_burn, lty = 3, col = "red")
plot(fit$sigma,  type = "l", log = "y", main = "sigma, all sweeps (log scale)", xlab = "sweep", ylab = "sigma"); abline(v = gibbs_burn, lty = 3, col = "red")
plot(post, lam, type = "l", main = "lambda, after burn-in", xlab = "sweep", ylab = "lambda"); lines(post, cumsum(lam) / seq_along(lam), col = "red", lwd = 2)
plot(post, sig, type = "l", main = "sigma, after burn-in", xlab = "sweep", ylab = "sigma"); lines(post, cumsum(sig) / seq_along(sig), col = "red", lwd = 2)
plot(fit$delta, type = "l", log = "y", main = "step size delta", xlab = "sweep", ylab = "delta"); abline(v = gibbs_burn, lty = 3, col = "red")
ra <- stats::filter(fit$acc, rep(1 / 500, 500), sides = 1)
plot(ra, type = "l", ylim = c(0, 1), main = "acceptance, moving average of 500 sweeps", xlab = "sweep", ylab = "acceptance")
abline(h = adapt_target, lty = 2, col = "blue"); abline(v = gibbs_burn, lty = 3, col = "red")
dev.off()

png(file.path(out_dir, "traces_theta.png"), width = 1600, height = 1200, res = 140)
par(mfrow = c(3, 2), mar = c(4, 4, 2.5, 1))
for (i in idx) {
  plot(post, TH[, i], type = "l", main = sprintf("theta[%d] | ESS %.0f | truth %.3f", i, ess_th[i], dat$truth[i]),
       xlab = "sweep", ylab = "theta"); abline(h = dat$truth[i], col = "blue", lwd = 2)
}
plot(ess_th, pch = 16, cex = 0.4, main = "ESS of every theta_i", xlab = "index i", ylab = "ESS")
dev.off()

png(file.path(out_dir, "acf_and_posteriors.png"), width = 1600, height = 1100, res = 140)
par(mfrow = c(2, 3), mar = c(4, 4, 2.5, 1))
acf(lam, lag.max = 200, main = "ACF lambda"); acf(sig, lag.max = 200, main = "ACF sigma")
acf(TH[, idx[3]], lag.max = 200, main = sprintf("ACF theta[%d]", idx[3]))
hist(lam, breaks = 60, main = "posterior of lambda", xlab = "lambda", col = "grey80", border = "white")
hist(sig, breaks = 60, main = "posterior of sigma", xlab = "sigma", col = "grey80", border = "white")
plot(TH[, idx[3]], lam, pch = ".", main = sprintf("lambda vs theta[%d]", idx[3]), xlab = "theta", ylab = "lambda")
dev.off()
cat("done\n")
