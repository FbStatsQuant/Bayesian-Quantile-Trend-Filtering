# Usage: Rscript --vanilla e15_tables.R RUN_DIR [OUTPUT_ROOT]
e15_read_paper <- function(root) {
  noise_names <- c(Beta = "Beta", "Mixed normal" = "Mixed", Gaussian = "Normal")
  methods <- c("Onizuka (Laplace)", "Onizuka (Horseshoe)", "Bayesian-PMALA",
    "ADMM", "Joint sampler (non-crossing)")
  tables <- list()
  values <- list()
  for (section in c("simulations", "appendix_simulations")) {
    lines <- readLines(file.path(root, "paper", "sections", paste0(section, ".tex")))
    labels <- grep("^\\\\label\\{tab:(vs|s)_ext_upper_(mse|cross_nb|cross_all)\\}$", lines)
    starts <- grep("^\\\\begin\\{table\\}", lines)
    ends <- grep("^\\\\end\\{table\\}", lines)
    for (label in labels) {
      id <- sub("^.*tab:([^}]+).*$", "\\1", lines[label])
      signal <- toupper(sub("_ext_upper_.*$", "", id))
      metric <- sub("^.*_ext_upper_", "", id)
      digits <- if (metric == "mse") 4L else 2L
      block <- lines[max(starts[starts < label]):min(ends[ends > label])]
      fields <- strsplit(block, " & ", fixed = TRUE)
      row_labels <- vapply(fields, `[[`, character(1L), 1L)
      headers <- which(row_labels %in% names(noise_names))
      stopifnot(identical(row_labels[headers], names(noise_names)))
      pmala_rows <- integer(length(headers))
      for (j in seq_along(headers)) {
        header <- headers[j]
        taus <- as.numeric(gsub("[^0-9.]", "", fields[[header]][-1L]))
        stopifnot(identical(taus, if (metric == "mse") c(.90, .93, .96, .97, .98, .99)
          else c(.96, .97, .98, .99)))
        rows <- header + seq_along(methods) + 1L
        stopifnot(identical(row_labels[rows], methods))
        pmala_rows[j] <- rows[3L]
        for (row in rows) {
          numbers <- sub(" .*", "", fields[[row]][-1L])
          stopifnot(length(numbers) == length(taus),
            all(grepl(sprintf("^[0-9]+[.][0-9]{%d}$", digits), numbers)))
          values[[length(values) + 1L]] <- data.frame(signal, noise = unname(noise_names[j]),
            tau = taus, method = row_labels[row], metric, value = numbers)
        }
      }
      tables[[id]] <- list(block = block, signal = signal, metric = metric, digits = digits,
        noises = unname(noise_names), rows = pmala_rows)
    }
  }
  stopifnot(length(tables) == 6L)
  list(tables = tables, values = do.call(rbind, values))
}

