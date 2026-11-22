# E-04 part A2: exact check at tau = 0.9 (n = 4) with honest Monte Carlo errors (all draws kept, batch means) and a fine grid
# accumulated in chunks (no 4-d array in memory).  Also tau = 0.5, lambda = 5 as a control.
E02_DIR <- Sys.getenv("E02_DIR", "/home/fb31/Bayesian-Quantile-Trend-Filtering/Engineering/E02_Rate_Sims")
source(file.path(E02_DIR, "e02_lib.R")); load_kernel()
bm_se <- function(v, nb = 100) { b <- floor(length(v) / nb); sd(colMeans(matrix(v[1:(b * nb)], b, nb))) / sqrt(nb) }
y <- c(0.1, 0.5, -0.2, 0.4); n <- 4
exact <- function(tau, lam, sig, G = 160) {
  lo_r <- 9 * sig / tau; hi_r <- 9 * sig / (1 - tau)
  ax <- lapply(1:n, function(i) { e <- seq(y[i] - lo_r, y[i] + hi_r, length.out = G + 1); (e[-1] + e[-(G + 1)]) / 2 })
  g234 <- as.matrix(expand.grid(ax[[2]], ax[[3]], ax[[4]]))
  l234 <- -(rho_tau(y[2] - g234[, 1], tau) + rho_tau(y[3] - g234[, 2], tau) + rho_tau(y[4] - g234[, 3], tau)) / sig
  c234 <- 3 * g234[, 1] - 3 * g234[, 2] + g234[, 3]                     # D theta = theta4 - 3 theta3 + 3 theta2 - theta1 = c234 - theta1
  S0 <- 0; S1 <- numeric(n); S2 <- numeric(n); mx <- -Inf
  lp_all <- function(t1) l234 - rho_tau(y[1] - t1, tau) / sig - lam * abs(c234 - t1)
  for (t1 in ax[[1]]) mx <- max(mx, max(lp_all(t1)))
  for (t1 in ax[[1]]) { w <- exp(lp_all(t1) - mx); S0 <- S0 + sum(w)
    S1 <- S1 + c(t1 * sum(w), colSums(g234 * w)); S2 <- S2 + c(t1^2 * sum(w), colSums(g234^2 * w)) }
  m <- S1 / S0; list(m = m, s = sqrt(S2 / S0 - m^2))
}
for (cl in list(list(tau = 0.9, lam = 5, sig = 0.3), list(tau = 0.5, lam = 5, sig = 0.3))) {
  ex <- exact(cl$tau, cl$lam, cl$sig); ex2 <- exact(cl$tau, cl$lam, cl$sig, G = 120)
  set.seed(1); g <- run_gibbs_frozen(y, rep(0, n), cl$tau, cl$lam, cl$sig, y, burn = 5000, keep = 400000, thin = 1, return_draws = TRUE)
  set.seed(2); p <- run_frozen(y, rep(0, n), cl$tau, cl$lam, cl$sig, y, burn = 10000, keep = 600000, thin = 1, return_draws = TRUE)
  sg <- apply(g$draws, 2, bm_se); sp <- apply(p$draws, 2, bm_se)
  cat(sprintf("\ntau %.1f lambda %g: grid G=160 vs G=120 max |diff| in sd %.4f\n", cl$tau, cl$lam, max(abs(ex$m - ex2$m) / ex$s)))
  cat("  exact mean ", sprintf("%8.4f", ex$m), "\n  Gibbs mean ", sprintf("%8.4f", colMeans(g$draws)), "  z vs exact:", sprintf("%6.2f", (colMeans(g$draws) - ex$m) / sg), "\n")
  cat("  P-MALA mean", sprintf("%8.4f", colMeans(p$draws)), "  z vs exact:", sprintf("%6.2f", (colMeans(p$draws) - ex$m) / sp), "\n")
  cat("  sd ratio Gibbs ", sprintf("%.4f", apply(g$draws, 2, sd) / ex$s), " P-MALA ", sprintf("%.4f", apply(p$draws, 2, sd) / ex$s), "\n")
}
