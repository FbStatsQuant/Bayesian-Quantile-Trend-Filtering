## ===========================================================================
##  Quantile trend filtering by ADMM (Brantley, Guinness & Chi, 2020, AOAS)
##  Single-dataset driver -- individual quantile
## ---------------------------------------------------------------------------
##  Solves    minimise_theta  sum_i rho_tau(y_i - theta_i) + lambda ||D^(k+1) theta||_1
##  on the same simulation designs as Individual_Sampler_Scale.R and
##  Onizuka_BQTF_Individual.R, with lambda chosen by the paper's criteria
##  (eBIC / SIC / validation) or fixed by hand, and reports
##
##     * MSE / MAD of the estimate against the true conditional quantile
##       Q_true (the tau-quantile of y | x),
##     * the lambda path table (criterion, df, objective, convergence),
##     * one plot: data, true quantile, estimated quantile,
##       and one plot of the selection criterion over the lambda grid.
##
##  Solvers (menu item `solver`), all for the SAME objective above:
##
##    "admm_windows"  Brantley et al. Algorithm 1: overlapping windows,
##                    window QPs, consensus averaging, dual ascent.  This is
##                    detrendr::get_trend_windows() re-implemented in R with a
##                    pluggable QP backend (piqp, gurobi or quadprog) and the
##                    detrendr stopping rule (eps_abs / eps_rel).  With one
##                    window it is just the LP below.
##    "admm_tf"       Two-block ADMM on the full series, r = y - theta:
##                    r-update = prox of the check loss (detrendr::prox_quantile),
##                    theta-update = Gaussian trend-filter prox, i.e.
##                    glmgen::trendfilter(v, k = order, lambda / rho) -- the same
##                    prox as in Individual_Sampler_Scale.R (exact QP fallback
##                    when glmgen is absent).  Over-relaxed, warm-started.
##    "admm_prox"     Three-way split:  r = y - theta, z = D theta; r-update =
##                    prox_quantile, z-update = soft threshold (detrendr::prox_f2),
##                    theta-update = one banded Cholesky solve of (I + D'D).
##                    Pure R + Matrix.  NOTE: for k = 2 the D'D conditioning
##                    makes this converge slowly at large lambda (thousands of
##                    iterations); it is kept for experimentation, and the path
##                    table reports convergence per lambda.
##    "spingarn"      detrendr::get_trend_spingarn(): Spingarn's method of
##                    partial inverses with the same prox operators and
##                    projection onto {eta = D theta}.  Pure R port of the
##                    package's C++ (spingarn.cpp / prox.cpp).
##    "lp"            The exact linear programme of eq. (1) in the detrendr
##                    formulation (get_model / solve_model): variables
##                    u+, u-, eta+, eta- with D(u+ - u-) + (eta+ - eta-) = D y.
##                    Backend: piqp, gurobi, Rglpk or lpSolve (auto-detected
##                    in that order, as detrendr does).  Reference solution.
##
##  Reference for the port: github.com/halleybrantley/detrendr (master):
##  R/get_model.R, R/solve_functions.R, R/get_trend_BIC.R, R/get_criteria.R,
##  R/get_trend_windows.R, R/update_windows.R, R/get_trend_spingarn.R,
##  src/prox.cpp, src/spingarn.cpp, src/getDk.cpp.
##
##  Conventions.  `order` is the paper's k (0, 1, 2 = piecewise constant,
##  linear, quadratic); the penalty uses D^(k+1).  detrendr's `k` argument is
##  the number of differences, i.e. detrendr k = order + 1 (the paper's k = 2
##  runs are detrendr's k = 3).
##
##  How to run: open in RStudio with the working directory anywhere at or
##  below "~/Quantile Regression", select all, Run.  No setwd().
## ===========================================================================


## ======================= USER SETTINGS (menu) ==============================

baseline <- "VS"        # "PC" | "VS" | "S"   (or 1 | 2 | 3)
noise    <- "Normal"    # "Normal" | "Beta" | "Mixed"
tau      <- 0.05        # quantile level in (0, 1)
order    <- 2           # paper's k: 0, 1, 2 ;  NA = baseline default (PC 0, VS 1, S 2)

n_data   <- 500
seed     <- 100

solver   <- "lp"            # "lp" | "admm_windows" | "admm_tf" | "admm_prox" | "spingarn"
                            #   lp           exact LP (reference; what the paper solves per window)
                            #   admm_windows Brantley Algorithm 1 (consensus ADMM over windows)
                            #   admm_tf      two-block ADMM, theta-step = trend-filter prox (glmgen)
                            #   admm_prox    three-way split with closed-form proxes (slow for k = 2)
                            #   spingarn     detrendr::get_trend_spingarn port (slow for k = 2)

## --- lambda selection -----------------------------------------------------
lambda_rule <- "eBIC"       # "eBIC" | "SIC" | "valid" | "fixed"
lambda_grid <- exp(seq(-4, 8, length.out = 25))   # grid used by the NOTS campaign
lambda_fixed <- 10          # used only when lambda_rule == "fixed"
ebic_gamma   <- 1           # eBIC gamma (paper: 1)
df_tol       <- 1e-4        # |D theta| > df_tol counts as an active knot
                            # (detrendr default 1e-9 is for exact LP solutions)
valid_every  <- 5           # "valid": hold out every 5th observation (paper)

## --- ADMM controls (admm_tf / admm_prox / admm_windows / spingarn) --------
admm_rho      <- 1          # augmented-Lagrangian parameter (detrendr: rho = 1..5)
admm_rho_x_lambda <- TRUE   # admm_prox only: use rho = admm_rho * lambda (keeps the
                            #   soft-threshold lambda/rho at unit scale along the path)
admm_relax    <- 1.6        # admm_tf over-relaxation alpha in [1, 1.8]
admm_max_iter <- 5000       # admm_tf / admm_prox / spingarn iteration cap per lambda
admm_eps_abs  <- 1e-5       # Boyd et al. stopping rule, absolute part
admm_eps_rel  <- 1e-4       # Boyd et al. stopping rule, relative part
admm_warm     <- TRUE       # warm start along the lambda path

window_size   <- 200        # admm_windows: window length (>= n gives 1 window)
overlap       <- 50         # admm_windows: overlap between windows
win_max_iter  <- 50         # admm_windows: outer consensus iterations per lambda
win_eps_abs   <- 1e-3       # admm_windows: detrendr uses 0.05 (coarse); tighter here
win_eps_rel   <- 1e-4

