# Remote numerical validation: reconstruct summaries from every saved tiny-run chain.
args_validation <- commandArgs(trailingOnly=TRUE)
run_root <- normalizePath(args_validation[1], mustWork=TRUE)
source(file.path(run_root, "code", "config.R")); source(file.path(run_root, "code", "common.R"))
stopifnot(isTRUE(cfg$validation))
grid_validation <- task_grid(cfg)
load_sampler(file.path(run_root, "code"), compile=FALSE)
metric_rows <- vector("list", nrow(grid_validation))
for (i in seq_len(nrow(grid_validation))) {
  row <- grid_validation[i, , drop=FALSE]
  attempt <- readLines(file.path(run_root, "tasks", task_relpath(row), "SUCCESS"))
  saved <- readRDS(file.path(attempt, "summary.rds"))
  raw <- readRDS(saved$raw_path)
  stopifnot(identical(raw$config, cfg), identical(raw$task, row), identical(raw$dat, saved$dat),
    identical(raw$dat, simulate_data(row$seed, cfg$n, row$tau, row$baseline, row$noise)))
  rebuilt <- summarize_fit(raw$fit, raw$dat, cfg, row)
  stopifnot(identical(rebuilt$est, saved$est), identical(rebuilt$lo, saved$lo),
    identical(rebuilt$hi, saved$hi), identical(rebuilt$metrics, saved$metrics))
  metric_rows[[i]] <- rebuilt$metrics
}
success <- list.files(file.path(run_root, "summary"), pattern="SUCCESS$", recursive=TRUE, full.names=TRUE)
stopifnot(length(success) == 1L)
averages <- read.csv(file.path(dirname(success), "average_metrics.csv"))
stopifnot(nrow(averages) == 30L, all(averages$n_seeds == 2L), all(averages$b0 == 0.01))
all_metrics <- do.call(rbind, metric_rows)
for (i in seq_len(nrow(averages))) {
  a <- averages[i, ]
  d <- all_metrics[all_metrics$baseline == a$baseline & all_metrics$noise == a$noise & all_metrics$tau == a$tau, ]
  for (key in c("MSE", "MAD", "MCIW", "coverage")) {
    stopifnot(isTRUE(all.equal(a[[paste0("mean_", key)]], mean(d[[key]]), tolerance=1e-12)),
      isTRUE(all.equal(a[[paste0("se_", key)]], sd(d[[key]]) / sqrt(2), tolerance=1e-12)))
  }
}
cat("VALIDATED_RAW_DRAWS_AND_ALL_30_CELL_AVERAGES", utc(), "\n")
