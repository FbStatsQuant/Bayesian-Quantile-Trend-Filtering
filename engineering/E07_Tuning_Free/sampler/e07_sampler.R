# =============================================================================
# E-07 tuning-free individual BQTF sampler (k = 2). An Engineering copy; the paper sampler is not modified.
#
# Model (the paper's): ALD(tau, sigma) working likelihood with Kozumi-Kobayashi z-augmentation; Laplace(lambda) prior on
# D^3 theta (flat on quadratics) written as a normal scale mixture with s_j ~ Exp(lambda^2/2); lambda ~ Gamma(a0, b0);
# sigma ~ IG(a_s, b_s) (Option P) or sigma fixed (Option F).
#
# Sweep (PROPOSAL items 1, 2, 4):
#   1. s | theta, lambda          1/s_j exact inverse Gaussian (clamp-free)
#   2. theta | z, s, lambda, sigma   the "theta move" (see below)
#   3. sigma | theta (P only)     IG(a_s + n, b_s + sum rho_tau(y - theta)), z integrated out; then z | theta, sigma (exact)
#   4. lambda | theta             conjugate Gamma(a0 + m, b0 + ||D theta||_1)
#   5. collapsed (lambda, theta) | t, z, sigma, with t_j = lambda^2 s_j ~ Exp(1/2) held fixed: slice-sample log lambda from
#        log p = (a0 + m) eta - b0 e^eta - 1/2 log det P(eta) + 1/2 r'W P^{-1} W r,   P = W + e^{2 eta} D' diag(1/t) D,
#      then theta | lambda, t, z exact (Knorr-Held & Rue 2002 block update; replaces the paper's ASIS).
# theta moves (step 2):
#   "exact"  : theta ~ N(P^{-1} W r, P^{-1}): the preconditioned-Langevin (OU) move with the exact metric P at step h = 2
#              (implicit midpoint), acceptance 1
#   "pcn"    : the same family at h < 2: theta' = mu + r_pcn (theta - mu) + sqrt(1 - r_pcn^2) (x - mu), x ~ N(mu, P^{-1});
#              reversible for N(mu, P^{-1}), acceptance 1
#   "hybrid" : the paper's P-MALA move (curvature metric, ADMM prox, MH, step size adapted in warm-up only) as step 2
#              (step 5 still draws theta exactly, as its validity requires)
# S0 (2026-11-23): diagnostics from the posterior package (bulk/folded Rhat, bulk and tail ESS), NA = not converged, one fixed
# stored-theta stride with iteration indices, dispersed theta starts, cap hits flagged.
# Defaults (PROPOSAL items 3, 5): y standardised by s_y = 1.4826 MAD(D^3 y)/sqrt(20); lambda ~ Gamma(2, n^{-5/2}),
# sigma ~ IG(0.1, 0.1) on the standardised scale; 4 chains from lambda0 = m x {1e-2, 1, 1e2, 1e4}, theta0 = y; blocks of 1000
# sweeps, first half discarded; stop when rank-normalised split-Rhat <= 1.01 and bulk ESS >= 400 for every monitored scalar.
# =============================================================================
e07_load <- function(dir = Sys.getenv("E07_DIR", "/home/fb31/Bayesian-Quantile-Trend-Filtering/engineering/E07_Tuning_Free/sampler"),
                     cache = Sys.getenv("E07_CACHE", file.path(tempdir(), "e07cache"))) {
  dir.create(cache, recursive = TRUE, showWarnings = FALSE)
  Rcpp::sourceCpp(file.path(dir, "e07_banded.cpp"), cacheDir = cache, env = globalenv())
}
rho_tau <- function(u, tau) u * (tau - (u < 0))
D3 <- function(theta) diff(theta, differences = 3L)
rinvg <- function(n, mu, lam) { yv <- rnorm(n)^2; phi <- mu * yv / (2 * lam); xv <- mu / (1 + phi + sqrt(phi * (phi + 2)))
  ifelse(runif(n) <= mu / (mu + xv), xv, mu * (mu / xv)) }
draw_z_exact <- function(e, tau, sigma) { q <- tau * (1 - tau); ae <- abs(e); z <- numeric(length(e)); zero <- ae < 1e-300
  if (any(!zero)) z[!zero] <- 1 / rinvg(sum(!zero), 1 / (q * ae[!zero]), 1 / (2 * q * sigma))
  if (any(zero)) z[zero] <- 2 * q * sigma * rchisq(sum(zero), 1); z }
