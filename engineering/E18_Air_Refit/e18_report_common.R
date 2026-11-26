e18_collect <- function(run, stage, grid, validate) {
  issue <- character(nrow(grid))
  failure_seconds <- rep(NA_real_, nrow(grid))
  records <- lapply(seq_len(nrow(grid)), function(i) {
    task <- as.list(grid[i, ])
    stem <- file.path(run, stage, task$id)
    tryCatch({
      if (file.exists(paste0(stem, ".fail.rds"))) {
        fail <- readRDS(paste0(stem, ".fail.rds"))
        if (identical(fail$task, task) && identical(fail$stage, stage) &&
            length(fail$seconds) == 1L && is.finite(fail$seconds)) failure_seconds[i] <<- fail$seconds
        stop("Failure record: ", fail$error)
      }
      path <- paste0(stem, ".rds")
      if (!file.exists(path)) stop("Missing worker result")
      result <- readRDS(path)
      stopifnot(identical(result$task, task), identical(result$stage, stage))
      validate(result)
      result
    }, error = function(err) {
      issue[i] <<- conditionMessage(err)
      NULL
    })
  })
  names(records) <- grid$id
  list(records = records, failure_seconds = failure_seconds,
    issues = data.frame(grid[nzchar(issue), ], detail = issue[nzchar(issue)]))
}

e18_sampler_diagnostics <- c("ess_log_lambda", "lambda_ess_e14", "ess_theta_median",
  "ess_theta_p05", "acc", "n_sigma_guard", "n_sigma_guard_postburn", "n_ipm_fallback",
  "n_warm_ipm_unconverged", "seconds")
e18_stat <- function(x, fields) {
  vapply(fields, function(k) {
    stopifnot(length(x[[k]]) == 1L, is.finite(x[[k]]))
    as.numeric(x[[k]])
  }, 0)
}
e18_validate_fit <- function(x, n, fields = e18_sampler_diagnostics) {
  stopifnot(identical(x$commit, e18_pin), length(x$est) == n, all(is.finite(x$est)),
    length(x$log_lambda) == 666L, all(is.finite(x$log_lambda)),
    x$chain_seed == x$task$seed + 1000L)
  e18_stat(x, fields)
}
