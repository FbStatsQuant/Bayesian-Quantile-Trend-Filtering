# Run from the E-18 repository root. Rscript run_fits.R OUT [owls | admm [ADMM_RUN]]
# OUT/pin holds the 63f2a56 sampler and its two C++ kernels, plus the E-14
# data wrapper and the archived campaign generator at their repository paths.
args <- commandArgs(TRUE)
stopifnot(length(args) %in% 1:3)
out <- normalizePath(args[1L], mustWork = TRUE)
mode <- if (length(args) >= 2L) args[2L] else "owls"
stopifnot(mode %in% c("owls", "admm"), mode == "admm" || length(args) <= 2L)
if (mode == "owls" && !nzchar(Sys.getenv("OWLS_JOB_CORES"))) stop("Use owls_run for the Owls diagnostics.")
source("engineering/E18_Air_Refit/e18_common.R")
pin <- file.path(out, "pin")
e14 <- new.env()
sys.source("engineering/E14_Inner_Rerun/e14_run.R", envir = e14)
e14$e14_load_sampler(pin)
archive <- e18_table2_archive(".")
offsets <- e18_table2_offsets(".")

memory_gate <- function() {
  line <- grep("^MemAvailable:", readLines("/proc/meminfo"), value = TRUE)
  stopifnot(as.numeric(strsplit(trimws(line), "[[:space:]]+")[[1L]][2L]) >= 15 * 1024^2)
}
fit_air <- function(arm, seed) {
  tau <- if (arm == 5L) .01 else .05
  d <- archive$data[[seed]]
  truth <- d$theta + offsets[match(tau, e18_taus)]
  burn <- if (arm == 2L) 30000L else 10000L
  sweeps <- 3L * burn
  a0 <- if (arm %in% 4:5) length(d$y) else 1
  b0 <- if (arm %in% 4:5) .01 else 1e-6
  init <- theta_init
  start_lambda <- length(d$y) - 3L
  admm_lambda <- NA_real_
  if (arm == 3L) {
    id <- sprintf("t05_s%03d", seed)
    grid <- 500^seq(0, 1.4, length.out = 15L)
    admm <- if (length(args) == 3L) {
      rec <- readRDS(file.path(args[3L], "admm-sim", paste0(id, ".rds")))
      stopifnot(rec$stage == "admm-sim", rec$task$id == id, rec$task$seed == seed, rec$task$tau == tau,
        startsWith(rec$remote_sha, "17e3e7c"), rec$y_sha == e18_vector_sha(d$y),
        rec$baseline_sha == e18_vector_sha(d$theta), rec$truth_sha == e18_vector_sha(truth),
        rec$lambda_selected %in% grid)
      rec
    } else e18_admm(d$y, tau, grid)
    stopifnot(prior_scale == "none", length(admm$est) == length(d$y), all(is.finite(admm$est)))
    sigma0 <- pilot_fit(d$y, tau)$sigma[1L]
    # Multiply check-loss + sigma0 * lambda * ||D theta||_1 by 1/sigma0.
    admm_lambda <- admm$lambda_selected
    start_lambda <- admm_lambda / sigma0
    init <- list(theta = admm$est, sigma = sigma0, lambda = start_lambda)
  }
  RNGkind("Mersenne-Twister", "Inversion", "Rejection")
  set.seed(seed + 1000L)
  start <- proc.time()
  fit <- gibbs_pmala_aug(
    d$y, tau, order = 2L, a0 = a0, b0 = b0, a_sigma = .1, b_sigma = .1,
    gibbs_iter = sweeps, gibbs_burn = burn, delta_init = delta_init,
    lambda_init = lambda_init, adapt_target = adapt_target, adapt_gain = adapt_gain,
    adapt_kappa = adapt_kappa, delta_bounds = delta_bounds, control = tf_control,
    metric = metric, c_fixed = c_metric, rho = admm_rho, iters = admm_iter,
    mh = mh_correct, adapt = adapt_delta, init = init, warm = 200L,
    gamma_warm = gamma_warm, prior_scale = prior_scale, cmap = FALSE,
    kappa = kappa_metric, adapt_all = TRUE, K = K_theta, asis = TRUE,
    tol = admm_tol, lamjump = lamjump, lamjump_s = lamjump_s, asis_q = "fixed",
    block = 0L, block_mode = block_mode, verbose = FALSE
  )
  post <- seq.int(burn + 1L, sweeps)
  # Same trace convention as E-18, every 30th/90th sweep starting at sweep 1.
  thin_by <- if (arm == 2L) 90L else 30L
  trace <- seq.int(1L, sweeps, by = thin_by)
  trace <- trace[trace > burn]
  stopifnot(length(trace) == 666L, nrow(fit$theta) == length(post), fit$lambda_hold_until == 200L)
  ess <- coda::effectiveSize(fit$theta[trace - burn, , drop = FALSE])
  est <- colMeans(fit$theta)
  bands <- apply(fit$theta, 2L, quantile, probs = c(.025, .975))
  # SD is computed in the sampler from the actual retained theta, after ASIS.
  squared <- (est - truth)^2
  peak <- d$s > .05
  lam <- fit$lambda[post]
  timing <- proc.time() - start
  summary <- data.frame(arm, tau, seed, a0, b0, sweeps, burn, thin_by,
    mse = mean(squared), mse_peak = sum(squared[peak]) / length(truth),
    mse_off_peak = sum(squared[!peak]) / length(truth),
    coverage = mean(bands[1L, ] <= truth & truth <= bands[2L, ]),
    lambda_mean = mean(lam), lambda_p10 = unname(quantile(lam, .1)), lambda_p90 = unname(quantile(lam, .9)),
    mean_Dtheta_l1 = mean(fit$SD[post]), log_lambda_ess = as.numeric(coda::effectiveSize(log(lam[trace - burn]))),
    theta_ess_median = median(ess), theta_ess_p10 = unname(quantile(ess, .1)),
    theta_ess_p05 = unname(quantile(ess, .05)), acceptance = fit$acc_post, sigma_guards = fit$n_sigma_guard,
    n_ipm_fallback = fit$n_ipm_fallback, n_warm_ipm_unconverged = sum(fit$warm_ipm_unconverged),
    admm_lambda, start_lambda, seconds = fit$seconds, cpu_seconds = sum(timing[1:2]), commit = e18_pin)
  e18_atomic(list(summary = summary, theta = fit$theta, lambda = lam,
    sigma = fit$sigma[post], roughness = fit$SD[post], est = est, truth = truth,
    thinned_sweeps = trace), file.path(out, sprintf("arm%d_s%03d.rds", arm, seed)))
  write.csv(summary, file.path(out, sprintf("arm%d_s%03d.csv", arm, seed)), row.names = FALSE)
}
interior_ids <- c("S_Beta_t50_s001", "VS_Mixed_t25_s001", "S_Normal_t75_s001")
replay_e14 <- function(seed) {
  id <- interior_ids[seed]
  grid <- e14$e14_tasks()
  t <- as.list(grid[grid$id == id, ])
  old <- readRDS(file.path("runs/E14-inner-rerun-20261125/out", paste0(id, ".rds")))
  stopifnot(identical(t$index, old$index), old$commit == e18_pin)
  # Delegate the replay to the original E-14 wrapper with its exact arguments.
  # The lexical proxy records counters from the untouched sampler's result.
  counters <- NULL
  e14$gibbs_pmala_aug <- function(...) {
    fit <- gibbs_pmala_aug(...)
    counters <<- c(ipm = fit$n_ipm_fallback, unconverged = sum(fit$warm_ipm_unconverged))
    fit
  }
  b0 <- if (is.null(old$b0)) c(VS = 1e-3, S = 5e-4)[[t$signal]] else old$b0
  t0 <- proc.time()
  x <- e14$e14_fit(t, pin, FALSE, b0 = b0, chain_seed = old$chain_seed)
  timing <- proc.time() - t0
  row <- data.frame(id, chain_seed = old$chain_seed, b0 = b0,
    old_mse = old$mse, mse = x$mse, mse_difference = x$mse - old$mse,
    n_ipm_fallback = unname(counters["ipm"]), n_warm_ipm_unconverged = unname(counters["unconverged"]),
    seconds = x$seconds, cpu_seconds = sum(timing[1:2]))
  write.csv(row, file.path(out, paste0("replay_", id, ".csv")), row.names = FALSE)
}

