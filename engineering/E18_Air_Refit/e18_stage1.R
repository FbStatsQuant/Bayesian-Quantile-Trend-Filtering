# Rscript --vanilla e18_stage1.R RUN_DIR [--pilot | --admm-sim=DIR]
args <- commandArgs(trailingOnly = TRUE)
if (!length(args)) stop("Usage: e18_stage1.R RUN_DIR [--pilot | --METHOD=REFIT_DIR ...]")
run <- normalizePath(args[1L])
prime <- startsWith(basename(run), "E18-prime-")
stage_pmala <- if (prime) "sim-prime" else "sim"
folder <- dirname(normalizePath(sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE))))
source(file.path(folder, "e18_common.R"))
source(file.path(folder, "e18_report_common.R"))
source(file.path(folder, "e18_select.R"))
benchmark_stages <- "admm-sim"
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
code <- file.path(folder, "..", "..")
archive <- e18_table2_archive(code)
offsets <- e18_table2_offsets(code)
hash_cols <- c("q01_sha256", "q05_sha256", "q10_sha256")
truth_shas <- unname(vapply(offsets, function(offset)
  vapply(archive$data, function(d) e18_vector_sha(d$theta + offset), ""), character(100L)))
stopifnot(identical(truth_shas, unname(as.matrix(audit[hash_cols]))))
metrics <- c("MSE", "CL", paste0("CAA_", e18_h))
fields <- c(e18_sampler_diagnostics, "ess_error_sq")
provenance_fields <- c("truth_sha", "R.version.string", "qnorm_tau")
check_data <- function(x) {
  seed <- x$task$seed
  j <- match(x$task$tau, e18_taus)
  stopifnot(identical(x$y_sha, audit$y_sha256[seed]),
    identical(x$baseline_sha, audit$baseline_sha256[seed]),
    identical(x$truth_sha, truth_shas[seed, j]),
    is.character(x$R.version.string), length(x$R.version.string) == 1L, nzchar(x$R.version.string),
    is.character(x$qnorm_tau), length(x$qnorm_tau) == 1L,
    identical(names(x$metrics), c(metrics, "coverage")),
    all(is.finite(x$metrics[c("MSE", "CL")])),
    all(is.finite(x$metrics[paste0("CAA_", e18_h)]) == (audit$n_signal[seed] > 0L)))
  e18_checked_offset(offsets[j], as.numeric(x$qnorm_tau))
}
grid <- e18_grid(stage_pmala)
if (pilot) grid <- grid[grid$index %in% if (prime) e18_prime_pilot_indices else e18_pilot_indices, ]
got <- e18_collect(run, stage_pmala, grid, function(x) {
  check_data(x)
  e18_validate_fit(x, 500L, fields)
  if (prime) stopifnot(x$a0 == 500L)
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
  row$a0 <- if (prime) grid$a0[i] else 1L
  row[c(metric_cols, fit_cols)] <- as.list(result)
  row[provenance_fields] <- if (is.null(x)) as.list(rep(NA_character_, length(provenance_fields)))
    else x[provenance_fields]
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
p10_finite <- function(x) if (any(is.finite(x))) unname(quantile(x, .1, na.rm = TRUE)) else NA_real_
summarize <- function(d, method, tau, b0, n, status, eligible = NA, chosen = NA, selected = NA) {
  row <- data.frame(tau = tau, method = method, b0 = b0, n = n,
    n_CAA_defined = if (is.na(n)) NA_integer_ else sum(is.finite(d[["CAA_0.5"]])),
    n_failed_or_missing = 100L - n, eligible = eligible,
    chosen_at_tau = chosen, selected_for_real = selected, status = status)
  if (prime) row$a0 <- if (method == "Bayesian-PMALA") 500L else NA_integer_
  for (k in metric_cols) row[[k]] <- mean_finite(d[[k]])
  row$lambda_ess <- median_finite(d$lambda_ess)
  row$lambda_ess_p10 <- p10_finite(d$lambda_ess)
  row$theta_ess_median <- median_finite(d$theta_ess_median)
  row$theta_ess_p10 <- p10_finite(d$theta_ess_median)
  row$theta_ess_p05 <- median_finite(d$theta_ess_p05)
  row$lambda_ess_fraction_below_20 <- mean_finite(d$lambda_ess < 20)
  row$acc_post <- median_finite(d$acc_post)
  row
}
by_cell <- do.call(rbind, lapply(seq_len(nrow(trace)), function(i) {
  t <- trace[i, ]
  d <- per_fit[per_fit$tau == t$tau & per_fit$b0 == t$b0 & !per_fit$failed, ]
  row <- summarize(d, "Bayesian-PMALA", t$tau, t$b0, t$n, t$reason, t$eligible,
    t$chosen_at_tau, t$selected_for_real)
  for (k in c("n_sigma_guard", "n_sigma_guard_postburn", "n_ipm_fallback", "n_warm_ipm_unconverged"))
    row[[k]] <- sum(d[[k]])
  if (prime) row <- cbind(row, as.data.frame(e18_warm_summary(d)))
  row$median_theta_error_sq_ess <- median_finite(d$theta_error_sq_ess)
  row$median_lambda_ess_e14 <- median_finite(d$lambda_ess_e14)
  row$min_acc <- if (nrow(d)) min(d$acc_post) else NA_real_
  row$max_acc <- if (nrow(d)) max(d$acc_post) else NA_real_
  row
}))
emit(by_cell, "pmala_cells")

# Published aggregates are historical reference. Comparisons use per-seed data.
published <- read.csv(file.path(folder, "published_stage1.csv"))
emit(published, "published_table2_reference")
benchmark_rows <- function(fits, method, available, source) {
  do.call(rbind, lapply(e18_taus, function(tau) {
    d <- if (is.null(fits)) data.frame() else fits[fits$tau == tau, ]
    n <- if (available) nrow(d) else NA_integer_
    status <- if (!available) "refit pending"
      else if (n < 100L) "refit incomplete; see discarded_reps.csv" else source
    summarize(d, method, tau, NA_real_, n, status)
  }))
}
benchmarks <- setNames(lapply(seq_along(benchmark_stages), function(i) {
  stage <- benchmark_stages[i]
  method <- benchmark_methods[i]
  root <- roots[[stage]]
  available <- dir.exists(file.path(root, stage))
  results <- if (available) e18_collect(root, stage, e18_grid(stage), function(x) {
    check_data(x)
    stopifnot(length(x$est) == 500L, all(is.finite(x$est)))
    stopifnot(startsWith(x$remote_sha, "17e3e7c"),
      x$lambda_selected %in% 500^seq(0, 1.4, length.out = 15L))
  })
  ok <- Filter(Negate(is.null), results$records)
  fits <- do.call(rbind, lapply(ok, function(x) {
    row <- data.frame(tau = x$task$tau, seed = x$task$seed, seconds = x$seconds)
    row[metric_cols] <- as.list(x$metrics)
    row[provenance_fields] <- x[provenance_fields]
    row
  }))
  issues <- data.frame(method = character(), tau = numeric(), seed = integer(), reason = character())
  if (available) {
    missing <- results$issues
    accounting <- file.path(root, c("slurm_accounting.psv", "E18_ACCOUNTING.psv"))
    accounting <- accounting[file.exists(accounting)]
    if (length(accounting)) {
      state <- read.table(accounting[1L], sep = "|", quote = "", comment.char = "",
        colClasses = "character", fill = TRUE)[, 1:2]
      arrays <- state[grepl("^[0-9]+_[0-9]+$", state[[1L]]), ]
      index <- as.integer(sub("^[0-9]+_", "", arrays[[1L]]))
      stopifnot(!anyDuplicated(index))
      timeout <- arrays[[2L]][match(missing$index, index)] %in% "TIMEOUT"
      missing$detail[timeout & missing$detail == "Missing worker result"] <- "Slurm timeout"
    }
    emit(missing, paste0(stage, "_issues"))
    issues <- data.frame(method = rep(method, nrow(missing)), tau = missing$tau,
      seed = missing$seed, reason = missing$detail)
  }
  if (length(ok)) emit(fits, paste0(stage, "_per_fit"))
  list(rows = benchmark_rows(fits, method, available, "complete refit"),
    fits = fits, issues = issues)
}), benchmark_methods[seq_along(benchmark_stages)])
emit(do.call(rbind, lapply(benchmarks, `[[`, "issues")), "discarded_reps")

lap <- archive$per_task
keys <- expand.grid(seed = 1:100, tau = e18_taus)
stopifnot(nrow(lap) == nrow(keys), all(lap$method == "onizuka_lap"),
  setequal(paste(lap$tau, lap$seed), paste(keys$tau, keys$seed)),
  all(is.finite(lap$MSE)), all(is.finite(lap$CL)), all(is.finite(lap$coverage)),
  all(vapply(lap[paste0("CAA_", e18_h)], function(x)
    identical(is.finite(x), audit$n_signal[lap$seed] > 0L), FALSE)))
laplace_fits <- lap[c("tau", "seed", "seconds", metrics, "coverage")]
names(laplace_fits)[names(laplace_fits) == "MSE"] <- "mse"
emit(laplace_fits, "onizuka-lap_per_fit")
laplace_method <- benchmark_methods[3L]
benchmarks[[laplace_method]] <- list(
  rows = benchmark_rows(laplace_fits, laplace_method, TRUE, "sealed Table 2 archive"),
  fits = laplace_fits)
hs <- published[published$method == "onizuka_hs", ]
stopifnot(identical(hs$tau, e18_taus), all(hs$n_seeds == 100L))
hs_note <- "from the original run; per-replication values not retained, so no paired comparison"
benchmarks[["Onizuka (HS)"]] <- list(rows = do.call(rbind, lapply(seq_len(nrow(hs)), function(i) {
  row <- summarize(data.frame(), "Onizuka (HS)", hs$tau[i], NA_real_, hs$n_seeds[i], hs_note)
  row[metric_cols[metric_cols != "coverage"]] <- hs[i, paste0("mean_", metrics)]
  row$n_CAA_defined <- hs$n_CAA_defined[i]
  row
})))

columns <- names(benchmarks[[1L]]$rows)
table <- do.call(rbind, c(list(by_cell[columns]), lapply(benchmarks, `[[`, "rows")))
emit(table[order(table$tau, match(table$method, c("Bayesian-PMALA", benchmark_methods)), -table$b0), ],
  "report_table")

paired_summary <- function(method) {
  fits <- benchmarks[[method]]$fits
  if (is.null(fits)) return(NULL)
  paired_metrics <- if (method == "ADMM") setdiff(metric_cols, "coverage") else metric_cols
  pairs <- merge(per_fit[!per_fit$failed, c("tau", "seed", "b0", paired_metrics)],
    fits[c("tau", "seed", paired_metrics)], by = c("tau", "seed"),
    suffixes = c("_pmala", "_benchmark"))
  do.call(rbind, lapply(seq_len(nrow(trace)), function(i) {
    t <- trace[i, ]
    d <- pairs[pairs$tau == t$tau & pairs$b0 == t$b0, ]
    do.call(rbind, lapply(paired_metrics, function(k) {
      delta <- d[[paste0(k, "_pmala")]] - d[[paste0(k, "_benchmark")]]
      delta <- delta[is.finite(delta)]
      m <- length(delta)
      row <- data.frame(method = method, tau = t$tau, b0 = t$b0, metric = k,
        n_pairs = m, mean_pmala_minus_benchmark = mean_finite(delta),
        paired_se = if (m > 1L) sd(delta) / sqrt(m) else NA_real_)
      if (prime) row$a0 <- 500L
      row
    }))
  }))
}
paired <- do.call(rbind, lapply(c("ADMM", laplace_method), paired_summary))
emit(paired, "paired_pmala_benchmarks")
admm <- paired[paired$method == "ADMM", setdiff(names(paired), "method")]
names(admm)[names(admm) == "mean_pmala_minus_benchmark"] <- "mean_pmala_minus_admm"
emit(admm, "paired_pmala_admm")
if (selection$selected$branch[1L] == "iii") quit(status = 1L)
