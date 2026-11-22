# =============================================================================
# E-02 contraction-rate study: frozen-(lambda, sigma) BQTF posterior sampler and metrics.
#
# Target (k = 2, third differences, flat on quadratics), lambda and sigma FIXED:
#   pi(theta | y) ∝ exp{ -sum_i rho_tau(y_i - theta_i) / sigma - lambda ||D theta||_1 }
# sampled exactly by the paper's kernels: Kozumi-Kobayashi augmentation z, and the P-MALA trend move in the
# curvature metric M = W + c D'D (c = min(kappa lambda^2 / 2, c_max)) with the ADMM proximal map
# (Simulations/Individual/prox_admm_metric.cpp, unchanged).  With lambda and sigma fixed the sweep is
#   theta | z  (P-MALA, exact MH)   ->   z | theta  (inverse Gaussian, exact).
# The step size is Robbins-Monro adapted during burn-in only, then frozen: the kept chain is time-homogeneous.
# MAP = quantile trend filter with penalty lambda * sigma, solved exactly by quantreg::rq.fit.sfn (sparse interior point).
#
# Distances (theta* = true tau-quantile at the grid points u_i = i/n):
#   Delta2(delta) = n^-1 sum_i min(|delta_i|, delta_i^2)   (Padilla & Chatterjee)
#   mse(delta)    = n^-1 sum_i delta_i^2
# =============================================================================
if (dir.exists("/home/fb31/R/e02lib")) .libPaths(c("/home/fb31/R/e02lib", .libPaths()))   # Owls user library (quantreg); NOTS has it in the R module library
suppressPackageStartupMessages({ library(SparseM); library(quantreg); library(coda) })

# Paths are configurable so the same code runs on Owls and from a NOTS code snapshot (E02_DIR, E02_KERNEL, E02_CACHE).
E02_DIR  <- Sys.getenv("E02_DIR", "/home/fb31/Bayesian-Quantile-Trend-Filtering/Engineering/E02_Rate_Sims")
KERNEL   <- Sys.getenv("E02_KERNEL", "/home/fb31/Bayesian-Quantile-Trend-Filtering/Simulations/Individual/prox_admm_metric.cpp")
load_kernel <- function(cache = Sys.getenv("E02_CACHE", "/home/fb31/BQTF_runs/E02/.rcpp_cache")) {
  dir.create(cache, recursive = TRUE, showWarnings = FALSE)
  Rcpp::sourceCpp(KERNEL, cacheDir = cache, env = globalenv())                       # paper's P-MALA kernel (validation only)
  Rcpp::sourceCpp(file.path(E02_DIR, "banded_ls.cpp"), cacheDir = cache, env = globalenv())   # perturb-and-solve Gaussian draw
}

# ---- truths, noise, true quantiles -----------------------------------------
truth_f <- function(id, u) switch(id,
  quad = 1 + 0.5 * u - 1.5 * u^2,                                                   # (i) pure quadratic
  sin  = sin(2 * pi * u),                                                           # (ii) smooth, n^2 ||D^3 theta*||_1 ~ 16 pi^2
  pq   = 3 * u^2 - 6 * pmax(u - 0.3, 0)^2 + 6 * pmax(u - 0.55, 0)^2 - 6 * pmax(u - 0.8, 0)^2,  # (iii) C^1 piecewise quadratic, 3 knots
  PQT  = 0.5 * (u - 0.5)^2 + 0.5 * (8 * pmax(u - 0.3, 0)^2 - 12 * pmax(u - 0.55, 0)^2 + 6 * pmax(u - 0.8, 0)^2),  # Theory T-03 PQ (V = 26)
  stop("unknown truth"))
NOISE_SCALE <- 0.5
# noise laws: "gauss"/"t2" = scale 0.5 (Engineering default grid); "g25" = N(0, 0.25^2), "cauchy10" = Cauchy(0, 0.1) (Theory T-03)
noise_q <- function(noise, tau, s = NOISE_SCALE) switch(noise, gauss = s * qnorm(tau), t2 = s * qt(tau, 2),
  g25 = 0.25 * qnorm(tau), cauchy10 = qcauchy(tau, 0, 0.1), stop("unknown noise"))
