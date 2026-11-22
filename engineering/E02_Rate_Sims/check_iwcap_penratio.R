# E-02 numerical check (2026-11-22): lambda*||D theta||_1/m and rough spread are invariant to the 1/s cap (1e2..1e10 x lambda^2).
# Results: PQT lambda 1e7 / 1e8.5 -> pen 1.003 / 1.001 for all caps; sin lambda 1e7 / 1e7.5 -> pen 1.33 / 1.55 for all caps (bias-dominated regime, a property of the target).
# Is lambda*||D theta||_1/m > 1.25 at extreme lambda a numerical artefact (iw cap) or a property of the target?
source("/home/fb31/Bayesian-Quantile-Trend-Filtering/engineering/E02_Rate_Sims/e02_lib.R"); load_kernel()
d <- make_data("sin", "g25", 0.5, 1000, 1); s0 <- sigma0("g25", 0.5)
for (ll in c(7, 7.5)) { lam <- 10^ll; m0 <- qtf_map_best(d$y, .5, lam * s0)
  for (cap in c(1e2, 1e6, 1e10)) { set.seed(3); ch <- run_gibbs_frozen(d$y, d$theta_star, .5, lam, s0, m0, burn = 1000, keep = 2000, thin = 10, iw_cap = cap)
    cat(sprintf("log10 lambda %.1f  iw_cap %.0e : pen %.3f  rough %.3e  ess_d2 %.0f\n", ll, cap, ch$summ[["pen_ratio"]], ch$summ[["rough_spread"]], ch$summ[["ess_d2"]])) } }
