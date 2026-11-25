# Rscript e14_run.R RUN_DIR TASK_INDEX [--smoke]
e14_tasks <- function() {
  tasks <- expand.grid(
    seed = 1:100, tau = c(0.05, 0.25, 0.50, 0.75, 0.95),
    noise = c("Normal", "Beta", "Mixed"), signal = c("VS", "S"),
    KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE
  )
  tasks$index <- seq_len(nrow(tasks)) - 1L
  tasks$id <- sprintf("%s_%s_t%02d_s%03d", tasks$signal, tasks$noise,
                      round(100 * tasks$tau), tasks$seed)
  tasks
}

e14_atomic_rds <- function(value, path) {
  tmp <- tempfile(pattern = paste0(".", basename(path), "."), tmpdir = dirname(path))
  on.exit(unlink(tmp), add = TRUE)
  saveRDS(value, tmp)
  if (!file.rename(tmp, path)) stop("Could not publish ", path)
}

e14_load_sampler <- function(code) {
  sampler_dir <- file.path(code, "method", "individual")
  lines <- readLines(file.path(sampler_dir, "Individual_Sampler_PMALA_Augmented.R"))
  main_at <- grep("^# ---- Main", lines)
  stopifnot(length(main_at) == 1L)

  old_dir <- setwd(sampler_dir)
  on.exit(setwd(old_dir), add = TRUE)
  eval(parse(text = lines[seq_len(main_at - 1L)]), envir = globalenv())
  options(rcpp.cache.dir = Sys.getenv("R_USER_CACHE_DIR", unset = tempdir()))
  load_prox_cpp(file.path(sampler_dir, "prox_admm_metric.cpp"))
}

e14_counter <- function(fit, name, trace) {
  if (!is.null(fit[[name]])) return(fit[[name]])
  if (!is.null(fit[[trace]])) return(sum(fit[[trace]]))
  NA_integer_
}

e14_fit <- function(task, code, smoke, b0 = c(VS = 1e-3, S = 5e-4)[[task$signal]],
                    chain_seed = 10001L + task$index, save_posterior_means = FALSE) {
  e14_load_sampler(code)

  data_file <- file.path(code, "engineering", "E14_Inner_Rerun", "e14_data.R")
  data_env <- new.env(parent = globalenv())
  source(data_file, local = data_env)
  dat <- data_env$e14_make_data(task$signal, task$noise, task$seed, task$tau)
  stopifnot(is.numeric(dat$y), is.numeric(dat$truth),
            length(dat$y) == 500L, length(dat$truth) == 500L,
            all(is.finite(dat$y)), all(is.finite(dat$truth)))

  sweeps <- if (smoke) 300L else 30000L
  burn <- if (smoke) 220L else 10000L
  RNGkind("Mersenne-Twister", "Inversion", "Rejection")
  set.seed(chain_seed)
  fit <- gibbs_pmala_aug(
    dat$y, task$tau, order = 2L, a0 = 1, b0 = b0, a_sigma = 0.1, b_sigma = 0.1,
    gibbs_iter = sweeps, gibbs_burn = burn, delta_init = delta_init,
    lambda_init = lambda_init, adapt_target = adapt_target, adapt_gain = adapt_gain,
    adapt_kappa = adapt_kappa, delta_bounds = delta_bounds, control = tf_control,
    metric = metric, c_fixed = c_metric, rho = admm_rho, iters = admm_iter,
    mh = mh_correct, adapt = adapt_delta, init = theta_init, warm = 200L,
    gamma_warm = gamma_warm, prior_scale = prior_scale, cmap = FALSE,
    kappa = kappa_metric, adapt_all = TRUE, K = K_theta, asis = TRUE,
    tol = admm_tol, lamjump = lamjump, lamjump_s = lamjump_s, asis_q = "fixed",
    block = 0L, block_mode = block_mode, verbose = !smoke
  )

  post <- seq.int(burn + 1L, sweeps)
  stopifnot(identical(dim(fit$theta), c(length(post), 500L)),
            length(fit$lambda) == sweeps, length(fit$sigma) == sweeps,
            all(is.finite(fit$lambda) & fit$lambda > 0),
            all(is.finite(fit$sigma) & fit$sigma > 0))
  est <- colMeans(fit$theta)
  interval <- apply(fit$theta, 2L, quantile, probs = c(0.025, 0.975), type = 7L)
  lo <- interval[1L, ]
  hi <- interval[2L, ]
  stopifnot(all(is.finite(est)), all(is.finite(lo)), all(is.finite(hi)))

  trace_sweep <- seq.int(1L, sweeps, by = ceiling(sweeps / 1000L))
  result <- list(
    chain_seed = chain_seed, sweeps = sweeps, burn = burn,
    est = est, lo = lo, hi = hi, truth = dat$truth,
    mse = mean((est - dat$truth)^2), mad = mean(abs(est - dat$truth)), mciw = mean(hi - lo),
    trace_sweep = trace_sweep, lambda = fit$lambda[trace_sweep], sigma = fit$sigma[trace_sweep],
    acc_post = fit$acc_post, acc = fit$acc_post, delta_final = fit$delta_final,
    lambda_ess = as.numeric(coda::effectiveSize(fit$lambda[post])),
    n_ipm_fallback = e14_counter(fit, "n_ipm_fallback", "warm_fallback"),
    n_sigma_guard = e14_counter(fit, "n_sigma_guard", "sigma_guard"),
    seconds = fit$seconds
  )
  if (save_posterior_means) {
    result$b0 <- b0
    result$coverage <- mean(dat$truth >= lo & dat$truth <= hi)
    result$lambda_mean <- mean(fit$lambda[post])
    result$sigma_mean <- mean(fit$sigma[post])
  }
  result
}

