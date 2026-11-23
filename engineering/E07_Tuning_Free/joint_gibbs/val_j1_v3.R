source("/home/fb31/Bayesian-Quantile-Trend-Filtering/engineering/E07_Tuning_Free/joint_gibbs/common_v3.R")
a <- commandArgs(TRUE); S <- if (length(a)) as.integer(a[1]) else 4000L; B <- S %/% 4L
d <- simulate_data(1, 500, 0.5, "VS", "Normal"); y <- d$y; a0 <- 1; b0 <- 0.01
tj <- system.time({ f1 <- bqtf_joint3(y, 0.5, a0, b0, 0.1, 0.1, S, B, chain_id = 1, verbose = TRUE); f2 <- bqtf_joint3(y, 0.5, a0, b0, 0.1, 0.1, S, B, chain_id = 2) })
ti <- system.time(fi <- bqtf_tf(y, 0.5, "P", move = "exact", standardize = FALSE, a0 = a0, b0 = b0, a_s = 0.1, b_s = 0.1, chains = 2, fixed_sweeps = S))
post <- (B + 1):S
lj <- cbind(f1$lambda[post, 1], f2$lambda[post, 1]); sj <- cbind(f1$sigma[post, 1], f2$sigma[post, 1])
mj <- (f1$mean + f2$mean) / 2
ess <- function(M) posterior::ess_bulk(M); mcse <- function(M) sd(M) / sqrt(ess(M))
cat(sprintf("J1 v3 : lambda mean %.4g (MCse %.3g) median %.4g | sigma mean %.5g (MCse %.3g) | ESS(loglam) %.0f Rhat %.3f\n", mean(lj), mcse(lj), median(lj), mean(sj), mcse(sj), ess(log(lj)), posterior::rhat(log(lj))))
cat(sprintf("bqtf_tf: lambda mean %.4g median %.4g | sigma mean %.5g | ESS(loglam) %.0f\n", mean(fi$lambda), median(fi$lambda), mean(fi$sigma), fi$ess_loglam))
dm <- mj[, 1] - fi$mean
cat(sprintf("curve: RMS diff %.4g max %.4g; RMS diff / mean posterior sd %.3f; MSE vs truth v3 %.5g bqtf_tf %.5g\n", sqrt(mean(dm^2)), max(abs(dm)), sqrt(mean(dm^2)) / mean((f1$sd[, 1] + f2$sd[, 1]) / 2), mean((mj[, 1] - d$truth)^2), mean((fi$mean - d$truth)^2)))
cat(sprintf("T-block mean|dloglam| %.3f moved %.3f ; secs v3 %.1f (2 chains) bqtf_tf %.1f ; crossings %d\n", mean(c(f1$tb_abs[post], f2$tb_abs[post])), mean(c(f1$tb_moved[post], f2$tb_moved[post])), tj[3], ti[3], sum(f1$crossings, f2$crossings)))
saveRDS(list(f1 = f1, f2 = f2, fi = fi[c("mean", "lambda", "sigma", "ess_loglam")]), file.path(SCR, "val_j1_v3.rds"))
