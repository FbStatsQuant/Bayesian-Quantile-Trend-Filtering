# From the repository root, use owls_run -j 1 -- Rscript --vanilla
# engineering/E20_Showcase/e20_run.R {individual-q10|individual-q90|joint|export}.
args <- commandArgs(trailingOnly = TRUE)
fit_names <- c("individual-q10", "individual-q90", "joint")
if (length(args) != 1L || !args[1L] %in% c(fit_names, "export"))
  stop("Choose individual-q10, individual-q90, joint, or export.")
if (!grepl("^owls([.]|$)", Sys.info()[["nodename"]]) ||
    Sys.getenv("OWLS_JOB_CORES") != "1")
  stop("Run on Owls with owls_run -j 1.")

root <- normalizePath(".")
out_dir <- file.path(root, "engineering", "E20_Showcase")
run_dir <- file.path(root, "runs", "E20-showcase-20261126")
dir.create(run_dir, showWarnings = FALSE, recursive = TRUE)
source(file.path(root, "engineering", "E14_Inner_Rerun", "e14_run.R"))

sampler_commit <- "63f2a56205b8d2ec311565db8c98874cd96754b2"
generator_file <- file.path("experiments", "interior_quantiles",
  "individual_nots_20261003", "source", "Individual_Sampler_PMALA_Augmented.R")
generator_commit <- "2ed6baec9fe8e5673419b2b93b0de821db5a337c"
data_seed <- 1L
n_showcase <- 1000L
taus <- c(0.1, 0.9)
chain_seeds <- setNames(c(10001L, 10002L, 10003L), fit_names)
fit_paths <- setNames(file.path(out_dir, paste0(fit_names, ".rds")), fit_names)

git_read <- function(args) {
  result <- system2("git", args, stdout = TRUE)
  if (!is.null(attr(result, "status"))) stop("git failed: ", paste(args, collapse = " "))
  result
}

make_data <- function() {
  # E-14 extracts this same generator; its wrapper fixes n=500.
  definitions <- parse(text = git_read(c("show", paste0(generator_commit, ":", generator_file))))
  generator <- Filter(function(expr) {
    is.call(expr) && identical(expr[[1L]], quote(`<-`)) &&
      identical(expr[[2L]], quote(simulate_data))
  }, as.list(definitions))
  stopifnot(length(generator) == 1L)
  eval(generator[[1L]])
  dat <- simulate_data(data_seed, n_showcase, 0.5, "VS", "Normal")
  stopifnot(identical(dat$x, seq_len(n_showcase)), length(dat$y) == n_showcase,
            length(dat$baseline) == n_showcase, all(is.finite(c(dat$y, dat$baseline))))
  list(x = dat$x, y = dat$y, truth = dat$baseline)
}

load_sampler <- function(joint) {
  snapshot <- tempfile("sampler-", tmpdir = run_dir)
  dir.create(snapshot)
  sampler_files <- c(
    "method/individual/Individual_Sampler_PMALA_Augmented.R",
    "method/individual/prox_admm_metric.cpp",
    "method/joint/Joint_Sampler_PMALA_Augmented.R",
    "method/joint/prox_box_metric.cpp"
  )
  for (path in sampler_files) {
    destination <- file.path(snapshot, path)
    dir.create(dirname(destination), recursive = TRUE, showWarnings = FALSE)
    writeLines(git_read(c("show", paste0(sampler_commit, ":", path))), destination)
  }
  if (!joint) {
    e14_load_sampler(snapshot)
    return(invisible(NULL))
  }

  joint_dir <- file.path(snapshot, "method", "joint")
  old_dir <- setwd(joint_dir)
  on.exit(setwd(old_dir), add = TRUE)
  lines <- readLines("Joint_Sampler_PMALA_Augmented.R")
  main_at <- grep("^# ---- Main", lines)
  stopifnot(length(main_at) == 1L)
  eval(parse(text = lines[seq_len(main_at - 1L)]), envir = globalenv())
  load_box_cpp(joint_dir, file.path(snapshot, "method", "individual"))
}

