# Felipe's joint sampler (worker copy, lamjump = FALSE) on the joint smoke design. Args: iter burn out.rds
a <- commandArgs(TRUE); iter <- as.integer(a[1]); burn <- as.integer(a[2]); outf <- a[3]
.libPaths(c("/home/fb31/R/e02lib", .libPaths()))
SCR <- "/tmp/claude-71711/-home-fb31-Bayesian-Quantile-Trend-Filtering/7aecef86-4e46-4d00-a632-302610e27229/scratchpad"
options(rcpp.cache.dir = file.path(SCR, "rcpp_felipe")); dir.create(file.path(SCR, "rcpp_felipe"), showWarnings = FALSE)
ROOT <- "/home/fb31/Bayesian-Quantile-Trend-Filtering"; setwd(ROOT)
L <- readLines("engineering/E07_Tuning_Free/joint/Joint_Sampler_PMALA_Augmented_E07lamjump.R"); k <- grep("^# ---- Main", L)[1]
e <- new.env(parent = globalenv()); eval(parse(text = L[seq_len(k - 1)]), e)
eval(quote(load_box_cpp(joint_dir = "/home/fb31/Bayesian-Quantile-Trend-Filtering/method/joint", ind_dir = "/home/fb31/Bayesian-Quantile-Trend-Filtering/method/individual")), e)
taus <- c(0.90, 0.93, 0.96, 0.97, 0.98, 0.99)
d <- e$simulate_data(1, 500L, taus, "VS", "Normal")
set.seed(1 + 1000)
fit <- e$gibbs_joint_pmala(d$y, taus, order = 2L, a0 = 1, b0 = 0.01, a_sigma = 0.1, b_sigma = 0.1, gibbs_iter = iter, gibbs_burn = burn,
  delta_init = 0.2, lambda_init = NULL, adapt_target = 0.5, adapt_gain = 1, adapt_kappa = 0.6, delta_bounds = c(1e-8, 100), metric = "curv",
  c_fixed = 1e4, rho = NULL, iters = 150L, mh = TRUE, adapt = TRUE, warm = 200L, gamma_warm = 1e4, kappa = 3, adapt_all = TRUE, K = 1L,
  asis = TRUE, tol = 0, zeta_scale = 1, ctrl = c(method = 1, try_unbounded = 1, ipm_max_iter = 100, ipm_tol = 1e-8, trace = 0),
  verbose = TRUE, keep_every = 1L, lamjump = FALSE)
est <- apply(fit$theta, c(2, 3), mean)
cat(sprintf("done: %d iter in %.1f s (%.3f s/iter)\n", iter, fit$seconds, fit$seconds / iter))
saveRDS(list(est = est, truth = d$truth, lambda = fit$lambda, sigma = fit$sigma, acc_post = fit$acc_post, outside_post = fit$outside_post,
  asis_moved_post = fit$asis_moved_post, seconds = fit$seconds, iter = iter, burn = burn, cross = sum(apply(fit$theta, 1, function(M) sum(apply(M, 1, is.unsorted))))), outf)
