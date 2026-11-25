# V1 / V2 pilot analysis (INTERNAL). Usage: Rscript variants_analyze.R <variants dir> <sigma_sprint dir> <out dir>
.libPaths(c("/home/fb31/Bayesian-Quantile-Trend-Filtering/ops/Rlib", .libPaths())); suppressPackageStartupMessages({ library(ggplot2); library(posterior) })
args <- commandArgs(TRUE); IN <- args[1]; SPR <- args[2]; OUT <- args[3]; dir.create(OUT, showWarnings = FALSE, recursive = TRUE); options(width = 230)
fs <- list.files(IN, pattern = "\\.rds$", full.names = TRUE); O <- lapply(fs, readRDS); R <- do.call(rbind, lapply(O, `[[`, "row"))
burn_of <- function(bl) if (bl == "VS") 10000L else 5000L
# ---- V1 (lambda fixed at kappa n^{5/2}) vs L (sprint), n = 500, seeds 1-3 ----
L <- do.call(rbind, lapply(list.files(SPR, pattern = "^L_.*\\.rds$", full.names = TRUE), function(f) readRDS(f)$row))
V1 <- R[R$arm == "V1", ]
if (nrow(V1)) {
  m <- merge(V1[, c("bl", "noise", "tau", "seed", "mse", "cover", "mciw", "lam_mean")], L[, c("bl", "noise", "tau", "seed", "mse", "cover", "mciw", "lam_mean")], by = c("bl", "noise", "tau", "seed"), suffixes = c("_V1", "_L"))
  A <- do.call(rbind, lapply(split(m, m[, c("bl", "noise", "tau")], drop = TRUE), function(d) { lr <- log(d$mse_V1 / d$mse_L); se <- sd(lr) / sqrt(nrow(d))
    data.frame(d[1, c("bl", "noise", "tau")], seeds = nrow(d), mse_L = mean(d$mse_L), mse_V1 = mean(d$mse_V1), ratio = exp(mean(lr)), lo = exp(mean(lr) - 2 * se), hi = exp(mean(lr) + 2 * se),
               cover_L = mean(d$cover_L), cover_V1 = mean(d$cover_V1), lam_L = mean(d$lam_mean_L), lam_V1 = d$lam_mean_V1[1]) }))
  write.csv(A, file.path(OUT, "V1_vs_L.csv"), row.names = FALSE)
  cat(sprintf("== V1 vs L (n = 500): median ratio %.3f, max %.2f, cells > 1.25: %d of %d -> %s ==\n", median(A$ratio), max(A$ratio), sum(A$ratio > 1.25), nrow(A),
              if (median(A$ratio) <= 1.10 && max(A$ratio) <= 1.25) "passes rule 1" else "REJECTED (data)"))
  print(A, digits = 3, row.names = FALSE)
}
# ---- V2 vs C (his constant b0), n = 1000 / 2000, seed 1, 2 chains each ----
VC <- which(R$arm %in% c("V2", "C"))
if (length(VC)) {
  sig0n <- function(n, tau) mean((1 + (seq_len(n) / n)^2) / 4) * dnorm(qnorm(tau))          # Normal family: E rho_tau(eps - q) = s(u) phi(z_tau)
  sbar <- function(n, tau) tau * (1 - tau) / min(dnorm(qnorm(tau)) / ((1 + (seq_len(n) / n)^2) / 4))
  Rr <- R[VC, ]; Rr$idx <- VC
  P <- do.call(rbind, lapply(split(Rr, Rr[, c("arm", "n", "bl", "tau")], drop = TRUE), function(d) {
    bn <- burn_of(d$bl[1]); tr <- lapply(d$idx, function(i) { t <- O[[i]]$lam_trace; t[(bn / 10 + 1):length(t)] })
    k <- min(lengths(tr)); M <- sapply(tr, function(t) log(t[seq_len(k)])); thr <- 1.6e-5 * d$n[1]^2.5
    data.frame(arm = d$arm[1], n = d$n[1], bl = d$bl[1], tau = d$tau[1], chains = nrow(d), mse = mean(d$mse), mse_c1 = d$mse[1], mse_c2 = if (nrow(d) > 1) d$mse[2] else NA,
               cover = mean(d$cover), width = mean(d$mciw), lam_med = median(exp(M)), lamsig = mean(d$lamsig_mean),
               sig_s0 = mean(d$sig_med) / sig0n(d$n[1], d$tau[1]), sig_sbar = mean(d$sig_med) / sbar(d$n[1], d$tau[1]),
               ess_loglam = sum(d$ess_loglam), rhat_loglam = if (ncol(M) > 1) rhat(M) else NA, p_below_floor = mean(exp(M) < thr), b0 = d$b0[1], sec = mean(d$seconds))
  }))
  P <- P[order(P$bl, P$n, P$tau, P$arm), ]; write.csv(P, file.path(OUT, "V2_pilot_cells.csv"), row.names = FALSE)
  cat("\n== V2 pilot: per arm and cell (MSE averaged over the 2 chains; ESS = sum over chains of single-chain ESS of the thinned post-burn trace; Rhat over 2 chains) ==\n")
  print(P, digits = 3, row.names = FALSE)
  W <- merge(P[P$arm == "V2", ], P[P$arm == "C", ], by = c("n", "bl", "tau"), suffixes = c("_V2", "_C"))
  W$ratio <- W$mse_V2 / W$mse_C; write.csv(W, file.path(OUT, "V2_vs_C.csv"), row.names = FALSE)
  cat("\n== V2 / C MSE ratio per cell (1 seed; chain-averaged) ==\n"); print(W[, c("n", "bl", "tau", "mse_C", "mse_V2", "ratio", "lam_med_C", "lam_med_V2", "rhat_loglam_C", "rhat_loglam_V2", "ess_loglam_C", "ess_loglam_V2", "p_below_floor_V2")], digits = 3, row.names = FALSE)
  # lambda traces
  TR <- do.call(rbind, lapply(Rr$idx, function(i) { r <- R[i, ]; t <- O[[i]]$lam_trace
    data.frame(arm = r$arm, n = r$n, bl = r$bl, tau = r$tau, chain = factor(r$chain), sweep = (seq_along(t) - 1) * 10 + 1, lambda = t) }))
  TR$panel <- sprintf("%s · n = %d · τ = %.2f", TR$bl, TR$n, TR$tau)
  g <- ggplot(TR, aes(sweep, lambda, colour = arm, linetype = chain)) + geom_line(linewidth = 0.3, alpha = 0.8) + scale_y_log10() +
    facet_wrap(~panel, scales = "free", ncol = 2) + scale_colour_manual(values = c(C = "#0072B2", V2 = "#D55E00"), labels = c(C = "his constant b0", V2 = "V2: b0 (500/n)^{5/2}"), name = NULL) +
    labs(title = "λ traces, Felipe's sampler, Gaussian noise (INTERNAL)", x = "sweep", y = "λ (log scale)") + theme_minimal(base_size = 9) + theme(legend.position = "bottom")
  ggsave(file.path(OUT, "V2_lambda_traces.png"), g, width = 8, height = 9, dpi = 200, device = "png", type = "cairo")
}