jobs <- if (mode == "admm") data.frame(arm = 3L, seed = 1:5) else
  rbind(expand.grid(seed = 1:5, arm = c(2L, 4L, 5L)), data.frame(seed = 1:3, arm = 14L))
requested <- Sys.getenv("E18_DIAG_TASKS")
if (nzchar(requested)) {
  labels <- with(jobs, sprintf("arm%d_s%03d", arm, seed))
  only <- match(strsplit(requested, ",", fixed = TRUE)[[1L]], labels)
  stopifnot(!anyNA(only), !anyDuplicated(only))
  jobs <- jobs[only, ]
}
work <- function(i) {
  arm <- jobs$arm[i]
  seed <- jobs$seed[i]
  label <- sprintf("arm%d_s%03d", arm, seed)
  expected <- if (arm == 14L) paste0("replay_", interior_ids[seed], ".csv") else paste0(label, c(".csv", ".rds"))
  if (all(file.exists(file.path(out, expected)))) return(TRUE)
  tryCatch({
    if (nzchar(Sys.getenv("OWLS_JOB_CORES"))) memory_gate()
    message("START ", label)
    if (arm == 14L) replay_e14(seed) else fit_air(arm, seed)
    message("DONE ", label)
    TRUE
  }, error = function(e) {
    message("FAIL ", label, ": ", conditionMessage(e))
    FALSE
  })
}
cores <- as.integer(Sys.getenv("OWLS_JOB_CORES", "1"))
if (!all(unlist(parallel::mclapply(seq_len(nrow(jobs)), work, mc.cores = cores, mc.set.seed = FALSE)))) quit(status = 1L)
