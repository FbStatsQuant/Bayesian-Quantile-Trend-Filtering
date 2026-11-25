# E-10 (HQ red flag, 2026-11-25 ~09:00): where do the two chains disagree on theta at n = 2000, and how big is it against the bands?
# For each cell: chain-1 minus chain-2 posterior mean of theta over x, with the within-chain 95% half-width (mean of the two chains'
# (hi - lo) / 2) shaded; old (polynomial ASIS) left, new (spline ASIS {10,20,40}) right.  From the calibration chains (seed 1).
# Usage: Rscript e10_chaindiff_n2000.R <folder with the per-chain .rds> <output folder>
args <- commandArgs(trailingOnly = TRUE); in_dir <- args[1]; out <- args[2]; dir.create(out, showWarnings = FALSE, recursive = TRUE)
rd <- function(b, tau, v, c_) readRDS(file.path(in_dir, sprintf("n2000_%s_t%03d_%s_c%d.rds", b, round(100 * tau), v, c_)))
cells <- list(c("S", .5), c("S", .75), c("VS", .5), c("VS", .75))
png(file.path(out, "h2h_n2000_chain_difference.png"), width = 2400, height = 2600, res = 150)
par(mfrow = c(4, 2), mar = c(3.5, 4.2, 2.4, 1), mgp = c(2.2, 0.7, 0), oma = c(0, 0, 3, 0))
rows <- list()
for (cl in cells) { b <- cl[1]; tau <- as.numeric(cl[2])
  D <- lapply(c(old = "poly", new = "fixed"), function(v) { r1 <- rd(b, tau, v, 1); r2 <- rd(b, tau, v, 2)
    list(d = r1$est - r2$est, hw = ((r1$hi - r1$lo) + (r2$hi - r2$lo)) / 4, truth = r1$truth) })
  yl <- range(unlist(lapply(D, function(z) c(z$d, z$hw, -z$hw))))
  for (s in names(D)) { z <- D[[s]]; x <- seq_along(z$d); n <- length(x)
    plot(x, z$d, type = "n", ylim = yl, xlab = "index", ylab = "chain 1 - chain 2 (posterior mean)",
         main = sprintf("%s | %s tau %.2f | |diff|/half-width: median %.2f, max %.1f", s, b, tau, median(abs(z$d) / z$hw), max(abs(z$d) / z$hw)))
    polygon(c(x, rev(x)), c(z$hw, rev(-z$hw)), col = adjustcolor(if (s == "old") "#1f77b4" else "#d62728", 0.25), border = NA)
    lines(x, z$d, lwd = 1.2); abline(h = 0, lty = 3)
    ed <- c(1:(n %/% 20), (n - n %/% 20 + 1):n); r <- abs(z$d) / z$hw
    rows[[length(rows) + 1L]] <- data.frame(baseline = b, tau = tau, sampler = s, mean_halfwidth = mean(z$hw),
      median_abs_diff = median(abs(z$d)), max_abs_diff = max(abs(z$d)), median_ratio = median(r), max_ratio = max(r),
      frac_ratio_gt1 = mean(r > 1), ratio_edges_5pct_median = median(r[ed]), ratio_interior_median = median(r[-ed]),
      argmax_index = which.max(r)) }
}
mtext("n = 2000, seed 1: chain 1 minus chain 2 posterior mean of theta (black) vs within-chain 95% half-width (shaded)", outer = TRUE, font = 2)
dev.off()
Tb <- do.call(rbind, rows); write.csv(Tb, file.path(out, "h2h_n2000_chain_difference.csv"), row.names = FALSE)
print(Tb, digits = 3, row.names = FALSE)
