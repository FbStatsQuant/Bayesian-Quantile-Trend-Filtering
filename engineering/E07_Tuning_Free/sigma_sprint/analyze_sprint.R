# sigma sprint analysis: tables and ggplot2 figures.  Usage: Rscript analyze_sprint.R <dir with the 180 fit .rds> <output dir>
.libPaths(c("/home/fb31/Bayesian-Quantile-Trend-Filtering/ops/Rlib", .libPaths()))
suppressPackageStartupMessages({ library(ggplot2); library(scales) })
args <- commandArgs(TRUE); IN <- args[1]; OUT <- args[2]; dir.create(OUT, showWarnings = FALSE, recursive = TRUE)
fs <- list.files(IN, pattern = "\\.rds$", full.names = TRUE); obj <- setNames(lapply(fs, readRDS), basename(fs))
R <- do.call(rbind, lapply(obj, `[[`, "row")); rownames(R) <- NULL
R$tv3 <- sapply(obj, function(o) sum(abs(diff(o$mean, differences = 3L))))       # ||D^3 theta_hat||_1 of the posterior mean
R$noise_lab <- c(Normal = "Gaussian", Beta = "Beta", Mixed = "Mixed normal")[R$noise]
cat(sprintf("%d fits (%d L, %d F)\n", nrow(R), sum(R$arm == "L"), sum(R$arm == "F")))
se <- function(x) sd(x) / sqrt(length(x))
cells <- unique(R[, c("bl", "noise", "noise_lab", "tau")]); cells <- cells[order(cells$bl, match(cells$noise, c("Normal", "Beta", "Mixed")), cells$tau), ]
T <- do.call(rbind, lapply(seq_len(nrow(cells)), function(j) {
  c0 <- cells[j, ]; L <- R[R$bl == c0$bl & R$noise == c0$noise & R$tau == c0$tau & R$arm == "L", ]; F <- R[R$bl == c0$bl & R$noise == c0$noise & R$tau == c0$tau & R$arm == "F", ]
  L <- L[order(L$seed), ]; F <- F[order(F$seed), ]; stopifnot(identical(L$seed, F$seed))
  lr <- log(F$mse / L$mse)
  data.frame(signal = c0$bl, noise = c0$noise_lab, tau = c0$tau, seeds = nrow(L), sigma_bar = L$sigma_bar[1],
             mse_L = mean(L$mse), mse_L_se = se(L$mse), mse_F = mean(F$mse), mse_F_se = se(F$mse),
             ratio_F_L = mean(F$mse) / mean(L$mse), ratio_geo = exp(mean(lr)), ratio_geo_lo = exp(mean(lr) - 2 * se(lr)), ratio_geo_hi = exp(mean(lr) + 2 * se(lr)),
             cover_L = mean(L$cover), cover_L_se = se(L$cover), cover_F = mean(F$cover), cover_F_se = se(F$cover),
             width_L = mean(L$mciw), width_L_se = se(L$mciw), width_F = mean(F$mciw), width_F_se = se(F$mciw),
             lam_L = mean(L$lam_mean), lam_F = mean(F$lam_mean), sig_L = mean(L$sig_mean), sig_L_se = se(L$sig_mean), sig_F = F$sig_mean[1],
             lamsig_L = mean(L$lamsig_mean), lamsig_F = mean(F$lamsig_mean), sigL_over_sbar = mean(L$sig_mean) / L$sigma_bar[1],
             ess_loglam_L = median(L$ess_loglam), ess_loglam_F = median(F$ess_loglam), sec_L = mean(L$seconds), sec_F = mean(F$seconds),
             tv3_L = mean(L$tv3), tv3_F = mean(F$tv3))
}))
T$crit <- ifelse(T$ratio_geo > 1.25, "FAIL (>1.25)", ifelse(T$ratio_geo > 1.10, "over 1.10", "ok"))
write.csv(T, file.path(OUT, "sigma_sprint_table.csv"), row.names = FALSE)
cat(sprintf("\nCRITERION (Felipe/HQ): median paired MSE ratio F/L = %.3f (bar <= 1.10); cells > 1.25: %d of %d; max %.2f\n",
            median(T$ratio_geo), sum(T$ratio_geo > 1.25), nrow(T), max(T$ratio_geo)))
f3 <- function(m, s) sprintf("%.4f ± %.4f", m, s); f2 <- function(m, s) sprintf("%.3f ± %.3f", m, s)
md <- c("| Signal | Noise | τ | MSE L | MSE F | MSE F/L (paired, ±2SE) | Cover L | Cover F | Width L | Width F | λ̄ L | λ̄ F | σ̄ L (÷σ̄) | σ F | λσ L | λσ F | ‖D³θ̂‖₁ L | ‖D³θ̂‖₁ F |",
        "|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|")
for (j in seq_len(nrow(T))) { x <- T[j, ]
  md <- c(md, sprintf("| %s | %s | %.2f | %s | %s | %.2f [%.2f, %.2f] | %s | %s | %s | %s | %.3g | %.3g | %.4f (%.2f) | %.4f | %.3g | %.3g | %.3g | %.3g |", x$signal, x$noise, x$tau,
    f3(x$mse_L, x$mse_L_se), f3(x$mse_F, x$mse_F_se), x$ratio_geo, x$ratio_geo_lo, x$ratio_geo_hi, f2(x$cover_L, x$cover_L_se), f2(x$cover_F, x$cover_F_se),
    f2(x$width_L, x$width_L_se), f2(x$width_F, x$width_F_se), x$lam_L, x$lam_F, x$sig_L, x$sigL_over_sbar, x$sig_F, x$lamsig_L, x$lamsig_F, x$tv3_L, x$tv3_F)) }
