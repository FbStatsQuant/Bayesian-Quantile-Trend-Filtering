# Rscript --vanilla e18_real_report.R RUN_DIR SELECTED_B0_CSV [ADMM_RUN_DIR]
args <- commandArgs(trailingOnly = TRUE)
if (!length(args) %in% 2:3) stop("Usage: e18_real_report.R RUN_DIR SELECTED_B0_CSV [ADMM_RUN_DIR]")
run <- normalizePath(args[1L])
prime <- startsWith(basename(run), "E18-prime-")
stage_pmala <- if (prime) "real-prime" else "real"
admm_run <- if (length(args) == 3L) normalizePath(args[3L]) else run
with_admm <- !prime || length(args) == 3L
code <- dirname(normalizePath(sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE))))
source(file.path(code, "e18_common.R"))
source(file.path(code, "e18_report_common.R"))
source(file.path(code, "e18_select.R"))
selected <- e18_read_selected(args[2L], prime)
input <- e18_real_input(run)
d <- input$data
n <- length(d$standardized)
stopifnot(n == 8640L, all(is.finite(d$standardized)), all(is.finite(d$block_mean)))
out <- file.path(run, "report")
dir.create(out, showWarnings = FALSE)
emit <- function(x, file) write.csv(x, file.path(out, paste0(file, ".csv")), row.names = FALSE)
if (prime) selected$a0_real <- 8640L
emit(selected, "spod_selected_b0")

real_grid <- e18_grid(stage_pmala)
grid_rates <- unique(real_grid$b0)
admm_grid <- e18_grid("admm-real")
same_input <- function(x) stopifnot(identical(x$input_sha, input$sha))
check_real <- function(x) {
  same_input(x)
  e18_validate_fit(x, n)
  if (prime) stopifnot(x$a0 == 8640L)
  stopifnot(identical(dim(x$theta_thin), c(666L, n)), all(is.finite(x$theta_thin)),
    all(vapply(x[c("lambda_stalled", "theta_stalled")],
      function(v) is.logical(v) && length(v) == 1L && !is.na(v), FALSE)),
    length(x$lambda_stalled) == 1L, length(x$theta_stalled) == 1L)
}
check_admm <- function(x) {
  same_input(x)
  e18_stat(x, c("lambda_selected", "seconds"))
  stopifnot(startsWith(x$remote_sha, "17e3e7c"), x$lambda_selected %in% exp(-2:12),
    length(x$est) == n, all(is.finite(x$est)))
}
got <- e18_collect(run, stage_pmala, real_grid, check_real)
emit(got$issues, "spod_pmala_issues")
if (with_admm) {
  admm <- e18_collect(admm_run, "admm-real", admm_grid, check_admm)
  emit(admm$issues, "spod_admm_issues")
}
ok <- Filter(Negate(is.null), got$records)
stall_ids <- names(Filter(function(x) x$lambda_stalled || x$theta_stalled, ok))
if (length(ok)) {
  chain_health <- do.call(rbind, lapply(ok, function(x) {
    z <- x$log_lambda
    data.frame(as.data.frame(x$task), as.list(e18_stat(x, e18_sampler_diagnostics)),
      first_half_lambda_median = exp(median(z[seq_len(333L)])),
      second_half_lambda_median = exp(median(z[334:666])),
      lambda_stalled = x$lambda_stalled, theta_stalled = x$theta_stalled,
      STOP_stall = x$lambda_stalled || x$theta_stalled,
      gate_pass = x$acc >= .4 & x$acc <= .6 & x$n_sigma_guard == 0L)
  }))
  if (prime) {
    for (k in e18_warm_fields) chain_health[[paste0(k, "_is_200")]] <- chain_health[[k]] == 200L
  }
  emit(chain_health, "spod_chain_health")
  plot_trace <- function(b0) {
    label <- sprintf("r%d", round(-log10(b0)))
    png(file.path(out, paste0("spod_lambda_trace_", label, ".png")), 1440, 1080, res = 144)
    on.exit(dev.off())
    par(mfrow = c(3L, 1L), mar = c(3.1, 4.1, 2, 1))
    for (tau in e18_taus) {
      chains <- Filter(function(x) x$task$tau == tau && x$task$b0 == b0, ok)
      if (!length(chains)) {
        plot.new()
        title(sprintf("tau %.2f: both chains missing", tau))
        next
      }
      log_lambda <- vapply(chains, `[[`, numeric(666L), "log_lambda")
      colors <- c("#0072B2", "#D55E00")[vapply(chains, function(x) x$task$seed, 1L)]
      matplot(e18_thin, log_lambda, type = "l", lty = 1, col = colors,
        xlab = "Sweep", ylab = "log(lambda)", main = sprintf("tau %.2f, b0 = %.0e", tau, b0))
      legend("topright", legend = paste("Chain", vapply(chains, function(x) x$task$seed, 1L)),
        col = colors, lty = 1, bty = "n")
    }
  }
  invisible(lapply(grid_rates, plot_trace))
}
if (prime) {
  chain_warm <- do.call(rbind, lapply(unique(real_grid$seed), function(seed) {
    chains <- Filter(function(x) x$task$seed == seed, ok)
    counts <- setNames(lapply(e18_warm_fields, function(k)
      vapply(chains, function(x) as.numeric(x[[k]]), 0)), e18_warm_fields)
    data.frame(seed = seed, a0 = 8640L, n_success = length(chains),
      n_requested = sum(real_grid$seed == seed), e18_warm_summary(counts))
  }))
  emit(chain_warm, "spod_chain_warm_summary")
}
if (with_admm) {
  benchmark <- data.frame(tau = e18_taus, paper_lambda = exp(c(4, 7, 7)),
    refit_lambda = vapply(admm$records, function(x) if (is.null(x)) NA_real_ else x$lambda_selected, 0))
  benchmark$match_to_1_decimal <- ifelse(is.na(benchmark$refit_lambda), NA,
    sprintf("%.1f", benchmark$paper_lambda) == sprintf("%.1f", benchmark$refit_lambda))
  emit(benchmark, "spod_admm_lambda_check")
}

