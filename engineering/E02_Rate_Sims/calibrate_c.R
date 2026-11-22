# E-02: calibrate c once at n0 = 500: Lam* = argmin_Lam mean_seeds Delta2(MAP_Lam - theta*) for the smooth truth (sin),
# Gaussian noise, tau = 0.5.  Then lambda*sigma = c_a n^a with c_a = Lam* / n0^a, so every a-curve passes through Lam* at n0.
source("/home/fb31/Bayesian-Quantile-Trend-Filtering/engineering/E02_Rate_Sims/e02_lib.R")
n0 <- 500; grid <- exp(seq(log(10), log(1e5), length.out = 41)); seeds <- 1:10
r <- withCallingHandlers(sapply(grid, function(L) mean(sapply(seeds, function(s) { d <- make_data("sin", "gauss", 0.5, n0, s); Delta2(qtf_map(d$y, 0.5, L) - d$theta_star) }))),
       warning = function(w) { if (grepl("rq.fit.sfn|tiny", conditionMessage(w))) invokeRestart("muffleWarning") })
i <- which.min(r); Lstar <- grid[i]
cat(sprintf("Lam*(n0=500) = %.3f  (Delta2 = %.5f); grid neighbours %.3f / %.3f\n", Lstar, r[i], grid[max(1,i-1)], grid[min(length(grid),i+1)]))
print(round(cbind(Lam = grid, D2 = r), 5))
A <- c(1, 15/7, 9/4, 7/3, 3)
cal <- data.frame(a = A, c = Lstar / n0^A, Lam_n0 = Lstar)
for (n in c(250, 1000, 4000, 16000, 32000)) cal[[paste0("Lam_n", n)]] <- cal$c * n^cal$a
print(signif(cal, 4))
saveRDS(list(Lstar = Lstar, grid = grid, d2 = r, cal = cal), "/home/fb31/BQTF_runs/E02/calibration.rds")
d <- make_data("sin", "gauss", 0.5, 500, 1); invisible(tryCatch(qtf_map(d$y, 0.5, Lstar), warning = function(w) cat("rq warning text:", conditionMessage(w), "\n")))
