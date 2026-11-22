# E-02: calibrated kinked-truth (pq) arm, the bias-law slope test (Theory).  lambda*sigma0 = 2000 (n/500)^a, N(0, 0.5^2) (kappa = 4).
# Slopes over n >= 2000 (paired bootstrap over seeds) for centre bias^2 (||theta_bar - theta*||^2/n), centre Delta2, rough spread,
# total risk (posterior mean of Delta2) and MAP error; the deterministic spline bias^2 per (a, n); risk-minimising a at each n.
suppressPackageStartupMessages(library(data.table))
source(file.path(Sys.getenv("E02_DIR"), "e02_lib.R")); load_kernel()
G <- Sys.getenv("E02_GRID")
rd <- function(ph) rbindlist(lapply(list.files(file.path(G, ph), pattern = "^pq_", full.names = TRUE), function(f) as.data.table(readRDS(f)$row)), fill = TRUE)
D <- rbindlist(list(rd("p1"), rd("kink83")[noise == "gauss"], rd("kink25"), rd("kink2426")), fill = TRUE)
D <- D[noise == "gauss" & tau == 0.5]
AV <- c(a1 = 1, a15_7 = 15/7, a9_4 = 9/4, a2.4 = 2.4, a7_3 = 7/3, a2.5 = 2.5, a2.6 = 2.6, a8_3 = 8/3, a3 = 3)
D[, aval := AV[a]]
kap <- kappa_eff("gauss", 0.5)
cat(sprintf("rows %d; kappa %.3f; cells per a:\n", nrow(D), kap)); print(D[, .N, by = .(a, n)][, .(n_cells = .N, reps = paste(range(N), collapse = "-")), by = a])
slope_boot <- function(d, metric, B = 2000) {
  W <- dcast(d, seed ~ n, value.var = metric); X <- as.matrix(W[, -1]); X <- X[complete.cases(X), , drop = FALSE]; ns <- as.numeric(colnames(X))
  f <- function(M) unname(coef(lm(log(colMeans(M)) ~ log(ns)))[2]); bs <- replicate(B, f(X[sample(nrow(X), nrow(X), TRUE), , drop = FALSE]))
  sprintf("%.3f [%.3f, %.3f]", f(X), quantile(bs, .025), quantile(bs, .975))
}
set.seed(1)
S <- D[n >= 2000, .(VP = round(5 * aval[1] / 3 - 5, 3), L1 = round(aval[1] - 3, 3), spread_pred = round(-aval[1] / 3, 3),
                    centre_mse = slope_boot(.SD, "centre_mse"), centre_d2 = slope_boot(.SD, "centre_d2"),
                    rough = slope_boot(.SD, "rough_spread"), risk_d2 = slope_boot(.SD, "d2_mean"), map_d2 = slope_boot(.SD, "map_d2"), reps = .N / uniqueN(n)), by = .(a, aval)]
setorder(S, aval); options(width = 250); cat("\n== slopes in n (n >= 2000), paired bootstrap 95% CI ==\n"); print(S)
# deterministic spline bias^2 and diagnostics per (a, n)
M <- D[, .(lambda = mean(lambda), centre_mse = mean(centre_mse), rough = mean(rough_spread), risk = mean(d2_mean), map = mean(map_d2), pen = mean(pen_ratio),
           ess_min = min(ess_d2)), by = .(a, aval, n)]
th <- function(nn) make_data("pq", "gauss", 0.5, nn, 1)
M[, spline_bias2 := mapply(function(nn, lam) { d <- th(nn); spline_bias(d$theta_star, d$y, kap, lam)[["spline_bias2"]] }, n, lambda)]
M[, `:=`(n_lam13 = n * lambda^(-1/3), w_over_n = (lambda^2 / kap)^(1/6) / n)]
setorder(M, aval, n); cat("\n== cell means ==\n"); print(M[, lapply(.SD, function(v) if (is.numeric(v)) signif(v, 3) else v)])
cat("\n== spline bias^2 slope (n >= 2000) ==\n"); print(M[n >= 2000, .(spline_slope = round(unname(coef(lm(log(spline_bias2) ~ log(n)))[2]), 3)), by = .(a, aval)][order(aval)])
cat("\n== risk-minimising a at each n (posterior risk = mean Delta2; also centre_mse) ==\n")
print(M[, .(a_best_risk = a[which.min(risk)], risk_min = signif(min(risk), 3), a_best_centre = a[which.min(centre_mse)]), by = n][order(n)])
fwrite(S, file.path(Sys.getenv("E02_OUT"), "analysis", "kink_slopes.csv")); fwrite(M, file.path(Sys.getenv("E02_OUT"), "analysis", "kink_cells.csv"))
