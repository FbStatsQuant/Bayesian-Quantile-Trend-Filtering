# worker.R: runs ONE model fit.
# Slurm starts 3,000 copies of this script, numbered 1 to 3,000.

# 1) Which fit am I?
grid <- expand.grid(
  seed     = 1:100,
  tau      = c(0.05, 0.25, 0.50, 0.75, 0.95),
  noise    = c("Normal", "Beta", "Mixed"),
  baseline = c("VS", "S"),
  stringsAsFactors = FALSE)       # 3,000 rows
id <- as.integer(Sys.getenv("SLURM_ARRAY_TASK_ID"))
my <- grid[id, ]

# 2) Load the sampler (functions + default settings)
source("sampler.R")
load_prox_cpp(cpp_src)            # compile the C++ part

# 3) Settings for this study
b0 <- 0.001       # lambda ~ Gamma(1, 0.001)
if (my$baseline == "VS") {
  gibbs_iter <- 30000; gibbs_burn <- 10000
}
if (my$baseline == "S") {
  gibbs_iter <- 20000; gibbs_burn <- 5000
  asis_lambda <- FALSE
}

# 4) Simulate the data, run the sampler
dat <- simulate_data(my$seed, n, my$tau,
                     my$baseline, my$noise)
set.seed(my$seed + 1000)          # MCMC seed
fit <- gibbs_pmala_aug(dat$y, my$tau, order, a0, b0, a_sigma, b_sigma,
  gibbs_iter, gibbs_burn, delta_init, lambda_init,
  adapt_target, adapt_gain, adapt_kappa, delta_bounds, tf_control,
  metric = metric, c_fixed = c_metric, rho = admm_rho, iters = admm_iter,
  mh = mh_correct, adapt = adapt_delta, init = theta_init,
  warm = warm_sweeps, gamma_warm = gamma_warm, K = K_theta,
  asis = asis_lambda, tol = admm_tol, lamjump = lamjump, lamjump_s = lamjump_s,
  prior_scale = prior_scale, cmap = FALSE, kappa = kappa_metric,
  adapt_all = adapt_all, verbose = FALSE)

# 5) Summarise and save
est <- colMeans(fit$theta)        # posterior mean
lo  <- apply(fit$theta, 2, quantile, 0.025)
hi  <- apply(fit$theta, 2, quantile, 0.975)
out <- data.frame(my,
  mse      = mean((est - dat$truth)^2),
  mad      = mean(abs(est - dat$truth)),
  mciw     = mean(hi - lo),
  coverage = mean(dat$truth >= lo & dat$truth <= hi))
write.csv(out, sprintf("results/fit_%04d.csv", id),
          row.names = FALSE)
