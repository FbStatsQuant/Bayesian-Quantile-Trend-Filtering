source("/home/fb31/Bayesian-Quantile-Trend-Filtering/engineering/E07_Tuning_Free/joint_gibbs/validate/common2.R")
d <- simulate_data(1, 500, 0.5, "VS", "Normal"); y <- d$y; a0 <- 1; b0 <- 0.01; S <- 4000; B <- 1000
fj <- bqtf_joint2(y, 0.5, a0, b0, 0.1, 0.1, S, B, chain_ids = 1:2, seed = 1)
fi <- bqtf_tf(y, 0.5, "P", move = "exact", standardize = FALSE, a0 = a0, b0 = b0, a_s = 0.1, b_s = 0.1, chains = 2, fixed_sweeps = S)
lj <- as.vector(fj$lambda[(B+1):S, 1, ]); sj <- as.vector(fj$sigma[(B+1):S, 1, ])
ess <- function(x) posterior::ess_bulk(matrix(x, ncol = 2))
cat(sprintf("JOINT2 J=1: lambda mean %.4g (MCse %.3g) median %.4g ; sigma mean %.5g (MCse %.3g)\n", mean(lj), sd(lj)/sqrt(ess(lj)), median(lj), mean(sj), sd(sj)/sqrt(ess(sj))))
cat(sprintf("INDIV     : lambda mean %.4g median %.4g ; sigma mean %.5g\n", mean(fi$lambda), median(fi$lambda), mean(fi$sigma)))
dm <- fj$levels[[1]]$mean - fi$mean
cat(sprintf("curve: max|diff| %.4g, RMS diff %.4g (%.3f x avg post sd); MSE vs truth joint2 %.5g indiv %.5g\n", max(abs(dm)), sqrt(mean(dm^2)), sqrt(mean(dm^2)) / mean(apply(fi$draws, 2, sd)), mean((fj$levels[[1]]$mean - d$truth)^2), mean((fi$mean - d$truth)^2)))
cat(sprintf("Rhat loglam joint2 %.3f ESS %.0f (indiv ESS %.0f); pCN acc %.3f ASIS moved %.3f; secs/sweep %.4f; crossings %d\n", posterior::rhat(matrix(log(lj), ncol = 2)), ess(log(lj)), fi$ess_loglam, mean(fj$acc_pcn), mean(fj$asis_moved), mean(fj$sec_per_sweep), sum(fj$crossings)))
