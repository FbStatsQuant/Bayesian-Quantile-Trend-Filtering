options(warn = 1)
worker_args <- commandArgs(trailingOnly = TRUE)
if (length(worker_args) != 2L) stop("Usage: worker.R RUN_DIR TASK_ID")
run_root <- normalizePath(worker_args[1], mustWork = TRUE)
code_root <- file.path(run_root, "code")
source(file.path(code_root, "config.R")); source(file.path(code_root, "common.R"))
validate_config(cfg)
grid_worker <- task_grid(cfg)
task_id_worker <- suppressWarnings(as.integer(worker_args[2]))
stopifnot(!is.na(task_id_worker), as.character(task_id_worker) == worker_args[2],
  task_id_worker %in% grid_worker$task_id)
row_worker <- grid_worker[task_id_worker, , drop = FALSE]
task_root <- file.path(run_root, "tasks", task_relpath(row_worker))
dir.create(task_root, recursive = TRUE, showWarnings = FALSE)
lock_worker <- file.path(task_root, "worker.lock")
if (!dir.create(lock_worker, showWarnings = FALSE)) stop("Task locked; inspect old job before removing lock")
main_worker <- function() {
  on.exit(unlink(lock_worker, recursive = TRUE), add = TRUE)
  if (file.exists(file.path(task_root, "SUCCESS"))) stop("Task complete; refusing overwrite")
  attempt <- file.path(task_root, paste0("attempt_", format(Sys.time(), "%Y%m%dT%H%M%S", tz="UTC"),
    "_", Sys.getenv("SLURM_JOB_ID", "manual"), "_", Sys.getpid()))
  stopifnot(dir.create(attempt))
  metadata <- list(started_utc = utc(), host = Sys.info(), pid = Sys.getpid(),
    command = commandArgs(), config = cfg, task = row_worker,
    slurm = Sys.getenv(c("SLURM_JOB_ID", "SLURM_ARRAY_JOB_ID", "SLURM_ARRAY_TASK_ID")),
    threads = Sys.getenv(c("OMP_NUM_THREADS", "OPENBLAS_NUM_THREADS", "MKL_NUM_THREADS")))
  atomic_rds(metadata, file.path(attempt, "metadata.rds"))
  dput(metadata, file = file.path(attempt, "metadata.txt"))
  status <- tryCatch({
    load_sampler(code_root)
    check_sampler_defaults(cfg)
    stopifnot(requireNamespace("coda", quietly = TRUE))
    capture.output(sessionInfo(), file = file.path(attempt, "sessionInfo.txt"))
    ip <- installed.packages()
    write.csv(ip[, c("Package", "Version", "LibPath", "Built"), drop=FALSE],
      file.path(attempt, "packages.csv"), row.names=FALSE)
    dat_worker <- simulate_data(row_worker$seed, cfg$n, row_worker$tau,
      row_worker$baseline, row_worker$noise)
    atomic_rds(dat_worker, file.path(attempt, "generated_data.rds"))
    set.seed(row_worker$seed + cfg$sampler_seed_offset)
    atomic_rds(.Random.seed, file.path(attempt, "rng_before.rds"))
    call_worker <- c(list(y = dat_worker$y, tau = row_worker$tau,
      control = do.call(glmgen::trendfilter.control.list, cfg$tf_control)), cfg$sampler)
    fit_worker <- do.call(gibbs_pmala_aug, call_worker)
    raw_dir <- file.path(run_root, "raw", task_relpath(row_worker))
    dir.create(raw_dir, recursive = TRUE, showWarnings = FALSE)
    raw_path <- file.path(raw_dir, paste0(basename(attempt), ".rds"))
    atomic_rds(list(fit = fit_worker, dat = dat_worker, config = cfg, task = row_worker,
      rng_final = .Random.seed), raw_path)
    summ <- summarize_fit(fit_worker, dat_worker, cfg, row_worker)
    summ$raw_path <- raw_path; summ$attempt <- attempt
    summ$source_sha256 <- readLines(file.path(code_root, "SHA256SUMS"))
    summ$finished_utc <- utc()
    atomic_rds(summ, file.path(attempt, "summary.rds"))
    write.csv(summ$metrics, file.path(attempt, "metrics.csv"), row.names = FALSE)
    writeLines(c("exit_status=0", paste0("finished_utc=", utc())), file.path(attempt, "exit_status.txt"))
    hash_files(c(raw_path, list.files(attempt, full.names = TRUE)), file.path(attempt, "OUTPUT_SHA256SUMS"))
    # Marker points to the audited attempt; no unaudited duplicate of summary.rds.
    marker <- file.path(task_root, paste0("SUCCESS.tmp-", Sys.getpid()))
    writeLines(attempt, marker)
    stopifnot(file.rename(marker, file.path(task_root, "SUCCESS")))
    list(exit_status = 0L)
  }, error = function(e) {
    dput(list(exit_status = 1L, finished_utc = utc(), error = conditionMessage(e)),
      file = file.path(attempt, "failure.rds.txt"))
    list(exit_status = 1L, error = conditionMessage(e))
  })
  if (status$exit_status != 0L) stop(status$error)
  cat("WORKER_SUCCESS", row_worker$task_id, utc(), "\n")
}
main_worker()
