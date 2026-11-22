# E-04 part A3 (HQ item 4): independent reference at HIGH penalty.  n = 4 (one third difference), lambda in {1e3, 1e6}, sigma 0.3,
# tau in {0.5, 0.9}.  Exact posterior moments by quadrature in rotated coordinates theta = Q alpha + d t (Q: orthonormal basis of
# the quadratic null space; d = D'/||D||), so the Laplace term is lambda ||D|| |t| and t is gridded at the 1/lambda scale while
# alpha uses a coarse 3-d grid.  Compared with long runs of the banded Gibbs sampler (production and exact latents) and P-MALA,
# with batch-means MC errors.
E02_DIR <- Sys.getenv("E02_DIR", "/home/fb31/Bayesian-Quantile-Trend-Filtering/Engineering/E02_Rate_Sims")
source(file.path(E02_DIR, "e02_lib.R")); load_kernel()
bm_se <- function(v, nb = 100) { b <- floor(length(v) / nb); sd(colMeans(matrix(v[1:(b * nb)], b, nb))) / sqrt(nb) }
y <- c(0.1, 0.5, -0.2, 0.4); n <- 4; Dv <- c(-1, 3, -3, 1); cD <- sqrt(sum(Dv^2)); d <- Dv / cD
Q <- qr.Q(qr(cbind(1, (1:4) / 4, ((1:4) / 4)^2)))
exact <- function(tau, lam, sig, Ga = 90, Gt = 241) {
  a0 <- as.numeric(crossprod(Q, y)); R <- 10 * sig / min(tau, 1 - tau)
  ax <- lapply(1:3, function(k) { e <- seq(a0[k] - R, a0[k] + R, length.out = Ga + 1); (e[-1] + e[-(Ga + 1)]) / 2 })
  A <- as.matrix(expand.grid(ax)); thA <- A %*% t(Q)                     # alpha grid mapped to theta (null-space part)
  tw <- 40 / (lam * cD); te <- seq(-tw, tw, length.out = Gt + 1); tt <- (te[-1] + te[-(Gt + 1)]) / 2
  S0 <- 0; S1 <- numeric(n); S2 <- numeric(n); mx <- -Inf
  lp_t <- function(t) { th <- sweep(thA, 2, d * t, "+"); -rowSums(rho_tau(sweep(-th, 2, -y), tau)) / sig - lam * cD * abs(t) }
  for (t in tt) mx <- max(mx, max(lp_t(t)))
  for (t in tt) { th <- sweep(thA, 2, d * t, "+"); w <- exp(lp_t(t) - mx); S0 <- S0 + sum(w); S1 <- S1 + colSums(th * w); S2 <- S2 + colSums(th^2 * w) }
  m <- S1 / S0; list(m = m, s = sqrt(S2 / S0 - m^2))
}
for (cl in list(list(tau = 0.5, lam = 1e3), list(tau = 0.9, lam = 1e3), list(tau = 0.5, lam = 1e6), list(tau = 0.9, lam = 1e6))) {
  sig <- 0.3; ex <- exact(cl$tau, cl$lam, sig); ex2 <- exact(cl$tau, cl$lam, sig, Ga = 70, Gt = 181)
  set.seed(1); g <- run_gibbs_frozen(y, rep(0, n), cl$tau, cl$lam, sig, y, burn = 5000, keep = 400000, thin = 1, return_draws = TRUE)
  set.seed(1); ge <- run_gibbs_frozen(y, rep(0, n), cl$tau, cl$lam, sig, y, burn = 5000, keep = 400000, thin = 1, return_draws = TRUE, exact_latents = TRUE)
  set.seed(2); p <- run_frozen(y, rep(0, n), cl$tau, cl$lam, sig, y, burn = 10000, keep = 400000, thin = 1, return_draws = TRUE)
  zf <- function(X) (colMeans(X) - ex$m) / apply(X, 2, bm_se)
  cat(sprintf("\ntau %.1f lambda %.0e: quadrature Ga=90/Gt=241 vs 70/181 max |diff| in sd %.4f; exact sd %s\n", cl$tau, cl$lam, max(abs(ex$m - ex2$m) / ex$s), paste(sprintf("%.3f", ex$s), collapse = " ")))
  cat("  z vs exact  Gibbs(prod) ", sprintf("%6.2f", zf(g$draws)), " | Gibbs(exact latents) ", sprintf("%6.2f", zf(ge$draws)), " | P-MALA ", sprintf("%6.2f", zf(p$draws)), "\n")
  cat("  sd ratio    Gibbs(prod) ", sprintf("%.3f", apply(g$draws, 2, sd) / ex$s), " | Gibbs(exact) ", sprintf("%.3f", apply(ge$draws, 2, sd) / ex$s), " | P-MALA ", sprintf("%.3f", apply(p$draws, 2, sd) / ex$s), sprintf(" (P-MALA acc %.2f)", p$summ[["acc_post"]]), "\n")
}