writeLines(md, file.path(OUT, "sigma_sprint_table.md"))

# ---- per-cell figures (seed 1): data, truth, L and F posterior means with 95% bands, MSE in subtitle ----------------------
COL <- c(`Learned σ (paper)` = "#0072B2", `Fixed σ = 1.1σ̄` = "#D55E00")
cell_fig <- function(bl, noise, tau, seed = 1) {
  key <- function(arm) sprintf("%s_%s_%s_t%03d_s%d.rds", arm, bl, noise, round(100 * tau), seed)
  L <- obj[[key("L")]]; F <- obj[[key("F")]]; if (is.null(L) || is.null(F)) return(invisible(NULL))
  n <- length(L$y); u <- seq_len(n) / n
  fit <- rbind(data.frame(u = u, est = L$mean, lo = L$lo, hi = L$hi, arm = names(COL)[1]), data.frame(u = u, est = F$mean, lo = F$lo, hi = F$hi, arm = names(COL)[2]))
  fit$arm <- factor(fit$arm, levels = names(COL))
  nl <- c(Normal = "Gaussian", Beta = "Beta", Mixed = "Mixed normal")[[noise]]
  sub <- sprintf("MSE (posterior mean): learned σ %.4f  ·  fixed σ %.4f  ·  ratio %.2f      seed %d, n = %d", L$row$mse, F$row$mse, F$row$mse / L$row$mse, seed, n)
  g <- ggplot() +
    geom_point(data = data.frame(u = u, y = L$y), aes(u, y), colour = "grey70", size = 0.5, alpha = 0.6) +
    geom_ribbon(data = fit, aes(u, ymin = lo, ymax = hi, fill = arm), alpha = 0.18) +
    geom_line(data = fit, aes(u, est, colour = arm), linewidth = 0.7) +
    geom_line(data = data.frame(u = u, q = L$truth), aes(u, q, linetype = "True quantile"), colour = "black", linewidth = 0.6) +
    scale_colour_manual(values = COL, name = NULL) + scale_fill_manual(values = COL, name = NULL) +
    scale_linetype_manual(values = c(`True quantile` = "22"), name = NULL) +
    labs(title = sprintf("%s · %s · τ = %s", bl, nl, format(tau)), subtitle = sub, x = "u", y = "y") +
    theme_minimal(base_size = 11) + theme(legend.position = "bottom", plot.title = element_text(face = "bold"), plot.subtitle = element_text(size = 8.5, colour = "grey25"))
  fn <- file.path(OUT, sprintf("cell_%s_%s_t%03d.png", bl, noise, round(100 * tau)))
  ggsave(fn, g, width = 7, height = 4.6, dpi = 300, device = "png", type = "cairo"); fn
}
for (cc in list(c("VS", "Normal"), c("S", "Beta"), c("VS", "Mixed"))) for (tau in c(0.05, 0.5, 0.95)) cell_fig(cc[1], cc[2], tau)

# ---- overview: paired MSE ratio F/L and coverage of both arms, all cells --------------------------------------------------
T$cell <- sprintf("%s · %s · τ = %.2f", T$signal, T$noise, T$tau); T$cell <- factor(T$cell, levels = rev(T$cell))
A <- rbind(data.frame(cell = T$cell, panel = "MSE ratio, fixed ÷ learned (paired, ±2 SE)", arm = "Fixed ÷ learned", v = T$ratio_geo, lo = T$ratio_geo_lo, hi = T$ratio_geo_hi),
           data.frame(cell = T$cell, panel = "95% band coverage (±2 SE)", arm = names(COL)[1], v = T$cover_L, lo = T$cover_L - 2 * T$cover_L_se, hi = pmin(1, T$cover_L + 2 * T$cover_L_se)),
           data.frame(cell = T$cell, panel = "95% band coverage (±2 SE)", arm = names(COL)[2], v = T$cover_F, lo = T$cover_F - 2 * T$cover_F_se, hi = pmin(1, T$cover_F + 2 * T$cover_F_se)))
REF <- data.frame(panel = c("MSE ratio, fixed ÷ learned (paired, ±2 SE)", "95% band coverage (±2 SE)"), x = c(1, 0.95))
g <- ggplot(A, aes(v, cell, colour = arm)) + geom_vline(data = REF, aes(xintercept = x), linetype = "22", colour = "grey40") +
  geom_errorbarh(aes(xmin = lo, xmax = hi), height = 0, position = position_dodge(width = 0.55), alpha = 0.8) +
  geom_point(position = position_dodge(width = 0.55), size = 1.8) + facet_wrap(~panel, scales = "free_x") +
  scale_colour_manual(values = c(COL, `Fixed ÷ learned` = "#009E73"), name = NULL) +
  labs(title = "Fixed σ = 1.1σ̄ vs learned σ, Felipe's original sampler (paper settings)", subtitle = "n = 500, 5 paired seeds per cell", x = NULL, y = NULL) +
  theme_minimal(base_size = 10) + theme(legend.position = "bottom", plot.title = element_text(face = "bold"), strip.text = element_text(face = "bold"))
ggsave(file.path(OUT, "overview_ratio_coverage.png"), g, width = 9, height = 7, dpi = 300, device = "png", type = "cairo")
print(T[, c("signal", "noise", "tau", "mse_L", "mse_F", "ratio_geo", "ratio_geo_lo", "ratio_geo_hi", "cover_L", "cover_F", "width_L", "width_F", "lam_L", "lam_F", "sig_L", "sigL_over_sbar", "sig_F", "lamsig_L", "lamsig_F", "tv3_L", "tv3_F", "ess_loglam_L", "ess_loglam_F", "crit")], digits = 3, row.names = FALSE)
