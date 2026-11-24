# E-08: one P-MALA fit (VS baseline, Normal noise, n = 500, data seed 1, k = 2) under one of two Gamma(a0 = 1, b0) priors on lambda.
# Usage: Rscript e08_run.R OUT_DIR TASK_ID [ITER BURN]
#   TASK_ID 1..10 indexes the grid arm x tau (arm varies slowest):
#     1-5  = "new"   (b0 = 1e-5), tau = 0.05 0.25 0.50 0.75 0.95
#     6-10 = "paper" (b0 = 1e-3), same taus
#   ITER/BURN (default 30000/10000) are for smoke tests only.
# Repo root: env BQTF_REPO wins; otherwise two levels above this script's directory.
# Output: OUT_DIR/fits/<arm>_t<100*tau>.rds  (theta draws are NOT saved).
options(warn = 1)
args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 2L && length(args) != 4L) stop("Usage: Rscript e08_run.R OUT_DIR TASK_ID [ITER BURN]")
e08_out <- args[1]   # NB: the sampler Settings block overwrites a global named out_dir, hence the e08_ name
task_id <- suppressWarnings(as.integer(args[2]))
iter <- if (length(args) == 4L) as.integer(args[3]) else 30000L
burn <- if (length(args) == 4L) as.integer(args[4]) else 10000L

grid <- expand.grid(tau = c(0.05, 0.25, 0.50, 0.75, 0.95), arm = c("new", "paper"), stringsAsFactors = FALSE)
grid$b0 <- ifelse(grid$arm == "new", 1e-5, 1e-3)
stopifnot(!is.na(task_id), task_id %in% seq_len(nrow(grid)), iter > burn, burn >= 1L)
row <- grid[task_id, ]

script_dir <- local({
  f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  if (length(f)) dirname(normalizePath(f[1])) else getwd()
})
repo <- Sys.getenv("BQTF_REPO", unset = "")
if (!nzchar(repo)) repo <- normalizePath(file.path(script_dir, "..", ".."), mustWork = TRUE)
ind_dir <- file.path(repo, "method", "individual")
sampler_file <- file.path(ind_dir, "Individual_Sampler_PMALA_Augmented.R")
cpp_file <- file.path(ind_dir, "prox_admm_metric.cpp")
stopifnot(file.exists(sampler_file), file.exists(cpp_file))

# Rcpp build cache: never inside method/. E08_CACHE if set (Slurm), else under tempdir() (honours TMPDIR).
cache <- Sys.getenv("E08_CACHE", unset = file.path(tempdir(), paste0("rcpp_cache_e08_", task_id)))
dir.create(cache, recursive = TRUE, showWarnings = FALSE)
options(rcpp.cache.dir = cache)

# Source only the definitions/settings before "# ---- Main" (as the campaign's common.R load_sampler does).
# The Settings block calls .script_dir(), which searches the working directory upwards for prox_admm_metric.cpp,
# so evaluate from method/individual (setwd only changes the process cwd; nothing is written there).
local({
  old <- setwd(ind_dir); on.exit(setwd(old))
  lines <- readLines(sampler_file, warn = FALSE)
  main <- grep("^# ---- Main", lines)
  stopifnot(length(main) == 1L)
  eval(parse(text = lines[seq_len(main - 1L)]), envir = globalenv())
})
load_prox_cpp(cpp_file)
stopifnot(requireNamespace("coda", quietly = TRUE))

# Paper VS specification, copied from experiments/interior_quantiles/individual_nots_20261003/VS_b0001/config.R
sampler <- list(order = 2L, a0 = 1, b0 = row$b0,
  a_sigma = 0.1, b_sigma = 0.1, gibbs_iter = iter, gibbs_burn = burn,
  delta_init = 0.2, lambda_init = NULL,
  adapt_target = 0.50, adapt_gain = 1, adapt_kappa = 0.6,
  delta_bounds = c(1e-8, 100), metric = "curv", c_fixed = 1e4,
  rho = NULL, iters = 150L, mh = TRUE, adapt = TRUE, init = "y",
  warm = 200L, gamma_warm = 1e4, prior_scale = "none", cmap = FALSE,
  kappa = 3, adapt_all = TRUE, K = 1L, asis = TRUE, tol = 0,
  lamjump = FALSE, lamjump_s = 0.3, verbose = FALSE)
tf_ctrl <- glmgen::trendfilter.control.list(max_iter = 2000L, obj_tol = 1e-8)

dat <- simulate_data(seed = 1L, n = 500L, tau = row$tau, "VS", "Normal")
set.seed(1L + 1000L)                       # identical sampler RNG for both arms
fit <- do.call(gibbs_pmala_aug, c(list(y = dat$y, tau = row$tau, control = tf_ctrl), sampler))

post <- seq.int(burn + 1L, iter)
stopifnot(nrow(fit$theta) == length(post), ncol(fit$theta) == length(dat$y), all(is.finite(fit$theta)))
if (length(fit$lambda) == iter) lam <- fit$lambda[post] else if (length(fit$lambda) == length(post)) lam <- fit$lambda else stop("unexpected lambda chain length ", length(fit$lambda))
if (length(fit$sigma) == iter) sig <- fit$sigma[post] else if (length(fit$sigma) == length(post)) sig <- fit$sigma else stop("unexpected sigma chain length ", length(fit$sigma))
cat(sprintf("chain lengths: lambda %d sigma %d theta rows %d (iter %d burn %d)\n",
            length(fit$lambda), length(fit$sigma), nrow(fit$theta), iter, burn))

ess <- function(v) as.numeric(coda::effectiveSize(v))
res <- list(
  arm = row$arm, tau = row$tau, a0 = 1, b0 = row$b0, task_id = task_id, iter = iter, burn = burn,
  x = dat$x, y = dat$y, truth = dat$truth, baseline = dat$baseline,
  theta_mean = colMeans(fit$theta),
  theta_lo = apply(fit$theta, 2, quantile, probs = 0.025, type = 7),
  theta_hi = apply(fit$theta, 2, quantile, probs = 0.975, type = 7),
  lambda = lam, sigma = sig,
  ess_lambda = ess(lam), ess_sigma = ess(sig), ess_lambda_sigma = ess(lam * sig),
  ess_theta_median = median(apply(fit$theta, 2, ess)),
  acc_post = fit$acc_post, seconds = fit$seconds,
  session_info = paste(capture.output(sessionInfo()), collapse = "\n"))
rm(fit)
dir.create(file.path(e08_out, "fits"), recursive = TRUE, showWarnings = FALSE)
path <- file.path(e08_out, "fits", sprintf("%s_t%d.rds", row$arm, as.integer(round(100 * row$tau))))
tmp <- paste0(path, ".tmp-", Sys.getpid())
saveRDS(res, tmp); stopifnot(file.rename(tmp, path))
unlink(cache, recursive = TRUE)
cat(sprintf("E08_DONE task %d arm %s tau %.2f b0 %g seconds %.1f acc %.3f ESS lambda %.0f sigma %.0f lam*sig %.0f theta(med) %.0f -> %s\n",
  task_id, row$arm, row$tau, row$b0, res$seconds, res$acc_post, res$ess_lambda, res$ess_sigma,
  res$ess_lambda_sigma, res$ess_theta_median, path))
