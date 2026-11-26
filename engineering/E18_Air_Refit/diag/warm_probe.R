# Capture warm inputs via an observer and replay the solver components.
args <- commandArgs(TRUE)
stopifnot(length(args) == 1L)
out <- normalizePath(args[1L], mustWork = TRUE)
pin <- file.path(out, "pin")
source("engineering/E18_Air_Refit/e18_common.R")
e14 <- new.env()
sys.source("engineering/E14_Inner_Rerun/e14_run.R", envir = e14)
e14$e14_load_sampler(pin)
d <- e18_table2_archive(".")$data[[1L]]
tau <- .05
targets <- c(1L, 50L, 200L)
states <- vector("list", length(targets))
sweep <- 0L
observe <- function(x, a, r, lambda, gamma, order, lower, upper, iters) {
  sweep <<- sweep + 1L
  wp <- warm_prox(x, a, r, lambda, gamma, order, lower, upper, iters)
  if (sweep %in% targets) {
    states[[match(sweep, targets)]] <<- list(x = x, a = a, r = r,
      sigma = get("sigma", envir = parent.frame()), lambda = lambda,
      gamma = gamma, order = order, lower = lower, upper = upper, iters = iters, result = wp)
  }
  wp
}
probe <- gibbs_pmala_aug
environment(probe) <- list2env(list(warm_prox = observe), parent = environment(probe))
RNGkind("Mersenne-Twister", "Inversion", "Rejection")
set.seed(1001L)
fit <- probe(
  d$y, tau, order = 2L, a0 = 1, b0 = 1e-6, a_sigma = .1, b_sigma = .1,
  gibbs_iter = 201L, gibbs_burn = 200L, delta_init = delta_init,
  lambda_init = lambda_init, adapt_target = adapt_target, adapt_gain = adapt_gain,
  adapt_kappa = adapt_kappa, delta_bounds = delta_bounds, control = tf_control,
  metric = metric, c_fixed = c_metric, rho = admm_rho, iters = admm_iter,
  mh = mh_correct, adapt = adapt_delta, init = theta_init, warm = 200L,
  gamma_warm = gamma_warm, prior_scale = prior_scale, cmap = FALSE,
  kappa = kappa_metric, adapt_all = TRUE, K = K_theta, asis = TRUE,
  tol = admm_tol, lamjump = lamjump, lamjump_s = lamjump_s, asis_q = "fixed",
  block = 0L, block_mode = block_mode, verbose = FALSE
)
stopifnot(sweep == 200L, fit$lambda_hold_until == 200L, all(lengths(states) > 0L))
saveRDS(list(states = states, sweeps = targets, warm_sigma = fit$sigma[1:200],
  warm_fallback = fit$warm_fallback[1:200], warm_unconverged = fit$warm_ipm_unconverged[1:200]),
  file.path(out, "warm_states.rds"))

# Add printing to a separate diagnostic copy. Its return must exactly match
# the production ADMM component. This copy never runs inside the sampler.
src <- readLines(file.path(pin, "method/individual/prox_admm_metric.cpp"))
at <- grep("if \\(std::sqrt\\(rp\\) <= tol .+rho \\* std::sqrt\\(rd\\)", src)
stopifnot(length(at) == 1L)
trace_cpp <- tempfile(fileext = ".cpp")
trace_line <- paste0('      Rprintf("admm %d %.17g %.17g %.17g %.17g %d\\n", it + 1, ',
  'std::sqrt(rp) / (std::sqrt(dn) + 1e-12), rho * std::sqrt(rd) / (bn + 1e-12), ',
  'std::sqrt(rp), std::sqrt(dn), (int)std::count_if(v.begin(), v.end(), [](double x) { return x != 0; }));')
writeLines(append(src, trace_line, after = at - 1L), trace_cpp)
instrument <- new.env()
Rcpp::sourceCpp(trace_cpp, env = instrument)

inspect <- function(i) {
  s <- states[[i]]
  admm_args <- with(s, list(x, a, r, lambda, gamma, a, 0, order, median(a), iters, warm_admm_tol))
  canonical <- do.call(prox_admm_metric_conv, admm_args)
  admm_log <- capture.output(traced <- do.call(instrument$prox_admm_metric_conv, admm_args))
  stopifnot(identical(canonical, traced))
  admm <- read.table(text = grep("^admm ", admm_log, value = TRUE),
    col.names = c("tag", "iteration", "primal_rel", "dual_rel", "primal_abs", "dtheta_norm", "split_nnz"))
  admm$tag <- NULL
  admm$sweep <- targets[i]
  admm$tolerance <- warm_admm_tol

  ctrl <- warm_ipm_ctrl
  ctrl[5L] <- 1
  ipm_log <- capture.output(ip <- with(s,
    prox_box_metric(x, a, r, lambda, gamma, a, 0, order, median(a), rep(0, length(x)),
      iters, 0, lower, upper, ctrl)))
  stopifnot(isTRUE(identical(ip$theta, s$result$theta)))
  ipm <- read.table(text = grep("^  ipm ", ipm_log, value = TRUE), fill = TRUE,
    col.names = c("tag", "iteration", "p", "primal", "d", "dual", "g", "gap", "o", "objective", "f", "phi"))
  ipm <- ipm[c("iteration", "primal", "dual", "gap", "objective", "phi")]
  ipm$iteration <- as.integer(sub(":$", "", ipm$iteration))
  ipm$sweep <- targets[i]
  g <- ip$diag
  reason <- if (g$converged == 1L) "tolerance met"
    else if (g$iters == ctrl[3L]) "iteration cap"
    else if (!is.finite(tail(ipm$phi, 1L))) "nonfinite merit"
    else "stall (no sufficient merit decrease)"
  qmin <- min(s$a * (1 + 1 / s$gamma))
  qnorm <- max(abs(s$a * (s$r + s$x / s$gamma)))
  thscale <- max(1, abs(s$x))
  summary <- with(s, data.frame(sweep = targets[i], sigma, a_min = min(a), a_median = median(a),
    a_max = max(a), a_condition = max(a) / min(a), r_min = min(r), r_max = max(r),
    lambda_effective = lambda, gamma, lambda_over_gamma = lambda / gamma,
    lambda_over_rho = lambda / median(a), gradient_scale = qnorm, bounds_finite = sum(is.finite(c(lower, upper))),
    admm_iterations = traced$iters, admm_primal_rel = tail(admm$primal_rel, 1L),
    admm_dual_rel = tail(admm$dual_rel, 1L), admm_converged = traced$converged,
    admm_primal_abs = tail(admm$primal_abs, 1L), admm_split_nnz = tail(admm$split_nnz, 1L),
    ipm_iterations = g$iters, ipm_converged = g$converged, ipm_stop = reason,
    ipm_primal = g$rp_D, ipm_dual = g$rd, ipm_gap = g$gap,
    ipm_primal_target = ctrl[4L] * (1 + thscale), ipm_dual_target = ctrl[4L] * qmin,
    ipm_gap_target = .5 * ctrl[4L]^2 * qmin,
    max_admm_ipm_theta_diff = max(abs(canonical$theta - ip$theta))))
  list(summary = summary, admm = admm, ipm = ipm)
}
results <- lapply(seq_along(states), inspect)
for (k in c("summary", "admm", "ipm"))
  write.csv(do.call(rbind, lapply(results, `[[`, k)), file.path(out, paste0("warm_", k, ".csv")), row.names = FALSE)
