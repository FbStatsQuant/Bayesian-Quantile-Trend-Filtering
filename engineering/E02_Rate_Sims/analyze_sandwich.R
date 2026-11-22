# E-02 free test (Fable / HQ): frequentist variance of the posterior mean across replicates vs the posterior spread, Gaussian
# noise, tau = 1/2, sigma = sigma0.  Prediction: ratio ~ pi/2 (sandwich vs posterior variance for the ALD working likelihood).
#   rough ratio = mean_i Var_seeds( (theta_bar - LSquad(theta_bar))_i ) / mean_seeds(rough_spread)
#   total ratio = mean_i Var_seeds( theta_bar_i ) / mean_seeds(total_spread)
suppressPackageStartupMessages(library(data.table)); G <- Sys.getenv("E02_GRID"); options(width = 200)
cells <- rbind(data.table(ph = "T3", pat = "^(sin|PQT)_g25_t050_b(2|9_4|15_7)_n"),
               data.table(ph = "p1", pat = "^(sin|pq|quad)_gauss_t050_a(15_7|9_4|7_3)_n"),
               data.table(ph = "lamcurve", pat = "^(sin|pq|quad)_gauss_t050_L0[4-8]_n"))
out <- list()
for (k in seq_len(nrow(cells))) {
  f <- list.files(file.path(G, cells$ph[k]), pattern = cells$pat[k], full.names = TRUE)
  key <- sub("_s[0-9]+\\.rds$", "", basename(f)); grp <- split(f, key)
  for (g in names(grp)) {
    ff <- grp[[g]]; if (length(ff) < 8) next
    L <- lapply(ff, readRDS); n <- length(L[[1]]$post_mean)
    PM <- do.call(rbind, lapply(L, `[[`, "post_mean")); rows <- rbindlist(lapply(L, function(o) as.data.table(o$row)), fill = TRUE)
    X <- qr.Q(qr(cbind(1, seq_len(n) / n, (seq_len(n) / n)^2))); PMr <- PM - (PM %*% X) %*% t(X)
    out[[length(out) + 1]] <- data.table(phase = cells$ph[k], cell = g, n = n, reps = nrow(PM), nl = n * mean(rows$lambda)^(-1/3),
      rough_ratio = mean(apply(PMr, 2, var)) / mean(rows$rough_spread), total_ratio = mean(apply(PM, 2, var)) / mean(rows$total_spread),
      quad_ratio = mean(apply(PM - PMr, 2, var)) / (mean(rows$total_spread) - mean(rows$rough_spread)))   # unpenalised (null-space) directions
  }
}
R <- rbindlist(out); setorder(R, phase, cell)
cat("pi/2 =", pi / 2, "\n"); print(R[, .(cells = .N, rough_median = round(median(rough_ratio), 3), rough_range = paste(round(range(rough_ratio), 3), collapse = "-"),
            total_median = round(median(total_ratio), 3), total_range = paste(round(range(total_ratio), 3), collapse = "-"),
            quad_median = round(median(quad_ratio), 3), quad_iqr = paste(round(quantile(quad_ratio, c(.25, .75)), 3), collapse = "-")), by = phase])
cat("\nmany-mode cells only (n lambda^-1/3 >= 10):\n"); print(R[nl >= 10, .(cells = .N, rough_median = round(median(rough_ratio), 3), rough_iqr = paste(round(quantile(rough_ratio, c(.25, .75)), 3), collapse = "-"),
            total_median = round(median(total_ratio), 3), quad_median = round(median(quad_ratio), 3), quad_iqr = paste(round(quantile(quad_ratio, c(.25, .75)), 3), collapse = "-"))])
fwrite(R, file.path(Sys.getenv("E02_OUT"), "analysis", "sandwich_ratio.csv"))
