# Production specification. b0 is a RATE, explicitly overriding sqrt(n).
# User override: 15,000 total Gibbs sweeps and 3,000 burn-in for every production fit.
cfg <- list(
  experiment = "individual_inner_VS_S_b001", validation = FALSE,
  baselines = c("VS", "S"), noises = c("Normal", "Beta", "Mixed"),
  taus = c(0.05, 0.25, 0.50, 0.75, 0.95), seeds = 1:100, n = 500L,
  sampler_seed_offset = 1000L, ci_probs = c(0.025, 0.975),
  sampler = list(order = 2L, a0 = 1, b0 = 0.01,
    a_sigma = 0.1, b_sigma = 0.1, gibbs_iter = 15000L, gibbs_burn = 3000L,
    delta_init = 0.2, lambda_init = NULL,
    adapt_target = 0.50, adapt_gain = 1, adapt_kappa = 0.6,
    delta_bounds = c(1e-8, 100), metric = "curv", c_fixed = 1e4,
    rho = NULL, iters = 150L, mh = TRUE, adapt = TRUE, init = "y",
    warm = 200L, gamma_warm = 1e4, prior_scale = "none", cmap = FALSE,
    kappa = 3, adapt_all = TRUE, K = 1L, asis = TRUE, tol = 0,
    lamjump = FALSE, lamjump_s = 0.3, verbose = TRUE),
  tf_control = list(max_iter = 2000L, obj_tol = 1e-8))
