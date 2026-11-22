# E-02: (1) P-MALA vs Gibbs efficiency (pvg); (2) long learned-lambda chains (lamlong): drift-clean slopes and PQ/sin ratio.
suppressPackageStartupMessages(library(data.table)); G <- Sys.getenv("E02_GRID"); options(width = 250)
P <- rbindlist(lapply(list.files(file.path(G, "pvg"), full.names = TRUE), function(f) as.data.table(readRDS(f)$row)), fill = TRUE)
cat("== (1) P-MALA vs Gibbs, learned lambda and sigma, sin, N(0,0.5^2), tau 0.5, 30k sweeps (10k burn) ==\n")
E <- P[, .(reps = .N, sec = mean(seconds), acc = mean(acc), lam = signif(mean(lam_mean), 4), sig = signif(mean(sig_mean), 4), d2 = signif(mean(d2_mean), 4),
           centre = signif(mean(centre_d2), 4), ess_d2 = round(mean(ess_d2)), ess_loglam = round(mean(ess_loglam)), ess_theta = round(mean(ess_theta_med)),
           esspsec_d2 = signif(mean(esspsec_d2), 3), esspsec_loglam = signif(mean(esspsec_loglam), 3), esspsec_theta = signif(mean(esspsec_theta_med), 3)),
       by = .(b0lab, n, sampler)]
setorder(E, b0lab, n, sampler); print(E)
R <- dcast(E, b0lab + n ~ sampler, value.var = c("sec", "esspsec_d2", "esspsec_loglam", "esspsec_theta", "lam", "d2"))
R[, `:=`(speed_per_sweep = round(sec_pmala / sec_gibbs, 1), gain_d2 = round(esspsec_d2_gibbs / esspsec_d2_pmala), gain_loglam = round(esspsec_loglam_gibbs / esspsec_loglam_pmala),
         gain_theta = round(esspsec_theta_gibbs / esspsec_theta_pmala), lam_ratio = round(lam_pmala / lam_gibbs, 3), d2_ratio = round(d2_pmala / d2_gibbs, 3))]
cat("\nGibbs/P-MALA efficiency gains (ESS per second) and agreement ratios (P-MALA/Gibbs):\n"); print(R[, .(b0lab, n, speed_per_sweep, gain_d2, gain_loglam, gain_theta, lam_ratio, d2_ratio)])
cat("\n== (2) lamlong: 30k kept, started at first-pass lambda; drift-clean cells only (|half-chain log-lambda drift| <= 2 MC se) ==\n")
f <- list.files(file.path(G, "lamlong"), full.names = TRUE)
L <- rbindlist(lapply(f, function(x) { o <- readRDS(x); r <- as.data.table(o$row); lt <- log(o$trace$lambda[-(1:3000)]); h <- length(lt) %/% 2
  se <- sqrt(var(lt[1:h]) / coda::effectiveSize(lt[1:h]) + var(lt[-(1:h)]) / coda::effectiveSize(lt[-(1:h)]))
  r[, `:=`(drift = mean(lt[-(1:h)]) - mean(lt[1:h]), drift_se = se)]; r }), fill = TRUE)
L[, clean := abs(drift) <= 2 * drift_se]
print(L[, .(reps = .N, clean = sum(clean), lam_med = signif(median(lam_median), 3), ess_loglam = round(median(ess_loglam)), drift_med = signif(median(abs(drift)), 2)), by = .(truth, a, n)][order(truth, a, n)])
sb <- function(d) { W <- dcast(d, seed ~ n, value.var = "lam_mean"); X <- as.matrix(W[, -1]); X <- X[complete.cases(X), , drop = FALSE]; ns <- as.numeric(colnames(X))
  if (nrow(X) < 3 || length(ns) < 3) return(data.table(slope = NA_real_, lo = NA_real_, hi = NA_real_, seeds = nrow(X)))
  fs <- function(M) unname(coef(lm(log(colMeans(M)) ~ log(ns)))[2]); bs <- replicate(2000, fs(X[sample(nrow(X), nrow(X), TRUE), , drop = FALSE]))
  data.table(slope = round(fs(X), 3), lo = round(quantile(bs, .025), 3), hi = round(quantile(bs, .975), 3), seeds = nrow(X)) }
cat("\nlambda-bar slope in n, seeds clean at all three n:\n")
ok <- L[, .(allclean = all(clean)), by = .(truth, a, seed)][allclean == TRUE]
print(merge(L, ok[, .(truth, a, seed)], by = c("truth", "a", "seed"))[, sb(.SD), by = .(truth, a)])
cat("\nall seeds (for comparison):\n"); print(L[, sb(.SD), by = .(truth, a)])
cat("\nPQ/sin lambda-bar ratio (clean cells, means over clean seeds):\n")
print(dcast(L[clean == TRUE, .(lam = mean(lam_mean)), by = .(truth, a, n)], a + n ~ truth, value.var = "lam")[, ratio := round(PQT / sin, 2)][])