## --- backends ---------------------------------------------------------------
lp_backend <- "auto"        # "auto" | "piqp" | "gurobi" | "Rglpk" | "lpSolve"
qp_backend <- "auto"        # "auto" | "piqp" | "gurobi" | "quadprog"
qp_tol     <- 1e-8          # piqp tolerance

## --- output -----------------------------------------------------------------
compare_with_lp    <- TRUE  # also solve the exact LP at the selected lambda
show_plots         <- TRUE
use_windows_device <- FALSE
save_outputs       <- TRUE  # png / csv / rds into results_admm_qtf/ beside script
verbose            <- TRUE  # one line per lambda on the path

## ===========================================================================
##  Nothing below needs editing for a routine run.
## ===========================================================================

suppressPackageStartupMessages({
  library(Matrix)
  library(ggplot2)
  library(tibble)
})


## ---------------------------------------------------------------------------
##  0. Locate this script's folder (for outputs)
## ---------------------------------------------------------------------------

.norm <- function(p) {
  if (is.null(p) || length(p) != 1L || is.na(p) || !nzchar(p)) return(NA_character_)
  tryCatch(normalizePath(p, winslash = "/", mustWork = FALSE), error = function(e) NA_character_)
}
.script_path <- function() {
  a <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
  if (length(a)) {
    p <- .norm(sub("^--file=", "", a[[1L]]))
    if (!is.na(p) && file.exists(p)) return(p)
  }
  if (requireNamespace("rstudioapi", quietly = TRUE) &&
      isTRUE(tryCatch(rstudioapi::isAvailable(), error = function(e) FALSE))) {
    p <- .norm(tryCatch(rstudioapi::getActiveDocumentContext()$path, error = function(e) NA_character_))
    if (!is.na(p) && file.exists(p)) return(p)
  }
  NA_character_
}
script_path <- .script_path()
script_dir <- if (!is.na(script_path)) dirname(script_path) else {
  cand <- c(.norm("~/Quantile Regression/method/admm_qtf"), .norm("~/OneDrive/Documents/Quantile Regression/method/admm_qtf"),
            .norm(file.path(getwd(), "method", "admm_qtf")), .norm(getwd()))
  cand[dir.exists(cand)][[1L]]
}
out_dir <- file.path(script_dir, "results_admm_qtf")
if (save_outputs) dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)


## ---------------------------------------------------------------------------
##  1. Resolve and validate settings
## ---------------------------------------------------------------------------

baseline_key <- if (is.numeric(baseline)) c("PC", "VS", "S")[as.integer(baseline)] else toupper(as.character(baseline))
if (is.na(baseline_key) || !baseline_key %in% c("PC", "VS", "S")) stop("baseline must be 'PC', 'VS' or 'S'.")
noise       <- match.arg(as.character(noise), c("Normal", "Beta", "Mixed"))
solver      <- match.arg(as.character(solver), c("lp", "admm_windows", "admm_tf", "admm_prox", "spingarn"))
lambda_rule <- match.arg(as.character(lambda_rule), c("eBIC", "SIC", "valid", "fixed"))
lp_backend  <- match.arg(as.character(lp_backend), c("auto", "piqp", "gurobi", "Rglpk", "lpSolve"))
qp_backend  <- match.arg(as.character(qp_backend), c("auto", "piqp", "gurobi", "quadprog"))

default_order <- c(PC = 0L, VS = 1L, S = 2L)[[baseline_key]]
if (length(order) != 1L || is.na(order)) order <- default_order
order <- as.integer(order)
stopifnot(order %in% 0:2, tau > 0, tau < 1, n_data > order + 3L,
          all(lambda_grid > 0), lambda_fixed > 0, admm_rho > 0)

.has <- function(pkg) requireNamespace(pkg, quietly = TRUE)
if (lp_backend == "auto") {
  lp_backend <- c("piqp", "gurobi", "Rglpk", "lpSolve")[c(.has("piqp"), .has("gurobi"), .has("Rglpk"), .has("lpSolve"))][1L]
  if (is.na(lp_backend)) lp_backend <- "none"
} else if (!.has(lp_backend)) stop("LP backend '", lp_backend, "' is not installed.")
if (qp_backend == "auto") {
  qp_backend <- c("piqp", "gurobi", "quadprog")[c(.has("piqp"), .has("gurobi"), .has("quadprog"))][1L]
  if (is.na(qp_backend)) qp_backend <- "none"
} else if (!.has(qp_backend)) stop("QP backend '", qp_backend, "' is not installed.")

if (solver == "lp" && lp_backend == "none")
  stop("solver = 'lp' needs one of piqp, gurobi, Rglpk, lpSolve.")
if (solver == "admm_windows" && (lp_backend == "none" || qp_backend == "none"))
  stop("solver = 'admm_windows' needs an LP backend (window initialisation) and a QP backend (piqp, gurobi or quadprog).")
if (solver == "admm_tf" && !.has("glmgen") && qp_backend == "none")
  stop("solver = 'admm_tf' needs glmgen (preferred) or a QP backend (piqp / quadprog) for the theta-step.")
if (compare_with_lp && lp_backend == "none") {
  message("Note: no LP backend installed; compare_with_lp disabled.")
  compare_with_lp <- FALSE
}


## ---------------------------------------------------------------------------
##  2. Simulate one dataset (identical generative code to the other drivers)
## ---------------------------------------------------------------------------

x_idx <- seq_len(n_data)
xs    <- x_idx / n_data

if (baseline_key == "PC") {
  m1 <- n_data / 100
  baseline_curve <- 2.5 * (x_idx >= 1 & x_idx <= m1 * 20) + 1.0 * (x_idx >= m1 * 20 + 1 & x_idx <= m1 * 40) +
                    3.5 * (x_idx >= m1 * 40 + 1 & x_idx <= m1 * 60) + 1.5 * (x_idx >= m1 * 60 + 1 & x_idx <= m1 * 100)
} else if (baseline_key == "VS") {
  baseline_curve <- 2 + sin(4 * xs - 2) + 2 * exp(-30 * (4 * xs - 2)^2)
} else {
  baseline_curve <- sin(2 * pi * x_idx / n_data)
}

