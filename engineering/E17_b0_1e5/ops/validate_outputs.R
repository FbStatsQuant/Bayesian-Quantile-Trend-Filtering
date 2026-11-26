# Usage: Rscript --vanilla validate_outputs.R DESIGN RUN_DIR
args <- commandArgs(TRUE)
stopifnot(length(args) == 2L, args[1L] %in% c("interior", "extreme"))
run <- normalizePath(args[2L], mustWork = TRUE)
code <- file.path(run, "code")
source(file.path(code, "engineering", "E17_b0_1e5", "e17_run.R"))
tasks <- e17_tasks(e17_workers(code), args[1L])
out <- file.path(run, "out")
expected <- paste0(tasks$id, ".rds")
recorded <- list.files(out, pattern = "[.]rds$")
missing <- setdiff(expected, recorded)
unexpected <- setdiff(recorded, expected)
if (length(missing)) write.table(tasks[match(missing, expected), c("index", "id")], row.names = FALSE)
for (name in unexpected) {
  error <- if (endsWith(name, ".fail.rds")) tryCatch(readRDS(file.path(out, name))$error,
    error = conditionMessage) else "Unexpected result file"
  message(name, ": ", error)
}
if (length(missing) || length(unexpected)) stop("The result grid is incomplete")

rows <- lapply(seq_len(nrow(tasks)), function(i) {
  row <- tasks[i, ]
  path <- file.path(out, expected[i])
  fit <- readRDS(path)
  fields <- c("id", "index", "signal", "noise", "tau", "seed")
  stopifnot(all(vapply(fields, function(field) identical(fit[[field]], row[[field]]), logical(1L))),
    fit$commit == e17_sampler_commit, fit$b0 == e17_rate, fit$chain_seed == 10001L + row$index,
    fit$sweeps == 30000L, fit$burn == 10000L, is.null(fit$theta))
  stats <- c("mse", "mad", "mciw", "coverage", "acc_post", "lambda_ess", "n_sigma_guard",
             "n_ipm_fallback", "lambda_mean", "sigma_mean", "seconds")
  stopifnot(all(vapply(fit[stats], function(x) is.numeric(x) && length(x) == 1L &&
    is.finite(x), logical(1L))))
  cbind(row[fields], as.data.frame(fit[stats]), b0 = fit$b0, commit = fit$commit)
})
summary <- do.call(rbind, rows)
health <- do.call(rbind, lapply(split(summary, summary$signal), function(x) {
  data.frame(signal = x$signal[1L], completed = nrow(x), failures = 0L,
    n_sigma_guard_gt_zero = sum(x$n_sigma_guard > 0),
    n_acc_outside_range = sum(x$acc_post < .4 | x$acc_post > .6),
    acc_min = min(x$acc_post), acc_max = max(x$acc_post), median_lambda_ess = median(x$lambda_ess),
    lambda_mean_min = min(x$lambda_mean), lambda_mean_max = max(x$lambda_mean),
    sigma_mean_min = min(x$sigma_mean), sigma_mean_max = max(x$sigma_mean))
}))
save_csv <- function(data, name) {
  tmp <- tempfile(paste0(".", name, "-"), tmpdir = run)
  on.exit(unlink(tmp), add = TRUE)
  write.csv(data, tmp, row.names = FALSE)
  stopifnot(file.rename(tmp, file.path(run, name)))
}
save_csv(summary, "e17_summary.csv")
save_csv(health, "e17_health.csv")
print(health, row.names = FALSE)
