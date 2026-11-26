# Rscript e18_run.R STAGE RUN_DIR ZERO_BASED_INDEX
args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 3L) stop("Usage: e18_run.R STAGE RUN_DIR ZERO_BASED_INDEX")
stage <- args[1L]
run <- normalizePath(args[2L], mustWork = TRUE)
code <- file.path(run, "code")
source(file.path(code, "engineering", "E18_Air_Refit", "e18_common.R"))
manifest <- read.dcf(file.path(code, "run_manifest.dcf"), fields = "Sampler-Commit")
stopifnot(nrow(manifest) == 1L, unname(manifest[1L,1L]) == e18_pin)
grid <- e18_grid(stage)
index <- suppressWarnings(as.integer(args[3L]))
stopifnot(grepl("^[0-9]+$", args[3L]), index %in% grid$index)
task <- as.list(grid[index + 1L, ])
is_real <- stage %in% c("real", "admm-real")
if (is_real) input <- e18_real_input(run)
out <- file.path(run, stage)
dir.create(out, showWarnings = FALSE)
path <- file.path(out, paste0(task$id, ".rds"))
failure <- file.path(out, paste0(task$id, ".fail.rds"))
if (file.exists(path)) {
  old <- readRDS(path)
  stopifnot(identical(old$task, task), identical(old$stage, stage))
  if (is_real) stopifnot(identical(old$input_sha, input$sha))
  quit(status = 0L)
}
run_fit <- function() {
  if (is_real) {
    y <- input$data$standardized
    stopifnot(length(y) == 8640L, all(is.finite(y)))
    fit <- if (stage == "real") e18_fit(code, task, y, save_theta = TRUE)
      else e18_admm(y, task$tau, exp(-2:12))
    return(c(list(task = task, stage = stage, input_sha = input$sha), fit))
  }
  RNGkind("Mersenne-Twister", "Inversion", "Rejection")
  d <- e18_table2_archive(code)$data[[task$seed]]
  stopifnot(all(lengths(d[c("y", "theta", "s")]) == 500L))
  truth <- d$theta + .25 * qnorm(task$tau)
  y_sha <- e18_vector_sha(d$y)
  truth_sha <- e18_vector_sha(truth)
  audit <- read.csv(file.path(code, "engineering", "E18_Air_Refit", "table2_data_sha256.csv"))
  q_col <- sprintf("q%02d_sha256", round(100 * task$tau))
  stopifnot(identical(y_sha, audit$y_sha256[task$seed]),
            identical(truth_sha, audit[[q_col]][task$seed]))
  fit <- if (stage == "sim") e18_fit(code, task, d$y, truth)
    else if (stage == "admm-sim") e18_admm(d$y, task$tau, 500^seq(0, 1.4, length.out = 15L))
    else e18_onizuka(code, stage, task, d$y)
  metrics <- e18_metrics(d$y, fit$est, truth, d$s, task$tau, fit$lo, fit$hi)
  c(list(task = task, stage = stage, y_sha = y_sha, truth_sha = truth_sha, metrics = metrics), fit)
}
t0 <- proc.time()[["elapsed"]]
status <- tryCatch({
  result <- run_fit()
  e18_atomic(result, path)
  message(task$id, " completed in ", round(result$seconds, 3), " s",
    if (!is.null(result$acc)) sprintf(" | acceptance %.4f | sigma guards %d",
      result$acc, result$n_sigma_guard))
  if (isTRUE(result$lambda_stalled) || isTRUE(result$theta_stalled))
    message(sprintf("STOP | %s stalled after burn-in | lambda=%s theta=%s",
      task$id, result$lambda_stalled, result$theta_stalled))
  unlink(failure)
  0L
}, error = function(err) {
  message(task$id, " failed: ", conditionMessage(err))
  e18_atomic(list(task = task, stage = stage,
    commit = if (stage %in% c("sim", "real")) e18_pin, error = conditionMessage(err),
    seconds = proc.time()[["elapsed"]] - t0), failure)
  1L
})
quit(status = status)
