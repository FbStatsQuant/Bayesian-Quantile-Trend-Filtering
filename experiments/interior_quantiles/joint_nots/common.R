utc <- function() format(Sys.time(), tz = "UTC", usetz = TRUE)
atomic_rds <- function(x, path, compress = FALSE) {
  tmp <- paste0(path, ".tmp-", Sys.getpid())
  saveRDS(x, tmp, compress = compress)
  if (!file.rename(tmp, path)) stop("Cannot finalize ", path)
}
validate_config <- function(x) {
  b <- x$batches
  unset <- names(b)[vapply(b, function(z) is.null(z$taus), logical(1))]
  if (length(unset)) stop("Quantile sets not chosen yet for batch(es): ", paste(unset, collapse = ", "))
  stopifnot(identical(x$baselines, c("VS", "S")), x$n > x$sampler$order + 1L,
    length(x$seeds) > 0L, !anyDuplicated(x$seeds), all(x$seeds >= 1L),
    all(x$seeds == as.integer(x$seeds)),
    identical(x$noises, c("Normal", "Beta", "Mixed")),
    identical(names(b), c("t05", "t25", "t50", "t75", "t95")),
    # Each batch: one target, at least two strictly increasing levels in (0, 1), target among them.
    all(vapply(b, function(z) is.numeric(z$taus) && length(z$taus) >= 2L && length(z$targets) == 1L &&
      all(z$taus > 0 & z$taus < 1) && all(diff(z$taus) > 0) && z$targets %in% z$taus, logical(1))),
    # Every reported level comes from exactly one batch, in batch order.
    identical(unname(vapply(b, `[[`, numeric(1), "targets")), x$report_taus),
    identical(x$ci_probs, c(0.025, 0.975)),
    x$raw_keep_every >= 1L, x$raw_keep_every == as.integer(x$raw_keep_every),
    x$sampler$a0 == 1, x$sampler$b0 == 0.01,
    x$sampler$gibbs_iter > x$sampler$gibbs_burn,
    x$sampler$gibbs_burn >= x$sampler$warm,
    x$sampler$keep_every == 1L)
  invisible(TRUE)
}
# Array index -> task. Seed varies fastest, then batch, noise, baseline. With 5 batches and
# 100 seeds: 1-1500 are VS, 1501-3000 are S; within a baseline, 500 per noise, 100 per batch.
# submit.sh writes this grid to metadata/task_index.tsv, which array.slurm reads by index.
task_grid <- function(config) {
  expand.grid(seed = config$seeds, batch = names(config$batches),
              noise = config$noises, baseline = config$baselines,
              stringsAsFactors = FALSE)[c("baseline", "noise", "batch", "seed")]
}
write_task_index <- function(grid, path)
  write.table(cbind(index = seq_len(nrow(grid)), grid), path,
              sep = "\t", quote = FALSE, row.names = FALSE, col.names = FALSE, eol = "\n")
task_dir <- function(run_root, baseline, noise, batch, seed)
  file.path(run_root, "tasks", baseline, noise, batch, sprintf("seed_%03d", seed))
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
summarize_fit <- function(fit, dat, config, baseline, noise, batch, seed) {
  taus <- config$batches[[batch]]$taus
  expected <- c(config$sampler$gibbs_iter - config$sampler$gibbs_burn, config$n, length(taus))
  stopifnot(all(dim(fit$theta) == expected), all(is.finite(fit$theta)),
            identical(as.numeric(fit$tau), taus), identical(as.numeric(dat$tau), taus))
  est <- apply(fit$theta, c(2, 3), mean)
  lo <- apply(fit$theta, c(2, 3), quantile, probs = config$ci_probs[1], type = 7)
  hi <- apply(fit$theta, c(2, 3), quantile, probs = config$ci_probs[2], type = 7)
  # Check every saved draw, one adjacent pair at a time to bound memory use.
  violations <- vapply(seq_len(length(taus) - 1L), function(j)
    max(0, fit$theta[, , j] - fit$theta[, , j + 1L]), numeric(1))
  stopifnot(all(violations == 0), all(is.finite(lo)), all(hi >= lo))
  metrics <- data.frame(baseline = baseline, noise = noise, batch = batch, seed = seed,
    tau = taus, target = taus %in% config$batches[[batch]]$targets,
    MSE = colMeans((est - dat$truth)^2),
    MAD = colMeans(abs(est - dat$truth)), MCIW = colMeans(hi - lo),
    coverage = colMeans(dat$truth >= lo & dat$truth <= hi),
    acc_post = fit$acc_post, outside_rate = fit$outside_post,
    ipm_share = fit$ipm_post, asis_moved = fit$asis_moved_post,
    delta_final = fit$delta_final, seconds = fit$seconds)
  stopifnot(all(is.finite(as.matrix(metrics[c("MSE", "MAD", "MCIW")]))))
  list(config = config, baseline = baseline, noise = noise, batch = batch, seed = seed,
       dat = dat, est = est, lo = lo, hi = hi, metrics = metrics,
       max_adjacent_draw_violation = violations)
}