set.seed(seed)
if (noise == "Mixed") {
  y <- baseline_curve + sapply(xs, function(xi) if (runif(1) < xi) rnorm(1, -0.2, sqrt(0.5)) else rnorm(1, 0.2, sqrt(0.5)))
  Q_true <- baseline_curve + sapply(xs, function(xi) {
    cdf <- function(t) xi * pnorm(t, -0.2, sqrt(0.5)) + (1 - xi) * pnorm(t, 0.2, sqrt(0.5))
    uniroot(function(t) cdf(t) - tau, interval = c(-10, 10))$root
  })
} else if (noise == "Beta") {
  y      <- baseline_curve + sapply(xs, function(xi) rbeta(1, 1, 11 - 10 * xi))
  Q_true <- baseline_curve + sapply(xs, function(xi) qbeta(tau, 1, 11 - 10 * xi))
} else {
  sd_noise <- (1 + xs^2) / 4
  y        <- baseline_curve + rnorm(n_data, 0, sd_noise)
  Q_true   <- baseline_curve + qnorm(tau) * sd_noise
}


## ---------------------------------------------------------------------------
##  3. Building blocks shared by all solvers
## ---------------------------------------------------------------------------

## D^(d), d = order + 1  (detrendr::get_Dk(n, k) with k = d)
diff_matrix <- function(n, d) {
  m <- n - d
  stopifnot(m > 0)
  Matrix::sparseMatrix(i = rep(seq_len(m), d + 1L),
                       j = unlist(lapply(0:d, function(j) seq_len(m) + j)),
                       x = rep((-1)^(d:0) * choose(d, 0:d), each = m), dims = c(m, n))
}

check_loss <- function(r, tau) sum(r * (tau - (r < 0)))

## detrendr::prox_quantile(w, tau, alpha): prox of alpha * rho_tau
prox_quantile <- function(w, tau, alpha) {
  hi <- tau * alpha; lo <- -(1 - tau) * alpha
  out <- numeric(length(w))
  a <- w > hi; b <- w < lo
  out[a] <- w[a] - hi
  out[b] <- w[b] - lo
  out
}
## detrendr::prox_f2(eta, lambda, step): soft threshold at step * lambda
soft_threshold <- function(v, t) sign(v) * pmax(abs(v) - t, 0)

objective_value <- function(theta, y, tau, lambda, D, w = NULL) {
  r <- y - theta
  if (!is.null(w)) r <- r[w > 0]
  check_loss(r, tau) + lambda * sum(abs(as.numeric(D %*% theta)))
}


## ---------------------------------------------------------------------------
##  4a. Exact LP  (detrendr::get_model / solve_model formulation)
## ---------------------------------------------------------------------------
##  variables x = (u+, u-, eta+, eta-), phi = u+ - u- = y - theta, eta = D theta
##  minimise  tau 1'u+ + (1-tau) 1'u- + lambda 1'(eta+ + eta-)
##  s.t.      D u+ - D u- + eta+ - eta- = D y,  x >= 0.
##  Held-out (validation) observations get zero loss weight, as in detrendr
##  (obj0[missInd] <- 0), which is Brantley's modified check loss (8).

lp_build <- function(y, tau, D, w) {
  n <- length(y); m <- nrow(D)
  A <- cbind(D, -D, Matrix::Diagonal(m), -Matrix::Diagonal(m))
  list(n = n, m = m, A = A, rhs = as.numeric(D %*% y),
       cost0 = c(tau * w, (1 - tau) * w), y = y)
}

lp_solve_backend <- function(bld, lambda, backend, tol = qp_tol) {
  n <- bld$n; m <- bld$m
  cost <- c(bld$cost0, rep(lambda, 2 * m))
  x <- switch(backend,
    piqp = {
      N <- length(cost)
      mdl <- piqp::piqp(P = Matrix::Diagonal(N, 0), c = cost, A = bld$A, b = bld$rhs,
                        G = -Matrix::Diagonal(N), h_u = rep(0, N),
                        settings = list(verbose = FALSE, eps_abs = tol, eps_rel = tol,
                                        eps_duality_gap_abs = tol, eps_duality_gap_rel = tol,
                                        max_iter = 20000L), backend = "sparse")
      fit <- solve(mdl)
      if (!identical(fit$info$status_desc, "solved")) stop("piqp LP: ", fit$info$status_desc)
      fit$x
    },
    gurobi = {
      res <- gurobi::gurobi(list(obj = cost, A = bld$A, rhs = bld$rhs, sense = rep("=", m),
                                 modelsense = "min", lb = rep(0, length(cost))), list(OutputFlag = 0))
      if (is.null(res$x)) stop("gurobi LP status: ", res$status)
      res$x
    },
    Rglpk = Rglpk::Rglpk_solve_LP(obj = cost, mat = bld$A, dir = rep("==", m), rhs = bld$rhs)$solution,
    lpSolve = {
      res <- lpSolve::lp(objective.in = cost, const.mat = as.matrix(bld$A),
                         const.dir = rep("=", m), const.rhs = bld$rhs)
      if (res$status != 0) stop("lpSolve status ", res$status)
      res$solution
    },
    stop("unknown LP backend"))
  phi <- x[seq_len(n)] - x[n + seq_len(n)]
  list(theta = bld$y - phi, z = NULL, converged = TRUE, iterations = 1L,
       primal_residual = NA_real_, dual_residual = NA_real_)
}

fit_lp_path <- function(y, tau, D, w, lambdas, backend) {
  bld <- lp_build(y, tau, D, w)
  lapply(lambdas, function(l) lp_solve_backend(bld, l, backend))
}


## ---------------------------------------------------------------------------
##  4b. Splitting ADMM with prox operators  (full series)
## ---------------------------------------------------------------------------
##  minimise sum w_i rho_tau(r_i) + lambda ||z||_1   s.t. r = y - theta, z = D theta
##  scaled form, penalty rho:
##    theta <- (I + D'D)^{-1} [ (y - r + u_r) + D'(z - u_z) ]     (banded Cholesky)
##    r     <- prox_{(w/rho) rho_tau}(y - theta + u_r)           (prox_quantile)
##    z     <- soft(D theta + u_z, lambda / rho)                 (prox_f2)
##    u_r  += y - theta - r ;  u_z += D theta - z
##  Stopping: Boyd et al. (2011) Sec. 3.3 with eps_abs / eps_rel.

