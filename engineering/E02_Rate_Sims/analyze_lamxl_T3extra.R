# E-02 final pieces: (1) lamxl extra-long learned-lambda chains (b0 = n^-2.5, sin and PQT, n = 2k: 100k kept; 8k: 250k kept)
# against the 30k lamlong chains; lambda-bar slope with lamlong n = 500 + lamxl n = 2k/8k.  (2) T3 raw grid (lambda = n^a,
# sigma = sigma0): the tau = 0.9 (N(0, 0.25^2)) and Cauchy(0, 0.1) arms, slopes in n against the tau = 0.5 Gaussian arm.
suppressPackageStartupMessages(library(data.table)); G <- Sys.getenv("E02_GRID"); options(width = 220)
rd <- function(ph) rbindlist(lapply(list.files(file.path(G, ph), full.names = TRUE), function(f) as.data.table(readRDS(f)$row)), fill = TRUE)
drift_tab <- function(ph, burn = 3000L) rbindlist(lapply(list.files(file.path(G, ph), full.names = TRUE), function(x) {
  o <- readRDS(x); r <- as.data.table(o$row); lt <- log(o$trace$lambda[-(1:burn)]); h <- length(lt) %/% 2
  se <- sqrt(var(lt[1:h]) / coda::effectiveSize(lt[1:h]) + var(lt[-(1:h)]) / coda::effectiveSize(lt[-(1:h)]))
  r[, `:=`(drift = mean(lt[-(1:h)]) - mean(lt[1:h]), drift_se = se, src = ph)]; r }), fill = TRUE)
cat("== (1) lamxl vs lamlong, b0 = n^-2.5 ==\n")
X <- drift_tab("lamxl"); L <- drift_tab("lamlong")[a == "Bn25"]
X[, clean := abs(drift) <= 2 * drift_se]; L[, clean := abs(drift) <= 2 * drift_se]
B <- rbind(L, X, fill = TRUE)
print(B[, .(reps = .N, clean = sum(clean), lam_mean = signif(mean(lam_mean), 4), ess_loglam = round(median(ess_loglam)),
            absdrift_med = signif(median(abs(drift)), 2), d2 = signif(mean(d2_mean), 4)), by = .(truth, n, src)][order(truth, n, src)])
cat("\nlambda-bar ratio lamxl / lamlong (same seeds):\n")
Rt <- merge(X[, .(truth, n, seed, xl = lam_mean)], L[, .(truth, n, seed, long = lam_mean)], by = c("truth", "n", "seed"))
print(Rt[, .(seeds = .N, ratio_mean = round(mean(xl / long), 3), ratio_range = paste(round(range(xl / long), 3), collapse = "-")), by = .(truth, n)])
sb <- function(d) { W <- dcast(d, seed ~ n, value.var = "lam_mean"); M <- as.matrix(W[, -1]); M <- M[complete.cases(M), , drop = FALSE]; ns <- as.numeric(colnames(M))
  fs <- function(Z) unname(coef(lm(log(colMeans(Z)) ~ log(ns)))[2]); set.seed(1); bs <- replicate(2000, fs(M[sample(nrow(M), nrow(M), TRUE), , drop = FALSE]))
  data.table(slope = round(fs(M), 3), lo = round(quantile(bs, .025), 3), hi = round(quantile(bs, .975), 3), seeds = nrow(M)) }
C <- rbind(L[n == 500], X, fill = TRUE)
cat("\nlambda-bar slope in n (lamlong n = 500 + lamxl n = 2k, 8k); lamlong-only was sin 2.531 [2.496, 2.565], PQT 2.139 [2.023, 2.275]:\n")
print(C[, sb(.SD), by = truth])
ok <- C[, .(allclean = all(clean)), by = .(truth, seed)][allclean == TRUE]
cat("seeds drift-clean at all three n:\n"); print(merge(C, ok[, .(truth, seed)], by = c("truth", "seed"))[, sb(.SD), by = truth])
cat("\nPQT/sin lambda-bar ratio (lamxl at 2k, 8k):\n"); print(dcast(C[, .(lam = mean(lam_mean)), by = .(truth, n)], n ~ truth, value.var = "lam")[, ratio := round(PQT / sin, 2)][])

cat("\n== (2) T3 raw grid lambda = n^a: tau = 0.9 and Cauchy arms vs tau = 0.5 Gaussian (n = 1k..4k, common range) ==\n")
T3 <- rd("T3"); AV <- c(b1.5 = 1.5, b2 = 2, b15_7 = 15/7, b9_4 = 9/4, b7_3 = 7/3, b2.5 = 2.5); T3[, aval := AV[a]]
T3[, arm := fifelse(noise == "cauchy10", "cauchy_t50", fifelse(tau == 0.9, "g25_t90", "g25_t50"))]
sl <- function(x, y) unname(coef(lm(log(y) ~ log(x)))[2])
S <- T3[n >= 1000 & n <= 4000, .(seeds = uniqueN(seed), nl_min = round(min(n * lambda^(-1/3)), 1), rough = round(sl(n, rough_spread), 3), pred_rough = round(-aval[1] / 3, 3),
                                 risk = round(sl(n, d2_mean), 3), centre = round(sl(n, centre_d2), 3), map = round(sl(n, map_d2), 3),
                                 pen_max = round(max(pen_ratio), 2), ess_min = round(min(ess_d2))), by = .(truth, arm, a, aval)][order(truth, aval, arm)]
print(S)
cat("\nrough-spread constant C = rough * kappa^(5/6) * lambda^(1/3) by arm (many-mode cells, n*lambda^-1/3 >= 10):\n")
source(file.path(Sys.getenv("E02_DIR"), "e02_lib.R"))
K <- unique(T3[, .(noise, tau)])[, kappa := mapply(kappa_eff, noise, tau)]; T3 <- merge(T3, K, by = c("noise", "tau"))
T3[, C := rough_spread * kappa^(5/6) * lambda^(1/3)]
print(T3[n * lambda^(-1/3) >= 10, .(cells = .N, kappa = round(kappa[1], 2), C_median = round(median(C), 3), C_iqr = paste(round(quantile(C, c(.25, .75)), 3), collapse = "-")), by = .(truth, arm)][order(truth, arm)])
