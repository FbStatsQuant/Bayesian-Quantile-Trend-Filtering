# Felipe's joint sampler (E07lamjump copy, lamjump = FALSE == his), paper settings (experiments/joint_upper_levels/config.R) except iteration counts.
# Args: iter burn out.rds
a <- commandArgs(TRUE); iter <- as.integer(a[1]); burn <- as.integer(a[2]); outf <- a[3]
ROOT <- local({ f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE)); d <- if (length(f)) dirname(normalizePath(f[1])) else getwd(); r <- tryCatch(system2("git", c("-C", shQuote(d), "rev-parse", "--show-toplevel"), stdout = TRUE, stderr = FALSE), error = function(e) character(0)); if (!length(r) || !nzchar(r[1])) stop("E07: cannot find the repo root; run from inside the checkout"); r[1] })   # E-12: repo root (Owls or NOTS), no absolute paths
.libPaths(c(file.path(ROOT, "ops/Rlib"), .libPaths()))
options(rcpp.cache.dir = file.path(ROOT, "tmp/rcpp_cache/rcpp_felipe"))   # E-12: was the session scratchpad
setwd(ROOT)
L <- readLines("engineering/E07_Tuning_Free/joint/Joint_Sampler_PMALA_Augmented_E07lamjump.R"); k <- grep("^# ---- Main", L)[1]
e <- new.env(parent = globalenv()); eval(parse(text = L[seq_len(k - 1)]), e)
eval(quote(load_box_cpp(joint_dir = file.path(ROOT, "method/joint"), ind_dir = file.path(ROOT, "method/individual"))), e)
taus <- c(0.90, 0.93, 0.96, 0.97, 0.98, 0.99)
d <- e$simulate_data(1, 500L, taus, "VS", "Normal")
truths <- sapply(taus, function(t) e$simulate_data(1, 500L, t, "VS", "Normal")$truth)
set.seed(1 + 1000)
fit <- e$gibbs_joint_pmala(d$y, taus, order = 2L, a0 = 1, b0 = 0.01, a_sigma = 0.1, b_sigma = 0.1, gibbs_iter = iter, gibbs_burn = burn,
  delta_init = 0.2, lambda_init = NULL, adapt_target = 0.5, adapt_gain = 1, adapt_kappa = 0.6, delta_bounds = c(1e-8, 100), metric = "curv",
  c_fixed = 1e4, rho = NULL, iters = 150L, mh = TRUE, adapt = TRUE, warm = 200L, gamma_warm = 1e4, kappa = 3, adapt_all = TRUE, K = 1L,
  asis = TRUE, tol = 0, zeta_scale = 1, ctrl = c(method = 1, try_unbounded = 1, ipm_max_iter = 100, ipm_tol = 1e-8, trace = 0),
  verbose = TRUE, keep_every = 1L, lamjump = FALSE)
est <- apply(fit$theta, c(2, 3), mean)
cross <- sum(apply(fit$theta, 1, function(M) sum(apply(M, 1, is.unsorted))))
cat(sprintf("done: %d iter in %.1f s (%.3f s/iter), crossings %d\n", iter, fit$seconds, fit$seconds / iter, cross))
saveRDS(list(est = est, truths = truths, taus = taus, lambda = fit$lambda, sigma = fit$sigma, acc_post = fit$acc_post, seconds = fit$seconds, iter = iter, burn = burn, cross = cross), outf)
