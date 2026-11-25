# E-10 quick head-to-head at n = 2000 from the finished calibration chains (HQ request, 2026-11-25 ~08:50):
# old = current sampler (polynomial ASIS move), new = spline ASIS move, q grid {10, 20, 40} cycled per sweep.
# Same data (seed 1) and chain seeds (1001, 1002) for both; lambda ~ Gamma(1, 1e-5), sigma ~ IG(0.1, 0.1), 30k sweeps / 10k burn-in.
# Usage: Rscript e10_h2h_n2000.R <folder with the per-chain .rds> <output folder>
suppressPackageStartupMessages(library(coda))
args <- commandArgs(trailingOnly = TRUE); in_dir <- args[1]; out <- args[2]; dir.create(out, showWarnings = FALSE, recursive = TRUE)
fs <- list.files(in_dir, pattern = "^n2000_.*_(poly|fixed)_c[12]\\.rds$", full.names = TRUE)
R <- lapply(fs, readRDS); names(R) <- vapply(R, `[[`, "", "id")
get <- function(base, tau, v) R[sprintf("n2000_%s_t%03d_%s_c%d", base, round(100 * tau), v, 1:2)]
post <- 10001:30000
rhat_from <- function(m, v, N) { W <- mean(v); B <- N * var(m); sqrt(((N - 1) / N * W + B / N) / W) }
split_rhat <- function(chains) { N <- min(lengths(chains)) %/% 2
  s <- unlist(lapply(chains, function(x) list(x[1:N], x[(N + 1):(2 * N)])), recursive = FALSE); rhat_from(vapply(s, mean, 0), vapply(s, var, 0), N) }
theta_rhat <- function(rs) { m <- do.call(cbind, lapply(rs, `[[`, "half_mean")); v <- do.call(cbind, lapply(rs, `[[`, "half_var")); N <- rs[[1]]$half_len
  W <- rowMeans(v); B <- N * apply(m, 1, var); sqrt(((N - 1) / N * W + B / N) / W) }

# ---- table: every n = 2000 cell with both samplers finished ----
rows <- list()
for (b in c("VS", "S", "PC")) for (tau in c(0.5, 0.75, 0.95)) for (v in c("poly", "fixed")) {
  rs <- get(b, tau, v); if (any(vapply(rs, is.null, TRUE))) next
  mins <- vapply(rs, function(r) r$seconds / 60, 0); tm <- sum(mins)
  le <- vapply(rs, function(r) r$lam_ess, 0); se <- vapply(rs, function(r) r$sig_ess, 0)
  thmed <- vapply(rs, function(r) median(r$ess_th), 0); thmin <- vapply(rs, function(r) min(r$ess_th), 0)
  est <- rowMeans(sapply(rs, `[[`, "est")); lo <- rowMeans(sapply(rs, `[[`, "lo")); hi <- rowMeans(sapply(rs, `[[`, "hi")); tr <- rs[[1]]$truth
  rh <- theta_rhat(rs)
  rows[[length(rows) + 1L]] <- data.frame(baseline = b, tau = tau, sampler = if (v == "poly") "old" else "new", q_grid = paste(rs[[1]]$q_grid, collapse = ","),
    lambda_mean = mean(unlist(lapply(rs, function(r) r$lambda[post]))),
    lambda_ess = sum(le), lambda_ess_per_min = sum(le) / tm, sigma_ess = sum(se), sigma_ess_per_min = sum(se) / tm,
    theta_ess_median = sum(thmed), theta_ess_median_per_min = sum(thmed) / tm, theta_ess_min = sum(thmin), theta_ess_min_per_min = sum(thmin) / tm,
    rhat_lambda = split_rhat(lapply(rs, function(r) r$lambda[post])), rhat_sigma = split_rhat(lapply(rs, function(r) r$sigma[post])),
    rhat_theta_median = median(rh), rhat_theta_max = max(rh),
    mse = mean((est - tr)^2), mse_chain1 = rs[[1]]$mse, mse_chain2 = rs[[2]]$mse,
    coverage = mean(tr >= lo & tr <= hi), band_width = mean(hi - lo), minutes_per_chain = mean(mins))
}
Tb <- do.call(rbind, rows)
write.csv(Tb, file.path(out, "h2h_n2000.csv"), row.names = FALSE)
f <- function(x, d) formatC(x, format = "f", digits = d, big.mark = ",")
md <- c("ESS columns sum the two chains (20k kept draws each); per-minute figures divide by the two chains' total run time. theta ESS is over the n = 2000 coordinates (median, min). MSE, coverage and band width use the two-chain posterior mean and 95% pointwise bands against the true quantile curve.", "",
  "| baseline | tau | sampler | lambda mean | lambda ESS (/min) | sigma ESS (/min) | theta ESS median (/min) | theta ESS min (/min) | split R-hat lambda / sigma / theta med / theta max | MSE | coverage | band width | min/chain |",
  "|---|---|---|---|---|---|---|---|---|---|---|---|---|")
