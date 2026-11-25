ROOT <- local({ f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE)); d <- if (length(f)) dirname(normalizePath(f[1])) else getwd(); r <- tryCatch(system2("git", c("-C", shQuote(d), "rev-parse", "--show-toplevel"), stdout = TRUE, stderr = FALSE), error = function(e) character(0)); if (!length(r) || !nzchar(r[1])) stop("E07: cannot find the repo root; run from inside the checkout"); r[1] })   # E-12: repo root (Owls or NOTS), no absolute paths
.libPaths(c(file.path(ROOT, "ops/Rlib"), .libPaths()))
options(rcpp.cache.dir = file.path(ROOT, "tmp/rcpp_cache"))
setwd(ROOT)
load_env <- function(path) {            # source everything before "# ---- Main" into a fresh env (no main run)
  L <- readLines(path); k <- grep("^# ---- Main", L)[1]
  e <- new.env(parent = globalenv()); eval(parse(text = L[seq_len(k - 1)]), e); e
}
e_new <- load_env("engineering/E07_Tuning_Free/joint/Joint_Sampler_PMALA_Augmented_E07lamjump.R")
e_old <- load_env("method/joint/Joint_Sampler_PMALA_Augmented.R")
eval(quote(load_box_cpp(joint_dir = file.path(ROOT, "method/joint"), ind_dir = file.path(ROOT, "method/individual"))), e_new)
cfg <- list(order = 2L, a0 = 1, b0 = 0.01, a_sigma = 0.1, b_sigma = 0.1, delta_init = 0.2, lambda_init = NULL,
  adapt_target = 0.50, adapt_gain = 1, adapt_kappa = 0.6, delta_bounds = c(1e-8, 100), metric = "curv", c_fixed = 1e4, rho = NULL,
  iters = 150L, mh = TRUE, adapt = TRUE, warm = 200L, gamma_warm = 1e4, kappa = 3, adapt_all = TRUE, K = 1L, asis = TRUE, tol = 0,
  zeta_scale = 1, ctrl = c(method = 1, try_unbounded = 1, ipm_max_iter = 100, ipm_tol = 1e-8, trace = 0), verbose = TRUE, keep_every = 1L)
run <- function(e, y, taus, iter, burn, seed, ...) {
  set.seed(seed)
  do.call(e$gibbs_joint_pmala, c(list(y = y, tau_list = taus, gibbs_iter = iter, gibbs_burn = burn), cfg, list(...)))
}
