# =============================================================================
# E-07 joint, non-crossing BQTF sampler (k = 2). Product over levels of the individual augmented posteriors restricted to
# theta_1 <= ... <= theta_J pointwise (Felipe's joint target). Levels visited in increasing order; box B_j = [theta_{j-1}, theta_{j+1}]
# with the latest values (-Inf/+Inf at the ends). Raw scale, priors as given. Reuses helpers of sampler/e07_sampler.R.
# Per sweep, per level j:
#  1. 1/s_j | theta_j, lambda_j exact (box-free).
#  2. theta_j: K_try pCN moves on the Gaussian conditional N(mu, P^-1), accepted iff the proposal lies in the box
#     (pCN is reversible for N(mu, P^-1); rejection outside the box targets the truncated Gaussian). r_pcn_j adapted in burn-in only.
#  3. sigma_j | theta_j ~ IG(a_s + n, b_s + sum rho), then z_j | theta_j, sigma_j exact.
#  4. lambda_j | theta_j ~ Gamma(a0 + m, b0 + ||D3 theta_j||_1).
#  5. collapsed (lambda_j, theta_j) proposal (slice on log lambda given t, z, sigma; theta' exact given lambda'); accepted iff theta' in B_j.
# =============================================================================
.e07j_dir <- Sys.getenv("E07_DIR", "/home/fb31/Bayesian-Quantile-Trend-Filtering/engineering/E07_Tuning_Free/sampler")
source(file.path(.e07j_dir, "e07_sampler.R"))

slice_loglam <- function(logf, e0) {                 # same stepping-out/shrinkage slice as e07_sweep step 5
  y0 <- logf(e0) - rexp(1); ww <- 0.3; L <- e0 - runif(1) * ww; U <- L + ww; j <- floor(runif(1) * 20); k <- 19 - j
  while (j > 0 && logf(L) > y0) { L <- L - ww; j <- j - 1 }; while (k > 0 && logf(U) > y0) { U <- U + ww; k <- k - 1 }
  repeat { e1 <- L + runif(1) * (U - L); if (logf(e1) > y0) break; if (e1 < e0) L <- e1 else U <- e1; if (U - L < 1e-10) { e1 <- e0; break } }
  e1
}

