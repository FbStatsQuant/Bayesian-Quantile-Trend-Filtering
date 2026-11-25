# E-10 analysis: calibration table of the q rules, worst-case choice of the rule, and the head-to-head report
# (new sampler = chosen rule vs Felipe's standard = polynomial ASIS, same data, chain seeds and settings otherwise).
# Usage: Rscript e10_analyze.R <out folder with the per-chain .rds> <report folder>
suppressPackageStartupMessages(library(coda))
args <- commandArgs(trailingOnly = TRUE)
out_dir <- if (length(args) >= 1) args[1] else "engineering/E10_Lambda_Mixing/out"
rep_dir <- if (length(args) >= 2) args[2] else "engineering/E10_Lambda_Mixing"
tab_dir <- file.path(rep_dir, "tables"); h2h_dir <- file.path(rep_dir, "head_to_head"); fig_dir <- file.path(h2h_dir, "figs")
for (d in c(tab_dir, h2h_dir, fig_dir)) dir.create(d, showWarnings = FALSE, recursive = TRUE)

files <- list.files(out_dir, pattern = "^n[0-9]+_.*_c[12]\\.rds$", full.names = TRUE)
R <- lapply(files, readRDS); names(R) <- vapply(R, `[[`, "", "id")
key <- function(r) with(r$task, sprintf("n%d_%s_t%03d", n, baseline, round(100 * tau)))
post_of <- function(r) (r$burn + 1):r$sweeps
cat(sprintf("%d chain files\n", length(R)))

# split R-hat from M sequences of equal length N (means m, variances v)
rhat_from <- function(m, v, N) { W <- mean(v); B <- N * var(m); sqrt(((N - 1) / N * W + B / N) / W) }
split_rhat <- function(chains) {                # list of numeric vectors (post burn-in)
  N <- min(lengths(chains)) %/% 2
  seqs <- unlist(lapply(chains, function(x) list(x[1:N], x[(N + 1):(2 * N)])), recursive = FALSE)
  rhat_from(vapply(seqs, mean, 0), vapply(seqs, var, 0), N)
}
theta_rhat <- function(rs) {                    # per-coordinate split R-hat from the stored half-chain moments
  m <- do.call(cbind, lapply(rs, `[[`, "half_mean")); v <- do.call(cbind, lapply(rs, `[[`, "half_var")); N <- rs[[1]]$half_len
  W <- rowMeans(v); B <- N * apply(m, 1, var); sqrt(((N - 1) / N * W + B / N) / W)
}

# ---- per (cell, variant) summary over the 2 chains ----------------------------------------------------------------------
cells <- unique(vapply(R, key, "")); variants <- unique(vapply(R, function(r) r$task$variant, ""))
rows <- list()
for (cl in cells) for (v in variants) {
  rs <- Filter(function(r) key(r) == cl && r$task$variant == v, R)
  if (length(rs) < 2) next
  tk <- rs[[1]]$task; mins <- vapply(rs, function(r) r$seconds / 60, 0)
  lam_ess <- vapply(rs, `[[`, 0, "lam_ess"); sig_ess <- vapply(rs, `[[`, 0, "sig_ess")
  th_med <- vapply(rs, function(r) median(r$ess_th), 0); th_min <- vapply(rs, function(r) min(r$ess_th), 0)
  mse <- vapply(rs, `[[`, 0, "mse")
  est <- rowMeans(sapply(rs, `[[`, "est")); lo <- rowMeans(sapply(rs, `[[`, "lo")); hi <- rowMeans(sapply(rs, `[[`, "hi"))
  rh_th <- theta_rhat(rs)
  rows[[length(rows) + 1L]] <- data.frame(cell = cl, n = tk$n, baseline = tk$baseline, tau = tk$tau, variant = v,
    q_grid = paste(rs[[1]]$q_grid, collapse = ","),
    minutes = mean(mins), ms_per_sweep = 1e3 * mean(mins) * 60 / rs[[1]]$sweeps,
    mse = mean(mse), mse_c1 = mse[1], mse_c2 = mse[2], mse_pooled = mean((est - rs[[1]]$truth)^2),
    coverage = mean(vapply(rs, `[[`, 0, "coverage")), width = mean(vapply(rs, `[[`, 0, "width")),
    lam_ess = sum(lam_ess), lam_ess_min = sum(lam_ess) / sum(mins), lam_ess_min_worst_chain = min(lam_ess / mins),
    sig_ess = sum(sig_ess), sig_ess_min = sum(sig_ess) / sum(mins),
    th_ess_med = mean(th_med), th_ess_med_min = sum(th_med) / sum(mins), th_ess_min = min(th_min),
    rhat_lam = split_rhat(lapply(rs, function(r) r$lambda[post_of(r)])), rhat_sig = split_rhat(lapply(rs, function(r) r$sigma[post_of(r)])),
    rhat_th_med = median(rh_th), rhat_th_max = max(rh_th),
    acc = mean(vapply(rs, `[[`, 0, "acc_post")), lam_mean = mean(unlist(lapply(rs, function(r) r$lambda[post_of(r)]))))
}
S <- do.call(rbind, rows); S <- S[order(S$n, S$baseline, S$tau, S$variant), ]
write.csv(S, file.path(tab_dir, "per_cell_variant.csv"), row.names = FALSE)

