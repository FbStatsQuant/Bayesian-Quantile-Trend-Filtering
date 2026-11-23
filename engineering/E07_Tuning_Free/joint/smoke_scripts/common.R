.libPaths(c("/home/fb31/R/e02lib", .libPaths()))
options(rcpp.cache.dir = "/tmp/claude-71711/-home-fb31-Bayesian-Quantile-Trend-Filtering/5a5aaa0b-5c86-47ef-8fba-2096636ee464/scratchpad/rcpp")
setwd("/home/fb31/Bayesian-Quantile-Trend-Filtering")
load_env <- function(path) {            # source everything before "# ---- Main" into a fresh env (no main run)
  L <- readLines(path); k <- grep("^# ---- Main", L)[1]
  e <- new.env(parent = globalenv()); eval(parse(text = L[seq_len(k - 1)]), e); e
}
e_new <- load_env("engineering/E07_Tuning_Free/joint/Joint_Sampler_PMALA_Augmented_E07lamjump.R")
e_old <- load_env("method/joint/Joint_Sampler_PMALA_Augmented.R")
eval(quote(load_box_cpp(joint_dir = "/home/fb31/Bayesian-Quantile-Trend-Filtering/method/joint", ind_dir = "/home/fb31/Bayesian-Quantile-Trend-Filtering/method/individual")), e_new)
cfg <- list(order = 2L, a0 = 1, b0 = 0.01, a_sigma = 0.1, b_sigma = 0.1, delta_init = 0.2, lambda_init = NULL,
  adapt_target = 0.50, adapt_gain = 1, adapt_kappa = 0.6, delta_bounds = c(1e-8, 100), metric = "curv", c_fixed = 1e4, rho = NULL,
  iters = 150L, mh = TRUE, adapt = TRUE, warm = 200L, gamma_warm = 1e4, kappa = 3, adapt_all = TRUE, K = 1L, asis = TRUE, tol = 0,
  zeta_scale = 1, ctrl = c(method = 1, try_unbounded = 1, ipm_max_iter = 100, ipm_tol = 1e-8, trace = 0), verbose = TRUE, keep_every = 1L)
run <- function(e, y, taus, iter, burn, seed, ...) {
  set.seed(seed)
  do.call(e$gibbs_joint_pmala, c(list(y = y, tau_list = taus, gibbs_iter = iter, gibbs_burn = burn), cfg, list(...)))
}