admm_prox_solve <- function(y, tau, lambda, D, w, rho, max_iter, eps_abs, eps_rel,
                            chol_M = NULL, state = NULL) {
  n <- length(y); m <- nrow(D)
  if (is.null(chol_M)) chol_M <- Matrix::Cholesky(Matrix::Diagonal(n) + Matrix::crossprod(D), LDL = FALSE, perm = FALSE)
  if (is.null(state)) {
    theta <- y; r <- numeric(n); z <- as.numeric(D %*% theta); u_r <- numeric(n); u_z <- numeric(m)
  } else { theta <- state$theta; r <- state$r; z <- state$z; u_r <- state$u_r; u_z <- state$u_z }
  fit_w <- w > 0
  converged <- FALSE; pri <- dua <- NA_real_
  for (it in seq_len(max_iter)) {
    r_old <- r; z_old <- z
    rhs   <- (y - r + u_r) + as.numeric(Matrix::crossprod(D, z - u_z))
    theta <- as.numeric(Matrix::solve(chol_M, rhs))
    Dth   <- as.numeric(D %*% theta)
    v     <- y - theta + u_r
    r     <- v
    r[fit_w] <- prox_quantile(v[fit_w], tau, w[fit_w] / rho)
    z     <- soft_threshold(Dth + u_z, lambda / rho)
    res_r <- y - theta - r; res_z <- Dth - z
    u_r   <- u_r + res_r; u_z <- u_z + res_z
    pri   <- sqrt(sum(res_r^2) + sum(res_z^2))
    dua   <- rho * sqrt(sum(((r - r_old) - as.numeric(Matrix::crossprod(D, z - z_old)))^2))
    eps_p <- sqrt(n + m) * eps_abs + eps_rel * max(sqrt(sum(theta^2) + sum(Dth^2)), sqrt(sum(r^2) + sum(z^2)), sqrt(sum(y^2)))
    eps_d <- sqrt(n) * eps_abs + eps_rel * rho * sqrt(sum((u_r + as.numeric(Matrix::crossprod(D, u_z)))^2))
    if (pri <= eps_p && dua <= eps_d) { converged <- TRUE; break }
  }
  list(theta = theta, z = z, converged = converged, iterations = it,
       primal_residual = pri, dual_residual = dua,
       state = list(theta = theta, r = r, z = z, u_r = u_r, u_z = u_z))
}

fit_admm_prox_path <- function(y, tau, D, w, lambdas, rho, max_iter, eps_abs, eps_rel, warm, rho_x_lambda = TRUE) {
  chol_M <- Matrix::Cholesky(Matrix::Diagonal(length(y)) + Matrix::crossprod(D), LDL = FALSE, perm = FALSE)
  out <- vector("list", length(lambdas)); st <- NULL
  for (i in seq_along(lambdas)) {
    rho_i <- if (rho_x_lambda) rho * lambdas[i] else rho
    if (!is.null(st) && rho_x_lambda && i > 1L) {           # rescale duals when rho changes
      st$u_r <- st$u_r * (rho * lambdas[i - 1L]) / rho_i; st$u_z <- st$u_z * (rho * lambdas[i - 1L]) / rho_i
    }
    out[[i]] <- admm_prox_solve(y, tau, lambdas[i], D, w, rho_i, max_iter, eps_abs, eps_rel, chol_M, st)
    if (warm) st <- out[[i]]$state
  }
  out
}


## ---------------------------------------------------------------------------
##  4b'. Two-block ADMM with the trend-filtering prox as theta-update
## ---------------------------------------------------------------------------
##  minimise sum w_i rho_tau(r_i) + lambda ||D theta||_1   s.t.  r = y - theta
##    theta <- argmin (rho/2)||theta - (y - r + u)||^2 + lambda ||D theta||_1
##             = Gaussian trend filtering of v = y - r + u with penalty lambda/rho
##             (glmgen::trendfilter, the same prox used in Individual_Sampler_Scale.R;
##              when glmgen is not installed an exact QP fallback is used)
##    r     <- prox_{(w/rho) rho_tau}(y - theta + u)
##    u    += y - theta - r
##  The hard l1 part is solved exactly inside the theta-step, so this does not
##  suffer from the D'D conditioning that slows the three-way split above.

tf_prox_factory <- function(D, order, backend) {
  n <- ncol(D); m <- nrow(D)
  if (requireNamespace("glmgen", quietly = TRUE)) {
    return(function(v, lam) {
      fit <- glmgen::trendfilter(x = seq_len(n), y = v, k = order, lambda = lam,
                                 control = glmgen::trendfilter.control.list(max_iter = 800L))
      as.numeric(fit$beta)
    })
  }
  message("Note: glmgen not installed; admm_tf uses an exact QP fallback for the theta-step (slow).")
  ## variables (theta, s) with s >= |D theta|:  min 1/2||theta - v||^2 + lam 1's
  G <- rbind(cbind(D, -Matrix::Diagonal(m)), cbind(-D, -Matrix::Diagonal(m)))
  if (backend == "piqp") {
    return(function(v, lam) {
      mdl <- piqp::piqp(P = Matrix::Diagonal(n + m, c(rep(1, n), rep(0, m))), c = c(-v, rep(lam, m)),
                        G = G, h_u = rep(0, 2 * m),
                        settings = list(verbose = FALSE, eps_abs = qp_tol, eps_rel = qp_tol,
                                        eps_duality_gap_abs = qp_tol, eps_duality_gap_rel = qp_tol, max_iter = 20000L),
                        backend = "sparse")
      fit <- solve(mdl); if (!identical(fit$info$status_desc, "solved")) stop("piqp TF prox: ", fit$info$status_desc)
      fit$x[seq_len(n)]
    })
  }
  if (backend == "quadprog") {
    Amat <- as.matrix(Matrix::t(-G)); tiny <- 1e-8
    return(function(v, lam) {
      quadprog::solve.QP(Dmat = diag(c(rep(1, n), rep(tiny, m))), dvec = c(v, rep(-lam, m)),
                         Amat = Amat, bvec = rep(0, 2 * m), meq = 0)$solution[seq_len(n)]
    })
  }
  stop("admm_tf needs glmgen, piqp or quadprog.")
}

admm_tf_solve <- function(y, tau, lambda, D, w, rho, max_iter, eps_abs, eps_rel, relax, prox_tf, state = NULL) {
  n <- length(y)
  if (is.null(state)) { theta <- y; r <- numeric(n); u <- numeric(n) } else { theta <- state$theta; r <- state$r; u <- state$u }
  fit_w <- w > 0; converged <- FALSE; pri <- dua <- NA_real_
  for (it in seq_len(max_iter)) {
    r_old <- r
    theta <- prox_tf(y - r + u, lambda / rho)
    th_rel <- relax * theta + (1 - relax) * (y - r_old)       # over-relaxation (Boyd 3.4.3)
    v <- y - th_rel + u
    r <- v; r[fit_w] <- prox_quantile(v[fit_w], tau, w[fit_w] / rho)
    res <- y - th_rel - r
    u <- u + res
    pri <- sqrt(sum((y - theta - r)^2)); dua <- rho * sqrt(sum((r - r_old)^2))
    eps_p <- sqrt(n) * eps_abs + eps_rel * max(sqrt(sum(theta^2)), sqrt(sum(r^2)), sqrt(sum(y^2)))
    eps_d <- sqrt(n) * eps_abs + eps_rel * rho * sqrt(sum(u^2))
    if (pri <= eps_p && dua <= eps_d) { converged <- TRUE; break }
  }
  list(theta = theta, z = as.numeric(D %*% theta), converged = converged, iterations = it,
       primal_residual = pri, dual_residual = dua, state = list(theta = theta, r = r, u = u))
}

