# Air-quality peak-detection simulation (Brantley, Guinness and Chi 2020, Sec. 4.2): ADD-ON package for the
# Onizuka et al. LAPLACE-prior BQTF sampler (BQTF.MCMC.Lap.multi, unchanged BQTF-function.R), one quantile per task.
# It reproduces the design of the production run air_n500_100seeds_20261008 (Air_sim) for this one extra method:
# same data (simulate_air() of the unchanged common_air.R, data seed s), n = 500, sd_eps = 0.25, k = 2,
# tau = 0.01, 0.05, 0.10, seeds 1-100, sampler RNG seed s + 1000, signal threshold and CAA thresholds.
cfg <- list(
  schema_version = 1L, campaign = "air_sim_lap", validation = FALSE, pilot = FALSE,
  n = 500L, sd_eps = 0.25, seeds = 1:100,
  taus = c(0.01, 0.05, 0.10),
  methods = c("onizuka_lap"),
  order = 2L,                                   # k = 2: third differences, piecewise-quadratic trends (TForder = 2)
  sampler_seed_offset = 1000L,                  # data RNG seed s; sampler RNG seed s + 1000 (set.seed(seed + 1000))
  onizuka = list(sampler = "BQTF.MCMC.Lap.multi", mc = 8000L, burn = 2000L, sig.init = c(1, 1), sparse = FALSE),
  signal_threshold = 0.5,                       # true signal: s_i > 0.5 (paper Sec. 4.2 text; also stored: y_i - theta_i > 0.5)
  caa_thresholds = c(0.5, 0.75, 1, 1.2),        # classification thresholds h for y_i - theta_hat_i > h
  concurrency = 400L                            # at most 400 tasks running at once
)

validate_config <- function(x) {
  stopifnot(identical(x$taus, c(0.01, 0.05, 0.10)), identical(x$methods, "onizuka_lap"),
    x$order == 2L, x$sd_eps == 0.25, x$sampler_seed_offset == 1000L,
    length(x$seeds) >= 1L, !anyDuplicated(x$seeds), all(x$seeds >= 1L),
    x$onizuka$mc > x$onizuka$burn, identical(x$onizuka$sampler, "BQTF.MCMC.Lap.multi"),
    identical(x$onizuka$sig.init, c(1, 1)), identical(x$onizuka$sparse, FALSE),
    x$signal_threshold == 0.5, all(x$caa_thresholds > 0), x$concurrency == 400L)
  # Production settings; a pilot (submit.sh NAME SEEDS) keeps all of them except the seed set.
  if (!isTRUE(x$validation)) stopifnot(x$n == 500L, isTRUE(x$pilot) || identical(x$seeds, 1:100),
    x$onizuka$mc == 8000L, x$onizuka$burn == 2000L)
  invisible(TRUE)
}

# One global index per task. Seed varies fastest, then tau: with 100 seeds, indices 1-100 are tau = 0.01,
# 101-200 tau = 0.05, 201-300 tau = 0.10. All tasks form ONE array with at most cfg$concurrency running.
# Allocation: the same Laplace code took ~14 min for 10k sweeps at n = 500 on NOTS; 2 h and 2 GB per task.
task_grid <- function(x) {
  g <- expand.grid(seed = x$seeds, tau = x$taus, method = x$methods, stringsAsFactors = FALSE)
  g$index <- seq_len(nrow(g))
  g[c("index", "method", "tau", "seed")]
}
method_folder <- c(onizuka_lap = "Onizuka")
task_root_of <- function(run_root, row) file.path(run_root, "tasks", row$method,
  sprintf("tau_%.2f", row$tau), sprintf("seed_%03d", row$seed))
batch_table <- function(x) {
  g <- task_grid(x)
  data.frame(batch = 1L, method = "all", first = min(g$index), last = max(g$index),
             time = "02:00:00", mem = "2G", job_name = "air_lap")
}
