# Usage: Rscript --vanilla e17_tables.R E17_INTERIOR E17_EXTREME E14 E14B E15 [NEW_OUTPUT_DIR]
e17_fit_health <- function(repo, runs, references) {
  workers <- e17_workers(repo)
  original <- new.env()
  sys.source(file.path(repo, "experiments", "extreme_quantiles", "packages",
    "Extreme_Individual", "common_extreme.R"), envir = original)
  do.call(rbind, lapply(names(runs), function(design) {
    tasks <- e17_tasks(workers, design)
    do.call(rbind, lapply(c("reference", "e17"), function(cohort) {
      base <- if (cohort == "e17") rep(runs[[design]], nrow(tasks))
        else if (design == "extreme") rep(references[["extreme"]], nrow(tasks))
        else unname(references[tasks$signal])
      rate <- if (cohort == "e17") e17_rate else 1e-3
      paths <- file.path(base, "out", paste0(tasks$id, ".rds"))
      vals <- lapply(seq_len(nrow(tasks)), function(i) {
        x <- readRDS(paths[i])
        old_vs <- cohort == "reference" && design == "interior" && tasks$signal[i] == "VS"
        fields <- c("id", "seed", "signal", "noise", "tau")
        if (!all(vapply(fields, function(key) identical(x[[key]], tasks[[key]][i]), logical(1L))) ||
            !isTRUE(x$commit == e17_sampler_commit && x$sweeps == 30000L && x$burn == 10000L &&
              x$chain_seed == 10001L + tasks$index[i]) ||
            !(isTRUE(x$b0 == rate) || (old_vs && is.null(x$b0)))) {
          stop("Fit identity, sampler, schedule or b0 mismatch: ", paths[i])
        }
        stopifnot(length(x$trace_sweep) == 1000L, all(x$trace_sweep == seq.int(1L, 30000L, by = 30L)),
          length(x$lambda) == 1000L, all(is.finite(x$lambda) & x$lambda > 0))
        diagnostics <- unlist(x[c("mse", "lambda_ess", "acc_post", "n_sigma_guard", "n_ipm_fallback")])
        stopifnot(length(diagnostics) == 5L, all(is.finite(diagnostics)), x$mse >= 0,
          x$lambda_ess >= 0, x$acc_post >= 0, x$acc_post <= 1)
        list(metrics = c(diagnostics, lambda_thinned_mean = mean(x$lambda[x$trace_sweep > x$burn])),
          est = if (design == "interior") x$est)
      })
      h <- data.frame(design, b0 = rate, tasks[c("id", "signal", "noise", "tau", "seed")],
        do.call(rbind, lapply(vals, `[[`, "metrics")), row.names = NULL)
      h$cross_nb <- h$cross_all <- NA_real_
      if (design == "interior") {
        groups <- split(seq_len(nrow(h)), interaction(h$signal, h$noise, h$seed, drop = TRUE))
        for (i in groups) {
          i <- i[order(h$tau[i])]
          est <- vapply(vals[i], `[[`, numeric(500L), "est")
          crossings <- original$crossing_counts(est, h$tau[i])$per_level
          h$cross_nb[i] <- crossings$crossings_neighbor
          h$cross_all[i] <- crossings$crossings_all
        }
      }
      h
    }))
  }))
}

e17_compare <- function(new, reference) {
  keys <- c("signal", "noise", "tau", "metric")
  stopifnot(!anyDuplicated(new[keys]), !anyDuplicated(reference[keys]))
  d <- merge(new[c(keys, "old", "new")], reference[c(keys, "old", "new")],
    by = keys, suffixes = c("_e17", "_reference"))
  stopifnot(nrow(d) == nrow(new), nrow(d) == nrow(reference),
    all(d$old_e17 == d$old_reference), all(is.finite(d$new_e17) & is.finite(d$new_reference)))
  data.frame(d[keys], published = d$old_e17,
    b0_1e3 = d$new_reference, b0_1e5 = d$new_e17,
    e17_over_published = ifelse(d$old_e17 != 0, d$new_e17 / d$old_e17, NA_real_))
}

