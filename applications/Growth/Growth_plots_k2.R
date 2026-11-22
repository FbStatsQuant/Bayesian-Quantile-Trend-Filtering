# Growth centiles, joint (non-crossing) P-MALA fits, k = 2: one figure per sex.
#
# Reads results_joint_k2/<sex>/posterior_summary.csv (written by Growth_Joint_PMALA_k2.R) and data/fdgs.csv, and writes
# results_joint_k2/figures/growth_joint_<boys|girls>.{pdf,png} in the layout of the manuscript's growth figures
# (grey points = children, curves = posterior means of the five levels).  Also prints the in-sample calibration
# (fraction of children below each curve) and the number of crossings of the posterior-mean curves.
#
# Run with the working directory set to this script's folder (applications/Growth).

suppressPackageStartupMessages({ library(ggplot2) })

d_all <- read.csv(file.path("data", "fdgs.csv"))
fig_dir <- file.path("results_joint_k2", "figures")
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)
cols <- c("10%" = "#0072B2", "30%" = "#009E73", "50%" = "#000000", "70%" = "#E69F00", "90%" = "#D55E00")

for (sex in c("boy", "girl")) {
  f <- file.path("results_joint_k2", sex, "posterior_summary.csv")
  if (!file.exists(f)) { message("skipping ", sex, ": ", f, " not found"); next }
  fits <- read.csv(f)
  fits$quantile <- factor(paste0(round(100 * fits$tau), "%"), levels = names(cols))
  d <- d_all[d_all$sex == sex & !is.na(d_all$hgt), ]
  p <- ggplot() +
    geom_point(data = d, aes(x = age, y = hgt), colour = "grey55", alpha = 0.35, size = 0.5) +
    geom_line(data = fits, aes(x = age, y = estimate, colour = quantile), linewidth = 0.8) +
    scale_colour_manual(values = cols, name = "Quantile") +
    scale_x_continuous(breaks = seq(0, 22, 2)) +
    labs(x = "Age (years)", y = "Height (cm)") +
    theme_minimal() + theme(legend.position = "bottom")
  stem <- paste0("growth_joint_", sex, "s")
  ggsave(file.path(fig_dir, paste0(stem, ".pdf")), p, width = 8.5, height = 5.2, bg = "white")
  ggsave(file.path(fig_dir, paste0(stem, ".png")), p, width = 8.5, height = 5.2, dpi = 220, bg = "white")

  # calibration and crossings of the posterior-mean curves (slot = age rounded to 0.1 y, as in the sampler)
  est <- sapply(sort(unique(fits$tau)), function(t) fits$estimate[fits$tau == t][order(fits$age[fits$tau == t])])
  ages <- sort(unique(fits$age)); s <- match(round(10 * d$age), round(10 * ages))
  cat(sex, "| children", nrow(d), "| frac_below:", sprintf("%.3f", colMeans(d$hgt < est[s, , drop = FALSE])),
      "| slots with a crossing of the mean curves:", sum(apply(est, 1, function(r) any(diff(r) < 0))), "of", nrow(est), "\n")
}
