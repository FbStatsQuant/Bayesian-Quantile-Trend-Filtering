a <- commandArgs(TRUE); lj <- as.logical(a[1]); S <- dirname(sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE)))
source(file.path(S, "common.R"))
taus <- c(0.90, 0.93, 0.96, 0.97, 0.98, 0.99)
dat <- e_new$simulate_data(1, 500L, taus, "VS", "Normal")
fit <- run(e_new, dat$y, taus, 3000L, 1000L, 1001, lamjump = lj)
post <- 1001:3000
est <- apply(fit$theta, c(2, 3), mean)
cm <- e_new$crossing_metrics(est, fit$theta)
out <- list(lj = lj, tau = taus, seconds = fit$seconds, sec_per_sweep = fit$seconds / 3000,
  lamjump_acc = fit$acc_lamjump, lj_outside = fit$lj_outside_post, s_lamjump = fit$s_lamjump,
  lambda_mean = colMeans(fit$lambda[post, ]), lambda_median = apply(fit$lambda[post, ], 2, median),
  sigma_mean = colMeans(fit$sigma[post, ]), mse = colMeans((est - dat$truth)^2),
  theta_acc = fit$acc_post, theta_outside = fit$outside_post, asis_moved = fit$asis_moved_post,
  n_cross_all_pairs = sum(cm$all_pairs$n_cross), n_cross_adjacent = sum(cm$adjacent$n_cross), draws_any_cross = sum(cm$all_pairs$draws_any_cross))
saveRDS(out, file.path(S, sprintf("smoke_lj%s.rds", lj))); print(out)
