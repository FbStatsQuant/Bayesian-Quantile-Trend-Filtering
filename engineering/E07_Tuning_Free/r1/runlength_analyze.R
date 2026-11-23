# Run-length study (HQ): Felipe's sampler, paper settings, run 1x (sprint L), 2x (L2x) and 4x (L4x) the paper's sweeps, same data/seeds.
# Per cell: paired MSE ratios, ESS(log lambda), and his as-run lambda-bar against the exact-Gibbs posterior median of lambda (R-A1, n = 500).
# Usage: Rscript runlength_analyze.R <dir with L (sprint), L2x, L4x fits> <route_a A1 dir> <out dir>
args <- commandArgs(TRUE); IN <- args[1]; A1D <- args[2]; OUT <- args[3]; dir.create(OUT, showWarnings = FALSE, recursive = TRUE); options(width = 220)
R <- do.call(rbind, lapply(list.files(IN, pattern = "^(L|L2x|L4x)_.*\\.rds$", full.names = TRUE), function(f) readRDS(f)$row[, c("arm", "bl", "noise", "tau", "seed", "mse", "cover", "lam_mean", "ess_loglam", "seconds")]))
A1 <- do.call(rbind, lapply(list.files(A1D, pattern = "_n00500_", full.names = TRUE), function(f) readRDS(f)$row[, c("bl", "noise", "tau", "seed", "lam_q50", "lam_q05", "lam_q95")]))
cells <- unique(R[R$arm != "L", c("bl", "noise", "tau")])
X <- do.call(rbind, lapply(seq_len(nrow(cells)), function(j) { c0 <- cells[j, ]
  get <- function(a) { d <- R[R$arm == a & R$bl == c0$bl & R$noise == c0$noise & R$tau == c0$tau, ]; d[order(d$seed), ] }
  L1 <- get("L"); L2 <- get("L2x"); L4 <- get("L4x"); G <- A1[A1$bl == c0$bl & A1$noise == c0$noise & A1$tau == c0$tau, ]; G <- G[order(G$seed), ]
  pr <- function(A, B) { s <- intersect(A$seed, B$seed); if (!length(s)) return(c(NA, NA, NA)); lr <- log(A$mse[match(s, A$seed)] / B$mse[match(s, B$seed)]); se <- sd(lr) / sqrt(length(lr))
    c(exp(mean(lr)), exp(mean(lr) - 2 * se), exp(mean(lr) + 2 * se)) }
  lamrel <- function(A) { s <- intersect(A$seed, G$seed); if (!length(s)) return(NA); exp(mean(log(A$lam_mean[match(s, A$seed)] / G$lam_q50[match(s, G$seed)]))) }
  r21 <- pr(L2, L1); r41 <- pr(L4, L1); r42 <- pr(L4, L2)
  data.frame(c0, seeds = nrow(L1), mse_1x = mean(L1$mse), mse_2x = if (nrow(L2)) mean(L2$mse) else NA, mse_4x = if (nrow(L4)) mean(L4$mse) else NA,
             r2_1 = r21[1], r2_1_lo = r21[2], r2_1_hi = r21[3], r4_1 = r41[1], r4_1_lo = r41[2], r4_1_hi = r41[3], r4_2 = r42[1], r4_2_lo = r42[2], r4_2_hi = r42[3],
             ess_1x = median(L1$ess_loglam), ess_2x = if (nrow(L2)) median(L2$ess_loglam) else NA, ess_4x = if (nrow(L4)) median(L4$ess_loglam) else NA,
             lam_vs_post_1x = lamrel(L1), lam_vs_post_2x = if (nrow(L2)) lamrel(L2) else NA, lam_vs_post_4x = if (nrow(L4)) lamrel(L4) else NA,
             cover_1x = mean(L1$cover), cover_4x = if (nrow(L4)) mean(L4$cover) else NA)
}))
X <- X[order(X$bl, X$noise, X$tau), ]; write.csv(X, file.path(OUT, "runlength_cells.csv"), row.names = FALSE)
print(X, digits = 3, row.names = FALSE)
for (b in unique(X$bl)) { x <- X[X$bl == b, ]
  cat(sprintf("\n%s: median MSE ratio 2x/1x %.3f (cells <1: %d/%d); 4x/1x %s; 4x/2x %s; as-run lambda / posterior lambda (geo mean over cells): 1x %.2f, 2x %s, 4x %s\n", b,
              median(x$r2_1, na.rm = TRUE), sum(x$r2_1 < 1, na.rm = TRUE), sum(!is.na(x$r2_1)), format(round(median(x$r4_1), 3)), format(round(median(x$r4_2), 3)),
              exp(mean(log(x$lam_vs_post_1x))), format(round(exp(mean(log(x$lam_vs_post_2x))), 2)), format(round(exp(mean(log(x$lam_vs_post_4x))), 2)))) }
