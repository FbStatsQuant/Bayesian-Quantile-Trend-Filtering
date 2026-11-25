# Compute manuscript comparisons at the precision displayed in the LaTeX tables.
e15_claim_values <- function(paper, comparison = NULL) {
  joint <- "Joint sampler (non-crossing)"
  individual <- "Bayesian-PMALA"
  laplace <- "Onizuka (Laplace)"
  horseshoe <- "Onizuka (Horseshoe)"
  admm <- "ADMM"
  keys <- c("signal", "noise", "tau", "metric")
  split_cells <- function(x) split(seq_len(nrow(x)),
    interaction(x$signal, x$noise, x$tau, x$metric, drop = TRUE))
  paper$number <- as.numeric(paper$value)
  if (!is.null(comparison)) {
    k <- function(x) do.call(paste, x[keys])
    rows <- which(paper$method == individual)
    idx <- match(k(paper[rows, ]), k(comparison))
    stopifnot(!anyNA(idx), !anyDuplicated(idx))
    digits <- ifelse(paper$metric[rows] == "mse", 4L, 2L)
    paper$number[rows] <- as.numeric(sprintf("%.*f", digits, comparison$new[idx]))
  }
  wide <- do.call(rbind, lapply(split_cells(paper), function(i) {
    d <- paper[i, ]
    data.frame(d[1L, keys], as.list(setNames(d$number, d$method)), check.names = FALSE)
  }))
  names(wide)[match(c(joint, individual, laplace, horseshoe, admm), names(wide))] <-
    c("joint", "individual", "laplace", "horseshoe", "admm")
  mse <- subset(wide, metric == "mse")
  vs <- subset(mse, signal == "VS")
  s <- subset(mse, signal == "S")
  mids <- subset(vs, noise %in% c("Normal", "Mixed") & tau >= .93)
  vs90 <- subset(vs, noise %in% c("Normal", "Mixed") & tau == .90)
  vb <- subset(vs, noise == "Beta" & tau < .99)
  sbn <- subset(s, noise %in% c("Normal", "Beta"))
  sm <- subset(s, noise == "Mixed")
  sm <- sm[order(sm$tau), ]
  lower <- function(v, ...) v < pmin(...)
  count <- function(x) sprintf("%d/%d", sum(x), length(x))
  tlabel <- function(d) sprintf("%s %s %.2f", d$signal, d$noise, d$tau)
  best <- function(d) {
    x <- unlist(d[c("joint", "individual", "laplace", "horseshoe", "admm")])
    paste(names(x)[x == min(x)], collapse = " and ")
  }

  gaps <- vapply(c("Normal", "Mixed"), function(nz) {
    d <- mids[mids$noise == nz, ]
    d <- d[order(d$tau), ]
    gap <- pmin(d$individual, d$laplace, d$horseshoe, d$admm) / d$joint
    sprintf("%s %.2f× to %.2f× (%s)", nz, gap[1L], tail(gap, 1L),
      if (all(diff(gap) > 0)) "strictly increasing" else "nonmonotone")
  }, character(1L))
  vs_beta99 <- subset(vs, noise == "Beta" & tau == .99)
  vs_normal90 <- subset(vs, noise == "Normal" & tau == .90)
  vs_mixed99 <- subset(vs, noise == "Mixed" & tau == .99)
  has_exception <- mse$joint >= mse$individual
  exceptions <- mse[has_exception, ]
  exception_text <- if (nrow(exceptions)) paste(tlabel(exceptions), collapse = ", ") else "none"
  s_mixed_wins <- with(sm, tau[lower(joint, individual, laplace, horseshoe, admm)])
  cross <- subset(wide, metric == "cross_nb")
  positive <- aggregate(cross[c("individual", "laplace", "horseshoe", "admm")],
    cross[c("signal", "noise")], function(x) any(x > 0))
  crossing_summary <- function(signal, metric) {
    d <- wide[wide$signal == signal & wide$metric == metric, ]
    sprintf("%s positive (mean counts %.2f–%.2f)", count(d$individual > 0),
      min(d$individual), max(d$individual))
  }
  c(
    count(with(mids, lower(joint, individual, laplace, horseshoe, admm))),
    paste(gaps, collapse = ". "),
    sprintf("Joint %.4f, individual %.4f, horseshoe %.4f, ADMM %.4f",
      vs_mixed99$joint, vs_mixed99$individual, vs_mixed99$horseshoe, vs_mixed99$admm),
    paste(paste(vs90$noise, vapply(seq_len(nrow(vs90)), function(i) best(vs90[i, ]),
      character(1L))), collapse = ". "),
    count(with(vb, lower(horseshoe, individual, laplace, admm, joint))),
    sprintf("%s smallest (joint %.4f, individual %.4f)", best(vs_beta99),
      vs_beta99$joint, vs_beta99$individual),
    count(with(sbn, lower(admm, individual, laplace, horseshoe, joint))),
    count(with(sbn, admm < joint & lower(joint, individual, laplace, horseshoe))),
    sprintf("ADMM %.4f to %.4f, joint %.4f to %.4f, individual %.4f to %.4f",
      sm$admm[1L], tail(sm$admm, 1L), sm$joint[1L], tail(sm$joint, 1L),
      sm$individual[1L], tail(sm$individual, 1L)),
    if (length(s_mixed_wins)) paste(sprintf("%.2f", s_mixed_wins), collapse = ", ") else "none",
    sprintf("%s (exceptions: %s)", count(!has_exception), exception_text),
    sprintf("Joint %.4f, individual %.4f", vs_normal90$joint, vs_normal90$individual),
    sprintf("Joint %.4f, individual %.4f", vs_beta99$joint, vs_beta99$individual),
    sprintf("Positive in %s individual, %s Laplace, %s horseshoe, and %s ADMM signal/noise groups. Joint has zero in %s neighboring cells",
      count(positive$individual), count(positive$laplace), count(positive$horseshoe),
      count(positive$admm), count(cross$joint == 0)),
    crossing_summary("VS", "cross_nb"), crossing_summary("VS", "cross_all"),
    crossing_summary("S", "cross_nb"), crossing_summary("S", "cross_all")
  )
}

