# E-13a PHASE 2 screen (after the warm-start and z-draw fixes; see CHANGES.md): joint multi-quantile sampler, prior rate b0
# (VS, Normal, n = 500, data seed 1, order 2).  Phase-1 script: e13_run.R (kept as the record of that screen).
#   Joint: tau = (0.3, 0.5, 0.7, 0.9) jointly, b0 in {1e-5, 1e-4, 1e-3}, lambda move poly (old) | fixed (new spline ASIS),
#          chains 1001 / 1002  -> tasks 1-12.
#   Individual reference: the same b0 and move, chain 1001, each tau alone -> tasks 13-36.
#   Before/after reference (HQ test 3): the individual sampler at its script defaults, VS n500 tau 0.75 data seed 1, chains 1001-1004,
#          with the code BEFORE the fixes (commit 772a4a3, tree in $E13_BEFORE_ROOT) and AFTER -> tasks 37-44.
# Settings = the samplers' defaults: lambda ~ Gamma(1, b0), sigma ~ IG(0.1, 0.1), curvature metric (kappa 3), 30k sweeps / 10k burn-in,
#   200 warm sweeps, ASIS on.  Records, per run and level: the warm-start IPM fallbacks, unconverged IPM solves, sigma-guard firings.
# The joint wrapper of pmala_box_step (same arguments, same RNG calls) only records where a crash happens and saves its inputs.
#
# Usage:  Rscript e13b_run.R list                         print the task table
#         Rscript e13b_run.R task <id> [iter] [burn]      run one task (row number or id)
# env E13_ROOT (code tree holding method/), E13_OUT (default <E13_ROOT>/runs/E13b-joint-b0-fix-20261125), E13_BEFORE_ROOT (tasks 37-40).
suppressPackageStartupMessages(library(coda))
`%||%` <- function(a, b) if (is.null(a) || length(a) == 0) b else a
ROOT <- normalizePath(Sys.getenv("E13_ROOT", "."))
OUT  <- Sys.getenv("E13_OUT", file.path(ROOT, "runs", "E13b-joint-b0-fix-20261125"))
for (s in c("out", "crash", "logs")) dir.create(file.path(OUT, s), showWarnings = FALSE, recursive = TRUE)
TAUS <- c(0.3, 0.5, 0.7, 0.9); B0S <- c(1e-5, 1e-4, 1e-3); VARS <- c("poly", "fixed")

tasks <- function() {
  g <- list()
  for (b0 in B0S) for (v in VARS) for (ch in 1:2)
    g[[length(g) + 1L]] <- data.frame(kind = "joint", b0 = b0, variant = v, chain = ch, tau = NA_real_)
  for (b0 in B0S) for (v in VARS) for (tau in TAUS)
    g[[length(g) + 1L]] <- data.frame(kind = "ind", b0 = b0, variant = v, chain = 1L, tau = tau)
  for (ver in c("before", "after")) for (ch in 1:4)
    g[[length(g) + 1L]] <- data.frame(kind = paste0("ref_", ver), b0 = NA_real_, variant = NA_character_, chain = ch, tau = 0.75)
  tk <- do.call(rbind, g)
  tk$id <- ifelse(tk$kind == "joint", sprintf("joint_%s_b%g_c%d", tk$variant, tk$b0, tk$chain),
           ifelse(tk$kind == "ind", sprintf("ind_%s_b%g_t%02d", tk$variant, tk$b0, round(100 * tk$tau)),
                  sprintf("%s_t75_c%d", tk$kind, tk$chain)))
  tk
}
TK <- tasks()

