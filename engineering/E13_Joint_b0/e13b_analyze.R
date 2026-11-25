# E-13a phase 2: summarise the screen after the fixes (runs/E13b-joint-b0-fix-20261125/out/*.rds from e13b_run.R).
# Writes e13b_screen_runs.csv (one row per joint run x level), e13b_screen_table.md (compact table), e13b_reference.md (before/after).
# Usage: Rscript e13b_analyze.R [out dir]
suppressPackageStartupMessages(library(coda))
`%||%` <- function(a, b) if (is.null(a) || length(a) == 0) b else a
od <- commandArgs(trailingOnly = TRUE)[1]; if (is.na(od)) od <- "runs/E13b-joint-b0-fix-20261125/out"
ed <- "engineering/E13_Joint_b0"
TAUS <- c(0.3, 0.5, 0.7, 0.9); B0S <- c(1e-5, 1e-4, 1e-3)
rd <- function(id) { f <- file.path(od, paste0(id, ".rds")); if (file.exists(f)) readRDS(f) else NULL }
split_rhat <- function(chains) {                     # classic split R-hat (Gelman et al. 2013), chains = list of post-burn vectors
  s <- unlist(lapply(chains, function(v) { h <- floor(length(v) / 2); list(v[1:h], v[(h + 1):(2 * h)]) }), recursive = FALSE)
  nn <- length(s[[1]]); mu <- sapply(s, mean); W <- mean(sapply(s, var)); B <- nn * var(mu)
  sqrt(((nn - 1) / nn * W + B / nn) / W)
}
rows <- list()
for (b0 in B0S) for (v in c("poly", "fixed")) {
  jr <- lapply(1:2, function(ch) rd(sprintf("joint_%s_b%g_c%d", v, b0, ch)))
  ok <- vapply(jr, function(r) !is.null(r) && !isTRUE(r$crashed), TRUE)
  for (j in seq_along(TAUS)) {
    ind <- rd(sprintf("ind_%s_b%g_t%02d", v, b0, round(100 * TAUS[j])))
    post <- function(r) r$lambda[(r$burn + 1):r$iter, j]
    rh <- if (all(ok)) split_rhat(lapply(jr, post)) else NA
    for (ch in 1:2) {
      r <- jr[[ch]]
      if (is.null(r)) next
      g <- function(x) if (ok[ch]) x else NA
      rows[[length(rows) + 1L]] <- data.frame(b0 = b0, move = v, chain = ch, tau = TAUS[j],
        crashed = isTRUE(r$crashed), crash_sweep = if (isTRUE(r$crashed)) r$crash_sweep else NA, minutes = r$minutes,
        lambda = g(r$lambda_mean[j]), lambda_ind = ind$lambda_mean %||% NA, lambda_ratio = g(r$lambda_mean[j]) / (ind$lambda_mean %||% NA),
        sigma = g(r$sigma_mean[j]), sigma_ind = ind$sigma_mean %||% NA, sigma_max_after_warm = g(max(r$sigma[201:r$iter, j])),
        sigma0 = g(r$sigma0[j]), acc = g(r$acc_post[j]), out = g(r$outside_post[j]),
        mse = g(r$mse[j]), mse_ind = ind$mse %||% NA, mse_ratio = g(r$mse[j]) / (ind$mse %||% NA),
        coverage = g(r$coverage[j]), width = g(r$width[j]), coverage_ind = ind$coverage %||% NA, width_ind = ind$width %||% NA,
        lambda_ess = g(r$lambda_ess[j]), rhat_lambda = rh, theta_ess_med = g(r$theta_ess_median[j]),
        warm_ipm = g(r$warm_fallback[j]), warm_ipm_unconv = g(r$warm_ipm_unconverged[j]), guard = g(r$guard_n[j]),
        guard_last = g(if (length(r$guard_sweeps[[j]])) max(r$guard_sweeps[[j]]) else NA),
        ind_warm_ipm = ind$warm_fallback %||% NA, ind_guard = ind$guard_n %||% NA, ind_lambda_ess = ind$lambda_ess %||% NA,
        draws_any_cross = g(r$draws_any_cross), cross_instances = g(r$crossings_post_total), mean_curve_cross = g(sum(r$crossing$adjacent$n_cross)),
        ind_minutes = ind$minutes %||% NA)
    }
  }
}
D <- do.call(rbind, rows); D <- D[order(D$b0, D$move, D$chain, D$tau), ]
write.csv(D, file.path(ed, "e13b_screen_runs.csv"), row.names = FALSE)
f3 <- function(x) ifelse(is.na(x), "-", formatC(x, format = "g", digits = 3)); f2 <- function(x) ifelse(is.na(x), "-", sprintf("%.2f", x))
f4 <- function(x) ifelse(is.na(x), "-", sprintf("%.4f", x)); f0 <- function(x) ifelse(is.na(x), "-", sprintf("%.0f", x))
key <- unique(D[, c("b0", "move", "tau")])
L <- c("| b0 | move | tau | crash c1/c2 | lambda joint c1 / c2 | lambda indiv | lambda joint/indiv c1/c2 | MSE joint c1 / c2 | MSE indiv | MSE ratio c1/c2 | split R-hat lambda | ESS lambda c1/c2 | acc c1/c2 | sigma c1 (indiv) | sigma max after warm c1/c2 | warm IPM fallbacks c1/c2 (indiv) | sigma guard c1/c2 (indiv) | crossings c1/c2 |",
       paste0("|", strrep("---|", 18)))