draw_x_exact <- function(v, lambda) { u <- lambda * abs(v); x <- numeric(length(v)); zero <- u < 1e-300      # x = 1/(lambda^2 s) = 1/t
  if (any(!zero)) x[!zero] <- rinvg(sum(!zero), 1 / u[!zero], 1)
  if (any(zero)) x[zero] <- 1 / rchisq(sum(zero), 1); x }
noise_scale <- function(y) { s <- 1.4826 * mad(D3(y), constant = 1) / sqrt(20)
  if (!is.finite(s) || s <= 0) s <- IQR(y) / 1.349
  if (!is.finite(s) || s <= 0) s <- diff(range(y)); if (!is.finite(s) || s <= 0) s <- 1; s }

# Multichain diagnostics (S0; Astra HQ review): posterior::rhat (max of rank-normalised bulk and folded split-Rhat), ess_bulk, ess_tail
# (Vehtari et al. 2021) on an iterations x chains matrix.  An undefined value is returned as NA and counts as NOT converged.
rhat_ess <- function(M) {
  r <- tryCatch(posterior::rhat(M), error = function(e) NA_real_); b <- tryCatch(posterior::ess_bulk(M), error = function(e) NA_real_)
  t <- tryCatch(posterior::ess_tail(M), error = function(e) NA_real_)
  c(rhat = if (is.finite(r)) r else NA_real_, ess = if (is.finite(b)) b else NA_real_, ess_tail = if (is.finite(t)) t else NA_real_)
}

# one sweep; st = chain state (standardised scale)
e07_sweep <- function(st, x, tau, a0, b0, a_s, b_s, sigma_fixed, move, r_pcn, P, collapsed = TRUE) {
  n <- length(x); m <- n - 3L; q <- tau * (1 - tau); psi <- (1 - 2 * tau) / q; t2 <- 2 / q
  th <- st$theta; lam <- st$lambda; sig <- st$sigma; z <- st$z
  iw <- lam^2 * draw_x_exact(D3(th), lam)                                         # 1. 1/s_j
  w <- 1 / (t2 * sig * z); r <- x - psi * z
  if (move == "exact") th <- banded_gauss_draw(w, r, iw, rnorm(n), rnorm(m))      # 2.
  else if (move == "pcn") { mu <- banded_solve_logdet(w, r, iw)$mean; xd <- banded_gauss_draw(w, r, iw, rnorm(n), rnorm(m))
    th <- mu + r_pcn * (th - mu) + sqrt(1 - r_pcn^2) * (xd - mu) }
  else if (move == "hybrid") { ps <- P$env$pmala_step(th, x, z, lam, sig, st$delta, P$cst, 2L, "curv", 1e4, NULL, 150L, TRUE, 3, 0)
    th <- ps$theta; st$acc <- ps$accept
    if (st$adapt) st$delta <- min(max(exp(log(st$delta) + st$it^(-0.6) * (exp(ps$log_alpha) - 0.5)), 1e-8), 100) }
  if (is.na(sigma_fixed)) sig <- 1 / rgamma(1, a_s + n, b_s + sum(rho_tau(x - th, tau)))   # 3. sigma | theta (z integrated out)
  z <- draw_z_exact(x - th, tau, sig); w <- 1 / (t2 * sig * z); r <- x - psi * z     #    z | theta, sigma
  lam <- rgamma(1, a0 + m, b0 + sum(abs(D3(th))))                                  # 4.
  if (collapsed) {                                                                 # 5.
    ix <- draw_x_exact(D3(th), lam); nev <- 0L
    logf <- function(eta) { o <- banded_solve_logdet(w, r, exp(2 * eta) * ix); nev <<- nev + 1L
      (a0 + m) * eta - b0 * exp(eta) - 0.5 * o$logdet + 0.5 * sum(w * r * o$mean) }
    e0 <- log(lam); y0 <- logf(e0) - rexp(1); ww <- 0.3; L <- e0 - runif(1) * ww; U <- L + ww; j <- floor(runif(1) * 20); k <- 19 - j
    while (j > 0 && logf(L) > y0) { L <- L - ww; j <- j - 1 }; while (k > 0 && logf(U) > y0) { U <- U + ww; k <- k - 1 }
    repeat { e1 <- L + runif(1) * (U - L); if (logf(e1) > y0) break; if (e1 < e0) L <- e1 else U <- e1; if (U - L < 1e-10) { e1 <- e0; break } }
    lam <- exp(e1); th <- banded_gauss_draw(w, r, lam^2 * ix, rnorm(n), rnorm(m)); st$nev <- nev
  }
  st$theta <- th; st$lambda <- lam; st$sigma <- sig; st$z <- z; st
}

