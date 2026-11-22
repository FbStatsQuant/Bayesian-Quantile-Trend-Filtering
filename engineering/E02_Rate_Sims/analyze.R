# E-02 analysis: per-cell means, log-log slopes vs n with bootstrap CIs over replicates, ESS diagnostics, plots.
#   Rscript analyze.R [phase ...]      (default: all phases present)
suppressPackageStartupMessages({ library(ggplot2); library(data.table) })
E02 <- "/home/fb31/Bayesian-Quantile-Trend-Filtering/engineering/E02_Rate_Sims"
ROOT <- "/home/fb31/BQTF_runs/E02/grid"
phases <- commandArgs(trailingOnly = TRUE); if (!length(phases)) phases <- list.files(ROOT)
dir.create(file.path(E02, "figs"), showWarnings = FALSE); dir.create(file.path(E02, "tables"), showWarnings = FALSE)
A_LAB <- c(a1 = "1", a15_7 = "15/7", a9_4 = "9/4", a7_3 = "7/3", a3 = "3")
read_phase <- function(ph) {
  f <- list.files(file.path(ROOT, ph), pattern = "\\.rds$", full.names = TRUE)
  if (!length(f)) return(NULL)
  rbindlist(lapply(f, function(x) tryCatch(as.data.table(readRDS(x)$row), error = function(e) NULL)), fill = TRUE)[, phase := ph]
}
DT <- rbindlist(lapply(phases, read_phase), fill = TRUE)
cat(sprintf("rows: %d\n", nrow(DT))); fwrite(DT, file.path(E02, "tables", "all_rows.csv"))
METRICS <- c("d2_mean", "d2_q95", "centre_d2", "spread_d2", "map_d2", "mse_mean")

# ---- cell means and diagnostics ----
grid <- DT[!startsWith(a, "L")]
cells <- grid[, c(lapply(.SD, mean), list(reps = .N, ess_min = min(ess_d2), ess_med = median(ess_d2), frac_ess_lt100 = mean(ess_d2 < 100),
                 cover95 = mean(cover95), pen_ratio = mean(pen_ratio), sec = mean(seconds))),
              by = .(truth, noise, tau, a, n), .SDcols = METRICS]
setorder(cells, truth, noise, tau, a, n); fwrite(cells, file.path(E02, "tables", "cell_means.csv"))

# ---- slopes: log(mean metric) ~ log n, PAIRED bootstrap over replicates ----
# Replicate s uses data seed s at every n, and the noise vectors share a prefix across n (set.seed(s); rnorm(n)), so replicate s is
# correlated across n.  The bootstrap therefore resamples replicate IDs once and uses the same resampled IDs at every n (E-04 fix).
slope_of <- function(n, v) unname(coef(lm(log(v) ~ log(n)))[2])
boot_slopes <- function(d, metric, nmin = 0, B = 400) {
  d <- d[n >= nmin]; ns <- sort(unique(d$n)); if (length(ns) < 3) return(NULL)
  W <- dcast(d, seed ~ n, value.var = metric)              # rows = replicate, cols = n
  M <- as.matrix(W[, -1]); ok <- stats::complete.cases(M); M <- M[ok, , drop = FALSE]
  est <- slope_of(ns, colMeans(M))
  bs <- replicate(B, { i <- sample(nrow(M), nrow(M), TRUE); slope_of(ns, colMeans(M[i, , drop = FALSE])) })
  data.table(metric = metric, nmin = nmin, slope = est, lo = quantile(bs, .025), hi = quantile(bs, .975), reps = nrow(M), n_range = sprintf("%d-%d", min(ns), max(ns)))
}
set.seed(1)
SL <- grid[, rbindlist(lapply(METRICS, function(mt) rbind(boot_slopes(.SD, mt, 0), boot_slopes(.SD, mt, 2000)))), by = .(truth, noise, tau, a)]
fwrite(SL, file.path(E02, "tables", "slopes.csv"))

