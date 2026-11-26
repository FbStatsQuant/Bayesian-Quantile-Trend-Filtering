e18_pin <- "63f2a56205b8d2ec311565db8c98874cd96754b2"
e18_taus <- c(.01, .05, .10)
e18_rates <- 10^-(3:6)
e18_h <- c(.5, .75, 1, 1.2)
e18_pilot_indices <- c(0L, 100L, 200L, 900L, 1000L, 1100L)
e18_post <- 10001:30000
# E-14's every-30th-sweep trace, restricted to the retained portion.
e18_thin <- seq.int(1L, 30000L, by = 30L)
e18_thin <- e18_thin[e18_thin > 10000L]
e18_archive <- file.path("experiments", "air_simulation", "onizuka_laplace_20261023",
  "attempt_20261023T171713_511660", "results.rds")
e18_archive_sha <- "4e4dd9fccd4bb83df3905cafb1b4260358069b6b5b9d982aa45ec4412397e9ba"

e18_grid <- function(stage) {
  g <- if (stage == "sim") expand.grid(seed = 1:100, tau = e18_taus, b0 = e18_rates)
    else if (stage == "real") expand.grid(seed = 1:2, tau = e18_taus, b0 = e18_rates)
    else if (stage == "admm-sim") expand.grid(seed = 1:100, tau = e18_taus)
    else if (stage == "admm-real") data.frame(seed = 1L, tau = e18_taus)
    else stop("Unknown stage: ", stage)
  g$index <- seq_len(nrow(g)) - 1L
  g$id <- if ("b0" %in% names(g)) sprintf("t%02d_r%d_s%03d",
    round(100 * g$tau), round(-log10(g$b0)), g$seed)
    else sprintf("t%02d_s%03d", round(100 * g$tau), g$seed)
  g
}

e18_air_generator <- function(code, driver = "individual_air_sim.R") {
  path <- file.path(code, "experiments", "air_simulation", "drivers", driver)
  expressions <- as.list(parse(path, keep.source = FALSE))
  def <- Filter(function(x) is.call(x) && identical(x[[1L]], quote(`<-`)) &&
    identical(x[[2L]], quote(simulate_air)), expressions)
  stopifnot(length(def) == 1L)
  env <- list2env(list(ns = splines::ns), parent = globalenv())
  eval(def[[1L]], envir = env)
  env$simulate_air
}

e18_sha <- function(path) {
  res <- system2("sha256sum", shQuote(path), stdout = TRUE)
  stopifnot(length(res) == 1L, is.null(attr(res, "status")))
  substr(res, 1L, 64L)
}

e18_vector_sha <- function(x) {
  path <- tempfile()
  on.exit(unlink(path))
  writeBin(as.double(x), path, endian = "little")
  e18_sha(path)
}

e18_table2_archive <- function(code) {
  path <- file.path(code, e18_archive)
  stopifnot(identical(e18_sha(path), e18_archive_sha))
  readRDS(path)
}

e18_metrics <- function(y, est, truth, signal, tau, lo = NULL, hi = NULL) {
  residual <- y - est
  positive <- signal > .5
  caa <- vapply(e18_h, function(h) {
    if (!any(positive) || all(positive)) return(NA_real_)
    mean(c(mean(residual[positive] > h), mean(residual[!positive] <= h)))
  }, numeric(1L))
  c(MSE = mean((est - truth)^2), CL = mean(residual * (tau - (residual < 0))),
    setNames(caa, paste0("CAA_", e18_h)),
    coverage = if (is.null(lo)) NA_real_ else mean(lo <= truth & truth <= hi))
}

e18_atomic <- function(value, path) {
  tmp <- tempfile(pattern = ".e18-", tmpdir = dirname(path))
  on.exit(unlink(tmp))
  saveRDS(value, tmp)
  if (!file.rename(tmp, path)) stop("Could not publish ", path)
}

e18_real_input <- function(run) {
  approval <- read.dcf(file.path(run, "STAGE2_GO.dcf"), fields = c("Run", "Input-SHA256"))
  input <- file.path(run, "spod_blocks.rds")
  sha <- e18_sha(input)
  stopifnot(nrow(approval) == 1L, approval[1L, "Run"] == basename(run),
            approval[1L, "Input-SHA256"] == sha)
  list(data = readRDS(input), sha = sha)
}

