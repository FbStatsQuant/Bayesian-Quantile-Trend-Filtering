options(warn = 1)
# Usage: process_results.R RUN_DIR [--pilot]
# Full mode refuses incomplete/invalid runs. Pilot mode summarises the completed tasks only and never
# writes average_metrics.csv or a SUCCESS marker.
process_args <- commandArgs(trailingOnly = TRUE)
if (!length(process_args) %in% 1:2 || (length(process_args) == 2L && process_args[2] != "--pilot"))
  stop("Usage: process_results.R RUN_DIR [--pilot]")
pilot <- length(process_args) == 2L
run_root <- normalizePath(process_args[1], mustWork = TRUE)
code_root <- file.path(run_root, "code")
source(file.path(code_root, "config.R")); source(file.path(code_root, "common.R"))
validate_config(cfg)
grid_process <- task_grid(cfg)
# Each processing attempt has its own directory; failed retries cannot leave stale averages.
summary_root <- file.path(run_root, "summary", paste0(if (pilot) "pilot_" else "attempt_",
  format(Sys.time(), "%Y%m%dT%H%M%S", tz="UTC"), "_", Sys.getpid()))
stopifnot(dir.create(summary_root, recursive = TRUE))
manifest <- readLines(file.path(code_root, "SHA256SUMS"))
rows <- vector("list", nrow(grid_process)); problems <- rep("", nrow(grid_process))
estimates <- vector("list", nrow(grid_process))
reference_data <- new.env(parent=emptyenv())
for (i in seq_len(nrow(grid_process))) {
  row <- grid_process[i, , drop=FALSE]
  task <- file.path(run_root, "tasks", task_relpath(row))
  rows[[i]] <- tryCatch({
    marker <- file.path(task, "SUCCESS")
    if (!file.exists(marker)) stop("missing SUCCESS marker")
    attempt <- readLines(marker)
    stopifnot(length(attempt) == 1L, dirname(attempt) == task)
    check <- system2("sha256sum", c("--check", "--quiet", shQuote(file.path(attempt, "OUTPUT_SHA256SUMS"))),
      stdout=TRUE, stderr=TRUE)
    if (!is.null(attr(check, "status"))) stop("output SHA256 verification failed: ", paste(check, collapse="; "))
    x <- readRDS(file.path(attempt, "summary.rds"))
    stopifnot(identical(x$config, cfg), identical(x$task, row),
      identical(x$source_sha256, manifest), x$attempt == attempt, file.exists(x$raw_path),
      identical(x$metrics$task_id, row$task_id), x$metrics$b0 == cfg$sampler$b0,
      length(x$est) == cfg$n, length(x$lo) == cfg$n, length(x$hi) == cfg$n,
      length(x$dat$truth) == cfg$n, all(x$hi >= x$lo))
    recalculated <- curve_metrics(x$est, x$lo, x$hi, x$dat$truth)
    stopifnot(all(is.finite(recalculated)),
      isTRUE(all.equal(unname(unlist(x$metrics[names(recalculated)])), unname(recalculated), tolerance=1e-12)))
    # All five quantiles must use the identical generated response for each data seed.
    data_key <- paste(row$baseline, row$noise, row$seed, sep="_")
    if (exists(data_key, reference_data, inherits=FALSE)) {
      stopifnot(identical(get(data_key, reference_data), x$dat$y))
    } else assign(data_key, x$dat$y, reference_data)
    estimates[[i]] <- x$est
    x$metrics
  }, error=function(e) { problems[i] <<- conditionMessage(e); NULL })
  if (i %% 100L == 0L) cat("INSPECTED", i, "of", nrow(grid_process), utc(), "\n")
}
status <- cbind(grid_process, valid=problems == "", problem=problems)
write.csv(status, file.path(summary_root, "task_status.csv"), row.names=FALSE)
missing <- problems == "missing SUCCESS marker"
if (pilot) {
  bad <- nzchar(problems) & !missing
  if (any(bad)) stop(sum(bad), " invalid completed tasks: ", summary_root)
  if (!any(!missing)) stop("No completed tasks: ", summary_root)
} else if (any(nzchar(problems))) {
  stop(sum(nzchar(problems)), " incomplete/invalid tasks; no averages written: ", summary_root)
}
all_metrics <- do.call(rbind, rows)
# Adjacent-level crossings for every (noise, seed) whose five levels are all complete.
crossings <- do.call(rbind, lapply(split(which(!nzchar(problems)),
    paste(grid_process$noise, grid_process$seed)[!nzchar(problems)]), function(ids) {
  if (length(ids) != length(cfg$taus)) return(NULL)
  est_by_tau <- setNames(estimates[ids], sprintf("%.2f", grid_process$tau[ids]))
  cbind(grid_process[ids[1], c("baseline", "noise", "seed")], count_crossings(est_by_tau), row.names=NULL)
}))
write.csv(all_metrics, file.path(summary_root, "per_seed_metrics.csv"), row.names=FALSE)
if (!is.null(crossings)) write.csv(crossings, file.path(summary_root, "crossings_adjacent.csv"), row.names=FALSE)
if (pilot) {
  hash_files(list.files(summary_root, full.names=TRUE), file.path(summary_root, "OUTPUT_SHA256SUMS"))
  print(all_metrics[c("noise", "tau", "seed", "MSE", "MAD", "MCIW", "coverage", "acc_post",
    "lambda_first_half", "lambda_second_half", "ess_log_lambda", "ess_theta_mid", "seconds")], row.names=FALSE)
  if (!is.null(crossings)) print(crossings, row.names=FALSE)
  cat("PILOT_SUMMARY", sum(!missing), "completed tasks", summary_root, utc(), "\n")
  quit(save="no")
}
cells <- expand.grid(tau=cfg$taus, noise=cfg$noises, baseline=cfg$baselines, stringsAsFactors=FALSE)
averages <- do.call(rbind, lapply(seq_len(nrow(cells)), function(i) {
  cell <- cells[i, , drop=FALSE]
  d <- all_metrics[all_metrics$baseline == cell$baseline & all_metrics$noise == cell$noise &
    all_metrics$tau == cell$tau, ]
  stopifnot(nrow(d) == length(cfg$seeds), identical(sort(d$seed), cfg$seeds))
  out <- cbind(cell, n_seeds=nrow(d), a0=cfg$sampler$a0, b0=cfg$sampler$b0)
  for (key in c("MSE", "MAD", "MCIW", "coverage")) {
    out[[paste0("mean_", key)]] <- mean(d[[key]])
    out[[paste0("se_", key)]] <- sd(d[[key]]) / sqrt(nrow(d))
  }
  out$median_MSE <- median(d$MSE)
  out$mean_acc_post <- mean(d$acc_post)
  out$median_ess_log_lambda <- median(d$ess_log_lambda)
  out$median_ess_theta_mid <- median(d$ess_theta_mid)
  out$mean_seconds <- mean(d$seconds)
  out
}))
crossing_averages <- aggregate(crossings ~ noise + tau_low + tau_high, data=crossings, FUN=mean)
write.csv(averages, file.path(summary_root, "average_metrics.csv"), row.names=FALSE)
write.csv(crossing_averages, file.path(summary_root, "average_crossings.csv"), row.names=FALSE)
atomic_rds(list(config=cfg, averages=averages, per_seed=all_metrics, crossings=crossings,
  source_sha256=manifest, processed_utc=utc()), file.path(summary_root, "results.rds"))
capture.output(sessionInfo(), file=file.path(summary_root, "sessionInfo.txt"))
hash_files(list.files(summary_root, full.names=TRUE), file.path(summary_root, "OUTPUT_SHA256SUMS"))
writeLines(utc(), file.path(summary_root, "SUCCESS"))
print(averages, row.names=FALSE)
print(crossing_averages, row.names=FALSE)
cat("PROCESS_SUCCESS", summary_root, utc(), "\n")