fit_admm_tf_path <- function(y, tau, D, order, w, lambdas, rho_mult, max_iter, eps_abs, eps_rel, relax, warm, backend) {
  prox_tf <- tf_prox_factory(D, order, backend)
  out <- vector("list", length(lambdas)); st <- NULL
  for (i in seq_along(lambdas)) {
    out[[i]] <- admm_tf_solve(y, tau, lambdas[i], D, w, rho_mult, max_iter, eps_abs, eps_rel, relax, prox_tf, st)
    if (warm) st <- out[[i]]$state
  }
  out
}


## ---------------------------------------------------------------------------
##  4c. Spingarn's method  (port of detrendr src/spingarn.cpp + prox.cpp)
## ---------------------------------------------------------------------------
##  One step:  (theta, eta) <- prox ;  mid = 2 prox - old ;  project mid onto
##  {eta = D theta} ;  new = old + (proj(mid) - prox).  Final output = prox().
##  detrendr runs a fixed number of iterations (numIter, default 10000) with
##  step = 1; here the same, plus an early stop when the iterate stalls.

spingarn_solve <- function(y, tau, lambda, D, w, max_iter, eps_abs, eps_rel, chol_M = NULL, state = NULL) {
  n <- length(y)
  if (is.null(chol_M)) chol_M <- Matrix::Cholesky(Matrix::Diagonal(n) + Matrix::crossprod(D), LDL = FALSE, perm = FALSE)
  if (is.null(state)) { theta <- y; eta <- as.numeric(D %*% theta) } else { theta <- state$theta; eta <- state$eta }
  fit_w <- w > 0
  prox_pair <- function(theta, eta) {
    v <- y - theta; p <- v
    p[fit_w] <- prox_quantile(v[fit_w], tau, w[fit_w])          # prox_f1 with step 1
    list(theta = y - p, eta = soft_threshold(eta, lambda))     # prox_f2 with step 1
  }
  converged <- FALSE; step_norm <- NA_real_
  for (it in seq_len(max_iter)) {
    th_old <- theta; et_old <- eta
    p <- prox_pair(theta, eta)
    th_mid <- 2 * p$theta - th_old; et_mid <- 2 * p$eta - et_old
    th_proj <- as.numeric(Matrix::solve(chol_M, th_mid + as.numeric(Matrix::crossprod(D, et_mid))))
    et_proj <- as.numeric(D %*% th_proj)
    theta <- th_old + (th_proj - p$theta); eta <- et_old + (et_proj - p$eta)
    step_norm <- sqrt(sum((theta - th_old)^2) + sum((eta - et_old)^2))
    if (step_norm <= sqrt(n) * eps_abs + eps_rel * sqrt(sum(theta^2) + sum(eta^2))) { converged <- TRUE; break }
  }
  p <- prox_pair(theta, eta)
  list(theta = p$theta, z = p$eta, converged = converged, iterations = it,
       primal_residual = step_norm, dual_residual = NA_real_, state = list(theta = theta, eta = eta))
}

fit_spingarn_path <- function(y, tau, D, w, lambdas, max_iter, eps_abs, eps_rel, warm) {
  chol_M <- Matrix::Cholesky(Matrix::Diagonal(length(y)) + Matrix::crossprod(D), LDL = FALSE, perm = FALSE)
  out <- vector("list", length(lambdas)); st <- NULL
  for (i in seq_along(lambdas)) {
    out[[i]] <- spingarn_solve(y, tau, lambdas[i], D, w, max_iter, eps_abs, eps_rel, chol_M, st)
    if (warm) st <- out[[i]]$state
  }
  out
}


## ---------------------------------------------------------------------------
##  4d. Brantley Algorithm 1: consensus ADMM over overlapping windows
## ---------------------------------------------------------------------------
##  Port of detrendr::get_trend_windows(): window variables phi^(w) = y^(w) -
##  theta^(w) (as u+ - u-) and eta^(w) = D theta^(w) (as eta+ - eta-); the
##  consensus variable averages phi over overlaps (update_consensus); each
##  window solves the QP  cost'x + (rho/2)||x||^2 + x'(w - rho zbar) with
##  the LP constraints (update_model); duals w += rho (x - zbar) (update_dual);
##  stop when both residual norms fall below detrendr's eps_pri / eps_dual.
##  The first window fit is the plain LP, as in the package.

window_layout <- function(n, size, ov) {
  size <- min(as.integer(round(size)), n); ov <- as.integer(round(ov))
  if (size >= n) return(list(ids = list(seq_len(n)), size = n, overlap = 0L))
  stopifnot(ov >= 0, ov < size)
  n_w <- ceiling((n - ov) / (size - ov))
  ids <- lapply(seq_len(n_w), function(i) {
    a <- 1L + (size - ov) * (i - 1L); b <- min(size + (size - ov) * (i - 1L), n); a:b
  })
  ids <- ids[lengths(ids) > 0L]
  list(ids = ids, size = size, overlap = ov)
}

qp_solve_backend <- function(bld, lin, rho, backend, tol = qp_tol) {
  ## minimise lin'x + (rho/2)||x||^2  s.t. A x = rhs, x >= 0
  N <- length(lin); m <- bld$m
  switch(backend,
    piqp = {
      mdl <- piqp::piqp(P = Matrix::Diagonal(N, rho), c = lin, A = bld$A, b = bld$rhs,
                        G = -Matrix::Diagonal(N), h_u = rep(0, N),
                        settings = list(verbose = FALSE, eps_abs = tol, eps_rel = tol,
                                        eps_duality_gap_abs = tol, eps_duality_gap_rel = tol,
                                        max_iter = 20000L), backend = "sparse")
      fit <- solve(mdl)
      if (!identical(fit$info$status_desc, "solved")) stop("piqp QP: ", fit$info$status_desc)
      fit$x
    },
    gurobi = {
      res <- gurobi::gurobi(list(obj = lin, Q = Matrix::Diagonal(N, rho / 2), A = bld$A, rhs = bld$rhs,
                                 sense = rep("=", m), modelsense = "min", lb = rep(0, N)), list(OutputFlag = 0))
      if (is.null(res$x)) stop("gurobi QP status: ", res$status)
      res$x
    },
    quadprog = {
      Amat <- as.matrix(Matrix::t(rbind(bld$A, Matrix::Diagonal(N))))
      quadprog::solve.QP(Dmat = diag(rho, N), dvec = -lin, Amat = Amat,
                         bvec = c(bld$rhs, rep(0, N)), meq = m)$solution
    },
    stop("unknown QP backend"))
}

