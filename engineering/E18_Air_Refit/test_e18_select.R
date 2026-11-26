# Run from the repository root. Tests the standalone selector on synthetic CSV files.
source("engineering/E18_Air_Refit/e18_common.R")
selector <- normalizePath("engineering/E18_Air_Refit/e18_select.R")
main <- function() {
  tmp <- tempfile("e18-select-")
  dir.create(tmp)
  on.exit(unlink(tmp, recursive = TRUE))
  rates <- e18_rates
  fixture <- function() {
    g <- e18_grid("sim")[c("tau", "b0", "seed")]
    transform(g, mse = 2, coverage = .95, acc_post = .50,
      n_sigma_guard_postburn = 0L, failed = FALSE)
  }
  run <- function(f, branch, expected) {
    path <- file.path(tmp, "per_fit.csv")
    set.seed(3L)
    write.csv(f[sample.int(nrow(f)), ], path, row.names = FALSE)
    result <- suppressWarnings(system2("Rscript", c("--vanilla", shQuote(selector), shQuote(path)),
      stdout = TRUE, stderr = TRUE))
    status <- attr(result, "status")
    stopifnot(identical(status, if (branch == "iii") 1L else NULL))
    out <- lapply(c("selection_trace", "selection_triples", "selected_b0"), function(k)
      read.csv(file.path(tmp, paste0(k, ".csv"))))
    stopifnot(nrow(out[[1L]]) == 12L, nrow(out[[2L]]) == if (branch == "i") 64L else 128L,
      identical(out[[3L]]$tau, e18_taus), all(out[[3L]]$branch == branch),
      isTRUE(all.equal(as.numeric(out[[3L]]$b0), expected)))
    names(out) <- c("cells", "triples", "selected")
    out
  }
  cell <- function(x, tau, b0) x[x$tau == tau & x$b0 == b0, ]
  ind <- function(f, k, j) f$tau == e18_taus[k] & f$b0 == rates[j]
  candidate <- function(x, b0, branch = "i")
    x[x$b0_01 == b0[1L] & x$b0_05 == b0[2L] & x$b0_10 == b0[3L] & x$branch == branch, ]

  # Common optimal rate and a lexicographic tie between common triples.
  f <- fixture()
  t <- run(f, "i", rep(rates[1L], 3L))
  stopifnot(candidate(t$triples, rep(rates[1L], 3L))$tie_break == "lexicographic b0")

  # Equal score, but spread beats lexicographic order.
  f$coverage <- .75
  f$coverage[f$b0 == rates[2L] | ind(f, 1L, 1L)] <- .95
  t <- run(f, "i", rep(rates[2L], 3L))
  stopifnot(candidate(t$triples, rep(rates[2L], 3L))$tie_break == "smallest spread",
    candidate(t$triples, rates[c(1L, 2L, 2L)])$rank == 2L)

  # Adjacent values, with lexicographic order deciding at the second tau.
  f$coverage <- .75
  f$coverage[ind(f, 1L, 1L) | ind(f, 2L, 1L) | ind(f, 2L, 2L) | ind(f, 3L, 2L)] <- .95
  t <- run(f, "i", rates[c(1L, 1L, 2L)])
  stopifnot(candidate(t$triples, rates[c(1L, 1L, 2L)])$tie_break == "lexicographic b0",
    candidate(t$triples, rates[c(1L, 2L, 2L)])$rank == 2L)

  # Reject separately optimal coverage choices with spread 100.
  f$coverage <- .75
  f$coverage[ind(f, 1L, 1L) | ind(f, 2L, 3L) | ind(f, 3L, 3L)] <- .95
  f$coverage[ind(f, 1L, 2L)] <- .94
  f$coverage[ind(f, 2L, 2L) | ind(f, 3L, 2L)] <- .97
  t <- run(f, "i", rates[c(2L, 3L, 3L)])
  wide <- candidate(t$triples, rates[c(1L, 3L, 3L)])
  stopifnot(wide$spread == 100, !wide$qualifies, is.na(wide$rank), wide$coverage_score == 0,
    all(t$cells$b0[t$cells$chosen_at_tau] == rates[c(1L, 3L, 3L)]))

  # Only the MSE minima are admissible, and their spread is too large.
  f <- fixture()
  cost <- matrix(c(1, 8, 8, 2, 4, 4, 1.5, 2, 2, 6, 1, 1), nrow = 3L)
  for (i in seq_along(e18_taus)) {
    for (j in seq_along(rates)) f$mse[ind(f, i, j)] <- cost[i, j]
  }
  t <- run(f, "ii", rates[c(3L, 4L, 4L)])
  win <- candidate(t$triples, rates[c(3L, 4L, 4L)], "ii")
  stopifnot(!any(t$triples$qualifies[t$triples$branch == "i"]), win$rank == 1L,
    abs(win$geometric_mse_ratio - 1.5^(1/3)) < 1e-12)

  # Eligible cells are present at each level, but their spread is too large.
  valid <- ind(f, 1L, 1L) | ind(f, 2L, 4L) | ind(f, 3L, 4L)
  f$acc_post[!valid] <- .39
  t <- run(f, "iii", rep(NA_real_, 3L))
  stopifnot(!any(t$triples$qualifies), all(grepl("escalate to HQ", t$selected$reason)))

  # Eligibility gates, partial cells at the boundary, and pairing by seed.
  f <- fixture()
  r4 <- f$b0 == rates[2L]
  f$mse[r4] <- 2.005 + ifelse(f$seed[r4] %% 2L == 0L, .1, -.1)
  f$coverage[r4] <- .96
  f$mse[ind(f, 1L, 4L)] <- .5
  f$n_sigma_guard_postburn[ind(f, 1L, 4L) & f$seed == 1L] <- 1L
  f$acc_post[ind(f, 2L, 4L)] <- .61
  f$failed[ind(f, 3L, 4L) & f$seed <= 6L] <- TRUE
  f$failed[ind(f, 3L, 3L) & f$seed <= 5L] <- TRUE
  f$mse[ind(f, 3L, 3L) & f$seed <= 5L] <- 50
  t <- run(f, "i", rep(rates[1L], 3L))$cells
  stopifnot(sum(t$admissible) == 9L, cell(t, .01, rates[4L])$best_b0_at_tau == rates[1L],
    cell(t, .01, rates[3L])$paired_se == 0,
    isTRUE(all.equal(cell(t, .01, rates[2L])$paired_se, sd(rep(c(-.095, .105), 50)) / sqrt(100))),
    cell(t, .10, rates[3L])$n == 95L, cell(t, .10, rates[3L])$n_paired == 95L,
    cell(t, .10, rates[3L])$mean_mse == 2,
    !cell(t, .01, rates[4L])$eligible, grepl("sigma guard", cell(t, .01, rates[4L])$reason),
    !cell(t, .05, rates[4L])$eligible, grepl("acceptance", cell(t, .05, rates[4L])$reason),
    !cell(t, .10, rates[4L])$eligible, cell(t, .10, rates[4L])$n == 94L,
    grepl(">5% failed", cell(t, .10, rates[4L])$reason))

  # Exact one-SE boundary and the independent per-tau coverage tie-break.
  f <- fixture()
  f$mse <- 1
  f$mse[ind(f, 1L, 2L) & f$seed == 100L] <- 2
  f$coverage[ind(f, 1L, 1L)] <- .97
  t <- run(f, "i", rep(rates[2L], 3L))$cells
  stopifnot(cell(t, .01, rates[2L])$admissible,
    isTRUE(all.equal(cell(t, .01, rates[2L])$paired_se, .01)),
    !cell(t, .01, rates[1L])$chosen_at_tau, cell(t, .01, rates[2L])$chosen_at_tau)
  cat("E-18 Felipe amendment CSV tests passed.\n")
}
main()