# ---- joint run ------------------------------------------------------------------------------------------------------------
run_joint <- function(tk, iter, burn) {
  owd <- setwd(file.path(ROOT, "method", "joint")); L <- readLines("Joint_Sampler_PMALA_Augmented.R")
  eval(parse(text = L[seq_len(grep("^# ---- Main", L)[1] - 1L)]), envir = globalenv()); load_box_cpp(); setwd(owd)
  J <- length(TAUS); dat <- simulate_data(1, 500L, TAUS, "VS", "Normal")
  G <- globalenv()
  G$.e13 <- new.env(); E <- G$.e13
  E$calls <- 0L; E$J <- J; E$warm <- warm_sweeps
  E$crash_file <- file.path(OUT, "crash", paste0(tk$id, ".rds"))
  E$orig <- pmala_box_step
  G$pmala_box_step <- function(theta, y, z, lambda, sigma, delta, cst, order, lower, upper, ...) {
    E <- .e13; E$calls <- E$calls + 1L                                   # K = 1: one call per level per sweep after the warm start
    sw <- E$warm + (E$calls - 1L) %/% E$J + 1L; lv <- (E$calls - 1L) %% E$J + 1L
    E$sweep <- sw; E$level <- lv
    tryCatch(E$orig(theta, y, z, lambda, sigma, delta, cst, order, lower, upper, ...),
             error = function(e) {
               saveRDS(list(msg = conditionMessage(e), sweep = sw, level = lv, theta = theta, y = y, z = z, lambda = lambda,
                            sigma = sigma, delta = delta, cst = cst, order = order, lower = lower, upper = upper, extra = list(...)),
                       E$crash_file)
               stop(e) })
  }
  set.seed(1000 + tk$chain)
  t0 <- proc.time()[["elapsed"]]
  fit <- tryCatch(gibbs_joint_pmala(dat$y, TAUS, 2L, 1, tk$b0, 0.1, 0.1, iter, burn, delta_init, NULL, adapt_target, adapt_gain,
                                    adapt_kappa, delta_bounds, metric = "curv", c_fixed = 0, rho = NULL, iters = admm_iter, mh = TRUE,
                                    adapt = TRUE, warm = warm_sweeps, gamma_warm = gamma_warm, kappa = kappa_metric, adapt_all = TRUE,
                                    K = 1L, asis = TRUE, tol = 0, zeta_scale = zeta_scale, ctrl = box_ctrl, asis_q = tk$variant,
                                    verbose = TRUE),
                  error = function(e) e)
  mins <- (proc.time()[["elapsed"]] - t0) / 60
  if (inherits(fit, "error")) {
    res <- list(task = tk, crashed = TRUE, msg = conditionMessage(fit), crash_sweep = E$sweep %||% NA, crash_level = E$level %||% NA,
                crash_file = if (file.exists(E$crash_file)) E$crash_file else NA, minutes = mins, truth = dat$truth)
    cat(sprintf("%s | CRASH at sweep %s level %s | %.1f min | %s\n", tk$id, res$crash_sweep, res$crash_level, mins, res$msg))
    return(res)
  }
  post <- (burn + 1):iter; TH <- fit$theta
  est <- apply(TH, c(2, 3), mean); lo <- apply(TH, c(2, 3), quantile, .025); hi <- apply(TH, c(2, 3), quantile, .975)
  cm <- crossing_metrics(est, TH)
  draws_any_cross <- mean(apply(TH, 1, function(M) any(diff(t(M)) < 0)))          # any adjacent-level crossing anywhere in a draw
  ess_th <- apply(TH, c(2, 3), function(v) as.numeric(effectiveSize(v)))
  thin <- seq(1, dim(TH)[1], by = 20)
  res <- list(task = tk, crashed = FALSE, minutes = mins, q_grid = fit$asis_q_grid, truth = dat$truth, y = dat$y,
              est = est, lo = lo, hi = hi, mse = colMeans((est - dat$truth)^2), coverage = colMeans(dat$truth >= lo & dat$truth <= hi),
              width = colMeans(hi - lo), sigma0 = fit$sigma0, warm_fallback = colSums(fit$warm_fallback),
              warm_ipm_unconverged = colSums(fit$warm_ipm_unconverged), guard_n = colSums(fit$sigma_guard),
              guard_sweeps = lapply(seq_len(J), function(j) which(fit$sigma_guard[, j] == 1L)),
              crossings_post_total = sum(vapply(seq_len(dim(TH)[1]), function(s) sum(diff(t(TH[s, , ])) < 0), 0)),   # (draw, point, pair) instances
              lambda = fit$lambda, sigma = fit$sigma, delta = fit$delta, acc = fit$acc, outside = fit$outside,
              acc_post = fit$acc_post, outside_post = fit$outside_post, asis_moved_post = fit$asis_moved_post, ipm_post = fit$ipm_post,
              delta_final = fit$delta_final,
              lambda_mean = colMeans(fit$lambda[post, , drop = FALSE]), sigma_mean = colMeans(fit$sigma[post, , drop = FALSE]),
              lambda_ess = apply(fit$lambda[post, , drop = FALSE], 2, function(v) as.numeric(effectiveSize(v))),
              theta_ess_median = apply(ess_th, 2, median), theta_ess_min = apply(ess_th, 2, min),
              crossing = cm, draws_any_cross = draws_any_cross, theta_thin = TH[thin, , , drop = FALSE])
  cat(sprintf("%s | warm IPM fallbacks %s | IPM unconverged %s | sigma guard %s\n", tk$id, paste(res$warm_fallback, collapse = "/"),
              paste(res$warm_ipm_unconverged, collapse = "/"), paste(res$guard_n, collapse = "/")))
  cat(sprintf("%s | %.1f min | lambda %s | sigma %s | acc %s | MSE %s | any-cross draws %.4f\n", tk$id, mins,
              paste(sprintf("%.3g", res$lambda_mean), collapse = "/"), paste(sprintf("%.3g", res$sigma_mean), collapse = "/"),
              paste(sprintf("%.2f", res$acc_post), collapse = "/"), paste(sprintf("%.5f", res$mse), collapse = "/"), draws_any_cross))
  res
}

