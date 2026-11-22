# E-02 (Theory statement v2): Laplace vs Gaussian twin (scale-mixture variances frozen at 2/lambda^2), paired by dataset seed.
# Ratios Laplace/twin of bias^2 (centre_mse), rough spread, total Delta2 risk (d2_mean) and draw-wise MSE (mse_mean); paired
# bootstrap over seeds.  Plus the deterministic spline-smoother bias^2 ||S theta* - theta*||^2/n, S = kappa (kappa I + lambda^2/2 D'D)^-1.
suppressPackageStartupMessages(library(data.table))
source(file.path(Sys.getenv("E02_DIR"), "e02_lib.R")); load_kernel()
G <- Sys.getenv("E02_GRID")
rd <- function(ph) rbindlist(lapply(list.files(file.path(G, ph), full.names = TRUE), function(f) as.data.table(readRDS(f)$row)), fill = TRUE)
L <- rbindlist(list(rd("T3")[a %in% c("b2", "b9_4", "b2.5") & noise == "g25" & tau == 0.5 & n %in% c(1000, 4000, 16000) & seed <= 10],
                    rd("kink83")[a == "b8_3" & truth == "PQT"], rd("T3s83")), fill = TRUE)
Tw <- rd("twin")
key <- c("truth", "a", "n", "seed")
J <- merge(L[, c(key, "lambda", "centre_mse", "rough_spread", "d2_mean", "mse_mean", "pen_ratio"), with = FALSE],
           Tw[, c(key, "centre_mse", "rough_spread", "d2_mean", "mse_mean"), with = FALSE], by = key, suffixes = c("_lap", "_tw"))
set.seed(1)
rat <- function(x, y, B = 2000) { r <- mean(x) / mean(y); bs <- replicate(B, { i <- sample(length(x), length(x), TRUE); mean(x[i]) / mean(y[i]) })
  sprintf("%.3f [%.3f, %.3f]", r, quantile(bs, .025), quantile(bs, .975)) }
out <- J[, .(reps = .N, lambda = signif(mean(lambda), 3), pen = round(mean(pen_ratio), 3),
             bias2_lap = signif(mean(centre_mse_lap), 3), bias2_tw = signif(mean(centre_mse_tw), 3),
             R_bias2 = rat(centre_mse_lap, centre_mse_tw), R_rough = rat(rough_spread_lap, rough_spread_tw),
             R_d2 = rat(d2_mean_lap, d2_mean_tw), R_mse = rat(mse_mean_lap, mse_mean_tw)), by = .(truth, a, n)]
kap <- kappa_eff("g25", 0.5)
out[, spline_bias2 := mapply(function(tr, nn, lam) { d <- make_data(tr, "g25", 0.5, nn, 1); signif(spline_bias(d$theta_star, d$y, kap, lam)[["spline_bias2"]], 3) }, truth, n, lambda)]
out[, w_over_n := signif((lambda^2 / kap)^(1/6) / n, 2)]
setorder(out, truth, a, n); options(width = 250); print(out)
fwrite(out, file.path(Sys.getenv("E02_OUT"), "analysis", "twin_ratios.csv"))
