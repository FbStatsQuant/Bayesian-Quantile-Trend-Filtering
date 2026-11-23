# =============================================================================
# E-07 joint non-crossing BQTF sampler, v2 (k = 2). Same target as e07_joint.R (product of the individual augmented posteriors on
# theta_1 <= ... <= theta_J pointwise); levels in increasing order, box [theta_{j-1}, theta_{j+1}] with the latest values.
# Per level j, per sweep:
#  1. latents: 1/s_j | theta_j, lambda_j exact;  sigma_j | theta_j ~ IG(a_s + n, b_s + sum rho) (z integrated out);  z_j | theta_j, sigma_j exact.
#  2. theta_j | z, s, sigma, lambda, box: ONE exact single-site truncated-Gibbs sweep (ss_tgibbs.cpp, always accepted; n_ss sweeps if asked),
#     then ONE global pCN-in-box attempt (r_pcn_j adapted in burn-in only toward 0.3).
#  3. lambda_j | theta_j ~ Gamma(a0 + m, b0 + ||D3 theta_j||_1), then Felipe's box-restricted ASIS (asis_box_step, copied verbatim by parsing
#     method/joint/Joint_Sampler_PMALA_Augmented.R) with a = w, r = y - psi z, Q = null_basis(n, 2).  No collapsed block.
# Init: smooth ordered start theta_j = smooth.spline(y) + sd(resid) qnorm(tau_j); sigma_j = mean rho; z_j = sigma_j; lambda_j = m.
# =============================================================================
.e07j_dir <- Sys.getenv("E07_DIR", "/home/fb31/Bayesian-Quantile-Trend-Filtering/engineering/E07_Tuning_Free/sampler")
.e07j2_dir <- "/home/fb31/Bayesian-Quantile-Trend-Filtering/engineering/E07_Tuning_Free/joint_gibbs"
source(file.path(.e07j_dir, "e07_sampler.R"))
local({                                                    # pull Felipe's box-ASIS definitions out of his script without running it
  ex <- parse(file.path("/home/fb31/Bayesian-Quantile-Trend-Filtering/method/joint/Joint_Sampler_PMALA_Augmented.R"), keep.source = FALSE)
  want <- c("in_box", "null_basis", "asis_scale_domain", "asis_box_step")
  for (e in ex) if (is.call(e) && identical(e[[1]], as.name("<-")) && is.name(e[[2]]) && as.character(e[[2]]) %in% want) eval(e, globalenv())
})
e07_load2 <- function(cache = Sys.getenv("E07_CACHE", file.path(tempdir(), "e07cache"))) {
  e07_load(cache = cache); Rcpp::sourceCpp(file.path(.e07j2_dir, "ss_tgibbs.cpp"), cacheDir = cache, env = globalenv()) }