# Arm 4b used coda's classic PSRF point estimate on four half-chains.
# Each coordinate is independent in this calculation. Batch the columns
# because coda computes full covariance matrices even with multivariate=FALSE.
theta_split_rhat <- function(draws) {
  halves <- seq_len(nrow(draws[[1L]]) / 2L)
  columns <- seq_len(ncol(draws[[1L]]))
  batches <- split(columns, (columns - 1L) %/% 32L)
  unlist(lapply(batches, function(j) {
    split_draws <- unlist(lapply(draws, function(x) list(
      x[halves, j, drop = FALSE], x[halves + length(halves), j, drop = FALSE])),
      recursive = FALSE)
    traces <- do.call(coda::mcmc.list, lapply(split_draws, coda::mcmc))
    coda::gelman.diag(traces, autoburnin = FALSE, transform = FALSE,
      multivariate = FALSE)$psrf[, 1L]
  }), use.names = FALSE)
}

theta_comparison <- function(draws, medians, tau) {
  rhat <- theta_split_rhat(draws)
  finite <- is.finite(rhat)
  gap <- abs(medians[1L, ] - medians[2L, ])
  iqr <- IQR(d$block_mean)
  max_gap <- max(gap)
  rms_gap <- sqrt(mean(gap^2))
  below <- rowMeans(sweep(medians, 2L, d$block_mean, FUN = ">"))
  data.frame(
    theta_rhat_method = "classic split Gelman-Rubin (coda)",
    theta_rhat_n_finite = sum(finite),
    theta_rhat_n_nonfinite = sum(!finite),
    theta_rhat_median = if (any(finite)) median(rhat[finite]) else NA_real_,
    theta_rhat_p90 = if (any(finite)) unname(quantile(rhat[finite], .9)) else NA_real_,
    theta_rhat_share_gt_1_1 = if (any(finite)) mean(rhat[finite] > 1.1) else NA_real_,
    chain_median_gap_max_pid = max_gap, chain_median_gap_rms_pid = rms_gap,
    y_iqr_pid = iqr,
    chain_median_gap_max_over_iqr = if (iqr > 0) max_gap / iqr else NA_real_,
    chain_median_gap_rms_over_iqr = if (iqr > 0) rms_gap / iqr else NA_real_,
    fraction_below_chain_1 = below[1L], fraction_below_chain_2 = below[2L],
    fraction_below_pooled = below[3L],
    fraction_below_minus_tau_chain_1 = below[1L] - tau,
    fraction_below_minus_tau_chain_2 = below[2L] - tau,
    fraction_below_minus_tau_pooled = below[3L] - tau)
}