# ---- individual run -------------------------------------------------------------------------------------------------------
run_ind <- function(tk, iter, burn) {
  root <- if (tk$kind == "ref_before") normalizePath(Sys.getenv("E13_BEFORE_ROOT")) else ROOT
  code <- file.path(root, "method", "individual"); lines <- readLines(file.path(code, "Individual_Sampler_PMALA_Augmented.R"))
  owd <- setwd(code); eval(parse(text = lines[seq_len(grep("^# ---- Main", lines)[1] - 1L)]), envir = globalenv()); setwd(owd)
  load_prox_cpp(file.path(code, "prox_admm_metric.cpp"))
  dat <- simulate_data(1, 500L, tk$tau, "VS", "Normal")
  set.seed(1000 + tk$chain)
  if (tk$kind != "ind") { tk$b0 <- b0; tk$variant <- asis_q }             # before/after reference: the script's own defaults
  # the individual script's Main call with its defaults (block move off, no lambda jump, prior_scale "none")
  fit <- tryCatch(gibbs_pmala_aug(dat$y, tk$tau, 2L, 1, tk$b0, 0.1, 0.1, iter, burn, delta_init, lambda_init, adapt_target, adapt_gain,
                                  adapt_kappa, delta_bounds, tf_control, metric = metric, c_fixed = c_metric, rho = admm_rho, iters = admm_iter,
                                  mh = mh_correct, adapt = adapt_delta, init = theta_init, warm = warm_sweeps, gamma_warm = gamma_warm,
                                  K = K_theta, asis = TRUE, tol = admm_tol, lamjump = lamjump, lamjump_s = lamjump_s, prior_scale = prior_scale,
                                  cmap = FALSE, kappa = kappa_metric, adapt_all = adapt_all, asis_q = tk$variant, block = block_theta,
                                  block_mode = block_mode, verbose = FALSE),
                  error = function(e) e)
  if (inherits(fit, "error")) { cat(tk$id, "| CRASH |", conditionMessage(fit), "\n"); return(list(task = tk, crashed = TRUE, msg = conditionMessage(fit))) }
  post <- (burn + 1):iter; TH <- fit$theta; est <- colMeans(TH)
  lo <- apply(TH, 2, quantile, .025); hi <- apply(TH, 2, quantile, .975)
  res <- list(task = tk, crashed = FALSE, minutes = fit$seconds / 60, est = est, lo = lo, hi = hi, truth = dat$truth, mse = mean((est - dat$truth)^2),
              coverage = mean(dat$truth >= lo & dat$truth <= hi), width = mean(hi - lo),
              lambda = fit$lambda, sigma = fit$sigma, lambda_mean = mean(fit$lambda[post]), sigma_mean = mean(fit$sigma[post]),
              lambda_ess = as.numeric(effectiveSize(fit$lambda[post])), sigma_ess = as.numeric(effectiveSize(fit$sigma[post])),
              acc_post = fit$acc_post, delta_final = fit$delta_final, sigma0 = fit$sigma0 %||% NA,
              warm_fallback = sum(fit$warm_fallback %||% NA), warm_ipm_unconverged = sum(fit$warm_ipm_unconverged %||% NA),
              guard_n = sum(fit$sigma_guard %||% NA), guard_sweeps = if (is.null(fit$sigma_guard)) NA else which(fit$sigma_guard == 1L))
  cat(sprintf("%s | %.1f min | lambda %.3g | sigma %.3g | acc %.2f | MSE %.5f | cover %.3f | width %.4f | warm IPM %s | guard %s\n", tk$id,
              res$minutes, res$lambda_mean, res$sigma_mean, res$acc_post, res$mse, res$coverage, res$width, res$warm_fallback, res$guard_n))
  res
}

run_task <- function(tk, iter, burn) {
  f <- file.path(OUT, "out", paste0(tk$id, if (iter != 30000L) sprintf("_it%d", iter) else "", ".rds"))
  if (file.exists(f)) { cat("exists:", f, "\n"); return(invisible()) }
  res <- if (tk$kind == "joint") run_joint(tk, iter, burn) else run_ind(tk, iter, burn)
  res$iter <- iter; res$burn <- burn; res$host <- Sys.info()[["nodename"]]; res$finished <- format(Sys.time())
  saveRDS(res, paste0(f, ".tmp")); file.rename(paste0(f, ".tmp"), f)
}

args <- commandArgs(trailingOnly = TRUE)
mode <- args[1]
if (identical(mode, "list")) { print(TK); quit(save = "no") }
if (identical(mode, "task")) {
  id <- args[2]; tk <- if (grepl("^[0-9]+$", id)) TK[as.integer(id), ] else TK[TK$id == id, ]
  stopifnot(nrow(tk) == 1)
  iter <- as.integer(args[3] %||% NA); burn <- as.integer(args[4] %||% NA)
  if (is.na(iter)) iter <- 30000L
  if (is.na(burn)) burn <- 10000L
  cat(sprintf("[%s] task %s | iter %d burn %d | host %s\n", format(Sys.time()), tk$id, iter, burn, Sys.info()[["nodename"]]))
  run_task(tk, iter, burn)
}