bqtf_joint2 <- function(y, taus, a0, b0, a_s, b_s, sweeps, burn, chain_ids = 1:2, n_ss = 1L, seed = 1, target_acc = 0.3,
                        init = c("smooth", "felipe"), pcn = TRUE, asis = TRUE, keep_theta = TRUE, verbose = FALSE) {
  init <- match.arg(init); n <- length(y); m <- n - 3L; J <- length(taus); stopifnot(!is.unsorted(taus)); chains <- length(chain_ids)
  nk <- sweeps - burn; Qn <- null_basis(n, 2L); qn <- qnorm(taus)
  th_all <- if (keep_theta) array(NA_real_, c(nk, n, J, chains)) else NULL
  lam_tr <- sig_tr <- array(NA_real_, c(sweeps, J, chains)); cross_tr <- matrix(0L, sweeps, chains)
  acc_pcn <- asis_moved <- matrix(0, J, chains); r_final <- matrix(NA_real_, J, chains); secs <- numeric(chains); thsum <- array(0, c(n, J, chains))
  for (ci in seq_len(chains)) {
    set.seed(seed + 100 * chain_ids[ci]); t0 <- proc.time()[["elapsed"]]
    TH <- if (init == "felipe") sapply(seq_len(J), function(j) y + sd(y) * (qn[j] - median(qn)))
          else { bs <- smooth.spline(seq_len(n), y)$y; sr <- sd(y - bs); sapply(seq_len(J), function(j) bs + sr * qn[j]) }
    if (J == 1 && init == "smooth") TH <- matrix(smooth.spline(seq_len(n), y)$y, n, 1)
    SIG <- sapply(seq_len(J), function(j) mean(rho_tau(y - TH[, j], taus[j])))
    bad <- !(SIG > 0); if (any(bad)) SIG[bad] <- sapply(which(bad), function(j) mean(rho_tau(y - median(y), taus[j])))
    Z <- sapply(seq_len(J), function(j) rep(SIG[j], n)); LAM <- rep(m, J); rp <- rep(0.5, J); ap <- am <- numeric(J)
    for (s in seq_len(sweeps)) {
      post <- s > burn
      for (j in seq_len(J)) {
        tau <- taus[j]; q <- tau * (1 - tau); psi <- (1 - 2 * tau) / q; t2 <- 2 / q
        lo <- if (j > 1) TH[, j - 1] else rep(-Inf, n); up <- if (j < J) TH[, j + 1] else rep(Inf, n)
        th <- TH[, j]; lam <- LAM[j]
        iw <- lam^2 * draw_x_exact(D3(th), lam)                                    # 1. latents
        sig <- 1 / rgamma(1, a_s + n, b_s + sum(rho_tau(y - th, tau)))
        z <- draw_z_exact(y - th, tau, sig); w <- 1 / (t2 * sig * z); r <- y - psi * z
        th <- ss_tgibbs(th, w, r, iw, lo, up, n_ss)                                # 2. exact single-site truncated Gibbs
        if (pcn) {
          mu <- banded_solve_logdet(w, r, iw)$mean; xd <- banded_gauss_draw(w, r, iw, rnorm(n), rnorm(m))
          prop <- mu + rp[j] * (th - mu) + sqrt(1 - rp[j]^2) * (xd - mu); okp <- all(prop >= lo & prop <= up)
          if (okp) th <- prop
          if (!post) { g <- 2 * s^(-0.6); lg <- qlogis(min(max(rp[j], 1e-6), 1 - 1e-6)) - g * (okp - target_acc)
            rp[j] <- min(max(plogis(lg), 0), 0.999) } else ap[j] <- ap[j] + okp
        }
        lam <- rgamma(1, a0 + m, b0 + sum(abs(D3(th))))                            # 3. lambda
        if (asis) { as_ <- asis_box_step(th, lam, w, r, a0, b0, Qn, lo, up); lam <- as_$lambda; th <- as_$theta; if (post) am[j] <- am[j] + as_$moved
          th <- pmin(pmax(th, lo), up) }                                           # (roundoff-only clamp; moves are inside the box by construction)
        TH[, j] <- th; LAM[j] <- lam; SIG[j] <- sig; Z[, j] <- z
      }
      cross_tr[s, ci] <- sum(apply(TH, 1, is.unsorted)); lam_tr[s, , ci] <- LAM; sig_tr[s, , ci] <- SIG
      if (post) { thsum[, , ci] <- thsum[, , ci] + TH; if (keep_theta) th_all[s - burn, , , ci] <- TH }
      if (verbose && s %% 1000 == 0) cat(sprintf("chain %d sweep %d  %.1fs\n", chain_ids[ci], s, proc.time()[["elapsed"]] - t0))
    }
    acc_pcn[, ci] <- ap / nk; asis_moved[, ci] <- am / nk; r_final[, ci] <- rp; secs[ci] <- proc.time()[["elapsed"]] - t0
  }
  mean_th <- apply(thsum, c(1, 2), sum) / (nk * chains)                            # n x J posterior mean
  lev <- if (keep_theta) lapply(seq_len(J), function(j) { D <- do.call(rbind, lapply(seq_len(chains), function(ci) th_all[, , j, ci]))
    list(mean = colMeans(D), median = apply(D, 2, median), lo = apply(D, 2, quantile, 0.025), hi = apply(D, 2, quantile, 0.975)) }) else NULL
  list(taus = taus, mean = mean_th, levels = lev, lambda = lam_tr, sigma = sig_tr, crossings = cross_tr, acc_pcn = acc_pcn,
       asis_moved = asis_moved, r_pcn = r_final, seconds = secs, sec_per_sweep = secs / sweeps, burn = burn, sweeps = sweeps)
}