record_cell <- function(chains, tau, b0) {
  if (any(vapply(chains, is.null, FALSE))) return(NULL)
  draws <- lapply(chains, `[[`, "theta_thin")
  if (prime) {
    medians <- d$center + d$scale * vapply(seq_len(n), function(i) {
      a <- draws[[1L]][, i]
      b <- draws[[2L]][, i]
      c(median(a), median(b), median(c(a, b)))
    }, numeric(3L))
    fit <- medians[3L, ]
  } else {
    fit <- d$center + d$scale * apply(do.call(rbind, draws), 2L, median)
  }
  traces <- do.call(coda::mcmc.list, lapply(chains, function(x) coda::mcmc(x$log_lambda)))
  diagnostic <- tryCatch({
    val <- coda::gelman.diag(traces, autoburnin = FALSE, transform = FALSE,
      multivariate = FALSE)$psrf[1L, 1L]
    if (!is.finite(val)) stop("Non-finite R-hat")
    list(rhat = val, detail = "")
  }, error = function(err) list(rhat = NA_real_, detail = conditionMessage(err)))
  field <- function(k) vapply(chains, function(x) as.numeric(x[[k]]), 0)
  selected_for_real <- isTRUE(b0 == selected$b0[match(tau, e18_taus)])
  rhat_gate_applies <- !prime || (selected_for_real && b0 == 1e-2)
  diagnostics <- data.frame(tau = tau, b0 = b0, a0 = if (prime) 8640L else 1L,
    log_lambda_ess_chain_1 = field("ess_log_lambda")[1L],
    log_lambda_ess_chain_2 = field("ess_log_lambda")[2L],
    log_lambda_ess_combined = as.numeric(coda::effectiveSize(traces)),
    lambda_median = exp(median(unlist(lapply(chains, `[[`, "log_lambda")))),
    log_lambda_rhat = diagnostic$rhat, rhat_detail = diagnostic$detail,
    rhat_gate_applies = rhat_gate_applies,
    STOP_rhat = rhat_gate_applies && is.finite(diagnostic$rhat) && diagnostic$rhat > 1.1,
    theta_ess_median_chain_1 = field("ess_theta_median")[1L],
    theta_ess_median_chain_2 = field("ess_theta_median")[2L],
    acceptance_chain_1 = field("acc")[1L], acceptance_chain_2 = field("acc")[2L],
    sigma_guards = sum(field("n_sigma_guard")), ipm_fallbacks = sum(field("n_ipm_fallback")),
    warm_ipm_unconverged = sum(field("n_warm_ipm_unconverged")),
    fit_wall_seconds_chain_1 = field("seconds")[1L], fit_wall_seconds_chain_2 = field("seconds")[2L])
  if (!prime) return(list(fit = fit, diagnostics = diagnostics))
  diagnostics$selected_for_real <- selected_for_real
  warm <- e18_warm_summary(setNames(lapply(e18_warm_fields, field), e18_warm_fields))
  list(fit = fit, chain_medians = medians[1:2, , drop = FALSE],
    diagnostics = cbind(diagnostics, theta_comparison(draws, medians, tau), as.data.frame(warm)))
}

