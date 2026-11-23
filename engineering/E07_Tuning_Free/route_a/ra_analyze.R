# Route A analysis for Theory. Usage: Rscript ra_analyze.R <route_a dir (A1/, A2/)> <sigma_sprint dir (L fits)> <out dir>
args <- commandArgs(TRUE); IN <- args[1]; SPR <- args[2]; OUT <- args[3]; dir.create(OUT, showWarnings = FALSE, recursive = TRUE); options(width = 230)
rd <- function(d) { f <- list.files(d, pattern = "\\.rds$", full.names = TRUE); if (!length(f)) return(NULL); do.call(rbind, lapply(f, function(x) readRDS(x)$row)) }
A1 <- rd(file.path(IN, "A1")); names(A1) <- sub("\\.(rhat|ess|ess_tail)$", "", names(A1))
A2 <- rd(file.path(IN, "A2"))
key <- c("bl", "noise", "tau", "n")
med <- function(v) tapply(A1[[v]], interaction(A1[, key], drop = TRUE), median)
S <- aggregate(A1[, c("sig_s0_q05", "sig_s0_q50", "sig_s0_q95", "sig_sbar_q05", "sig_sbar_q50", "sig_sbar_q95", "lam_q05", "lam_q50", "lam_q95",
                      "lamsig_q05", "lamsig_q50", "lamsig_q95", "q95_rough", "q95_full", "mse_pm", "ess_loglam", "ess_logsig", "rhat_loglam", "rhat_logsig", "seconds")],
               A1[, key], median)
S$ess_loglam_min <- aggregate(A1$ess_loglam, A1[, key], min)$x; S$rhat_max <- aggregate(pmax(A1$rhat_loglam, A1$rhat_logsig), A1[, key], max)$x
S$conv_frac <- aggregate(A1$converged, A1[, key], mean)$x
S <- S[order(S$bl, S$noise, S$tau, S$n), ]
write.csv(S, file.path(OUT, "ra1_cells.csv"), row.names = FALSE)
cat("== R-A1: posterior of sigma and lambda by n (medians over seeds) ==\n")
print(S[, c(key, "sig_s0_q05", "sig_s0_q50", "sig_s0_q95", "sig_sbar_q50", "lam_q50", "lamsig_q50", "q95_rough", "q95_full", "mse_pm", "ess_loglam_min", "rhat_max", "conv_frac")], digits = 3, row.names = FALSE)
# width of the sigma posterior (q95/q05 - 1) vs n, and slopes in n (n >= 500; seed-median, log-log)
sl <- function(x, y) unname(coef(lm(log(y) ~ log(x)))[2])
G <- do.call(rbind, lapply(split(S, S[, c("bl", "noise", "tau")], drop = TRUE), function(d) { d <- d[d$n >= 500 & d$n <= 4000, ]
  data.frame(d[1, c("bl", "noise", "tau")], sig_s0_med_range = paste(sprintf("%.3f", range(d$sig_s0_q50)), collapse = "-"),
             sig_width_slope = sl(d$n, d$sig_s0_q95 / d$sig_s0_q05 - 1), lam_slope = sl(d$n, d$lam_q50), lamsig_slope = sl(d$n, d$lamsig_q50),
             rough_slope = sl(d$n, d$q95_rough), full_slope = sl(d$n, d$q95_full), mse_slope = sl(d$n, d$mse_pm)) }))
write.csv(G, file.path(OUT, "ra1_slopes.csv"), row.names = FALSE)
cat("\n== slopes in n (n = 500..4000): sigma-posterior relative width, lambda (heuristic 3/4), lambda*sigma, radii, MSE ==\n"); print(G, digits = 3, row.names = FALSE)
# HQ cross-check: exact-Gibbs sigma/sigma_bar vs Felipe's sampler (sprint L) on the same n = 500 datasets
L <- do.call(rbind, lapply(list.files(SPR, pattern = "^L_.*\\.rds$", full.names = TRUE), function(x) readRDS(x)$row))
if (!is.null(L) && nrow(L)) {
  a <- A1[A1$n == 500, ]; m <- merge(a[, c("bl", "noise", "tau", "seed", "sig_sbar_q50", "sigma_bar", "lam_q50")], L[, c("bl", "noise", "tau", "seed", "sig_mean", "sigma_bar", "lam_mean")], by = c("bl", "noise", "tau", "seed"), suffixes = c("_gibbs", "_pmala"))
  m$ratio_sig <- (m$sig_sbar_q50 * m$sigma_bar_gibbs) / m$sig_mean; m$ratio_lam <- m$lam_q50 / m$lam_mean
  C <- aggregate(cbind(ratio_sig, ratio_lam) ~ bl + noise + tau, m, function(x) round(median(x), 3)); write.csv(C, file.path(OUT, "crosscheck_sigma_gibbs_vs_pmala.csv"), row.names = FALSE)
  cat(sprintf("\n== CROSS-CHECK n = 500 (%d paired datasets): sigma Gibbs/P-MALA median %.3f (range %.3f-%.3f); sigma_bar definitions agree to %.1e; lambda Gibbs/P-MALA median %.2f (range %.2f-%.2f) ==\n",
              nrow(m), median(m$ratio_sig), min(m$ratio_sig), max(m$ratio_sig), max(abs(m$sigma_bar_gibbs / m$sigma_bar_pmala - 1)), median(m$ratio_lam), min(m$ratio_lam), max(m$ratio_lam)))
  print(C, row.names = FALSE)
}
if (!is.null(A2)) {
  B <- merge(aggregate(A2[, c("q95_rough", "mse_pm")], A2[, key], median), aggregate(A1[, c("q95_rough", "mse_pm")], A1[, key], median), by = key, suffixes = c("_A2fixed", "_A1full"))
  B$rough_ratio <- B$q95_rough_A2fixed / B$q95_rough_A1full; B$mse_ratio <- B$mse_pm_A2fixed / B$mse_pm_A1full
  write.csv(B, file.path(OUT, "ra2_fixed_vs_full.csv"), row.names = FALSE)
  cat("\n== R-A2: sigma and lambda fixed at the A1 posterior medians vs the full method (ratios A2/A1) ==\n"); print(B, digits = 3, row.names = FALSE)
}
