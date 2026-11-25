# Usage: Rscript e14_tables.R RUN_OR_RESULTS_DIR [NEW_OUTPUT_DIR [VALID_REPS_CSV]]
# The RDS schema uses posterior_mean, lo, hi and truth for the four curves.
# An optional status="failed" and error string can record a failed keyed fit.

e14_read_paper <- function(root) {
  noise_names <- c("Beta" = "Beta", "Mixed normal" = "Mixed", "Gaussian" = "Normal")
  methods <- c("Onizuka (Laplace)", "Onizuka (Horseshoe)", "Bayesian-PMALA", "ADMM")
  taus <- c(.05, .25, .50, .75, .95)
  tables <- list()
  values <- list()
  for (section in c("simulations", "appendix_simulations")) {
    lines <- readLines(file.path(root, "paper", "sections", paste0(section, ".tex")))
    labels <- grep("^\\\\label\\{tab:(vs|s)_int_(mse|mad|mciw)\\}$", lines)
    starts <- grep("^\\\\begin\\{table\\}", lines)
    ends <- grep("^\\\\end\\{table\\}", lines)
    for (label in labels) {
      id <- sub("^.*tab:([^}]+).*$", "\\1", lines[label])
      signal <- toupper(sub("_int_.*$", "", id))
      metric <- toupper(sub("^.*_int_", "", id))
      block <- lines[max(starts[starts < label]):min(ends[ends > label])]
      fields <- strsplit(block, " & ", fixed = TRUE)
      row_labels <- vapply(fields, `[[`, character(1L), 1L)
      headers <- which(row_labels %in% names(noise_names))
      stopifnot(identical(row_labels[headers], names(noise_names)))
      for (j in seq_along(headers)) {
        start <- headers[j]
        end <- c(headers, length(block) + 1L)[j + 1L] - 1L
        rows <- which(seq_along(block) > start & seq_along(block) <= end & row_labels %in% methods)
        expected <- if (metric == "MCIW") head(methods, -1L) else methods
        stopifnot(identical(row_labels[rows], expected))
        for (row in rows) {
          numbers <- c(fields[[row]][2:5], strsplit(fields[[row]][6L], " ", fixed = TRUE)[[1L]][1L])
          stopifnot(length(fields[[row]]) == 6L, all(grepl("^[0-9]+[.][0-9]{6}$", numbers)))
          values[[length(values) + 1L]] <- data.frame(signal, noise = unname(noise_names[j]),
            tau = taus, method = row_labels[row], metric, value = numbers, se = NA_real_)
        }
        if (metric == "MCIW") {
          values[[length(values) + 1L]] <- data.frame(signal, noise = unname(noise_names[j]),
            tau = taus, method = "ADMM", metric, value = NA_character_, se = NA_real_)
        }
      }
      tables[[id]] <- list(block = block, signal = signal, metric = metric,
        noises = unname(noise_names), rows = which(row_labels == "Bayesian-PMALA"))
    }
  }
  stopifnot(length(tables) == 6L)
  published <- do.call(rbind, values)
  list(tables = tables, published = published)
}