admm_windows_solve <- function(y, tau, lambda, D_full, order, w, layout, rho, max_iter,
                               eps_abs, eps_rel, lp_backend, qp_backend, state = NULL) {
  n <- length(y); ids <- layout$ids; W <- length(ids); d <- order + 1L
  cover <- tabulate(unlist(ids), nbins = n)
  blds <- lapply(ids, function(id) lp_build(y[id], tau, diff_matrix(length(id), d), w[id]))
  ## window LP fits (initialisation), variables x^(w) = (u+, u-, eta+, eta-)
  xs_w <- lapply(seq_len(W), function(k) {
    f <- lp_solve_backend(blds[[k]], lambda, lp_backend)
    n_k <- blds[[k]]$n; phi <- y[ids[[k]]] - f$theta; eta <- as.numeric(blds[[k]]$A[, seq_len(n_k)] %*% phi * 0)  # placeholder
    eta <- as.numeric(diff_matrix(n_k, d) %*% f$theta)
    c(pmax(phi, 0), pmax(-phi, 0), pmax(eta, 0), pmax(-eta, 0))
  })
  if (W == 1L) {
    x <- xs_w[[1L]]; n1 <- blds[[1L]]$n
    return(list(theta = y - (x[seq_len(n1)] - x[n1 + seq_len(n1)]), converged = TRUE, iterations = 0L,
                primal_residual = 0, dual_residual = 0, n_windows = 1L, state = NULL))
  }
  ## split each x into (phi, eta) = (u+ - u-, eta+ - eta-)
  split_x <- function(x, n_k) list(phi = x[seq_len(n_k)] - x[n_k + seq_len(n_k)],
                                   eta = x[2 * n_k + seq_len(length(x) / 2 - n_k)] - x[length(x) / 2 + n_k + seq_len(length(x) / 2 - n_k)])
  consensus <- function(phis) {             # detrendr::update_consensus (average over overlaps)
    bar <- numeric(n)
    for (k in seq_len(W)) bar[ids[[k]]] <- bar[ids[[k]]] + phis[[k]]
    bar / cover
  }
  dual <- if (is.null(state)) lapply(seq_len(W), function(k) numeric(2L * blds[[k]]$n - d)) else state$dual
  parts <- lapply(seq_len(W), function(k) split_x(xs_w[[k]], blds[[k]]$n))
  phibar <- consensus(lapply(parts, `[[`, "phi"))
  etabar <- lapply(seq_len(W), function(k) as.numeric(diff_matrix(blds[[k]]$n, d) %*% (y[ids[[k]]] - phibar[ids[[k]]])))
  dual <- lapply(seq_len(W), function(k) dual[[k]] + rho * c(parts[[k]]$phi - phibar[ids[[k]]], parts[[k]]$eta - etabar[[k]]))
  converged <- FALSE; pri <- dua <- NA_real_; phibar_old <- phibar
  for (it in seq_len(max_iter)) {
    ## window QPs (update_model + solve)
    for (k in seq_len(W)) {
      b <- blds[[k]]; n_k <- b$n; m_k <- b$m
      zb <- c(phibar[ids[[k]]], etabar[[k]])
      g  <- dual[[k]] - rho * zb                            # w - rho * zbar
      lin <- c(b$cost0, rep(lambda, 2 * m_k)) + c(g[seq_len(n_k)], -g[seq_len(n_k)], g[n_k + seq_len(m_k)], -g[n_k + seq_len(m_k)])
      xs_w[[k]] <- qp_solve_backend(b, lin, rho, qp_backend)
    }
    parts  <- lapply(seq_len(W), function(k) split_x(xs_w[[k]], blds[[k]]$n))
    phibar <- consensus(lapply(parts, `[[`, "phi"))
    etabar <- lapply(seq_len(W), function(k) as.numeric(diff_matrix(blds[[k]]$n, d) %*% (y[ids[[k]]] - phibar[ids[[k]]])))
    resid  <- lapply(seq_len(W), function(k) c(parts[[k]]$phi - phibar[ids[[k]]], parts[[k]]$eta - etabar[[k]]))
    dual   <- lapply(seq_len(W), function(k) dual[[k]] + rho * resid[[k]])
    pri <- sqrt(sum(unlist(resid)^2))
    dua <- rho * sqrt(sum((phibar - phibar_old)^2))
    eps_p <- sqrt(n) * eps_abs + eps_rel * max(sqrt(sum(unlist(lapply(parts, `[[`, "phi"))^2)), sqrt(sum(phibar^2)))
    eps_d <- sqrt(n) * eps_abs + eps_rel * sqrt(sum(unlist(dual)^2))
    phibar_old <- phibar
    if (it > 1L && pri <= eps_p && dua <= eps_d) { converged <- TRUE; break }
  }
  list(theta = y - phibar, converged = converged, iterations = it, primal_residual = pri, dual_residual = dua,
       n_windows = W, state = list(dual = dual))
}

fit_admm_windows_path <- function(y, tau, D, order, w, lambdas, layout, rho, max_iter, eps_abs, eps_rel,
                                  lp_backend, qp_backend, warm) {
  out <- vector("list", length(lambdas)); st <- NULL
  for (i in seq_along(lambdas)) {
    out[[i]] <- admm_windows_solve(y, tau, lambdas[i], D, order, w, layout, rho, max_iter, eps_abs, eps_rel,
                                   lp_backend, qp_backend, st)
    if (warm) st <- out[[i]]$state
  }
  out
}


## ---------------------------------------------------------------------------
##  5. Selection criteria  (detrendr::get_criteria; paper Section 3)
## ---------------------------------------------------------------------------
##  eBIC:  2 * check_loss / sigma + df log n + 2 gamma log choose(P, df),
##         sigma = 0.5 - |0.5 - tau|  (= (1 - |1 - 2 tau|)/2),  P = n - k - 1
##  SIC :  log(mean check loss) + df log n / (2 n)
##  valid: mean check loss on the held-out set (every `valid_every`-th point)
##  df   :  number of |D theta| > df_tol (for admm_prox / spingarn the exactly
##          sparse z copy is used instead, which is what the ADMM returns as
##          the l1-penalised block).

