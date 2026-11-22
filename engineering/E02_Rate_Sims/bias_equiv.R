# E-02 / Theory request: bias equivalence of the Laplace posterior mean and the spline smoother, on NOISELESS data y = theta*.
# Frozen-lambda Laplace posterior with a GAUSSIAN likelihood (precision kappa = 16):
#   pi(theta) ∝ exp{-kappa/2 ||y - theta||^2 - lambda ||D theta||_1},  flat on quadratics,
# sampled by the same scale-mixture Gibbs (1/s_j | theta ~ InvGauss(lambda/|v_j|, lambda^2), production cap) and the same banded QR
# draw, with the likelihood weights fixed at w = kappa, r = y (no z-augmentation needed).  Rao-Blackwellised posterior mean:
#   theta_RB = mean over sweeps of E[theta | s] = Q(s)^{-1} W y  (one zero-noise banded solve per sweep).
# Reports bias2_RB = ||theta_RB - theta*||^2/n and the spline bias2 ||S theta* - theta*||^2/n, S = kappa (kappa I + lambda^2/2 D'D)^{-1}.
source(file.path(Sys.getenv("E02_DIR", "."), "e02_lib.R")); load_kernel()
kappa <- 16
cells <- expand.grid(n = c(300, 600, 1200, 2400), a = c(2, 9/4, 5/2, 8/3))
res <- parallel::mclapply(seq_len(nrow(cells)), function(ci) {
  n <- cells$n[ci]; a <- cells$a[ci]; lam <- n^a; m <- n - 3L
  ts <- make_data("PQT", "g25", 0.5, n, 1)$theta_star - noise_q("g25", 0.5)   # PQ truth (tau = 0.5, so q = 0); y = theta*
  y <- ts; w <- rep(kappa, n); iw_max <- 1e6 * lam^2
  theta <- spline_smooth(y, kappa, lam); set.seed(100 + ci)
  burn <- 1000L; keep <- 2000L; sum_rb <- numeric(n); sum_th <- numeric(n); pen <- numeric(keep)
  for (it in seq_len(burn + keep)) {
    v <- D3(theta)
    iw <- pmin(rinvgauss(m, lam / pmax(abs(v), lam / iw_max), lam^2), iw_max)
    mu <- banded_gauss_draw(w, y, iw, numeric(n), numeric(m))               # E[theta | s]
    theta <- mu + (banded_gauss_draw(w, y, iw, rnorm(n), rnorm(m)) - mu)   # = a fresh exact draw (same solve with noise)
    if (it > burn) { k <- it - burn; sum_rb <- sum_rb + mu; sum_th <- sum_th + theta; pen[k] <- lam * sum(abs(D3(theta))) / m }
  }
  rb <- sum_rb / keep; pm <- sum_th / keep
  sb <- mse(spline_smooth(ts, kappa, lam) - ts)
  data.frame(n = n, a = a, lambda = lam, bias2_RB = mse(rb - ts), bias2_pm = mse(pm - ts), spline_bias2 = sb,
             ratio_RB = mse(rb - ts) / sb, ratio_pm = mse(pm - ts) / sb, pen_ratio = mean(pen), w_over_n = (lam^2 / kappa)^(1/6) / n)
}, mc.cores = as.integer(Sys.getenv("SLURM_CPUS_PER_TASK", "2")), mc.preschedule = FALSE)
R <- do.call(rbind, res); R <- R[order(R$a, R$n), ]
out <- file.path(Sys.getenv("E02_OUT", "/home/fb31/BQTF_runs/E02"), "analysis"); dir.create(out, recursive = TRUE, showWarnings = FALSE)
saveRDS(R, file.path(out, "bias_equiv.rds")); print(signif(R, 4), row.names = FALSE)
