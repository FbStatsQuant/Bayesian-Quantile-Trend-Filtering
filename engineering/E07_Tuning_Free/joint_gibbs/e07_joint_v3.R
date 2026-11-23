# =============================================================================
# E-07 joint v3 (design change 2026-11-23): joint non-crossing exact sampler for ordered quantile trends (k = 2). Copy of e07_joint.R (v1) with
#   - theta_j moved by EXACT REFLECTIVE HMC for the box-truncated Gaussian N(mu, P^-1) on [theta_{j-1}, theta_{j+1}] (Pakman & Paninski 2014;
#     banded_rhmc in e07_banded_v3.cpp, T = pi/2, no accept step, no bounce cap), replacing pCN and the collapsed accept-iff-in-box block;
#   - optional stack-shift Gibbs block (Fable Idea 3) once per sweep after all levels (stack = TRUE);
#   - the T-block in the box (Fable Idea 2) is kept as an option (tblock = TRUE) but is DROPPED by design (wall-limited).
# Target: product over levels of the individual augmented posteriors restricted to theta_1 <= ... <= theta_J pointwise.
# Per sweep, per level j (increasing order; box B_j = [theta_{j-1}, theta_{j+1}] from the latest values):
#  1. 1/s_j | theta_j, lambda_j exact (box-free).
#  2. theta_j | s_j, z_j, lambda_j, sigma_j, box ~ N(mu, P^-1) restricted to the box: reflective HMC (theta_move = "rhmc"), or v1 pCN ("pcn").
#  3. sigma_j | theta_j (z integrated out), then z_j | theta_j, sigma_j exact.
#  4. lambda_j | theta_j ~ Gamma(a0 + m, b0 + ||D3 theta_j||_1).
#  5. T-block in the box: x = 1/t ~ InvGauss given (theta_j, lambda_j); with w, r at the current (z_j, sigma_j),
#       P(eta) = diag(w) + e^{2 eta} D' diag(x) D = R'R, mu(eta) = P^-1 W r, omega = R(eta0)(theta - mu(eta0)),
#       theta(omega, eta) = mu(eta) + R(eta)^-1 omega.  Slice-sample eta' | omega from
#       f(eta) = (a0+m) eta - b0 e^eta - 1/2 logdet P(eta) + 1/2 (w r)' mu(eta) + log 1{theta(omega, eta) in B_j}
#       (fixed width 0.3, fixed step limits 20: reversible).  lambda_j = e^eta', theta_j = theta(omega, eta').  Exact Gibbs, no rejection.
# After all levels (stack-shift): x_j ~ InvGauss | (theta_j, lambda_j) fresh, iw_j = lambda_j^2 x_j, P_j = diag(w_j) + D' diag(iw_j) D,
#   Delta ~ N(P_S^-1 b, P_S^-1), P_S = sum_j P_j, b = sum_j [W_j (r_j - theta_j) - D' diag(iw_j) D theta_j];  theta_j <- theta_j + Delta all j.
# =============================================================================
.e07j_dir <- Sys.getenv("E07_DIR", "/home/fb31/Bayesian-Quantile-Trend-Filtering/engineering/E07_Tuning_Free/sampler")
source(file.path(.e07j_dir, "e07_sampler.R"))
.e07v3_dir <- "/home/fb31/Bayesian-Quantile-Trend-Filtering/engineering/E07_Tuning_Free/joint_gibbs"
e07v3_load <- function(cache = Sys.getenv("E07_CACHE", file.path(tempdir(), "e07cache"))) {
  e07_load(cache = cache)
  Rcpp::sourceCpp(file.path(.e07v3_dir, "e07_banded_v3.cpp"), cacheDir = cache, env = globalenv())
}

# fixed-width slice (same stepping-out/shrinkage rule as e07_sweep step 5); f0 = log-density at e0 given (feasibility of e0 assumed)
slice_fixed <- function(logf, e0, f0) {
  y0 <- f0 - rexp(1); ww <- 0.3; L <- e0 - runif(1) * ww; U <- L + ww; j <- floor(runif(1) * 20); k <- 19 - j
  while (j > 0 && logf(L) > y0) { L <- L - ww; j <- j - 1 }; while (k > 0 && logf(U) > y0) { U <- U + ww; k <- k - 1 }
  repeat { e1 <- L + runif(1) * (U - L); if (logf(e1) > y0) break; if (e1 < e0) L <- e1 else U <- e1; if (U - L < 1e-10) { e1 <- e0; break } }
  e1
}

