# Joint (non-crossing) sampler worker. Usage: Rscript --vanilla worker_joint.R RUN_DIR INDEX
# Loads the definitions and Settings block of the unchanged joint sampler (source/Joint), then evaluates
# its own Main-section call `fit <- gibbs_joint_pmala(...)`, so every saved setting is used.
# Only these names are rebound: dat (task data), tau_list (cfg$fit_taus), b0 (by baseline),
# gibbs_iter, gibbs_burn and, in validation only, cfg$joint_validation_overrides.
options(warn = 1)
args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 2L) stop("Usage: worker_joint.R RUN_DIR INDEX")
stopifnot(!any(grepl("=", args)))   # the source's Settings block parses key=value command-line overrides
run_root <- normalizePath(args[1], mustWork = TRUE)
code_root <- file.path(run_root, "code")
source(file.path(code_root, "Extreme_Joint_Sampler", "config.R"))
source(file.path(code_root, "Extreme_Joint_Sampler", "common_extreme.R"))
validate_config(cfg)
grid <- task_grid(cfg)
index <- suppressWarnings(as.integer(args[2]))
stopifnot(!is.na(index), as.character(index) == args[2], index %in% grid$index)
row <- grid[index, , drop = FALSE]

load_joint <- function(code_root) {
  src <- file.path(code_root, "Extreme_Joint_Sampler", "source", "Joint")
  ind <- file.path(code_root, "Extreme_Joint_Sampler", "source", "Individual")
  old <- setwd(src); on.exit(setwd(old))
  lines <- readLines("Joint_Sampler_PMALA_Augmented.R", warn = FALSE)
  main <- grep("^# ---- Main", lines)
  stopifnot(length(main) == 1L)
  env <- new.env(parent = globalenv())
  eval(parse(text = lines[seq_len(main - 1L)]), envir = env)       # definitions + Settings block only
  stopifnot(env$order == cfg$order)
  env$load_box_cpp(src, ind)
  main_exprs <- parse(text = lines[main:length(lines)])
  is_fit <- vapply(main_exprs, function(e) is.call(e) && identical(e[[1]], as.name("<-")) &&
                     identical(e[[2]], as.name("fit")), logical(1))
  stopifnot(sum(is_fit) == 1L)
  call <- main_exprs[[which(is_fit)]][[3]]
  stopifnot(identical(call[[1]], as.name("gibbs_joint_pmala")))
  list(env = env, call = call)
}

fit_joint <- function(dat, row) {
  s <- load_joint(code_root)
  ce <- new.env(parent = s$env)
  ce$dat <- list(y = dat$y); ce$tau_list <- cfg$fit_taus
  ce$b0 <- cfg$lambda_prior_rate[[row$baseline]]
  ce$gibbs_iter <- cfg$mcmc_iter; ce$gibbs_burn <- cfg$mcmc_burn
  for (k in names(cfg$joint_validation_overrides)) {
    stopifnot(exists(k, envir = s$env, inherits = FALSE)); assign(k, cfg$joint_validation_overrides[[k]], envir = ce)
  }
  used <- setdiff(all.vars(s$call), c("dat", "y"))
  settings <- mget(used, envir = ce, inherits = TRUE)
  set.seed(row$seed + cfg$sampler_seed_offset)
  rng_before <- .Random.seed
  fit <- eval(s$call, ce)
  J <- length(cfg$fit_taus); keep <- cfg$mcmc_iter - cfg$mcmc_burn
  stopifnot(identical(dim(fit$theta), c(keep, cfg$n, J)), all(is.finite(fit$theta)),
            identical(as.numeric(fit$tau), cfg$fit_taus))
  # Every retained draw must be ordered at every index (the sampler enforces it; re-checked here).
  viol <- vapply(seq_len(J - 1L), function(j) max(0, fit$theta[, , j] - fit$theta[, , j + 1L]), numeric(1))
  stopifnot(all(viol == 0))
  est_all <- apply(fit$theta, c(2, 3), mean)
  colnames(est_all) <- tau_label(cfg$fit_taus)
  post <- seq.int(cfg$mcmc_burn + 1L, cfg$mcmc_iter)
  list(est = est_all[, tau_label(cfg$report_taus), drop = FALSE],
       diag = list(settings_used = settings, saved_call = deparse(s$call), rng_before = rng_before,
                   fit_taus = cfg$fit_taus, est_all_levels = est_all, max_adjacent_draw_violation = viol,
                   acc_post = fit$acc_post, outside_post = fit$outside_post, ipm_post = fit$ipm_post,
                   asis_moved_post = fit$asis_moved_post, delta_final = fit$delta_final,
                   lambda_mean = colMeans(fit$lambda[post, , drop = FALSE]),
                   sigma_mean = colMeans(fit$sigma[post, , drop = FALSE]),
                   lambda = fit$lambda, sigma = fit$sigma, delta = fit$delta, acc = fit$acc,
                   theta_mid = fit$theta[, cfg$n %/% 2L, ], sampler_seconds = fit$seconds))
}

run_extreme_task(run_root, code_root, row, task_root_of(run_root, row), cfg, cfg$report_taus, fit_joint, "joint")
