# E-02 validation: banded Gibbs (workhorse) vs exact P-MALA (paper kernel) on the same frozen posterior.
# Long chains at small n; compare posterior mean, pointwise sd, mean Delta2 and spread with batch-means standard errors.
source(file.path(Sys.getenv("E02_DIR", "/home/fb31/Bayesian-Quantile-Trend-Filtering/engineering/E02_Rate_Sims"), "e02_lib.R")); load_kernel()
OUT_V <- file.path(Sys.getenv("E02_OUT", "/home/fb31/Bayesian-Quantile-Trend-Filtering/runs/E02"), "validation"); dir.create(OUT_V, recursive = TRUE, showWarnings = FALSE)
bm_se <- function(v, nb = 50) { b <- floor(length(v) / nb); sd(colMeans(matrix(v[1:(b * nb)], b, nb))) / sqrt(nb) }
cells <- list(list(truth = "sin", noise = "gauss", tau = 0.5, n = 250, Lam = 20),
              list(truth = "sin", noise = "gauss", tau = 0.9, n = 250, Lam = 450),
              list(truth = "pq",  noise = "t2",    tau = 0.5, n = 250, Lam = 450),
              list(truth = "sin", noise = "gauss", tau = 0.5, n = 500, Lam = 2000))
res <- parallel::mclapply(seq_along(cells), function(i) {
  cl <- cells[[i]]; d <- make_data(cl$truth, cl$noise, cl$tau, cl$n, 11); sig <- sigma0(cl$noise, cl$tau); lam <- cl$Lam / sig
  map <- qtf_map_best(d$y, cl$tau, cl$Lam)
  set.seed(1); g <- run_gibbs_frozen(d$y, d$theta_star, cl$tau, lam, sig, map, burn = 2000, keep = 100000, thin = 10)
  set.seed(2); p <- run_frozen(d$y, d$theta_star, cl$tau, lam, sig, map, burn = 5000, keep = 400000, thin = 40)
  list(cell = cl, g = g, p = p)
}, mc.cores = as.integer(Sys.getenv("SLURM_CPUS_PER_TASK", Sys.getenv("OWLS_JOB_CORES", "2"))))
saveRDS(res, file.path(OUT_V, "validate_samplers.rds"))
for (r in res) {
  cl <- r$cell; g <- r$g; p <- r$p
  dm <- r$g$post_mean - r$p$post_mean
  cat(sprintf("\n== %s %s tau=%.2f n=%d Lam=%g ==\n", cl$truth, cl$noise, cl$tau, cl$n, cl$Lam))
  cat(sprintf("Gibbs : d2 %.5f (se %.5f) spread %.5f centre %.5f ESS_d2 %.0f  %.0fs\n", g$summ["d2_mean"], bm_se(g$trace$d2), g$summ["spread_d2"], g$summ["centre_d2"], g$summ["ess_d2"], g$summ["seconds"]))
  cat(sprintf("PMALA : d2 %.5f (se %.5f) spread %.5f centre %.5f ESS_d2 %.0f  acc %.2f %.0fs\n", p$summ["d2_mean"], bm_se(p$trace$d2), p$summ["spread_d2"], p$summ["centre_d2"], p$summ["ess_d2"], p$summ["acc_post"], p$summ["seconds"]))
  cat(sprintf("max |post mean diff| = %.4g ; median = %.4g ; ciw95 Gibbs %.4f PMALA %.4f ; z(d2 diff) = %.2f\n",
              max(abs(dm)), median(abs(dm)), g$summ["ciw95"], p$summ["ciw95"],
              (g$summ["d2_mean"] - p$summ["d2_mean"]) / sqrt(bm_se(g$trace$d2)^2 + bm_se(p$trace$d2)^2)))
}
