# Rscript --vanilla e18_select.R PER_FIT_CSV
e18_select <- function(fits) {
  prime <- "a0" %in% names(fits) && all(fits$a0 == 500L)
  if ("a0" %in% names(fits)) stopifnot(!anyNA(fits$a0), prime || all(fits$a0 == 1L))
  g <- e18_grid(if (prime) "sim-prime" else "sim")
  rates <- unique(g$b0)
  g <- g[c("tau", "b0", "seed")]
  fields <- c("mse", "coverage", "acc_post", "n_sigma_guard_postburn")
  stopifnot(all(c(names(g), "failed", fields) %in% names(fits)),
    nrow(fits) == nrow(g), !anyNA(fits[c(names(g), "failed")]), is.logical(fits$failed))
  keys <- function(d) paste(d$tau, d$b0, d$seed)
  idx <- match(keys(g), keys(fits))
  stopifnot(!anyNA(idx), !anyDuplicated(idx))
  fits <- fits[idx, ]
  good <- fits[!fits$failed, ]
  stopifnot(all(vapply(good[fields], function(x) all(is.finite(x)), FALSE)),
    all(good$mse >= 0), all(good$coverage >= 0 & good$coverage <= 1),
    all(good$acc_post >= 0 & good$acc_post <= 1),
    all(good$n_sigma_guard_postburn >= 0 & good$n_sigma_guard_postburn %% 1 == 0))

  # Resolve numerical ties in derived scores in descending b0 order.
  pick <- function(indices, scores) {
    if (!length(indices)) return(NA_integer_)
    best_score <- min(scores)
    same <- if (is.finite(best_score))
      abs(scores - best_score) <= 16 * .Machine$double.eps * max(1, abs(best_score))
      else scores == best_score
    indices[which(same)[1L]]
  }
  cells <- unique(g[c("tau", "b0")])
  trace <- do.call(rbind, lapply(seq_len(nrow(cells)), function(i) {
    cell <- cells[i, ]
    x <- good[good$tau == cell$tau & good$b0 == cell$b0, ]
    n <- nrow(x)
    acc <- median(x$acc_post)
    guards <- sum(x$n_sigma_guard_postburn)
    reasons <- c(if (n < 95L) ">5% failed", if (guards > 0) "post-burn-in sigma guard",
      if (n && (acc < .4 || acc > .6)) "median acceptance outside [0.4, 0.6]")
    data.frame(cell, n = n, n_failed = 100L - n, mean_mse = if (n) mean(x$mse) else NA_real_,
      mean_coverage = if (n) mean(x$coverage) else NA_real_, median_acceptance = acc,
      n_sigma_guard_postburn = guards, eligible = !length(reasons),
      reason = paste(reasons, collapse = "; "))
  }))
  trace$best_b0_at_tau <- trace$best_mean_mse <- trace$mean_mse_gap <- NA_real_
  trace$paired_diff <- trace$paired_se <- NA_real_
  trace$n_paired <- NA_integer_
  trace$admissible <- trace$chosen_at_tau <- FALSE

  for (tau in e18_taus) {
    ix <- which(trace$tau == tau)
    elig <- ix[trace$eligible[ix]]
    if (!length(elig)) next
    best <- elig[which.min(trace$mean_mse[elig])]
    trace$best_b0_at_tau[ix] <- trace$b0[best]
    trace$best_mean_mse[ix] <- trace$mean_mse[best]
    trace$mean_mse_gap[ix] <- trace$mean_mse[ix] - trace$mean_mse[best]
    t <- good[good$tau == tau, ]
    ref <- t[t$b0 == trace$b0[best], c("seed", "mse")]
    for (i in ix) {
      x <- t[t$b0 == trace$b0[i], c("seed", "mse")]
      common <- merge(x, ref, by = "seed", suffixes = c("", "_best"))
      delta <- common$mse - common$mse_best
      trace$n_paired[i] <- length(delta)
      if (length(delta)) trace$paired_diff[i] <- mean(delta)
      if (length(delta) >= 2L) trace$paired_se[i] <- sd(delta) / sqrt(100)
    }
    gap_tolerance <- 16 * .Machine$double.eps *
      pmax(trace$mean_mse[elig], trace$best_mean_mse[elig])
    trace$admissible[elig] <- trace$mean_mse_gap[elig] <= trace$paired_se[elig] + gap_tolerance
    trace$admissible[best] <- TRUE
    adm <- ix[trace$admissible[ix]]
    chosen <- pick(adm, abs(trace$mean_coverage[adm] - .95))
    trace$chosen_at_tau[chosen] <- TRUE
  }

  choice <- e18_choose_triple(trace, rates)
  trace$selected_for_real <- trace$b0 == choice$selected$b0[match(trace$tau, e18_taus)]
  if (prime) {
    trace$a0 <- 500L
    choice$selected$a0 <- 500L
    choice$triples$a0 <- 500L
  }
  list(trace = trace, selected = choice$selected, triples = choice$triples)
}