# ---- calibration: each candidate vs the current sampler (poly) in every cell ------------------------------------------
base <- S[S$variant == "poly", ]; cand <- setdiff(unique(S$variant), "poly")
cmp <- do.call(rbind, lapply(cand, function(v) {
  # at n = 500 all candidate grids coincide ({10, 20, 40}); the "fixed" runs stand in for every candidate there
  do.call(rbind, lapply(seq_len(nrow(base)), function(i) {
    b <- base[i, ]; vv <- if (b$n == 500) "fixed" else v
    x <- S[S$cell == b$cell & S$variant == vv, ]; if (!nrow(x)) return(NULL)
    noise <- (abs(b$mse_c1 - b$mse_c2) + abs(x$mse_c1 - x$mse_c2)) / 2     # chain-to-chain (MC) spread of the MSE in this cell
    data.frame(variant = v, cell = b$cell, n = b$n, baseline = b$baseline, tau = b$tau, q_grid = x$q_grid,
               lam_ess_min_ratio = x$lam_ess_min / b$lam_ess_min, lam_ess_min_ratio_worst_chain = x$lam_ess_min_worst_chain / b$lam_ess_min_worst_chain,
               th_ess_med_ratio = x$th_ess_med / b$th_ess_med, sig_ess_ratio = x$sig_ess / b$sig_ess,
               mse_ratio = x$mse / b$mse, mse_excess_over_noise = (x$mse - b$mse) / max(noise, 1e-12),
               mse_worse = (x$mse - b$mse) > 2 * noise + 0.02 * b$mse,
               coverage_new = x$coverage, coverage_cur = b$coverage, time_ratio = x$minutes / b$minutes)
  }))
}))
write.csv(cmp, file.path(tab_dir, "calibration_vs_current.csv"), row.names = FALSE)
gm <- function(x) exp(mean(log(x)))
summ <- do.call(rbind, lapply(split(cmp, cmp$variant), function(d) data.frame(variant = d$variant[1],
  cells = nrow(d), worst_lam_ess_min_ratio = min(d$lam_ess_min_ratio), worst_cell = d$cell[which.min(d$lam_ess_min_ratio)],
  cells_below_current = sum(d$lam_ess_min_ratio < 1), gmean_lam_ess_min_ratio = gm(d$lam_ess_min_ratio),
  worst_th_ess_ratio = min(d$th_ess_med_ratio), gmean_th_ess_ratio = gm(d$th_ess_med_ratio),
  cells_mse_worse = sum(d$mse_worse), worst_mse_ratio = max(d$mse_ratio), gmean_mse_ratio = gm(d$mse_ratio),
  worst_time_ratio = max(d$time_ratio))))
# per-sweep cost vs n (log-log slope) for every variant: "still about linear in n" means slope ~ 1
slopes <- do.call(rbind, lapply(split(S, S$variant), function(d) {
  a <- aggregate(ms_per_sweep ~ n, d, mean); data.frame(variant = d$variant[1], slope_log_ms_vs_log_n = unname(coef(lm(log(ms_per_sweep) ~ log(n), a))[2]),
                                                       ms_500 = a$ms_per_sweep[a$n == 500][1], ms_2000 = a$ms_per_sweep[a$n == 2000][1], ms_5000 = a$ms_per_sweep[a$n == 5000][1]) }))
