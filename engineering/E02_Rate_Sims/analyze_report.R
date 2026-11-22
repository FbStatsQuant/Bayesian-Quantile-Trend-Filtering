# E-02 report numbers and figures (base R graphics; runs on NOTS).  P1 from three sweeps (T3lam, lamcurve, Qlam); raw-grid T3 slopes
# along lambda = n^a; figures: fig_P1.png (rough spread vs lambda), fig_kink.png (calibrated kinked truth: spread/risk and spline bias^2 vs n).
suppressPackageStartupMessages(library(data.table)); G <- Sys.getenv("E02_GRID"); O <- file.path(Sys.getenv("E02_OUT"), "analysis"); options(width = 220)
rd <- function(ph) rbindlist(lapply(list.files(file.path(G, ph), full.names = TRUE), function(f) as.data.table(readRDS(f)$row)), fill = TRUE)
kap <- function(noise) ifelse(noise == "g25", 16, 4)
sl <- function(x, y) unname(coef(lm(log(y) ~ log(x)))[2])
P <- rbind(rd("T3lam")[, src := "T3lam"], rd("lamcurve")[, src := "lamcurve"], rd("Qlam")[, src := "Qlam"], fill = TRUE)
P[, kappa := kap(noise)]
M <- P[, .(lambda = mean(lambda), rough = mean(rough_spread), pen = mean(pen_ratio), nl = n * mean(lambda)^(-1/3)), by = .(src, truth, noise, kappa, n, a)]
M[, C := rough * kappa^(5/6) * lambda^(1/3)]
cat("== P1: rough spread vs lambda at fixed n, many-mode cells (n lambda^-1/3 >= 10) ==\n")
print(M[nl >= 10, .(cells = .N, slope = round(sl(lambda, rough), 3), C_median = round(median(C), 3), C_range = paste(round(range(C), 3), collapse = "-")), by = .(src, truth, kappa, n)][order(src, truth, kappa, n)])
cat("\n== raw grid T3 (lambda = n^a, N(0,0.25^2), tau 0.5): slopes in n (n >= 1000) vs -a/3 ==\n")
T3 <- rd("T3")[noise == "g25" & tau == 0.5]
AV <- c(b1.5 = 1.5, b2 = 2, b15_7 = 15/7, b9_4 = 9/4, b7_3 = 7/3, b2.5 = 2.5)
T3[, aval := AV[a]]
print(T3[n >= 1000, .(n_range = paste(range(n), collapse = "-"), rough = round(sl(n, rough_spread), 3), pred = round(-aval[1] / 3, 3),
                      centre = round(sl(n, centre_mse), 3), risk = round(sl(n, d2_mean), 3), map = round(sl(n, map_d2), 3), pen_max = round(max(pen_ratio), 2)), by = .(truth, a, aval)][order(truth, aval)])
# ---- figures ----
png(file.path(O, "fig_P1.png"), width = 1500, height = 560, res = 130, type = "cairo"); par(mfrow = c(1, 3), mar = c(4.2, 4.4, 2.5, 1))
for (s in c("T3lam", "lamcurve", "Qlam")) {
  d <- M[src == s]; grp <- unique(d[, .(truth, kappa, n)]); cols <- seq_len(nrow(grp)) + 1
  plot(NA, xlim = range(d$lambda), ylim = range(d$rough), log = "xy", xlab = expression(lambda), ylab = "rough spread", main = sprintf("P1: %s", s))
  for (i in seq_len(nrow(grp))) { e <- d[truth == grp$truth[i] & kappa == grp$kappa[i] & n == grp$n[i]][order(lambda)]; lines(e$lambda, e$rough, col = cols[i], lwd = 2); points(e$lambda, e$rough, col = cols[i], pch = ifelse(e$nl >= 10, 16, 1), cex = .7) }
  for (k in unique(d$kappa)) { xx <- range(d$lambda); lines(xx, 0.3 * k^(-5/6) * xx^(-1/3), lty = 2) }
  legend("bottomleft", legend = sprintf("%s k=%g n=%d", grp$truth, grp$kappa, grp$n), col = cols, lwd = 2, cex = .7, bty = "n")
}
dev.off()
K <- fread(file.path(O, "kink_cells.csv")); K <- K[aval >= 2.2 & aval < 3]
png(file.path(O, "fig_kink.png"), width = 1500, height = 560, res = 130, type = "cairo"); par(mfrow = c(1, 3), mar = c(4.2, 4.4, 2.5, 1))
av <- sort(unique(K$aval)); cols <- seq_along(av) + 1
for (what in c("risk", "rough", "spline_bias2")) {
  plot(NA, xlim = range(K$n), ylim = range(K[[what]]), log = "xy", xlab = "n", ylab = what,
       main = c(risk = "posterior risk (mean Delta2)", rough = "rough spread (slope -a/3)", spline_bias2 = "bias^2 = spline bias^2 (VP: 5a/3-5)")[what])
  for (i in seq_along(av)) { e <- K[aval == av[i]][order(n)]; lines(e$n, e[[what]], col = cols[i], lwd = 2); points(e$n, e[[what]], col = cols[i], pch = 16, cex = .6) }
  legend("bottomleft", legend = sprintf("a = %.3g", av), col = cols, lwd = 2, cex = .75, bty = "n")
}
dev.off(); cat("\nfigures written to", O, "\n")