noise_r <- function(noise, n, s = NOISE_SCALE) switch(noise, gauss = s * rnorm(n), t2 = s * rt(n, 2),
  g25 = 0.25 * rnorm(n), cauchy10 = rcauchy(n, 0, 0.1), stop("unknown noise"))
noise_d <- function(noise, s = NOISE_SCALE) switch(noise, gauss = function(e) dnorm(e, 0, s), t2 = function(e) dt(e / s, 2) / s,
  g25 = function(e) dnorm(e, 0, 0.25), cauchy10 = function(e) dcauchy(e, 0, 0.1), stop("unknown noise"))
rho_tau <- function(u, tau) u * (tau - (u < 0))
# sigma0 = E rho_tau(eps - q_tau): the pseudo-true ALD scale (KL projection).  Infinite for Cauchy (no first moment): there
# sigma is chosen to match the Gaussian arm's curvature kappa = f(q_tau)/sigma (see kappa_eff), as agreed with Theory.
sigma0 <- function(noise, tau, s = NOISE_SCALE) {
  if (noise == "cauchy10") return(noise_d("cauchy10")(noise_q("cauchy10", tau)) / kappa_eff("g25", tau))
  q <- noise_q(noise, tau, s); dens <- noise_d(noise, s)
  integrate(function(e) rho_tau(e - q, tau) * dens(e), -Inf, Inf, rel.tol = 1e-10)$value
}
kappa_eff <- function(noise, tau) noise_d(noise)(noise_q(noise, tau)) / sigma0(noise, tau)   # f(F^-1(tau)) / sigma
make_data <- function(truth, noise, tau, n, seed) {
  RNGkind("Mersenne-Twister", "Inversion", "Rejection"); set.seed(seed)
  u <- seq_len(n) / n; f <- truth_f(truth, u)
  y <- f + noise_r(noise, n)
  list(u = u, y = y, theta_star = f + noise_q(noise, tau), n = n, truth = truth, noise = noise, tau = tau, seed = seed)
}

# ---- distances ----------------------------------------------------------------
Delta2 <- function(d) mean(pmin(abs(d), d^2))
mse    <- function(d) mean(d^2)
D3     <- function(theta) diff(theta, differences = 3L)

# ---- exact MAP: quantile trend filter, penalty Lam = lambda * sigma ---------------
# min_theta sum rho_tau(y - theta) + Lam ||D theta||_1, as one sparse quantile regression:
# rows I (response y), Lam*D and -Lam*D (response 0); rho_tau(v) + rho_tau(-v) = |v| for the penalty rows.
qtf_map <- function(y, tau, Lam) {
  n <- length(y); m <- n - 3L; st <- c(-1, 3, -3, 1)
  ra <- c(rep(1, n), rep(Lam * st, m), rep(-Lam * st, m))
  ja <- c(seq_len(n), rep(0:3, m) + rep(seq_len(m), each = 4), rep(0:3, m) + rep(seq_len(m), each = 4))
  ia <- c(seq_len(n), n + 1L + 4L * (0:(2L * m)))
  X <- new("matrix.csr", ra = ra, ja = as.integer(ja), ia = as.integer(ia), dimension = as.integer(c(n + 2L * m, n)))
  yy <- c(y, rep(0, 2L * m))
  nnz <- length(ra)
  fit <- rq.fit.sfn(X, yy, tau = tau, control = list(tmpmax = max(1e5, 60 * n), nnzlmax = max(1e6, 40 * nnz), small = 1e-8))
  as.numeric(fit$coef)
}
qtf_obj <- function(theta, y, tau, Lam) sum(rho_tau(y - theta, tau)) + Lam * sum(abs(D3(theta)))

