source("/home/fb31/Bayesian-Quantile-Trend-Filtering/engineering/E07_Tuning_Free/joint_gibbs/common_v3.R")
a <- commandArgs(TRUE); S <- as.integer(a[1]); stk <- a[2] == "1"
taus <- c(0.90, 0.93, 0.96, 0.97, 0.98, 0.99); y <- simulate_data(1, 500, taus[1], "VS", "Normal")$y
f <- bqtf_joint3(y, taus, 1, 0.01, 0.1, 0.1, S, S %/% 3, chain_id = 1, stack = stk, verbose = TRUE)
cat(sprintf("sec/sweep %.4f crossings %d capped %d\n", f$seconds / S, sum(f$crossings), f$capped))
cat("bounces median:", apply(f$bounces, 2, median), " max:", apply(f$bounces, 2, max), "\n")
cat("lambda median (post):", round(apply(f$lambda[(S %/% 3 + 1):S, ], 2, median), 1), "\n")
cat("mean |dlog lam|/sweep:", round(colMeans(f$dlam_sweep[(S %/% 3 + 1):S, ]), 3), "\n")
