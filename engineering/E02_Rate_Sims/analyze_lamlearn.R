# E-02: learned-lambda arms (lamlearn, lamlearn2, lamlearn3): lambda-bar slopes in n (paired bootstrap over seeds), PQ/sin ratio,
# mixing diagnostics.  Theory's discriminator: at b0 = n^-2.5 slope 2.5 (VP) vs 2.25 (l1); ratio PQ/sin ~6 (VP) vs ~3.8 (l1).
suppressPackageStartupMessages(library(data.table))
R <- Sys.getenv("E02_GRID", "/home/fb31/Bayesian-Quantile-Trend-Filtering/runs/E02/nots/grid")
D <- rbindlist(lapply(c("lamlearn", "lamlearn2", "lamlearn3"), function(ph) rbindlist(lapply(list.files(file.path(R, ph), full.names = TRUE),
       function(f) as.data.table(readRDS(f)$row)), fill = TRUE)[, phase := ph]), fill = TRUE)
D[, b0lab := a]
cat("cells (mean over seeds):\n")
M <- D[, .(lam_med = median(lam_median), lam_mean = mean(lam_mean), ess_loglam = median(ess_loglam), ess_min = min(ess_loglam),
           drift_abs = median(abs(lam_drift)), pen = mean(pen_ratio), centre = mean(centre_d2), spread = mean(spread_d2), rough = mean(rough_spread),
           map_d2 = mean(map_d2), reps = .N), by = .(truth, noise, b0lab, n)]
setorder(M, truth, b0lab, n); print(M[, lapply(.SD, function(v) if (is.numeric(v)) signif(v, 3) else v)])
slope_boot <- function(d, B = 2000) {               # log(mean lambda over seeds) ~ log n; paired bootstrap over seed IDs
  W <- dcast(d, seed ~ n, value.var = "lam_mean"); X <- as.matrix(W[, -1]); X <- X[complete.cases(X), , drop = FALSE]; ns <- as.numeric(colnames(X))
  f <- function(M) unname(coef(lm(log(colMeans(M)) ~ log(ns)))[2])
  bs <- replicate(B, f(X[sample(nrow(X), nrow(X), TRUE), , drop = FALSE]))
  data.table(slope = f(X), lo = quantile(bs, .025), hi = quantile(bs, .975), reps = nrow(X))
}
cat("\nslope of log lambda-bar vs log n (paired bootstrap 95% CI):\n")
print(D[, slope_boot(.SD), by = .(truth, noise, b0lab)][, lapply(.SD, function(v) if (is.numeric(v)) round(v, 3) else v)])
cat("\nratio lambda-bar(PQT)/lambda-bar(sin) at the same n and b0 (paired by seed; bootstrap CI):\n")
for (b in c("Bn25", "Bn2", "B1", "B1e3")) for (nn in c(500, 2000, 8000)) {
  a <- D[truth == "PQT" & b0lab == b & n == nn, .(seed, p = lam_mean)]; s <- D[truth == "sin" & b0lab == b & n == nn, .(seed, s = lam_mean)]
  J <- merge(a, s, by = "seed"); if (nrow(J) < 3) next
  bs <- replicate(2000, { i <- sample(nrow(J), nrow(J), TRUE); mean(J$p[i]) / mean(J$s[i]) })
  cat(sprintf("  b0=%-5s n=%5d  ratio %.2f  [%.2f, %.2f]  (reps %d)\n", b, nn, mean(J$p) / mean(J$s), quantile(bs, .025), quantile(bs, .975), nrow(J)))
}
cat("\nlamlearn3 (quad, kappa = 4, b0 = n^-2): start lambda = m (Bn2) vs 0.3 n^(9/4) (Bn2i); prediction lambda ~ 0.45 n^(9/4)\n")
print(M[truth == "quad", .(b0lab, n, lam_med, pred = signif(0.45 * n^(9/4), 3), ess_loglam, drift_abs)])
