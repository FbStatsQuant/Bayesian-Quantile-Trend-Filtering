# E-06 analysis: slopes of the Delta2 contraction radius against n, paired-bootstrap CIs, paper table + figure.
# Reads $E06_OUT/grid/{main,supp}/*.rds; writes into $E06_RES (default: this folder) tables/ and figs/.
#   E06_LOGC: exponent c of the log factor in eps_n^2 = (log n)^c ..., used only for the descriptive log-adjusted slope.
E06_OUT <- Sys.getenv("E06_OUT", "/home/fb31/BQTF_runs/E06")
E06_RES <- Sys.getenv("E06_RES", Sys.getenv("E06_DIR", "/home/fb31/Bayesian-Quantile-Trend-Filtering/engineering/E06_Rate_Validation"))
PRED <- c(primary = -5/6, fallback = -3/4, padilla = -5/7)
LOGC <- as.numeric(Sys.getenv("E06_LOGC", as.character(1/6)))   # Theory: headline c = 0 (plain slope); c = 1/6 sensitivity
B <- 2000L; MS <- c(1, 2, 4)
dir.create(file.path(E06_RES, "tables"), showWarnings = FALSE); dir.create(file.path(E06_RES, "figs"), showWarnings = FALSE)
files <- list.files(file.path(E06_OUT, "grid"), pattern = "\\.rds$", recursive = TRUE, full.names = TRUE)
files <- files[!grepl("/smoke/", files)]   # main + supp_r (+ supp if ever run)
obj <- lapply(files, readRDS)
R <- do.call(rbind, lapply(obj, `[[`, "row"))
R$cfg <- with(R, paste(truth, noise, sprintf("t%03d", round(100 * tau)), sched, arm, sep = "_"))
# regime diagnostics (HQ): many-mode n*lambda^(-1/3) >= 10; kernel width w/n with w = (lambda^2/kappa)^(1/6), kappa = f(q)/sigma
# (f(q) = tau(1-tau)/sigma_bar); bias^2/risk = centre Delta2 / posterior-mean Delta2; split R-hat of the thinned Delta2 trace.
R$nl <- R$n * R$lambda^(-1/3)
R$kappa <- R$tau * (1 - R$tau) / R$sigma_bar / R$sigma
R$w_n <- (R$lambda^2 / R$kappa)^(1/6) / R$n
R$bias_frac <- R$centre_d2 / R$d2_mean
split_rhat <- function(x) { h <- length(x) %/% 2; ch <- cbind(x[1:h], x[(h + 1):(2 * h)]); W <- mean(apply(ch, 2, var))
  Bv <- h * var(colMeans(ch)); sqrt(((h - 1) / h * W + Bv / h) / W) }
R$rhat_d2 <- sapply(obj, function(o) split_rhat(o$d2))
cat(sprintf("%d fits, %d configs; failed/missing cells are listed below\n", nrow(R), length(unique(R$cfg))))
cnt <- table(R$cfg, R$n); print(cnt[apply(cnt, 1, function(r) any(r < 20)), , drop = FALSE])

