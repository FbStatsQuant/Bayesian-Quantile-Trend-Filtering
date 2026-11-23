# P3 (his lamjump) decision per HQ: (1) beats his sampler at EQUAL wall time (L2x = 2x sweeps) on S, (2) <= 1.05 on every VS cell vs L,
# (3) ESS(log lambda)/s not worse (or the MSE gain survives at equal compute), (4) joint port (checked separately).
args <- commandArgs(TRUE); IN <- args[1]; OUT <- args[2]; dir.create(OUT, showWarnings = FALSE); options(width = 220)
R <- do.call(rbind, lapply(list.files(IN, pattern = "\\.rds$", full.names = TRUE), function(f) { r <- readRDS(f)$row
  r[, c("arm", "bl", "noise", "tau", "seed", "mse", "cover", "mciw", "lam_mean", "ess_loglam", "seconds")] }))
pair <- function(a, b, bl) do.call(rbind, lapply(split(R[R$bl == bl & R$arm %in% c(a, b), ], ~ noise + tau, drop = TRUE), function(d) {
  A <- d[d$arm == a, ]; B <- d[d$arm == b, ]; s <- intersect(A$seed, B$seed); A <- A[match(s, A$seed), ]; B <- B[match(s, B$seed), ]
  lr <- log(A$mse / B$mse); se <- sd(lr) / sqrt(length(lr))
  data.frame(bl = bl, noise = d$noise[1], tau = d$tau[1], cmp = paste(a, "vs", b), seeds = length(s), mse_a = mean(A$mse), mse_b = mean(B$mse),
             ratio = exp(mean(lr)), lo = exp(mean(lr) - 2 * se), hi = exp(mean(lr) + 2 * se), cover_a = mean(A$cover), cover_b = mean(B$cover),
             esss_a = median(A$ess_loglam / A$seconds), esss_b = median(B$ess_loglam / B$seconds), sec_a = mean(A$seconds), sec_b = mean(B$seconds)) }))
X <- rbind(pair("P3", "L2x", "S"), pair("L2x", "L", "S"), pair("P3", "L", "S"), pair("P3", "L", "VS"))
write.csv(X, file.path(OUT, "p3_verdict_cells.csv"), row.names = FALSE)
print(X, digits = 3, row.names = FALSE)
sm <- function(cmp, bl) { x <- X[X$cmp == cmp & X$bl == bl, ]; if (!nrow(x)) return(NULL)
  data.frame(cmp = cmp, bl = bl, cells = nrow(x), median_ratio = median(x$ratio), max_ratio = max(x$ratio), cells_ratio_gt1 = sum(x$ratio > 1),
             esss_ratio_median = median(x$esss_a / x$esss_b), sec_ratio = mean(x$sec_a) / mean(x$sec_b)) }
V <- rbind(sm("P3 vs L2x", "S"), sm("L2x vs L", "S"), sm("P3 vs L", "S"), sm("P3 vs L", "VS")); write.csv(V, file.path(OUT, "p3_verdict_summary.csv"), row.names = FALSE)
cat("\n== summary ==\n"); print(V, digits = 3, row.names = FALSE)
