# E-13a Phase 1 diagnosis: short traced runs of the JOINT sampler (VS, Normal, n = 500, data seed 1, order 2, chain seed 1001).
# Nothing in method/ is changed.  The script loads the joint sampler, then replaces pmala_box_step by a recording copy (same code,
# same RNG calls, so the chain is identical) and wraps asis_box_step (records only).  Optional overrides are DIAGNOSTIC ONLY
# (they change the sampler and are never used in the screen): E13_CAP (cap on the metric weight c), E13_ASIS=0 (no lambda ASIS move).
# Usage: Rscript e13_diag.R <tag> <variant poly|fixed> <b0> <iters> [taus, default 0.3,0.5,0.7,0.9]
# Writes runs/E13-joint-b0-20261125/diag/<tag>.rds (fit traces + per-call records).
args <- commandArgs(trailingOnly = TRUE)
tag <- args[1]; variant <- args[2]; b0 <- as.numeric(args[3]); iters <- as.integer(args[4])
TAUS <- if (length(args) >= 5) as.numeric(strsplit(args[5], ",")[[1]]) else c(0.3, 0.5, 0.7, 0.9)
ROOT <- normalizePath("."); OUT <- Sys.getenv("E13_OUT", file.path(ROOT, "runs", "E13-joint-b0-20261125"))
dir.create(file.path(OUT, "diag"), showWarnings = FALSE, recursive = TRUE)
owd <- setwd(file.path(ROOT, "method", "joint")); L <- readLines("Joint_Sampler_PMALA_Augmented.R")
eval(parse(text = L[seq_len(grep("^# ---- Main", L)[1] - 1L)]), envir = globalenv()); load_box_cpp(); setwd(owd)
CAP <- as.numeric(Sys.getenv("E13_CAP", "1e8")); ASIS <- Sys.getenv("E13_ASIS", "1") == "1"
if (CAP != 1e8) metric_dc <- function(metric, a, lambda, c_fixed, kappa = 1) list(d = a, c = min(kappa * lambda^2 / 2, CAP))
J <- length(TAUS); dat <- simulate_data(1, 500L, TAUS, "VS", "Normal"); n <- length(dat$y)
R <- new.env(); R$rec <- list(); R$calls <- 0L; R$asis <- list(); R$acalls <- 0L
pmala_box_step <- function(theta, y, z, lambda, sigma, delta, cst, order, lower, upper, metric = "curv", c_fixed = 0,
                           rho = NULL, iters = 200L, mh = TRUE, kappa = 1, tol = 0, zeta_scale = 1, ctrl = box_ctrl) {
  R$calls <- R$calls + 1L; sw <- warm_sweeps + (R$calls - 1L) %/% J + 1L; lv <- (R$calls - 1L) %% J + 1L
  gamma <- delta / 2
  a <- 1 / (cst$t2 * sigma * z); r <- y - cst$psi * z
  M <- metric_dc(metric, a, lambda, c_fixed, kappa); d <- M$d; c <- M$c
  pen <- box_penalties(a, d, c, gamma, rho, zeta_scale)
  base <- list(sweep = sw, level = lv, lambda = lambda, sigma = sigma, delta = delta, c = c, c_raw = kappa * lambda^2 / 2,
               a_min = min(a), a_med = median(a), z_med = median(z), z_cap = sum(z >= 1e4),
               at_lo = sum(theta <= lower + 1e-10), at_up = sum(theta >= upper - 1e-10),
               gap_lo_med = median(theta - lower), gap_up_med = median(upper - theta),
               resid_med = median(abs(y - theta)), SD = sum(abs(Dtheta(theta, order))))
  mv <- tryCatch(pmala_box_move(theta, a, r, lambda, gamma, d, c, order, pen$rho, pen$zeta, iters, tol, rnorm(length(theta)), delta, lower, upper, ctrl),
                 error = function(e) { R$rec[[R$calls]] <- c(base, crash = TRUE)
                   saveRDS(list(msg = conditionMessage(e), base = base, theta = theta, y = y, z = z, lambda = lambda, sigma = sigma, delta = delta,
                                cst = cst, order = order, lower = lower, upper = upper, extra = list(kappa = kappa)),
                           file.path(OUT, "diag", paste0(tag, "_crash.rds"))); stop(e) })
  base$p_move <- max(abs(mv$p - theta)); base$p_at_bd <- sum(mv$p <= lower + 1e-10 | mv$p >= upper - 1e-10)
  if (mv$outside) { R$rec[[R$calls]] <- c(base, outside = TRUE, dU = NA, dq = NA, log_alpha = -Inf, acc = FALSE)
    return(list(theta = theta, accept = FALSE, log_alpha = -Inf, outside = TRUE, ipm = mv$diag_fwd$outer)) }
  prop <- mv$prop
  dU <- U_cond(theta, a, r, lambda, order) - U_cond(prop, a, r, lambda, order); dq <- (mv$q_fwd - mv$q_rev) / (2 * delta)
  dU_data <- (sum(a * (theta - r)^2) - sum(a * (prop - r)^2)) / 2; dU_pen <- dU - dU_data
  log_alpha <- dU + dq
  if (!is.finite(log_alpha)) log_alpha <- -Inf
  accept <- log(runif(1)) < log_alpha
  R$rec[[R$calls]] <- c(base, outside = FALSE, dU = dU, dU_data = dU_data, dU_pen = dU_pen, dq = dq, log_alpha = log_alpha, acc = accept,
                        rev_move = max(abs(mv$pstar - prop)))
  list(theta = if (accept) prop else theta, accept = accept, log_alpha = min(0, log_alpha), outside = FALSE,
       ipm = max(mv$diag_fwd$outer, mv$diag_rev$outer))
}
asis_orig <- asis_box_step
asis_box_step <- function(theta, lambda, a, r, a0, b0, P, order, lower, upper, ...) {
  out <- asis_orig(theta, lambda, a, r, a0, b0, P, order, lower, upper, ...)
  R$acalls <- R$acalls + 1L
  R$asis[[R$acalls]] <- c(lam_in = lambda, lam_out = out$lambda, moved = out$moved, q = attr(P, "q"))
  out
}
set.seed(1001)
t0 <- proc.time()[["elapsed"]]
fit <- tryCatch(gibbs_joint_pmala(dat$y, TAUS, 2L, 1, b0, 0.1, 0.1, iters, max(warm_sweeps, iters - 1L), delta_init, NULL, adapt_target,
                                  adapt_gain, adapt_kappa, delta_bounds, metric = "curv", c_fixed = 0, rho = NULL, iters = admm_iter, mh = TRUE,
                                  adapt = TRUE, warm = warm_sweeps, gamma_warm = gamma_warm, kappa = kappa_metric, adapt_all = TRUE, K = 1L,
                                  asis = ASIS, tol = 0, zeta_scale = zeta_scale, ctrl = box_ctrl, asis_q = variant, verbose = TRUE),
                error = function(e) e)
nm <- unique(unlist(lapply(R$rec, names)))
rec <- do.call(rbind, lapply(R$rec, function(x) { x <- x[nm]; names(x) <- nm; as.data.frame(lapply(x, function(v) if (is.null(v)) NA else v)) }))
asis <- if (length(R$asis)) as.data.frame(do.call(rbind, R$asis)) else NULL
saveRDS(list(tag = tag, variant = variant, b0 = b0, taus = TAUS, cap = CAP, asis_on = ASIS, fit = if (inherits(fit, "error")) NULL else fit[setdiff(names(fit), "theta")],
             final_theta = if (inherits(fit, "error")) NULL else fit$final$theta, error = if (inherits(fit, "error")) conditionMessage(fit) else NULL,
             rec = rec, asis = asis, y = dat$y, truth = dat$truth, seconds = proc.time()[["elapsed"]] - t0),
        file.path(OUT, "diag", paste0(tag, ".rds")))
cat("done", tag, if (inherits(fit, "error")) conditionMessage(fit) else "", "\n")