# monitored scalars per sweep (standardised scale)
e07_mon <- function(st, x, tau, Qp, idx) c(loglam = log(st$lambda), logsig = log(st$sigma), logtv = log(sum(abs(D3(st$theta)))),
  chk = sum(rho_tau(x - st$theta, tau)), drop(crossprod(Qp, st$theta)), st$theta[idx])

#' Fit. y, tau (k = 2 only). sigma_mode "P" (learned) or "F" (fixed at sigma_F, raw units).
#'   standardize = TRUE uses the default priors on y/s_y; FALSE uses the given raw-scale priors (G0 same-target tests).
#'   fixed_sweeps: if set, run exactly this many sweeps per chain (first half warm-up) instead of the stopping rule.
bqtf_tf <- function(y, tau, sigma_mode = c("P", "F"), sigma_F = NA, move = c("exact", "pcn", "hybrid"), r_pcn = 1 / 3,
                    standardize = TRUE, a0 = 2, c_b0 = 1, b0 = NULL, a_s = 0.1, b_s = NULL, chains = 4L,
                    lambda0_mult = c(1e-2, 1, 1e2, 1e4), block = 1000L, max_sweeps = 50000L, rhat_max = 1.01, ess_min = 400,
                    fixed_sweeps = NULL, keep_max = 1000L, collapsed = TRUE, paper_env = NULL, verbose = FALSE) {
  sigma_mode <- match.arg(sigma_mode); move <- match.arg(move); t0 <- proc.time()[["elapsed"]]
  n <- length(y); m <- n - 3L
  if (standardize) { ctr <- median(y); sc <- noise_scale(y) } else { ctr <- 0; sc <- 1 }
  x <- (y - ctr) / sc
  if (is.null(b0)) b0 <- c_b0 * n^(-5 / 2)                       # standardised scale (raw rate = s_y n^-5/2)
  if (is.null(b_s)) b_s <- 0.1
  sig_fix <- if (sigma_mode == "F") sigma_F / sc else NA
  P <- if (move == "hybrid") list(env = paper_env, cst = paper_env$ald_const(tau)) else NULL
  u <- seq_len(n) / n; Qp <- qr.Q(qr(cbind(1, u, u^2))); idx <- unique(pmax(1L, round(n * (1:9) / 10)))
  sig0 <- if (is.na(sig_fix)) mean(rho_tau(x - median(x), tau)) else sig_fix
  chains <- min(chains, length(lambda0_mult))
  th0 <- list(x, stats::smooth.spline(u, x)$y, x + rnorm(n, 0, sd(x) / 2), rep(median(x), n))       # dispersed theta starts (S0)
  ST <- lapply(seq_len(chains), function(cc) list(theta = th0[[(cc - 1L) %% 4L + 1L]], lambda = m * lambda0_mult[cc], sigma = sig0, z = rep(sig0, n),
                                                  delta = 0.2, adapt = TRUE, it = 0L, acc = NA, nev = 0L))
  stride <- max(1L, as.integer(ceiling(max_sweeps * n / 5e6)))                                     # ONE fixed stored-theta stride (S0)
  if (!is.null(fixed_sweeps)) stride <- max(1L, as.integer(ceiling(fixed_sweeps * n / 5e6)))
  MON <- vector("list", chains); THs <- vector("list", chains); ITs <- vector("list", chains); nev_tot <- 0
  total <- 0L; done <- FALSE; diag <- NULL
  while (!done) {
    nb <- if (!is.null(fixed_sweeps)) fixed_sweeps else block
    for (cc in seq_len(chains)) {
      mon <- matrix(NA_real_, nb, 4L + 3L + length(idx)); th_keep <- matrix(NA_real_, nb, n); it_keep <- integer(nb)
      for (i in seq_len(nb)) {
        ST[[cc]]$it <- ST[[cc]]$it + 1L
        ST[[cc]]$adapt <- (ST[[cc]]$it <= (total + nb) / 2)       # hybrid: adapt the P-MALA step in the warm-up half only
        ST[[cc]] <- e07_sweep(ST[[cc]], x, tau, a0, b0, a_s, b_s, sig_fix, move, r_pcn, P, collapsed)
        mon[i, ] <- e07_mon(ST[[cc]], x, tau, Qp, idx); nev_tot <- nev_tot + ST[[cc]]$nev
        if (ST[[cc]]$it %% stride == 0L) { th_keep[i, ] <- ST[[cc]]$theta; it_keep[i] <- ST[[cc]]$it }
      }
      MON[[cc]] <- rbind(MON[[cc]], mon); keep_rows <- it_keep > 0L
      THs[[cc]] <- rbind(THs[[cc]], th_keep[keep_rows, , drop = FALSE]); ITs[[cc]] <- c(ITs[[cc]], it_keep[keep_rows])
    }
    total <- total + nb
    post <- (total %/% 2 + 1L):total
    if (!is.na(sig_fix)) { cols <- setdiff(seq_len(ncol(MON[[1]])), 2L) } else cols <- seq_len(ncol(MON[[1]]))
    diag <- t(sapply(cols, function(j) rhat_ess(sapply(MON, function(M) M[post, j]))))
    ok <- !anyNA(diag) && all(diag[, "rhat"] <= rhat_max) && all(diag[, "ess"] >= ess_min) && all(diag[, "ess_tail"] >= ess_min)
    if (verbose) cat(sprintf("sweeps %d: max Rhat %.3f min bulk ESS %.0f min tail ESS %.0f\n", total, max(diag[, "rhat"]), min(diag[, "ess"]), min(diag[, "ess_tail"])))
    done <- !is.null(fixed_sweeps) || ok || total >= max_sweeps
  }
  # posterior summaries from the second half of every chain (theta history is thinned uniformly, so take its second half)
  # post-warm-up theta draws by iteration index (second half), all at the same stride
  TH <- do.call(rbind, lapply(seq_along(THs), function(cc) THs[[cc]][ITs[[cc]] > total %/% 2, , drop = FALSE]))
  TH <- ctr + sc * TH
  lam <- unlist(lapply(MON, function(M) exp(M[post, 1]))) / sc; sig <- unlist(lapply(MON, function(M) exp(M[post, 2]))) * sc
  secs <- proc.time()[["elapsed"]] - t0
  list(mean = colMeans(TH), median = apply(TH, 2, median), lo = apply(TH, 2, quantile, 0.025), hi = apply(TH, 2, quantile, 0.975),
       lambda = lam, sigma = sig, sweeps = total, chains = chains, converged = ok, cap_hit = !ok && is.null(fixed_sweeps),
       rhat_max = max(diag[, "rhat"]), ess_min = min(diag[, "ess"]), ess_tail_min = min(diag[, "ess_tail"]), ess_loglam = diag[1, "ess"],
       diag = diag, stride = stride, seconds = secs,
       slice_evals_per_sweep = nev_tot / (total * chains), s_y = sc, center = ctr, b0_raw = b0 * sc, sigma_mode = sigma_mode, move = move,
       draws = TH)
}

