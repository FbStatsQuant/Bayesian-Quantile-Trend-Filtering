# Usage: Rscript --vanilla e17_run.R DESIGN RUN_DIR TASK_INDEX [--smoke]
e17_sampler_commit <- "63f2a56205b8d2ec311565db8c98874cd96754b2"
e17_rate <- 1e-5

e17_workers <- function(root) {
  env <- new.env(parent = globalenv())
  sys.source(file.path(root, "engineering", "E14_Inner_Rerun", "e14_run.R"), envir = env)
  sys.source(file.path(root, "engineering", "E15_Extreme_Individual", "e15_run.R"), envir = env)
  env
}

e17_tasks <- function(workers, design) {
  if (identical(design, "interior")) workers$e14_tasks() else workers$e15_tasks()
}

e17_main <- function(args) {
  if (!length(args) %in% 3:4 || !args[1L] %in% c("interior", "extreme")) {
    stop("Usage: e17_run.R DESIGN RUN_DIR TASK_INDEX [--smoke]")
  }
  design <- args[1L]
  run <- normalizePath(args[2L], mustWork = TRUE)
  code <- file.path(run, "code")
  workers <- e17_workers(code)
  manifest <- read.dcf(file.path(code, "run_manifest.dcf"), fields = "Sampler-Commit")
  stopifnot(nrow(manifest) == 1L, identical(unname(manifest[1L, 1L]), e17_sampler_commit))
  tasks <- e17_tasks(workers, design)
  index <- suppressWarnings(as.integer(args[3L]))
  stopifnot(grepl("^[0-9]+$", args[3L]), index %in% tasks$index)
  task <- tasks[index + 1L, ]
  smoke <- length(args) == 4L && identical(args[4L], "--smoke")
  saved <- file.path(run, if (smoke) "out-smoke" else "out", paste0(task$id, ".rds"))
  if (file.exists(saved)) {
    previous <- readRDS(saved)
    stopifnot(identical(previous$id, task$id), previous$b0 == e17_rate,
      previous$commit == e17_sampler_commit, previous$chain_seed == 10001L + index,
      previous$sweeps == (if (smoke) 300L else 30000L),
      previous$burn == (if (smoke) 220L else 10000L))
  }
  fit_task <- if (design == "interior") {
    function(task, code, smoke) workers$e14_fit(task, code, smoke, b0 = e17_rate,
      save_posterior_means = TRUE)
  } else {
    function(task, code, smoke) workers$e15_fit(task, code, smoke, b0 = e17_rate)
  }
  workers$e14_main(args[-1L], tasks, fit_task)
}

if (sys.nframe() == 0L) quit(status = e17_main(commandArgs(trailingOnly = TRUE)))