e14_main <- function(args, tasks = e14_tasks(), fit_task = e14_fit) {
  if (!length(args) %in% c(2L, 3L) || (length(args) == 3L && args[3L] != "--smoke"))
    stop("Usage: Rscript e14_run.R RUN_DIR TASK_INDEX [--smoke]")
  smoke <- length(args) == 3L
  index <- suppressWarnings(as.integer(args[2L]))
  if (!grepl("^[0-9]+$", args[2L]) || is.na(index) || index >= nrow(tasks))
    stop("Task index must be between 0 and ", nrow(tasks) - 1L)
  task <- as.list(tasks[index + 1L, ])
  run <- normalizePath(args[1L], mustWork = TRUE)
  code <- file.path(run, "code")
  out <- file.path(run, if (smoke) "out-smoke" else "out")
  dir.create(out, showWarnings = FALSE)
  result_path <- file.path(out, paste0(task$id, ".rds"))
  fail_path <- file.path(out, paste0(task$id, ".fail.rds"))
  if (file.exists(result_path)) {
    unlink(fail_path)
    cat("Already complete ", task$id, "\n", sep = "")
    return(0L)
  }

  commit <- NA_character_
  hostname <- Sys.info()[["nodename"]]
  started <- proc.time()[["elapsed"]]
  tryCatch({
    manifest <- read.dcf(file.path(code, "run_manifest.dcf"), fields = "Sampler-Commit")
    stopifnot(nrow(manifest) == 1L, !is.na(manifest[1L, 1L]),
              grepl("^[[:xdigit:]]{40}$", manifest[1L, 1L]))
    commit <- manifest[1L, 1L]

    fit <- fit_task(task, code, smoke)
    e14_atomic_rds(c(task, fit, list(commit = commit, hostname = hostname)), result_path)
    unlink(fail_path)
    cat(sprintf("%s | %.3f s | %.6f s/sweep | MSE %.6g | MAD %.6g | MCIW %.6g\n",
                task$id, fit$seconds, fit$seconds / fit$sweeps, fit$mse, fit$mad, fit$mciw))
    0L
  }, error = function(err) {
    message(task$id, " failed: ", conditionMessage(err))
    if (!file.exists(result_path)) {
      e14_atomic_rds(c(task, list(error = conditionMessage(err), commit = commit,
                                 hostname = hostname, seconds = proc.time()[["elapsed"]] - started)),
                     fail_path)
      if (file.exists(result_path)) unlink(fail_path)
    }
    1L
  })
}

if (sys.nframe() == 0L) quit(status = e14_main(commandArgs(trailingOnly = TRUE)))