bqtf_joint <- function(y, taus, a0, b0, a_s, b_s, sweeps, burn, chains = 2, K_try = 5, seed = 1, target_acc = 0.3, init = c("felipe", "smooth"), verbose = FALSE) {
  init <- match.arg(init); n <- length(y); m <- n - 3L; J <- length(taus); stopifnot(!is.unsorted(taus))
  keep <- (burn + 1L):sweeps; nk <- length(keep)
  th_all <- array(NA_real_, c(nk, n, J, chains))   # draws
  lam_tr <- sig_tr <- array(NA_real_, c(sweeps, J, chains)); cross_tr <- matrix(0L, sweeps, chains)
  acc_pcn <- acc_col <- matrix(0, J, chains); r_final <- matrix(NA_real_, J, chains); secs <- numeric(chains)
  qn <- qnorm(taus); shift <- qn - median(qn)
  for (cc in seq_len(chains)) {
    set.seed(seed + 100 * cc); t0 <- proc.time()[["elapsed"]]
    TH <- if (init == "felipe") sapply(seq_len(J), function(j) y + sd(y) * shift[j])   # n x J, ordered (default; Felipe's rule)
          else { bs <- smooth.spline(seq_len(n), y)$y; sr <- sd(y - bs); sapply(seq_len(J), function(j) bs + sr * qn[j]) }  # smooth ordered start
    SIG <- sapply(seq_len(J), function(j) mean(rho_tau(y - TH[, j], taus[j])))
    bad <- !(SIG > 0); if (any(bad)) SIG[bad] <- sapply(which(bad), function(j) mean(rho_tau(y - median(y), taus[j])))  # degenerate init (J = 1: theta = y)
    Z <- sapply(seq_len(J), function(j) rep(SIG[j], n)); LAM <- rep(m, J)
    rp <- rep(0.5, J); ap <- ac <- numeric(J); nsw_post <- 0L
    for (s in seq_len(sweeps)) {
      post <- s > burn
      for (j in seq_len(J)) {
        tau <- taus[j]; q <- tau * (1 - tau); psi <- (1 - 2 * tau) / q; t2 <- 2 / q
        lo <- if (j > 1) TH[, j - 1] else rep(-Inf, n); up <- if (j < J) TH[, j + 1] else rep(Inf, n)
        th <- TH[, j]; lam <- LAM[j]; sig <- SIG[j]; z <- Z[, j]
        iw <- lam^2 * draw_x_exact(D3(th), lam)                                  # 1.
        w <- 1 / (t2 * sig * z); r <- y - psi * z
        mu <- banded_solve_logdet(w, r, iw)$mean; nacc <- 0L                     # 2.
        for (kk in seq_len(K_try)) {
          xd <- banded_gauss_draw(w, r, iw, rnorm(n), rnorm(m))
          prop <- mu + rp[j] * (th - mu) + sqrt(1 - rp[j]^2) * (xd - mu)
          if (all(prop >= lo & prop <= up)) { th <- prop; nacc <- nacc + 1L }
        }
        a_bar <- nacc / K_try
        if (!post) { g <- 2 * s^(-0.6); lg <- qlogis(min(max(rp[j], 1e-6), 1 - 1e-6)) - g * (a_bar - target_acc)
          rp[j] <- min(max(plogis(lg), 0), 0.999) }
        if (post) ap[j] <- ap[j] + a_bar
        sig <- 1 / rgamma(1, a_s + n, b_s + sum(rho_tau(y - th, tau)))           # 3.
        z <- draw_z_exact(y - th, tau, sig); w <- 1 / (t2 * sig * z); r <- y - psi * z
        lam <- rgamma(1, a0 + m, b0 + sum(abs(D3(th))))                          # 4.
        ix <- draw_x_exact(D3(th), lam)                                          # 5.
        logf <- function(eta) { o <- banded_solve_logdet(w, r, exp(2 * eta) * ix)
          (a0 + m) * eta - b0 * exp(eta) - 0.5 * o$logdet + 0.5 * sum(w * r * o$mean) }
        e1 <- slice_loglam(logf, log(lam)); lam1 <- exp(e1)
        th1 <- banded_gauss_draw(w, r, lam1^2 * ix, rnorm(n), rnorm(m))
        if (all(th1 >= lo & th1 <= up)) { th <- th1; lam <- lam1; if (post) ac[j] <- ac[j] + 1 }
        TH[, j] <- th; LAM[j] <- lam; SIG[j] <- sig; Z[, j] <- z
      }
      if (post) nsw_post <- nsw_post + 1L
      cross_tr[s, cc] <- sum(apply(TH, 1, is.unsorted)); lam_tr[s, , cc] <- LAM; sig_tr[s, , cc] <- SIG
      if (post) th_all[s - burn, , , cc] <- TH
      if (verbose && s %% 500 == 0) cat(sprintf("chain %d sweep %d  %.1fs\n", cc, s, proc.time()[["elapsed"]] - t0))
    }
    acc_pcn[, cc] <- ap / nsw_post; acc_col[, cc] <- ac / nsw_post; r_final[, cc] <- rp
    secs[cc] <- proc.time()[["elapsed"]] - t0
  }
  lev <- lapply(seq_len(J), function(j) { D <- do.call(rbind, lapply(seq_len(chains), function(cc) th_all[, , j, cc]))
    list(mean = colMeans(D), median = apply(D, 2, median), lo = apply(D, 2, quantile, 0.025), hi = apply(D, 2, quantile, 0.975)) })
  list(taus = taus, levels = lev, lambda = lam_tr, sigma = sig_tr, crossings = cross_tr, acc_pcn = acc_pcn, acc_collapsed = acc_col,
       r_pcn = r_final, seconds = secs, sec_per_sweep = secs / sweeps, burn = burn, sweeps = sweeps)
}
