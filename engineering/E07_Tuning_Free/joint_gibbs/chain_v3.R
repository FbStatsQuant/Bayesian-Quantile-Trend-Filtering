# one v3 chain on the joint design. Args: chain_id sweeps burn out.rds [stack(1/0) tblock(1/0)]
source("/home/fb31/Bayesian-Quantile-Trend-Filtering/engineering/E07_Tuning_Free/joint_gibbs/common_v3.R")
a <- commandArgs(TRUE); cid <- as.integer(a[1]); S <- as.integer(a[2]); B <- as.integer(a[3]); outf <- a[4]
stk <- if (length(a) >= 5) a[5] == "1" else TRUE; tbk <- if (length(a) >= 6) a[6] == "1" else TRUE
taus <- c(0.90, 0.93, 0.96, 0.97, 0.98, 0.99); y <- simulate_data(1, 500, taus[1], "VS", "Normal")$y
truths <- sapply(taus, function(t) simulate_data(1, 500, t, "VS", "Normal")$truth)
f <- bqtf_joint3(y, taus, 1, 0.01, 0.1, 0.1, S, B, chain_id = cid, init = "smooth", stack = stk, tblock = tbk, verbose = TRUE)
f$truths <- truths
cat(sprintf("done chain %d: %.1f s (%.4f s/sweep), crossings %d\n", cid, f$seconds, f$seconds / S, sum(f$crossings)))
saveRDS(f, outf)