for (i in seq_len(nrow(key))) {
  s <- D[D$b0 == key$b0[i] & D$move == key$move[i] & D$tau == key$tau[i], ]; s <- s[order(s$chain), ]
  g <- function(col, f) paste(f(s[[col]]), collapse = " / ")
  L <- c(L, sprintf("| %g | %s | %.1f | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s (%s) | %s | %s (%s) | %s (%s) | %s |", key$b0[i], key$move[i], key$tau[i],
                    paste(ifelse(s$crashed, paste0("yes (", s$crash_sweep, ")"), "no"), collapse = " / "),
                    g("lambda", f3), f3(s$lambda_ind[1]), g("lambda_ratio", f2), g("mse", f4), f4(s$mse_ind[1]), g("mse_ratio", f2), f2(s$rhat_lambda[1]),
                    g("lambda_ess", f0), g("acc", f2), f3(s$sigma[1]), f3(s$sigma_ind[1]), g("sigma_max_after_warm", f3),
                    g("warm_ipm", f0), f0(s$ind_warm_ipm[1]), g("guard", f0), f0(s$ind_guard[1]), g("cross_instances", f0)))
}
writeLines(L, file.path(ed, "e13b_screen_table.md")); cat(L, sep = "\n")
cat(sprintf("\njoint post-burn draws with any crossing (max over runs): %s | crossing instances (sum): %s | mean-curve crossings (max): %s\n",
            f4(max(D$draws_any_cross, na.rm = TRUE)), sum(D$cross_instances, na.rm = TRUE), max(D$mean_curve_cross, na.rm = TRUE)))
cat(sprintf("total minutes: joint %.0f, individual %.0f\n", sum(unique(D[, c("b0", "move", "chain", "minutes")])$minutes),
            sum(unique(D[D$chain == 1, c("b0", "move", "tau", "ind_minutes")])$ind_minutes, na.rm = TRUE)))
# ---- before/after reference (individual sampler, script defaults, VS n500 tau 0.75, chains 1001-1004) ----
ref <- lapply(c("before", "after"), function(v) lapply(1:4, function(ch) rd(sprintf("ref_%s_t75_c%d", v, ch))))
if (all(vapply(unlist(ref, recursive = FALSE), Negate(is.null), TRUE))) {
  stats <- c("mse", "coverage", "width", "lambda_mean", "sigma_mean")
  M <- sapply(ref, function(rr) sapply(stats, function(s) vapply(rr, function(r) r[[s]], 0)), simplify = "array")   # chain x stat x version
  # MC standard error of each version's 4-chain average: between-chain sd / sqrt(4); difference SE = sqrt(se_b^2 + se_a^2)
  R <- data.frame(statistic = stats, before = colMeans(M[, , 1]), se_before = apply(M[, , 1], 2, sd) / 2,
                  after = colMeans(M[, , 2]), se_after = apply(M[, , 2], 2, sd) / 2)
  R$diff <- R$after - R$before; R$se_diff <- sqrt(R$se_before^2 + R$se_after^2); R$z <- R$diff / R$se_diff
  # within-chain MC SE (batch means via ESS) for lambda and sigma, as a cross-check of the between-chain SE
  wc <- function(rr, s) sqrt(mean(vapply(rr, function(r) { v <- r[[s]][(r$burn + 1):r$iter]; var(v) / effectiveSize(v) }, 0)) / 4)
  R$se_within_before <- c(NA, NA, NA, wc(ref[[1]], "lambda"), wc(ref[[1]], "sigma")); R$se_within_after <- c(NA, NA, NA, wc(ref[[2]], "lambda"), wc(ref[[2]], "sigma"))
  write.csv(R, file.path(ed, "e13b_reference.csv"), row.names = FALSE)
  cat("\nBefore/after reference (4 chains each):\n"); print(format(R, digits = 4), row.names = FALSE)
  per <- do.call(rbind, lapply(1:2, function(k) data.frame(version = c("before", "after")[k], chain = 1:4, M[, , k],
                  warm_ipm = vapply(ref[[k]], function(r) r$warm_fallback %||% NA, 0), guard = vapply(ref[[k]], function(r) r$guard_n %||% NA, 0),
                  minutes = vapply(ref[[k]], function(r) r$minutes, 0))))
  write.csv(per, file.path(ed, "e13b_reference_chains.csv"), row.names = FALSE); print(format(per, digits = 4), row.names = FALSE)
}
