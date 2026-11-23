# Hyperparameter screen analysis (INTERNAL). Spec posterior vs his-prior posterior (both via exact Gibbs, same datasets) -> isolates the PRIOR effect.
# Usage: Rscript screen_analyze.R <hyper dir> <gibbs_vs dir (G_ baseline)> <out dir>
a <- commandArgs(TRUE); HY <- a[1]; GV <- a[2]; OUT <- a[3]; dir.create(OUT, showWarnings = FALSE, recursive = TRUE); options(width = 220)
H <- do.call(rbind, lapply(list.files(HY, pattern = "\\.rds$", full.names = TRUE), function(f) { r <- readRDS(f)$row; for (v in c("lam_q05", "p_floor")) if (is.null(r[[v]])) r[[v]] <- NA; r }))
B <- do.call(rbind, lapply(list.files(GV, pattern = "^G_", full.names = TRUE), function(f) readRDS(f)$row))
m <- merge(H, B[, c("n", "bl", "noise", "tau", "seed", "mse", "cover", "mciw", "lam_med")], by = c("n", "bl", "noise", "tau", "seed"), suffixes = c("", "_base"))
m$lr <- log(m$mse / m$mse_base)
T <- do.call(rbind, lapply(split(m, m[, c("spec", "n", "bl", "noise", "tau")], drop = TRUE), function(d) { se <- if (nrow(d) > 1) sd(d$lr) / sqrt(nrow(d)) else NA
  data.frame(d[1, c("spec", "n", "bl", "noise", "tau")], seeds = nrow(d), ratio = exp(mean(d$lr)), lo = exp(mean(d$lr) - 2 * se), hi = exp(mean(d$lr) + 2 * se),
             cover = mean(d$cover), cover_base = mean(d$cover_base), lam_med = median(d$lam_med), lam_base = median(d$lam_med_base), p_floor = mean(d$p_floor), conv = mean(d$converged)) }))
T <- T[order(T$spec, T$n, T$bl, T$noise, T$tau), ]; write.csv(T, file.path(OUT, "screen_cells.csv"), row.names = FALSE)
V <- do.call(rbind, lapply(split(T, T[, c("spec", "n")], drop = TRUE), function(x) data.frame(spec = x$spec[1], n = x$n[1], cells = nrow(x), median_ratio = median(x$ratio), max_ratio = max(x$ratio),
  cells_gt_1.25 = sum(x$ratio > 1.25), S_median = median(x$ratio[x$bl == "S"]), VS_median = median(x$ratio[x$bl == "VS"]), cover = mean(x$cover), cover_base = mean(x$cover_base),
  lam_ratio_geo = exp(mean(log(x$lam_med / x$lam_base))), p_floor_max = max(x$p_floor, na.rm = TRUE), conv = mean(x$conv))))
V$verdict_n <- ifelse(V$median_ratio <= 1.10 & V$max_ratio <= 1.25, "passes bar", "fails bar")
write.csv(V, file.path(OUT, "screen_summary.csv"), row.names = FALSE)
cat("== Spec posterior vs his-prior posterior (exact Gibbs both): MSE ratio per n ==\n"); print(V[order(V$spec, V$n), ], digits = 3, row.names = FALSE)
