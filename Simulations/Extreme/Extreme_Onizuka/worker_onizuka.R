# Onizuka BQTF MCMC worker (Laplace or horseshoe prior). Usage: Rscript --vanilla worker_onizuka.R RUN_DIR INDEX
# Runs the original, unchanged BQTF-function.R (source/). Tuning free: X = 1, ..., n (as in
# Onizuka_BQTF_Individual.R and the earlier NOTS campaigns), TForder = k = 2, sig.init = c(1, 1),
# sparse = FALSE; mc = cfg$mcmc_iter draws, the first cfg$mcmc_burn discarded; posterior mean reported.
options(warn = 1)
args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 2L) stop("Usage: worker_onizuka.R RUN_DIR INDEX")
run_root <- normalizePath(args[1], mustWork = TRUE)
code_root <- file.path(run_root, "code")
source(file.path(code_root, "Extreme_Individual", "config.R"))
source(file.path(code_root, "Extreme_Individual", "common_extreme.R"))
validate_config(cfg)
grid <- task_grid(cfg)
index <- suppressWarnings(as.integer(args[2]))
stopifnot(!is.na(index), as.character(index) == args[2], index %in% grid$index)
row <- grid[index, , drop = FALSE]
stopifnot(row$method %in% c("onizuka_lap", "onizuka_hs"))

load_bqtf <- function(code_root) {
  env <- new.env(parent = globalenv())
  # The file opens with library(MASS, GIGrvg, invgamma, Bessel, MCMCpack). Bessel is used only by the
  # VB/CVB routines; it is skipped when absent (as in Onizuka_BQTF_Individual.R). Everything else must load.
  env$library <- function(package, ...) {
    pkg <- as.character(substitute(package))
    if (pkg == "Bessel" && !requireNamespace(pkg, quietly = TRUE)) return(invisible(NULL))
    suppressPackageStartupMessages(base::library(pkg, character.only = TRUE))
  }
  sys.source(file.path(code_root, "Extreme_Onizuka", "source", "BQTF-function.R"), envir = env)
  env
}

fit_onizuka <- function(dat, row) {
  env <- load_bqtf(code_root)
  fname <- c(onizuka_lap = "BQTF.MCMC.Lap.multi", onizuka_hs = "BQTF.MCMC.HS.multi")[[row$method]]
  set.seed(row$seed + cfg$sampler_seed_offset)
  rng_before <- .Random.seed
  th <- env[[fname]](X = seq_len(cfg$n), Y = dat$y, TForder = cfg$order, pp = row$tau,
                     mc = cfg$mcmc_iter, sparse = cfg$onizuka$sparse, sig.init = cfg$onizuka$sig.init)
  stopifnot(is.matrix(th), identical(dim(th), c(cfg$mcmc_iter, cfg$n)))
  post <- th[seq.int(cfg$mcmc_burn + 1L, cfg$mcmc_iter), , drop = FALSE]
  stopifnot(all(is.finite(post)))
  list(est = colMeans(post),
       diag = list(sampler = fname, rng_before = rng_before, theta_mid = th[, cfg$n %/% 2L],
                   sig_init = cfg$onizuka$sig.init, X = "index"))
}

run_extreme_task(run_root, code_root, row, task_root_of(run_root, row), cfg, cfg$taus, fit_onizuka, row$method)
