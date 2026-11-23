# E-06 calibration (as E-02 calibrate_c.R, per truth x noise x tau):
#   Lam_star = argmin_Lam mean over 10 seeds of Delta2(MAP_Lam - theta*) at n0 = 500, on a 49-point log grid 1 .. 1e6,
#   restricted to the many-mode regime (see Lmax below).  The full risk curves go to calibration_curves.csv.
# Writes $E06_OUT/calibration.rds (a data frame) and prints the table, with a flag if the minimum is on the grid edge.
E06_DIR <- Sys.getenv("E06_DIR", "/home/fb31/Bayesian-Quantile-Trend-Filtering/engineering/E06_Rate_Validation")
E02_DIR <- Sys.getenv("E02_DIR", "/home/fb31/Bayesian-Quantile-Trend-Filtering/engineering/E02_Rate_Sims")
OUT <- Sys.getenv("E06_OUT", "/home/fb31/BQTF_runs/E06")
source(file.path(E02_DIR, "e02_lib.R")); source(file.path(E06_DIR, "e06_lib.R")); load_kernel()
cores <- as.integer(Sys.getenv("SLURM_CPUS_PER_TASK", "2"))
grid <- 10^seq(0, 6, by = 0.125); seeds <- 1:10
combos <- expand.grid(truth = c("pq", "sin"), noise = names(STD), tau = c(0.5, 0.9), stringsAsFactors = FALSE)
res <- parallel::mclapply(seq_len(nrow(combos)), function(i) {
  cb <- combos[i, ]
  dat <- lapply(seeds, function(s) make_data(cb$truth, cb$noise, cb$tau, N0, s))
  r <- sapply(grid, function(L) mean(sapply(dat, function(d) Delta2(qtf_map_best(d$y, cb$tau, L) - d$theta_star))))
  # regime constraint (the theorem's many-mode regime, HQ gate): n * lambda^(-1/3) >= 10 in every cell of the E-06 grid, for both
  # sigma arms.  n * lambda^(-1/3) grows in n for every schedule (a < 3) and lambda(n_min) is largest under the primary a = 5/2,
  # so the binding cell is n = 1000, primary, smaller sigma: lambda0 <= (1000/10)^3 / (1000/500)^(5/2).
  Lmax <- (1000 / 10)^3 / (1000 / N0)^(5/2) * min(sigma_arm("Abar", cb$noise, cb$tau), sigma_arm("S0", cb$noise, cb$tau))
  j0 <- which.min(r); ok <- grid <= Lmax; j <- which(ok)[which.min(r[ok])]
  list(curve = r, row = data.frame(cb, Lam_star = grid[j], d2_min = r[j], Lam_unconstr = grid[j0], d2_unconstr = r[j0], Lam_max = Lmax,
             binding = j != j0, edge = j == 1, stringsAsFactors = FALSE))
}, mc.cores = cores, mc.preschedule = FALSE)
cal <- do.call(rbind, lapply(res, `[[`, "row"))
curves <- cbind(combos[rep(seq_len(nrow(combos)), each = length(grid)), ], Lam = grid, d2 = unlist(lapply(res, `[[`, "curve")))
write.csv(curves, file.path(OUT, "calibration_curves.csv"), row.names = FALSE)
dir.create(OUT, recursive = TRUE, showWarnings = FALSE)
saveRDS(cal, file.path(OUT, "calibration.rds")); print(cal, digits = 4)
if (any(cal$edge)) cat("WARNING: calibration minimum on the grid edge for", sum(cal$edge), "combos\n")
if (any(cal$binding)) cat("NOTE: the regime constraint binds for", sum(cal$binding), "combos (Lam_star = largest admissible grid point below Lam_max, or a lower local minimum)\n")
