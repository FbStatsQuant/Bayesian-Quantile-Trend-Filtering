# Rscript --vanilla e18_stage1.R RUN_DIR [--pilot]
args <- commandArgs(trailingOnly = TRUE)
if (!(length(args) == 1L || (length(args) == 2L && args[2L] == "--pilot")))
  stop("Usage: e18_stage1.R RUN_DIR [--pilot]")
run <- normalizePath(args[1L])
folder <- file.path(run, "code", "engineering", "E18_Air_Refit")
source(file.path(folder, "e18_common.R"))
source(file.path(folder, "e18_report_common.R"))
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
pilot <- length(args) == 2L
grid <- e18_grid("sim")
if (pilot) grid <- grid[grid$index %in% e18_pilot_indices, ]
got <- e18_collect(run, "sim", grid, function(x) {
  check_data(x)
  e18_validate_fit(x, 500L, fields)
  stopifnot(is.finite(x$metrics[["coverage"]]), x$metrics[["coverage"]] %in% (0:500 / 500))
})
emit(got$issues, if (pilot) "pilot_issues" else "issues")
records <- Filter(Negate(is.null), got$records)
per_fit <- do.call(rbind, lapply(records, function(x) {
  as.data.frame(c(x$task, as.list(x$metrics), as.list(e18_stat(x, fields))),
    check.names = FALSE)
}))
aggregation <- function(x) {
  setNames(as.list(c(mean(x), sd(x) / sqrt(length(x)))), c("mean", "se"))
}
if (pilot) {
  if (length(records)) {
    per_fit$gate_pass <- with(per_fit, acc >= .4 & acc <= .6 & n_sigma_guard == 0L)
    emit(per_fit, "pilot_metrics")
    print(per_fit[c("index", "tau", "b0", "acc", "n_sigma_guard", "seconds", "gate_pass")])
  }
  stopifnot(nrow(got$issues) == 0L, all(per_fit$gate_pass))
  quit(status = 0L)
}
if (length(records)) emit(per_fit, "per_fit")
summ <- function(cell, tau, b0, requested) {
  row <- data.frame(tau = tau, b0 = b0, n_requested = requested,
    n_complete = nrow(cell), n_failed_or_missing = requested - nrow(cell))
  if (!nrow(cell)) return(row)
  for (k in intersect(c(metrics, "coverage"), names(cell))) {
    val <- cell[[k]]
    val <- val[is.finite(val)]
    for (what in names(aggregation(val))) row[[paste0(what, "_", k)]] <- aggregation(val)[[what]]
  }
  row$n_CAA_defined <- sum(!is.na(cell[["CAA_0.5"]]))
  for (k in intersect(fields, names(cell))) {
    row[[paste0("median_", k)]] <- median(cell[[k]])
    row[[paste0("min_", k)]] <- min(cell[[k]])
  }
  for (k in intersect(c("n_sigma_guard", "n_ipm_fallback"), names(cell))) row[[k]] <- sum(cell[[k]])
  if ("acc" %in% names(cell)) {
    row$max_acc <- max(cell$acc)
    row$n_acc_outside_gate <- sum(cell$acc < .4 | cell$acc > .6)
  }
  row
}
# An empty cell still appears with all counts and blank estimates.
bind_rows <- function(rows) {
  cols <- unique(unlist(lapply(rows, names)))
  do.call(rbind, lapply(rows, function(d) {
    d[setdiff(cols, names(d))] <- NA_real_
    d[cols]
  }))
}
cells <- unique(grid[c("tau", "b0")])
by_cell <- bind_rows(lapply(seq_len(nrow(cells)), function(i) {
  tau <- cells$tau[i]
  b0 <- cells$b0[i]
  cell <- if (is.null(per_fit)) data.frame() else per_fit[per_fit$tau == tau & per_fit$b0 == b0, ]
  summ(cell, tau, b0, 100L)
}))
emit(by_cell, "pmala_cells")
emit(read.csv(file.path(folder, "published_stage1.csv")), "published_table2")
if (dir.exists(file.path(run, "admm-sim"))) {
  admm <- e18_collect(run, "admm-sim", e18_grid("admm-sim"), check_data)
  emit(admm$issues, "admm_issues")
  ok <- Filter(Negate(is.null), admm$records)
  per_admm <- do.call(rbind, lapply(ok, function(x) {
    as.data.frame(c(x$task, as.list(x$metrics[metrics]),
      list(lambda = x$lambda_selected, seconds = x$seconds, detrendr_sha = x$remote_sha)),
      check.names = FALSE)
  }))
  if (length(ok)) emit(per_admm, "admm_per_fit")
  emit(bind_rows(lapply(e18_taus, function(tau) {
    cell <- if (is.null(per_admm)) data.frame() else per_admm[per_admm$tau == tau, ]
    summ(cell, tau, NA_real_, 100L)
  })), "admm_cells")
}
if (nrow(got$issues)) stop(nrow(got$issues), " missing or failed fits. Selection withheld.")

# One row per seed, matched across rates and levels.
mse_at <- function(tau) vapply(e18_rates, function(b0) {
  x <- per_fit[per_fit$tau == tau & per_fit$b0 == b0, ]
  stopifnot(nrow(x) == 100L, identical(sort(x$seed), 1:100))
  x$MSE[match(1:100, x$seed)]
}, numeric(100L))
levels <- lapply(e18_taus, mse_at)
levels[[4L]] <- Reduce("+", levels) / length(e18_taus)
comparisons <- lapply(seq_along(levels), function(k) {
  m <- levels[[k]]
  tau <- c(e18_taus, NA_real_)[k]
  means <- colMeans(m)
  best <- which.min(means)
  pairs <- combn(seq_along(e18_rates), 2L)
  list(selection = data.frame(tau = tau, b0 = e18_rates[best], mean_MSE = means[best]),
       pairs = do.call(rbind, lapply(seq_len(ncol(pairs)), function(j) {
         a <- pairs[1L, j]
         b <- pairs[2L, j]
         d <- m[, a] - m[, b]
         data.frame(tau = tau, b0_a = e18_rates[a], b0_b = e18_rates[b],
           mean_diff_a_minus_b = mean(d), se = sd(d) / sqrt(length(d)), n_pairs = length(d),
           includes_selected = best %in% c(a, b))
       })))
})
emit(do.call(rbind, lapply(comparisons, `[[`, "selection")), "selected_b0")
emit(do.call(rbind, lapply(comparisons, `[[`, "pairs")), "paired_differences")