# MAP by majorize-minimize (IRLS) with a decreasing smoothing eps; robust at any Lam (quantreg's interior point breaks
# down for Lam >~ 1e6 on this scale).  Majorizers at the current point (e0 = y - theta0, v0 = D theta0):
#   rho_tau(e) <= e^2 / (4|e0|) + (tau - 1/2) e + |e0| / 4,   |v| <= v^2 / (2|v0|) + |v0| / 2,
# so each step is the banded weighted least squares  argmin sum w (theta - r)^2 / 2 + sum iw v^2 / 2  with
#   w = 1 / (2 max(|e0|, eps)),  r = y + (2 tau - 1) max(|e0|, eps),  iw = Lam / max(|v0|, eps_v),
# solved by the same stable banded QR (banded_gauss_draw with zero noise).  The objective is monotone for each fixed eps.
qtf_map_mm <- function(y, tau, Lam, theta0 = NULL, eps_seq = 10^seq(-3, -11, by = -1), iters_per = 200L, tol = 1e-13) {
  n <- length(y); m <- n - 3L; sy <- sd(y)
  th <- if (is.null(theta0) || any(!is.finite(theta0))) rep(median(y), n) else theta0
  z1 <- numeric(n); z2 <- numeric(m)
  for (eps in eps_seq) {
    ee <- eps * sy; ev <- eps * sy / n^3
    fold <- Inf
    for (k in seq_len(iters_per)) {
      e0 <- pmax(abs(y - th), ee); v0 <- pmax(abs(D3(th)), ev)
      th <- banded_gauss_draw(1 / (2 * e0), y + (2 * tau - 1) * e0, Lam / v0, z1, z2)
      f <- qtf_obj(th, y, tau, Lam)
      if (abs(fold - f) <= tol * abs(f)) break
      fold <- f
    }
  }
  th
}
# MAP used in the study: the better (lower objective) of quantreg's sparse interior point and the MM solution started from it.
qtf_map_best <- function(y, tau, Lam) {
  rq <- tryCatch(suppressWarnings(qtf_map(y, tau, Lam)), error = function(e) rep(NA_real_, length(y)))
  cand <- list(rq = rq, mm_cold = qtf_map_mm(y, tau, Lam))
  if (all(is.finite(rq))) cand$mm_warm <- qtf_map_mm(y, tau, Lam, theta0 = rq)
  f <- sapply(cand, function(x) if (all(is.finite(x))) qtf_obj(x, y, tau, Lam) else Inf)
  i <- which.min(f)
  structure(cand[[i]], solver = names(cand)[i], f = f)
}

# Theory T-03 M2: total spread = n^-1 sum_i Var_post(theta_i); rough spread = the same after removing, from each centred draw,
# its least-squares quadratic (projection onto span{1, u, u^2}).  Computed from the thinned draw matrix TH (draws x n).
spread_decomp <- function(TH) {
  n <- ncol(TH); C <- sweep(TH, 2, colMeans(TH))
  X <- qr.Q(qr(cbind(1, seq_len(n) / n, (seq_len(n) / n)^2)))     # orthonormal basis of quadratics
  R <- C - (C %*% X) %*% t(X)
  dof <- nrow(TH) - 1
  c(total = sum(C^2) / (dof * n), rough = sum(R^2) / (dof * n))
}

