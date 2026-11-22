# E-02: quick analysis of the T3lam phase (Theory P1: rough spread vs lambda at fixed n). Reads the synced NOTS outputs.
suppressPackageStartupMessages(library(data.table))
f <- list.files("/home/fb31/BQTF_runs/E02/nots/grid/T3lam", full.names = TRUE)
D <- rbindlist(lapply(f, function(x) as.data.table(readRDS(x)$row)), fill = TRUE)
D[, loglam := log10(lambda)]
M <- D[, .(rough = mean(rough_spread), total = mean(total_spread), bias2 = mean(centre_mse), spread_d2 = mean(spread_d2), centre_d2 = mean(centre_d2),
           d2 = mean(d2_mean), map_d2 = mean(map_d2), pen = mean(pen_ratio), ess = min(ess_d2), cov = mean(cover95)), by = .(truth, n, loglam)]
setorder(M, truth, n, loglam); print(M[, lapply(.SD, function(v) if (is.numeric(v)) signif(v, 3) else v)])
sl <- function(x, y) unname(coef(lm(log(y) ~ log(x)))[2])
cat("\nslope of log rough spread vs log lambda (all lambda / lambda <= 1e6 / lambda >= 1e6):\n")
print(M[, .(all = sl(10^loglam, rough), low = sl(10^loglam[loglam <= 6], rough[loglam <= 6]), high = sl(10^loglam[loglam >= 6], rough[loglam >= 6]),
            n_lam13 = n * (10^loglam[1])^(-1/3)), by = .(truth, n)])
cat("\nP1 constant C in rough = C kappa^(-5/6) lambda^(-1/3), kappa = 16:\n")
print(M[, .(C_median = median(rough * 16^(5/6) * (10^loglam)^(1/3)), C_range = paste(signif(range(rough * 16^(5/6) * (10^loglam)^(1/3)), 3), collapse = "-")), by = .(truth, n)])
cat("\nflatness in n at fixed lambda: rough(n=4000)/rough(n=1000)\n")
W <- dcast(M, truth + loglam ~ n, value.var = "rough"); W[, ratio := `4000` / `1000`]; print(W[, .(truth, loglam, ratio = signif(ratio, 3))])
