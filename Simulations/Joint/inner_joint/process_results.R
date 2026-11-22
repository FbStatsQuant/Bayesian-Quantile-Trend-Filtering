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
grid <- task_grid(cfg)
rows <- vector("list", nrow(grid)); problems <- rep("", nrow(grid))
for (i in seq_len(nrow(grid))) {
  g <- grid[i, ]
  task <- task_dir(run_root, g$baseline, g$noise, g$batch, g$seed)
  rows[[i]] <- tryCatch({
    if (!file.exists(file.path(task, "SUCCESS"))) stop("missing SUCCESS marker")
    x <- readRDS(file.path(task, "summary.rds"))
    stopifnot(identical(x$config, cfg), identical(x$source_sha256, manifest),
      x$baseline == g$baseline, x$noise == g$noise, x$batch == g$batch, x$seed == g$seed,
      file.exists(x$raw_path), identical(x$metrics$tau, cfg$batches[[g$batch]]$taus),
      all(x$metrics$seed == g$seed), all(x$metrics$noise == g$noise),
      all(x$metrics$baseline == g$baseline), all(x$max_adjacent_draw_violation == 0))
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
selected <- all_metrics[all_metrics$target, ]
stopifnot(nrow(selected) == length(cfg$baselines) * length(cfg$noises) * length(cfg$report_taus) * length(cfg$seeds))
se <- function(v) sd(v) / sqrt(length(v))
cells <- expand.grid(tau = cfg$report_taus, noise = cfg$noises, baseline = cfg$baselines, stringsAsFactors = FALSE)
averages <- do.call(rbind, lapply(seq_len(nrow(cells)), function(i) {
  d <- selected[selected$baseline == cells$baseline[i] & selected$noise == cells$noise[i] & selected$tau == cells$tau[i], ]
  stopifnot(nrow(d) == length(cfg$seeds), identical(sort(d$seed), cfg$seeds), length(unique(d$batch)) == 1L)
  data.frame(baseline = cells$baseline[i], noise = cells$noise[i], tau = cells$tau[i], batch = d$batch[1],
    n_seeds = nrow(d), mean_MSE = mean(d$MSE), mean_MAD = mean(d$MAD), mean_MCIW = mean(d$MCIW),
    se_MSE = se(d$MSE), se_MAD = se(d$MAD), se_MCIW = se(d$MCIW), mean_coverage = mean(d$coverage),
    mean_acc = mean(d$acc_post), mean_outside = mean(d$outside_rate), mean_hours = mean(d$seconds) / 3600)
}))
# Sampler diagnostics at every fitted level (targets and helper levels).
diag_cells <- unique(all_metrics[c("baseline", "noise", "batch", "tau")])
diagnostics <- do.call(rbind, lapply(seq_len(nrow(diag_cells)), function(i) {
  k <- diag_cells[i, ]
  d <- all_metrics[all_metrics$baseline == k$baseline & all_metrics$noise == k$noise &
                   all_metrics$batch == k$batch & all_metrics$tau == k$tau, ]
  data.frame(k, target = d$target[1], n_seeds = nrow(d), mean_MSE = mean(d$MSE),
    mean_coverage = mean(d$coverage), acc_min = min(d$acc_post), acc_mean = mean(d$acc_post),
    acc_max = max(d$acc_post), outside_mean = mean(d$outside_rate), ipm_share_mean = mean(d$ipm_share),
    asis_moved_mean = mean(d$asis_moved), hours_median = median(d$seconds) / 3600,
    hours_max = max(d$seconds) / 3600)
}))
# Side-by-side with the manuscript's interior tables (individual fits, same signals and noises).
ref <- read.csv(file.path(code_root, "paper_reference", "interior_tables_long.csv"))
long <- do.call(rbind, lapply(c("MSE", "MAD", "MCIW"), function(metric)
  data.frame(averages[c("baseline", "noise", "tau", "batch")], metric = metric,
             joint = averages[[paste0("mean_", metric)]], joint_se = averages[[paste0("se_", metric)]])))
wide_ref <- reshape(ref, idvar = c("baseline", "metric", "noise", "tau"), timevar = "method", direction = "wide")
names(wide_ref) <- sub("^value[.]", "", names(wide_ref))
comparison <- merge(long, wide_ref, by = c("baseline", "metric", "noise", "tau"), all.x = TRUE)
stopifnot(nrow(comparison) == 3L * nrow(averages), all(is.finite(comparison$paper_PMALA)))
comparison$joint_to_PMALA_ratio <- comparison$joint / comparison$paper_PMALA
methods <- intersect(c("paper_Laplace", "paper_Horseshoe", "paper_PMALA", "paper_ADMM"), names(comparison))
bench <- as.matrix(comparison[methods])
comparison$paper_best <- apply(bench, 1, min, na.rm = TRUE)
comparison$paper_best_method <- apply(bench, 1, function(v) methods[which.min(v)])
comparison$joint_is_best <- comparison$joint < comparison$paper_best
comparison <- comparison[order(match(comparison$baseline, cfg$baselines), match(comparison$metric, c("MSE", "MAD", "MCIW")),
                               match(comparison$noise, c("Beta", "Mixed", "Normal")), comparison$tau), ]
write.csv(all_metrics, file.path(summary_root, "per_seed_all_taus.csv"), row.names = FALSE)
write.csv(selected, file.path(summary_root, "per_seed_targets.csv"), row.names = FALSE)
write.csv(averages, file.path(summary_root, "average_metrics_targets.csv"), row.names = FALSE)
write.csv(diagnostics, file.path(summary_root, "diagnostics_all_taus.csv"), row.names = FALSE)
write.csv(comparison, file.path(summary_root, "comparison_paper_interior.csv"), row.names = FALSE)
atomic_rds(list(config = cfg, averages = averages, per_seed = all_metrics, diagnostics = diagnostics,
  comparison = comparison, source_sha256 = manifest, processed_utc = utc()), file.path(summary_root, "results.rds"))
capture.output(sessionInfo(), file = file.path(summary_root, "sessionInfo.txt"))
print(comparison[comparison$metric == "MSE", c("baseline", "noise", "tau", "joint", "paper_PMALA",
  "joint_to_PMALA_ratio", "paper_best_method", "joint_is_best")], row.names = FALSE)
cat("PROCESS_SUCCESS", utc(), "\n")