e18_choose_triple <- function(trace, grid_rates = e18_rates) {
  triples <- expand.grid(b0_01 = grid_rates, b0_05 = grid_rates, b0_10 = grid_rates,
    KEEP.OUT.ATTRS = FALSE)
  rates <- as.matrix(triples)
  powers <- round(-log10(rates))
  triples$spread <- 10^apply(powers, 1L, function(x) diff(range(x)))
  # Trace row indices for the three rates in each triple, ordered by tau.
  lookup <- vapply(seq_along(e18_taus), function(j)
    match(paste(e18_taus[j], rates[, j]), paste(trace$tau, trace$b0)), integer(nrow(rates)))
  flags <- function(column) apply(matrix(trace[[column]][lookup], ncol = 3L), 1L, all)
  coverage <- rowMeans(matrix(abs(trace$mean_coverage[lookup] - .95), ncol = 3L))
  ratio <- with(trace, ifelse(best_mean_mse > 0, mean_mse / best_mean_mse,
    ifelse(mean_mse == 0, 1, Inf)))
  log_ratio <- rowMeans(matrix(log(ratio[lookup]), ncol = 3L))
  rank_branch <- function(branch, flag, score) {
    x <- triples
    x$branch <- branch
    x$coverage_score <- if (branch == "i") score else NA_real_
    x$geometric_mse_ratio <- if (branch == "ii") exp(score) else NA_real_
    pass <- flags(flag)
    x$qualifies <- x$spread <= 10 & pass
    x$rejection_reason <- vapply(seq_len(nrow(x)), function(i) paste(
      c(if (x$spread[i] > 10) "spread > 10", if (!pass[i]) paste("rate fails", flag)),
      collapse = "; "), "")
    x$rank <- NA_integer_
    x$tie_break <- ""
    pending <- which(x$qualifies)
    next_rank <- 1L
    while (length(pending)) {
      best <- min(score[pending])
      equal <- if (is.finite(best))
        abs(score[pending] - best) <= 16 * .Machine$double.eps * max(1, abs(best))
        else score[pending] == best
      group <- pending[equal]
      ordering <- with(x[group, ], order(spread, -b0_01, -b0_05, -b0_10))
      ranked <- group[ordering]
      x$rank[ranked] <- seq.int(next_rank, length.out = length(ranked))
      x$tie_break[ranked] <- if (length(ranked) == 1L) "primary score" else {
        by_spread <- x$spread[ranked]
        ifelse(duplicated(by_spread) | duplicated(by_spread, fromLast = TRUE),
          "lexicographic b0", "smallest spread")
      }
      next_rank <- next_rank + length(ranked)
      pending <- pending[!equal]
    }
    x
  }
  scored <- rank_branch("i", "admissible", coverage)
  branch <- "i"
  reason <- "admissible triple; minimum mean absolute coverage error"
  if (!any(scored$qualifies)) {
    scored <- rbind(scored, rank_branch("ii", "eligible", log_ratio))
    branch <- "ii"
    reason <- "no admissible triple within spread 10; minimum geometric mean MSE ratio"
  }
  win <- which(scored$branch == branch & !is.na(scored$rank) & scored$rank == 1L)
  if (length(win)) {
    selected_rates <- as.numeric(scored[win, colnames(rates)])
  } else {
    selected_rates <- rep(NA_real_, length(e18_taus))
    branch <- "iii"
    reason <- "no eligible triple with spread <= 10; escalate to HQ"
  }
  list(triples = scored, selected = data.frame(tau = e18_taus, b0 = selected_rates,
    branch = branch, reason = reason))
}

e18_write_selection <- function(selection, dir) {
  write.csv(selection$trace, file.path(dir, "selection_trace.csv"), row.names = FALSE)
  write.csv(selection$triples, file.path(dir, "selection_triples.csv"), row.names = FALSE)
  write.csv(selection$selected, file.path(dir, "selected_b0.csv"), row.names = FALSE)
  print(selection$selected, row.names = FALSE)
}

e18_read_selected <- function(path, prime = FALSE) {
  x <- read.csv(path)
  stopifnot(identical(x$tau, e18_taus), length(unique(x$branch)) == 1L,
    all(x$branch %in% c("i", "ii", "iii")))
  if (x$branch[1L] == "iii") stopifnot(all(is.na(x$b0)))
  else stopifnot(all(x$b0 %in% if (prime) e18_prime_rates else e18_rates),
    diff(range(round(-log10(x$b0)))) <= 1L)
  if (prime) stopifnot(length(x$a0) == nrow(x), all(x$a0 == 500L))
  x
}

if (sys.nframe() == 0L) {
  args <- commandArgs(trailingOnly = TRUE)
  if (length(args) != 1L) stop("Usage: e18_select.R PER_FIT_CSV")
  folder <- dirname(normalizePath(sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE))))
  source(file.path(folder, "e18_common.R"))
  selection <- e18_select(read.csv(args[1L], check.names = FALSE))
  e18_write_selection(selection, dirname(args[1L]))
  if (selection$selected$branch[1L] == "iii") quit(status = 1L)
}
