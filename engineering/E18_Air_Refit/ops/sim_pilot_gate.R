# Usage: Rscript --vanilla sim_pilot_gate.R COLLECTED_PILOT_DIR
args <- commandArgs(TRUE)
stopifnot(length(args) == 1L)
prime <- startsWith(basename(normalizePath(args[[1L]])), "E18-prime-")
stage <- if (prime) "sim-prime" else "sim"
files <- list.files(file.path(args[[1L]], stage), pattern = "[.]rds$", full.names = TRUE)
ids <- c(0L, 100L, 200L, if (prime) c(1200L, 1300L, 1400L) else c(900L, 1000L, 1100L))
stopifnot(length(files) == length(ids), !any(endsWith(files, ".fail.rds")))
fits <- lapply(files, readRDS)
scalar <- function(x) is.numeric(x) && length(x) == 1L && is.finite(x)
rows <- lapply(fits, function(fit) {
  task <- fit$task
  stopifnot(identical(fit$stage, stage), scalar(task$index), scalar(task$tau), scalar(task$b0),
    scalar(fit$acc), scalar(fit$n_sigma_guard), scalar(fit$seconds),
    is.null(fit$error), identical(fit$commit, "63f2a56205b8d2ec311565db8c98874cd96754b2"))
  if (prime) stopifnot(identical(task$a0, 500L), identical(fit$a0, task$a0))
  data.frame(index = task$index, tau = task$tau, b0 = task$b0, a0 = if (prime) 500L else 1L,
    acceptance = fit$acc, n_sigma_guard = fit$n_sigma_guard, seconds = fit$seconds)
})
status <- do.call(rbind, rows)
status <- status[order(status$index), ]
print(status, row.names = FALSE)
stopifnot(all(status$index == ids), all(status$tau == rep(c(.01, .05, .10), 2L)),
          all(status$b0 == rep(c(if (prime) 1e-2 else 1e-3, 1e-6), each = 3L)))
if (any(status$acceptance < .4 | status$acceptance > .6 | status$n_sigma_guard != 0L)) {
  stop("Stage-1 pilot failed the acceptance or sigma-guard gate")
}
cat("All six fits passed the acceptance and sigma-guard gates\n")
