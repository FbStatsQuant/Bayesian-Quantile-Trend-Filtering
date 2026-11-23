# Non-proximal candidate (HQ 11-23): our exact augmented Gibbs (e07_sampler, move "exact" + collapsed lambda block) on Felipe's EXACT posterior
# (raw scale, lambda ~ Gamma(1, b0 paper per signal), sigma ~ IG(0.1, 0.1)), stopping rule = 4 chains, Rhat <= 1.01, bulk+tail ESS >= 400.
# Same datasets/seeds as his runs: n = 500 sprint grid (18 cells x seeds 1-5); n = 1000/2000 cells of the V2 pilot (his C arm, seed 1).
# Saves curves (mean, median, 2.5/97.5%) for coverage and fit plots.
E07 <- Sys.getenv("E07_DIR"); E02 <- Sys.getenv("E02_DIR"); OUT <- file.path(Sys.getenv("E07_OUT"), "gibbs_vs"); dir.create(OUT, recursive = TRUE, showWarnings = FALSE)
suppressPackageStartupMessages(library(posterior))
source(file.path(E07, "sampler", "e07_sampler.R")); e07_load(file.path(E07, "sampler"), Sys.getenv("E07_CACHE"))
pl <- readLines(file.path(E07, "Individual_Sampler_PMALA_Augmented_E07R1copy.R")); i <- grep("^simulate_data", pl); j <- i + which(pl[(i + 1):length(pl)] == "}")[1]
eval(parse(text = pl[i:j]))
b0_of <- function(bl) if (bl == "VS") 1e-3 else 5e-4
g <- function(n, bl, noise, tau, seeds) expand.grid(n = n, bl = bl, noise = noise, tau = tau, seed = seeds, stringsAsFactors = FALSE)
tasks <- rbind(g(500, c("VS", "S"), c("Normal", "Beta", "Mixed"), c(0.05, 0.5, 0.95), 1:5), g(1000, c("VS", "S"), "Normal", c(0.05, 0.5, 0.95), 1), g(2000, c("VS", "S"), "Normal", 0.5, 1))
tasks$file <- file.path(OUT, sprintf("G_n%05d_%s_%s_t%03d_s%d.rds", tasks$n, tasks$bl, tasks$noise, round(100 * tasks$tau), tasks$seed))
tasks <- tasks[!file.exists(tasks$file), ]; tasks <- tasks[order(-tasks$n), ]
cat(sprintf("[%s] gibbs_vs: %d tasks\n", format(Sys.time()), nrow(tasks)))
res <- parallel::mclapply(seq_len(nrow(tasks)), function(i) { tk <- tasks[i, ]
  r <- tryCatch({
    d <- simulate_data(tk$seed, tk$n, tk$tau, tk$bl, tk$noise); set.seed(tk$seed + 3000L)
    f <- bqtf_tf(d$y, tk$tau, move = "exact", standardize = FALSE, a0 = 1, b0 = b0_of(tk$bl), a_s = 0.1, b_s = 0.1, max_sweeps = 20000L)
    row <- data.frame(tk[1:5], seconds = f$seconds, sweeps = f$sweeps, chains = f$chains, converged = f$converged, rhat_max = f$rhat_max,
                      ess_min = f$ess_min, ess_loglam = f$ess_loglam, lam_med = median(f$lambda), sig_med = median(f$sigma),
                      mse = mean((f$mean - d$truth)^2), mse_med = mean((f$median - d$truth)^2), mciw = mean(f$hi - f$lo), cover = mean(d$truth >= f$lo & d$truth <= f$hi))
    saveRDS(list(row = row, mean = f$mean, median = f$median, lo = f$lo, hi = f$hi, y = d$y, truth = d$truth), tk$file); "ok"
  }, error = function(e) paste("ERROR", conditionMessage(e)))
  if (r != "ok") cat(sprintf("task %s failed: %s\n", basename(tk$file), r)); r
}, mc.cores = as.integer(Sys.getenv("SLURM_CPUS_PER_TASK", "2")), mc.preschedule = FALSE)
cat(sprintf("[%s] done: %d ok, %d failed\n", format(Sys.time()), sum(unlist(res) == "ok"), sum(unlist(res) != "ok")))