# Option F plug-in (PROPOSAL section 3): sigma_F = c tau(1-tau) max_u s_hat(u), Hendricks-Koenker sparsity of the pilot residuals on
# (1, u, u^2) at tau +- h (Hall-Sheather bandwidth).  Abstains (NA) when n * min(tau - h, 1 - tau - h) < 5 or the sparsity is not positive.
sigma_plugin <- function(y, tau, pilot, c_F = 2, min_tail = 5) {
  n <- length(y); u <- seq_len(n) / n; e <- y - pilot; X <- cbind(1, u, u^2)
  h <- n^(-1 / 3) * qnorm(0.975)^(2 / 3) * (1.5 * dnorm(qnorm(tau))^2 / (2 * qnorm(tau)^2 + 1))^(1 / 3)
  if (n * min(tau - h, 1 - tau - h) < min_tail) return(list(sigma = NA_real_, h = h, reason = "too few tail observations"))
  bp <- quantreg::rq.fit(X, e, tau = tau + h)$coefficients; bm <- quantreg::rq.fit(X, e, tau = tau - h)$coefficients
  s_hat <- drop(X %*% (bp - bm)) / (2 * h)
  if (any(!is.finite(s_hat)) || max(s_hat) <= 0) return(list(sigma = NA_real_, h = h, reason = "non-positive sparsity"))
  list(sigma = c_F * tau * (1 - tau) * max(s_hat), h = h, reason = "ok", s_max = max(s_hat))
}
