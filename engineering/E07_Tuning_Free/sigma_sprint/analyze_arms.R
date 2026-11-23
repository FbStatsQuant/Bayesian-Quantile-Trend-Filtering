# sigma sprint, arm set 2: every fixed-sigma arm against L (learned sigma, Felipe's original), paired on common seeds.
# Rule 1 (Felipe, permanent): an arm is REJECTED (data) if its median paired MSE ratio over cells > 1.10 or any cell > 1.25.
# Usage: Rscript analyze_arms.R <dir with all fit .rds> <output dir>
.libPaths(c("/home/fb31/R/e02lib", .libPaths())); suppressPackageStartupMessages({ library(ggplot2) })
args <- commandArgs(TRUE); IN <- args[1]; OUT <- args[2]; dir.create(OUT, showWarnings = FALSE, recursive = TRUE)
fs <- list.files(IN, pattern = "\\.rds$", full.names = TRUE); obj <- lapply(fs, readRDS)
R <- do.call(rbind, lapply(obj, function(o) { r <- o$row; r$tv3 <- sum(abs(diff(o$mean, differences = 3L)))
  for (v in c("a0", "b0", "lam_c")) if (is.null(r[[v]])) r[[v]] <- NA; r[, c("arm", "bl", "noise", "tau", "seed", "sigma_bar", "a0", "b0", "lam_c",
  "lam_mean", "sig_mean", "lamsig_mean", "mse", "mciw", "cover", "ess_loglam", "seconds", "tv3")] }))
ARMS <- intersect(c("F", "EB1", "EB025", "TH"), unique(R$arm))
NL <- c(Normal = "Gaussian", Beta = "Beta", Mixed = "Mixed normal")
cells <- unique(R[, c("bl", "noise", "tau")]); cells <- cells[order(cells$bl, match(cells$noise, names(NL)), cells$tau), ]
se <- function(x) if (length(x) > 1) sd(x) / sqrt(length(x)) else NA
T <- do.call(rbind, lapply(seq_len(nrow(cells)), function(j) { c0 <- cells[j, ]
  do.call(rbind, lapply(ARMS, function(a) {
    X <- R[R$bl == c0$bl & R$noise == c0$noise & R$tau == c0$tau & R$arm == a, ]
    L <- R[R$bl == c0$bl & R$noise == c0$noise & R$tau == c0$tau & R$arm == "L" & R$seed %in% X$seed, ]
    X <- X[order(X$seed), ]; L <- L[order(L$seed), ]; lr <- log(X$mse / L$mse)
    data.frame(signal = c0$bl, noise = NL[[c0$noise]], tau = c0$tau, arm = a, seeds = nrow(X),
               mse_L = mean(L$mse), mse_X = mean(X$mse), ratio = exp(mean(lr)), ratio_lo = exp(mean(lr) - 2 * se(lr)), ratio_hi = exp(mean(lr) + 2 * se(lr)),
               cover_L = mean(L$cover), cover_X = mean(X$cover), width_L = mean(L$mciw), width_X = mean(X$mciw),
               lam_L = mean(L$lam_mean), lam_X = mean(X$lam_mean), lamsig_L = mean(L$lamsig_mean), lamsig_X = mean(X$lamsig_mean),
               tv3_L = mean(L$tv3), tv3_X = mean(X$tv3), lam_c = mean(X$lam_c), pull = mean(X$lam_mean / X$lam_c),
               lamc_TH_over_EB = NA_real_, ess_loglam_X = median(X$ess_loglam))
  })) }))
# F-TH centre against the EB centre (same dataset): how far the theory-shaped centre sits from Lambda_hat / sigma_F
if (all(c("TH", "EB1") %in% ARMS)) { k <- T$arm == "TH"
  T$lamc_TH_over_EB[k] <- T$lam_c[k] / T$lam_c[T$arm == "EB1"][match(paste(T$signal, T$noise, T$tau)[k], paste(T$signal, T$noise, T$tau)[T$arm == "EB1"])] }
T$cell_flag <- ifelse(T$ratio > 1.25, "FAIL >1.25", ifelse(T$ratio > 1.10, ">1.10", "ok"))
write.csv(T, file.path(OUT, "arms_table.csv"), row.names = FALSE)
V <- do.call(rbind, lapply(ARMS, function(a) { x <- T[T$arm == a, ]
  data.frame(arm = a, seeds = max(x$seeds), median_ratio = median(x$ratio), max_ratio = max(x$ratio), cells_over_1.25 = sum(x$ratio > 1.25),
             cells_over_1.10 = sum(x$ratio > 1.10), mean_cover = mean(x$cover_X), min_cover = min(x$cover_X), mean_cover_L = mean(x$cover_L),
             verdict = if (median(x$ratio) <= 1.10 && max(x$ratio) <= 1.25) "passes rule 1" else
               sprintf("rejected (data): median %.2f, %d cells > 1.25 (max %.2f)", median(x$ratio), sum(x$ratio > 1.25), max(x$ratio))) }))
write.csv(V, file.path(OUT, "arms_verdict.csv"), row.names = FALSE); options(width = 250)
cat("== Rule-1 verdict per arm (paired vs L on common seeds) ==\n"); print(V, row.names = FALSE, digits = 3)
cat("\n== Per cell ==\n"); print(T[, c("signal", "noise", "tau", "arm", "seeds", "mse_L", "mse_X", "ratio", "ratio_lo", "ratio_hi", "cover_L", "cover_X", "width_L", "width_X",
                                     "lam_L", "lam_X", "lamsig_L", "lamsig_X", "tv3_L", "tv3_X", "lam_c", "pull", "lamc_TH_over_EB", "cell_flag")], digits = 3, row.names = FALSE)
T$cell <- factor(sprintf("%s · %s · τ = %.2f", T$signal, T$noise, T$tau), levels = rev(unique(sprintf("%s · %s · τ = %.2f", T$signal, T$noise, T$tau))))
PAL <- c(F = "#D55E00", EB1 = "#009E73", EB025 = "#CC79A7", TH = "#E69F00")
LAB <- c(F = "F: σ = 1.1σ̄, paper λ prior", EB1 = "F-EB κ=1", EB025 = "F-EB κ=0.25", TH = "F-TH (n^{5/2}/V̂)")
g <- ggplot(T, aes(ratio, cell, colour = arm)) + annotate("rect", xmin = 0, xmax = 1.10, ymin = -Inf, ymax = Inf, fill = "grey92") +
  geom_vline(xintercept = c(1, 1.25), linetype = c("solid", "22"), colour = c("grey40", "firebrick")) +
  geom_errorbarh(aes(xmin = ratio_lo, xmax = ratio_hi), height = 0, position = position_dodge(width = 0.7), alpha = 0.7) +
  geom_point(position = position_dodge(width = 0.7), size = 1.8) + scale_x_log10() +
  scale_colour_manual(values = PAL[ARMS], labels = LAB[ARMS], name = NULL) +
  labs(title = "MSE ratio to learned σ (Felipe's original), fixed-σ arms", subtitle = "Paired geometric mean ±2 SE; shaded ≤ 1.10, red dashed = 1.25 (Felipe's bar)", x = "MSE ratio (log scale)", y = NULL) +
  theme_minimal(base_size = 10) + theme(legend.position = "bottom", plot.title = element_text(face = "bold"))
ggsave(file.path(OUT, "arms_mse_ratio.png"), g, width = 8.5, height = 7.5, dpi = 300, device = "png", type = "cairo")
