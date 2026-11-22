utc <- function() format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")
atomic_rds <- function(x, path, compress = FALSE) {
  tmp <- paste0(path, ".tmp-", Sys.getpid())
  saveRDS(x, tmp, compress = compress)
  if (!file.rename(tmp, path)) stop("Cannot finalize ", path)
}
validate_config <- function(x, production = !isTRUE(x$validation)) {
  stopifnot(identical(x$baselines, c("VS", "S")),
    identical(x$noises, c("Normal", "Beta", "Mixed")),
    identical(x$taus, c(0.05, 0.25, 0.50, 0.75, 0.95)),
    identical(x$ci_probs, c(0.025, 0.975)), x$sampler_seed_offset == 1000L,
    x$n > x$sampler$order + 1L, length(x$seeds) >= 2L,
    !anyDuplicated(x$seeds), all(x$seeds > 0),
    all(x$seeds == as.integer(x$seeds)),
    x$sampler$a0 == 1, x$sampler$b0 == 0.01,
    x$sampler$gibbs_iter > x$sampler$gibbs_burn,
    x$sampler$gibbs_burn >= x$sampler$warm,
    x$sampler$prior_scale == "none", isTRUE(x$sampler$mh))
  if (production) stopifnot(!x$validation, x$n == 500L,
    identical(x$seeds, 1:100), x$sampler$order == 2L,
    x$sampler$gibbs_iter == 15000L, x$sampler$gibbs_burn == 3000L)
  invisible(TRUE)
}
task_grid <- function(config) {
  g <- expand.grid(seed = config$seeds, tau = config$taus,
    noise = config$noises, baseline = config$baselines, stringsAsFactors = FALSE)
  g$task_id <- seq_len(nrow(g))
  g$block_id <- (g$task_id - 1L) %/% (length(config$seeds) * length(config$taus)) + 1L
  g$array_id <- g$task_id
  g
}
task_relpath <- function(row) file.path(row$baseline, row$noise,
  sprintf("tau_%.2f", row$tau), sprintf("seed_%03d", row$seed))
load_sampler <- function(code, compile = TRUE) {
  src <- file.path(code, "source")
  old <- setwd(src); on.exit(setwd(old))
  lines <- readLines("Individual_Sampler_PMALA_Augmented.R", warn = FALSE)
  main <- grep("^# ---- Main", lines)
  stopifnot(length(main) == 1L)
  # Definitions/settings only: never execute the standalone pilot or tests.
  eval(parse(text = lines[seq_len(main - 1L)]), envir = globalenv())
  if (compile) load_prox_cpp(file.path(src, "prox_admm_metric.cpp"))
}
check_sampler_defaults <- function(config) {
  # Run lengths follow the user's campaign override, checked by validate_config;
  # the untouched source snapshot retains its historical 30k/10k pilot defaults.
  validate_config(config)
  map <- c(order="order", a0="a0", b0="b0", a_sigma="a_sigma", b_sigma="b_sigma",
    delta_init="delta_init",
    lambda_init="lambda_init", adapt_target="adapt_target", adapt_gain="adapt_gain",
    adapt_kappa="adapt_kappa", delta_bounds="delta_bounds", metric="metric",
    c_fixed="c_metric", rho="admm_rho", iters="admm_iter", mh="mh_correct",
    adapt="adapt_delta", init="theta_init", warm="warm_sweeps", gamma_warm="gamma_warm",
    prior_scale="prior_scale", kappa="kappa_metric", adapt_all="adapt_all",
    K="K_theta", asis="asis_lambda", tol="admm_tol", lamjump="lamjump", lamjump_s="lamjump_s")
  for (key in names(map)) {
    if (isTRUE(config$validation) && key == "warm") next
    if (!isTRUE(all.equal(config$sampler[[key]], get(map[[key]], globalenv()))))
      stop("Source/config mismatch: ", key)
  }
  control <- do.call(glmgen::trendfilter.control.list, config$tf_control)
  stopifnot(isTRUE(all.equal(control, get("tf_control", globalenv()))))
  invisible(TRUE)
}
curve_metrics <- function(est, lo, hi, truth) c(
  MSE = mean((est - truth)^2), MAD = mean(abs(est - truth)),
  MCIW = mean(hi - lo), coverage = mean(truth >= lo & truth <= hi))
summarize_fit <- function(fit, dat, config, row) {
  post <- seq.int(config$sampler$gibbs_burn + 1L, config$sampler$gibbs_iter)
  stopifnot(identical(dim(fit$theta), c(length(post), config$n)),
    all(is.finite(fit$theta)), length(dat$truth) == config$n,
    all(is.finite(dat$y)), all(is.finite(dat$truth)))
  for (key in c("lambda", "sigma", "delta", "SD", "acc")) {
    stopifnot(length(fit[[key]]) == config$sampler$gibbs_iter,
      all(is.finite(fit[[key]][post])))
  }
  stopifnot(all(fit$lambda[post] > 0), all(fit$sigma[post] > 0),
    all(fit$delta[post] > 0), fit$acc_post >= 0, fit$acc_post <= 1)
  est <- colMeans(fit$theta)
  lo <- apply(fit$theta, 2, quantile, probs = config$ci_probs[1], type = 7)
  hi <- apply(fit$theta, 2, quantile, probs = config$ci_probs[2], type = 7)
  ess <- function(v) as.numeric(coda::effectiveSize(v))
  half <- length(post) %/% 2L
  metrics <- cbind(row, as.data.frame(as.list(curve_metrics(est, lo, hi, dat$truth))),
    a0 = config$sampler$a0, b0 = config$sampler$b0,
    acc_post = fit$acc_post, delta_final = fit$delta_final,
    lambda_mean = mean(fit$lambda[post]), sigma_mean = mean(fit$sigma[post]),
    ess_log_lambda = ess(log(fit$lambda[post])), ess_log_sigma = ess(log(fit$sigma[post])),
    ess_theta_mid = ess(fit$theta[, config$n %/% 2L]),
    lambda_first_half = mean(fit$lambda[post[seq_len(half)]]),
    lambda_second_half = mean(fit$lambda[tail(post, half)]), seconds = fit$seconds)
  stopifnot(all(is.finite(as.matrix(metrics[c("MSE", "MAD", "MCIW", "coverage")]))))
  list(config = config, task = row, dat = dat, est = est, lo = lo, hi = hi, metrics = metrics)
}
hash_files <- function(files, destination) {
  hashes <- system2("sha256sum", shQuote(files), stdout = TRUE)
  if (!is.null(attr(hashes, "status"))) stop("Output hashing failed")
  writeLines(hashes, destination)
}
