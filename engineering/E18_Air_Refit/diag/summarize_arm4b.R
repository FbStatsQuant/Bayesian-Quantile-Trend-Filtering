args <- commandArgs(TRUE)
stopifnot(length(args) == 1L)
out <- normalizePath(args[1L], mustWork = TRUE)
source("engineering/E18_Air_Refit/e18_common.R")
paths <- file.path(out, sprintf("arm%d_s001.rds", 41:42))
stopifnot(all(file.exists(paths)))
fits <- lapply(paths, readRDS)
a <- fits[[1L]]
b <- fits[[2L]]
stopifnot(identical(a$chain, "A"), identical(b$chain, "B"), a$chain_seed != b$chain_seed,
  identical(a$truth, b$truth), identical(a$thinned_sweeps, b$thinned_sweeps),
  all(vapply(fits, function(x) identical(dim(x$theta), c(60000L, 500L)), FALSE)),
  length(a$thinned_sweeps) == 666L, requireNamespace("coda", quietly = TRUE))
draws <- lapply(fits, function(x) x$theta[x$thinned_sweeps - 30000L, , drop = FALSE])
chain_list <- do.call(coda::mcmc.list, lapply(draws, coda::mcmc))
ess <- c(lapply(draws, coda::effectiveSize), list(coda::effectiveSize(chain_list)))
est <- list(a$est, b$est, (a$est + b$est) / 2)
pooled_bands <- vapply(seq_along(a$truth), function(j)
  quantile(c(a$theta[, j], b$theta[, j]), c(.025, .975), names = FALSE), numeric(2L))
pooled_coverage <- mean(pooled_bands[1L, ] <= a$truth & a$truth <= pooled_bands[2L, ])
rows <- data.frame(chain = c("A", "B", "pooled"),
  init = c("E-18 data-based", "ADMM", "combined"),
  chain_seed = c(a$chain_seed, b$chain_seed, NA_integer_),
  theta_ess_median = vapply(ess, median, 0),
  theta_ess_p10 = vapply(ess, function(x) unname(quantile(x, .1)), 0),
  coverage = c(a$summary$coverage, b$summary$coverage, pooled_coverage),
  mse = vapply(est, function(x) mean((x - a$truth)^2), 0),
  lambda_mean = c(a$summary$lambda_mean, b$summary$lambda_mean, NA_real_),
  lambda_p10 = c(a$summary$lambda_p10, b$summary$lambda_p10, NA_real_),
  lambda_p90 = c(a$summary$lambda_p90, b$summary$lambda_p90, NA_real_),
  seconds = c(a$summary$seconds, b$summary$seconds, NA_real_),
  cpu_seconds = c(a$summary$cpu_seconds, b$summary$cpu_seconds, NA_real_))
write.csv(rows, file.path(out, "arm4b_chains.csv"), row.names = FALSE)

if (requireNamespace("posterior", quietly = TRUE)) {
  method <- "rank-normalized folded split R-hat"
  rhat <- vapply(seq_along(a$truth), function(j)
    posterior::rhat(cbind(draws[[1L]][, j], draws[[2L]][, j])), 0)
} else {
  method <- "classic split Gelman-Rubin (coda)"
  halves <- seq_len(333L)
  split <- unlist(lapply(draws, function(x) list(x[halves, ], x[halves + 333L, ])), recursive = FALSE)
  rhat <- coda::gelman.diag(do.call(coda::mcmc.list, lapply(split, coda::mcmc)),
    autoburnin = FALSE, transform = FALSE, multivariate = FALSE)$psrf[, 1L]
}
peak <- e18_table2_archive(".")$data[[1L]]$s > .05
pi <- which(peak)
oi <- which(!peak)
# Predefined by the signal only: three evenly spaced peak ranks, plus the
# nearest unused nonpeak point to each of seven evenly spaced grid indices.
peak_fixed <- pi[ceiling(length(pi) * c(1, 3, 5) / 6)]
off_fixed <- integer()
for (j in round(seq(1, 500, length.out = 7L))) {
  free <- setdiff(oi, off_fixed)
  off_fixed <- c(off_fixed, free[which.min(abs(free - j))])
}
fixed <- sort(c(peak_fixed, off_fixed))
stopifnot(length(fixed) == 10L, sum(peak[fixed]) == 3L, length(rhat) == 500L)
diag <- data.frame(index = seq_along(rhat), peak, fixed = seq_along(rhat) %in% fixed,
  rhat = as.numeric(rhat), method)
write.csv(diag, file.path(out, "arm4b_rhat.csv"), row.names = FALSE)
write.csv(do.call(rbind, lapply(fits, `[[`, "summary")),
  file.path(out, "arm4b_fit_metrics.csv"), row.names = FALSE)
print(rows, row.names = FALSE)
print(diag[fixed, ], row.names = FALSE)
cat(sprintf("Max R-hat %.5f at index %d, %d/500 > 1.1, %d nonfinite.\n",
  max(rhat, na.rm = TRUE), which.max(rhat), sum(rhat > 1.1, na.rm = TRUE), sum(!is.finite(rhat))))
