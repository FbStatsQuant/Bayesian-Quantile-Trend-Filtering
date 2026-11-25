# E-13a: summarise the screen (runs/E13-joint-b0-20261125/out/*.rds from e13_run.R).
# Writes engineering/E13_Joint_b0/e13_screen_runs.csv (one row per joint run x level) and e13_screen_table.md (compact table).
# Usage: Rscript e13_analyze.R [out dir]
suppressPackageStartupMessages(library(coda))
`%||%` <- function(a, b) if (is.null(a)) b else a
od <- commandArgs(trailingOnly = TRUE)[1]; if (is.na(od)) od <- "runs/E13-joint-b0-20261125/out"
ed <- "engineering/E13_Joint_b0"
TAUS <- c(0.3, 0.5, 0.7, 0.9)
rd <- function(id) { f <- file.path(od, paste0(id, ".rds")); if (file.exists(f)) readRDS(f) else NULL }
split_rhat <- function(chains) {                     # classic split R-hat (Gelman et al. 2013), chains = list of post-burn vectors
  s <- unlist(lapply(chains, function(v) { h <- floor(length(v) / 2); list(v[1:h], v[(h + 1):(2 * h)]) }), recursive = FALSE)
  nn <- length(s[[1]]); mu <- sapply(s, mean); W <- mean(sapply(s, var)); B <- nn * var(mu)
  sqrt(((nn - 1) / nn * W + B / nn) / W)
}
rows <- list()
for (b0 in c(1e-5, 1e-4, 1e-3, 1e-2)) for (v in c("poly", "fixed")) {
  jr <- lapply(1:2, function(ch) rd(sprintf("joint_%s_b%g_c%d", v, b0, ch)))
  ok <- vapply(jr, function(r) !is.null(r) && !isTRUE(r$crashed), TRUE)
  for (j in seq_along(TAUS)) {
    ind <- rd(sprintf("ind_%s_b%g_t%02d", v, b0, round(100 * TAUS[j])))
    ref <- rd(sprintf("ind_%s_b%g_t%02d", v, 1e-5, round(100 * TAUS[j])))
    post <- function(r) r$lambda[(r$burn + 1):r$iter, j]
    rh <- if (all(ok)) split_rhat(lapply(jr, post)) else NA
    rh_log <- if (all(ok)) split_rhat(lapply(jr, function(r) log(post(r)))) else NA
    for (ch in 1:2) {
      r <- jr[[ch]]
      if (is.null(r)) next
      rows[[length(rows) + 1L]] <- data.frame(b0 = b0, move = v, chain = ch, tau = TAUS[j],
        crashed = isTRUE(r$crashed), crash_sweep = if (isTRUE(r$crashed)) r$crash_sweep else NA, crash_level = if (isTRUE(r$crashed)) r$crash_level else NA,
        minutes = r$minutes,
        lambda = if (ok[ch]) r$lambda_mean[j] else NA, lambda_ind = ind$lambda_mean %||% NA,
        sigma = if (ok[ch]) r$sigma_mean[j] else NA, sigma_ind = ind$sigma_mean %||% NA,
        acc = if (ok[ch]) r$acc_post[j] else NA, out = if (ok[ch]) r$outside_post[j] else NA, delta_final = if (ok[ch]) r$delta_final[j] else NA,
        mse = if (ok[ch]) r$mse[j] else NA, mse_ind = ind$mse %||% NA,
        lambda_ess = if (ok[ch]) r$lambda_ess[j] else NA, theta_ess_med = if (ok[ch]) r$theta_ess_median[j] else NA,
        rhat_lambda = rh, rhat_loglambda = rh_log,
        draws_any_cross = if (ok[ch]) r$draws_any_cross else NA,
        mean_curve_cross = if (ok[ch]) sum(r$crossing$adjacent$n_cross) else NA,
        ind_minutes = ind$minutes %||% NA, ind_acc = ind$acc_post %||% NA, ind_lambda_ess = ind$lambda_ess %||% NA, ind_crashed = isTRUE(ind$crashed))
    }
  }
}
D <- do.call(rbind, rows)
# how far b0 pulls lambda down: lambda at b0 / lambda at b0 = 1e-5, same move, chain and level (joint) and the same for the individual
base <- subset(D, b0 == 1e-5)[, c("move", "chain", "tau", "lambda", "lambda_ind")]; names(base)[4:5] <- c("lambda_b1e5", "lambda_ind_b1e5")
D <- merge(D, base, by = c("move", "chain", "tau"), all.x = TRUE)
D$pull <- D$lambda / D$lambda_b1e5; D$pull_ind <- D$lambda_ind / D$lambda_ind_b1e5
D <- D[order(D$b0, D$move, D$chain, D$tau), ]
write.csv(D, file.path(ed, "e13_screen_runs.csv"), row.names = FALSE)
# compact table: one row per (b0, move, tau); chain 1 / chain 2 side by side
f3 <- function(x) ifelse(is.na(x), "-", formatC(x, format = "g", digits = 3))
f2 <- function(x) ifelse(is.na(x), "-", sprintf("%.2f", x))
f4 <- function(x) ifelse(is.na(x), "-", sprintf("%.4f", x))
key <- unique(D[, c("b0", "move", "tau")])
L <- c("| b0 | move | tau | crash c1/c2 (sweep) | lambda joint c1 / c2 | lambda indiv | pull vs 1e-5 (joint c1, indiv) | MSE joint c1 / c2 | MSE indiv | split R-hat lambda | ESS lambda c1/c2 | acc c1/c2 | sigma c1 | min c1/c2 |",
       "|---|---|---|---|---|---|---|---|---|---|---|---|---|---|")
for (i in seq_len(nrow(key))) {
  s <- D[D$b0 == key$b0[i] & D$move == key$move[i] & D$tau == key$tau[i], ]; s <- s[order(s$chain), ]
  g <- function(col, f) paste(f(s[[col]]), collapse = " / ")
  cr <- paste(ifelse(s$crashed, paste0("yes (", s$crash_sweep, ")"), "no"), collapse = " / ")
  L <- c(L, sprintf("| %g | %s | %.1f | %s | %s | %s | %s, %s | %s | %s | %s | %s | %s | %s | %s |", key$b0[i], key$move[i], key$tau[i], cr,
                    g("lambda", f3), f3(s$lambda_ind[1]), f2(s$pull[1]), f2(s$pull_ind[1]), g("mse", f4), f4(s$mse_ind[1]), f2(s$rhat_lambda[1]),
                    g("lambda_ess", function(x) ifelse(is.na(x), "-", sprintf("%.0f", x))), g("acc", f2), f3(s$sigma[1]),
                    g("minutes", function(x) sprintf("%.0f", x))))
}
writeLines(L, file.path(ed, "e13_screen_table.md"))
cat(L, sep = "\n")
cat(sprintf("\njoint draws with any crossing (max over runs): %s | mean-curve crossings (max): %s\n",
            f4(max(D$draws_any_cross, na.rm = TRUE)), max(D$mean_curve_cross, na.rm = TRUE)))
cat(sprintf("total minutes: joint %.0f, individual %.0f\n", sum(unique(D[, c("b0", "move", "chain", "minutes")])$minutes),
            sum(unique(D[D$chain == 1, c("b0", "move", "tau", "ind_minutes")])$ind_minutes, na.rm = TRUE)))
