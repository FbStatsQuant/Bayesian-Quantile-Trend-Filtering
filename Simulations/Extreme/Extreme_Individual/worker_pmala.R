# Individual Bayesian-PMALA worker. Usage: Rscript --vanilla worker_pmala.R RUN_DIR INDEX
# Loads the definitions and Settings block of the unchanged sampler (source/), then evaluates the
# sampler's own Main-section call `fit <- gibbs_pmala_aug(...)`, so every saved setting is used.
# Only these names are rebound: dat, tau (task), order, b0 (by baseline), gibbs_iter, gibbs_burn
# (campaign overrides) and, in validation only, cfg$pmala_validation_overrides.
options(warn = 1)
args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 2L) stop("Usage: worker_pmala.R RUN_DIR INDEX")
run_root <- normalizePath(args[1], mustWork = TRUE)
code_root <- file.path(run_root, "code")
source(file.path(code_root, "Extreme_Individual", "config.R"))
source(file.path(code_root, "Extreme_Individual", "common_extreme.R"))
validate_config(cfg)
grid <- task_grid(cfg)
index <- suppressWarnings(as.integer(args[2]))
stopifnot(!is.na(index), as.character(index) == args[2], index %in% grid$index)
row <- grid[index, , drop = FALSE]
stopifnot(row$method == "pmala")

load_pmala <- function(code_root) {
  src <- file.path(code_root, "Extreme_Individual", "source")
  old <- setwd(src); on.exit(setwd(old))
  lines <- readLines("Individual_Sampler_PMALA_Augmented.R", warn = FALSE)
  main <- grep("^# ---- Main", lines)
  stopifnot(length(main) == 1L)
  env <- new.env(parent = globalenv())
  eval(parse(text = lines[seq_len(main - 1L)]), envir = env)       # definitions + Settings block only
  env$load_prox_cpp(file.path(src, "prox_admm_metric.cpp"))
  main_exprs <- parse(text = lines[main:length(lines)])
  is_fit <- vapply(main_exprs, function(e) is.call(e) && identical(e[[1]], as.name("<-")) &&
                     identical(e[[2]], as.name("fit")), logical(1))
  stopifnot(sum(is_fit) == 1L)
  call <- main_exprs[[which(is_fit)]][[3]]
  stopifnot(identical(call[[1]], as.name("gibbs_pmala_aug")))
  list(env = env, call = call)
}

fit_pmala <- function(dat, row) {
  s <- load_pmala(code_root)
  ce <- new.env(parent = s$env)
  ce$dat <- list(y = dat$y); ce$tau <- row$tau
  ce$order <- cfg$order; ce$b0 <- cfg$lambda_prior_rate[[row$baseline]]
  ce$gibbs_iter <- cfg$mcmc_iter; ce$gibbs_burn <- cfg$mcmc_burn
  for (k in names(cfg$pmala_validation_overrides)) {
    stopifnot(exists(k, envir = s$env, inherits = FALSE)); assign(k, cfg$pmala_validation_overrides[[k]], envir = ce)
  }
  # Every variable the saved call reads, after the overrides: recorded for audit.
  used <- setdiff(all.vars(s$call), c("dat", "y"))
  settings <- mget(used, envir = ce, inherits = TRUE)
  set.seed(row$seed + cfg$sampler_seed_offset)
  rng_before <- .Random.seed
  fit <- eval(s$call, ce)
  post <- seq.int(cfg$mcmc_burn + 1L, cfg$mcmc_iter)
  stopifnot(identical(dim(fit$theta), c(length(post), cfg$n)), all(is.finite(fit$theta)))
  list(est = colMeans(fit$theta),
       diag = list(settings_used = settings, saved_call = deparse(s$call), rng_before = rng_before,
                   acc_post = fit$acc_post, delta_final = fit$delta_final,
                   lambda_mean = mean(fit$lambda[post]), sigma_mean = mean(fit$sigma[post]),
                   lambda = fit$lambda, sigma = fit$sigma, delta = fit$delta, acc = fit$acc,
                   theta_mid = fit$theta[, cfg$n %/% 2L], sampler_seconds = fit$seconds))
}

run_extreme_task(run_root, code_root, row, task_root_of(run_root, row), cfg, cfg$taus, fit_pmala, "pmala")
