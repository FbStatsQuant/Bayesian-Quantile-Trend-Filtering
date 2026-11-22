options(warn = 1)
args_worker <- commandArgs(trailingOnly = TRUE)
if (length(args_worker) != 5L) stop("Usage: worker.R RUN_DIR VS|S Normal|Beta|Mixed t05|t25|t50|t75|t95 SEED")
run_root <- normalizePath(args_worker[1], mustWork = TRUE)
code_root <- file.path(run_root, "code")
source(file.path(code_root, "config.R")); source(file.path(code_root, "common.R"))
validate_config(cfg)
baseline_task <- args_worker[2]; noise_task <- args_worker[3]; batch_task <- args_worker[4]
seed_task <- as.integer(args_worker[5])
stopifnot(baseline_task %in% cfg$baselines, noise_task %in% cfg$noises,
          batch_task %in% names(cfg$batches), seed_task %in% cfg$seeds)
taus_task <- cfg$batches[[batch_task]]$taus
task_root <- task_dir(run_root, baseline_task, noise_task, batch_task, seed_task)
dir.create(task_root, recursive = TRUE, showWarnings = FALSE)
if (file.exists(file.path(task_root, "SUCCESS"))) stop("Task already complete; refusing to overwrite")
lock <- file.path(task_root, "worker.lock")
if (!dir.create(lock, showWarnings = FALSE)) stop("Task locked; inspect prior job before removing lock")
attempt <- file.path(task_root, paste0("attempt_", format(Sys.time(), "%Y%m%dT%H%M%S", tz = "UTC"), "_", Sys.getpid()))
dir.create(attempt)
main_worker <- function() {
  on.exit(unlink(lock, recursive = TRUE), add = TRUE)
  metadata <- list(started_utc = utc(), host = Sys.info(), pid = Sys.getpid(),
    command = commandArgs(), config = cfg, baseline = baseline_task, noise = noise_task,
    batch = batch_task, taus = taus_task, seed = seed_task,
    slurm = Sys.getenv(c("SLURM_JOB_ID", "SLURM_ARRAY_JOB_ID", "SLURM_ARRAY_TASK_ID")),
    threads = Sys.getenv(c("OMP_NUM_THREADS", "OPENBLAS_NUM_THREADS", "MKL_NUM_THREADS")))
  atomic_rds(metadata, file.path(attempt, "metadata.rds"))
  dput(metadata, file = file.path(attempt, "metadata.txt"))
  status <- tryCatch({
    load_sampler(code_root)
    capture.output(sessionInfo(), file = file.path(attempt, "sessionInfo.txt"))
    # Identical data generator and RNG convention to the supplied sampler; the noise draw
    # depends only on (seed, baseline, noise), so every batch of a seed sees the same y.
    dat_task <- simulate_data(seed_task, cfg$n, taus_task, baseline_task, noise_task)
    atomic_rds(dat_task, file.path(attempt, "generated_data.rds"))
    set.seed(seed_task + cfg$sampler_seed_offset)
    atomic_rds(.Random.seed, file.path(attempt, "rng_before.rds"))
    fit_task <- do.call(gibbs_joint_pmala,
      c(list(y = dat_task$y, tau_list = taus_task), cfg$sampler))
    rng_final <- .Random.seed
    summ <- summarize_fit(fit_task, dat_task, cfg, baseline_task, noise_task, batch_task, seed_task)
    # Thin only the stored theta draws; summaries above used every retained sweep.
    keep_raw <- seq(1L, dim(fit_task$theta)[1], by = cfg$raw_keep_every)
    fit_task$theta <- fit_task$theta[keep_raw, , , drop = FALSE]
    fit_task$theta_thin_index <- keep_raw
    raw_dir <- file.path(run_root, "raw", baseline_task, noise_task, batch_task, sprintf("seed_%03d", seed_task))
    dir.create(raw_dir, recursive = TRUE, showWarnings = FALSE)
    raw_path <- file.path(raw_dir, paste0(basename(attempt), ".rds"))
    atomic_rds(list(fit = fit_task, dat = dat_task, config = cfg, rng_final = rng_final), raw_path)
    summ$raw_path <- raw_path; summ$attempt <- attempt
    summ$source_sha256 <- readLines(file.path(code_root, "SHA256SUMS"))
    summ$finished_utc <- utc()
    atomic_rds(summ, file.path(attempt, "summary.rds"))
    write.csv(summ$metrics, file.path(attempt, "metrics.csv"), row.names = FALSE)
    # Include the large raw output and generated data in the audit hashes.
    files <- c(raw_path, list.files(attempt, full.names = TRUE))
    hashes <- system2("sha256sum", shQuote(files), stdout = TRUE)
    if (!is.null(attr(hashes, "status"))) stop("Output hashing failed")
    writeLines(hashes, file.path(attempt, "OUTPUT_SHA256SUMS"))
    atomic_rds(summ, file.path(task_root, "summary.rds"))
    writeLines(c(utc(), attempt), file.path(task_root, "SUCCESS"))
    list(exit_status = 0L, finished_utc = utc())
  }, error = function(e) list(exit_status = 1L, finished_utc = utc(), error = conditionMessage(e)))
  dput(status, file = file.path(attempt, "exit_status.txt"))
  if (status$exit_status != 0L) stop(status$error)
  cat("WORKER_SUCCESS", baseline_task, noise_task, batch_task, seed_task, utc(), "\n")
}
main_worker()
