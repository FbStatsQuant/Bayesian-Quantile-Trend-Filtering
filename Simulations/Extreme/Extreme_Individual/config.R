# Extreme-quantile campaign, individual job: every method fits one level at a time.
# Methods: individual Bayesian-PMALA (this folder), ADMM/QTF with eBIC (../Extreme_admm),
# Onizuka BQTF MCMC with Laplace and horseshoe priors (../Extreme_Onizuka).
# PMALA keeps every setting saved in source/Individual_Sampler_PMALA_Augmented.R except
# tau, baseline, noise and the overrides below (order, lambda prior rate, run length).
cfg <- list(
  schema_version = 1L, campaign = "extreme_individual", validation = FALSE,
  n = 500L, seeds = 1:100,
  baselines = c("VS", "S"), noises = c("Normal", "Beta", "Mixed"),
  taus = c(0.96, 0.97, 0.98, 0.99),
  methods = c("pmala", "admm", "onizuka_lap", "onizuka_hs"),
  order = 2L,                                   # k = 2 (third differences) for every method
  lambda_prior_rate = c(VS = 0.01, S = 0.001),  # PMALA Gamma(a0, b0) rate b0, by baseline
  mcmc_iter = 10000L, mcmc_burn = 3000L,        # PMALA and Onizuka: total sweeps, discarded burn-in
  sampler_seed_offset = 1000L,                  # data RNG seed s, MCMC RNG seed s + 1000
  pmala_validation_overrides = list(),          # validation only (e.g. warm_sweeps); empty in production
  onizuka = list(sig.init = c(1, 1), sparse = FALSE),   # driver defaults; X = 1, ..., n
  admm = list(
    lambda_grid = exp(seq(-6, 10, by = 0.25)),  # 65 log-spaced values, 0.0025 to 22026
    ebic_gamma = 1,                             # Brantley et al. (2020) Sec. 3.2
    df_tol = 1e-6,                              # |D theta| > df_tol counts as a knot (interior-point LP solution)
    piqp_tol = 1e-9, piqp_max_iter = 5000L, piqp_retry_max_iter = 50000L),
  concurrency = 400L
)

validate_config <- function(x) {
  stopifnot(identical(x$baselines, c("VS", "S")), identical(x$noises, c("Normal", "Beta", "Mixed")),
    identical(x$taus, c(0.96, 0.97, 0.98, 0.99)),
    identical(x$methods, c("pmala", "admm", "onizuka_lap", "onizuka_hs")),
    x$order == 2L, identical(names(x$lambda_prior_rate), c("VS", "S")),
    x$mcmc_iter > x$mcmc_burn, x$sampler_seed_offset == 1000L,
    length(x$seeds) >= 1L, !anyDuplicated(x$seeds), all(x$seeds >= 1L),
    all(x$admm$lambda_grid > 0), !is.unsorted(x$admm$lambda_grid, strictly = TRUE),
    x$admm$ebic_gamma == 1, x$concurrency == 400L)
  if (!isTRUE(x$validation)) stopifnot(x$n == 500L, identical(x$seeds, 1:100),
    x$lambda_prior_rate[["VS"]] == 0.01, x$lambda_prior_rate[["S"]] == 0.001,
    x$mcmc_iter == 10000L, x$mcmc_burn == 3000L, length(x$pmala_validation_overrides) == 0L,
    length(x$admm$lambda_grid) == 65L, identical(x$onizuka$sig.init, c(1, 1)), !x$onizuka$sparse)
  invisible(TRUE)
}

# One global index per task. Seed varies fastest, then tau, noise, baseline, method:
# with 100 seeds each method owns 2,400 consecutive indices (pmala 1-2400, admm 2401-4800,
# onizuka_lap 4801-7200, onizuka_hs 7201-9600); batches.tsv lists these ranges.
task_grid <- function(x) {
  g <- expand.grid(seed = x$seeds, tau = x$taus, noise = x$noises, baseline = x$baselines,
                   method = x$methods, stringsAsFactors = FALSE)
  g$index <- seq_len(nrow(g))
  g[c("index", "method", "baseline", "noise", "tau", "seed")]
}
method_folder <- c(pmala = "Extreme_Individual", admm = "Extreme_admm",
                   onizuka_lap = "Extreme_Onizuka", onizuka_hs = "Extreme_Onizuka")
task_root_of <- function(run_root, row) file.path(run_root, "tasks", row$method, row$baseline, row$noise,
  sprintf("tau_%.2f", row$tau), sprintf("seed_%03d", row$seed))
batch_table <- function(x) {
  g <- task_grid(x)
  do.call(rbind, lapply(seq_along(x$methods), function(b) {
    idx <- g$index[g$method == x$methods[b]]
    data.frame(batch = b, method = x$methods[b], first = min(idx), last = max(idx),
               time = c(pmala = "02:00:00", admm = "01:00:00", onizuka_lap = "08:00:00", onizuka_hs = "08:00:00")[[x$methods[b]]],
               mem = c(pmala = "2G", admm = "2G", onizuka_lap = "4G", onizuka_hs = "4G")[[x$methods[b]]],
               job_name = paste0("ext_", x$methods[b]))
  }))
}
