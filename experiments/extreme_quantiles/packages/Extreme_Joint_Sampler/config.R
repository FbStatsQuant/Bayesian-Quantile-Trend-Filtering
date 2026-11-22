# Extreme-quantile campaign, joint job: the non-crossing joint sampler fits six levels together.
# Only 0.96-0.99 are analysed (MSE, crossings); 0.90 and 0.93 are fitted but excluded from every summary.
# The sampler keeps every setting saved in source/Joint/Joint_Sampler_PMALA_Augmented.R except
# tau_list, baseline, noise and the overrides below (lambda prior rate, run length).
cfg <- list(
  schema_version = 1L, campaign = "extreme_joint", validation = FALSE,
  n = 500L, seeds = 1:100,
  baselines = c("VS", "S"), noises = c("Normal", "Beta", "Mixed"),
  fit_taus = c(0.90, 0.93, 0.96, 0.97, 0.98, 0.99),
  report_taus = c(0.96, 0.97, 0.98, 0.99),
  order = 2L,                                   # k = 2; equals the saved value (checked)
  lambda_prior_rate = c(VS = 0.01, S = 0.001),  # Gamma(a0, b0) rate b0 at every level, by baseline
  # 30k sweeps / 10k burn-in for both baselines (user, 2026-10-07). For VS this reproduces the 2026-10-02
  # campaign (identical code, data, seeds), whose joint fits had the lowest MSE in 9 of 12 VS cells.
  # The 10k/3k run (extreme_joint_VS_S_10k3k_20261007) stopped while interior-level lambda was still falling.
  mcmc_iter = 30000L, mcmc_burn = 10000L,
  sampler_seed_offset = 1000L,
  joint_validation_overrides = list(),          # validation only (e.g. warm_sweeps); empty in production
  concurrency = 400L
)

validate_config <- function(x) {
  stopifnot(identical(x$baselines, c("VS", "S")), identical(x$noises, c("Normal", "Beta", "Mixed")),
    identical(x$fit_taus, c(0.90, 0.93, 0.96, 0.97, 0.98, 0.99)),
    identical(x$report_taus, c(0.96, 0.97, 0.98, 0.99)), all(x$report_taus %in% x$fit_taus),
    x$order == 2L, identical(names(x$lambda_prior_rate), c("VS", "S")),
    x$mcmc_iter > x$mcmc_burn, x$sampler_seed_offset == 1000L,
    length(x$seeds) >= 1L, !anyDuplicated(x$seeds), all(x$seeds >= 1L), x$concurrency == 400L)
  if (!isTRUE(x$validation)) stopifnot(x$n == 500L, identical(x$seeds, 1:100),
    x$lambda_prior_rate[["VS"]] == 0.01, x$lambda_prior_rate[["S"]] == 0.001,
    x$mcmc_iter == 30000L, x$mcmc_burn == 10000L, length(x$joint_validation_overrides) == 0L)
  invisible(TRUE)
}

# Seed varies fastest, then noise, then baseline: with 100 seeds, VS = 1-300 and S = 301-600,
# one batch (array) per baseline.
task_grid <- function(x) {
  g <- expand.grid(seed = x$seeds, noise = x$noises, baseline = x$baselines, stringsAsFactors = FALSE)
  g$index <- seq_len(nrow(g)); g$method <- "joint"
  g[c("index", "method", "baseline", "noise", "seed")]
}
task_root_of <- function(run_root, row) file.path(run_root, "tasks", "joint", row$baseline, row$noise,
  sprintf("seed_%03d", row$seed))
batch_table <- function(x) {
  g <- task_grid(x)
  do.call(rbind, lapply(seq_along(x$baselines), function(b) {
    idx <- g$index[g$baseline == x$baselines[b]]
    data.frame(batch = b, method = "joint", first = min(idx), last = max(idx),
               time = "06:00:00", mem = "4G", job_name = paste0("ext_joint_", x$baselines[b]))
  }))
}
