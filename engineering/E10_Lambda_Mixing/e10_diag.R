# E-10 diagnostics requested by HQ (2026-11-25) on the S n2000 low-coverage finding: bug in the new move (A) or true posterior (B)?
# Usage: Rscript e10_diag.R proj                      projection exactness of the production projector, n = 2000 / 5000, every q of every grid
#        Rscript e10_diag.R exact <case 1-8>          production spline path vs an importance-sampling reference, n = 7
#        Rscript e10_diag.R cross <tau> <first>       cross-initialisation, S n2000: <first> (new | old) from the standard start for 30k,
#                                                     then the other sampler from the first one's final state (theta, lambda, sigma, z) for 30k
# env: E10_CODE (sampler folder), E10_OUT (output folder)
suppressPackageStartupMessages(library(coda))
code <- Sys.getenv("E10_CODE", "method/individual"); out <- Sys.getenv("E10_OUT", "engineering/E10_Lambda_Mixing/diag")
dir.create(out, showWarnings = FALSE, recursive = TRUE)
src <- file.path(code, "Individual_Sampler_PMALA_Augmented.R"); lines <- readLines(src); main_at <- grep("^# ---- Main", lines)[1]
owd <- setwd(code); eval(parse(text = lines[seq_len(main_at - 1)]), envir = globalenv()); setwd(owd)
load_prox_cpp(file.path(code, "prox_admm_metric.cpp"))
args <- commandArgs(trailingOnly = TRUE); mode <- args[1]
bm_se <- function(v, nb = 50) { b <- floor(length(v) / nb); sd(colMeans(matrix(v[1:(b * nb)], b, nb))) / sqrt(nb) }

if (mode == "proj") {
  set.seed(1); rows <- list()
  for (n in c(2000L, 5000L)) {
    qs <- sort(unique(unlist(lapply(c("fixed", "n_prop", "n16", "geo"), function(rl) asis_q_grid(n, 2L, rl)))))
    x <- seq_len(n) / n; polys <- sapply(0:3, function(d) x^d)
    for (q in qs) {
      P <- asis_projector(n, q, 2L); e_id <- e_sym <- e_orth <- 0
      for (rep in 1:5) {
        u <- rnorm(n); w <- cumsum(rnorm(n)); Pu <- P(u); Pw <- P(w)
        e_id <- max(e_id, max(abs(P(Pu) - Pu)) / max(abs(Pu)))
        e_sym <- max(e_sym, abs(sum(Pu * w) - sum(u * Pw)) / sqrt(sum(u^2) * sum(w^2)))
        e_orth <- max(e_orth, abs(sum(Pu * (u - Pu))) / sum(u^2))
      }
      e_poly <- max(apply(polys, 2, function(p) max(abs(P(p) - p)) / max(abs(p))))
      rows[[length(rows) + 1L]] <- data.frame(n = n, q = q, idempotence = e_id, symmetry = e_sym, orthogonality = e_orth, cubic_poly_in_span = e_poly)
    }
  }
  R <- do.call(rbind, rows); print(R, digits = 3, row.names = FALSE)
  cat(sprintf("max errors: idempotence %.1e | symmetry %.1e | orthogonality %.1e | polynomials (deg <= 3) %.1e | all < 1e-10: %s\n",
              max(R$idempotence), max(R$symmetry), max(R$orthogonality), max(R$cubic_poly_in_span),
              all(c(R$idempotence, R$symmetry, R$orthogonality, R$cubic_poly_in_span) < 1e-10)))
  write.csv(R, file.path(out, "proj_exactness.csv"), row.names = FALSE)
}