# compact markdown slope table (all n and n >= 2000) for the report
fmt <- function(s, lo, hi) sprintf("%.2f [%.2f, %.2f]", s, lo, hi)
for (nm in c(0, 2000)) {
  W <- SL[nmin == nm, .(cell = paste(truth, noise, tau, A_LAB[a]), metric, txt = fmt(slope, lo, hi))]
  W <- dcast(W, cell ~ metric, value.var = "txt")
  setcolorder(W, c("cell", intersect(c("d2_mean", "d2_q95", "centre_d2", "spread_d2", "map_d2", "mse_mean"), names(W))))
  writeLines(c(paste("|", paste(names(W), collapse = " | "), "|"), paste(rep("|---", ncol(W)), collapse = ""), "|",
               apply(W, 1, function(r) paste("|", paste(r, collapse = " | "), "|"))),
             file.path(E02, "tables", sprintf("slopes_nmin%d.md", nm)))
}

# ---- plots ----
long <- melt(cells, id.vars = c("truth", "noise", "tau", "a", "n"), measure.vars = c("d2_mean", "centre_d2", "spread_d2", "map_d2"), variable.name = "metric")
long[, a_lab := factor(A_LAB[a], levels = A_LAB)]
for (key in unique(paste(long$noise, long$tau))) {
  sub <- long[paste(noise, tau) == key]
  g <- ggplot(sub, aes(n, value, colour = a_lab)) + geom_line() + geom_point(size = 1) +
    scale_x_log10() + scale_y_log10() + facet_grid(metric ~ truth, scales = "free_y") +
    labs(title = sprintf("E-02: Delta2 vs n (%s, tau = %s); lambda*sigma = c n^a", strsplit(key, " ")[[1]][1], strsplit(key, " ")[[1]][2]), colour = "a", y = "mean over replicates") +
    theme_bw(base_size = 10)
  ggsave(file.path(E02, "figs", sprintf("rates_%s.png", gsub(" ", "_tau", key))), g, width = 10, height = 8, dpi = 130)
}
# ESS diagnostic plot
g <- ggplot(grid, aes(factor(n), ess_d2)) + geom_boxplot(outlier.size = .4) + facet_grid(a ~ truth + paste(noise, tau)) + scale_y_log10() +
  geom_hline(yintercept = 100, linetype = 2, colour = "red") + labs(x = "n", y = "ESS of Delta2 chain (5000 kept draws)") + theme_bw(base_size = 8) +
  theme(axis.text.x = element_text(angle = 90))
ggsave(file.path(E02, "figs", "ess_d2.png"), g, width = 12, height = 8, dpi = 120)

# ---- spread vs lambda (lamcurve phase) ----
lc <- DT[startsWith(a, "L")]
if (nrow(lc)) {
  lcm <- lc[, .(spread_d2 = mean(spread_d2), centre_d2 = mean(centre_d2), d2_mean = mean(d2_mean), lambda = mean(lambda), ess_min = min(ess_d2)), by = .(truth, n, a)]
  fwrite(lcm, file.path(E02, "tables", "lamcurve_means.csv"))
  lsl <- lcm[, .(spread_vs_lambda_slope_all = slope_of(lambda, spread_d2),
                 spread_vs_lambda_slope_upper = slope_of(lambda[lambda >= median(lambda)], spread_d2[lambda >= median(lambda)])), by = .(truth, n)]
  fwrite(lsl, file.path(E02, "tables", "lamcurve_slopes.csv")); print(lsl)
  g <- ggplot(melt(lcm, id.vars = c("truth", "n", "a", "lambda", "ess_min"), measure.vars = c("spread_d2", "centre_d2", "d2_mean")),
              aes(lambda, value, colour = variable)) + geom_line() + geom_point(size = 1) + scale_x_log10() + scale_y_log10() +
    facet_grid(n ~ truth) + geom_abline(slope = -1/3, intercept = 0, linetype = 3) + labs(title = "Spread / centre vs lambda at fixed n (dotted: slope -1/3 reference)") + theme_bw(base_size = 10)
  ggsave(file.path(E02, "figs", "lamcurve.png"), g, width = 10, height = 6, dpi = 130)
}
cat("analysis written to", file.path(E02, "tables"), "and", file.path(E02, "figs"), "\n")