# ---- slopes with paired bootstrap over seeds -----------------------------------------------------------------
slope <- function(n, y) unname(coef(lm(log(y) ~ log(n)))[2])
cfg_slopes <- function(d, meas) {
  W <- reshape(d[, c("n", "seed", meas)], idvar = "seed", timevar = "n", direction = "wide")  # seeds x n
  W <- W[complete.cases(W), ]; ns <- as.numeric(sub(paste0(meas, "."), "", names(W)[-1], fixed = TRUE)); Y <- as.matrix(W[, -1])
  med <- apply(Y, 2, median)
  set.seed(606); bs <- replicate(B, { i <- sample(nrow(Y), replace = TRUE); slope(ns, apply(Y[i, , drop = FALSE], 2, median)) })
  bl <- replicate(B, { i <- sample(nrow(Y), replace = TRUE); apply(Y[i, , drop = FALSE], 2, median) })
  list(ns = ns, med = med, lo = apply(bl, 1, quantile, 0.025), hi = apply(bl, 1, quantile, 0.975),
       slope = slope(ns, med), ci = unname(quantile(bs, c(0.025, 0.975))),
       slope_logadj = slope(ns, med / log(ns)^LOGC), nseed = nrow(Y))
}
meta <- unique(R[, c("cfg", "truth", "noise", "tau", "sched", "arm", "a", "pred")])
S <- do.call(rbind, lapply(seq_len(nrow(meta)), function(j) {
  d <- R[R$cfg == meta$cfg[j], ]
  q <- cfg_slopes(d, "d2_q95"); m <- cfg_slopes(d, "d2_mean"); e <- cfg_slopes(d, "mse_q95"); rr <- cfg_slopes(d, "d2r_q95")
  data.frame(meta[j, ], nseed = q$nseed, n_min = min(q$ns), n_max = max(q$ns),
             slope_q95 = q$slope, lo_q95 = q$ci[1], hi_q95 = q$ci[2], slope_q95_logadj = q$slope_logadj,
             slope_mean = m$slope, lo_mean = m$ci[1], hi_mean = m$ci[2],
             slope_mse_q95 = e$slope, lo_mse_q95 = e$ci[1], hi_mse_q95 = e$ci[2],
             slope_rough_q95 = rr$slope, lo_rough_q95 = rr$ci[1], hi_rough_q95 = rr$ci[2],
             pred_in_ci = q$ci[1] <= meta$pred[j] & meta$pred[j] <= q$ci[2],
             ess_d2_min = min(d$ess_d2), rhat_max = max(d$rhat_d2), nl_min = min(d$nl), w_n_max = max(d$w_n),
             bias_frac_max = max(tapply(d$bias_frac, d$n, median)), pen_ratio_max = max(tapply(d$pen_ratio, d$n, median)),
             stringsAsFactors = FALSE)
}))
S <- S[order(S$truth, S$sched, S$arm, S$noise, S$tau), ]
# calibration cap (HQ): flag configs whose Lam_star was capped by the many-mode restriction
cal <- readRDS(file.path(E06_OUT, "calibration.rds"))
S$capped <- mapply(function(tr, nz, ta) isTRUE(cal$binding[cal$truth == tr & cal$noise == nz & cal$tau == ta]), S$truth, S$noise, S$tau)
invisible(file.copy(file.path(E06_OUT, "calibration_curves.csv"), file.path(E06_RES, "tables", "e06_calibration_curves.csv"), overwrite = TRUE))
write.csv(cal, file.path(E06_RES, "tables", "e06_calibration.csv"), row.names = FALSE)

# anomaly gate for launching phase supp (HQ): many-mode, ESS/R-hat at E-02 standards, no saturation
S$flag <- with(S, paste0(ifelse(nl_min < 10, "few-mode;", ""), ifelse(ess_d2_min < 110, "ESS;", ""), ifelse(rhat_max > 1.01, "Rhat;", ""),
                         ifelse(w_n_max > 0.1, "w/n;", ""), ifelse(pen_ratio_max > 1.1, "pen>1;", "")))
write.csv(S, file.path(E06_RES, "tables", "e06_slopes_all.csv"), row.names = FALSE)
cat(sprintf("\nGATE: %d of %d configs flagged\n", sum(S$flag != ""), nrow(S))); if (any(S$flag != "")) print(S[S$flag != "", c("cfg", "flag", "nl_min", "ess_d2_min", "rhat_max", "w_n_max", "pen_ratio_max")], digits = 3, row.names = FALSE)

# ---- exceedance P(Delta2 > M eps_n^2 | y), eps_n^2 = median q95 at n = 1k * (n / 1k)^pred -------------------------
R$file <- files
E <- do.call(rbind, lapply(seq_len(nrow(meta)), function(j) {
  idx <- which(R$cfg == meta$cfg[j]); d <- R[idx, ]; n1 <- min(d$n)
  e1 <- median(d$d2_q95[d$n == n1])
  do.call(rbind, lapply(sort(unique(d$n)), function(nn) {
    ii <- idx[R$n[idx] == nn]; eps2 <- e1 * (nn / n1)^meta$pred[j]
    p <- sapply(MS, function(M) mean(sapply(ii, function(i) mean(obj[[i]]$d2 > M * eps2))))
    data.frame(cfg = meta$cfg[j], n = nn, M = MS, p_exceed = p)
  }))
}))
write.csv(E, file.path(E06_RES, "tables", "e06_exceedance.csv"), row.names = FALSE)

