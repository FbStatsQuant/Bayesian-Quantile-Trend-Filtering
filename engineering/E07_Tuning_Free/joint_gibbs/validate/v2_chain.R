cid <- as.integer(commandArgs(TRUE)[1]); sweeps <- as.integer(commandArgs(TRUE)[2]); outf <- commandArgs(TRUE)[3]
source("/home/fb31/Bayesian-Quantile-Trend-Filtering/engineering/E07_Tuning_Free/joint_gibbs/validate/common2.R")
taus <- c(0.90, 0.93, 0.96, 0.97, 0.98, 0.99); ds <- lapply(taus, function(t) simulate_data(1, 500, t, "VS", "Normal"))
f <- bqtf_joint2(ds[[1]]$y, taus, 1, 0.01, 0.1, 0.1, sweeps, sweeps %/% 2, chain_ids = cid, keep_theta = FALSE)
cat(sprintf("chain %d: %.1f s, %.4f s/sweep, crossings %d\n", cid, f$seconds, f$sec_per_sweep, sum(f$crossings)))
f$truth <- sapply(ds, function(d) d$truth); saveRDS(f, outf)
