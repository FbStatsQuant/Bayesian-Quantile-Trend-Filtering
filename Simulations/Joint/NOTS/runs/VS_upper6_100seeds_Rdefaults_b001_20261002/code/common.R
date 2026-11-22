utc <- function() format(Sys.time(), tz = "UTC", usetz = TRUE)
atomic_rds <- function(x, path, compress = FALSE) {
  tmp <- paste0(path, ".tmp-", Sys.getpid())
  saveRDS(x, tmp, compress = compress)
  if (!file.rename(tmp, path)) stop("Cannot finalize ", path)
}
validate_config <- function(x) {
  stopifnot(x$baseline == "VS", x$n > x$sampler$order + 1L,
    length(x$seeds) > 0L, !anyDuplicated(x$seeds), all(x$seeds >= 1L),
    all(x$seeds == as.integer(x$seeds)),
    identical(x$noises, c("Normal", "Beta", "Mixed")),
    identical(x$taus, c(0.90, 0.93, 0.96, 0.97, 0.98, 0.99)),
    identical(x$report_taus, c(0.96, 0.97, 0.98, 0.99)),
    identical(x$ci_probs, c(0.025, 0.975)),
    x$sampler$a0 > 0, x$sampler$b0 > 0,
    x$sampler$gibbs_iter > x$sampler$gibbs_burn,
    x$sampler$gibbs_burn >= x$sampler$warm,
    x$sampler$keep_every == 1L)
  invisible(TRUE)
}
load_sampler <- function(code) {
  src <- file.path(code, "source", "Joint")
  old <- setwd(src); on.exit(setwd(old))
  lines <- readLines("Joint_Sampler_PMALA_Augmented.R")
  main <- grep("^# ---- Main", lines)
  stopifnot(length(main) == 1L)
  # Load definitions only: never execute the source's standalone pilot/plots.
  eval(parse(text = lines[seq_len(main - 1L)]), envir = globalenv())
  load_box_cpp(src, file.path(code, "source", "Individual"))
}
summarize_fit <- function(fit, dat, config, noise, seed) {
  expected <- c(config$sampler$gibbs_iter - config$sampler$gibbs_burn,
                config$n, length(config$taus))
  stopifnot(all(dim(fit$theta) == expected), all(is.finite(fit$theta)),
            identical(as.numeric(fit$tau), config$taus))
  est <- apply(fit$theta, c(2, 3), mean)
  lo <- apply(fit$theta, c(2, 3), quantile, probs = config$ci_probs[1], type = 7)
  hi <- apply(fit$theta, c(2, 3), quantile, probs = config$ci_probs[2], type = 7)
  # Check every saved draw, one adjacent pair at a time to bound memory use.
  violations <- vapply(seq_len(length(config$taus) - 1L), function(j)
    max(0, fit$theta[, , j] - fit$theta[, , j + 1L]), numeric(1))
  stopifnot(all(violations == 0), all(is.finite(lo)), all(hi >= lo))
  metrics <- data.frame(noise = noise, seed = seed, tau = config$taus,
    MSE = colMeans((est - dat$truth)^2),
    MAD = colMeans(abs(est - dat$truth)), MCIW = colMeans(hi - lo),
    coverage = colMeans(dat$truth >= lo & dat$truth <= hi),
    acc_post = fit$acc_post, outside_rate = fit$outside_post,
    ipm_share = fit$ipm_post, asis_moved = fit$asis_moved_post,
    delta_final = fit$delta_final, seconds = fit$seconds)
  stopifnot(all(is.finite(as.matrix(metrics[c("MSE", "MAD", "MCIW")]))))
  list(config = config, noise = noise, seed = seed, dat = dat,
       est = est, lo = lo, hi = hi, metrics = metrics,
       max_adjacent_draw_violation = violations)
}
