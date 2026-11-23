# Fit plots (INTERNAL until a win is confirmed): truth vs Felipe's P-MALA vs exact augmented Gibbs, same data, posterior means + 95% bands.
# Usage: Rscript plots.R <gibbs_vs dir> <sigma_sprint dir> <variants dir> <out dir>
.libPaths(c("/home/fb31/R/e02lib", .libPaths())); suppressPackageStartupMessages(library(ggplot2))
a <- commandArgs(TRUE); GV <- a[1]; SP <- a[2]; VA <- a[3]; OUT <- a[4]; dir.create(OUT, showWarnings = FALSE, recursive = TRUE)
COL <- c(`Felipe's sampler (P-MALA)` = "#0072B2", `Exact augmented Gibbs` = "#D55E00")
NL <- c(Normal = "Gaussian", Beta = "Beta", Mixed = "Mixed normal")
fig <- function(G, P, n, bl, noise, tau, seed, tP, tG) {
  u <- seq_len(n) / n
  fit <- rbind(data.frame(u = u, est = P$mean, lo = P$lo, hi = P$hi, arm = names(COL)[1]), data.frame(u = u, est = G$mean, lo = G$lo, hi = G$hi, arm = names(COL)[2]))
  fit$arm <- factor(fit$arm, levels = names(COL))
  mP <- mean((P$mean - G$truth)^2); mG <- mean((G$mean - G$truth)^2)
  sub <- sprintf("MSE: P-MALA %.4g (%.0f s)  ·  Gibbs %.4g (%.0f s)  ·  ratio %.2f      n = %d, seed %d", mP, tP, mG, tG, mG / mP, n, seed)
  g <- ggplot() + geom_point(data = data.frame(u = u, y = G$y), aes(u, y), colour = "grey72", size = if (n > 1000) 0.25 else 0.5, alpha = 0.5) +
    geom_ribbon(data = fit, aes(u, ymin = lo, ymax = hi, fill = arm), alpha = 0.18) + geom_line(data = fit, aes(u, est, colour = arm), linewidth = 0.6) +
    geom_line(data = data.frame(u = u, q = G$truth), aes(u, q, linetype = "True quantile"), colour = "black", linewidth = 0.55) +
    scale_colour_manual(values = COL, name = NULL) + scale_fill_manual(values = COL, name = NULL) + scale_linetype_manual(values = c(`True quantile` = "22"), name = NULL) +
    labs(title = sprintf("%s · %s · τ = %s", bl, NL[[noise]], format(tau)), subtitle = sub, x = "u", y = "y") +
    theme_minimal(base_size = 11) + theme(legend.position = "bottom", plot.title = element_text(face = "bold"), plot.subtitle = element_text(size = 8.5, colour = "grey25"))
  ggsave(file.path(OUT, sprintf("fit_n%05d_%s_%s_t%03d_s%d.png", n, bl, noise, round(100 * tau), seed)), g, width = 7, height = 4.6, dpi = 300, device = "png", type = "cairo")
}
for (cc in list(c("S", "Normal", 0.5), c("S", "Mixed", 0.05), c("S", "Beta", 0.95), c("VS", "Normal", 0.5), c("VS", "Mixed", 0.95), c("VS", "Beta", 0.05))) {
  bl <- cc[1]; noise <- cc[2]; tau <- as.numeric(cc[3])
  G <- readRDS(file.path(GV, sprintf("G_n00500_%s_%s_t%03d_s1.rds", bl, noise, round(100 * tau)))); P <- readRDS(file.path(SP, sprintf("L_%s_%s_t%03d_s1.rds", bl, noise, round(100 * tau))))
  fig(G, P, 500, bl, noise, tau, 1, P$row$seconds, G$row$seconds) }
for (cc in list(c("S", 2000, 0.5), c("VS", 2000, 0.5), c("S", 1000, 0.05), c("VS", 1000, 0.95))) {
  bl <- cc[1]; n <- as.integer(cc[2]); tau <- as.numeric(cc[3])
  G <- readRDS(file.path(GV, sprintf("G_n%05d_%s_Normal_t%03d_s1.rds", n, bl, round(100 * tau)))); P <- readRDS(file.path(VA, sprintf("C_n%05d_%s_Normal_t%03d_s1_c1.rds", n, bl, round(100 * tau))))
  fig(G, P, n, bl, "Normal", tau, 1, P$row$seconds, G$row$seconds) }