pmala <- setNames(lapply(grid_rates, function(b0) {
  lapply(e18_taus, function(tau) {
    which <- real_grid$tau == tau & real_grid$b0 == b0
    record_cell(got$records[which], tau, b0)
  })
}), sprintf("pmala_r%d", round(-log10(grid_rates))))
cell_diag <- do.call(rbind, unlist(lapply(pmala, function(cells)
  lapply(cells, `[[`, "diagnostics")), recursive = FALSE))
if (!is.null(cell_diag)) emit(cell_diag, "spod_cell_health")

fits <- lapply(pmala, function(cells) lapply(cells, `[[`, "fit"))
b0_by_view <- lapply(grid_rates, rep, times = length(e18_taus))
names(b0_by_view) <- names(fits)
fits$pmala_selected <- lapply(seq_along(e18_taus), function(i) {
  if (!is.na(selected$b0[i])) pmala[[match(selected$b0[i], grid_rates)]][[i]]$fit
})
b0_by_view$pmala_selected <- selected$b0
if (with_admm) {
  fits$admm <- lapply(admm$records, function(x)
    if (!is.null(x)) d$center + d$scale * x$est)
  b0_by_view$admm <- rep(NA_real_, length(e18_taus))
}
labels <- function(name) {
  b0 <- b0_by_view[[name]]
  ifelse(is.na(b0), sprintf("tau = %.2f", e18_taus),
    sprintf("tau = %.2f, b0 = %.0e", e18_taus, b0))
}
colors <- c("#0072B2", "#009E73", "#D55E00")
p <- c(.90, .95, .99)
hours <- d$offsets / 3600
assess <- function(name, series) {
  available <- !vapply(series, is.null, FALSE)
  stats <- do.call(rbind, lapply(which(available), function(i) {
    residual <- d$block_mean - series[[i]]
    cuts <- quantile(residual, p, names = FALSE)
    data.frame(method = name, tau = e18_taus[i], b0 = b0_by_view[[name]][i],
      fraction_below = mean(residual < 0), threshold_90 = cuts[1L],
      threshold_95 = cuts[2L], threshold_99 = cuts[3L],
      wall_seconds_admm = if (name == "admm") admm$records[[i]]$seconds else NA_real_)
  }))
  pairs <- combn(seq_along(e18_taus), 2L, simplify = FALSE)
  cross_vectors <- lapply(pairs, function(pair) {
    if (all(available[pair])) series[[pair[1L]]] > series[[pair[2L]]] else rep(NA, n)
  })
  crossing <- do.call(rbind, lapply(seq_along(pairs), function(i) {
    pair <- pairs[[i]]
    data.frame(method = name, tau_lower = e18_taus[pair[1L]], tau_upper = e18_taus[pair[2L]],
      b0_lower = b0_by_view[[name]][pair[1L]], b0_upper = b0_by_view[[name]][pair[2L]],
      crossed_points = sum(cross_vectors[[i]]), n_points = n)
  }))
  crossing$any_crossing_points <- if (all(available)) sum(Reduce(`|`, cross_vectors)) else NA_integer_
  list(stats = stats, crossing = crossing)
}
scored <- lapply(names(fits), function(name) assess(name, fits[[name]]))
stats <- do.call(rbind, lapply(scored, `[[`, "stats"))
if (!is.null(stats)) emit(stats, "spod_calibration_thresholds")
emit(do.call(rbind, lapply(scored, `[[`, "crossing")), "spod_crossings")