if (mode == "exact") {
  # n = 7, real cubic B-spline subspaces through the production asis_projector (spline branch), ord 0 and 1, b0 = 0.5 (bounded IS weights)
  cases <- expand.grid(q = c(4L, 5L, 6L), ord = c(0L, 1L)); cases$qj <- cases$q
  cases <- rbind(cases, data.frame(q = c(6L, 6L), ord = c(0L, 1L), qj = c(1L, 2L)),     # 7-8: wrong Jacobians (q_jac = k + 1): must fail
                 data.frame(q = c(1L, 2L), ord = c(0L, 1L), qj = c(1L, 2L)))                 # 9-10: controls, the original polynomial move
  cs <- cases[as.integer(args[2]), ]; nn <- 7L; ord <- cs$ord; mm <- nn - ord - 1L; a0_ <- 1; b0_ <- 0.5; sg <- 0.5; tt <- 0.3; cst <- ald_const(tt)
  set.seed(13); yy <- cumsum(rnorm(nn, 0, 0.3)); zz <- rexp(nn, 1 / sg); a <- 1 / (cst$t2 * sg * zz); r <- yy - cst$psi * zz
  # importance-sampling reference of the lambda-marginalised target pi(th) ∝ exp(-sum a (th - r)^2 / 2) (b0 + ||D th||_1)^-(m + a0).
  # Proposal: multivariate t (5 df) centred and scaled (x 1.5^2) from a pilot chain of the plain kernel (P-MALA + conjugate lambda, no
  # interweaving), so the reference does not depend on the move under test; IS is exact for any proposal, the pilot only sets efficiency.
  Dm <- diff(diag(nn), differences = ord + 1L)
  set.seed(76); th <- r; lam <- 2; PIL <- matrix(NA, 60000L, nn)
  for (i in seq_len(60000L)) { th <- pmala_step(th, yy, zz, lam, sg, 1.0, cst, ord, "curv", 0, iters = 300L, kappa = 3)$theta
    lam <- rgamma(1, a0_ + mm, b0_ + sum(abs(Dm %*% th))); PIL[i, ] <- th }
  mu <- colMeans(PIL[-(1:5000), ]); Sig <- 1.5^2 * cov(PIL[-(1:5000), ]); Lc <- t(chol(Sig)); Si <- chol2inv(chol(Sig)); nu <- 5
  logt <- function(dx) -(nu + nn) / 2 * log1p(rowSums((dx %*% Si) * dx) / nu)
  set.seed(77); Nis <- 4e7; chs <- 1e6; mom <- list(); lw_ref <- NA
  for (b in seq_len(Nis / chs)) {
    Z <- matrix(rnorm(chs * nn), chs, nn) %*% t(Lc) / sqrt(rchisq(chs, nu) / nu); G <- Z + rep(mu, each = chs)
    SD <- rowSums(abs(G %*% t(Dm)))
    lw <- -as.vector((G - rep(r, each = chs))^2 %*% a) / 2 - (mm + a0_) * log(b0_ + SD) - logt(Z)
    if (is.na(lw_ref)) lw_ref <- max(lw)
    w <- exp(lw - lw_ref); lamv <- (mm + a0_) / (b0_ + SD)
    mom[[b]] <- c(sum(w), colSums(G * w), colSums(G^2 * w), sum(w * lamv), sum(w^2), sum(w * lamv^2))
  }
  M <- do.call(rbind, mom); W <- sum(M[, 1]); ix <- function(k) 1 + (k - 1) * nn + seq_len(nn)
  m_ex <- colSums(M[, ix(1)]) / W; e2 <- colSums(M[, ix(2)]) / W; s_ex <- sqrt(e2 - m_ex^2); lam_ex <- sum(M[, 2 + 2 * nn]) / W
  W2 <- sum(M[, 3 + 2 * nn]); ess_is <- W^2 / W2; sd_lam <- sqrt(sum(M[, 4 + 2 * nn]) / W - lam_ex^2)
  # IS standard errors by the Kish effective sample size (sd / sqrt(ESS)); they enter the z-scores together with the chain's batch-means se
  se_m_is <- s_ex / sqrt(ess_is); se_s_is <- s_ex / sqrt(2 * ess_is); se_l_is <- sd_lam / sqrt(ess_is)
  # chain: P-MALA + conjugate lambda + production generalised ASIS with the spline projector
  P <- asis_projector(nn, cs$q, ord); stopifnot(attr(P, "poly") == (cs$q == ord + 1L), attr(P, "q") == cs$q)
  set.seed(500 + as.integer(args[2])); th <- r; lam <- 2; M2 <- 200000L; S <- matrix(NA, M2, nn); L <- numeric(M2)
  for (i in seq_len(M2)) {
    st <- pmala_step(th, yy, zz, lam, sg, 1.0, cst, ord, "curv", 0, iters = 300L, kappa = 3); th <- st$theta
    lam <- rgamma(1, a0_ + mm, b0_ + sum(abs(diff(th, differences = ord + 1L))))
    as_ <- asis_step(th, lam, a, r, a0_, b0_, P, ord, q_jac = cs$qj); lam <- as_$lambda; th <- as_$theta
    S[i, ] <- th; L[i] <- lam
  }
  S1 <- S[-(1:5000), ]; L1 <- L[-(1:5000)]
  m1 <- colMeans(S1); se1 <- apply(S1, 2, bm_se); s1 <- apply(S1, 2, sd); se_s1 <- apply(S1, 2, function(v) bm_se((v - mean(v))^2)) / (2 * s1)
  zz_ <- c(max(abs(m1 - m_ex) / sqrt(se1^2 + se_m_is^2)), max(abs(s1 - s_ex) / sqrt(se_s1^2 + se_s_is^2)),
           abs(mean(L1) - lam_ex) / sqrt(bm_se(L1)^2 + se_l_is^2)); right <- cs$qj == cs$q
  pass <- if (right) max(zz_) < 4 else max(zz_) > 8
  res <- data.frame(case = as.integer(args[2]), n = nn, ord = ord, q_spline = cs$q, q_jacobian = cs$qj, jacobian = if (right) "correct" else "WRONG",
                    is_ess = round(ess_is), is_se_lambda = se_l_is, chain_se_lambda = bm_se(L1), max_mean_z = zz_[1], max_sd_z = zz_[2], lambda_z = zz_[3], E_lambda_chain = mean(L1), E_lambda_ref = lam_ex,
                    expected = if (right) "pass (all z < 4)" else "fail (some z > 8)", as_expected = pass)
  print(res, digits = 4, row.names = FALSE); write.csv(res, file.path(out, sprintf("exact_case%d.csv", as.integer(args[2]))), row.names = FALSE)
}

