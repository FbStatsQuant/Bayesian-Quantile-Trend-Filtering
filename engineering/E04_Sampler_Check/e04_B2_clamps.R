# E-04 part B2 (Astra findings 1-2): do the latent clamps change E-02's quantities?  Production Gibbs (paper's z safeguards +
# 1/s cap) vs clamp-free exact latents, on identical data and identical MCMC seeds, in the cells where clamps could bind:
# Cauchy noise, the largest penalties, an asymmetric quantile, and a moderate control.  Also reports clamp-hit rates.
E02_DIR <- Sys.getenv("E02_DIR", "/home/fb31/Bayesian-Quantile-Trend-Filtering/engineering/E02_Rate_Sims")
OUT <- file.path(Sys.getenv("E04_OUT", "/home/fb31/Bayesian-Quantile-Trend-Filtering/runs/E04"), "B2"); dir.create(OUT, recursive = TRUE, showWarnings = FALSE)
source(file.path(E02_DIR, "e02_lib.R")); load_kernel()
cal <- readRDS(file.path(E02_DIR, "calibration.rds"))
cells <- list(
  list(id = "cauchy_PQT_b2.5_n4000", truth = "PQT", noise = "cauchy10", tau = 0.5, n = 4000, lam = 4000^2.5),
  list(id = "cauchy_PQT_b15_7_n4000", truth = "PQT", noise = "cauchy10", tau = 0.5, n = 4000, lam = 4000^(15/7)),
  list(id = "extreme_sin_1e9_n1000", truth = "sin", noise = "g25", tau = 0.5, n = 1000, lam = 1e9),
  list(id = "extreme_PQT_1e9_n1000", truth = "PQT", noise = "g25", tau = 0.5, n = 1000, lam = 1e9),
  list(id = "tau09_sin_b9_4_n2000", truth = "sin", noise = "g25", tau = 0.9, n = 2000, lam = 2000^(9/4)),
  list(id = "control_sin_cal15_7_n2000", truth = "sin", noise = "gauss", tau = 0.5, n = 2000, lam = NA))
jobs <- expand.grid(cell = seq_along(cells), seed = 1:5, exact = c(FALSE, TRUE))
res <- parallel::mclapply(seq_len(nrow(jobs)), function(j) {
  jb <- jobs[j, ]; cl <- cells[[jb$cell]]
  d <- make_data(cl$truth, cl$noise, cl$tau, cl$n, jb$seed); sig <- sigma0(cl$noise, cl$tau)
  lam <- if (is.na(cl$lam)) cal$Lstar * (cl$n / 500)^(15/7) / sig else cl$lam
  map <- qtf_map_best(d$y, cl$tau, lam * sig); set.seed(jb$seed + 1000L)
  ch <- run_gibbs_frozen(d$y, d$theta_star, cl$tau, lam, sig, map, burn = 1000, keep = 5000, thin = 5, exact_latents = jb$exact)
  data.frame(cell = cl$id, seed = jb$seed, exact = jb$exact, t(ch$summ[c("d2_mean", "centre_d2", "rough_spread", "total_spread", "pen_ratio", "cover95", "ess_d2", "clamp_rate_z", "clamp_rate_iw")]))
}, mc.cores = as.integer(Sys.getenv("SLURM_CPUS_PER_TASK", "2")), mc.preschedule = FALSE)
R <- do.call(rbind, res); saveRDS(R, file.path(OUT, "B2.rds"))
cat("paired comparison (exact - production), mean over 5 seeds; rel = diff / production mean; z = mean diff / se(diff)\n")
for (cid in unique(R$cell)) {
  P <- R[R$cell == cid & !R$exact, ]; E <- R[R$cell == cid & R$exact, ]; P <- P[order(P$seed), ]; E <- E[order(E$seed), ]
  line <- sapply(c("d2_mean", "centre_d2", "rough_spread", "pen_ratio", "cover95"), function(k) { dd <- E[[k]] - P[[k]]
    sprintf("%s rel %+.4f z %+.2f", k, mean(dd) / mean(P[[k]]), mean(dd) / (sd(dd) / sqrt(length(dd)) + 1e-300)) })
  cat(sprintf("%-28s clamp rates (prod): z %.2e, 1/s %.2e\n   %s\n", cid, mean(P$clamp_rate_z), mean(P$clamp_rate_iw), paste(line, collapse = " | ")))
}