# ---- paper outputs ----------------------------------------------------------------------------------------------
NOISE_TEX <- c(gauss = "Gaussian", laplace = "Laplace", t3 = "$t_3$", t2 = "$t_2$", cauchy = "Cauchy")
fmt <- function(s, lo, hi) sprintf("$%.2f$ {\\scriptsize $[%.2f, %.2f]$}", s, lo, hi)
main_table <- function(file, m = "q95") {
cell <- function(tr, nz, ta, sc, ar) { x <- S[S$truth == tr & S$noise == nz & S$tau == ta & S$sched == sc & S$arm == ar, ]
  if (!nrow(x)) "--" else fmt(x[[paste0("slope_", m)]], x[[paste0("lo_", m)]], x[[paste0("hi_", m)]]) }
tab <- c("\\begin{tabular}{llcccc}", "\\toprule",
         " & & \\multicolumn{2}{c}{piecewise quadratic} & \\multicolumn{2}{c}{sine} \\\\",
         "\\cmidrule(lr){3-4}\\cmidrule(lr){5-6}",
         "noise & $\\tau$ & $\\sigma = 1.1\\bar\\sigma$ & $\\sigma = \\sigma_0$ & $\\sigma = 1.1\\bar\\sigma$ & $\\sigma = \\sigma_0$ \\\\", "\\midrule")
for (nz in names(NOISE_TEX)) for (ta in c(0.5, 0.9))
  tab <- c(tab, sprintf("%s & %.1f & %s & %s & %s & %s \\\\", if (ta == 0.5) NOISE_TEX[[nz]] else "", ta,
                        cell("pq", nz, ta, "primary", "Abar"), cell("pq", nz, ta, "primary", "S0"),
                        cell("sin", nz, ta, "primary", "Abar"), cell("sin", nz, ta, "primary", "S0")))
tab <- c(tab, "\\bottomrule", "\\end{tabular}")
writeLines(tab, file)
}
main_table(file.path(E06_RES, "tables", "e06_main_table.tex"), "q95")
main_table(file.path(E06_RES, "tables", "e06_main_table_rough.tex"), "rough_q95")

# supplement: every config
SCHED_TEX <- c(primary = "$n^{5/2}/V$", fallback = "$(n^3/V)^{3/4}$", padilla = "Padilla")
ARM_TEX <- c(Abar = "$1.1\\bar\\sigma$", S0 = "$\\sigma_0$")
ex <- function(cfg, nn, M = 2) { x <- E[E$cfg == cfg & E$n == nn & E$M == M, "p_exceed"]; if (length(x)) sprintf("%.2f", x) else "--" }
sup <- c("\\begin{longtable}{lllllcccccc}", "\\toprule",
         "truth & noise & $\\tau$ & $\\lambda_n$ & $\\sigma$ & pred. & $\\hat q_n$ slope [95\\% CI] & log-adj. & rough $\\hat q_n$ slope & mean $\\Delta^2$ slope & $P_{1\\text{k}}/P_{32\\text{k}}$ \\\\",
         "\\midrule", "\\endhead")
for (j in seq_len(nrow(S))) { x <- S[j, ]
  sup <- c(sup, sprintf("%s & %s & %.1f & %s & %s & $%.3f$ & %s & $%.2f$ & %s & %s & %s/%s \\\\", paste0(x$truth, if (x$capped) "$^\\dagger$" else ""),
    NOISE_TEX[[x$noise]], x$tau, SCHED_TEX[[x$sched]], ARM_TEX[[x$arm]], x$pred, fmt(x$slope_q95, x$lo_q95, x$hi_q95),
    x$slope_q95_logadj, fmt(x$slope_rough_q95, x$lo_rough_q95, x$hi_rough_q95), fmt(x$slope_mean, x$lo_mean, x$hi_mean), ex(x$cfg, x$n_min), ex(x$cfg, x$n_max))) }
sup <- c(sup, "\\bottomrule", "\\multicolumn{11}{l}{\\footnotesize $^\\dagger$ calibration constant capped to keep $n\\lambda^{-1/3} \\ge 10$ in every cell (uncapped MAP-risk curves: \\texttt{calibration\\_curves.csv}).}", "\\end{longtable}")
writeLines(sup, file.path(E06_RES, "tables", "e06_supp_table.tex"))
dg <- c("\\begin{longtable}{lllllcccccc}", "\\toprule",
        "truth & noise & $\\tau$ & $\\lambda_n$ & $\\sigma$ & $\\min n\\lambda^{-1/3}$ & $\\max w/n$ & $\\max \\text{bias}^2/\\text{risk}$ & $\\max \\lambda\\|D\\theta\\|_1/m$ & min ESS & max $\\hat R$ \\\\",
        "\\midrule", "\\endhead")
for (j in seq_len(nrow(S))) { x <- S[j, ]
  dg <- c(dg, sprintf("%s & %s & %.1f & %s & %s & %.0f & %.3f & %.2f & %.2f & %.0f & %.3f \\\\", paste0(x$truth, if (x$capped) "$^\\dagger$" else ""), NOISE_TEX[[x$noise]], x$tau,
    SCHED_TEX[[x$sched]], ARM_TEX[[x$arm]], x$nl_min, x$w_n_max, x$bias_frac_max, x$pen_ratio_max, x$ess_d2_min, x$rhat_max)) }
dg <- c(dg, "\\bottomrule", "\\end{longtable}")
writeLines(dg, file.path(E06_RES, "tables", "e06_supp_diagnostics.tex"))