criterion_value <- function(theta, z, y, tau, D, w, rule, valid_idx) {
  n <- length(y)
  Dth <- if (!is.null(z)) z else as.numeric(D %*% theta)
  df  <- sum(abs(Dth) > df_tol)
  fit_idx <- which(w > 0)
  loss <- check_loss((y - theta)[fit_idx], tau)
  val <- switch(rule,
    eBIC = {
      P <- nrow(D)
      pen <- 2 * ebic_gamma * lchoose(P, df)
      2 * loss / (0.5 - abs(0.5 - tau)) + log(n) * df + pen
    },
    SIC   = log(loss / length(fit_idx)) + log(n) * df / (2 * n),
    valid = check_loss((y - theta)[valid_idx], tau) / length(valid_idx),
    fixed = NA_real_)
  list(value = val, df = df, loss = loss)
}


## ---------------------------------------------------------------------------
##  6. Run
## ---------------------------------------------------------------------------

d <- order + 1L
D <- diff_matrix(n_data, d)

## loss weights: 1 everywhere, 0 on the held-out set for the validation rule
w_fit <- rep(1, n_data)
valid_idx <- integer(0)
if (lambda_rule == "valid") {
  valid_idx <- seq(valid_every, n_data, by = valid_every)
  w_fit[valid_idx] <- 0
}

lambdas <- if (lambda_rule == "fixed") lambda_fixed else sort(lambda_grid, decreasing = TRUE)
layout  <- window_layout(n_data, window_size, overlap)

tag <- sprintf("%s_%s_%s_%s_k%d_tau%s_n%d_seed%03d", baseline_key, noise, solver, lambda_rule, order,
               gsub("\\.", "", sprintf("%.2f", tau)), n_data, seed)

cat("\n=== Quantile trend filtering (Brantley et al. 2020) ===\n")
cat("baseline     :", baseline_key, "\n")
cat("noise        :", noise, "\n")
cat("tau          :", tau, "\n")
cat("order (k)    :", order, sprintf(" -> penalty on D^(%d) theta", d),
    if (order != default_order) sprintf("  [baseline default is %d]", default_order) else "", "\n")
cat("n            :", n_data, " seed:", seed, "\n")
cat("solver       :", solver,
    if (solver == "admm_windows") sprintf("(windows = %d, size = %d, overlap = %d, QP = %s, LP = %s)",
                                          length(layout$ids), layout$size, layout$overlap, qp_backend, lp_backend)
    else if (solver == "lp") sprintf("(backend = %s)", lp_backend)
    else sprintf("(rho = %g, max_iter = %d)", admm_rho, admm_max_iter), "\n")
cat("lambda rule  :", lambda_rule, if (lambda_rule == "fixed") sprintf("(lambda = %g)", lambda_fixed)
    else sprintf("(grid of %d values, %.3g .. %.3g)", length(lambdas), min(lambdas), max(lambdas)), "\n\n")

t0 <- proc.time()
fits <- switch(solver,
  lp           = fit_lp_path(y, tau, D, w_fit, lambdas, lp_backend),
  admm_tf      = fit_admm_tf_path(y, tau, D, order, w_fit, lambdas, admm_rho, admm_max_iter, admm_eps_abs, admm_eps_rel,
                                  admm_relax, admm_warm, qp_backend),
  admm_prox    = fit_admm_prox_path(y, tau, D, w_fit, lambdas, admm_rho, admm_max_iter, admm_eps_abs, admm_eps_rel,
                                    admm_warm, admm_rho_x_lambda),
  spingarn     = fit_spingarn_path(y, tau, D, w_fit, lambdas, admm_max_iter, admm_eps_abs, admm_eps_rel, admm_warm),
  admm_windows = fit_admm_windows_path(y, tau, D, order, w_fit, lambdas, layout, admm_rho, win_max_iter,
                                       win_eps_abs, win_eps_rel, lp_backend, qp_backend, admm_warm))
path_seconds <- (proc.time() - t0)[["elapsed"]]

path <- do.call(rbind, lapply(seq_along(lambdas), function(i) {
  f <- fits[[i]]
  cr <- criterion_value(f$theta, f$z, y, tau, D, w_fit, lambda_rule, valid_idx)
  data.frame(lambda = lambdas[i], criterion = cr$value, df = cr$df, check_loss = cr$loss,
             objective = objective_value(f$theta, y, tau, lambdas[i], D, w_fit),
             converged = f$converged, iterations = f$iterations,
             primal_residual = f$primal_residual, dual_residual = f$dual_residual,
             mse_vs_truth = mean((f$theta - Q_true)^2))
}))
if (verbose && nrow(path) > 1L) {
  for (i in seq_len(nrow(path)))
    cat(sprintf("lambda = %9.4g  %s = %10.4f  df = %4d  obj = %9.4f  conv = %-5s iters = %5d  MSE = %.5f\n",
                path$lambda[i], lambda_rule, path$criterion[i], path$df[i], path$objective[i],
                path$converged[i], path$iterations[i], path$mse_vs_truth[i]))
}

sel <- if (lambda_rule == "fixed") 1L else which.min(path$criterion)
lambda_hat <- path$lambda[sel]
theta_hat  <- fits[[sel]]$theta
boundary   <- lambda_rule != "fixed" && sel %in% c(1L, nrow(path))

## validation rule: refit on all data at the selected lambda (paper Sec. 3.1)
if (lambda_rule == "valid") {
  w_all <- rep(1, n_data)
  refit <- switch(solver,
    lp           = fit_lp_path(y, tau, D, w_all, lambda_hat, lp_backend)[[1L]],
    admm_tf      = fit_admm_tf_path(y, tau, D, order, w_all, lambda_hat, admm_rho, admm_max_iter, admm_eps_abs, admm_eps_rel,
                                    admm_relax, FALSE, qp_backend)[[1L]],
    admm_prox    = admm_prox_solve(y, tau, lambda_hat, D, w_all, if (admm_rho_x_lambda) admm_rho * lambda_hat else admm_rho,
                                   admm_max_iter, admm_eps_abs, admm_eps_rel),
    spingarn     = spingarn_solve(y, tau, lambda_hat, D, w_all, admm_max_iter, admm_eps_abs, admm_eps_rel),
    admm_windows = admm_windows_solve(y, tau, lambda_hat, D, order, w_all, layout, admm_rho, win_max_iter,
                                      win_eps_abs, win_eps_rel, lp_backend, qp_backend))
  theta_hat <- refit$theta
}