# T-block in the box. Returns list(theta, lambda, moved)
tblock_box <- function(th, lam, w, r, lo, up, a0, b0, m) {
  x <- draw_x_exact(D3(th), lam); e0 <- log(lam)
  om <- banded_omega(w, r, exp(2 * e0) * x, th)
  logf <- function(eta, check = TRUE) {
    o <- banded_eval(w, r, exp(2 * eta) * x, om)
    if (check && any(o$theta < lo | o$theta > up)) return(-Inf)
    (a0 + m) * eta - b0 * exp(eta) - 0.5 * o$logdet + 0.5 * o$quad
  }
  e1 <- slice_fixed(logf, e0, logf(e0, FALSE))
  if (e1 == e0) return(list(theta = th, lambda = lam, moved = FALSE))
  list(theta = banded_eval(w, r, exp(2 * e1) * x, om)$theta, lambda = exp(e1), moved = TRUE)
}

# b = sum_j [W_j (r_j - theta_j) - D' diag(iw_j) D theta_j]; lists over levels
stack_shift_b <- function(TH, W, R, IW) {
  n <- length(TH[[1]]); m <- n - 3L; b <- numeric(n); st <- c(-1, 3, -3, 1)
  for (j in seq_along(TH)) {
    b <- b + W[[j]] * (R[[j]] - TH[[j]]); v <- IW[[j]] * D3(TH[[j]])
    for (t in 1:4) b[t:(t + m - 1L)] <- b[t:(t + m - 1L)] - st[t] * v
  }
  b
}