# headline figure: pq, Gaussian, tau = 1/2, sigma = 1.1 sigma_bar; three schedules
head_fig <- function(file, tr = "pq", nz = "gauss", ta = 0.5, ar = "Abar", meas = "d2_q95") {
  cols <- c(primary = "#1b6ca8", fallback = "#c0392b", padilla = "#6b6b6b"); pchs <- c(primary = 19, fallback = 17, padilla = 15)
  cur <- lapply(names(cols), function(sc) { d <- R[R$truth == tr & R$noise == nz & R$tau == ta & R$sched == sc & R$arm == ar, ]
    if (nrow(d)) cfg_slopes(d, meas) else NULL }); names(cur) <- names(cols); cur <- cur[!sapply(cur, is.null)]
  pdf(file, width = 5.2, height = 4, family = "serif", useDingbats = FALSE)
  par(mar = c(4, 4.4, 0.6, 0.6), mgp = c(2.4, 0.6, 0), tcl = -0.3, las = 1, cex = 0.95)
  yr <- range(unlist(lapply(cur, function(c) c(c$lo, c$hi)))); xr <- range(unlist(lapply(cur, `[[`, "ns")))
  plot(NA, xlim = xr * c(0.9, 1.1), ylim = yr * c(0.85, 1.15), log = "xy", xaxt = "n", yaxt = "n",
       xlab = expression(n), ylab = if (meas == "d2_q95") expression(hat(q)[n] ~ "(95% posterior quantile of " * Delta[n]^2 * ")")
                                     else expression(hat(q)[n]^symbol("\136") ~ "(95% posterior quantile of the rough part of " * Delta[n]^2 * ")"))
  axis(1, at = 1000 * 2^(0:5), labels = c("1k", "2k", "4k", "8k", "16k", "32k"))
  yt <- 10^seq(floor(log10(yr[1])), ceiling(log10(yr[2]))); axis(2, at = yt, labels = sapply(log10(yt), function(e) as.expression(bquote(10^.(e)))))
  axis(2, at = as.vector(outer(2:9, yt)), labels = FALSE, tcl = -0.15)
  for (sc in names(cur)) { c <- cur[[sc]]; p <- PRED[[sc]]
    gm <- exp(mean(log(c$ns))); y0 <- exp(mean(log(c$med)))                     # theory line through the data's centre
    curve(y0 * (x / gm)^p, from = xr[1] * 0.9, to = xr[2] * 1.1, add = TRUE, lty = 2, col = cols[[sc]], lwd = 1.1)
    arrows(c$ns, c$lo, c$ns, c$hi, angle = 90, code = 3, length = 0.025, col = cols[[sc]], lwd = 1)
    points(c$ns, c$med, pch = pchs[[sc]], col = cols[[sc]], cex = 0.9) }
  lg <- as.expression(lapply(names(cur), function(sc) { c <- cur[[sc]]; v <- sprintf("%.2f [%.2f, %.2f]", c$slope, c$ci[1], c$ci[2])
    switch(sc, primary  = bquote(lambda[n] %prop% n^{5/2}/V * ":  " * .(v) ~ "(theory " * -5/6 * ")"),
               fallback = bquote(lambda[n] %prop% (n^3/V)^{3/4} * ":  " * .(v) ~ "(theory " * -3/4 * ")"),
               padilla  = bquote("Padilla" ~ lambda[n] * ":  " * .(v) ~ "(theory " * -5/7 * ")")) }))
  legend("bottomleft", legend = lg, col = cols[names(cur)], pch = pchs[names(cur)], lty = 2, bty = "n", cex = 0.78, inset = 0.01)
  dev.off()
}
head_fig(file.path(E06_RES, "figs", "fig_e06_headline.pdf"))
head_fig(file.path(E06_RES, "figs", "fig_e06_headline_rough.pdf"), meas = "d2r_q95")
cat("\nPrimary-schedule slopes of q95 (pred -0.833):\n")
print(S[S$sched == "primary", c("truth", "noise", "tau", "arm", "slope_q95", "lo_q95", "hi_q95", "slope_q95_logadj", "slope_rough_q95", "lo_rough_q95", "hi_rough_q95", "slope_mean", "pred_in_ci")], digits = 3, row.names = FALSE)
cat("\nOther schedules:\n")
print(S[S$sched != "primary", c("truth", "noise", "tau", "sched", "arm", "pred", "slope_q95", "lo_q95", "hi_q95", "slope_rough_q95", "pred_in_ci")], digits = 3, row.names = FALSE)
cat("\nExceedance P(D2 > 2 eps_n^2), mean over seeds, by n (rows = configs):\n")
E2 <- E[E$M == 2, ]; print(round(xtabs(p_exceed ~ cfg + n, E2), 3))
