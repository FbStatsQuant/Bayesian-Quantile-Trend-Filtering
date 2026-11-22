# ADMM/QTF worker (Brantley et al. 2020, eBIC). Usage: Rscript --vanilla worker_admm.R RUN_DIR INDEX
options(warn = 1)
args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 2L) stop("Usage: worker_admm.R RUN_DIR INDEX")
run_root <- normalizePath(args[1], mustWork = TRUE)
code_root <- file.path(run_root, "code")
source(file.path(code_root, "Extreme_Individual", "config.R"))
source(file.path(code_root, "Extreme_Individual", "common_extreme.R"))
source(file.path(code_root, "Extreme_admm", "qtf_lp_ebic.R"))
validate_config(cfg)
grid <- task_grid(cfg)
index <- suppressWarnings(as.integer(args[2]))
stopifnot(!is.na(index), as.character(index) == args[2], index %in% grid$index)
row <- grid[index, , drop = FALSE]
stopifnot(row$method == "admm")

fit_admm <- function(dat, row) {
  f <- qtf_ebic_path(dat$y, row$tau, cfg$order, cfg$admm)
  list(est = f$est, diag = f[c("path", "selected", "lambda", "boundary", "n_failed", "n_retried", "piqp_version")])
}

run_extreme_task(run_root, code_root, row, task_root_of(run_root, row), cfg, cfg$taus, fit_admm, "admm")
