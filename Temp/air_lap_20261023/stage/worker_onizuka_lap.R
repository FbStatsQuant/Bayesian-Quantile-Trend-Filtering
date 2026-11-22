# Onizuka, Hashimoto and Sugasawa LAPLACE-prior BQTF worker. Usage: Rscript --vanilla worker_onizuka_lap.R RUN_DIR INDEX
# Runs BQTF.MCMC.Lap.multi of the UNCHANGED source/BQTF-function.R for one (tau, seed) with n = 500:
#   X = 1..n, TForder = 2, pp = tau, mc = 8000 draws, sparse = FALSE, sig.init = c(1, 1), set.seed(seed + 1000)
#   immediately before the call (the RNG kind is the Mersenne-Twister/Inversion/Rejection set by simulate_air(), as in
#   the horseshoe worker of the production run); retained draws 2001-8000; posterior mean and pointwise 95% band
#   (0.025 / 0.975 sample quantiles of the retained draws), exactly as ../../Air_sim/Onizuka/worker_onizuka.R does.
# The Laplace function returns only the theta draws; the sigma2/tau2 diagnostics of the horseshoe worker are NA here.
options(warn = 1)
args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 2L) stop("Usage: worker_onizuka_lap.R RUN_DIR INDEX")
run_root <- normalizePath(args[1], mustWork = TRUE)
code_root <- file.path(run_root, "code")
source(file.path(code_root, "Driver", "config.R"))
suppressPackageStartupMessages(library(splines))    # simulate_air() uses ns()
source(file.path(code_root, "Driver", "common_air.R"))
validate_config(cfg)
grid <- task_grid(cfg)
index <- suppressWarnings(as.integer(args[2]))
stopifnot(!is.na(index), as.character(index) == args[2], index %in% grid$index)
row <- grid[index, , drop = FALSE]
stopifnot(row$method == "onizuka_lap")

load_bqtf <- function(code_root) {
  env <- new.env(parent = globalenv())
  # The file opens with library(MASS, GIGrvg, invgamma, Bessel, MCMCpack). Bessel is used only by the VB/CVB routines;
  # it is skipped when absent. Everything else must load.
  env$library <- function(package, ...) {
    pkg <- as.character(substitute(package))
    if (pkg == "Bessel" && !requireNamespace(pkg, quietly = TRUE)) return(invisible(NULL))
    suppressPackageStartupMessages(base::library(pkg, character.only = TRUE))
  }
  sys.source(file.path(code_root, "Onizuka", "source", "BQTF-function.R"), envir = env)
  env
}

fit_onizuka_lap <- function(dat, row) {
  o <- cfg$onizuka
  env <- load_bqtf(code_root)
  set.seed(row$seed + cfg$sampler_seed_offset)
  rng_before <- .Random.seed
  th <- env[[o$sampler]](X = seq_len(cfg$n), Y = dat$y, TForder = cfg$order, pp = row$tau,
                         mc = o$mc, sparse = o$sparse, sig.init = o$sig.init)
  stopifnot(is.matrix(th), identical(dim(th), c(o$mc, cfg$n)))
  post <- seq.int(o$burn + 1L, o$mc)
  p <- th[post, , drop = FALSE]
  stopifnot(all(is.finite(p)))
  list(est = colMeans(p), lo = apply(p, 2, quantile, 0.025), hi = apply(p, 2, quantile, 0.975),
       diag = list(sampler = o$sampler, rng_before = rng_before,
                   sigma2_mean = NA_real_, tau2_mean = NA_real_, sigma2 = NULL, tau2 = NULL,   # not returned by the Laplace function
                   theta_mid = th[, cfg$n %/% 2L], sig_init = o$sig.init, X = "index"))
}

run_air_task(run_root, code_root, row, task_root_of(run_root, row), cfg, fit_onizuka_lap, "onizuka_lap")
