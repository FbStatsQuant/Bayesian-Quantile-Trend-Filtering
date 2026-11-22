# E-02 (HQ question): is the lambda-mixing loss under b0 = n^-2 cheaply fixable?  Gibbs with lam_steps in {1, 5, 20}
# (repeated conjugate + ASIS lambda moves per sweep), sin truth, N(0, 0.25^2), sigma = sigma0, n = 2000, b0 = n^-2, 3 seeds.
source(file.path(Sys.getenv("E02_DIR", "."), "e02_lib.R")); load_kernel()
OUT <- file.path(Sys.getenv("E02_OUT", "/home/fb31/BQTF_runs/E02"), "lamsteps"); dir.create(OUT, recursive = TRUE, showWarnings = FALSE)
jobs <- expand.grid(ls = c(1L, 5L, 20L), seed = 1:3)
res <- parallel::mclapply(seq_len(nrow(jobs)), function(j) {
  jb <- jobs[j, ]; n <- 2000; d <- make_data("sin", "g25", 0.5, n, jb$seed); s0 <- sigma0("g25", 0.5)
  st <- qtf_map_best(d$y, 0.5, (n - 3) * s0); set.seed(jb$seed + 1000)
  ch <- run_gibbs_frozen(d$y, d$theta_star, 0.5, n - 3, s0, st, burn = 3000, keep = 10000, thin = 10, learn_lambda = TRUE, b0 = n^-2, lam_steps = jb$ls)
  data.frame(lam_steps = jb$ls, seed = jb$seed, lam_mean = ch$summ[["lam_mean"]], ess_loglam = ch$summ[["ess_loglam"]], drift = ch$summ[["lam_drift"]],
             ess_d2 = ch$summ[["ess_d2"]], centre_d2 = ch$summ[["centre_d2"]], sec = ch$summ[["seconds"]])
}, mc.cores = as.integer(Sys.getenv("SLURM_CPUS_PER_TASK", "2")))
R <- do.call(rbind, res); saveRDS(R, file.path(OUT, "lamsteps.rds")); print(R)
print(aggregate(cbind(ess_loglam, sec, ess_d2) ~ lam_steps, R, mean))
