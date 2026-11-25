#!/usr/bin/env Rscript
args <- commandArgs(trailingOnly = TRUE)
entry <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE)[[1L]])
source(file.path(dirname(entry), "design.R"))

tasks <- make_tasks()
if (identical(args, "manifest")) {
  write.table(tasks, stdout(), sep = "\t", row.names = FALSE, quote = FALSE)
  quit(save = "no")
}

stopifnot(length(args) == 2L, args[1] %in% c("pilot", "full"), identical(Sys.getenv("OWLS_ENV_SOURCED"), "1"))
mode <- args[1]
task <- tasks[tasks$id == args[2], , drop = FALSE]
stopifnot(nrow(task) == 1L)
iter <- if (mode == "pilot") 1200L else full_iter
burn <- if (mode == "pilot") 800L else full_burn
run_dir <- run_directory()
output <- file.path(run_dir, mode, paste0(task$id, ".rds"))
if (file.exists(output)) quit(save = "no")
sampler_root <- file.path(run_dir, "source", "method")
commit <- readLines(file.path(run_dir, "source", "sampler-commit.txt"))
stopifnot(length(commit) == 1L, startsWith(commit, sampler_revision))

load_sampler <- function(joint) {
  folder <- if (joint) "joint" else "individual"
  filename <- if (joint) "Joint_Sampler_PMALA_Augmented.R" else "Individual_Sampler_PMALA_Augmented.R"
  old <- setwd(file.path(sampler_root, folder))
  on.exit(setwd(old))
  lines <- readLines(filename)
  main <- grep("^# ---- Main", lines)
  stopifnot(length(main) == 1L)
  eval(parse(text = head(lines, main - 1L)), envir = globalenv())
  if (joint) load_box_cpp() else load_prox_cpp()
}

count_joint_crossings <- function(draws, estimate) {
  by_pair <- lapply(seq_len(ncol(estimate) - 1L), function(j) {
    any_cross <- rep(FALSE, dim(draws)[1L])
    instances <- 0
    for (i in seq_len(nrow(estimate))) {
      crossed <- draws[, i, j] > draws[, i, j + 1L]
      instances <- instances + sum(crossed)
      any_cross <- any_cross | crossed
    }
    list(instances = instances, any_cross = any_cross, mean_cross = sum(estimate[, j] > estimate[, j + 1L]))
  })
  list(
    adjacent_draw_instances = vapply(by_pair, function(x) x$instances, numeric(1)),
    draws_with_any_cross = sum(Reduce(`|`, lapply(by_pair, function(x) x$any_cross))),
    adjacent_mean_crossings = vapply(by_pair, function(x) x$mean_cross, integer(1))
  )
}

run_sampler <- function(task, dat, tau_levels, iter, burn, joint) {
  shared <- list(
    y = dat$y, order = 2L, a0 = 1, b0 = task$b0, a_sigma = 0.1, b_sigma = 0.1,
    gibbs_iter = iter, gibbs_burn = burn, delta_init = delta_init, lambda_init = NULL,
    adapt_target = adapt_target, adapt_gain = adapt_gain, adapt_kappa = adapt_kappa,
    delta_bounds = delta_bounds, metric = "curv", rho = NULL, iters = admm_iter,
    mh = TRUE, adapt = TRUE, warm = warm_iter, gamma_warm = gamma_warm,
    kappa = kappa_metric, adapt_all = TRUE, K = 1L, asis = TRUE, tol = 0,
    asis_q = "fixed", verbose = TRUE
  )
  if (joint) {
    return(do.call(gibbs_joint_pmala, c(shared, list(
      tau_list = tau_levels, c_fixed = 0, zeta_scale = zeta_scale, ctrl = box_ctrl
    ))))
  }
  do.call(gibbs_pmala_aug, c(shared, list(
    tau = tau_levels, control = tf_control, c_fixed = c_metric, init = "data",
    prior_scale = "none", cmap = FALSE, lamjump = FALSE, block = 0L
  )))
}

summarize_fit <- function(fit, truth, n_levels, joint, iter, burn) {
  post <- seq.int(burn + 1L, iter)
  draws <- fit$theta
  if (!joint) dim(draws) <- c(length(post), n_observations, 1L)
  estimate <- matrix(colMeans(draws, dims = 1L), n_observations, n_levels)
  lower <- upper <- matrix(NA_real_, n_observations, n_levels)
  for (j in seq_len(n_levels)) {
    for (i in seq_len(n_observations)) {
      band <- quantile(draws[, i, j], c(0.025, 0.975), names = FALSE)
      lower[i, j] <- band[1L]
      upper[i, j] <- band[2L]
    }
  }
  list(
    posterior_mean = estimate, lower95 = lower, upper95 = upper,
    mse = colMeans((estimate - truth)^2), acceptance = fit$acc_post,
    lambda = matrix(fit$lambda, nrow = iter)[post, , drop = FALSE],
    sigma = matrix(fit$sigma, nrow = iter),
    n_sigma_guard = fit$n_sigma_guard, n_ipm_fallback = fit$n_ipm_fallback,
    crossings = if (joint) count_joint_crossings(draws, estimate) else NULL
  )
}

main <- function() {
  joint <- task$kind == "joint"
  load_sampler(joint)
  tau_levels <- if (joint) taus else task$tau
  dat <- simulate_data(task$data_seed, n_observations, tau_levels, task$baseline, "Normal")
  set.seed(task$chain)
  cat(sprintf("[%s] %s | %s | %d sweeps, %d burn-in | %s\n",
              format(Sys.time(), "%FT%T%z"), mode, task$id, iter, burn, commit))
  start <- proc.time()
  fit <- tryCatch(run_sampler(task, dat, tau_levels, iter, burn, joint), error = identity)
  elapsed <- proc.time() - start
  crashed <- inherits(fit, "error")
  result <- list(
    task = task, tau = tau_levels, iter = iter, burn = burn, warm = warm_iter,
    commit = commit, r_version = R.version.string, y = dat$y,
    crashed = crashed, seconds = unname(elapsed["elapsed"]),
    sampler_cpu_seconds = unname(sum(elapsed[c("user.self", "sys.self")])),
    finished = format(Sys.time(), "%FT%T%z")
  )
  if (crashed) {
    result$error <- conditionMessage(fit)
    message("Sampler error: ", result$error)
  } else {
    result <- c(result, summarize_fit(fit, dat$truth, length(tau_levels), joint, iter, burn))
  }
  temporary <- tempfile(paste0(task$id, "-"), tmpdir = dirname(output), fileext = ".tmp")
  on.exit(unlink(temporary))
  saveRDS(result, temporary)
  if (!file.rename(temporary, output)) stop("Could not publish ", output)
  cat(sprintf("%s | %.3f s elapsed | %.3f CPU s | crashed %s\n",
              task$id, result$seconds, result$sampler_cpu_seconds, crashed))
}

main()