summ <- merge(summ, slopes, by = "variant", all.x = TRUE)
# rule choice: admissible = no cell below the current sampler on lambda-ESS/min, no MSE-worse cell, theta-ESS not worse (>= 0.9 everywhere);
# among admissible rules the largest worst-case lambda-ESS/min ratio wins (geometric mean breaks near-ties within 5%)
summ$admissible <- summ$cells_below_current == 0 & summ$cells_mse_worse == 0 & summ$worst_th_ess_ratio >= 0.9
summ <- summ[order(-summ$admissible, -summ$worst_lam_ess_min_ratio), ]
pool <- summ[summ$admissible, ]; if (!nrow(pool)) pool <- summ
top <- pool[pool$worst_lam_ess_min_ratio >= 0.95 * max(pool$worst_lam_ess_min_ratio), ]
chosen <- top$variant[which.max(top$gmean_lam_ess_min_ratio)]
summ$chosen <- summ$variant == chosen
write.csv(summ, file.path(tab_dir, "rule_summary.csv"), row.names = FALSE)
cat("\n==== rule summary (worst case over cells vs the current sampler) ====\n"); print(summ, digits = 3, row.names = FALSE)
cat(sprintf("\nCHOSEN RULE: %s\n", chosen))

# ---- head-to-head: chosen rule (new) vs poly (standard) ---------------------------------------------------------------
pick <- function(cl, n) { v <- if (n == 500) "fixed" else chosen; S[S$cell == cl & S$variant == v, ] }
H <- do.call(rbind, lapply(seq_len(nrow(base)), function(i) {
  b <- base[i, ]; x <- pick(b$cell, b$n)
  f <- function(d, lab) data.frame(n = d$n, baseline = d$baseline, tau = d$tau, sampler = lab, q_grid = d$q_grid,
    mse = d$mse, coverage = d$coverage, band_width = d$width,
    lambda_ess = d$lam_ess, lambda_ess_per_min = d$lam_ess_min, sigma_ess = d$sig_ess, sigma_ess_per_min = d$sig_ess_min,
    theta_ess_median = d$th_ess_med, theta_ess_median_per_min = d$th_ess_med_min, theta_ess_min = d$th_ess_min,
    rhat_lambda = d$rhat_lam, rhat_sigma = d$rhat_sig, rhat_theta_median = d$rhat_th_med, rhat_theta_max = d$rhat_th_max,
    minutes_per_chain = d$minutes)
  rbind(f(b, "standard"), f(x, "new"))
}))
write.csv(H, file.path(h2h_dir, "head_to_head.csv"), row.names = FALSE)

# markdown table for the README
fmt <- function(x, d) formatC(x, format = "f", digits = d)
md <- c("| n | baseline | tau | sampler | MSE | coverage | band width | lambda ESS (/min) | sigma ESS (/min) | theta ESS median (/min) | R-hat lambda / sigma / theta med / theta max | min per chain |",
        "|---|---|---|---|---|---|---|---|---|---|---|---|")
for (i in seq_len(nrow(H))) { h <- H[i, ]
  md <- c(md, sprintf("| %d | %s | %.2f | %s | %s | %s | %s | %s (%s) | %s (%s) | %s (%s) | %s / %s / %s / %s | %s |", h$n, h$baseline, h$tau, h$sampler,
    formatC(h$mse, format = "g", digits = 3), fmt(h$coverage, 3), fmt(h$band_width, 3), fmt(h$lambda_ess, 0), fmt(h$lambda_ess_per_min, 2),
    fmt(h$sigma_ess, 0), fmt(h$sigma_ess_per_min, 1), fmt(h$theta_ess_median, 0), fmt(h$theta_ess_median_per_min, 1),
    fmt(h$rhat_lambda, 3), fmt(h$rhat_sigma, 3), fmt(h$rhat_theta_median, 3), fmt(h$rhat_theta_max, 3), fmt(h$minutes_per_chain, 1))) }
writeLines(md, file.path(h2h_dir, "head_to_head_table.md"))

