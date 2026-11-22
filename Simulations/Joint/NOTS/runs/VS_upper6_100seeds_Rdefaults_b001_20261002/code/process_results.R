options(warn = 1)
args_process <- commandArgs(trailingOnly = TRUE)
if (length(args_process) != 1L) stop("Usage: process_results.R RUN_DIR")
run_root <- normalizePath(args_process[1], mustWork = TRUE)
code_root <- file.path(run_root, "code")
source(file.path(code_root, "config.R")); source(file.path(code_root, "common.R"))
validate_config(cfg)
summary_root <- file.path(run_root, "summary")
dir.create(summary_root, showWarnings = FALSE)
manifest <- readLines(file.path(code_root, "SHA256SUMS"))
grid <- expand.grid(seed = cfg$seeds, noise = cfg$noises, stringsAsFactors = FALSE)
rows <- vector("list", nrow(grid)); problems <- rep("", nrow(grid))
for (i in seq_len(nrow(grid))) {
  task <- file.path(run_root, "tasks", grid$noise[i], sprintf("seed_%03d", grid$seed[i]))
  rows[[i]] <- tryCatch({
    if (!file.exists(file.path(task, "SUCCESS"))) stop("missing SUCCESS marker")
    x <- readRDS(file.path(task, "summary.rds"))
    stopifnot(identical(x$config, cfg), identical(x$source_sha256, manifest),
      x$noise == grid$noise[i], x$seed == grid$seed[i], file.exists(x$raw_path),
      identical(x$metrics$tau, cfg$taus), all(x$metrics$seed == grid$seed[i]),
      all(x$metrics$noise == grid$noise[i]), all(x$max_adjacent_draw_violation == 0))
    # Recompute metrics from saved curves and truth, rather than trusting CSVs.
    m <- x$metrics
    m$MSE <- colMeans((x$est - x$dat$truth)^2)
    m$MAD <- colMeans(abs(x$est - x$dat$truth))
    m$MCIW <- colMeans(x$hi - x$lo)
    stopifnot(all(is.finite(as.matrix(m[c("MSE", "MAD", "MCIW")]))),
      all(m$MCIW >= 0),
      isTRUE(all.equal(m[c("MSE", "MAD", "MCIW")], x$metrics[c("MSE", "MAD", "MCIW")], tolerance = 1e-12)))
    m
  }, error = function(e) { problems[i] <<- conditionMessage(e); NULL })
}
write.csv(cbind(grid, valid = problems == "", problem = problems),
          file.path(summary_root, "task_status.csv"), row.names = FALSE)
if (any(nzchar(problems))) stop(sum(nzchar(problems)), " incomplete/invalid tasks; see task_status.csv. No averages written.")
all_metrics <- do.call(rbind, rows)
selected <- all_metrics[all_metrics$tau %in% cfg$report_taus, ]
averages <- do.call(rbind, lapply(cfg$noises, function(noise) do.call(rbind,
  lapply(cfg$report_taus, function(tau) {
    d <- selected[selected$noise == noise & selected$tau == tau, ]
    stopifnot(nrow(d) == length(cfg$seeds), identical(sort(d$seed), cfg$seeds))
    data.frame(noise = noise, tau = tau, n_seeds = nrow(d),
      mean_MSE = mean(d$MSE), mean_MAD = mean(d$MAD), mean_MCIW = mean(d$MCIW),
      se_MSE = sd(d$MSE) / sqrt(nrow(d)), se_MAD = sd(d$MAD) / sqrt(nrow(d)),
      se_MCIW = sd(d$MCIW) / sqrt(nrow(d)), mean_coverage = mean(d$coverage))
  }))))
write.csv(all_metrics, file.path(summary_root, "per_seed_all_six_quantiles.csv"), row.names = FALSE)
write.csv(selected, file.path(summary_root, "per_seed_tau096_099.csv"), row.names = FALSE)
write.csv(averages, file.path(summary_root, "average_metrics_tau096_099.csv"), row.names = FALSE)
atomic_rds(list(config = cfg, averages = averages, per_seed = all_metrics,
  source_sha256 = manifest, processed_utc = utc()), file.path(summary_root, "results.rds"))
capture.output(sessionInfo(), file = file.path(summary_root, "sessionInfo.txt"))
print(averages, row.names = FALSE)
cat("PROCESS_SUCCESS", utc(), "\n")