# ---- frozen-hyperparameter sampler ---------------------------------------------------
ald_const <- function(tau) list(psi = (1 - 2 * tau) / (tau * (1 - tau)), t2 = 2 / (tau * (1 - tau)))
rinvgauss <- function(n, mu, lam) {
  # Michael, Schucany & Haas (1976) in an overflow/cancellation-safe form: with phi = mu y / (2 lam),
  # the smaller root mu (1 + phi - sqrt(phi^2 + 2 phi)) equals mu / (1 + phi + sqrt(phi^2 + 2 phi)).  Same distribution.
  yv <- rnorm(n)^2; phi <- mu * yv / (2 * lam)
  xv <- mu / (1 + phi + sqrt(phi * (phi + 2)))
  ifelse(runif(n) <= mu / (mu + xv), xv, mu * (mu / xv))
}
draw_z <- function(e, tau, sigma) {            # 1/z ~ InvGauss(1/(tau(1-tau)|e|), 1/(2 tau(1-tau) sigma)); paper's safeguards
  ae <- pmax(abs(e), 1e-10)
  v <- rinvgauss(length(e), 1 / (tau * (1 - tau) * ae), 1 / (2 * tau * (1 - tau) * sigma))
  pmin(pmax(1 / v, 1e-8), 1e4)
}
# Clamp-free exact latent draws (E-04 / Astra findings 1-2).  Both use the stable inverse-Gaussian generator and the exact
# zero-argument limits; no floors or caps.
#  z_i | e_i, sigma: 1/z ~ InvGauss(1/(q|e|), 1/(2 q sigma)), q = tau(1-tau); limit e -> 0: z = 2 q sigma chi^2_1.
draw_z_exact <- function(e, tau, sigma) {
  q <- tau * (1 - tau); ae <- abs(e); z <- numeric(length(e)); zero <- ae < 1e-300
  if (any(!zero)) z[!zero] <- 1 / rinvgauss(sum(!zero), 1 / (q * ae[!zero]), 1 / (2 * q * sigma))
  if (any(zero)) z[zero] <- 2 * q * sigma * rchisq(sum(zero), 1)
  z
}
#  1/s_j | v_j, lambda: with x = 1/(lambda^2 s_j), x ~ InvGauss(1/(lambda|v_j|), 1) (scale-free); limit v -> 0: lambda^2 s_j = chi^2_1.
draw_iw_exact <- function(v, lambda) {
  m <- length(v); u <- lambda * abs(v); lam2s <- numeric(m); zero <- u < 1e-300
  if (any(!zero)) lam2s[!zero] <- 1 / rinvgauss(sum(!zero), 1 / u[!zero], 1)
  if (any(zero)) lam2s[zero] <- rchisq(sum(zero), 1)
  lambda^2 / lam2s                                                     # 1/s_j
}
U_cond <- function(theta, a, r, lambda) sum(a * (theta - r)^2) / 2 + lambda * sum(abs(D3(theta)))

