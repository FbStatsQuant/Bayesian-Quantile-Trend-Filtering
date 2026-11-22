# Munich rent application, k = 2: figures for both methods.
#
# Draws the four manuscript figures from the posterior summaries written by
#   Munich_PMALA_k2.R      -> results_pmala_k2/posterior_summary.csv
#   Munich_Onizuka_HS_k2.R -> results_onizuka_k2/posterior_summary.csv
# through ONE routine, so the two methods' panels are identical in layout,
# colour, scale and point style and differ only in the fitted curves. This is
# what the manuscript claims when it says the two are compared "under the same
# layout".
#
# The figure basenames are the ones \includegraphics expects in
# PMALA version Tex Project/figures/:
#   munich_pmala_q10_q90      munich_pmala_q30_q50_q70
#   munich_onizuka_q10_q90    munich_onizuka_q30_q50_q70
#
# Run with the working directory set to this script's folder
# (Data Applications/Munich Rent).

library(ggplot2)
library(dplyr)
library(tidyr)

taus <- c(0.10, 0.30, 0.50, 0.70, 0.90)

# DATA (same processing as both samplers)
munich_file <- file.path("data", "munich.rda")
stopifnot(file.exists(munich_file))
load(munich_file)
munich <- munich[order(munich$fsize), ]
y         <- munich$rent
locations <- sort(unique(munich$fsize))
obs_index <- match(munich$fsize, locations)

df_data <- tibble(fsize = munich$fsize, rent = y)

quantile_colors <- c("10%" = "#F15A60", "30%" = "#67B85C", "50%" = "#2196F3",
                     "70%" = "#2CCED2", "90%" = "#E229C2")

# Shared drawing routine: data, 95% bands, posterior-mean curves for the
# requested quantiles; sandwich = TRUE also shades between the first and
# last curve.
quantile_plot <- function(df_fits, which_taus, sandwich = FALSE) {
  df <- filter(df_fits, tau %in% which_taus)
  p <- ggplot()
  if (sandwich) {
    lo <- filter(df, tau == min(which_taus))
    hi <- filter(df, tau == max(which_taus))
    band <- data.frame(location = lo$location, q_lo = lo$estimate, q_hi = hi$estimate)
    p <- p + geom_ribbon(data = band, aes(x = location, ymin = q_lo, ymax = q_hi),
                         fill = "grey80", alpha = 0.45)
  }
  p +
    geom_point(data = df_data, aes(x = fsize, y = rent),
               shape = 1, color = "grey55", alpha = 0.5, size = 1) +
    geom_ribbon(data = df, aes(x = location, ymin = lower, ymax = upper, fill = quantile),
                alpha = 0.25) +
    geom_line(data = df, aes(x = location, y = estimate, color = quantile),
              linewidth = 1) +
    scale_color_manual(values = quantile_colors) +
    scale_fill_manual(values = quantile_colors) +
    labs(x = "floor size (m2)", y = "rent (EUR per m2)", color = NULL, fill = NULL) +
    theme_minimal() +
    theme(legend.position = "top")
}

read_fits <- function(dir) {
  f <- file.path(dir, "posterior_summary.csv")
  stopifnot(file.exists(f))
  as_tibble(read.csv(f)) %>%
    mutate(quantile = factor(paste0(100 * tau, "%"),
                             levels = paste0(100 * sort(taus), "%")))
}

methods <- list(
  pmala   = list(dir = "results_pmala_k2",   stem = "munich_pmala"),
  onizuka = list(dir = "results_onizuka_k2", stem = "munich_onizuka")
)

for (mname in names(methods)) {
  m <- methods[[mname]]
  if (!file.exists(file.path(m$dir, "posterior_summary.csv"))) {
    message("skipping ", mname, ": ", m$dir, "/posterior_summary.csv not found")
    next
  }
  df_fits <- read_fits(m$dir)

  panels <- list(
    list(name = paste0(m$stem, "_q10_q90"),      taus = c(0.10, 0.90), sandwich = TRUE),
    list(name = paste0(m$stem, "_q30_q50_q70"),  taus = c(0.30, 0.50, 0.70), sandwich = FALSE)
  )

  for (pan in panels) {
    p <- quantile_plot(df_fits, pan$taus, sandwich = pan$sandwich)
    ggsave(file.path(m$dir, paste0(pan$name, ".pdf")), p,
           width = 8.5, height = 5.2, bg = "white")
    ggsave(file.path(m$dir, paste0(pan$name, ".png")), p,
           width = 8.5, height = 5.2, dpi = 220, bg = "white")
    cat("wrote", file.path(m$dir, pan$name), ".pdf/.png\n")
  }

  # In-sample calibration of the posterior-mean curves, and whether the five
  # independent fits happen to be ordered at every floor size.
  est_wide <- df_fits %>%
    select(location, tau, estimate) %>%
    pivot_wider(names_from = tau, values_from = estimate) %>%
    arrange(location)
  est_mat <- as.matrix(est_wide[, -1])
  frac_below <- sapply(seq_along(taus), function(j)
    mean(y < est_mat[obs_index, j]))
  cat(mname, "frac_below:", paste(sprintf("%.3f", frac_below), collapse = " "), "\n")
  cat(mname, "locations where the five curves are not ordered:",
      sum(apply(est_mat, 1, function(r) any(diff(r) < 0))), "of", nrow(est_mat), "\n\n")
}
