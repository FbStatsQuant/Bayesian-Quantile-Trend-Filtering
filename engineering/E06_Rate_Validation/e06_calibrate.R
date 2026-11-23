# E-06 calibration (as E-02 calibrate_c.R, per truth x noise x tau):
#   Lam_star = argmin_Lam mean over 10 seeds of Delta2(MAP_Lam - theta*) at n0 = 500, on a 49-point log grid 1 .. 1e6.
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
  j <- which.min(r)
  data.frame(cb, Lam_star = grid[j], d2_min = r[j], edge = j %in% c(1, length(grid)), stringsAsFactors = FALSE)
}, mc.cores = cores, mc.preschedule = FALSE)
cal <- do.call(rbind, res)
dir.create(OUT, recursive = TRUE, showWarnings = FALSE)
saveRDS(cal, file.path(OUT, "calibration.rds")); print(cal, digits = 4)
if (any(cal$edge)) cat("WARNING: calibration minimum on the grid edge for", sum(cal$edge), "combos\n")