# One chain. Returns post-burn running means, traces, diagnostics.  chain_id fixes the seed.
bqtf_joint3 <- function(y, taus, a0, b0, a_s, b_s, sweeps, burn, chain_id = 1, K_try = 5, seed = 1, target_acc = 0.3,
                        init = c("smooth", "felipe"), theta_move = c("rhmc", "pcn"), tblock = FALSE, stack = FALSE, verbose = FALSE) {
  theta_move <- match.arg(theta_move)
  init <- match.arg(init); n <- length(y); m <- n - 3L; J <- length(taus); stopifnot(!is.unsorted(taus))
  idx9 <- unique(pmax(1L, round(n * (1:9) / 10))); nk <- sweeps - burn
  lam_tr <- sig_tr <- matrix(NA_real_, sweeps, J); cross_tr <- integer(sweeps); tb_abs <- tb_move <- bnc <- matrix(0, sweeps, J); dl_tr <- matrix(NA_real_, sweeps, J)
  pt_tr <- array(NA_real_, c(nk, length(idx9), J)); sumTH <- matrix(0, n, J); sumsqTH <- matrix(0, n, J)
  ap <- numeric(J); qn <- qnorm(taus); ncap <- 0L
  set.seed(seed + 100 * chain_id); t0 <- proc.time()[["elapsed"]]
  TH <- if (init == "felipe") sapply(seq_len(J), function(j) y + sd(y) * (qn[j] - median(qn)))
        else { bs <- smooth.spline(seq_len(n), y)$y; sr <- sd(y - bs); sapply(seq_len(J), function(j) bs + sr * qn[j]) }
  SIG <- sapply(seq_len(J), function(j) mean(rho_tau(y - TH[, j], taus[j])))
  bad <- !(SIG > 0); if (any(bad)) SIG[bad] <- sapply(which(bad), function(j) mean(rho_tau(y - median(y), taus[j])))
  Z <- sapply(seq_len(J), function(j) rep(SIG[j], n)); LAM <- rep(m, J); rp <- rep(0.5, J); nsw <- 0L
  for (s in seq_len(sweeps)) {
    post <- s > burn; lam_prev <- LAM
    for (j in seq_len(J)) {
      tau <- taus[j]; q <- tau * (1 - tau); psi <- (1 - 2 * tau) / q; t2 <- 2 / q
      lo <- if (j > 1) TH[, j - 1] else rep(-Inf, n); up <- if (j < J) TH[, j + 1] else rep(Inf, n)
      th <- TH[, j]; lam <- LAM[j]; sig <- SIG[j]; z <- Z[, j]
      iw <- lam^2 * draw_x_exact(D3(th), lam)                                  # 1.
      w <- 1 / (t2 * sig * z); r <- y - psi * z
      if (theta_move == "rhmc") {
        hm <- banded_rhmc(w, r, iw, th, lo, up, pi / 2); th <- hm$theta; bnc[s, j] <- hm$bounces; if (hm$capped) ncap <- ncap + 1L
      } else {
        mu <- banded_solve_logdet(w, r, iw)$mean; nacc <- 0L
        for (kk in seq_len(K_try)) {
          xd <- banded_gauss_draw(w, r, iw, rnorm(n), rnorm(m))
          prop <- mu + rp[j] * (th - mu) + sqrt(1 - rp[j]^2) * (xd - mu)
          if (all(prop >= lo & prop <= up)) { th <- prop; nacc <- nacc + 1L }
        }
        a_bar <- nacc / K_try
        if (!post) { g <- 2 * s^(-0.6); lg <- qlogis(min(max(rp[j], 1e-6), 1 - 1e-6)) - g * (a_bar - target_acc)
          rp[j] <- min(max(plogis(lg), 0), 0.999) }
        if (post) ap[j] <- ap[j] + a_bar
      }
      sig <- 1 / rgamma(1, a_s + n, b_s + sum(rho_tau(y - th, tau)))           # 3.
      z <- draw_z_exact(y - th, tau, sig); w <- 1 / (t2 * sig * z); r <- y - psi * z
      lam <- rgamma(1, a0 + m, b0 + sum(abs(D3(th))))                          # 4.
      if (tblock) {                                                            # 5.
        tb <- tblock_box(th, lam, w, r, lo, up, a0, b0, m)
        tb_abs[s, j] <- abs(log(tb$lambda) - log(lam)); tb_move[s, j] <- tb$moved; th <- tb$theta; lam <- tb$lambda
      }
      TH[, j] <- th; LAM[j] <- lam; SIG[j] <- sig; Z[, j] <- z
    }
    if (stack) {                                                               # stack-shift (all levels)
      Wl <- vector("list", J); Rl <- vector("list", J); IWl <- vector("list", J); Tl <- vector("list", J)
      for (j in seq_len(J)) { tau <- taus[j]; q <- tau * (1 - tau); psi <- (1 - 2 * tau) / q; t2 <- 2 / q
        Tl[[j]] <- TH[, j]; Wl[[j]] <- 1 / (t2 * SIG[j] * Z[, j]); Rl[[j]] <- y - psi * Z[, j]
        IWl[[j]] <- LAM[j]^2 * draw_x_exact(D3(TH[, j]), LAM[j]) }
      Ws <- Reduce(`+`, Wl); IWs <- Reduce(`+`, IWl); b <- stack_shift_b(Tl, Wl, Rl, IWl)
      Dl <- banded_gauss_draw(Ws, b / Ws, IWs, rnorm(n), rnorm(m)); TH <- TH + Dl
    }
    dl_tr[s, ] <- abs(log(LAM) - log(lam_prev))
    if (post) { nsw <- nsw + 1L; sumTH <- sumTH + TH; sumsqTH <- sumsqTH + TH^2; for (j in seq_len(J)) pt_tr[s - burn, , j] <- TH[idx9, j] }
    cross_tr[s] <- sum(apply(TH, 1, is.unsorted)); lam_tr[s, ] <- LAM; sig_tr[s, ] <- SIG
    if (verbose && s %% 500 == 0) cat(sprintf("chain %d sweep %d  %.1fs\n", chain_id, s, proc.time()[["elapsed"]] - t0))
  }
  list(taus = taus, mean = sumTH / nsw, sd = sqrt(pmax(sumsqTH / nsw - (sumTH / nsw)^2, 0)), lambda = lam_tr, sigma = sig_tr, crossings = cross_tr,
       acc_pcn = ap / nsw, r_pcn = rp, tb_abs = tb_abs, tb_moved = tb_move, bounces = bnc, capped = ncap, dlam_sweep = dl_tr, pts = pt_tr, idx9 = idx9,
       seconds = proc.time()[["elapsed"]] - t0, sweeps = sweeps, burn = burn)
}
