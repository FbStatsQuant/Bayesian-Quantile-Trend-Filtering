# Generalised ASIS scale move for lambda (Fable/Astra consult, HQ check 2026-11-25).
# Hold p = Q Q' theta fixed (Q: orthonormal n x q basis of a fixed subspace; q = k+1 polynomial basis = the current step),
# rescale v = theta - p:  lambda' = e^eta,  theta(eta) = p + (lambda / lambda') v.
# Group move (Liu & Sabatti 2000) on t = eta - log(lambda): Jacobian e^{t} (lambda) * e^{-t (n - q)} (v), Lebesgue Haar on t.
# Target pi(lambda', theta') with pi ∝ lambda^(a0 - 1 + m) e^{-b0 lambda - lambda ||D theta||_1} exp(-sum a (theta - r)^2 / 2), m = n - k - 1:
#   log f(eta) = (a0 + q - k - 1) eta - b0 e^eta - ||e^eta D p + lambda D v||_1 - sum a (theta(eta) - r)^2 / 2.
# With q = k + 1 (polynomial null space), D p = 0 and this is the canonical asis_step exactly.
asis_step_g <- function(theta, lambda, a, r, a0, b0, Q, ord, w = 1, max_steps = 30L, q_jac = ncol(Q)) {   # q_jac: test hook only
  n <- length(theta); q <- q_jac; k <- ord
  p <- as.numeric(Q %*% crossprod(Q, theta)); v <- theta - p
  Dp <- diff(p, differences = k + 1L); Dv <- diff(v, differences = k + 1L)
  logf <- function(eta) { lam <- exp(eta); th <- p + (lambda / lam) * v
    (a0 + q - k - 1) * eta - b0 * lam - sum(abs(lam * Dp + lambda * Dv)) - sum(a * (th - r)^2) / 2 }
  eta0 <- log(lambda); y0 <- logf(eta0) - rexp(1)
  L <- eta0 - runif(1) * w; U <- L + w; j <- floor(runif(1) * max_steps); kk <- max_steps - 1 - j
  while (j > 0 && logf(L) > y0) { L <- L - w; j <- j - 1 }
  while (kk > 0 && logf(U) > y0) { U <- U + w; kk <- kk - 1 }
  repeat { eta1 <- L + runif(1) * (U - L)
    if (logf(eta1) > y0) break
    if (eta1 < eta0) L <- eta1 else U <- eta1
    if (U - L < 1e-10) { eta1 <- eta0; break } }
  lam1 <- exp(eta1)
  list(lambda = lam1, theta = p + (lambda / lam1) * v)
}
spline_basis <- function(n, q) qr.Q(qr(splines::bs(seq_len(n) / n, df = q, intercept = TRUE)))   # cubic, contains quadratics