e18_fit <- function(code, task, y, truth = NULL, save_theta = FALSE) {
  original <- new.env(parent = globalenv())
  sys.source(file.path(code, "engineering", "E14_Inner_Rerun", "e14_run.R"), envir = original)
  original$e14_load_sampler(code)
  stopifnot(adapt_target == .5, identical(theta_init, "data"),
    identical(warm_lambda, "hold"), lambda_hold_extra == 0L)
  RNGkind("Mersenne-Twister", "Inversion", "Rejection")
  chain_seed <- task$seed + 1000L
  set.seed(chain_seed)
  t0 <- proc.time()[["elapsed"]]
  fit <- gibbs_pmala_aug(
    y, task$tau, order = 2L, a0 = 1, b0 = task$b0, a_sigma = .1, b_sigma = .1,
    gibbs_iter = 30000L, gibbs_burn = 10000L, delta_init = delta_init,
    lambda_init = lambda_init, adapt_target = adapt_target, adapt_gain = adapt_gain,
    adapt_kappa = adapt_kappa, delta_bounds = delta_bounds, control = tf_control,
    metric = metric, c_fixed = c_metric, rho = admm_rho, iters = admm_iter,
    mh = mh_correct, adapt = adapt_delta, init = theta_init, warm = 200L,
    gamma_warm = gamma_warm, prior_scale = prior_scale, cmap = FALSE,
    kappa = kappa_metric, adapt_all = TRUE, K = K_theta, asis = TRUE,
    tol = admm_tol, lamjump = lamjump, lamjump_s = lamjump_s, asis_q = "fixed",
    block = 0L, block_mode = block_mode, verbose = TRUE
  )
  stopifnot(nrow(fit$theta) == length(e18_post), ncol(fit$theta) == length(y),
    all(is.finite(fit$theta)), length(e18_thin) == 666L,
    length(fit$lambda) == 30000L, length(fit$sigma) == 30000L,
    all(is.finite(fit$lambda) & fit$lambda > 0),
    all(is.finite(fit$sigma) & fit$sigma > 0))
  th <- fit$theta[e18_thin - 10000L, , drop = FALSE]
  stopifnot(requireNamespace("coda", quietly = TRUE))
  ess <- coda::effectiveSize(th)
  log_lambda <- log(fit$lambda[e18_thin])
  bands <- if (!is.null(truth)) apply(fit$theta, 2L, quantile, probs = c(.025, .975), type = 7L)
  list(est = colMeans(fit$theta), lo = if (!is.null(bands)) bands[1L, ],
    hi = if (!is.null(bands)) bands[2L, ], theta_thin = if (save_theta) th,
    chain_seed = chain_seed, log_lambda = log_lambda,
    ess_log_lambda = as.numeric(coda::effectiveSize(log_lambda)),
    lambda_ess_e14 = as.numeric(coda::effectiveSize(fit$lambda[e18_post])),
    ess_theta_median = median(ess), ess_theta_p05 = unname(quantile(ess, .05)),
    ess_error_sq = if (!is.null(truth)) as.numeric(coda::effectiveSize(rowSums(sweep(th, 2L, truth)^2))),
    acc = fit$acc_post, n_sigma_guard = fit$n_sigma_guard,
    n_ipm_fallback = fit$n_ipm_fallback, seconds = proc.time()[["elapsed"]] - t0,
    sampler_seconds = fit$seconds, commit = e18_pin)
}

e18_admm <- function(y, tau, grid) {
  stopifnot(requireNamespace("detrendr", quietly = TRUE))
  remote_sha <- utils::packageDescription("detrendr")$RemoteSha
  if (is.null(remote_sha) || !startsWith(remote_sha, "17e3e7c"))
    stop("Expected detrendr GitHub revision 17e3e7c; found ", if (is.null(remote_sha)) "no RemoteSha" else remote_sha)
  t0 <- proc.time()[["elapsed"]]
  fit <- detrendr::get_trend_BIC(y, tau, 3L, lambdaSeq = grid, criteria = "eBIC", solver = NULL)
  est <- as.numeric(fit$trend)
  stopifnot(length(est) == length(y), all(is.finite(est)), length(fit$lambda) == 1L,
    is.finite(fit$lambda), fit$lambda %in% grid)
  list(est = est, lambda_selected = fit$lambda, seconds = proc.time()[["elapsed"]] - t0,
    detrendr = as.character(utils::packageVersion("detrendr")),
    remote_sha = remote_sha)
}
