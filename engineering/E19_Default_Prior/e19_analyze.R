# Run from the repository root.
# Rscript --vanilla e19_analyze.R {check|summarize} E19_OUT E14_OUT OUTPUT_DIR [INDEX_LIST]
source("engineering/E14_Inner_Rerun/e14_run.R")
source("engineering/E19_Default_Prior/e19_run.R")

diagnostics <- function(x) {
  data.frame(
    mse = x$mse, mad = x$mad, mciw = x$mciw,
    coverage = mean(x$lo <= x$truth & x$truth <= x$hi),
    lambda_ess = x$lambda_ess,
    log_lambda_ess = if (is.null(x$log_lambda_ess)) NA_real_ else x$log_lambda_ess,
    theta_ess_median = if (is.null(x$theta_ess_median)) NA_real_ else x$theta_ess_median,
    theta_ess_p05 = if (is.null(x$theta_ess_p05)) NA_real_ else x$theta_ess_p05,
    acceptance = x$acc_post, n_sigma_guard = x$n_sigma_guard,
    n_ipm_fallback = x$n_ipm_fallback,
    n_warm_ipm_unconverged = if (is.null(x$n_warm_ipm_unconverged))
      NA_real_ else x$n_warm_ipm_unconverged
  )
}

read_pair <- function(task, e19_out, e14_out) {
  tryCatch({
    old <- e19_read_comparator(task, e14_out)
    fit <- readRDS(file.path(e19_out, paste0(task$id, ".rds")))
    stopifnot(all(vapply(names(task), function(k) identical(task[[k]], fit[[k]]), logical(1L))))
    delta <- e19_check_pair(fit, old)
    stopifnot(isTRUE(fit$pairing_verified), identical(fit$generator_blob, e19_generator_blob),
      identical(fit$truth_max_abs_delta, delta),
      is.character(fit$y_sha256), length(fit$y_sha256) == 1L, grepl("^[a-f0-9]{64}$", fit$y_sha256),
      identical(unname(fit$commit), e19_sampler_commit),
      identical(unname(old$commit), e19_sampler_commit),
      fit$chain_seed == 10001L + task$index, identical(old$chain_seed, fit$chain_seed),
      fit$sweeps == 30000L, fit$burn == 10000L, fit$warm == 200L, fit$lambda_hold_until == 200L,
      fit$a0 == 500, fit$b0 == 1e-2, fit$n_sigma_guard == 0, is.finite(fit$acc_post))
    new_metrics <- diagnostics(fit)
    new_metrics$truth_max_abs_delta <- delta
    stopifnot(all(is.finite(unlist(new_metrics))))
    list(e14 = diagnostics(old), e19 = new_metrics)
  }, error = function(e) stop(task$id, ": ", conditionMessage(e), call. = FALSE))
}

summarize_run <- function(x, run) {
  values <- c(
    vapply(x[c("mse", "mad", "mciw", "coverage")], mean, numeric(1)),
    setNames(vapply(x[c("lambda_ess", "log_lambda_ess", "theta_ess_median", "theta_ess_p05")],
      median, numeric(1)), c("median_lambda_ess", "median_log_lambda_ess",
      "median_theta_ess_median", "median_theta_ess_p05")),
    median_acceptance = median(x$acceptance),
    min_acceptance = min(x$acceptance),
    max_acceptance = max(x$acceptance),
    vapply(x[c("n_sigma_guard", "n_ipm_fallback", "n_warm_ipm_unconverged")], sum, numeric(1))
  )
  as.list(setNames(values, paste0(names(values), "_", run)))
}

