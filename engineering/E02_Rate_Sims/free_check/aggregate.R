d <- "/home/fb31/BQTF_runs/E02/free_check"
fs <- list.files(d, "\\.rds$", full.names = TRUE)
R <- lapply(fs, readRDS)
df <- do.call(rbind, lapply(R, function(r) data.frame(base = r$baseline, tau = r$tau, n = r$n, a0 = r$a0, b0 = r$b0, seed = r$seed,
  lam = r$lam_mean, lam_med = r$lam_med, kappa = r$kappa, lo = r$lam_q[1], hi = r$lam_q[2], lam_cap = r$lam_mean / r$CAP, sig = r$sig_mean, lamsig = r$lamsig,
  sig_L0 = r$sig_L0, sig_Lh = r$sig_Lhat, lamSD_m = r$lamSD_m, essL = r$ess_loglam, essS = r$ess_sig,
  drift = r$drift, mse = r$mse, sec = r$seconds, L0 = r$L0, acc = r$acc_post)))
df <- df[order(df$base, df$tau, df$b0, df$n, df$seed), ]
options(width = 250); print(format(df, digits = 3), row.names = FALSE)
write.csv(df, "/home/fb31/Bayesian-Quantile-Trend-Filtering/engineering/E02_Rate_Sims/free_check/free_check_table.csv", row.names = FALSE)
cat("\nTotal CPU seconds (sampler):", sum(df$sec), "\n")
a <- aggregate(cbind(lam, lamsig) ~ base + tau + n, subset(df, b0 == 0.01), mean)
for (b in unique(a$base)) for (t in unique(a$tau)) { s <- subset(a, base == b & tau == t)
  cat(sprintf("%s tau=%.1f slope lam~n: %.3f  lam*sig~n: %.3f   (n: %s)\n", b, t,
    coef(lm(log(lam) ~ log(n), s))[2], coef(lm(log(lamsig) ~ log(n), s))[2], paste(s$n, collapse = ","))) }