e17_write_mse <- function(path, design, comparison, health) {
  labels <- c(Normal = "Gaussian", Beta = "Beta", Mixed = "Mixed normal")
  extreme <- design == "extreme"
  lines <- lapply(c("VS", "S"), function(signal) {
    d <- comparison[comparison$signal == signal & tolower(comparison$metric) == "mse", ]
    d <- d[order(match(d$noise, names(labels)), d$tau), ]
    h <- health[health$design == design & health$signal == signal, ]
    previous <- median(h$lambda_ess[h$b0 == 1e-3])
    current <- median(h$lambda_ess[h$b0 == e17_rate])
    tau <- sprintf("%.2f", d$tau)
    if (extreme) tau[d$tau == .99] <- "**0.99**"
    extra_cell <- if (extreme) sprintf(" %.6f |", d$e17_over_1e3) else ""
    header <- "| Noise | τ | Published old | b0 = 1e-3 | E-17 b0 = 1e-5 | E-17 / published |"
    separator <- "| --- | ---: | ---: | ---: | ---: | ---: |"
    c(paste("##", signal), "",
      paste0(header, if (extreme) " E-17 / E-15 |" else ""),
      paste0(separator, if (extreme) " ---: |" else ""),
      sprintf("| %s | %s | %.6f | %.6f | %.6f | %.6f |%s", labels[d$noise], tau,
        d$published, d$b0_1e3, d$b0_1e5, d$e17_over_published, extra_cell), "",
      sprintf("Median λ ESS on the full post-burn-in λ trace: %.6f at b0 = 1e-3, %.6f at b0 = 1e-5.",
        previous, current),
      sprintf("E-17 fits below 0.40 post-burn-in acceptance: %d.",
        sum(h$b0 == e17_rate & h$acc_post < .4)), "")
  })
  reference <- if (extreme) {
    "The b0 = 1e-3 column uses E-15. Published MSEs use four decimals, padded here to six. Rows at τ = **0.99** are marked in bold."
  } else "The b0 = 1e-3 column uses E-14 VS and E-14b S."
  writeLines(c(paste("# E-17", design, "individual-sampler MSE"), "",
    reference, if (!extreme) "The ratio uses the published old MSE as its denominator.", "",
    head(unlist(lines), -1L)), path)
}

e17_health_by_tau <- function(health) {
  keys <- c("design", "signal", "tau", "b0")
  strata <- split(seq_len(nrow(health)), interaction(health[keys], drop = TRUE))
  summary <- do.call(rbind, lapply(strata, function(i) {
    h <- health[i, ]
    data.frame(h[1L, keys], n_fits = nrow(h), median_lambda_ess = median(h$lambda_ess),
      min_lambda_ess = min(h$lambda_ess), median_run_mean_lambda = median(h$lambda_thinned_mean),
      median_acc_post = median(h$acc_post), n_sigma_guard = sum(h$n_sigma_guard),
      n_low_acceptance = sum(h$acc_post < .4),
      n_ipm_fallback = sum(h$n_ipm_fallback), row.names = NULL)
  }))
  summary[order(summary$design, summary$signal, summary$tau, -summary$b0), ]
}

e17_interior_crossings <- function(health) {
  h <- subset(health, design == "interior")
  keys <- c("signal", "noise", "tau")
  first <- subset(h, b0 == 1e-3)
  second <- subset(h, b0 == e17_rate)
  m <- c("cross_nb", "cross_all")
  do.call(rbind, lapply(m, function(metric) {
    ref <- aggregate(first[metric], first[keys], mean)
    cur <- aggregate(second[metric], second[keys], mean)
    names(ref)[4L] <- "b0_1e3"
    names(cur)[4L] <- "b0_1e5"
    data.frame(merge(ref, cur, by = keys), metric)
  }))
}

e17_verify_mse <- function(design, comparison, health) {
  keys <- c("signal", "noise", "tau")
  h <- health[health$design == design, ]
  mse <- comparison[tolower(comparison$metric) == "mse", ]
  for (cohort in c("b0_1e3", "b0_1e5")) {
    rate <- if (cohort == "b0_1e3") 1e-3 else e17_rate
    d <- h[h$b0 == rate, ]
    means <- aggregate(d["mse"], d[keys], mean)
    check <- merge(means, mse, by = keys)
    stopifnot(nrow(check) == nrow(mse), all(table(do.call(paste, d[keys])) == 100L),
      isTRUE(all.equal(check$mse, check[[cohort]], tolerance = 1e-12)))
  }
}

