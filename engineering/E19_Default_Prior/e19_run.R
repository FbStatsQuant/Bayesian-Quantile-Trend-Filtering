# Usage: Rscript --vanilla e19_run.R RUN_DIR TASK_INDEX E14_OUT
e19_sampler_commit <- "63f2a56205b8d2ec311565db8c98874cd96754b2"

e19_read_comparator <- function(task, comparator) {
  archived <- readRDS(file.path(comparator, paste0(task$id, ".rds")))
  for (key in names(task)) {
    if (!identical(archived[[key]], task[[key]]))
      stop("E-14 comparator task key mismatch: ", key)
  }
  for (field in c("y", "truth")) {
    x <- archived[[field]]
    if (!is.numeric(x) || length(x) != 500L || any(!is.finite(x)))
      stop("E-14 comparator is missing a valid stored ", field, " vector: ", task$id)
  }
  archived
}

e19_check_pair <- function(dat, archived) {
  for (field in c("y", "truth")) {
    if (!identical(dat[[field]], archived[[field]], num.eq = FALSE))
      stop("E-14 comparator ", field, " differs for ", archived$id)
  }
}

e19_main <- function(args) {
  if (length(args) != 3L) stop("Usage: Rscript --vanilla e19_run.R RUN_DIR TASK_INDEX E14_OUT")
  run <- normalizePath(args[1L], mustWork = TRUE)
  comparator <- normalizePath(args[3L], mustWork = TRUE)
  code <- file.path(run, "code")
  if (identical(comparator, file.path(run, "out")))
    stop("Use the archived E-14 results as the comparator")
  workers <- new.env(parent = globalenv())
  sys.source(file.path(code, "engineering", "E14_Inner_Rerun", "e14_run.R"), envir = workers)
  manifest <- read.dcf(file.path(code, "run_manifest.dcf"), fields = "Sampler-Commit")
  stopifnot(nrow(manifest) == 1L, identical(unname(manifest[1L, 1L]), e19_sampler_commit))

  fit_task <- function(task, code, smoke) {
    archived <- e19_read_comparator(task, comparator)
    for (package in c("glmgen", "Matrix", "Rcpp", "splines", "coda")) {
      if (!requireNamespace(package, quietly = TRUE))
        stop("Required package unavailable: ", package)
    }
    fit <- workers$e14_fit(task, code, smoke, a0 = 500, b0 = 1e-2,
      check_data = function(dat) e19_check_pair(dat, archived), save_diagnostics = TRUE)
    fit$pairing_verified <- TRUE
    fit
  }
  workers$e14_main(args[1:2], fit_task = fit_task)
}

if (sys.nframe() == 0L) quit(status = e19_main(commandArgs(trailingOnly = TRUE)))
