ROOT <- local({ f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE)); d <- if (length(f)) dirname(normalizePath(f[1])) else getwd(); r <- tryCatch(system2("git", c("-C", shQuote(d), "rev-parse", "--show-toplevel"), stdout = TRUE, stderr = FALSE), error = function(e) character(0)); if (!length(r) || !nzchar(r[1])) stop("E07: cannot find the repo root; run from inside the checkout"); r[1] })   # E-12: repo root (Owls or NOTS), no absolute paths
.libPaths(c(file.path(ROOT, "ops/Rlib"), .libPaths()))
S <- file.path(ROOT, "engineering/E07_Tuning_Free/joint_gibbs/validate/inputs")   # E-12: v2_c1/v2_c2/felipe_full.rds copied from the archived scratchpad 7aecef86 (sha256 in inputs/SHA256SUMS)
taus <- c(0.90, 0.93, 0.96, 0.97, 0.98, 0.99); J <- 6
c1 <- readRDS(file.path(S, "v2_c1.rds")); c2 <- readRDS(file.path(S, "v2_c2.rds")); fe <- readRDS(file.path(S, "felipe_full.rds"))
sw <- c1$sweeps; post2 <- (c1$burn + 1):sw; truth <- c1$truth; cpu2 <- sum(c(c1$seconds, c2$seconds))
mean2 <- (c1$mean + c2$mean) / 2
tab <- data.frame(tau = taus,
  MSE_v2 = colMeans((mean2 - truth)^2), MSE_F = colMeans((fe$est - truth)^2),
  lam_v2 = sapply(1:J, function(j) median(c(c1$lambda[post2, j, 1], c2$lambda[post2, j, 1]))),
  lam_F = sapply(1:J, function(j) median(fe$lambda[(fe$burn + 1):fe$iter, j])),
  Rhat_v2 = sapply(1:J, function(j) posterior::rhat(cbind(log(c1$lambda[post2, j, 1]), log(c2$lambda[post2, j, 1])))),
  ESS_v2 = sapply(1:J, function(j) posterior::ess_bulk(cbind(log(c1$lambda[post2, j, 1]), log(c2$lambda[post2, j, 1])))),
  ESS_F = sapply(1:J, function(j) posterior::ess_bulk(matrix(log(fe$lambda[(fe$burn + 1):fe$iter, j]), ncol = 1))))
tab$ESSps_v2 <- tab$ESS_v2 / cpu2; tab$ESSps_F <- tab$ESS_F / fe$seconds
tab$pCN_v2 <- rowMeans(cbind(c1$acc_pcn[, 1], c2$acc_pcn[, 1])); tab$acc_F <- fe$acc_post
print(tab, digits = 3, row.names = FALSE)
cat(sprintf("CPU s: v2 %.0f (2 chains x %d sweeps, %.4f s/sweep), Felipe %.0f (1 chain x %d iters, %.4f s/iter)\n", cpu2, sw, mean(c(c1$sec_per_sweep, c2$sec_per_sweep)), fe$seconds, fe$iter, fe$seconds / fe$iter))
cat(sprintf("crossings: v2 %d, Felipe %d\n", sum(c1$crossings) + sum(c2$crossings), fe$cross))
cat(sprintf("v2 ASIS moved: %s; Felipe ASIS moved %s, outside-box rej %s\n", paste(round(rowMeans(cbind(c1$asis_moved[,1], c2$asis_moved[,1])), 2), collapse = " "), paste(round(fe$asis_moved_post, 2), collapse = " "), paste(round(fe$outside_post, 2), collapse = " ")))
cat("median ESS/s ratio v2/F:", round(median(tab$ESSps_v2 / tab$ESSps_F), 2), "\n")
