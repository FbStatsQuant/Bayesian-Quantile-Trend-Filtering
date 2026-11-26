# Usage: Rscript --vanilla e19_run.R RUN_DIR TASK_INDEX E14_OUT
#        Rscript --vanilla e19_run.R RUN_DIR --preflight
#        Rscript --vanilla e19_run.R RUN_DIR --build-reference OUTPUT_RDS (on Owls)
e19_sampler_commit <- "63f2a56205b8d2ec311565db8c98874cd96754b2"
e19_generator_blob <- "b2023dc92bb6d3a51136a6013fd63d7b6d6ee7d9"
e19_pairing_tolerance <- 1e-12

e19_hash_vector <- function(x) {
  digest::digest(writeBin(x, raw(), size = 8L, endian = "little"),
    algo = "sha256", serialize = FALSE)
}

e19_verify_generator <- function(code) {
  path <- file.path(code, "engineering", "E14_Inner_Rerun", "e14_data.R")
  contents <- readBin(path, "raw", n = file.size(path))
  header <- c(charToRaw(paste("blob", length(contents))), as.raw(0))
  blob <- digest::digest(c(header, contents), algo = "sha1", serialize = FALSE)
  if (!identical(blob, e19_generator_blob)) stop("Unexpected E-14 generator blob: ", path)
  path
}

e19_reference_cases <- function(code) {
  ref <- readLines(file.path(code, "engineering", "E14_Inner_Rerun", "DATA_MATCH.md"))
  first <- match("## Exact comparisons", ref)
  last <- match("### Reproduce the checks", ref)
  stopifnot(!is.na(first), !is.na(last), first < last)
  ref <- ref[seq.int(first, last)]
  ref <- grep("^\\| (VS|S) \\| (Normal|Beta|Mixed) \\|", ref, value = TRUE)
  fields <- strsplit(substring(ref, 3L, nchar(ref) - 2L), " | ", fixed = TRUE)
  stopifnot(length(fields) == 12L, all(lengths(fields) == 6L))
  cases <- do.call(rbind, fields)
  stopifnot(!anyDuplicated(cases[, 1:4]),
    all(grepl("^`[0-9a-f]{64}`$", cases[, 5:6])))
  cases
}

e19_regenerate_cases <- function(cases, generator) {
  data_env <- new.env(parent = globalenv())
  source(generator, local = data_env)
  lapply(seq_len(nrow(cases)), function(i) {
    case <- cases[i, ]
    dat <- data_env$e14_make_data(case[1L], case[2L], as.integer(case[3L]), as.numeric(case[4L]))
    dat[c("y", "truth")]
  })
}

e19_verify_reference_vectors <- function(vectors, cases) {
  stopifnot(length(vectors) == nrow(cases))
  for (i in seq_len(nrow(cases))) {
    actual <- vapply(vectors[[i]][c("y", "truth")], e19_hash_vector, character(1L))
    expected <- gsub("`", "", cases[i, 5:6], fixed = TRUE)
    if (!identical(unname(actual), expected))
      stop("Reference digest mismatch for ", paste(cases[i, 1:4], collapse = " "))
  }
  cat("All 12 E-19 reference cases matched both SHA-256 digests\n")
}

e19_max_delta <- function(x, ref) {
  stopifnot(is.double(x), is.double(ref), length(x) == 500L, length(ref) == 500L,
    all(is.finite(x)), all(is.finite(ref)))
  max(abs(x - ref))
}

e19_preflight <- function(code, generator) {
  cases <- e19_reference_cases(code)
  path <- file.path(code, "engineering", "E19_Default_Prior", "preflight", "reference_owls.rds")
  reference <- readRDS(path)
  e19_verify_reference_vectors(reference, cases)
  regenerated <- e19_regenerate_cases(cases, generator)
  max_delta <- vapply(seq_len(nrow(cases)), function(i) {
    y <- e19_max_delta(regenerated[[i]]$y, reference[[i]]$y)
    truth <- e19_max_delta(regenerated[[i]]$truth, reference[[i]]$truth)
    cat(sprintf("%s | max |y delta| %.17g | max |truth delta| %.17g\n",
      paste(cases[i, 1:4], collapse = " "), y, truth))
    c(y = y, truth = truth)
  }, c(y = 0, truth = 0))
  if (any(max_delta > e19_pairing_tolerance))
    stop("E-19 reference pairing preflight exceeded ", e19_pairing_tolerance)
  cat(sprintf("All 24 vector comparisons passed (maximum %.17g)\n", max(max_delta)))
  invisible(0L)
}

