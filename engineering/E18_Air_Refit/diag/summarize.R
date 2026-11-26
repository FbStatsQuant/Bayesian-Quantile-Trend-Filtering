args <- commandArgs(TRUE)
stopifnot(length(args) == 1L)
out <- normalizePath(args[1L], mustWork = TRUE)
source("engineering/E18_Air_Refit/e18_common.R")
archive <- e18_table2_archive(".")
offsets <- e18_table2_offsets(".")
read_control <- function(seed) {
  d <- archive$data[[seed]]
  tr <- d$theta + offsets[match(.05, e18_taus)]
  path <- sprintf("runs/E18-sim-20261126/sim/t05_r6_s%03d.rds", seed)
  x <- readRDS(path)
  stopifnot(x$task$seed == seed, x$task$tau == .05, x$task$b0 == 1e-6, x$commit == e18_pin,
    identical(x$y_sha, e18_vector_sha(d$y)), identical(x$baseline_sha, e18_vector_sha(d$theta)),
    identical(x$truth_sha, e18_vector_sha(tr)))
  sq <- (x$est - tr)^2
  peak <- d$s > .05
  lam <- exp(x$log_lambda)
  stopifnot(length(lam) == 666L, isTRUE(all.equal(mean(sq), x$metrics[["MSE"]])))
  data.frame(arm = 1L, tau = .05, seed, a0 = 1, b0 = 1e-6, sweeps = 30000L,
    burn = 10000L, thin_by = 30L, mse = mean(sq),
    mse_peak = sum(sq[peak]) / length(tr), mse_off_peak = sum(sq[!peak]) / length(tr),
    coverage = x$metrics[["coverage"]], lambda_mean = mean(lam),
    lambda_p10 = unname(quantile(lam, .1)), lambda_p90 = unname(quantile(lam, .9)),
    mean_Dtheta_l1 = NA_real_, log_lambda_ess = x$ess_log_lambda, theta_ess_median = x$ess_theta_median,
    theta_ess_p10 = NA_real_, theta_ess_p05 = x$ess_theta_p05,
    acceptance = x$acc, sigma_guards = x$n_sigma_guard, n_ipm_fallback = x$n_ipm_fallback,
    n_warm_ipm_unconverged = x$n_warm_ipm_unconverged, admm_lambda = NA_real_,
    start_lambda = length(tr) - 3L, seconds = x$sampler_seconds, cpu_seconds = 0, commit = x$commit)
}
existing <- lapply(1:5, read_control)
paths <- list.files(out, "^arm[2-5]_s00[1-5][.]csv$", full.names = TRUE)
rows <- do.call(rbind, c(existing, lapply(paths, read.csv)))
stopifnot(!anyDuplicated(rows[c("arm", "seed")]),
  all(abs(rows$mse_peak + rows$mse_off_peak - rows$mse) < 1e-12))
rows$lambda_summary_source <- ifelse(rows$arm == 1L, "666 thinned draws", "all retained draws")
write.csv(rows, file.path(out, "per_fit.csv"), row.names = FALSE)
counts <- tabulate(rows$arm, nbins = 5L)
labels <- c("E-18 archive", "90k sweeps", "ADMM initialized", "Table 2 prior", "Table 2 prior")
cols <- c("mse", "mse_peak", "mse_off_peak", "coverage", "lambda_mean", "lambda_p10", "lambda_p90",
  "mean_Dtheta_l1", "log_lambda_ess", "theta_ess_median", "theta_ess_p10", "theta_ess_p05",
  "acceptance", "sigma_guards", "n_ipm_fallback", "n_warm_ipm_unconverged", "seconds")
mean_avail <- function(x) if (length(x) && any(!is.na(x))) mean(x, na.rm = TRUE) else NA_real_
arms <- do.call(rbind, lapply(seq_along(labels), function(a) {
  x <- rows[rows$arm == a, ]
  tau <- if (a == 5L) .01 else .05
  old_pmala <- if (tau == .01) .0461 else .0138
  old_admm <- if (tau == .01) .0302 else .0127
  data.frame(arm = a, condition = labels[a], tau, n = counts[a],
    as.list(vapply(x[cols], mean_avail, 0)),
    published_pmala_mse = old_pmala, published_admm_mse = old_admm,
    ratio_to_pmala = mean_avail(x$mse) / old_pmala, ratio_to_admm = mean_avail(x$mse) / old_admm)
}))
write.csv(arms, file.path(out, "per_arm.csv"), row.names = FALSE)
replays <- list.files(out, "^replay_.+[.]csv$", full.names = TRUE)
if (length(replays)) write.csv(do.call(rbind, lapply(replays, read.csv)),
  file.path(out, "interior_replays.csv"), row.names = FALSE)
print(arms[c("arm", "tau", "n", "mse", "coverage", "ratio_to_pmala", "ratio_to_admm")], row.names = FALSE)
cat(sprintf("Measured fitting CPU (excludes compilation/file writes and warm probe) %.4f core-hours.\n",
  sum(rows$cpu_seconds) / 3600))
