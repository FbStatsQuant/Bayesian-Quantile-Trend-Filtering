source("/tmp/claude-71711/-home-fb31-Bayesian-Quantile-Trend-Filtering/5a5aaa0b-5c86-47ef-8fba-2096636ee464/scratchpad/common.R")
taus <- c(0.90, 0.93)
dat <- e_new$simulate_data(1, 200L, taus, "VS", "Normal")
iter <- 260L; burn <- 220L    # warm = 200, so 60 post-warm exact-kernel sweeps
fo <- run(e_old, dat$y, taus, iter, burn, 1001)
fn <- run(e_new, dat$y, taus, iter, burn, 1001, lamjump = FALSE)
cat("identical theta:", identical(fo$theta, fn$theta), " max|diff|:", max(abs(fo$theta - fn$theta)), "\n")
cat("identical lambda/sigma/delta:", identical(fo$lambda, fn$lambda), identical(fo$sigma, fn$sigma), identical(fo$delta, fn$delta), "\n")
cat("old acc_post:", fo$acc_post, " outside:", fo$outside_post, "\n")
# sanity: lamjump = TRUE runs and differs
ft <- run(e_new, dat$y, taus, iter, burn, 1001, lamjump = TRUE)
cat("lamjump TRUE differs:", !identical(ft$theta, fn$theta), " acc_lamjump:", ft$acc_lamjump, " outside:", ft$lj_outside_post, "\n")