e14_build_tables <- function(results_dir, output_dir, valid_csv, published_csv, root) {
  paper <- e14_read_paper(root)
  published <- read.csv(published_csv, colClasses = c(value = "character", se = "numeric"))
  stopifnot(isTRUE(all.equal(published, paper$published, check.attributes = FALSE)))
  metrics <- c("mse", "mad", "mciw")
  diagnostics <- c("lambda_ess", "acc", "delta_final", "n_ipm_fallback", "n_sigma_guard", "seconds")
  old <- subset(published, method == "Bayesian-PMALA")
  cells <- unique(old[c("signal", "noise", "tau")])
  keys <- function(d) paste(d$signal, d$noise, d$tau, d$seed, sep = "/")
  reps <- read.csv(valid_csv, colClasses = c(kept = "logical"))
  candidate <- merge(cells, data.frame(seed = 1:100), by = NULL)
  stopifnot(identical(names(reps), c("signal", "noise", "tau", "seed", "kept")),
    !anyDuplicated(keys(reps)), setequal(keys(reps), keys(candidate)))
  stopifnot(dir.exists(results_dir))
  if (!dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)) {
    stop("Use a new output directory: ", output_dir)
  }

  files <- list.files(results_dir, pattern = "[.]rds$", recursive = TRUE, full.names = TRUE)
  run_keys <- keys(reps)
  fits <- vector("list", nrow(reps))
  paths <- rep(NA_character_, nrow(reps))
  reason <- rep(NA_character_, nrow(reps))
  unassigned <- list()
  scalar <- function(x) is.numeric(x) && length(x) == 1L && is.finite(x)
  noise_id <- function(x) {
    if (identical(x, "Gaussian")) return("Normal")
    if (identical(x, "Mixed normal")) return("Mixed")
    x
  }
  vector_field <- function(fit, aliases) {
    present <- intersect(aliases, names(fit))
    if (length(present)) fit[[present[1L]]] else NULL
  }
  validate <- function(fit) {
    if (!is.null(fit$error) || identical(fit$status, "failed") || identical(fit$status, "error")) {
      stop(if (is.null(fit$error)) "Worker reported failure" else as.character(fit$error))
    }
    est <- vector_field(fit, c("posterior_mean", "est", "theta_mean"))
    lo <- vector_field(fit, c("lo", "q025", "theta_lo"))
    hi <- vector_field(fit, c("hi", "q975", "theta_hi"))
    truth <- fit$truth
    stopifnot(all(vapply(list(est, lo, hi, truth), function(x) {
      is.numeric(x) && is.null(dim(x)) && length(x) == 500L && all(is.finite(x))
    }, logical(1L))), all(hi >= lo))
    # Original common.R curve_metrics, called by process_results.R.
    calculated <- c(mse = mean((est - truth)^2), mad = mean(abs(est - truth)),
      mciw = mean(hi - lo))
    stopifnot(all(vapply(fit[metrics], scalar, logical(1L))),
      isTRUE(all.equal(unlist(fit[metrics]), calculated, tolerance = 1e-12)))
    stopifnot(all(vapply(fit[diagnostics], scalar, logical(1L))),
      fit$lambda_ess >= 0, fit$acc >= 0, fit$acc <= 1, fit$delta_final > 0,
      fit$n_ipm_fallback >= 0, fit$n_ipm_fallback == floor(fit$n_ipm_fallback),
      fit$n_sigma_guard >= 0, fit$n_sigma_guard == floor(fit$n_sigma_guard),
      fit$seconds >= 0, is.character(fit$commit), length(fit$commit) == 1L,
      !is.na(fit$commit), nzchar(fit$commit))
    c(as.list(calculated), fit[diagnostics], list(commit = fit$commit))
  }

  for (file in files) {
    fit <- tryCatch(readRDS(file), error = identity)
    identity_issue <- NULL
    if (inherits(fit, "error")) {
      identity_issue <- conditionMessage(fit)
    } else if (!is.list(fit) || !is.character(fit$signal) || length(fit$signal) != 1L ||
        !is.character(fit$noise) || length(fit$noise) != 1L ||
        !scalar(fit$tau) || !scalar(fit$seed)) {
      identity_issue <- "Missing or malformed signal/noise/tau/seed"
    }
    if (is.null(identity_issue)) {
      fit$noise <- noise_id(fit$noise)
      idx <- match(keys(fit), run_keys)
      if (is.na(idx)) identity_issue <- paste("Unexpected run", keys(fit))
    }
    if (!is.null(identity_issue)) {
      unassigned[[length(unassigned) + 1L]] <- data.frame(signal = NA_character_,
        noise = NA_character_, tau = NA_real_, seed = NA_integer_, kept = NA,
        issue = "unassigned", file = file, detail = identity_issue)
      next
    }
    if (!is.na(paths[idx])) {
      paths[idx] <- paste(paths[idx], file, sep = " | ")
      reason[idx] <- "Duplicate result files"
      fits[idx] <- list(NULL)
      next
    }
    paths[idx] <- file
    checked <- tryCatch(validate(fit), error = identity)
    if (inherits(checked, "error")) {
      reason[idx] <- conditionMessage(checked)
    } else {
      fits[[idx]] <- checked
    }
  }

  required_or_unknown <- is.na(reps$kept) | reps$kept
  missing <- is.na(paths)
  failed <- !is.na(reason)
  missing_rows <- which(required_or_unknown & missing)
  failed_rows <- which(failed)
  issues <- rbind(
    data.frame(reps[missing_rows, ], issue = rep("missing", length(missing_rows)),
      file = paths[missing_rows], detail = rep("No keyed RDS file", length(missing_rows))),
    data.frame(reps[failed_rows, ], issue = rep("failed", length(failed_rows)),
      file = paths[failed_rows], detail = reason[failed_rows]),
    do.call(rbind, unassigned)
  )
  write.csv(issues, file.path(output_dir, "run_issues.csv"), row.names = FALSE)

  comparison <- health <- vector("list", nrow(cells))
  for (i in seq_len(nrow(cells))) {
    cell <- cells[i, ]
    in_cell <- reps$signal == cell$signal & reps$noise == cell$noise & reps$tau == cell$tau
    kept <- in_cell & reps$kept %in% TRUE
    unknown <- in_cell & is.na(reps$kept)
    ok <- kept & !missing & !failed
    n <- sum(ok)
    complete <- !any(unknown) && all(ok[kept])
    d <- do.call(rbind, lapply(fits[ok], as.data.frame))
    v <- function(key, fun) if (n > 0L) fun(d[[key]]) else NA_real_
    health[[i]] <- cbind(cell, n_kept = sum(kept), n_used = n, n_unknown = sum(unknown),
      n_failed = sum(kept & failed), n_missing = sum(kept & missing),
      n_unknown_failed = sum(unknown & failed), n_unknown_missing = sum(unknown & missing),
      median_lambda_ess = v("lambda_ess", median), min_lambda_ess = v("lambda_ess", min),
      mean_acc = v("acc", mean), median_acc = v("acc", median), min_acc = v("acc", min),
      n_sigma_guard = v("n_sigma_guard", sum), n_ipm_fallback = v("n_ipm_fallback", sum),
      commits = paste(sort(unique(d$commit)), collapse = " "))
    previous <- old[old$signal == cell$signal & old$noise == cell$noise & old$tau == cell$tau, ]
    stopifnot(identical(tolower(previous$metric), metrics))
    new_mean <- if (complete && n > 0L) vapply(d[metrics], mean, numeric(1L)) else NA_real_
    new_se <- if (complete && n > 1L) vapply(d[metrics], sd, numeric(1L)) / sqrt(n) else NA_real_
    comparison[[i]] <- data.frame(previous[c("signal", "noise", "tau", "metric")],
      old = as.numeric(previous$value), old_se = previous$se,
      new = new_mean, new_se, ratio = new_mean / as.numeric(previous$value), n_kept = sum(kept),
      n_used = n, complete, row.names = NULL)
  }
  comparison <- do.call(rbind, comparison)
  write.csv(comparison, file.path(output_dir, "pmala_old_vs_new.csv"), row.names = FALSE)
  write.csv(do.call(rbind, health), file.path(output_dir, "health.csv"), row.names = FALSE)

  if (!all(comparison$complete) || length(unassigned)) {
    message("LaTeX tables require known PMALA seed eligibility and complete kept results. See ",
      output_dir)
    return(invisible(FALSE))
  }
  for (id in names(paper$tables)) {
    table <- paper$tables[[id]]
    for (j in seq_along(table$rows)) {
      selected <- subset(comparison, signal == table$signal & noise == table$noises[j] &
        metric == table$metric)
      selected <- selected[order(selected$tau), ]
      values <- ifelse(is.na(selected$new), "\\textemdash{}", sprintf("%.6f", selected$new))
      table$block[table$rows[j]] <- paste0("Bayesian-PMALA & ",
        paste(values, collapse = " & "), " ", strrep("\\", 2L))
    }
    writeLines(table$block, file.path(output_dir, paste0(id, ".tex")))
  }
  invisible(TRUE)
}

if (sys.nframe() == 0L) {
  args <- commandArgs(trailingOnly = TRUE)
  if (!length(args) %in% 1:3) {
    stop("Usage: e14_tables.R RUN_OR_RESULTS_DIR [NEW_OUTPUT_DIR [VALID_REPS_CSV]]")
  }
  script <- sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE))
  folder <- dirname(normalizePath(script, mustWork = TRUE))
  valid_csv <- if (length(args) == 3L) args[3L] else file.path(folder, "valid_reps.csv")
  results_dir <- args[1L]
  if (dir.exists(file.path(results_dir, "out"))) results_dir <- file.path(results_dir, "out")
  output_dir <- if (length(args) >= 2L) args[2L] else file.path(folder, "out")
  success <- e14_build_tables(results_dir, output_dir, valid_csv,
    file.path(folder, "published_values.csv"), file.path(folder, "..", ".."))
  quit(status = if (success) 0L else 1L)
}
