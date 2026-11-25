# Usage: Rscript --vanilla e15_summary.R RUN_DIR
args <- commandArgs(trailingOnly = TRUE)
stopifnot(length(args) == 1L)
run <- normalizePath(args[[1L]], mustWork = TRUE)
code <- file.path(run, "code")
source(file.path(code, "engineering", "E15_Extreme_Individual", "e15_run.R"))
manifest <- read.dcf(file.path(code, "run_manifest.dcf"))
sampler_commit <- manifest[1L, "Sampler-Commit"]
tasks <- e15_tasks()
out <- file.path(run, "out")
files <- file.path(out, paste0(tasks$id, ".rds"))
stopifnot(nrow(tasks) == 3600L, length(list.files(out, pattern = "[.]rds$")) == nrow(tasks))

rows <- lapply(seq_len(nrow(tasks)), function(i) {
  x <- readRDS(files[i])
  stopifnot(identical(x$id, tasks$id[i]), identical(x$index, tasks$index[i]),
            identical(x$signal, tasks$signal[i]), identical(x$noise, tasks$noise[i]),
            identical(x$tau, tasks$tau[i]), identical(x$seed, tasks$seed[i]),
            identical(x$commit, sampler_commit), x$burn == 10000L, x$sweeps == 30000L,
            length(x$trace_sweep) == length(x$lambda), length(x$lambda) == length(x$sigma),
            length(x$trace_sweep) == 1000L, length(x$truth) == 500L,
            length(x$lo) == 500L, length(x$hi) == 500L,
            all(x$trace_sweep == seq.int(1L, x$sweeps, by = 30L)),
            all(is.finite(x$lambda) & x$lambda > 0),
            all(is.finite(x$sigma) & x$sigma > 0),
            all(is.finite(c(x$mse, x$mad, x$mciw, x$coverage, x$acc_post,
                            x$seconds, x$lo, x$hi, x$truth, x$lambda_mean, x$sigma_mean))),
            all(x$hi >= x$lo), x$lambda_mean > 0, x$sigma_mean > 0,
            x$coverage == mean(x$lo <= x$truth & x$truth <= x$hi))
  data.frame(id = x$id, signal = x$signal, noise = x$noise, tau = x$tau, seed = x$seed,
             MSE = x$mse, MAD = x$mad, MCIW = x$mciw,
             coverage = x$coverage,
             acc_post = x$acc_post, n_sigma_guard = x$n_sigma_guard,
             n_ipm_fallback = x$n_ipm_fallback,
             lambda_mean = x$lambda_mean, sigma_mean = x$sigma_mean,
             seconds = x$seconds, commit = x$commit)
})
results <- do.call(rbind, rows)
stopifnot(nrow(results) == 3600L, !anyDuplicated(results$id),
          all(is.finite(results$n_sigma_guard)), all(is.finite(results$n_ipm_fallback)))

health <- do.call(rbind, lapply(c("ALL", "VS", "S"), function(signal) {
  d <- if (signal == "ALL") results else results[results$signal == signal, ]
  expected <- if (signal == "ALL") nrow(tasks) else sum(tasks$signal == signal)
  data.frame(signal = signal, n_completed = nrow(d), n_failures = expected - nrow(d),
             n_sigma_guard_gt_zero = sum(d$n_sigma_guard > 0),
             n_acc_outside_range = sum(d$acc_post < 0.4 | d$acc_post > 0.6),
             lambda_mean_min = min(d$lambda_mean), lambda_mean_max = max(d$lambda_mean),
             sigma_mean_min = min(d$sigma_mean), sigma_mean_max = max(d$sigma_mean))
}))

write_atomic_csv <- function(x, name) {
  dest <- file.path(run, name)
  tmp <- tempfile(pattern = paste0(".", name, "."), tmpdir = run)
  on.exit(unlink(tmp), add = TRUE)
  write.csv(x, tmp, row.names = FALSE)
  if (!file.rename(tmp, dest)) stop("Could not publish ", dest)
}
write_atomic_csv(results, "e15_summary.csv")
write_atomic_csv(health, "e15_health.csv")
print(health, row.names = FALSE)