e19_read_comparator <- function(task, comparator) {
  archived <- readRDS(file.path(comparator, paste0(task$id, ".rds")))
  for (key in names(task)) {
    if (!identical(archived[[key]], task[[key]]))
      stop("E-14 comparator task key mismatch: ", key)
  }
  truth <- archived[["truth"]]
  if (!is.double(truth) || length(truth) != 500L || any(!is.finite(truth)))
    stop("E-14 comparator is missing a valid stored truth vector: ", task$id)
  archived
}

e19_check_pair <- function(dat, archived) {
  delta <- e19_max_delta(dat[["truth"]], archived[["truth"]])
  if (delta > e19_pairing_tolerance)
    stop("E-14 comparator truth exceeds tolerance for ", archived$id, ": ", delta)
  delta
}

e19_main <- function(args) {
  preflight <- length(args) == 2L && identical(args[2L], "--preflight")
  if (!preflight && length(args) != 3L)
    stop("Usage: Rscript --vanilla e19_run.R RUN_DIR TASK_INDEX E14_OUT (or RUN_DIR --preflight)")
  run <- normalizePath(args[1L], mustWork = TRUE)
  code <- file.path(run, "code")
  generator <- e19_verify_generator(code)
  if (preflight) return(e19_preflight(code, generator))
  if (identical(args[2L], "--build-reference")) {
    cases <- e19_reference_cases(code)
    reference <- e19_regenerate_cases(cases, generator)
    e19_verify_reference_vectors(reference, cases)
    saveRDS(reference, args[3L], version = 2L)
    return(0L)
  }
  comparator <- normalizePath(args[3L], mustWork = TRUE)
  if (identical(comparator, file.path(run, "out")))
    stop("Use the archived E-14 results as the comparator")
  workers <- new.env(parent = globalenv())
  sys.source(file.path(code, "engineering", "E14_Inner_Rerun", "e14_run.R"), envir = workers)
  manifest <- read.dcf(file.path(code, "run_manifest.dcf"), fields = "Sampler-Commit")
  stopifnot(nrow(manifest) == 1L, identical(unname(manifest[1L, 1L]), e19_sampler_commit))

  fit_task <- function(task, code, smoke) {
    archived <- e19_read_comparator(task, comparator)
    for (package in c("glmgen", "Matrix", "Rcpp", "splines", "coda", "digest")) {
      if (!requireNamespace(package, quietly = TRUE))
        stop("Required package unavailable: ", package)
    }
    fit <- workers$e14_fit(task, code, smoke, a0 = 500, b0 = 1e-2,
      check_data = function(dat) e19_check_pair(dat, archived), save_diagnostics = TRUE)
    fit$y_sha256 <- e19_hash_vector(fit$y)
    fit$y <- NULL
    fit$generator_blob <- e19_generator_blob
    fit$truth_max_abs_delta <- e19_check_pair(fit, archived)
    fit$pairing_verified <- TRUE
    if (!isTRUE(fit$n_sigma_guard == 0)) stop("Nonzero or missing sigma-guard count: ", fit$n_sigma_guard)
    stopifnot(fit$sweeps == 30000L, fit$burn == 10000L, fit$warm == 200L,
      fit$lambda_hold_until == 200L, fit$chain_seed == 10001L + task$index,
      fit$a0 == 500, fit$b0 == 1e-2, is.finite(fit$acc_post))
    fit
  }
  workers$e14_main(args[1:2], fit_task = fit_task)
}

if (sys.nframe() == 0L) quit(status = e19_main(commandArgs(trailingOnly = TRUE)))
