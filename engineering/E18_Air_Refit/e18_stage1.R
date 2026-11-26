# Rscript --vanilla e18_stage1.R RUN_DIR [--pilot | --admm-sim=DIR --onizuka-hs=DIR --onizuka-lap=DIR]
args <- commandArgs(trailingOnly = TRUE)
if (!length(args)) stop("Usage: e18_stage1.R RUN_DIR [--pilot | --METHOD=REFIT_DIR ...]")
run <- normalizePath(args[1L])
folder <- dirname(normalizePath(sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE))))
source(file.path(folder, "e18_common.R"))
source(file.path(folder, "e18_report_common.R"))
source(file.path(folder, "e18_select.R"))
benchmark_stages <- c("admm-sim", "onizuka-hs", "onizuka-lap")
benchmark_methods <- c("ADMM", "Onizuka (HS)", "Onizuka (Laplace)")
pilot <- identical(args[-1L], "--pilot")
roots <- setNames(rep(run, length(benchmark_stages)), benchmark_stages)
if (!pilot && length(args) > 1L) {
  flags <- args[-1L]
  stages <- sub("^--([^=]+)=.*$", "\\1", flags)
  stopifnot(all(stages %in% benchmark_stages), !anyDuplicated(stages))
  roots[stages] <- vapply(sub("^[^=]+=", "", flags), normalizePath, "", mustWork = TRUE)
}
out <- file.path(run, "report")
dir.create(out, showWarnings = FALSE)
emit <- function(x, file) write.csv(x, file.path(out, paste0(file, ".csv")), row.names = FALSE)
audit <- read.csv(file.path(folder, "table2_data_sha256.csv"))
hash_cols <- c("q01_sha256", "q05_sha256", "q10_sha256")
metrics <- c("MSE", "CL", paste0("CAA_", e18_h))
fields <- c(e18_sampler_diagnostics, "ess_error_sq")
check_data <- function(x) {
  stopifnot(identical(x$y_sha, audit$y_sha256[x$task$seed]),
    identical(x$truth_sha, audit[[hash_cols[match(x$task$tau, e18_taus)]]][x$task$seed]),
    identical(names(x$metrics), c(metrics, "coverage")),
    all(is.finite(x$metrics[c("MSE", "CL")])),
    all(is.finite(x$metrics[paste0("CAA_", e18_h)]) == (audit$n_signal[x$task$seed] > 0L)))
}
grid <- e18_grid("sim")
if (pilot) grid <- grid[grid$index %in% e18_pilot_indices, ]
got <- e18_collect(run, "sim", grid, function(x) {
  check_data(x)
  e18_validate_fit(x, 500L, fields)
  stopifnot(x$metrics[["coverage"]] %in% (0:500 / 500),
    x$n_sigma_guard_postburn >= 0, x$n_sigma_guard_postburn <= x$n_sigma_guard,
    x$n_sigma_guard <= 30000L)
})
emit(got$issues, if (pilot) "pilot_issues" else "issues")
metric_cols <- c("mse", metrics[-1L], "coverage")
fit_cols <- c("lambda_ess", "lambda_ess_e14", "theta_ess_median", "theta_ess_p05",
  "acc_post", "n_sigma_guard", "n_sigma_guard_postburn", "n_ipm_fallback",
  "n_warm_ipm_unconverged", "seconds", "theta_error_sq_ess")
per_fit <- do.call(rbind, lapply(seq_len(nrow(grid)), function(i) {
  x <- got$records[[i]]
  result <- rep(NA_real_, length(metric_cols) + length(fit_cols))
  if (is.null(x)) result[match("seconds", c(metric_cols, fit_cols))] <- got$failure_seconds[i]
  else result <- c(x$metrics, e18_stat(x, fields))
  row <- grid[i, c("tau", "b0", "seed")]
  row[c(metric_cols, fit_cols)] <- as.list(result)
  row$failed <- is.null(x)
  row$commit <- e18_pin
  row
}))
if (pilot) {
  per_fit$gate_pass <- with(per_fit, !failed & acc_post >= .4 & acc_post <= .6 & n_sigma_guard == 0L)
  emit(per_fit, "pilot_metrics")
  print(per_fit[c("tau", "b0", "acc_post", "n_sigma_guard", "seconds", "gate_pass")])
  stopifnot(all(per_fit$gate_pass))
  quit(status = 0L)
}
emit(per_fit, "per_fit")
selection <- e18_select(per_fit)
e18_write_selection(selection, out)
trace <- selection$trace