run_fit <- function(id, dat) {
  joint <- id == "joint"
  tau <- if (joint) taus else taus[match(id, fit_names)]
  git_head <- git_read(c("rev-parse", "HEAD"))
  load_sampler(joint)

  # Individual arguments follow e14_fit, with the shared showcase data.
  settings <- list(
    order = 2L, a0 = 1, b0 = if (joint) 0.01 else 1e-3, a_sigma = 0.1, b_sigma = 0.1,
    gibbs_iter = 30000L, gibbs_burn = 10000L, delta_init = delta_init,
    lambda_init = lambda_init, adapt_target = adapt_target, adapt_gain = adapt_gain,
    adapt_kappa = adapt_kappa, delta_bounds = delta_bounds, metric = metric,
    c_fixed = c_metric, rho = admm_rho, iters = admm_iter, mh = mh_correct,
    adapt = adapt_delta, warm = 200L, gamma_warm = gamma_warm, kappa = kappa_metric,
    adapt_all = TRUE, K = K_theta, asis = TRUE, tol = admm_tol,
    asis_q = if (joint) asis_q else "fixed", verbose = TRUE,
    warm_lam = warm_lambda, guard = sigma_guard
  )
  if (joint) {
    settings <- c(settings, list(zeta_scale = zeta_scale, ctrl = box_ctrl, keep_every = 1L))
    sampler <- gibbs_joint_pmala
    fit_args <- c(list(y = dat$y, tau_list = tau), settings)
  } else {
    settings <- c(settings, list(control = tf_control, init = theta_init,
      prior_scale = prior_scale, cmap = FALSE, lamjump = lamjump, lamjump_s = lamjump_s,
      block = 0L, block_mode = block_mode))
    sampler <- gibbs_pmala_aug
    fit_args <- c(list(y = dat$y, tau = tau), settings)
  }

  RNGkind("Mersenne-Twister", "Inversion", "Rejection")
  set.seed(chain_seeds[[id]])
  start <- proc.time()
  fit <- do.call(sampler, fit_args)
  elapsed <- proc.time() - start
  post <- seq.int(settings$gibbs_burn + 1L, settings$gibbs_iter)
  stopifnot(identical(dim(fit$theta), if (joint) c(length(post), n_showcase, length(tau))
                     else c(length(post), n_showcase)),
            all(is.finite(fit$theta)), all(is.finite(fit$lambda) & fit$lambda > 0),
            all(is.finite(fit$sigma) & fit$sigma > 0))
  lambda <- matrix(fit$lambda, nrow = settings$gibbs_iter)
  sigma <- matrix(fit$sigma, nrow = settings$gibbs_iter)
  levels <- lapply(seq_along(tau), function(j) {
    draws <- if (joint) fit$theta[, , j] else fit$theta
    interval <- apply(draws, 2L, quantile, probs = c(0.025, 0.975), type = 7L)
    list(tau = tau[j], mean = colMeans(draws), lo = interval[1L, ], hi = interval[2L, ],
         acceptance = fit$acc_post[j], lambda_ess = as.numeric(coda::effectiveSize(lambda[post, j])),
         sigma_guards = fit$n_sigma_guard[j])
  })
  list(id = id, data = dat, data_seed = data_seed, generator_commit = generator_commit,
       chain_seed = chain_seeds[[id]], git_head = git_head,
       sampler_commit = sampler_commit, r_version = R.version.string,
       settings = settings, asis_q_grid = fit$asis_q_grid, lambda_hold_until = fit$lambda_hold_until,
       wall_seconds = unname(elapsed[["elapsed"]]),
       cpu_seconds = unname(elapsed[["user.self"]] + elapsed[["sys.self"]]),
       levels = levels, lambda = lambda, sigma = sigma)
}

export_curves <- function(dat) {
  fits <- lapply(fit_paths, readRDS)
  stopifnot(identical(unname(vapply(fits, `[[`, "", "id")), fit_names),
            all(vapply(fits, function(fit) identical(fit$data, dat), logical(1L))))
  method_rows <- function(method, levels) {
    q10 <- levels[[1L]]
    q90 <- levels[[2L]]
    stopifnot(identical(c(q10$tau, q90$tau), taus))
    data.frame(method = method, x = dat$x, y = dat$y, truth = dat$truth,
      q10 = q10$mean, q90 = q90$mean, q10_lo = q10$lo, q10_hi = q10$hi,
      q90_lo = q90$lo, q90_hi = q90$hi)
  }
  curves <- rbind(method_rows("joint", fits$joint$levels),
    method_rows("individual", c(fits[["individual-q10"]]$levels,
                                fits[["individual-q90"]]$levels)))
  stopifnot(nrow(curves) == 2L * n_showcase, !anyDuplicated(curves[c("method", "x")]),
            all(curves$q10[curves$method == "joint"] <= curves$q90[curves$method == "joint"]),
            all(curves$q10_lo <= curves$q10_hi), all(curves$q90_lo <= curves$q90_hi),
            all(is.finite(as.matrix(curves[-1L]))))
  tmp <- tempfile(".curves-", tmpdir = out_dir)
  on.exit(unlink(tmp), add = TRUE)
  write.csv(curves, tmp, row.names = FALSE)
  if (!file.rename(tmp, file.path(out_dir, "curves.csv"))) stop("Could not publish curves.csv")
  for (method in c("joint", "individual")) {
    rows <- curves[curves$method == method, ]
    cat(sprintf("%s: crossings %d, inside fraction %.3f\n", method,
                sum(rows$q10 > rows$q90), mean(rows$y >= rows$q10 & rows$y <= rows$q90)))
  }
}

if (args[1L] == "export") {
  export_curves(make_data())
} else {
  id <- args[1L]
  path <- fit_paths[[id]]
  stopifnot(requireNamespace("coda", quietly = TRUE))
  result <- run_fit(id, make_data())
  e14_atomic_rds(result, path)
  cat(sprintf("%s: wall %.3f s, CPU %.3f s, %s\n",
              id, result$wall_seconds, result$cpu_seconds, result$r_version))
  for (level in result$levels)
    cat(sprintf("tau %.1f: acceptance %.5f, lambda ESS %.3f, sigma guards %d\n",
                level$tau, level$acceptance, level$lambda_ess, level$sigma_guards))
}