# Runs one chain.  Returns per-draw traces and summaries; never stores the full draw matrix.
#   lambda, sigma : frozen hyperparameters;  theta0 : start (the MAP);  thin : keep every thin-th draw for spread/intervals
run_frozen <- function(y, theta_star, tau, lambda, sigma, theta0, burn = 2000L, keep = 10000L, thin = 10L,
                       kappa = 3, c_max = 1e9, admm_iter = 150L, delta0 = 0.2, adapt_target = 0.5, verbose = FALSE, return_draws = FALSE) {
  n <- length(y); m <- n - 3L; cst <- ald_const(tau)
  c_met <- min(kappa * lambda^2 / 2, c_max)
  theta <- theta0; z <- draw_z(y - theta, tau, sigma); delta <- delta0
  nk <- keep %/% thin; TH <- matrix(NA_real_, nk, n)
  d2 <- ms <- pen <- numeric(keep); acc <- logical(burn + keep); delta_tr <- numeric(burn + keep)
  sum_th <- numeric(n); t0 <- proc.time()[["elapsed"]]
  for (it in seq_len(burn + keep)) {
    a <- 1 / (cst$t2 * sigma * z); r <- y - cst$psi * z; gamma <- delta / 2
    rho <- 0.1 * (mean(a) + c_met) / gamma
    mv <- pmala_move(theta, a, r, lambda, gamma, a, c_met, 2L, rho, admm_iter, 0, rnorm(n), delta)
    la <- U_cond(theta, a, r, lambda) - U_cond(mv$prop, a, r, lambda) + (mv$q_fwd - mv$q_rev) / (2 * delta)
    if (!is.finite(la)) la <- -Inf
    if (log(runif(1)) < la) { theta <- mv$prop; acc[it] <- TRUE }
    z <- draw_z(y - theta, tau, sigma)
    if (it <= burn) {                                   # Robbins-Monro on log delta, burn-in only
      delta <- exp(log(delta) + it^(-0.6) * (min(1, exp(la)) - adapt_target)); delta <- min(max(delta, 1e-10), 1e2)
    }
    delta_tr[it] <- delta
    if (it > burn) {
      k <- it - burn; dl <- theta - theta_star
      d2[k] <- Delta2(dl); ms[k] <- mean(dl^2); pen[k] <- lambda * sum(abs(D3(theta))) / m
      sum_th <- sum_th + theta
      if (k %% thin == 0) TH[k %/% thin, ] <- theta
    }
    if (verbose && it %% 1000 == 0) cat(sprintf("it %6d acc %.3f delta %.3e d2 %.4g\n", it, mean(acc[max(1, it - 999):it]), delta, if (it > burn) d2[it - burn] else NA))
  }
  secs <- proc.time()[["elapsed"]] - t0
  pm <- sum_th / keep
  spread <- apply(TH, 1, function(th) Delta2(th - pm))
  sp <- spread_decomp(TH)
  lo <- apply(TH, 2, quantile, 0.025); hi <- apply(TH, 2, quantile, 0.975)
  ess <- function(x) as.numeric(coda::effectiveSize(x))
  list(post_mean = pm, bands = list(lo = lo, hi = hi), sd = apply(TH, 2, sd), draws = if (return_draws) TH else NULL,
       summ = c(d2_mean = mean(d2), d2_q90 = unname(quantile(d2, 0.90)), d2_q95 = unname(quantile(d2, 0.95)),
                mse_mean = mean(ms), centre_d2 = Delta2(pm - theta_star), centre_mse = mse(pm - theta_star),
                spread_d2 = mean(spread), spread_d2_q95 = unname(quantile(spread, 0.95)),
                pen_ratio = mean(pen), ess_d2 = ess(d2), ess_spread = ess(spread), ess_mid_thinned = ess(TH[, n %/% 2]),
                acc_post = mean(acc[(burn + 1):(burn + keep)]), delta = delta, c_metric = c_met, c_capped = as.numeric(c_met < kappa * lambda^2 / 2),
                cover95 = mean(theta_star >= lo & theta_star <= hi), ciw95 = mean(hi - lo),
                total_spread = sp[["total"]], rough_spread = sp[["rough"]], d2_q90b = unname(quantile(d2, 0.90)), seconds = secs),
       trace = list(d2 = d2, pen = pen, delta = delta_tr, acc = acc))
}

