# head to head table. Args: felipe.rds chain1.rds chain2.rds
.libPaths(c("/home/fb31/R/e02lib", .libPaths()))
a <- commandArgs(TRUE); fe <- readRDS(a[1]); c1 <- readRDS(a[2]); c2 <- readRDS(a[3])
taus <- fe$taus; J <- length(taus); tr <- fe$truths
postF <- (fe$burn + 1):fe$iter; post3 <- (c1$burn + 1):c1$sweeps
ess <- function(M) posterior::ess_bulk(M)
rows <- lapply(seq_len(J), function(j) {
  lf <- log(fe$lambda[postF, j]); l3 <- cbind(log(c1$lambda[post3, j]), log(c2$lambda[post3, j]))
  m3 <- (c1$mean[, j] + c2$mean[, j]) / 2
  data.frame(tau = taus[j],
    MSE_F = mean((fe$est[, j] - tr[, j])^2), MSE_v3 = mean((m3 - tr[, j])^2),
    lamMed_F = median(exp(lf)), lamMed_v3 = median(exp(l3)),
    ESSs_F = ess(matrix(lf, ncol = 1)) / fe$seconds, ESSs_v3 = ess(l3) / (c1$seconds + c2$seconds),
    Rhat_v3 = posterior::rhat(l3), ESS_F = ess(matrix(lf, ncol = 1)), ESS_v3 = ess(l3),
    dlam_F = mean(abs(diff(lf))), dlam_v3 = mean(abs(c(diff(l3[, 1]), diff(l3[, 2])))),
    bnc_med = median(c(c1$bounces[post3, j], c2$bounces[post3, j])), bnc_max = max(c1$bounces[post3, j], c2$bounces[post3, j]))
})
tab <- do.call(rbind, rows); print(tab, digits = 4, row.names = FALSE)
cat(sprintf("crossings: Felipe %d, v3 %d | seconds: Felipe %.0f (%d it, %.3f s/it), v3 %.0f + %.0f (%d sweeps, %.4f s/sweep) | capped %d\n",
  fe$cross, sum(c1$crossings, c2$crossings), fe$seconds, fe$iter, fe$seconds / fe$iter, c1$seconds, c2$seconds, c1$sweeps, c1$seconds / c1$sweeps, c1$capped + c2$capped))
# R-hat of theta at 9 points, level-averaged curve
pr <- sapply(seq_len(J), function(j) sapply(seq_len(dim(c1$pts)[2]), function(i) posterior::rhat(cbind(c1$pts[, i, j], c2$pts[, i, j]))))
cat("max Rhat theta at 9 pts per level:", paste(round(apply(pr, 2, max), 3), collapse = " "), "\n")
avg <- sapply(seq_len(dim(c1$pts)[2]), function(i) posterior::rhat(cbind(rowMeans(c1$pts[, i, ]), rowMeans(c2$pts[, i, ]))))
cat("Rhat level-averaged curve at 9 pts:", paste(round(avg, 3), collapse = " "), "\n")
cat("min ESS/s theta (9 pts) v3 per level:", paste(round(sapply(seq_len(J), function(j) min(sapply(seq_len(dim(c1$pts)[2]), function(i) ess(cbind(c1$pts[, i, j], c2$pts[, i, j]))))) / (c1$seconds + c2$seconds), 3), collapse = " "), "\n")