mean_finite <- function(x) if (any(is.finite(x))) mean(x, na.rm = TRUE) else NA_real_
median_finite <- function(x) if (any(is.finite(x))) median(x, na.rm = TRUE) else NA_real_
summarize <- function(d, method, tau, b0, n, status, eligible = NA, chosen = NA, selected = NA) {
  row <- data.frame(tau = tau, method = method, b0 = b0, n = n,
    n_CAA_defined = if (is.na(n)) NA_integer_ else sum(is.finite(d[["CAA_0.5"]])),
    n_failed_or_missing = 100L - n, eligible = eligible,
    chosen_at_tau = chosen, selected_for_real = selected, status = status)
  for (k in metric_cols) row[[k]] <- mean_finite(d[[k]])
  for (k in c("lambda_ess", "theta_ess_median", "theta_ess_p05", "acc_post"))
    row[[k]] <- median_finite(d[[k]])
  row
}
by_cell <- do.call(rbind, lapply(seq_len(nrow(trace)), function(i) {
  t <- trace[i, ]
  d <- per_fit[per_fit$tau == t$tau & per_fit$b0 == t$b0 & !per_fit$failed, ]
  row <- summarize(d, "Bayesian-PMALA", t$tau, t$b0, t$n, t$reason, t$eligible,
    t$chosen_at_tau, t$selected_for_real)
  for (k in c("n_sigma_guard", "n_sigma_guard_postburn", "n_ipm_fallback", "n_warm_ipm_unconverged"))
    row[[k]] <- sum(d[[k]])
  row$median_theta_error_sq_ess <- median_finite(d$theta_error_sq_ess)
  row$median_lambda_ess_e14 <- median_finite(d$lambda_ess_e14)
  row$min_acc <- if (nrow(d)) min(d$acc_post) else NA_real_
  row$max_acc <- if (nrow(d)) max(d$acc_post) else NA_real_
  row
}))
emit(by_cell, "pmala_cells")

# The old aggregate values are retained for historical reference. Benchmark
# rows used for the refit comparison come only from verified E-18 outputs.
emit(read.csv(file.path(folder, "published_stage1.csv")), "published_table2_reference")
benchmarks <- lapply(seq_along(benchmark_stages), function(i) {
  stage <- benchmark_stages[i]
  method <- benchmark_methods[i]
  root <- roots[[stage]]
  available <- dir.exists(file.path(root, stage))
  results <- if (available) e18_collect(root, stage, e18_grid(stage), function(x) {
    check_data(x)
    stopifnot(length(x$est) == 500L, all(is.finite(x$est)))
    if (stage == "admm-sim") stopifnot(startsWith(x$remote_sha, "17e3e7c"),
      x$lambda_selected %in% 500^seq(0, 1.4, length.out = 15L))
    else stopifnot(identical(x$source_sha, e18_onizuka_sha), x$metrics[["coverage"]] %in% (0:500 / 500))
  })
  ok <- Filter(Negate(is.null), results$records)
  fits <- do.call(rbind, lapply(ok, function(x) {
    row <- data.frame(tau = x$task$tau, seed = x$task$seed, seconds = x$seconds)
    row[metric_cols] <- as.list(x$metrics)
    row
  }))
  if (available) emit(results$issues, paste0(stage, "_issues"))
  if (length(ok)) emit(fits, paste0(stage, "_per_fit"))
  rows <- do.call(rbind, lapply(e18_taus, function(tau) {
    d <- if (is.null(fits)) data.frame() else fits[fits$tau == tau, ]
    n <- if (available) nrow(d) else NA_integer_
    status <- if (!available) "refit pending; archive did not pass reuse audit"
      else if (n < 100L) "refit incomplete; see issue file" else "complete refit"
    summarize(d, method, tau, NA_real_, n, status)
  }))
  list(rows = rows, fits = fits)
})
columns <- names(benchmarks[[1L]]$rows)
table <- do.call(rbind, c(list(by_cell[columns]), lapply(benchmarks, `[[`, "rows")))
emit(table[order(table$tau, match(table$method, c("Bayesian-PMALA", benchmark_methods)), -table$b0), ],
  "report_table")

if (!is.null(benchmarks[[1L]]$fits)) {
  # Paired comparisons to ADMM use the intersection of successful seeds.
  pairs <- merge(per_fit[!per_fit$failed, c("tau", "seed", "b0", metrics[-1L], "mse")],
    benchmarks[[1L]]$fits, by = c("tau", "seed"), suffixes = c("_pmala", "_admm"))
  joined <- do.call(rbind, lapply(seq_len(nrow(trace)), function(i) {
    t <- trace[i, ]
    d <- pairs[pairs$tau == t$tau & pairs$b0 == t$b0, ]
    do.call(rbind, lapply(metric_cols[metric_cols != "coverage"], function(k) {
      delta <- d[[paste0(k, "_pmala")]] - d[[paste0(k, "_admm")]]
      delta <- delta[is.finite(delta)]
      m <- length(delta)
      data.frame(tau = t$tau, b0 = t$b0, metric = k, n_pairs = m,
        mean_pmala_minus_admm = mean_finite(delta), paired_se = if (m > 1L) sd(delta) / sqrt(m) else NA_real_)
    }))
  }))
  emit(joined, "paired_pmala_admm")
}
if (selection$selected$branch[1L] == "iii") quit(status = 1L)
