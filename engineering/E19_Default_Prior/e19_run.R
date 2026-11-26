# Usage: Rscript --vanilla e19_run.R RUN_DIR TASK_INDEX E14_OUT
#        Rscript --vanilla e19_run.R RUN_DIR --preflight
e19_sampler_commit <- "63f2a56205b8d2ec311565db8c98874cd96754b2"
e19_generator_blob <- "b2023dc92bb6d3a51136a6013fd63d7b6d6ee7d9"

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

e19_preflight <- function(code, generator) {
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
  data_env <- new.env(parent = globalenv())
  source(generator, local = data_env)
  checks <- lapply(seq_len(nrow(cases)), function(i) {
    case <- cases[i, ]
    dat <- data_env$e14_make_data(case[1L], case[2L], as.integer(case[3L]), as.numeric(case[4L]))
    actual <- vapply(dat[c("y", "truth")], e19_hash_vector, character(1L))
    expected <- gsub("`", "", case[5:6], fixed = TRUE)
    matched <- unname(actual) == expected
    cat(sprintf("%s | y %s (%s) | truth %s (%s)\n",
      paste(case[1:4], collapse = " "), actual[[1L]], if (matched[1L]) "OK" else "MISMATCH",
      actual[[2L]], if (matched[2L]) "OK" else "MISMATCH"))
    matched
  })
  if (!all(unlist(checks))) stop("E-19 reference pairing preflight failed")
  cat("All 12 E-19 reference cases matched both SHA-256 digests\n")
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
  if (!identical(dat[["truth"]], archived[["truth"]], num.eq = FALSE))
    stop("E-14 comparator truth differs for ", archived$id)
}

e19_main <- function(args) {
  preflight <- length(args) == 2L && identical(args[2L], "--preflight")
  if (!preflight && length(args) != 3L)
    stop("Usage: Rscript --vanilla e19_run.R RUN_DIR TASK_INDEX E14_OUT (or RUN_DIR --preflight)")
  run <- normalizePath(args[1L], mustWork = TRUE)
  code <- file.path(run, "code")
  generator <- e19_verify_generator(code)
  if (preflight) return(e19_preflight(code, generator))
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
    fit$pairing_verified <- TRUE
    fit
  }
  workers$e14_main(args[1:2], fit_task = fit_task)
}

if (sys.nframe() == 0L) quit(status = e19_main(commandArgs(trailingOnly = TRUE)))