# ---- figures for representative cells ---------------------------------------------------------------------------------
rep_cells <- c("n500_VS_t075", "n5000_VS_t075", "n2000_PC_t095", "n500_S_t095")
col2 <- c("#1f77b4", "#d62728")
for (cl in intersect(rep_cells, cells)) {
  nn <- as.integer(sub("^n([0-9]+)_.*", "\\1", cl)); vnew <- if (nn == 500) "fixed" else chosen
  get2 <- function(v) Filter(function(r) key(r) == cl && r$task$variant == v, R)
  A <- list(standard = get2("poly"), new = get2(vnew)); if (any(lengths(A) < 2)) next
  ttl <- function(lab) sprintf("%s | %s (q %s)", cl, lab, paste(A[[lab]][[1]]$q_grid, collapse = ","))
  png(file.path(fig_dir, paste0(cl, "_traces.png")), width = 1800, height = 2000, res = 140)
  par(mfrow = c(7, 2), mar = c(3, 4, 2, 1), mgp = c(2, 0.6, 0))
  for (what in c("lambda", "sigma")) for (lab in names(A)) {
    rr <- A[[lab]]; yl <- range(unlist(lapply(A, function(a) lapply(a, function(r) r[[what]][post_of(r)]))))
    plot(rr[[1]][[what]], type = "l", col = col2[1], log = if (what == "lambda") "y" else "", ylim = if (what == "lambda") yl else NULL,
         main = sprintf("%s: %s trace (2 chains)", ttl(lab), what), xlab = "sweep", ylab = what)
    lines(rr[[2]][[what]], col = adjustcolor(col2[2], 0.7)); abline(v = rr[[1]]$burn, lty = 3)
  }
  for (k in 1:5) for (lab in names(A)) { r <- A[[lab]][[1]]
    plot(r$theta_pts[, k], type = "l", col = col2[1], main = sprintf("%s: theta[%d] (chain 1, post burn-in)", lab, r$pts[k]), xlab = "kept sweep", ylab = "theta") }
  dev.off()
  png(file.path(fig_dir, paste0(cl, "_acf_hist.png")), width = 1800, height = 1300, res = 140)
  par(mfrow = c(3, 2), mar = c(3.5, 4, 2, 1), mgp = c(2, 0.6, 0))
  for (lab in names(A)) { r <- A[[lab]][[1]]; acf(r$lambda[post_of(r)], lag.max = 500, main = sprintf("%s: ACF of lambda (chain 1)", ttl(lab))) }
  for (what in c("lambda", "sigma")) {
    pooled <- lapply(A, function(a) unlist(lapply(a, function(r) r[[what]][post_of(r)])))
    br <- seq(min(unlist(pooled)), max(unlist(pooled)), length.out = 60)
    for (lab in names(A)) hist(pooled[[lab]], breaks = br, col = adjustcolor(col2[match(lab, names(A))], 0.5), border = NA, freq = FALSE,
                               main = sprintf("%s: posterior of %s (2 chains pooled)", lab, what), xlab = what)
  }
  dev.off()
  png(file.path(fig_dir, paste0(cl, "_fit.png")), width = 1800, height = 650, res = 140)
  par(mfrow = c(1, 2), mar = c(3.5, 4, 2, 1), mgp = c(2, 0.6, 0))
  for (lab in names(A)) { rr <- A[[lab]]; r <- rr[[1]]; x <- seq_along(r$y)
    est <- rowMeans(sapply(rr, `[[`, "est")); lo <- rowMeans(sapply(rr, `[[`, "lo")); hi <- rowMeans(sapply(rr, `[[`, "hi"))
    plot(x, r$y, pch = 16, cex = 0.3, col = "grey70", xlab = "index", ylab = "y",
         main = sprintf("%s | MSE %.5f | coverage %.3f", ttl(lab), mean((est - r$truth)^2), mean(r$truth >= lo & r$truth <= hi)))
    polygon(c(x, rev(x)), c(lo, rev(hi)), col = adjustcolor(col2[match(lab, names(A))], 0.25), border = NA)
    lines(x, r$truth, lwd = 1.5); lines(x, est, col = col2[match(lab, names(A))], lwd = 1.5, lty = 2) }
  dev.off()
}
cat("done\n")
