# E-04 analysis of parts A (exact n = 4), B (paper settings, P-MALA vs Gibbs, 4 chains each), C (R-hat of the E-02 functional).
suppressPackageStartupMessages(library(coda))
R <- Sys.getenv("E04_OUT", "/home/fb31/BQTF_runs/E04")
cat("== A: exact posterior (4-d grid) vs samplers; z = (sampler - exact) / MC se (se from ESS) ==\n")
for (r in readRDS(file.path(R, "A", "A_0.rds"))) {
  cl <- r$cell; se_g <- r$s_ex / sqrt(r$g$ess); se_p <- r$s_ex / sqrt(r$p$ess)
  cat(sprintf("tau %.1f lambda %g sigma %.1f | grid edge mass %.1e | Gibbs: max|z_mean| %.2f, sd ratio %.3f-%.3f | P-MALA: max|z_mean| %.2f, sd ratio %.3f-%.3f, acc %.2f\n",
      cl$tau, cl$lam, cl$sig, r$grid_mass_edge, max(abs((r$g$m - r$m_ex) / se_g)), min(r$g$s / r$s_ex), max(r$g$s / r$s_ex),
      max(abs((r$p$m - r$m_ex) / se_p)), min(r$p$s / r$s_ex), max(r$p$s / r$s_ex), r$p$acc))
}
cat("\n== B: paper settings (paper's VS generator, n = 500, tau 0.5, learned lambda and sigma), 4 chains per sampler ==\n")
B <- lapply(list.files(file.path(R, "B"), full.names = TRUE), readRDS); truth <- B[[1]]$truth
res <- do.call(c, lapply(B, `[[`, "res"))
for (b0 in c(1, 1e-3)) {
  cat(sprintf("\n-- b0 = %g --\n", b0))
  S <- list()
  for (smp in c("pmala", "gibbs")) {
    ch <- Filter(function(x) x$sampler == smp && x$b0 == b0, res)
    pm <- sapply(ch, `[[`, "pm"); lo <- sapply(ch, `[[`, "lo"); hi <- sapply(ch, `[[`, "hi")
    S[[smp]] <- list(pm = rowMeans(pm), pm_se = apply(pm, 1, sd) / sqrt(ncol(pm)), lo = rowMeans(lo), lo_se = apply(lo, 1, sd) / sqrt(ncol(lo)),
                     hi = rowMeans(hi), hi_se = apply(hi, 1, sd) / sqrt(ncol(hi)),
                     d2 = sapply(ch, function(x) mean(x$d2)), lam = sapply(ch, function(x) mean(x$lam)), sig = sapply(ch, function(x) mean(x$sig)),
                     rhat_loglam = gelman.diag(mcmc.list(lapply(ch, function(x) mcmc(log(x$lam)))), autoburnin = FALSE)$psrf[1, 1],
                     rhat_d2 = gelman.diag(mcmc.list(lapply(ch, function(x) mcmc(x$d2))), autoburnin = FALSE)$psrf[1, 1],
                     ess_loglam = sum(sapply(ch, function(x) effectiveSize(log(x$lam)))), ess_d2 = sum(sapply(ch, function(x) effectiveSize(x$d2))),
                     cover = mean(truth >= rowMeans(lo) & truth <= rowMeans(hi)), mse = mean((rowMeans(pm) - truth)^2),
                     acc = mean(sapply(ch, `[[`, "acc")), sec = mean(sapply(ch, `[[`, "sec")))
    s <- S[[smp]]
    cat(sprintf("%-6s lambda %9.1f (chains %s) sigma %.4f | Delta2 %.5f | MSE(pm) %.5f | cover95 %.3f | R-hat log-lambda %.3f Delta2 %.3f | ESS(4 ch) log-lambda %.0f Delta2 %.0f | acc %s | sec/chain %.0f\n",
        smp, mean(s$lam), paste(round(s$lam), collapse = "/"), mean(s$sig), mean(s$d2), s$mse, s$cover, s$rhat_loglam, s$rhat_d2, s$ess_loglam, s$ess_d2,
        if (is.na(s$acc)) "-" else sprintf("%.2f", s$acc), s$sec))
  }
  P <- S$pmala; G <- S$gibbs
  zf <- function(a, sa, b, sb) (a - b) / sqrt(sa^2 + sb^2)
  zm <- zf(P$pm, P$pm_se, G$pm, G$pm_se); zl <- zf(P$lo, P$lo_se, G$lo, G$lo_se); zh <- zf(P$hi, P$hi_se, G$hi, G$hi_se)
  psd <- (G$hi - G$lo) / 3.92
  cat(sprintf("agreement P-MALA vs Gibbs (pointwise, n = 500): mean |z| %.2f / %.2f / %.2f (mean, 2.5%%, 97.5%%), share |z| > 3: %.3f / %.3f / %.3f\n",
      mean(abs(zm)), mean(abs(zl)), mean(abs(zh)), mean(abs(zm) > 3), mean(abs(zl) > 3), mean(abs(zh) > 3)))
  cat(sprintf("  max |pm_P - pm_G| / posterior sd = %.3f (median %.3f); Delta2 diff z = %.2f; lambda diff z = %.2f; sigma diff z = %.2f\n",
      max(abs(P$pm - G$pm) / psd), median(abs(P$pm - G$pm) / psd),
      zf(mean(P$d2), sd(P$d2) / 2, mean(G$d2), sd(G$d2) / 2), zf(mean(P$lam), sd(P$lam) / 2, mean(G$lam), sd(G$lam) / 2), zf(mean(P$sig), sd(P$sig) / 2, mean(G$sig), sd(G$sig) / 2)))
}
cat("\n== C: R-hat of Delta2 (4 dispersed starts: MAP, data, LS quadratic, MAP + jitter), Gibbs, fixed lambda, sigma ==\n")
for (r in readRDS(file.path(R, "C", "C_0.rds")))
  cat(sprintf("n %5d a %.3f | R-hat %.3f (upper %.3f) | ESS per chain %s | Delta2 chain means %s | centre %s\n", r$cell$n, r$cell$a, r$rhat_d2[1], r$rhat_d2[2],
      paste(round(r$ess_d2), collapse = "/"), paste(signif(r$d2_means, 3), collapse = "/"), paste(signif(r$centre, 3), collapse = "/")))
