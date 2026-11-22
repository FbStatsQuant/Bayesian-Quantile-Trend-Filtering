# Campaign settings for the joint interior-quantile study; source snapshots are preserved verbatim.
# One task = (baseline, noise, batch, seed). Each batch is fitted jointly; only its target is reported.
# One batch per target level, each with its own jointly fitted set of levels (must include the target).
# taus = NULL marks a set not yet chosen; validate_config() refuses to run until every set is filled in.
cfg <- list(
  schema_version = 2L, experiment = "joint_interior_per_target",
  baselines = c("VS", "S"), n = 500L, seeds = 1:100,
  noises = c("Normal", "Beta", "Mixed"),
  batches = list(
    # Packed near the tails, padded around 0.25/0.75, wider spacing around the median;
    # the upper sets mirror the lower ones (tau -> 1 - tau). Written as literals so that
    # identical() comparisons never depend on floating-point 1 - x.
    t05 = list(taus = c(0.025, 0.05, 0.075, 0.10, 0.15, 0.20),        targets = 0.05),
    t25 = list(taus = c(0.10, 0.15, 0.20, 0.25, 0.30, 0.35, 0.40),    targets = 0.25),
    t50 = list(taus = c(0.20, 0.30, 0.40, 0.50, 0.60, 0.70, 0.80),    targets = 0.50),
    t75 = list(taus = c(0.60, 0.65, 0.70, 0.75, 0.80, 0.85, 0.90),    targets = 0.75),
    t95 = list(taus = c(0.80, 0.85, 0.90, 0.925, 0.95, 0.975),        targets = 0.95)
  ),
  report_taus = c(0.05, 0.25, 0.50, 0.75, 0.95),
  ci_probs = c(0.025, 0.975), sampler_seed_offset = 1000L,
  # Raw files keep every raw_keep_every-th posterior theta draw (all traces are kept in full).
  # Point estimates and intervals are always computed from all retained sweeps before thinning.
  raw_keep_every = 20L,
  prior_label = "Gamma_shape1_rate_0.01",
  sampler = list(
    order = 2L, a0 = 1, b0 = 0.01, a_sigma = 0.1, b_sigma = 0.1,
    gibbs_iter = 30000L, gibbs_burn = 10000L,
    delta_init = 0.2, lambda_init = NULL, adapt_target = 0.50,
    adapt_gain = 1, adapt_kappa = 0.6, delta_bounds = c(1e-8, 100),
    metric = "curv", c_fixed = 1e4, rho = NULL, iters = 150L,
    mh = TRUE, adapt = TRUE, warm = 200L, gamma_warm = 1e4,
    kappa = 3, adapt_all = TRUE, K = 1L, asis = TRUE, tol = 0,
    zeta_scale = 1,
    ctrl = c(method = 1, try_unbounded = 1, ipm_max_iter = 100,
             ipm_tol = 1e-8, trace = 0),
    verbose = TRUE, keep_every = 1L
  )
)
