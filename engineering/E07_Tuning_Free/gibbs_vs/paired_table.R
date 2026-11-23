# Paired table: exact augmented Gibbs (G) vs Felipe's sampler (P), same posterior, same datasets/seeds. Usage: Rscript paired_table.R <gv dir> <sprint dir> <variants dir> <out dir>
a <- commandArgs(TRUE); GV <- a[1]; SP <- a[2]; VA <- a[3]; OUT <- a[4]
G <- do.call(rbind, lapply(list.files(GV, pattern = "^G_", full.names = TRUE), function(f) readRDS(f)$row))
L <- do.call(rbind, lapply(list.files(SP, pattern = "^L_", full.names = TRUE), function(f) { r <- readRDS(f)$row; r$n <- 500L; r }))
C <- do.call(rbind, lapply(list.files(VA, pattern = "^C_", full.names = TRUE), function(f) readRDS(f)$row)); C <- C[C$chain == 1, ]
P <- rbind(L[, c("n", "bl", "noise", "tau", "seed", "mse", "cover", "mciw", "seconds", "ess_loglam")], C[, c("n", "bl", "noise", "tau", "seed", "mse", "cover", "mciw", "seconds", "ess_loglam")])
m <- merge(G, P, by = c("n", "bl", "noise", "tau", "seed"), suffixes = c("_G", "_P")); m$lr <- log(m$mse_G / m$mse_P)
T <- do.call(rbind, lapply(split(m, m[, c("n", "bl", "noise", "tau")], drop = TRUE), function(d) { se <- if (nrow(d) > 1) sd(d$lr) / sqrt(nrow(d)) else NA
  data.frame(d[1, c("n", "bl", "noise", "tau")], seeds = nrow(d), mse_P = mean(d$mse_P), mse_G = mean(d$mse_G), ratio = exp(mean(d$lr)), ratio_lo = exp(mean(d$lr) - 2 * se), ratio_hi = exp(mean(d$lr) + 2 * se),
             cover_P = mean(d$cover_P), cover_G = mean(d$cover_G), width_P = mean(d$mciw_P), width_G = mean(d$mciw_G), sec_P = mean(d$seconds_P), sec_G = mean(d$seconds_G),
             time_ratio = mean(d$seconds_G) / mean(d$seconds_P), esss_loglam_P = median(d$ess_loglam_P / d$seconds_P), esss_loglam_G = median(d$ess_loglam_G / d$seconds_G),
             converged_G = mean(d$converged), rhat_max_G = max(d$rhat_max)) }))
T <- T[order(T$n, T$bl, T$noise, T$tau), ]; write.csv(T, file.path(OUT, "paired_gibbs_vs_pmala.csv"), row.names = FALSE)
for (nn in sort(unique(T$n))) { x <- T[T$n == nn, ]; cat(sprintf("n = %d: %d cells, MSE ratio G/P median %.3f (S %.3f, VS %.3f), max %.3f, cells < 1: %d; time ratio %.2f; coverage P %.3f G %.3f\n", nn, nrow(x),
  median(x$ratio), median(x$ratio[x$bl == "S"]), median(x$ratio[x$bl == "VS"]), max(x$ratio), sum(x$ratio < 1), mean(x$time_ratio), mean(x$cover_P), mean(x$cover_G))) }
