# Usage: Rscript --vanilla process_results.R RUN_DIR
# Verifies all 9,600 individual tasks (4 methods), then writes per-task MSE, per-seed crossings and
# cell averages under RUN_DIR/summary/attempt_*/. Refuses to average an incomplete or invalid run.
options(warn = 1)
args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 1L) stop("Usage: process_results.R RUN_DIR")
run_root <- normalizePath(args[1], mustWork = TRUE)
code_root <- file.path(run_root, "code")
source(file.path(code_root, "Extreme_Individual", "config.R"))
source(file.path(code_root, "Extreme_Individual", "common_extreme.R"))
validate_config(cfg)
process_campaign(run_root, cfg, task_grid(cfg), task_root_of, cfg$taus)