e17_build_tables <- function(repo, runs, references, output_root) {
  # The owner's extreme-table decision is pending. Retain the optional paper output.
  extreme_paper <- FALSE
  e14 <- file.path(repo, "engineering", "E14_Inner_Rerun")
  e15 <- file.path(repo, "engineering", "E15_Extreme_Individual")
  sys.source(file.path(e14, "e14_tables.R"), envir = environment())
  sys.source(file.path(e14, "e14b_tables.R"), envir = environment())
  sys.source(file.path(e15, "e15_tables.R"), envir = environment())
  if (extreme_paper) sys.source(file.path(e15, "e15_claims.R"), envir = environment())
  if (file.exists(output_root)) stop("Use a new output directory: ", output_root)
  dir.create(dirname(output_root), recursive = TRUE, showWarnings = FALSE)
  stage <- tempfile(".e17-reports-", tmpdir = dirname(output_root))
  dir.create(stage)
  on.exit({
    if (dir.exists(stage)) message("Incomplete build retained at ", stage)
  })

  interior <- file.path(stage, "interior")
  extreme <- file.path(stage, "extreme")
  extreme_work <- if (extreme_paper) extreme else file.path(stage, ".extreme-work")
  published <- file.path(e14, "published_values.csv")
  ok <- e14_build_tables(file.path(runs[["interior"]], "out"), file.path(interior, "out"),
    file.path(e14, "valid_reps.csv"), published, repo, mse_markdown = NULL)
  if (!ok) stop("Incomplete interior grid")
  if (!e15_build_tables(runs[["extreme"]], extreme_work, repo,
      write_reports = FALSE, write_latex = extreme_paper)) {
    stop("Incomplete extreme grid")
  }

  health <- e17_fit_health(repo, runs, references)
  low <- subset(health, b0 == e17_rate & acc_post < .4,
    select = c(design, id, signal, noise, tau, seed, acc_post, lambda_ess))
  low$is_extreme_tau_099 <- low$design == "extreme" & low$tau == .99
  write.csv(low, file.path(stage, "low_acceptance_fits.csv"), row.names = FALSE)
  by_tau <- e17_health_by_tau(health)
  write.csv(subset(by_tau, design == "interior"), file.path(stage, "health_by_tau.csv"),
    row.names = FALSE)
  raw14 <- read.csv(file.path(interior, "out", "pmala_old_vs_new.csv"))
  raw15 <- read.csv(file.path(extreme_work, "out", "old_vs_new.csv"))
  ref14 <- read.csv(file.path(e14, "out", "b1e3", "pmala_old_vs_new.csv"))
  ref15 <- read.csv(file.path(e15, "out", "old_vs_new.csv"))
  cmp14 <- e17_compare(raw14, ref14)
  cmp15 <- e17_compare(raw15, ref15)
  cmp15$e17_over_1e3 <- ifelse(cmp15$b0_1e3 != 0, cmp15$b0_1e5 / cmp15$b0_1e3, NA_real_)
  cmp15$is_extreme_tau_099 <- cmp15$tau == .99
  e17_verify_mse("interior", cmp14, health)
  e17_verify_mse("extreme", cmp15, health)
  if (!extreme_paper) dir.create(extreme)
  extreme_ess <- subset(by_tau, design == "extreme",
    select = c(signal, tau, b0, n_fits, median_lambda_ess, min_lambda_ess,
      median_run_mean_lambda, n_low_acceptance))
  extreme_ess$is_extreme_tau_099 <- extreme_ess$tau == .99
  write.csv(extreme_ess, file.path(extreme, "lambda_ess_by_tau.csv"), row.names = FALSE)
  write.csv(cmp14, file.path(interior, "comparison.csv"), row.names = FALSE)
  write.csv(subset(cmp15, metric == "mse"), file.path(extreme, "comparison.csv"), row.names = FALSE)
  cross14 <- e17_interior_crossings(health)
  cross15 <- subset(cmp15, metric %in% c("cross_nb", "cross_all"))
  write.csv(cross14, file.path(interior, "crossing_comparison.csv"), row.names = FALSE)
  write.csv(cross15, file.path(extreme, "crossing_comparison.csv"), row.names = FALSE)
  e17_write_mse(file.path(interior, "old_vs_new_mse.md"), "interior", cmp14, health)
  e17_write_mse(file.path(extreme, "old_vs_new_mse.md"), "extreme", cmp15, health)
  sys.source(file.path(repo, "engineering", "E17_b0_1e5", "e17_headlines.R"), envir = environment())
  e17_write_headlines(file.path(stage, "headlines.md"), cmp14, cmp15, cross14, cross15, health, low)
  note <- "E-17 individual fits at b0 = 1e-5. Prepared for HQ review."
  e14b_write_claims(file.path(interior, "recomputed_claims.md"),
    read.csv(published, colClasses = c(value = "character")), e14_read_paper(repo)$published,
    raw14, rate = "1e-5", note = note, comparison_label = "Recomputed with E-17")
  if (extreme_paper) {
    e15_write_claims(file.path(extreme, "recomputed_claims.md"),
      e15_read_paper(repo)$values, raw15, note = note)
  } else {
    stopifnot(unlink(extreme_work, recursive = TRUE) == 0L)
  }
  if (!file.rename(stage, output_root)) stop("Could not publish ", output_root)
  invisible(TRUE)
}

if (sys.nframe() == 0L) {
  args <- commandArgs(trailingOnly = TRUE)
  if (!length(args) %in% 5:6) {
    stop("Usage: e17_tables.R E17_INTERIOR E17_EXTREME E14 E14B E15 [NEW_OUTPUT_DIR]")
  }
  script <- sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE))
  folder <- dirname(normalizePath(script, mustWork = TRUE))
  source(file.path(folder, "e17_run.R"))
  output <- if (length(args) == 6L) args[6L] else file.path(folder, "out")
  e17_build_tables(file.path(folder, "..", ".."),
    setNames(args[1:2], c("interior", "extreme")),
    setNames(args[3:5], c("VS", "S", "extreme")), output)
}