analyze <- function(args) {
  if (length(args) < 4L || length(args) > 5L || !args[1L] %in% c("check", "summarize"))
    stop("Usage: e19_analyze.R {check|summarize} E19_OUT E14_OUT OUTPUT_DIR [INDEX_LIST]")
  e19_out <- args[2L]
  e14_out <- args[3L]
  output <- args[4L]
  tasks <- e14_tasks()
  subset_check <- length(args) == 5L
  if (subset_check) {
    stopifnot(args[1L] == "check", grepl("^[0-9]+(,[0-9]+)*$", args[5L]))
    indices <- as.integer(strsplit(args[5L], ",", fixed = TRUE)[[1L]])
    stopifnot(all(indices %in% tasks$index), !anyDuplicated(indices))
    tasks <- tasks[match(indices, tasks$index), ]
  }
  fits <- list.files(e19_out, "[.]rds$")
  stopifnot(setequal(fits, paste0(tasks$id, ".rds")))
  pairs <- lapply(seq_len(nrow(tasks)), function(i) read_pair(as.list(tasks[i, ]), e19_out, e14_out))
  old <- do.call(rbind, lapply(pairs, `[[`, "e14"))
  new <- do.call(rbind, lapply(pairs, `[[`, "e19"))
  accepted <- if (subset_check) new$acceptance else median(new$acceptance)
  stopifnot(all(accepted >= 0.4 & accepted <= 0.6))
  cat(sprintf("%d fits passed | zero sigma guards | acceptance %.5f to %.5f (median %.5f)\n",
    nrow(tasks), min(new$acceptance), max(new$acceptance), median(new$acceptance)))
  cat(sprintf("Maximum absolute truth delta %.17g\n", max(new$truth_max_abs_delta)))
  dir.create(output, recursive = TRUE, showWarnings = FALSE)
  if (args[1L] == "check") {
    write.csv(cbind(tasks, new), file.path(output, "fit_gates.csv"), row.names = FALSE)
    return(invisible(NULL))
  }

  cells <- unique(tasks[c("signal", "noise", "tau")])
  per_cell <- lapply(seq_len(nrow(cells)), function(i) {
    cell <- cells[i, ]
    take <- tasks$signal == cell$signal & tasks$noise == cell$noise & tasks$tau == cell$tau
    e14 <- old[take, ]
    e19 <- new[take, ]
    n <- nrow(e19)
    stopifnot(n == 100L)
    d <- e19$mse - e14$mse
    paired_z <- mean(d) / (sd(d) / sqrt(n))
    ratio <- mean(e19$mse) / mean(e14$mse)
    data.frame(cell, n_pairs = n, mse_ratio = ratio, paired_z,
      significantly_worse = paired_z > 2 & ratio > 1.1,
      summarize_run(e14, "e14"), summarize_run(e19, "e19"), row.names = NULL)
  })
  per_cell <- do.call(rbind, per_cell)
  per_cell <- per_cell[order(-per_cell$mse_ratio, -per_cell$paired_z), ]
  stopifnot(all(is.finite(per_cell$mse_ratio)), !anyNA(per_cell$significantly_worse))
  conditions <- do.call(rbind, lapply(c("VS", "S"), function(signal) {
    cell <- per_cell[per_cell$signal == signal, ]
    stopifnot(nrow(cell) == 15L)
    data.frame(signal, geometric_mean_mse_ratio = exp(mean(log(cell$mse_ratio))),
      n_significantly_worse = sum(cell$significantly_worse),
      median_coverage_e14 = median(cell$coverage_e14), median_coverage_e19 = median(cell$coverage_e19))
  }))
  conditions$pass_ratio <- conditions$geometric_mean_mse_ratio <= 1
  conditions$pass_cells <- conditions$n_significantly_worse == 0L
  conditions$coverage_threshold <- conditions$median_coverage_e14 - 0.05
  conditions$pass_coverage <- conditions$median_coverage_e19 >= conditions$coverage_threshold
  conditions$verdict <- if (all(conditions$pass_ratio & conditions$pass_cells &
    conditions$pass_coverage)) "PASS" else "FAIL"
  write.csv(per_cell, file.path(output, "e19_cells.csv"), row.names = FALSE)
  write.csv(conditions, file.path(output, "e19_verdict.csv"), row.names = FALSE)
  print(conditions, row.names = FALSE)
  print(head(per_cell[c("signal", "noise", "tau", "mse_ratio", "paired_z", "coverage_e14",
    "coverage_e19")], 5L), row.names = FALSE)
}

analyze(commandArgs(trailingOnly = TRUE))
