# Bayesian-PMALA figure for the SPod application (Section 4.4.1).
#
# Reads the E-18 Stage 2' Writing export and draws the two panels in the
# style of the ADMM benchmark figure (spod_detrended_admm.png,
# spod_quantiles_admm.png):
#   spod_detrended_pmala.png  detrended series, one facet per level, with the
#                             90th/95th/99th percentiles of the detrended data
#   spod_quantiles_pmala.png  the three fitted baselines on the observed series
#
# The curves are pointwise posterior medians of two pooled chains, fitted
# separately at each level. They cross at some time points, so they are drawn
# as lines and nothing is shaded between them.
#
# Run from the repository root:
#   ~/.config/bvs-hq/owls/owls_run -j 1 -- Rscript --vanilla \
#     paper/figures/make_spod_pmala_figure.R

suppressPackageStartupMessages(library(ggplot2))

curves_csv <- "engineering/E18_Air_Refit/results_a0_n/spod_curves.csv"
out_dir <- "paper/figures"
stopifnot(file.exists(curves_csv), dir.exists(out_dir))

d <- read.csv(curves_csv, stringsAsFactors = FALSE)
stopifnot(nrow(d) == 8640L, all(c("time", "y", "q01", "q05", "q10") %in% names(d)))
d$t <- as.POSIXct(paste("2018-06-15", d$time), tz = "UTC")
stopifnot(!anyNA(d$t), !is.unsorted(d$t))

levels_tau <- c(q01 = "tau = 0.01", q05 = "tau = 0.05", q10 = "tau = 0.10")
day0 <- as.POSIXct("2018-06-15 00:00:00", tz = "UTC")
x_scale <- scale_x_datetime(date_labels = "%b %d %H:%M", timezone = "UTC",
                            breaks = day0 + 3600 * seq(0, 24, by = 6))

# Detrended series and thresholds (type-7 percentiles of the detrended data).
long <- do.call(rbind, lapply(names(levels_tau), function(k)
  data.frame(t = d$t, level = levels_tau[[k]], resid = d$y - d[[k]])))
long$level <- factor(long$level, levels = unname(levels_tau))
thr <- do.call(rbind, lapply(split(long, long$level), function(z)
  data.frame(level = z$level[1],
             threshold = c("90%", "95%", "99%"),
             value = unname(quantile(z$resid, c(0.90, 0.95, 0.99), type = 7)))))
thr$threshold <- factor(thr$threshold, levels = c("90%", "95%", "99%"))

p_detr <- ggplot(long, aes(t, resid)) +
  geom_line(colour = "grey35", linewidth = 0.2) +
  geom_hline(data = thr, aes(yintercept = value, linetype = threshold),
             colour = "black", linewidth = 0.4) +
  scale_linetype_manual(values = c("90%" = "dashed", "95%" = "solid", "99%" = "dotted"),
                        name = "threshold (quantile of detrended data)") +
  facet_wrap(~level, ncol = 1, scales = "free_y") +
  x_scale +
  labs(title = "Detrended series | P-MALA (posterior median) | SPod d | 2018-06-15",
       x = NULL, y = "y - theta (counts)") +
  theme_bw(base_size = 11) +
  theme(legend.position = "bottom")

# Fitted baselines on the observed series: lines only.
fit <- do.call(rbind, lapply(names(levels_tau), function(k)
  data.frame(t = d$t, level = levels_tau[[k]], value = d[[k]])))
fit$level <- factor(fit$level, levels = unname(levels_tau))

p_fit <- ggplot() +
  geom_line(data = d, aes(t, y), colour = "grey60", linewidth = 0.2) +
  geom_line(data = fit, aes(t, value, colour = level), linewidth = 0.35) +
  scale_colour_manual(values = c("tau = 0.01" = "firebrick3",
                                 "tau = 0.05" = "steelblue",
                                 "tau = 0.10" = "darkgreen"), name = NULL) +
  x_scale +
  labs(title = "Baseline quantile trends | P-MALA (posterior median) | SPod d | 2018-06-15 | n = 8640",
       x = NULL, y = "PID (counts)") +
  theme_bw(base_size = 11) +
  theme(legend.position = "bottom")

ggsave(file.path(out_dir, "spod_detrended_pmala.png"), p_detr,
       width = 12, height = 9, dpi = 150)
ggsave(file.path(out_dir, "spod_quantiles_pmala.png"), p_fit,
       width = 12, height = 5.5, dpi = 150)

# Numbers quoted in Section 4.4.1, printed for checking.
cat("thresholds (counts):\n"); print(thr, row.names = FALSE)
cat("fraction below curve:",
    sprintf("%.4f", sapply(names(levels_tau), function(k) mean(d$y < d[[k]]))), "\n")
cross <- (d$q01 > d$q05) | (d$q05 > d$q10)
cat("time points with an adjacent pair out of order:", sum(cross), "of", nrow(d),
    "| q01 > q05:", sum(d$q01 > d$q05), "| q05 > q10:", sum(d$q05 > d$q10),
    "| largest reversal:", sprintf("%.2f", max(d$q01 - d$q05, d$q05 - d$q10)), "counts\n")
