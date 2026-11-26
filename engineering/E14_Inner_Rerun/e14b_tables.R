# Usage: Rscript --vanilla e14b_tables.R VS_RUN_DIR S_RUN_DIR [NEW_OUTPUT_DIR]
e14b_claim_values <- function(values) {
  values$method <- c("Onizuka (Laplace)" = "laplace", "Onizuka (Horseshoe)" = "horseshoe",
    "Bayesian-PMALA" = "pmala", ADMM = "admm")[values$method]
  values$value <- as.numeric(values$value)
  w <- reshape(values[c("signal", "noise", "tau", "metric", "method", "value")],
    idvar = c("signal", "noise", "tau", "metric"), timevar = "method", direction = "wide")
  names(w) <- sub("^value[.]", "", names(w))
  vs <- subset(w, signal == "VS" & metric == "MSE")
  vmad <- subset(w, signal == "VS" & metric == "MAD")
  s <- subset(w, signal == "S" & metric == "MSE")
  count <- function(x) sprintf("%d/%d", sum(x), length(x))
  noise_label <- c(Normal = "Gaussian", Beta = "Beta", Mixed = "mixed normal")
  cell_label <- function(d) sprintf("%s at τ = %.2f", noise_label[d$noise], d$tau)
  vs_horse <- function(d) with(subset(d, noise == "Beta"),
    count(horseshoe < pmin(pmala, laplace, admm)))
  vs_admm <- function(d) {
    largest <- with(d, admm > pmax(pmala, laplace, horseshoe))
    exceptions <- cell_label(d[!largest, ])
    if (length(exceptions)) paste0(count(largest), " (exceptions: ",
      paste(exceptions, collapse = ", "), ")") else count(largest)
  }
  compare_onizuka <- function(d, relative = FALSE) {
    best <- with(d, pmin(laplace, horseshoe))
    below <- d$pmala < best
    above <- with(d, pmala > pmax(laplace, horseshoe))
    out <- sprintf("%s below both, %d above both, %d between or tied",
      count(below), sum(above), sum(!below & !above))
    if (!relative) return(out)
    percentages <- 100 * (d$pmala / best - 1)
    sprintf("%s (relative difference %+.2f%% to %+.2f%%)", out,
      min(percentages), max(percentages))
  }
  spread <- with(vs, max(pmax(pmala, laplace, horseshoe) / pmin(pmala, laplace, horseshoe)))
  ratio <- with(s, pmala / admm)
  c(
    sprintf("%.6f", spread), vs_horse(vs), vs_admm(vs),
    with(s, count(admm < pmin(pmala, laplace, horseshoe))),
    sprintf("%.4f to %.4f (%s to %s)", min(ratio), max(ratio),
      cell_label(s[which.min(ratio), ]), cell_label(s[which.max(ratio), ])),
    compare_onizuka(subset(s, tau %in% c(.25, .50, .75)), relative = TRUE),
    compare_onizuka(subset(s, tau %in% c(.05, .95)), relative = TRUE),
    paste(vs_horse(vmad), "horseshoe wins under Beta.", vs_admm(vmad), "ADMM largest overall."),
    compare_onizuka(subset(w, signal == "VS" & metric == "MCIW")),
    compare_onizuka(subset(w, signal == "S" & metric == "MAD")),
    compare_onizuka(subset(w, signal == "S" & metric == "MCIW"))
  )
}

e14b_write_claims <- function(path, published, current, comparison,
    rate = "1e-3", note = "HQ review only. The prior-rate decision remains open.",
    comparison_label = "Recomputed with E-14b") {
  k <- function(d) paste(d$signal, d$noise, d$tau, d$metric)
  new <- current
  target <- new$method == "Bayesian-PMALA"
  idx <- match(k(new[target, ]), k(comparison))
  stopifnot(!anyNA(idx), !anyDuplicated(idx), all(comparison$complete[idx]))
  new$value[target] <- sprintf("%.6f", comparison$new[idx])
  claims <- c(
    "VS MSE, largest ratio among the Bayesian samplers",
    "VS Beta MSE, horseshoe smallest",
    "VS MSE, ADMM largest",
    "S MSE, ADMM smallest",
    "S MSE, PMALA divided by ADMM",
    "S MSE versus Onizuka at τ = 0.25, 0.50, 0.75",
    "S MSE versus Onizuka at τ = 0.05 and 0.95",
    "VS MAD, Beta winner and ADMM ranking",
    "VS MCIW versus Onizuka",
    "S MAD versus Onizuka",
    "S MCIW versus Onizuka"
  )
  writeLines(c(paste("# Interior-quantile claims with b0 =", rate), "",
    note, "",
    "The archived baseline predates E-14. The current-paper column uses the tables supplied to this build. Ratios use the displayed six-decimal MSEs. Signed percentages compare PMALA with the smaller Onizuka MSE in each cell.", "",
    paste0("| Claim | Pre-E-14 published | Current paper | ", comparison_label, " |"),
    "| --- | --- | --- | --- |",
    sprintf("| %s | %s | %s | %s |", claims, e14b_claim_values(published),
      e14b_claim_values(current), e14b_claim_values(new))), path)
}

if (sys.nframe() == 0L) {
  args <- commandArgs(trailingOnly = TRUE)
  if (!length(args) %in% 2:3) stop("Usage: e14b_tables.R VS_RUN_DIR S_RUN_DIR [NEW_OUTPUT_DIR]")
  script <- sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE))
  folder <- dirname(normalizePath(script, mustWork = TRUE))
  root <- file.path(folder, "..", "..")
  source(file.path(folder, "e14_tables.R"))
  runs <- setNames(args[1:2], c("VS", "S"))
  results <- setNames(file.path(runs, "out"), names(runs))
  attempts <- setNames(file.path(runs, "e14_attempts.csv"), names(runs))
  output <- if (length(args) == 3L) args[3L] else file.path(folder, "out", "b1e3")
  published_csv <- file.path(folder, "published_values.csv")
  ok <- e14_build_tables(results, output, file.path(folder, "valid_reps.csv"), published_csv, root,
    attempts_csv = attempts,
    notes = c(S = "Published: b0 = 5e-4, old sampler, 20k sweeps / 5k burn-in. New: b0 = 1e-3, updated sampler, 30k sweeps / 10k burn-in."))
  if (ok) {
    e14b_write_claims(file.path(output, "recomputed_claims.md"),
      read.csv(published_csv, colClasses = c(value = "character")), e14_read_paper(root)$published,
      read.csv(file.path(output, "pmala_old_vs_new.csv")))
  }
  quit(status = if (ok) 0L else 1L)
}