# ---- exact banded Gibbs sampler for the same frozen posterior ---------------------------------------
# Laplace(rate lambda) on each (D theta)_j as a normal scale mixture: (D theta)_j | s_j ~ N(0, s_j), s_j ~ Exp(rate lambda^2/2)
# (Park & Casella 2008); ALD as Kozumi-Kobayashi mixture (z).  Full conditionals, all exact:
#   theta | z, s ~ N(Q^{-1} W r, Q^{-1}),  Q = W + D' diag(1/s) D   (perturb-and-solve, banded Givens QR, O(n); banded_ls.cpp)
#   z | theta    : as in the paper;   1/s_j | theta ~ InvGauss(lambda / |(D theta)_j|, lambda^2)
# Marginally over (z, s) the stationary law of theta is exactly pi(theta | y) above.  Joint theta draw = global moves.
.Dmat_cache <- new.env()
Dmat3 <- function(n) {
  key <- as.character(n)
  if (is.null(.Dmat_cache[[key]])) .Dmat_cache[[key]] <- Matrix::bandSparse(n - 3L, n, k = 0:3, diagonals = list(rep(-1, n - 3L), rep(3, n - 3L), rep(-3, n - 3L), rep(1, n - 3L)))
  .Dmat_cache[[key]]
}
# Learned-lambda option (sigma still fixed): lambda ~ Gamma(a0, rate b0) a priori.  After the z draw:
#   lambda | theta ~ Gamma(a0 + m, b0 + ||D theta||_1)  (s integrated out), then the paper's ancillary interweaving redraw
#   of (lambda, theta) given z (asis_step, Yu & Meng 2011), then s | theta, lambda at the top of the next sweep.
#   Partially collapsed but valid: s is always redrawn from its full conditional before it is used again.
asis_step <- function(theta, lambda, a, r, a0, b0, Q, w = 1, max_steps = 30L) {   # verbatim from the paper's sampler
  th_par <- Q %*% crossprod(Q, theta); th_perp <- theta - th_par
  logf <- function(eta) { lam <- exp(eta); th <- th_par + (lambda / lam) * th_perp
    a0 * eta - b0 * lam - sum(a * (th - r)^2) / 2 }
  eta0 <- log(lambda); y0 <- logf(eta0) - rexp(1)
  L <- eta0 - runif(1) * w; U <- L + w; j <- floor(runif(1) * max_steps); kk <- max_steps - 1 - j
  while (j > 0 && logf(L) > y0) { L <- L - w; j <- j - 1 }
  while (kk > 0 && logf(U) > y0) { U <- U + w; kk <- kk - 1 }
  repeat { eta1 <- L + runif(1) * (U - L)
    if (logf(eta1) > y0) break
    if (eta1 < eta0) L <- eta1 else U <- eta1
    if (U - L < 1e-10) { eta1 <- eta0; break } }
  lam1 <- exp(eta1)
  list(lambda = lam1, theta = as.numeric(th_par + (lambda / lam1) * th_perp))
}
run_gibbs_frozen <- function(y, theta_star, tau, lambda, sigma, theta0, burn = 1000L, keep = 5000L, thin = 5L,
                             iw_cap = 1e6, verbose = FALSE, learn_lambda = FALSE, a0 = 1, b0 = 1, asis = TRUE,
                             learn_sigma = FALSE, a_sigma = 0.1, b_sigma = 0.1, sigma0_init = sigma, lam_steps = 1L, twin = FALSE, return_draws = FALSE, exact_latents = TRUE) {
  # exact_latents = TRUE: clamp-free z and 1/s draws (draw_z_exact, draw_iw_exact); FALSE: the production draws with the paper's
  # safeguards (z in [1e-8, 1e4], |e| >= 1e-10) and the 1/s cap iw_cap * lambda^2.  Clamp hits are counted in both cases.
  # twin = TRUE: the "Gaussian twin" (Theory, statement v2): scale-mixture variances frozen at t_j = 2/lambda^2, i.e. a Gaussian
  # prior on D theta with the Laplace(lambda) variance; same ALD likelihood and z-augmentation.
  # lam_steps: number of (conjugate lambda | theta, ASIS (lambda, theta) | z) pairs per sweep; each pair leaves the target invariant.
  # learn_sigma: sigma ~ IG(a_sigma, b_sigma) as in the paper; sigma | theta, z ~ IG(a_sigma + 3n/2, b_sigma + sum z +
  # sum (y - theta - psi z)^2 / (2 t2 z)) drawn after the lambda block (the paper's order theta, z, lambda, sigma).
  # iw_cap: 1/s_j <= iw_cap * lambda^2 (the natural scale of 1/s_j is lambda^2); a negligible truncation that keeps Q
  # factorisable when (D theta)_j is exactly 0 (the MAP start) or vanishingly small.
  n <- length(y); m <- n - 3L; cst <- ald_const(tau); iw_max <- iw_cap * lambda^2
  theta <- theta0; z <- draw_z(y - theta, tau, sigma)
  nk <- keep %/% thin; TH <- matrix(NA_real_, nk, n)
  d2 <- ms <- pen <- numeric(keep); sum_th <- numeric(n); t0 <- proc.time()[["elapsed"]]
  lam_tr <- rep(lambda, burn + keep); sig_tr <- rep(sigma, burn + keep); hits_z <- 0; hits_iw <- 0
  idx3 <- unique(pmax(1L, round(n * c(0.25, 0.5, 0.75)))); th3 <- matrix(NA_real_, keep, length(idx3))
  Qn <- if (learn_lambda && asis) qr.Q(qr(cbind(1, seq_len(n) / n, (seq_len(n) / n)^2))) else NULL
  for (it in seq_len(burn + keep)) {
    v <- D3(theta)
    iw <- if (twin) rep(lambda^2 / 2, m) else if (exact_latents) draw_iw_exact(v, lambda) else {
      iw_raw <- rinvgauss(m, lambda / pmax(abs(v), lambda / iw_max), lambda^2); hits_iw <- hits_iw + sum(iw_raw > iw_max | abs(v) < lambda / iw_max); pmin(iw_raw, iw_max) }
    w <- 1 / (cst$t2 * sigma * z); r <- y - cst$psi * z
    theta <- banded_gauss_draw(w, r, iw, rnorm(n), rnorm(m))                             # exact N(Q^{-1} W r, Q^{-1})
    if (exact_latents) z <- draw_z_exact(y - theta, tau, sigma) else {
      ez <- y - theta; z_raw <- 1 / rinvgauss(n, 1 / (tau * (1 - tau) * pmax(abs(ez), 1e-10)), 1 / (2 * tau * (1 - tau) * sigma))
      hits_z <- hits_z + sum(z_raw < 1e-8 | z_raw > 1e4 | abs(ez) < 1e-10); z <- pmin(pmax(z_raw, 1e-8), 1e4) }
    if (learn_lambda) {
      w <- 1 / (cst$t2 * sigma * z); r <- y - cst$psi * z
      for (ls in seq_len(lam_steps)) {
        lambda <- rgamma(1, a0 + m, b0 + sum(abs(D3(theta))))
        if (asis) { as_ <- asis_step(theta, lambda, w, r, a0, b0, Qn); lambda <- as_$lambda; theta <- as_$theta }
      }
      iw_max <- iw_cap * lambda^2; lam_tr[it] <- lambda
    }
    if (learn_sigma) {
      ss <- sum((y - theta - cst$psi * z)^2 / (2 * cst$t2 * z)) + sum(z)
      sigma <- 1 / rgamma(1, shape = a_sigma + 1.5 * n, rate = b_sigma + ss); sig_tr[it] <- sigma
    }
    if (it > burn) {
      k <- it - burn; dl <- theta - theta_star
      d2[k] <- Delta2(dl); ms[k] <- mean(dl^2); pen[k] <- lambda * sum(abs(D3(theta))) / m
      sum_th <- sum_th + theta; th3[k, ] <- theta[idx3]
      if (k %% thin == 0) TH[k %/% thin, ] <- theta
    }
    if (verbose && it %% 1000 == 0) cat(sprintf("it %6d d2 %.4g\n", it, if (it > burn) d2[it - burn] else NA))
  }
  secs <- proc.time()[["elapsed"]] - t0
  pm <- sum_th / keep
  spread <- apply(TH, 1, function(th) Delta2(th - pm))
  sp <- spread_decomp(TH)
  lo <- apply(TH, 2, quantile, 0.025); hi <- apply(TH, 2, quantile, 0.975)
  ess <- function(x) as.numeric(coda::effectiveSize(x))
  list(post_mean = pm, sd = apply(TH, 2, sd),
       summ = c(d2_mean = mean(d2), d2_q90 = unname(quantile(d2, 0.90)), d2_q95 = unname(quantile(d2, 0.95)),
                mse_mean = mean(ms), centre_d2 = Delta2(pm - theta_star), centre_mse = mse(pm - theta_star),
                spread_d2 = mean(spread), spread_d2_q95 = unname(quantile(spread, 0.95)),
                pen_ratio = mean(pen), ess_d2 = ess(d2), ess_spread = ess(spread), ess_mid_thinned = ess(TH[, n %/% 2]),
                acc_post = 1, delta = NA, c_metric = NA, c_capped = NA,
                cover95 = mean(theta_star >= lo & theta_star <= hi), ciw95 = mean(hi - lo),
                total_spread = sp[["total"]], rough_spread = sp[["rough"]], d2_q90b = unname(quantile(d2, 0.90)),
                lam_mean = mean(lam_tr[(burn + 1):(burn + keep)]), lam_median = median(lam_tr[(burn + 1):(burn + keep)]),
                ess_loglam = if (learn_lambda) ess(log(lam_tr[(burn + 1):(burn + keep)])) else NA,
                lam_drift = if (learn_lambda) { h <- lam_tr[(burn + 1):(burn + keep)]; k2 <- length(h) %/% 2; log(mean(h[-(1:k2)]) / mean(h[1:k2])) } else NA,
                sig_mean = mean(sig_tr[(burn + 1):(burn + keep)]), ess_sigma = if (learn_sigma) ess(sig_tr[(burn + 1):(burn + keep)]) else NA,
                ess_theta_min = min(apply(th3, 2, ess)), ess_theta_med = median(apply(th3, 2, ess)),
                clamp_rate_z = hits_z / ((burn + keep) * n), clamp_rate_iw = hits_iw / ((burn + keep) * m),
                seconds = secs),
       bands = list(lo = lo, hi = hi), draws = if (return_draws) TH else NULL,
       trace = list(d2 = d2, pen = pen, lambda = if (learn_lambda) lam_tr else NULL, sigma = if (learn_sigma) sig_tr else NULL, theta3 = th3))
}

