# Production specification: S baseline, inner quantiles, individual P-MALA.
# Identical to the 2026-10-03 campaign (VS_S_inner_100seeds_15k_3k_b001) except the user's overrides
# (2026-10-08, 2026-10-12): lambda rate b0 = 0.0005, ASIS off, 20,000 sweeps with 5,000 burn-in.
# The source snapshot is the 10-03 sampler file; `overrides` lists every setting that differs from its Settings block.
cfg <- list(
  experiment = "individual_inner_S_b00005", validation = FALSE,
  baselines = "S", noises = c("Normal", "Beta", "Mixed"),
  taus = c(0.05, 0.25, 0.50, 0.75, 0.95), seeds = 1:100, n = 500L,
  sampler_seed_offset = 1000L, ci_probs = c(0.025, 0.975),
  sampler = list(order = 2L, a0 = 1, b0 = 0.0005,
    a_sigma = 0.1, b_sigma = 0.1, gibbs_iter = 20000L, gibbs_burn = 5000L,
    delta_init = 0.2, lambda_init = NULL,
    adapt_target = 0.50, adapt_gain = 1, adapt_kappa = 0.6,
    delta_bounds = c(1e-8, 100), metric = "curv", c_fixed = 1e4,
    rho = NULL, iters = 150L, mh = TRUE, adapt = TRUE, init = "y",
    warm = 200L, gamma_warm = 1e4, prior_scale = "none", cmap = FALSE,
    kappa = 3, adapt_all = TRUE, K = 1L, asis = FALSE, tol = 0,
    lamjump = FALSE, lamjump_s = 0.3, verbose = TRUE),
  overrides = list(b0 = c(source = 0.01, run = 0.0005), asis = c(source = TRUE, run = FALSE)),
  tf_control = list(max_iter = 2000L, obj_tol = 1e-8))