plot_fits <- function(name, series) {
  file <- file.path(out, paste0("spod_quantiles_", name, ".png"))
  png(file, 1440, 780, res = 144)
  on.exit(dev.off())
  par(mar = c(4, 4.5, 1, 1))
  plot(hours, d$block_mean, type = "l", col = "grey62",
    ylim = range(c(d$block_mean, unlist(series))), xlim = c(0, 24), xaxt = "n",
    xlab = "Hour on June 15", ylab = "PID (counts)")
  axis(1L, at = seq(0, 24, by = 4))
  for (i in seq_along(series)) lines(hours, series[[i]], col = colors[i], lwd = 2)
  legend("topright", c("Observed", labels(name)), col = c("grey62", colors), lty = 1, bty = "n")
}
plot_detrended <- function(name, series) {
  file <- file.path(out, paste0("spod_detrended_", name, ".png"))
  png(file, 1440, 1200, res = 144)
  on.exit(dev.off())
  par(mfrow = c(3, 1), mar = c(3.5, 4.5, 2, 1))
  for (i in seq_along(series)) {
    residual <- d$block_mean - series[[i]]
    cuts <- quantile(residual, p, names = FALSE)
    plot(hours, residual, type = "l", col = "grey45", main = labels(name)[i],
      xlim = c(0, 24), xaxt = "n", xlab = "Hour on June 15", ylab = "Detrended PID (counts)")
    axis(1L, at = seq(0, 24, by = 4))
    abline(h = cuts, col = colors, lty = 2:4, lwd = 2)
    legend("topright", c("90th percentile", "95th percentile", "99th percentile"),
      col = colors, lty = 2:4, bty = "n")
  }
}
plot_chain_overlay <- function(tau, b0, medians) {
  file <- file.path(out, sprintf("spod_chain_overlay_t%02d_r%d.png",
    round(100 * tau), round(-log10(b0))))
  png(file, 1440, 780, res = 144)
  on.exit(dev.off())
  par(mar = c(4, 4.5, 3, 1))
  plot(hours, d$block_mean, type = "l", col = "grey62",
    ylim = range(d$block_mean, medians), xlim = c(0, 24), xaxt = "n",
    xlab = "Hour on June 15", ylab = "PID (counts)",
    main = sprintf("Chain posterior medians at tau %.2f, b0 = %.0e", tau, b0))
  axis(1L, at = seq(0, 24, by = 4))
  lines(hours, medians[1L, ], col = "#0072B2", lwd = 2)
  lines(hours, medians[2L, ], col = "#D55E00", lwd = 2, lty = 2)
  legend("topright", c("Observed", "Chain A (seed 1001)", "Chain B (seed 1002)"),
    col = c("grey62", "#0072B2", "#D55E00"), lty = c(1, 1, 2), bty = "n")
}
if (prime) {
  for (i in which(!is.na(selected$b0))) {
    b0 <- selected$b0[i]
    cell <- pmala[[match(b0, grid_rates)]][[i]]
    if (!is.null(cell)) plot_chain_overlay(e18_taus[i], b0, cell$chain_medians)
  }
}
for (name in names(fits)) {
  series <- fits[[name]]
  if (any(vapply(series, is.null, FALSE))) next
  plot_fits(name, series)
  plot_detrended(name, series)
  emit(data.frame(seconds_since_midnight = d$offsets, observed = d$block_mean,
    fit_tau01 = series[[1L]], fit_tau05 = series[[2L]], fit_tau10 = series[[3L]]),
    paste0("spod_curves_", name))
}
if (with_admm && any(!benchmark$match_to_1_decimal, na.rm = TRUE))
  warning("ADMM selected different lambda values than the paper. See spod_admm_lambda_check.csv.")
if (length(stall_ids) || (!is.null(cell_diag) && any(cell_diag$STOP_rhat)))
  stop("STOP: a chain stalled or log-lambda R-hat exceeded 1.1 in a gated cell. See the chain and cell health CSVs.")
if (nrow(got$issues) || (!prime && nrow(admm$issues))) stop("Incomplete real-data fit set. See issue CSVs.")
if (selected$branch[1L] == "iii") stop("STOP: Stage 1 did not select a rate triple. Escalate to HQ.")