if (mode == "cross") {
  tau <- as.numeric(args[2]); first <- args[3]; second <- setdiff(c("new", "old"), first)
  rule <- c(new = "fixed", old = "poly")
  dat <- simulate_data(1, 2000L, tau, "S", "Normal"); cst <- ald_const(tau); n <- 2000L; m <- n - 3L
  # log posterior pieces at a state: ALD log-likelihood, the lambda-marginalised log prior of theta, and the full log joint
  logdens <- function(th, lam, sg) {
    u <- dat$y - th; ll <- sum(log(tau * (1 - tau) / sg) - rho_tau(u, tau) / sg); SD <- sum(abs(diff(th, differences = 3)))
    lp_sig <- -(0.1 + 1) * log(sg) - 0.1 / sg
    c(loglik = ll, SD = SD, log_marg_prior_theta = -(m + 1) * log(1e-5 + SD),
      log_joint = ll + m * log(lam) - lam * SD + (1 - 1) * log(lam) - 1e-5 * lam + lp_sig,
      log_marg = ll - (m + 1) * log(1e-5 + SD) + lp_sig)
  }
  run <- function(which, init, warm) {
    set.seed(if (which == "new") 2001 else 2002)
    gibbs_pmala_aug(dat$y, tau, 2L, 1, 1e-5, 0.1, 0.1, 30000L, 10000L, delta_init, lambda_init, adapt_target, adapt_gain, adapt_kappa, delta_bounds,
                    tf_control, metric = "curv", iters = admm_iter, init = init, warm = warm, gamma_warm = gamma_warm, K = 1L, asis = TRUE,
                    prior_scale = "none", kappa = kappa_metric, adapt_all = TRUE, asis_q = rule[[which]], verbose = FALSE)
  }
  summ <- function(fit, which, phase) {
    post <- 10001:30000; TH <- fit$theta; est <- colMeans(TH); lo <- apply(TH, 2, quantile, .025); hi <- apply(TH, 2, quantile, .975)
    thin <- seq(1, nrow(TH), by = 500); D <- t(sapply(thin, function(i) logdens(TH[i, ], fit$lambda[10000 + i], fit$sigma[10000 + i])))
    data.frame(tau = tau, phase = phase, sampler = which, lambda_start = fit$lambda[1], lambda_mean = mean(fit$lambda[post]),
               lambda_q05 = quantile(fit$lambda[post], .05), lambda_q95 = quantile(fit$lambda[post], .95),
               lambda_last5k_mean = mean(fit$lambda[25001:30000]), lambda_ess = as.numeric(effectiveSize(fit$lambda[post])),
               sigma_mean = mean(fit$sigma[post]), mse = mean((est - dat$truth)^2), coverage = mean(dat$truth >= lo & dat$truth <= hi), width = mean(hi - lo),
               SD_mean = mean(D[, "SD"]), loglik_mean = mean(D[, "loglik"]), log_joint_mean = mean(D[, "log_joint"]), log_marg_mean = mean(D[, "log_marg"]),
               minutes = fit$seconds / 60, row.names = NULL)
  }
  f1 <- run(first, "y", warm_sweeps); s1 <- summ(f1, first, "1: standard start")
  f2 <- run(second, f1$final, 0L);    s2 <- summ(f2, second, sprintf("2: from %s final state", first))
  res <- rbind(s1, s2); print(res, digits = 4, row.names = FALSE)
  write.csv(res, file.path(out, sprintf("cross_t%03d_%sfirst.csv", round(100 * tau), first)), row.names = FALSE)
  saveRDS(list(lambda1 = f1$lambda, lambda2 = f2$lambda, sigma1 = f1$sigma, sigma2 = f2$sigma, final1 = f1$final, final2 = f2$final),
          file.path(out, sprintf("cross_t%03d_%sfirst.rds", round(100 * tau), first)))
}