# ---- one cell replicate: data -> MAP -> chain -> summary row --------------------------------
run_rep <- function(truth, noise, tau, n, seed, Lam_fun, sigma_mode = "sigma0", ..., save_dir = NULL) {
  dat <- make_data(truth, noise, tau, n, seed)
  sig <- if (sigma_mode == "sigma0") sigma0(noise, tau) else 1
  Lam <- Lam_fun(n)                                   # lambda * sigma
  lam <- Lam / sig
  t0 <- proc.time()[["elapsed"]]; map <- qtf_map_best(dat$y, tau, Lam); t_map <- proc.time()[["elapsed"]] - t0
  set.seed(seed + 1000L)
  ch <- run_frozen(dat$y, dat$theta_star, tau, lam, sig, map, ...)
  row <- data.frame(truth = truth, noise = noise, tau = tau, n = n, seed = seed, sigma_mode = sigma_mode, sigma = sig,
                    lambda = lam, Lam = Lam, map_d2 = Delta2(map - dat$theta_star), map_mse = mse(map - dat$theta_star),
                    map_pen_ratio = lam * sum(abs(D3(map))) / (n - 3), pm_vs_map_d2 = Delta2(ch$post_mean - map),
                    t_map = t_map, t(ch$summ))
  if (!is.null(save_dir)) {
    dir.create(save_dir, recursive = TRUE, showWarnings = FALSE)
    saveRDS(list(row = row, trace = ch$trace, post_mean = ch$post_mean, map = map),
            file.path(save_dir, sprintf("%s_%s_t%03d_n%05d_s%03d.rds", truth, noise, round(100 * tau), n, seed)))
  }
  row
}

# ---- Theory statement v2: spline-smoother comparator (post-processing only) --------------------------------------------
# S = kappa (kappa I + (lambda^2/2) D'D)^{-1}, kappa = f_eps(q_tau)/sigma.  Bias of the posterior mean is predicted to equal the
# bias of S: bias2 = n^-1 ||S theta* - theta*||^2 (deterministic).  Also the spline's error on the actual data, n^-1 ||S y - theta*||^2.
# One banded solve each, by the stable QR (banded_gauss_draw with zero noise solves (kappa I + (lambda^2/2) D'D) th = kappa r).
spline_smooth <- function(r, kappa, lambda) {
  n <- length(r); banded_gauss_draw(rep(kappa, n), r, rep(lambda^2 / 2, n - 3L), numeric(n), numeric(n - 3L))
}
spline_bias <- function(theta_star, y, kappa, lambda) {
  c(spline_bias2 = mse(spline_smooth(theta_star, kappa, lambda) - theta_star),
    spline_err_mse = mse(spline_smooth(y, kappa, lambda) - theta_star))
}