e15_build_tables <- function(run_dir, output_root, root, seeds = 1:100, write_reports = TRUE,
    write_latex = TRUE) {
  paper <- e15_read_paper(root)
  published <- subset(paper$values, method == "Bayesian-PMALA")
  rownames(published) <- NULL
  archived <- read.csv(file.path(root, "engineering", "E15_Extreme_Individual",
    "published_values.csv"), colClasses = c(value = "character"))
  stopifnot(identical(published, archived[names(published)]))
  cells <- subset(published, metric == "mse", select = c(signal, noise, tau))
  grid <- merge(cells, data.frame(seed = seeds), by = NULL)
  key <- function(x) paste(x$signal, x$noise, x$tau, x$seed, sep = "/")
  grid_keys <- key(grid)
  run_results <- file.path(run_dir, "out")
  if (!dir.exists(run_results)) stop("Result directory missing: ", run_results)
  out <- file.path(output_root, "out")
  if (!dir.create(out, recursive = TRUE, showWarnings = FALSE)) stop("Use a new output folder: ", out)
  attempts <- NULL
  attempts_path <- file.path(run_dir, "e15_attempts.csv")
  if (file.exists(attempts_path)) {
    attempts <- read.csv(attempts_path)
    fields <- c("n_failed_attempts", "n_rerun")
    stopifnot(identical(names(attempts), c("signal", fields)), nrow(attempts) == 2L,
      setequal(attempts$signal, c("VS", "S")), all(vapply(attempts[fields], function(x) {
        is.numeric(x) && all(is.finite(x) & x >= 0 & x == floor(x))
      }, logical(1L))))
  }
  fits <- vector("list", nrow(grid))
  paths <- problem <- rep(NA_character_, nrow(grid))
  unkeyed <- list()
  scalar <- function(x) is.numeric(x) && length(x) == 1L && is.finite(x)
  valid_curve <- function(x) is.numeric(x) && is.null(dim(x)) &&
    length(x) == 500L && all(is.finite(x))
  for (path in list.files(run_results, pattern = "[.]rds$", full.names = TRUE, recursive = TRUE)) {
    x <- tryCatch(readRDS(path), error = identity)
    k <- NA_integer_
    issue <- if (inherits(x, "error")) conditionMessage(x) else "Missing or unexpected fit identity"
    if (is.list(x) && !inherits(x, "error")) {
      if (is.null(x$signal)) x$signal <- x$baseline
      if (is.character(x$signal) && length(x$signal) == 1L &&
          is.character(x$noise) && length(x$noise) == 1L && scalar(x$tau) && scalar(x$seed)) {
        k <- match(key(x), grid_keys)
      }
    }
    if (is.na(k)) {
      unkeyed[[length(unkeyed) + 1L]] <- data.frame(key = NA_character_, file = path, problem = issue)
      next
    }
    if (!is.na(paths[k])) {
      paths[k] <- paste(paths[k], path, sep = " | ")
      problem[k] <- "Duplicate result files"
      next
    }
    paths[k] <- path
    checked <- tryCatch({
      if (!is.null(x$error) || identical(x$status, "failed")) {
        stop(if (is.null(x$error)) "Worker reported failure" else as.character(x$error))
      }
      est <- x$est
      if (is.null(est)) est <- x$posterior_mean
      stopifnot(valid_curve(est), valid_curve(x$truth),
        scalar(x$mse), x$mse >= 0, scalar(x$lambda_ess), x$lambda_ess >= 0)
      mse <- mean((est - x$truth)^2)
      stopifnot(isTRUE(all.equal(mse, x$mse, tolerance = 1e-12)))
      list(est = est, mse = mse, lambda_ess = x$lambda_ess, y = x$y)
    }, error = identity)
    if (inherits(checked, "error")) problem[k] <- conditionMessage(checked) else fits[[k]] <- checked
  }
  problem[is.na(paths)] <- "Missing result"
  bad <- which(!is.na(problem))
  issues <- rbind(data.frame(key = grid_keys[bad], file = paths[bad], problem = problem[bad]),
    do.call(rbind, unkeyed))
  write.csv(issues, file.path(out, "run_issues.csv"), row.names = FALSE)
  if (nrow(issues)) {
    message(nrow(issues), " result issues; see ", file.path(out, "run_issues.csv"))
    return(invisible(FALSE))
  }

  # Use the original processor's crossing definition and pair accounting.
  original <- file.path(root, "experiments", "extreme_quantiles", "packages", "Extreme_Individual",
    "common_extreme.R")
  campaign <- new.env(parent = globalenv())
  sys.source(original, envir = campaign)
  crossing_taus <- c(.96, .97, .98, .99)
  seed_groups <- split(seq_len(nrow(grid)), interaction(grid$signal, grid$noise, grid$seed, drop = TRUE))
  crosses <- do.call(rbind, lapply(seed_groups, function(i) {
    y <- lapply(fits[i], `[[`, "y")
    if (any(lengths(y))) {
      stopifnot(all(vapply(y, identical, logical(1L), y[[1L]], num.eq = FALSE)))
    }
    i <- i[match(crossing_taus, grid$tau[i])]
    est <- vapply(fits[i], `[[`, numeric(500L), "est")
    cnt <- campaign$crossing_counts(est, crossing_taus)$per_level
    data.frame(grid[i, c("signal", "noise", "tau")],
      cross_nb = cnt$crossings_neighbor, cross_all = cnt$crossings_all)
  }))
  factors <- c("signal", "noise", "tau")
  cross_means <- aggregate(crosses[c("cross_nb", "cross_all")], crosses[factors], mean)
  grid$mse <- vapply(fits, `[[`, numeric(1L), "mse")
  grid$lambda_ess <- vapply(fits, `[[`, numeric(1L), "lambda_ess")
  means <- aggregate(grid["mse"], grid[factors], mean)
  comparison <- do.call(rbind, lapply(c("mse", "cross_nb", "cross_all"), function(metric) {
    old <- published[published$metric == metric, c(factors, "metric", "value")]
    d <- merge(old, if (metric == "mse") means else cross_means[c(factors, metric)], by = factors)
    stopifnot(nrow(d) == nrow(old))
    data.frame(d[factors], metric, old = as.numeric(d$value), new = d[[metric]])
  }))
  write.csv(comparison, file.path(out, "old_vs_new.csv"), row.names = FALSE)
  for (id in if (write_latex) names(paper$tables) else character()) {
    table <- paper$tables[[id]]
    for (j in seq_along(table$rows)) {
      d <- comparison[comparison$signal == table$signal & comparison$noise == table$noises[j] &
        comparison$metric == table$metric, ]
      values <- sprintf(paste0("%.", table$digits, "f"), d$new[order(d$tau)])
      table$block[table$rows[j]] <- paste0("Bayesian-PMALA & ",
        paste(values, collapse = " & "), " ", strrep("\\", 2L))
    }
    writeLines(table$block, file.path(out, paste0(id, ".tex")))
  }

  if (!write_reports) return(invisible(TRUE))
  noise_labels <- c(Normal = "Gaussian", Beta = "Beta", Mixed = "Mixed normal")
  blocks <- lapply(c("VS", "S"), function(signal) {
    d <- comparison[comparison$signal == signal & comparison$metric == "mse", ]
    d <- d[order(match(d$noise, names(noise_labels)), d$tau), ]
    rows <- sprintf("| %s | %.2f | %.6f | %.6f | %.6f |", noise_labels[d$noise], d$tau,
      d$old, d$new, d$new / d$old)
    status <- if (is.null(attempts)) {
      "Failed fits in final results: 0 · Reruns: unavailable"
    } else {
      counts <- attempts[attempts$signal == signal, ]
      sprintf("Failed attempts: %d · Rerun fits: %d", counts$n_failed_attempts, counts$n_rerun)
    }
    c(paste("##", signal), "",
      "| Noise | τ | Published individual MSE | New individual MSE | New / old |",
      "| --- | ---: | ---: | ---: | ---: |", rows, "",
      sprintf("%s · Median λ ESS: %.6f", status, median(grid$lambda_ess[grid$signal == signal])), "")
  })
  writeLines(c("# Extreme upper quantiles — individual sampler MSE", "",
    "Published fits used the old sampler at 10k sweeps / 3k burn-in with b0 = 0.01 for VS and 0.001 for S. The rerun uses the updated sampler at 30k / 10k with b0 = 0.001 for both signals. On VS, the MSE ratio combines changes to b0, the sampler, and chain length. On S, the sampler and chain length change at the same b0.", "",
    head(unlist(blocks), -1L)), file.path(output_root, "old_vs_new_mse.md"))
  source(file.path(root, "engineering", "E15_Extreme_Individual", "e15_claims.R"), local = TRUE)
  e15_write_claims(file.path(output_root, "recomputed_claims.md"), paper$values, comparison)
  invisible(TRUE)
}

if (sys.nframe() == 0L) {
  args <- commandArgs(trailingOnly = TRUE)
  if (!length(args) %in% 1:2) stop("Usage: e15_tables.R RUN_DIR [OUTPUT_ROOT]")
  script <- sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE))
  project <- dirname(normalizePath(script, mustWork = TRUE))
  destination <- if (length(args) == 2L) args[2L] else project
  ok <- e15_build_tables(args[1L], destination, file.path(project, "..", ".."))
  quit(status = if (ok) 0L else 1L)
}
