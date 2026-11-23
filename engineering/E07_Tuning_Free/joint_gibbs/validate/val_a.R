source("/home/fb31/Bayesian-Quantile-Trend-Filtering/engineering/E07_Tuning_Free/joint_gibbs/validate/common.R")
d <- simulate_data(1, 500, 0.5, "VS", "Normal"); y <- d$y; n <- 500
a0 <- 1; b0 <- 0.01
S <- 4000; B <- 1000
tj <- system.time(fj <- bqtf_joint(y, 0.5, a0, b0, 0.1, 0.1, S, B, chains = 2, K_try = 5, seed = 1))
ti <- system.time(fi <- bqtf_tf(y, 0.5, "P", move = "exact", standardize = FALSE, a0 = a0, b0 = b0, a_s = 0.1, b_s = 0.1,
                                chains = 2, fixed_sweeps = S))
lj <- as.vector(fj$lambda[(B+1):S, 1, ]); sj <- as.vector(fj$sigma[(B+1):S, 1, ])
ess <- function(x, nch = 2) { M <- matrix(x, ncol = nch); posterior::ess_bulk(M) }
cat(sprintf("JOINT J=1: lambda mean %.4g (MCse %.3g) median %.4g ; sigma mean %.5g (MCse %.3g)\n", mean(lj), sd(lj)/sqrt(ess(lj)), median(lj), mean(sj), sd(sj)/sqrt(ess(sj))))
cat(sprintf("INDIV    : lambda mean %.4g median %.4g ; sigma mean %.5g\n", mean(fi$lambda), median(fi$lambda), mean(fi$sigma)))
cat(sprintf("ESS(logla) joint %.0f ; indiv %.0f\n", ess(log(lj)), fi$ess_loglam))
dm <- fj$levels[[1]]$mean - fi$mean
cat(sprintf("curve: max|diff| %.4g, RMS diff %.4g; MSE vs truth joint %.5g indiv %.5g; sd(y-truth)=%.3f\n", max(abs(dm)), sqrt(mean(dm^2)),
            mean((fj$levels[[1]]$mean - d$truth)^2), mean((fi$mean - d$truth)^2), sd(y - d$truth)))
cat(sprintf("RMS diff / posterior sd(avg)=: %.3f\n", sqrt(mean(dm^2)) / mean(apply(fi$draws, 2, sd))))
cat(sprintf("rhat loglam joint %.3f; indiv rhat_max %.3f\n", posterior::rhat(matrix(log(lj), ncol = 2)), fi$rhat_max))
cat(sprintf("acc pcn %s collapsed %s r_pcn %s; secs joint %.1f indiv %.1f; crossings %d\n", paste(round(fj$acc_pcn,3)), paste(round(fj$acc_collapsed,3)), paste(round(fj$r_pcn,3)), tj[3], ti[3], sum(fj$crossings)))
saveRDS(list(fj=fj, fi=fi), file.path(SCR, "val_a.rds"))
