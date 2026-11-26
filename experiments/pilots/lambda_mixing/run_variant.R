# lambda-mixing variant runner (HQ, 2026-11-25). Same data and settings as ../default_prior_VS_normal_t075/run.R
# (VS, Normal, tau 0.75, n 500, seed 1, order 2, lambda ~ Gamma(1, 1e-5), sigma ~ IG(0.1, 0.1)), with overrides.
# Usage (repo root): owls_run -j 1 -- Rscript experiments/pilots/lambda_mixing/run_variant.R <name> [key=value ...]
#   keys: any setting of the canonical settings block (K_theta, asis_lambda, gibbs_iter, gibbs_burn, lambda_init, ...)
#   plus chain_seed (RNG seed of the chain; the data seed stays 1).
suppressPackageStartupMessages(library(coda))
args <- commandArgs(trailingOnly = TRUE); name <- args[1]; kv <- args[-1]
if (any(sub("=.*", "", kv) %in% c("lamjump", "lamjump_s")))
  stop("The lambda jump was removed from the individual sampler.")
src  <- "method/individual/Individual_Sampler_PMALA_Augmented.R"
lines <- readLines(src); main_at <- grep("^# ---- Main", lines)[1]
setwd(dirname(src)); eval(parse(text = lines[seq_len(main_at - 1)]), envir = globalenv()); setwd("../..")
out_dir <- "experiments/pilots/lambda_mixing/results"; dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

order <- 2L; a0 <- 1; b0 <- 1e-5; a_sigma <- 0.1; b_sigma <- 0.1
baseline_id <- "VS"; noise_id <- "Normal"; tau <- 0.75; seed <- 1; n <- 500L; chain_seed <- seed + 1000
for (s in kv) { k <- sub("=.*", "", s); v <- sub("^[^=]*=", "", s); assign(k, eval(parse(text = v)), envir = globalenv()) }
if (exists("asis_q") && asis_q > order + 1) {          # generalised ASIS: hold a q-dim cubic-spline part fixed (asis_general.R)
  source("experiments/pilots/lambda_mixing/asis_general.R")
  null_basis <- function(n, order) spline_basis(n, asis_q)
  asis_step  <- function(theta, lambda, a, r, a0, b0, Q, w = 1, max_steps = 30L) asis_step_g(theta, lambda, a, r, a0, b0, Q, order, w, max_steps)
}
gibbs_iter <- as.integer(gibbs_iter); gibbs_burn <- as.integer(gibbs_burn); K_theta <- as.integer(K_theta)

load_prox_cpp(cpp_src)
dat <- simulate_data(seed, n, tau, baseline_id, noise_id)
set.seed(chain_seed)
fit <- gibbs_pmala_aug(dat$y, tau, order, a0, b0, a_sigma, b_sigma,
                       gibbs_iter, gibbs_burn, delta_init, lambda_init,
                       adapt_target, adapt_gain, adapt_kappa, delta_bounds, tf_control,
                       metric = metric, c_fixed = c_metric, rho = admm_rho, iters = admm_iter,
                       mh = mh_correct, adapt = adapt_delta, init = theta_init, warm = warm_sweeps, gamma_warm = gamma_warm,
                       K = K_theta, asis = asis_lambda, tol = admm_tol,
                       prior_scale = prior_scale, cmap = FALSE, kappa = kappa_metric, adapt_all = adapt_all, verbose = FALSE)
post <- (gibbs_burn + 1):gibbs_iter
lam <- fit$lambda[post]; sig <- fit$sigma[post]; TH <- fit$theta
est <- colMeans(TH); lo <- apply(TH, 2, quantile, .025); hi <- apply(TH, 2, quantile, .975)
ess_th <- apply(TH, 2, function(v) as.numeric(effectiveSize(v))); mins <- fit$seconds / 60
res <- data.frame(name = name, overrides = paste(kv, collapse = " "), sweeps = gibbs_iter, burn = gibbs_burn,
                  minutes = round(mins, 2), acc = round(fit$acc_post, 3),
                  mse = signif(mean((est - dat$truth)^2), 4), coverage = round(mean(dat$truth >= lo & dat$truth <= hi), 3),
                  lam_mean = signif(mean(lam), 4), lam_ess = round(effectiveSize(lam), 1),
                  lam_ess_per_min = round(effectiveSize(lam) / mins, 2),
                  th_ess_median = round(median(ess_th)), th_ess_min = round(min(ess_th)),
                  th_ess_med_per_min = round(median(ess_th) / mins, 1),
                  sig_ess = round(effectiveSize(sig)))
print(t(res))
write.csv(res, file.path(out_dir, paste0(name, ".csv")), row.names = FALSE)
saveRDS(list(lambda = fit$lambda, sigma = fit$sigma, theta_mid = TH[, c(50, 150, 250, 350, 450)], est = est, lo = lo, hi = hi),
        file.path(out_dir, paste0(name, ".rds")))
png(file.path(out_dir, paste0(name, "_lambda.png")), width = 1400, height = 500, res = 120)
plot(fit$lambda, type = "l", log = "y", main = sprintf("%s | lambda ESS %.1f (%.2f/min) | MSE %.5f", name,
     res$lam_ess, res$lam_ess_per_min, res$mse), xlab = "sweep", ylab = "lambda"); abline(v = gibbs_burn, lty = 3, col = "red")
dev.off()