e15_write_claims <- function(path, paper, comparison = NULL) {
  claims <- c(
    "VS Gaussian/mixed normal from τ = 0.93, joint MSE strictly smallest",
    "VS Gaussian/mixed normal from τ = 0.93, nearest competitor MSE divided by joint MSE as τ increases",
    "VS mixed normal at τ = 0.99, joint advantage and reference MSEs",
    "VS Gaussian/mixed normal at τ = 0.90, MSE winners",
    "VS Beta at τ = 0.90 through 0.98, horseshoe MSE strictly smallest",
    "VS Beta at τ = 0.99, MSE winners",
    "S Beta/Gaussian, ADMM MSE strictly smallest",
    "S Beta/Gaussian, ADMM smallest and joint second",
    "S mixed normal, MSE endpoints at τ = 0.90 and 0.99",
    "S mixed normal, levels where joint MSE is strictly smallest",
    "Both signals, joint MSE strictly below individual MSE",
    "VS Gaussian at τ = 0.90, joint and individual MSE",
    "VS Beta at τ = 0.99, joint and individual MSE",
    "Crossings among adjacent reported levels, individual versus joint",
    "Appendix VS neighboring individual counts",
    "Appendix VS total individual counts",
    "Appendix S neighboring individual counts",
    "Appendix S total individual counts"
  )
  old <- e15_claim_values(paper)
  new <- if (is.null(comparison)) "Pending production build" else e15_claim_values(paper, comparison)
  stopifnot(length(old) == length(claims))
  writeLines(c("# Extreme-upper-quantile manuscript claims", "",
    "Rankings and ties use the four displayed MSE decimals. The advantage is measured relative to the smallest competing MSE in the same cell. Crossing summaries use the displayed two decimals.", "",
    "| Claim | Published | Recomputed |", "| --- | --- | --- |",
    sprintf("| %s | %s | %s |", claims, old, new), "",
    "The comparison covers the prose around the extreme MSE and crossing tables. The design still fits six levels separately for the individual sampler and counts crossings only among 0.96–0.99. The appendix counts index-level inversions, adds the specified pair counts, and averages over paired data seeds. All 48 joint crossing entries remain zero.", "",
    "Appendix C.9 must extend the updated-sampler scope to the extreme individual runs and describe their run settings. Check the opening sentence at [appendix_pmala.tex](../../paper/sections/appendix_pmala.tex#L170).", "",
    "[Extreme MSE prose](../../paper/sections/simulations.tex#L92) · [Crossing definition](../../paper/sections/appendix_simulations.tex#L144)"
  ), path)
}