mse <- mean((theta_hat - Q_true)^2)
mad <- mean(abs(theta_hat - Q_true))
rmse <- sqrt(mse)
obj_hat <- objective_value(theta_hat, y, tau, lambda_hat, D)
df_hat  <- sum(abs(as.numeric(D %*% theta_hat)) > df_tol)

lp_ref <- NULL
if (compare_with_lp && solver != "lp") {
  t1 <- proc.time()
  lp_ref <- lp_solve_backend(lp_build(y, tau, D, rep(1, n_data)), lambda_hat, lp_backend)
  lp_ref$seconds <- (proc.time() - t1)[["elapsed"]]
  lp_ref$objective <- objective_value(lp_ref$theta, y, tau, lambda_hat, D)
  lp_ref$mse <- mean((lp_ref$theta - Q_true)^2)
}

cat("\n=== RESULTS (vs Q_true, the true tau-quantile of y | x) ===\n")
cat("selected lambda     :", signif(lambda_hat, 6), if (boundary) " [ON THE GRID BOUNDARY]" else "", "\n")
cat("active knots (df)   :", df_hat, "\n")
cat("objective at lambda :", signif(obj_hat, 8), "\n")
cat("MSE                 :", signif(mse, 6), "\n")
cat("RMSE                :", signif(rmse, 6), "\n")
cat("MAD                 :", signif(mad, 6), "\n")
cat("all path fits conv. :", all(path$converged), "\n")
cat("path elapsed (s)    :", round(path_seconds, 2), "\n")
if (!is.null(lp_ref)) {
  cat(sprintf("exact LP at lambda  : objective %.8g  (ADMM - LP = %.3g, rel %.2e)  MSE %.6f  [%s, %.2fs]\n",
              lp_ref$objective, obj_hat - lp_ref$objective, (obj_hat - lp_ref$objective) / (1 + abs(lp_ref$objective)),
              lp_ref$mse, lp_backend, lp_ref$seconds))
  cat(sprintf("max |theta_admm - theta_lp| : %.4g\n", max(abs(theta_hat - lp_ref$theta))))
}
cat("\n")

metrics <- data.frame(
  baseline = baseline_key, noise = noise, tau = tau, order = order, n = n_data, seed = seed,
  solver = solver, lambda_rule = lambda_rule, lambda = lambda_hat, boundary = boundary, df = df_hat,
  mse = mse, rmse = rmse, mad = mad, objective = obj_hat,
  all_converged = all(path$converged), path_seconds = path_seconds,
  lp_objective = if (is.null(lp_ref)) NA_real_ else lp_ref$objective,
  lp_mse = if (is.null(lp_ref)) NA_real_ else lp_ref$mse,
  stringsAsFactors = FALSE)


## ---------------------------------------------------------------------------
##  7. Plots
## ---------------------------------------------------------------------------

df_plot <- tibble(x = x_idx, y = y, truth = Q_true, estimate = theta_hat)
pal <- c("True quantile" = "black", "QTF estimate" = "#1F618D")
p_fit <- ggplot(df_plot, aes(x = x)) +
  geom_point(aes(y = y), colour = "grey55", alpha = 0.40, size = 0.7) +
  geom_line(aes(y = truth, colour = "True quantile"), linewidth = 1.0) +
  geom_line(aes(y = estimate, colour = "QTF estimate"), linewidth = 0.9, linetype = "22") +
  scale_colour_manual(values = pal, breaks = names(pal), name = NULL) +
  labs(title = sprintf("Quantile trend filtering (%s): %s baseline, %s noise, tau = %.2f, k = %d",
                       solver, baseline_key, noise, tau, order),
       subtitle = sprintf("n = %d, lambda = %.3g by %s, df = %d  |  MSE = %.5f, MAD = %.5f",
                          n_data, lambda_hat, lambda_rule, df_hat, mse, mad),
       x = "x", y = "value") +
  theme_minimal(base_size = 11) + theme(legend.position = "bottom")

p_path <- NULL
if (lambda_rule != "fixed") {
  p_path <- ggplot(path, aes(x = lambda, y = criterion)) +
    geom_line(colour = "grey40") + geom_point(aes(colour = converged), size = 2) +
    geom_vline(xintercept = lambda_hat, linetype = "dashed", colour = "#C0392B") +
    scale_x_log10() +
    scale_colour_manual(values = c(`TRUE` = "#1F618D", `FALSE` = "#C0392B"), name = "converged") +
    labs(title = sprintf("%s over the lambda grid (selected lambda = %.3g)", lambda_rule, lambda_hat),
         x = "lambda (log scale)", y = lambda_rule) +
    theme_minimal(base_size = 11) + theme(legend.position = "bottom")
}

.show <- function(p) {
  if (!show_plots || is.null(p)) return(invisible(NULL))
  if (use_windows_device && interactive() && .Platform$OS.type == "windows") windows()
  print(p)
}
.show(p_fit); .show(p_path)


## ---------------------------------------------------------------------------
##  8. Save
## ---------------------------------------------------------------------------

if (save_outputs) {
  png_fit  <- file.path(out_dir, paste0("fit_", tag, ".png"))
  ggsave(png_fit, plot = p_fit, width = 9, height = 5.2, dpi = 300)
  if (!is.null(p_path)) ggsave(file.path(out_dir, paste0("path_", tag, ".png")), plot = p_path, width = 7, height = 4.5, dpi = 300)
  write.csv(metrics, file.path(out_dir, paste0("metrics_", tag, ".csv")), row.names = FALSE)
  write.csv(path, file.path(out_dir, paste0("path_", tag, ".csv")), row.names = FALSE)
  saveRDS(list(config = list(baseline = baseline_key, noise = noise, tau = tau, order = order, n = n_data, seed = seed,
                             solver = solver, lambda_rule = lambda_rule, lambda_grid = lambdas, ebic_gamma = ebic_gamma,
                             df_tol = df_tol, admm = list(rho = admm_rho, max_iter = admm_max_iter, eps_abs = admm_eps_abs,
                                                          eps_rel = admm_eps_rel, warm = admm_warm),
                             windows = list(size = layout$size, overlap = layout$overlap, n_windows = length(layout$ids),
                                            max_iter = win_max_iter, eps_abs = win_eps_abs, eps_rel = win_eps_rel),
                             lp_backend = lp_backend, qp_backend = qp_backend),
               metrics = metrics, path = path, x = x_idx, y = y, truth = Q_true, baseline_curve = baseline_curve,
               theta_hat = theta_hat, lambda_hat = lambda_hat, lp_reference = lp_ref),
          file.path(out_dir, paste0("fit_", tag, ".rds")))
  cat("Saved to", out_dir, "\n\n")
}