for (i in seq_len(nrow(Tb))) { x <- Tb[i, ]
  md <- c(md, sprintf("| %s | %.2f | %s | %s | %s (%s) | %s (%s) | %s (%s) | %s (%s) | %s / %s / %s / %s | %s | %s | %s | %s |", x$baseline, x$tau, x$sampler,
    f(x$lambda_mean, 0), f(x$lambda_ess, 1), f(x$lambda_ess_per_min, 2), f(x$sigma_ess, 0), f(x$sigma_ess_per_min, 1),
    f(x$theta_ess_median, 0), f(x$theta_ess_median_per_min, 1), f(x$theta_ess_min, 0), f(x$theta_ess_min_per_min, 2),
    f(x$rhat_lambda, 2), f(x$rhat_sigma, 3), f(x$rhat_theta_median, 3), f(x$rhat_theta_max, 2),
    formatC(x$mse, format = "g", digits = 3), f(x$coverage, 3), f(x$band_width, 3), f(x$minutes_per_chain, 1))) }
writeLines(md, file.path(out, "h2h_n2000.md"))

# ---- one PNG per requested cell ----
cols <- c(old1 = "#1f77b4", old2 = "#6baed6", new1 = "#d62728", new2 = "#fc9272")
for (cl in list(c("S", 0.5), c("S", 0.75), c("VS", 0.75), c("VS", 0.95))) {
  b <- cl[1]; tau <- as.numeric(cl[2]); A <- list(old = get(b, tau, "poly"), new = get(b, tau, "fixed"))
  if (any(vapply(unlist(A, recursive = FALSE), is.null, TRUE))) next
  ch <- list(old1 = A$old[[1]], old2 = A$old[[2]], new1 = A$new[[1]], new2 = A$new[[2]])
  tr <- A$old[[1]]$truth; n <- length(tr); k <- c(1, 3, 5)                       # stored points n/10, n/2, 9n/10
  png(file.path(out, sprintf("h2h_n2000_%s_t%03d.png", b, round(100 * tau))), width = 2400, height = 3600, res = 150)
  layout(matrix(c(1, 1, 2, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 13), ncol = 2, byrow = TRUE), heights = c(1, 1, 1, 1, 1, 1, 1, 1.4))
  par(mar = c(3.5, 4.2, 2.2, 1), mgp = c(2.2, 0.7, 0), oma = c(0, 0, 3, 0))
  ttl <- sprintf("n = 2000 | %s | tau = %.2f | old = polynomial ASIS (blue), new = spline ASIS q {10,20,40} (red) | 2 chains each", b, tau)
  yl <- range(unlist(lapply(ch, `[[`, "lambda")))
  plot(NA, xlim = c(1, 30000), ylim = yl, log = "y", xlab = "sweep", ylab = "lambda", main = "lambda trace (all sweeps, log scale; burn-in left of the dashed line)")
  for (nm in names(ch)) lines(ch[[nm]]$lambda, col = cols[nm]); abline(v = 10000, lty = 2)
  legend("bottomright", names(ch), col = cols, lwd = 2, bty = "n", ncol = 4, cex = 0.9)
  ys <- range(unlist(lapply(ch, function(r) r$sigma[-(1:500)])))
  plot(NA, xlim = c(1, 30000), ylim = ys, xlab = "sweep", ylab = "sigma", main = "sigma trace (first 500 sweeps not shown)")
  for (nm in names(ch)) lines(ch[[nm]]$sigma, col = cols[nm]); abline(v = 10000, lty = 2)
  for (j in k) for (s in c("old", "new")) {
    yv <- range(c(unlist(lapply(ch, function(r) r$theta_pts[, j])), tr[A$old[[1]]$pts[j]]))
    plot(NA, xlim = c(1, 20000), ylim = yv, xlab = "kept sweep", ylab = "theta",
         main = sprintf("%s: theta[%d] trace (kept draws), truth = black", s, A$old[[1]]$pts[j]))
    for (c_ in 1:2) lines(A[[s]][[c_]]$theta_pts[, j], col = cols[paste0(s, c_)]); abline(h = tr[A$old[[1]]$pts[j]], lwd = 2)
  }
  for (s in c("old", "new")) { r <- A[[s]][[1]]
    acf(r$lambda[post], lag.max = 2000, main = sprintf("%s: ACF of lambda (chain 1, kept draws)", s), col = cols[paste0(s, 1)]) }
  ll <- lapply(A, function(a) log10(unlist(lapply(a, function(r) r$lambda[post])))); br <- seq(min(unlist(ll)), max(unlist(ll)), length.out = 80)
  hist(ll$old, breaks = br, col = adjustcolor(cols["old1"], 0.5), border = NA, freq = FALSE, xlab = "log10 lambda",
       main = "posterior of lambda (kept draws, both chains; old blue, new red)", ylim = c(0, max(hist(ll$old, br, plot = FALSE)$density, hist(ll$new, br, plot = FALSE)$density)))
  hist(ll$new, breaks = br, col = adjustcolor(cols["new1"], 0.5), border = NA, freq = FALSE, add = TRUE)
  sl <- lapply(A, function(a) unlist(lapply(a, function(r) r$sigma[post]))); qr_ <- quantile(unlist(sl), c(0.005, 0.995))
  sl <- lapply(sl, function(v) v[v >= qr_[1] & v <= qr_[2]]); br <- seq(qr_[1], qr_[2], length.out = 80)
  hist(sl$old, breaks = br, col = adjustcolor(cols["old1"], 0.5), border = NA, freq = FALSE, xlab = "sigma",
       main = "posterior of sigma (kept draws, both chains; central 99% of the pooled draws)", ylim = c(0, max(hist(sl$old, br, plot = FALSE)$density, hist(sl$new, br, plot = FALSE)$density)))
  hist(sl$new, breaks = br, col = adjustcolor(cols["new1"], 0.5), border = NA, freq = FALSE, add = TRUE)
  x <- seq_len(n); y <- A$old[[1]]$y
  plot(x, y, pch = 16, cex = 0.25, col = "grey75", xlab = "index", ylab = "y", main = "fit: posterior mean and 95% pointwise band vs truth (black)")
  for (s in c("old", "new")) { est <- rowMeans(sapply(A[[s]], `[[`, "est")); lo <- rowMeans(sapply(A[[s]], `[[`, "lo")); hi <- rowMeans(sapply(A[[s]], `[[`, "hi"))
    polygon(c(x, rev(x)), c(lo, rev(hi)), col = adjustcolor(cols[paste0(s, 1)], 0.3), border = NA); lines(x, est, col = cols[paste0(s, 1)], lwd = 1.2) }
  lines(x, tr, lwd = 1.5)
  tb <- Tb[Tb$baseline == b & Tb$tau == tau, ]
  legend("topleft", bty = "n", cex = 0.95, legend = sprintf("%s: MSE %.5f | coverage %.3f | band width %.3f | lambda ESS %.1f", tb$sampler, tb$mse, tb$coverage, tb$band_width, tb$lambda_ess),
         text.col = c(cols["old1"], cols["new1"])[match(tb$sampler, c("old", "new"))])
  mtext(ttl, outer = TRUE, cex = 1.05, font = 2)
  dev.off()
}
print(Tb[, c("baseline", "tau", "sampler", "lambda_mean", "lambda_ess", "rhat_lambda", "mse", "coverage", "band_width")], digits = 3, row.names = FALSE)
