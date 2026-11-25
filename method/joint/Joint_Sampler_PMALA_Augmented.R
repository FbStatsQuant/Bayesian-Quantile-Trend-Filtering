# =============================================================================
# Joint (non-crossing) Bayesian quantile trend filtering: the individual augmented P-MALA sampler
# (method/individual/Individual_Sampler_PMALA_Augmented.R) extended to an ordered set of quantile levels.
#
# Target.  Levels tau_1 < ... < tau_J, each with its own (theta_j, z_j, lambda_j, sigma_j) and the individual model
#   y_i = theta_ij + eps_ij,  eps_ij ~ ALD(0, sigma_j, tau_j)   (Kozumi-Kobayashi augmentation, Laplace prior on D theta_j,
#   lambda_j ~ Gamma(a0, b0), sigma_j ~ IG(a_sigma, b_sigma)),  coupled only by the order indicator
#   pi_C(Theta, Z, lambda, sigma | y)  propto  1{theta_1 <= theta_2 <= ... <= theta_J componentwise} prod_j pi_j(theta_j, z_j, lambda_j, sigma_j | y).
#   Given Theta the indicator is constant, so the z, lambda and sigma conditionals are the individual ones, level by level.
#
# One Gibbs sweep visits j = 1..J in increasing order and completes all of level j's updates before moving on, with the box
#   B_j = [ell_j, u_j],  ell_j = theta_{j-1} (already updated this sweep),  u_j = theta_{j+1} (previous sweep),  +-Inf at the ends,
# held fixed through level j's theta and interweaving updates, so the ordering holds after every accepted move.
#   Block 1  theta_j | z_j, lambda_j, sigma_j, B_j   P-MALA whose proximal map is the BOX-CONSTRAINED problem
#            T_B(x) = argmin_{theta in B_j} U_j(theta) + ||theta - x||_M^2 / (2 gamma),  M = diag(a) + kappa (lambda^2/2) D'D
#            (prox_box_metric.cpp: the unbounded banded ADMM first -- accepted when it lands in the box, bitwise the individual
#            map -- otherwise a banded primal-dual interior-point solve to 1e-8 in theta; a deterministic map either way).
#            Proposal theta* ~ N(T_B(theta), delta M^{-1}).  theta* outside B_j: target density 0, reject.  Otherwise the usual
#            ratio  log alpha = U(theta) - U(theta*) + [||theta* - T_B(theta)||_M^2 - ||theta - T_B(theta*)||_M^2] / (2 delta)
#            (same metric both ways, so the Gaussian normalisers cancel; no truncated-normal constant).
#   Block 2  z_j | theta_j, sigma_j          individual InvGauss draw
#   Block 3  lambda_j | theta_j              Gamma(a0 + m, b0 + ||D theta_j||_1), then the ASIS redraw restricted to the box:
#            theta_j(lambda') = p_j + (lambda_j / lambda') (theta_j - p_j) must stay in B_j, an interval in log lambda'.
#   Block 4  sigma_j | theta_j, z_j          individual IG draw
#   delta_j adapted exactly as in the individual script (Robbins-Monro, diminishing gain, whole run when adapt_all = TRUE).
# J = 1: B_1 = R^n and every block dispatches to the unchanged individual routines (same RNG call sequence; test T1).
#
# Usage:  Rscript Joint_Sampler_PMALA_Augmented.R              (pilot run: tau_list below; csv + plots in results_joint/)
#         Rscript Joint_Sampler_PMALA_Augmented.R test_prox    (optimisation-kernel tests only)
#         Rscript Joint_Sampler_PMALA_Augmented.R test         (kernel tests + sampler exactness tests)
# =============================================================================

suppressPackageStartupMessages(library(glmgen))
`%||%` <- function(a, b) if (is.null(a)) b else a

# ---- Locate this script's folder (prox_box_metric.cpp beside it; ../individual/prox_admm_metric.cpp is #included) -------
.norm <- function(p) {
  if (is.null(p) || length(p) != 1L || is.na(p) || !nzchar(p)) return(NA_character_)
  tryCatch(normalizePath(p, winslash = "/", mustWork = FALSE), error = function(e) NA_character_)
}
.script_dir <- function(target = "prox_box_metric.cpp") {
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  p <- if (length(a)) .norm(sub("^--file=", "", a[[1L]])) else NA_character_
  if (is.na(p)) p <- .norm(tryCatch(sys.frame(1)$ofile, error = function(e) NULL))
  if (is.na(p) && requireNamespace("rstudioapi", quietly = TRUE) &&
      isTRUE(tryCatch(rstudioapi::isAvailable(), error = function(e) FALSE)))
    p <- .norm(tryCatch(rstudioapi::getActiveDocumentContext()$path, error = function(e) NA_character_))
  if (!is.na(p) && file.exists(file.path(dirname(p), target))) return(dirname(p))
  rel <- file.path("method", "joint")
  up <- character(0); d <- .norm(getwd())
  while (!is.na(d) && !(d %in% up)) { up <- c(up, d); d <- dirname(d) }
  cand <- c(up, file.path(up, rel), file.path(c("~", "~/Documents", "~/OneDrive/Documents"), "Quantile Regression", rel))
  hit <- cand[file.exists(file.path(cand, target))]
  if (length(hit)) return(.norm(hit[[1L]]))
  stop("Could not find ", target, ". Open this script from method/joint, or setwd() there.")
}
script_dir     <- .script_dir()
individual_dir <- file.path(dirname(script_dir), "individual")
out_dir        <- file.path(script_dir, "results_joint")

# ---- C++ kernel: the unbounded kernel (#included) and the bounded one ---------------------------------------------------
# Rtools / g++ on the PATH: Rcpp::sourceCpp (both files, since sourceCpp only exports the attributes of the file it is given).
# Otherwise: one mingw g++ DLL with plain .Call entry points for both kernels.
load_box_cpp <- function(joint_dir = script_dir, ind_dir = individual_dir) {
  src <- file.path(joint_dir, "prox_box_metric.cpp"); inc <- normalizePath(ind_dir, winslash = "/", mustWork = TRUE)
  stopifnot(file.exists(src), file.exists(file.path(inc, "prox_admm_metric.cpp")))
  old <- Sys.getenv("PKG_CPPFLAGS", unset = NA); Sys.setenv(PKG_CPPFLAGS = sprintf('-I"%s"', inc))
  ok <- tryCatch({ Rcpp::sourceCpp(src, env = globalenv()); Rcpp::sourceCpp(file.path(inc, "prox_admm_metric.cpp"), env = globalenv()); TRUE },
                 error = function(e) FALSE, warning = function(w) FALSE)
  if (is.na(old)) Sys.unsetenv("PKG_CPPFLAGS") else Sys.setenv(PKG_CPPFLAGS = old)
  if (ok) return(invisible("sourceCpp"))
  dll <- file.path(tempdir(), "prox_box_metric.dll"); gpp <- "C:/mingw64/bin/g++.exe"
  cmd <- sprintf('"%s" -std=gnu++17 -O2 -w -shared -static-libgcc -static-libstdc++ -I"%s/include" -I"%s" -I"%s" -o "%s" "%s" -L"%s/bin/x64" -lR',
                 gpp, R.home(), system.file("include", package = "Rcpp"), inc, dll, src, R.home())
  if (system(cmd) != 0) stop("could not compile prox_box_metric.cpp (neither Rtools nor mingw g++ worked)")
  info <- dyn.load(dll); sym <- function(nm) getNativeSymbolInfo(nm, info)$address; G <- globalenv()
  s1 <- sym("C_prox_admm_metric"); s2 <- sym("C_pmala_move"); s3 <- sym("C_minv_sqrt_noise"); s4 <- sym("C_mnorm2"); s5 <- sym("C_metric_logdet")
  b1 <- sym("C_prox_box_metric"); b2 <- sym("C_box_objective"); b3 <- sym("C_pmala_box_move")
  assign("prox_admm_metric", function(x, a, r, lambda, gamma, d, c, k, rho, max_iter, tol = 0)
    .Call(s1, as.numeric(x), as.numeric(a), as.numeric(r), as.numeric(lambda), as.numeric(gamma), as.numeric(d), as.numeric(c),
          as.integer(k), as.numeric(rho), as.integer(max_iter), as.numeric(tol)), envir = G)
  assign("pmala_move", function(theta, a, r, lambda, gamma, d, c, k, rho, max_iter, tol, xi, delta)
    .Call(s2, as.numeric(theta), as.numeric(a), as.numeric(r), as.numeric(lambda), as.numeric(gamma), as.numeric(d), as.numeric(c),
          as.integer(k), as.numeric(rho), as.integer(max_iter), as.numeric(tol), as.numeric(xi), as.numeric(delta)), envir = G)
  assign("minv_sqrt_noise", function(xi, d, c, k) .Call(s3, as.numeric(xi), as.numeric(d), as.numeric(c), as.integer(k)), envir = G)
  assign("mnorm2", function(v, d, c, k) .Call(s4, as.numeric(v), as.numeric(d), as.numeric(c), as.integer(k)), envir = G)
  assign("metric_logdet", function(d, c, k) .Call(s5, as.numeric(d), as.numeric(c), as.integer(k)), envir = G)
  assign("prox_box_metric", function(x, a, r, lambda, gamma, d, c, k, rho, zeta, max_iter, tol, lower, upper, ctrl)
    .Call(b1, as.numeric(x), as.numeric(a), as.numeric(r), as.numeric(lambda), as.numeric(gamma), as.numeric(d), as.numeric(c),
          as.integer(k), as.numeric(rho), as.numeric(zeta), as.integer(max_iter), as.numeric(tol), as.numeric(lower), as.numeric(upper),
          as.numeric(ctrl)), envir = G)
  assign("box_objective", function(theta, x, a, r, lambda, gamma, d, c, k, lower, upper)
    .Call(b2, as.numeric(theta), as.numeric(x), as.numeric(a), as.numeric(r), as.numeric(lambda), as.numeric(gamma), as.numeric(d),
          as.numeric(c), as.integer(k), as.numeric(lower), as.numeric(upper)), envir = G)
  assign("pmala_box_move", function(theta, a, r, lambda, gamma, d, c, k, rho, zeta, max_iter, tol, xi, delta, lower, upper, ctrl)
    .Call(b3, as.numeric(theta), as.numeric(a), as.numeric(r), as.numeric(lambda), as.numeric(gamma), as.numeric(d), as.numeric(c),
          as.integer(k), as.numeric(rho), as.numeric(zeta), as.integer(max_iter), as.numeric(tol), as.numeric(xi), as.numeric(delta),
          as.numeric(lower), as.numeric(upper), as.numeric(ctrl)), envir = G)
  invisible("mingw")
}

# ---- Settings (joint-specific first, then the individual script's values) ------------------------------------------------
tau_list        <- c(0.75, 0.95)   # ordered quantile levels sampled jointly (strictly increasing, inside (0, 1))
target_quantile <- 0.95            # the level whose fit is plotted and reported as "target" (must be in tau_list)
seed        <- 1
n           <- 500L
baseline_id <- "VS"
noise_id    <- "Normal"
order       <- 2L          # k: piecewise quadratic; D = 3rd differences
a0 <- 1;  b0 <- 1e-5       # Gamma prior on lambda (value of the current individual script; E-08)
a_sigma <- 0.1; b_sigma <- 0.1
gibbs_iter  <- 30000
gibbs_burn  <- 10000
delta_init  <- 0.2
adapt_target <- 0.50
adapt_gain   <- 1.0
adapt_kappa  <- 0.6
delta_bounds <- c(1e-8, 100)
lambda_init  <- NULL       # NULL -> m
metric       <- "curv"
kappa_metric <- 3
c_metric     <- 1e4
mh_correct   <- TRUE
adapt_delta  <- TRUE
adapt_all    <- TRUE
warm_sweeps  <- 200L       # burn-in only: bounded conditional-MAP steps (prox with gamma_warm) before the exact kernel takes over
gamma_warm   <- 1e4
admm_iter    <- 150L       # ADMM iteration budget of the unbounded step inside T_B(x)
admm_tol     <- 0          # residual-based early exit of that step; 0 = full budget
K_theta      <- 1L
asis_lambda  <- TRUE
asis_q       <- "auto"     # ASIS subspace (E-10), as in the individual script: "auto" (calibrated q grid, cycled per sweep) | "poly" | numeric grid
admm_rho     <- NULL       # NULL -> 0.1 (mean(d) + c) / gamma
zeta_scale   <- 1          # only used by the comparison method 0 (two-block ADMM): zeta_i = zeta_scale (a_i + d_i / gamma)
box_ctrl     <- c(method = 1, try_unbounded = 1, ipm_max_iter = 100, ipm_tol = 1e-8, trace = 0)   # see prox_box_metric.cpp
tf_control   <- trendfilter.control.list(max_iter = 2000L, obj_tol = 1e-8)

# Command-line overrides for a pilot run:  Rscript Joint_Sampler_PMALA_Augmented.R gibbs_iter=3000 gibbs_burn=1000 tau_list=0.75,0.95 target_quantile=0.95
# (keys: seed n baseline_id noise_id gibbs_iter gibbs_burn warm_sweeps tau_list target_quantile b0 admm_iter K_theta asis_q)
for (kv in grep("=", commandArgs(trailingOnly = TRUE), value = TRUE)) {
  key <- sub("=.*", "", kv); val <- sub("^[^=]*=", "", kv)
  if (!exists(key)) stop("unknown setting: ", key)
  assign(key, if (key %in% c("baseline_id", "noise_id")) val else if (key == "asis_q") (if (grepl("^[0-9,]+$", val)) as.numeric(strsplit(val, ",")[[1]]) else val) else if (key == "tau_list") as.numeric(strsplit(val, ",")[[1]]) else as.numeric(val))
}
n <- as.integer(n); gibbs_iter <- as.integer(gibbs_iter); gibbs_burn <- as.integer(gibbs_burn); warm_sweeps <- as.integer(warm_sweeps); admm_iter <- as.integer(admm_iter); K_theta <- as.integer(K_theta)

# Bayesian-PMALA (individual) MSE from the manuscript tables, for the "is the joint fit close?" check (VS, n = 500, k = 2)
paper_mse <- list(VS = list(Beta = c(`0.05` = 0.000546, `0.25` = 0.001035, `0.5` = 0.001930, `0.75` = 0.003029, `0.95` = 0.007953,
                                     `0.96` = 0.010106, `0.97` = 0.012007, `0.98` = 0.015317, `0.99` = 0.021983),
                            Mixed = c(`0.05` = 0.079580, `0.25` = 0.033127, `0.5` = 0.026996, `0.75` = 0.031119, `0.95` = 0.074788,
                                      `0.96` = 0.097170, `0.97` = 0.133098, `0.98` = 0.172418, `0.99` = 0.250430),
                            Normal = c(`0.05` = 0.020012, `0.25` = 0.007919, `0.5` = 0.006843, `0.75` = 0.007612, `0.95` = 0.018994,
                                       `0.96` = 0.023881, `0.97` = 0.030245, `0.98` = 0.038815, `0.99` = 0.058112)))

# ---- Data (identical generator to the individual script; tau may be a vector -> truth is n x J) -----------------------------
simulate_data <- function(seed, n, tau, baseline_id, noise_id) {
  RNGkind("Mersenne-Twister", "Inversion", "Rejection")
  set.seed(seed)
  x <- seq_len(n); xs <- x / n; mm <- n / 100
  baseline <- switch(baseline_id,
    PC = 2.5 * (x <= mm * 20) + 1 * (x >= mm * 20 + 1 & x <= mm * 40) +
      3.5 * (x >= mm * 40 + 1 & x <= mm * 60) + 1.5 * (x >= mm * 60 + 1),
    VS = 2 + sin(4 * xs - 2) + 2 * exp(-30 * (4 * xs - 2)^2),
    S  = sin(2 * pi * x / n), stop("Unknown baseline"))
  qfun <- function(t) {
    if (noise_id == "Mixed") vapply(xs, function(xi) uniroot(function(u) xi * pnorm(u, -.2, sqrt(.5)) +
                  (1 - xi) * pnorm(u, .2, sqrt(.5)) - t, c(-10, 10))$root, numeric(1))
    else if (noise_id == "Beta") qbeta(t, 1, 11 - 10 * xs)
    else if (noise_id == "Normal") qnorm(t) * (1 + xs^2) / 4
    else stop("Unknown noise")
  }
  if (noise_id == "Mixed") {
    noise <- vapply(xs, function(xi) if (runif(1) < xi) rnorm(1, -.2, sqrt(.5)) else rnorm(1, .2, sqrt(.5)), numeric(1))
  } else if (noise_id == "Beta") {
    noise <- vapply(xs, function(xi) rbeta(1, 1, 11 - 10 * xi), numeric(1))
  } else if (noise_id == "Normal") {
    noise <- rnorm(n, 0, (1 + xs^2) / 4)
  } else stop("Unknown noise")
  truth <- sapply(tau, function(t) baseline + qfun(t))
  list(x = x, y = baseline + noise, baseline = baseline, truth = truth, tau = tau)
}

# ---- Model pieces (verbatim from the individual script) ------------------------------------------------------------------
ald_const <- function(tau) list(psi = (1 - 2 * tau) / (tau * (1 - tau)), t2 = 2 / (tau * (1 - tau)))
Dtheta  <- function(theta, order) diff(theta, differences = order + 1L)
rho_tau <- function(u, tau) u * (tau - (u < 0))
U_cond  <- function(theta, a, r, lambda, order) sum(a * (theta - r)^2) / 2 + lambda * sum(abs(Dtheta(theta, order)))
prox_T <- function(x, a, r, lambda, gamma, d, c, order, rho = NULL, iters = 200L, tol = 0) {
  if (is.null(rho)) rho <- 0.1 * (mean(d) + c) / gamma
  prox_admm_metric(x, a, r, lambda, gamma, d, c, order, rho, iters, tol)
}
metric_dc <- function(metric, a, lambda, c_fixed, kappa = 1) {
  switch(metric,
    curv  = list(d = a,                 c = min(kappa * lambda^2 / 2, 1e8)),
    fixed = list(d = rep(1, length(a)), c = c_fixed),
    iso   = list(d = rep(1, length(a)), c = 0),
    stop("unknown metric"))
}
rinvgauss <- function(n, mu, lam) {
  nu <- rnorm(n); yv <- nu^2
  xv <- mu + mu^2 * yv / (2 * lam) - (mu / (2 * lam)) * sqrt(4 * mu * lam * yv + mu^2 * yv^2)
  u  <- runif(n)
  ifelse(u <= mu / (mu + xv), xv, mu^2 / xv)
}
draw_z <- function(e, tau, sigma) {
  ae <- pmax(abs(e), 1e-10)
  v  <- rinvgauss(length(e), mu = 1 / (tau * (1 - tau) * ae), lam = 1 / (2 * tau * (1 - tau) * sigma))
  pmin(pmax(1 / v, 1e-8), 1e4)
}
draw_sigma <- function(y, theta, z, cst, a_sigma, b_sigma, lambda_SD = 0, m = 0) {
  n <- length(y)
  ss <- sum((y - theta - cst$psi * z)^2 / (2 * cst$t2 * z)) + sum(z)
  1 / rgamma(1, shape = a_sigma + 1.5 * n + m, rate = b_sigma + ss + lambda_SD)
}
pmala_step <- function(theta, y, z, lambda, sigma, delta, cst, order, metric = "curv", c_fixed = 0,
                       rho = NULL, iters = 200L, mh = TRUE, kappa = 1, tol = 0) {
  gamma <- delta / 2
  a <- 1 / (cst$t2 * sigma * z); r <- y - cst$psi * z
  M <- metric_dc(metric, a, lambda, c_fixed, kappa); d <- M$d; c <- M$c
  if (is.null(rho)) rho <- 0.1 * (mean(d) + c) / gamma
  if (!mh) {
    p    <- prox_T(theta, a, r, lambda, gamma, d, c, order, rho, iters, tol)
    prop <- p + sqrt(delta) * minv_sqrt_noise(rnorm(length(theta)), d, c, order)
    return(list(theta = prop, accept = TRUE, log_alpha = 0))
  }
  mv <- pmala_move(theta, a, r, lambda, gamma, d, c, order, rho, iters, tol, rnorm(length(theta)), delta)
  prop <- mv$prop
  log_alpha <- (U_cond(theta, a, r, lambda, order) - U_cond(prop, a, r, lambda, order)) + (mv$q_fwd - mv$q_rev) / (2 * delta)
  if (!is.finite(log_alpha)) log_alpha <- -Inf
  accept <- log(runif(1)) < log_alpha
  list(theta = if (accept) prop else theta, accept = accept, log_alpha = min(0, log_alpha))
}
# Generalised interweaving move, projector and q schedule: verbatim copies of the individual script (E-10); see the comments there.
asis_step <- function(theta, lambda, a, r, a0, b0, P, order, w = 1, max_steps = 30L, q_jac = attr(P, "q")) {
  th_par <- P(theta); th_perp <- theta - th_par; k <- order
  if (isTRUE(attr(P, "poly"))) { Dp <- 0; Dv <- 0 }      # D p = 0 exactly; lambda ||D v||_1 is then a constant in eta
  else { Dp <- diff(th_par, differences = k + 1L); Dv <- diff(th_perp, differences = k + 1L) }
  logf <- function(eta) { lam <- exp(eta); th <- th_par + (lambda / lam) * th_perp
    (a0 + q_jac - k - 1) * eta - b0 * lam - sum(abs(lam * Dp + lambda * Dv)) - sum(a * (th - r)^2) / 2 }
  eta0 <- log(lambda); y0 <- logf(eta0) - rexp(1)
  L <- eta0 - runif(1) * w; U <- L + w; j <- floor(runif(1) * max_steps); kk <- max_steps - 1 - j
  while (j > 0 && logf(L) > y0) { L <- L - w; j <- j - 1 }
  while (kk > 0 && logf(U) > y0) { U <- U + w; kk <- kk - 1 }
  repeat { eta1 <- L + runif(1) * (U - L)
    if (logf(eta1) > y0) break
    if (eta1 < eta0) L <- eta1 else U <- eta1
    if (U - L < 1e-10) { eta1 <- eta0; break } }
  lam1 <- exp(eta1)
  list(lambda = lam1, theta = as.numeric(th_par + (lambda / lam1) * th_perp))
}
null_basis <- function(n, order) qr.Q(qr(outer(seq_len(n) / n, 0:order, `^`)))   # orthonormal basis of degree-<=k polynomials

# Projector theta -> P theta onto the ASIS subspace, as a closure with attributes q (dimension) and poly (q = k + 1).
#   q = k + 1: the degree-<=k polynomials (orthonormal basis, n x (k+1)).
#   q > k + 1: B-splines of degree max(3, k) on equally spaced knots over x = i/n, which contain the degree-<=k polynomials.
#              B (n x q) has <= degree + 1 nonzeros per row, so B'B is banded (bandwidth = degree) and its Cholesky factor
#              (no permutation) has no fill: P theta = B (B'B)^{-1} B' theta costs O(n) per call.
#   basis = <matrix>: any fixed full-column-rank basis (tests).
asis_projector <- function(n, q, order, basis = NULL) {
  if (is.null(basis) && q == order + 1L) {
    Q <- null_basis(n, order)
    return(structure(function(th) as.numeric(Q %*% crossprod(Q, th)), q = q, poly = TRUE))
  }
  if (is.null(basis)) {
    deg <- max(3L, order); x <- seq_len(n) / n; nin <- q - deg - 1L
    stopifnot(nin >= 0L, q <= n)
    inner <- if (nin > 0L) seq(x[1], x[n], length.out = nin + 2L)[-c(1L, nin + 2L)] else numeric(0)
    knots <- c(rep(x[1], deg + 1L), inner, rep(x[n], deg + 1L))
    basis <- splines::splineDesign(knots, x, ord = deg + 1L, sparse = TRUE)
  }
  B <- if (inherits(basis, "Matrix")) basis else Matrix::Matrix(basis, sparse = TRUE)
  ch <- Matrix::Cholesky(Matrix::crossprod(B), perm = FALSE, LDL = FALSE)
  structure(function(th) as.numeric(B %*% Matrix::solve(ch, Matrix::crossprod(B, th), system = "A")), q = ncol(B), poly = FALSE)
}
# The q schedule of the interweaving move: the projector cycles over a grid of q values, one per sweep (a fixed systematic scan of
# exact kernels, hence exact).  Grid entries are clamped to [k + 2, n / 4] (and >= degree + 1 of the splines) and deduplicated.
#   rule = "poly"  : q = k + 1 only (the original move)
#   rule = "auto"  : the default rule (calibrated in E-10, see engineering/E10_Lambda_Mixing)
#   rule = "n_prop": {n/50, n/25, n/12.5}           rule = "fixed": {10, 20, 40}
#   rule = "n16"   : {10, 20, 40} (n/500)^(1/6)      rule = "geo"  : {10, 20, 40, ...} doubling up to n/12.5
#   rule = <numeric vector>: that grid (clamped)
asis_q_grid <- function(n, order, rule = "auto") {
  if (identical(rule, "auto")) rule <- asis_q_default
  if (identical(rule, "poly")) return(order + 1L)
  g <- if (is.numeric(rule)) rule else switch(rule,
    n_prop = n / c(50, 25, 12.5),
    fixed  = c(10, 20, 40),
    n16    = c(10, 20, 40) * (n / 500)^(1 / 6),
    geo    = 10 * 2^(0:max(0, floor(log2(n / 12.5 / 10)))),
    stop("unknown asis q rule: ", rule))
  lo <- max(order + 2L, max(3L, order) + 1L); hi <- max(lo, floor(n / 4))
  unique(pmin(pmax(as.integer(round(g)), lo), hi))
}
asis_q_default <- "fixed"    # E-10 rule; placeholder until the calibration is read (engineering/E10_Lambda_Mixing/README.md)

# ---- Box pieces ----------------------------------------------------------------------------------------------------------
box_penalties <- function(a, d, c, gamma, rho = NULL, zeta_scale = 1)
  list(rho = if (is.null(rho)) 0.1 * (mean(d) + c) / gamma else rho, zeta = zeta_scale * (a + d / gamma))
in_box <- function(theta, lower, upper) all(theta >= lower & theta <= upper)

# T_B(x): bounded prox (returns the feasible point; $diag carries the solver diagnostics)
prox_box <- function(x, a, r, lambda, gamma, d, c, order, lower, upper, rho = NULL, zeta_scale = 1, iters = 200L, tol = 0, ctrl = box_ctrl) {
  pen <- box_penalties(a, d, c, gamma, rho, zeta_scale)
  prox_box_metric(x, a, r, lambda, gamma, d, c, order, pen$rho, pen$zeta, iters, tol, lower, upper, ctrl)
}
# Block 1 with a box: one P-MALA move on theta | z, lambda, sigma restricted to [lower, upper]
pmala_box_step <- function(theta, y, z, lambda, sigma, delta, cst, order, lower, upper, metric = "curv", c_fixed = 0,
                           rho = NULL, iters = 200L, mh = TRUE, kappa = 1, tol = 0, zeta_scale = 1, ctrl = box_ctrl) {
  gamma <- delta / 2
  a <- 1 / (cst$t2 * sigma * z); r <- y - cst$psi * z
  M <- metric_dc(metric, a, lambda, c_fixed, kappa); d <- M$d; c <- M$c
  pen <- box_penalties(a, d, c, gamma, rho, zeta_scale)
  if (!mh) {                                                                      # proximal ULA with support rejection (diagnostic)
    p    <- prox_box_metric(theta, a, r, lambda, gamma, d, c, order, pen$rho, pen$zeta, iters, tol, lower, upper, ctrl)$theta
    prop <- p + sqrt(delta) * minv_sqrt_noise(rnorm(length(theta)), d, c, order)
    ok <- in_box(prop, lower, upper)
    return(list(theta = if (ok) prop else theta, accept = ok, log_alpha = if (ok) 0 else -Inf, outside = !ok, ipm = NA))
  }
  mv <- pmala_box_move(theta, a, r, lambda, gamma, d, c, order, pen$rho, pen$zeta, iters, tol, rnorm(length(theta)), delta, lower, upper, ctrl)
  if (mv$outside) return(list(theta = theta, accept = FALSE, log_alpha = -Inf, outside = TRUE, ipm = mv$diag_fwd$outer))
  prop <- mv$prop
  log_alpha <- (U_cond(theta, a, r, lambda, order) - U_cond(prop, a, r, lambda, order)) + (mv$q_fwd - mv$q_rev) / (2 * delta)
  if (!is.finite(log_alpha)) log_alpha <- -Inf
  accept <- log(runif(1)) < log_alpha
  list(theta = if (accept) prop else theta, accept = accept, log_alpha = min(0, log_alpha), outside = FALSE,
       ipm = max(mv$diag_fwd$outer, mv$diag_rev$outer))
}
# Block 3b with a box: ASIS redraw of lambda along theta(lambda') = p + (lambda / lambda') v, restricted to theta(lambda') in [lower, upper].
# s = lambda / lambda' must satisfy lower_i <= p_i + s v_i <= upper_i for all i: an interval [s_lo, s_hi] in s, i.e. an interval in
# eta = log lambda'.  The slice sampler on eta assigns -Inf outside it (and re-checks the reconstructed curve); a degenerate
# interval leaves the state unchanged.  Same RNG call pattern as asis_step.
asis_scale_domain <- function(p, v, lower, upper) {
  lo <- 0; hi <- Inf
  for (i in seq_along(p)) {
    if (v[i] == 0) { if (p[i] < lower[i] || p[i] > upper[i]) return(c(Inf, -Inf)) }
    else { e <- sort(c((lower[i] - p[i]) / v[i], (upper[i] - p[i]) / v[i])); lo <- max(lo, e[1]); hi <- min(hi, e[2]) }
  }
  c(lo, hi)
}
asis_box_step <- function(theta, lambda, a, r, a0, b0, P, order, lower, upper, w = 1, max_steps = 30L, q_jac = attr(P, "q")) {
  th_par <- P(theta); th_perp <- theta - th_par; k <- order
  if (isTRUE(attr(P, "poly"))) { Dp <- 0; Dv <- 0 } else { Dp <- diff(th_par, differences = k + 1L); Dv <- diff(th_perp, differences = k + 1L) }
  dom <- asis_scale_domain(th_par, th_perp, lower, upper); unchanged <- list(lambda = lambda, theta = theta, moved = FALSE)
  if (!(dom[1] < dom[2]) || dom[2] <= 0) return(unchanged)
  eta0 <- log(lambda); eta_lo <- eta0 - log(dom[2]); eta_hi <- eta0 - log(dom[1])
  logf <- function(eta) {
    if (eta < eta_lo || eta > eta_hi) return(-Inf)
    lam <- exp(eta); th <- th_par + (lambda / lam) * th_perp
    if (!in_box(th, lower, upper)) return(-Inf)
    (a0 + q_jac - k - 1) * eta - b0 * lam - sum(abs(lam * Dp + lambda * Dv)) - sum(a * (th - r)^2) / 2
  }
  y0 <- logf(eta0) - rexp(1)
  if (!is.finite(y0)) return(unchanged)
  L <- eta0 - runif(1) * w; U <- L + w; j <- floor(runif(1) * max_steps); kk <- max_steps - 1 - j
  while (j > 0 && logf(L) > y0) { L <- L - w; j <- j - 1 }
  while (kk > 0 && logf(U) > y0) { U <- U + w; kk <- kk - 1 }
  repeat { eta1 <- L + runif(1) * (U - L)
    if (logf(eta1) > y0) break
    if (eta1 < eta0) L <- eta1 else U <- eta1
    if (U - L < 1e-10) return(unchanged) }
  lam1 <- exp(eta1)
  list(lambda = lam1, theta = as.numeric(th_par + (lambda / lam1) * th_perp), moved = TRUE)
}

# ---- Joint Gibbs sampler ---------------------------------------------------------------------------------------------------
gibbs_joint_pmala <- function(y, tau_list, order, a0, b0, a_sigma, b_sigma,
                              gibbs_iter, gibbs_burn, delta_init, lambda_init,
                              adapt_target, adapt_gain, adapt_kappa, delta_bounds,
                              metric = "curv", c_fixed = 0, rho = NULL, iters = 200L,
                              mh = TRUE, adapt = TRUE, warm = 0L, gamma_warm = 1e3,
                              kappa = 1, adapt_all = TRUE, K = 1L, asis = FALSE, tol = 0,
                              zeta_scale = 1, ctrl = box_ctrl, asis_q = "auto", verbose = TRUE, keep_every = 1L) {
  stopifnot(length(tau_list) >= 1, all(diff(tau_list) > 0), all(tau_list > 0 & tau_list < 1), warm <= gibbs_burn, gibbs_burn < gibbs_iter)
  n <- length(y); m <- n - order - 1L; J <- length(tau_list)
  q_grid <- asis_q_grid(n, order, asis_q)
  Ps <- if (asis) lapply(q_grid, function(q) asis_projector(n, q, order)) else NULL   # one per sweep, cycled (same at every level)
  cst <- lapply(tau_list, ald_const)
  # init: theta_j = y + s_y (Phi^-1(tau_j) - median Phi^-1(tau)) for J > 1 (ordered, data-based, no RNG); exactly y for J = 1.
  # Hyperparameters at the individual script's data-free defaults: sigma = 1, z = sigma, lambda = m (one unit of penalty per difference).
  off <- if (J == 1) 0 else max(sd(y), 0.1) * (qnorm(tau_list) - median(qnorm(tau_list)))
  theta <- sapply(off, function(o) y + o); if (!is.matrix(theta)) theta <- matrix(theta, n, J)
  sigma <- rep(1, J); z <- matrix(1, n, J); lambda <- rep(if (is.null(lambda_init)) m else lambda_init, J); delta <- rep(delta_init, J)
  keep <- length(seq(gibbs_burn + 1L, gibbs_iter, by = keep_every))
  theta_s <- array(NA_real_, c(keep, n, J)); kept <- 0L
  lambda_s <- sigma_s <- delta_s <- acc_s <- SD_s <- out_s <- ipm_s <- asis_s <- matrix(NA_real_, gibbs_iter, J)
  n_acc <- numeric(J)
  t0 <- proc.time()[["elapsed"]]
  for (it in seq_len(gibbs_iter)) {
    for (j in seq_len(J)) {
      lower <- if (j > 1L) theta[, j - 1L] else rep(-Inf, n)                  # already updated in this sweep
      upper <- if (j < J)  theta[, j + 1L] else rep(Inf, n)                   # previous sweep
      free <- (J == 1L)
      th <- theta[, j]; zj <- z[, j]; sg <- sigma[j]; lam <- lambda[j]; dl <- delta[j]; cs <- cst[[j]]
      if (it <= warm) {                                                        # warm start: optimisation step only (conditional MAP in the box)
        a <- 1 / (cs$t2 * sg * zj); r <- y - cs$psi * zj
        th <- if (free) prox_T(th, a, r, lam, gamma_warm, a, 0, order, rho = median(a), iters = 2L * iters)
              else prox_box(th, a, r, lam, gamma_warm, a, 0, order, lower, upper, rho = median(a), zeta_scale = zeta_scale, iters = 2L * iters, ctrl = ctrl)$theta
        st <- list(theta = th, accept = NA, log_alpha = NA, outside = NA, ipm = NA)
      } else {                                                                 # Block 1: K P-MALA moves at fixed (z, lambda, sigma, box)
        acc_k <- la_k <- out_k <- ipm_k <- numeric(K)
        for (kk in seq_len(K)) {
          st <- if (free) c(pmala_step(th, y, zj, lam, sg, dl, cs, order, metric, c_fixed, rho, iters, mh, kappa, tol), list(outside = FALSE, ipm = 0))
                else pmala_box_step(th, y, zj, lam, sg, dl, cs, order, lower, upper, metric, c_fixed, rho, iters, mh, kappa, tol, zeta_scale, ctrl)
          th <- st$theta; acc_k[kk] <- st$accept; la_k[kk] <- exp(st$log_alpha); out_k[kk] <- st$outside; ipm_k[kk] <- st$ipm
        }
        st <- list(theta = th, accept = mean(acc_k), log_alpha = log(mean(la_k)), outside = mean(out_k), ipm = mean(ipm_k))
      }
      n_acc[j] <- n_acc[j] + if (is.na(st$accept)) 0 else st$accept
      zj  <- draw_z(y - th, tau_list[j], sg)                                   # Block 2
      SD  <- sum(abs(Dtheta(th, order)))
      lam <- rgamma(1, shape = a0 + m, rate = b0 + SD)                         # Block 3 (sufficient parameterisation)
      moved <- NA
      if (asis && it > warm) {                                                 # Block 3b: ancillary redraw (restricted to the box), theta rescales
        a_ <- 1 / (cs$t2 * sg * zj); r_ <- y - cs$psi * zj
        Pit <- Ps[[(it - 1L) %% length(Ps) + 1L]]
        as_ <- if (free) asis_step(th, lam, a_, r_, a0, b0, Pit, order) else asis_box_step(th, lam, a_, r_, a0, b0, Pit, order, lower, upper)
        moved <- if (free) TRUE else as_$moved
        lam <- as_$lambda; th <- as_$theta; SD <- sum(abs(Dtheta(th, order)))
      }
      sg <- draw_sigma(y, th, zj, cs, a_sigma, b_sigma, lambda_SD = 0, m = 0)   # Block 4
      if (adapt && it > warm && (adapt_all || it <= gibbs_burn)) {              # adapt delta_j (diminishing gain)
        dl <- exp(log(dl) + adapt_gain * it^(-adapt_kappa) * (exp(st$log_alpha) - adapt_target))
        dl <- min(max(dl, delta_bounds[1]), delta_bounds[2])
      }
      if (!is.finite(sg) || !is.finite(lam) || !all(is.finite(th)))
        stop(sprintf("non-finite state at sweep %d, level %d: sigma %g lambda %g", it, j, sg, lam))
      if (!in_box(th, lower, upper)) stop(sprintf("ordering violated at sweep %d, level %d (max violation %.3e)", it, j, max(lower - th, th - upper)))
      theta[, j] <- th; z[, j] <- zj; sigma[j] <- sg; lambda[j] <- lam; delta[j] <- dl
      lambda_s[it, j] <- lam; sigma_s[it, j] <- sg; delta_s[it, j] <- dl; acc_s[it, j] <- st$accept; SD_s[it, j] <- SD
      out_s[it, j] <- st$outside; ipm_s[it, j] <- st$ipm; asis_s[it, j] <- moved
    }
    if (it > gibbs_burn && (it - gibbs_burn - 1L) %% keep_every == 0L) { kept <- kept + 1L; theta_s[kept, , ] <- theta }
    if (verbose && it %% 500 == 0)
      cat(sprintf("it %5d | acc %s | out %s | delta %s | lambda %s | sigma %s | %.0fs\n", it,
                  paste(sprintf("%.3f", n_acc / it), collapse = "/"), paste(sprintf("%.3f", colMeans(out_s[seq_len(it), , drop = FALSE], na.rm = TRUE)), collapse = "/"),
                  paste(sprintf("%.2e", delta), collapse = "/"), paste(sprintf("%.1f", lambda), collapse = "/"), paste(sprintf("%.4f", sigma), collapse = "/"),
                  proc.time()[["elapsed"]] - t0))
  }
  post <- (gibbs_burn + 1):gibbs_iter
  list(tau = tau_list, theta = theta_s, lambda = lambda_s, sigma = sigma_s, delta = delta_s, acc = acc_s, SD = SD_s, outside = out_s, ipm = ipm_s, asis_moved = asis_s,
       acc_post = colMeans(acc_s[post, , drop = FALSE]), outside_post = colMeans(out_s[post, , drop = FALSE]),
       ipm_post = colMeans(ipm_s[post, , drop = FALSE], na.rm = TRUE), asis_moved_post = colMeans(asis_s[post, , drop = FALSE], na.rm = TRUE),
       delta_final = delta, final = list(theta = theta, z = z, sigma = sigma, lambda = lambda), asis_q_grid = if (asis) q_grid else NULL,
       seconds = proc.time()[["elapsed"]] - t0)
}

# ---- Crossing metrics ------------------------------------------------------------------------------------------------------
# est: n x J matrix of point estimates; draws: keep x n x J array.  "Crossing" at index i between levels j < j' means est[i, j] > est[i, j'].
crossing_metrics <- function(est, draws = NULL) {
  J <- ncol(est); pairs <- if (J > 1) combn(J, 2) else matrix(integer(0), 2, 0)
  adj <- data.frame(); allp <- data.frame()
  for (q in seq_len(ncol(pairs))) {
    j1 <- pairs[1, q]; j2 <- pairs[2, q]; v <- est[, j1] - est[, j2]
    row <- data.frame(j1 = j1, j2 = j2, n_cross = sum(v > 0), frac_cross = mean(v > 0), max_violation = max(0, max(v)), n_ties = sum(v == 0))
    if (!is.null(draws)) { dv <- draws[, , j1] - draws[, , j2]; row$draws_any_cross = mean(apply(dv > 0, 1, any)); row$draws_max_violation = max(0, max(dv)) }
    allp <- rbind(allp, row); if (j2 == j1 + 1L) adj <- rbind(adj, row)
  }
  list(adjacent = adj, all_pairs = allp)
}

# ---- Independent reference: the same bounded problem as a QP, solved by Clarabel (interior point, tight tolerances) --------
# variables (theta, t), t >= |D theta| by two linear constraints, box rows for the finite bounds only.
ref_box_prox <- function(x, a, r, lambda, gamma, d, c, order, lower, upper, tol = 1e-10) {
  suppressWarnings(requireNamespace("clarabel", quietly = TRUE)); requireNamespace("Matrix", quietly = TRUE)
  n <- length(x); p <- order + 1L; m <- n - p
  Dm  <- Matrix::Matrix(diff(diag(n), differences = p), sparse = TRUE)
  DtD <- Matrix::crossprod(Dm)
  P   <- Matrix::Diagonal(n, a + d / gamma) + (c / gamma) * DtD
  qth <- -(a * r + (d * x + c * as.numeric(DtD %*% x)) / gamma)
  Pf  <- Matrix::bdiag(P, Matrix::Matrix(0, m, m, sparse = TRUE)); qf <- c(qth, rep(lambda, m))
  Im  <- Matrix::Diagonal(m)
  A1 <- cbind(Dm, -Im); A2 <- cbind(-Dm, -Im)
  iu <- which(is.finite(upper)); il <- which(is.finite(lower))
  Au <- Matrix::sparseMatrix(i = seq_along(iu), j = iu, x = rep(1, length(iu)), dims = c(length(iu), n + m))
  Al <- Matrix::sparseMatrix(i = seq_along(il), j = il, x = rep(-1, length(il)), dims = c(length(il), n + m))
  A  <- rbind(A1, A2, Au, Al); b <- c(rep(0, 2 * m), upper[iu], -lower[il])
  s  <- clarabel::clarabel(A = methods::as(A, "CsparseMatrix"), b = b, q = qf, P = methods::as(Pf, "CsparseMatrix"),
                           cones = list(l = nrow(A)),
                           control = clarabel::clarabel_control(verbose = FALSE, tol_gap_abs = tol, tol_gap_rel = tol, tol_feas = tol,
                                                                max_iter = 500L))
  list(theta = pmin(pmax(s$x[seq_len(n)], lower), upper), status = s$status, r_prim = s$r_prim, r_dual = s$r_dual, iterations = s$iterations)
}
# convergence flag of a method-1 solve (the kernel's own theta-unit criteria; TRUE on the unbounded fast path)
ipm_converged <- function(s, ...) isTRUE(s$diag$converged == 1)

# ---- Optimisation-kernel tests -------------------------------------------------------------------------------------------
run_prox_tests <- function(ctrl = box_ctrl) {
  t_start <- proc.time()[["elapsed"]]
  rel_gap <- function(f, fref) (f - fref) / (1 + abs(fref))
  tight <- c(1, 1, 300, 1e-12)                                                   # our own tight reference (theta accuracy 1e-12)
  cat(sprintf("ctrl = method %g, try_unbounded %g, ipm_max_iter %g, ipm_tol %g\n", ctrl[1], ctrl[2], ctrl[3], ctrl[4]))

  cat("== P1: free box -> bitwise the unbounded kernel (method 1 fast path, and method 0 with zeta = 0) ==\n")
  set.seed(1); nn <- 120; ord <- 2L; lam <- 40; gam <- 0.05
  a <- rexp(nn) * 20 + 1; r <- sin(seq_len(nn) / 15) + rnorm(nn, 0, .2); x <- r + rnorm(nn, 0, .3); d <- a; cc <- 1.5 * lam^2
  rho <- 0.1 * (mean(d) + cc) / gam; inf_lo <- rep(-Inf, nn); inf_up <- rep(Inf, nn)
  p_u <- prox_admm_metric(x, a, r, lam, gam, d, cc, ord, rho, 150L, 0)
  p_1 <- prox_box_metric(x, a, r, lam, gam, d, cc, ord, rho, rep(0, nn), 150L, 0, inf_lo, inf_up, ctrl)
  p_0 <- prox_box_metric(x, a, r, lam, gam, d, cc, ord, rho, rep(0, nn), 150L, 0, inf_lo, inf_up, c(0, 1, 0))
  p_w <- prox_box_metric(x, a, r, lam, gam, d, cc, ord, rho, rep(0, nn), 150L, 0, p_u - 1, p_u + 1, ctrl)   # wide box containing T(x)
  cat(sprintf("   method 1: %.1e (ipm used %d) | method 0 (zeta = 0): %.1e | wide box: %.1e (ipm used %d)\n",
              max(abs(p_1$theta - p_u)), p_1$diag$outer, max(abs(p_0$theta - p_u)), max(abs(p_w$theta - p_u)), p_w$diag$outer))
  stopifnot(identical(p_1$theta, p_u), identical(p_0$theta, p_u), identical(p_w$theta, p_u), p_1$diag$outer == 0, p_w$diag$outer == 0)

  cat("== P2: lambda = 0, c = 0 -> closed form clip((a r + d x/gamma)/(a + d/gamma), L, U) ==\n")
  set.seed(2); lo <- x - 0.2 * runif(nn); up <- x + 0.2 * runif(nn); lo[1:10] <- -Inf; up[20:30] <- Inf; lo[50] <- up[50] <- x[50]
  cf <- pmin(pmax((a * r + d * x / gam) / (a + d / gam), lo), up)
  pen <- box_penalties(a, d, 0, gam)
  p0 <- prox_box_metric(x, a, r, 0, gam, d, 0, ord, pen$rho, pen$zeta, 150L, 0, lo, up, ctrl)
  cat(sprintf("   max |IPM - closed form| = %.1e | max box violation = %.1e | ipm iters %d | active %d/%d\n",
              max(abs(p0$theta - cf)), p0$diag$max_viol, p0$diag$iters, p0$diag$n_active, nn))
  stopifnot(max(abs(p0$theta - cf)) < 1e-7, p0$diag$max_viol == 0, p0$theta[50] == x[50])

  cat("== P3: determinism, exact feasibility, degenerate coordinates, one-sided and tight boxes ==\n")
  set.seed(3); lo <- x - 0.1; up <- x + 0.1; lo[5:15] <- -Inf; up[60:70] <- Inf; lo[80] <- up[80] <- x[80] + 0.05; lo[90:95] <- up[90:95] <- x[90:95]
  pen <- box_penalties(a, d, cc, gam)
  q1 <- prox_box_metric(x, a, r, lam, gam, d, cc, ord, pen$rho, pen$zeta, 150L, 0, lo, up, ctrl)
  q2 <- prox_box_metric(x, a, r, lam, gam, d, cc, ord, pen$rho, pen$zeta, 150L, 0, lo, up, ctrl)
  ref <- ref_box_prox(x, a, r, lam, gam, d, cc, ord, lo, up)
  f1 <- q1$diag$obj; fr <- box_objective(ref$theta, x, a, r, lam, gam, d, cc, ord, lo, up)
  cat(sprintf("   identical repeat: %s | viol %.1e | pinned exact: %s | active %d/%d | ipm iters %d | converged %s | err vs clarabel %.1e | rel gap %+.1e\n",
              identical(q1, q2), q1$diag$max_viol, all(q1$theta[c(80, 90:95)] == lo[c(80, 90:95)]), q1$diag$n_active, nn, q1$diag$iters,
              ipm_converged(q1, a, d, gam, lo, up), max(abs(q1$theta - ref$theta)), rel_gap(f1, fr)))
  stopifnot(identical(q1, q2), q1$diag$max_viol == 0, all(q1$theta[c(80, 90:95)] == lo[c(80, 90:95)]), rel_gap(f1, fr) < 1e-8)

  cat("== P4: 108 small random instances (orders 0-2, lambda 0.5-50, gamma 0.01-1, four box types) vs Clarabel and a tight self-reference ==\n")
  set.seed(4); worst <- data.frame()
  for (ord_ in 0:2) for (lam_ in c(0.5, 5, 50)) for (gam_ in c(0.01, 0.1, 1)) for (box in c("two", "one", "degen", "tight")) {
    nn_ <- 60; a_ <- rexp(nn_) * 5 + 0.5; r_ <- cumsum(rnorm(nn_, 0, .3)); x_ <- r_ + rnorm(nn_, 0, .3); d_ <- a_; c_ <- 1.5 * lam_^2
    lo_ <- switch(box, two = x_ - 0.3 * runif(nn_), one = rep(-Inf, nn_), degen = x_ - 0.3 * runif(nn_), tight = x_ - 0.02 * runif(nn_))
    up_ <- switch(box, two = x_ + 0.3 * runif(nn_), one = x_ + 0.2 * runif(nn_), degen = x_ + 0.3 * runif(nn_), tight = x_ + 0.02 * runif(nn_))
    if (box == "degen") { idx <- sample(nn_, 8); lo_[idx] <- up_[idx] <- x_[idx] + 0.05 }
    pen_ <- box_penalties(a_, d_, c_, gam_)
    cl <- ref_box_prox(x_, a_, r_, lam_, gam_, d_, c_, ord_, lo_, up_); f_cl <- box_objective(cl$theta, x_, a_, r_, lam_, gam_, d_, c_, ord_, lo_, up_)
    tg <- prox_box_metric(x_, a_, r_, lam_, gam_, d_, c_, ord_, pen_$rho, pen_$zeta, 150L, 0, lo_, up_, tight)
    s  <- prox_box_metric(x_, a_, r_, lam_, gam_, d_, c_, ord_, pen_$rho, pen_$zeta, 150L, 0, lo_, up_, ctrl)
    worst <- rbind(worst, data.frame(order = ord_, lambda = lam_, gamma = gam_, box = box, clarabel_status = cl$status,
      gap_vs_clarabel = rel_gap(s$diag$obj, f_cl), err_vs_tight = max(abs(s$theta - tg$theta)), gap_vs_tight = rel_gap(s$diag$obj, tg$diag$obj),
      tight_gap_vs_clarabel = rel_gap(tg$diag$obj, f_cl), ipm_used = s$diag$outer, ipm_iters = s$diag$iters,
      converged = ipm_converged(s, a_, d_, gam_, lo_, up_), active = mean(cl$theta <= lo_ + 1e-9 | cl$theta >= up_ - 1e-9)))
  }
  cat(sprintf("   Clarabel solved %d/108 | IPM used in %d | converged %d | max err vs tight ref %.1e | max rel gap vs tight %.1e | max rel gap vs Clarabel %+.1e (tight ref: %+.1e) | ipm iters max %d\n",
              sum(worst$clarabel_status == 2), sum(worst$ipm_used), sum(worst$converged), max(worst$err_vs_tight), max(worst$gap_vs_tight),
              max(worst$gap_vs_clarabel), max(worst$tight_gap_vs_clarabel), max(worst$ipm_iters[worst$ipm_used == 1])))
  print(aggregate(cbind(err_vs_tight, gap_vs_clarabel, ipm_iters) ~ box + order, worst, max), digits = 3)
  stopifnot(max(worst$err_vs_tight) < 1e-6, max(worst$gap_vs_clarabel) < 1e-8, all(worst$ipm_iters[worst$ipm_used == 1] < 100))

  cat("== P5: perturbation test -- feasible random perturbations of the solution raise the objective ==\n")
  set.seed(5); nn_ <- 80; ord_ <- 2L; lam_ <- 10; gam_ <- .05; a_ <- rexp(nn_) * 5 + .5; r_ <- cumsum(rnorm(nn_, 0, .3)); x_ <- r_ + rnorm(nn_, 0, .3)
  d_ <- a_; c_ <- 1.5 * lam_^2; lo_ <- x_ - .1 * runif(nn_); up_ <- x_ + .1 * runif(nn_); pen_ <- box_penalties(a_, d_, c_, gam_)
  sol <- prox_box_metric(x_, a_, r_, lam_, gam_, d_, c_, ord_, pen_$rho, pen_$zeta, 150L, 0, lo_, up_, ctrl)
  f0 <- sol$diag$obj
  worse <- replicate(500, { th <- pmin(pmax(sol$theta + rnorm(nn_, 0, 1e-4), lo_), up_); box_objective(th, x_, a_, r_, lam_, gam_, d_, c_, ord_, lo_, up_) > f0 })
  cat(sprintf("   perturbations with larger objective: %d / 500 (ipm used %d, active %d/%d)\n", sum(worse), sol$diag$outer, sol$diag$n_active, nn_))
  stopifnot(all(worse))

  cat("== P6: realistic sampler fixtures (n = 500, k = 2, VS Normal data, augmented weights, neighbour-curve boxes) ==\n")
  dat <- simulate_data(1, 500L, c(0.75, 0.95), "VS", "Normal"); nn_ <- 500L; ord_ <- 2L
  fit0 <- as.numeric(glmgen::trendfilter(seq_len(nn_), dat$y, k = ord_, lambda = 30, thinning = FALSE)$beta[, 1])
  res6 <- data.frame(); set.seed(6)
  for (tau_ in c(0.75, 0.95)) for (lam_ in c(100, 1000, 5000)) for (delta_ in c(0.02, 0.1, 0.5)) for (box in c("lower", "both", "tight", "degen")) {
    cst <- ald_const(tau_); sg <- 0.3; th0 <- fit0 + if (tau_ == 0.95) 0.3 else 0.1
    zz <- pmin(pmax(rexp(nn_, 1 / sg), 1e-8), 1e4); a_ <- 1 / (cst$t2 * sg * zz); r_ <- dat$y - cst$psi * zz
    gam_ <- delta_ / 2; M <- metric_dc("curv", a_, lam_, 0, 3); pen_ <- box_penalties(a_, M$d, M$c, gam_)
    lo_ <- switch(box, lower = th0 - 0.06 + 0.05 * sin(seq_len(nn_) / 25), both = th0 - 0.06 + 0.05 * sin(seq_len(nn_) / 25), tight = th0 - 1e-3, degen = th0 - 0.05)
    up_ <- switch(box, lower = rep(Inf, nn_), both = th0 + 0.06 + 0.05 * cos(seq_len(nn_) / 40), tight = th0 + 1e-3, degen = th0 + 0.05)
    if (box == "degen") { idx <- sample(nn_, 5); lo_[idx] <- up_[idx] <- th0[idx] }
    x_ <- pmin(pmax(th0 + rnorm(nn_, 0, 0.02), lo_), up_)
    cl <- ref_box_prox(x_, a_, r_, lam_, gam_, M$d, M$c, ord_, lo_, up_); f_cl <- box_objective(cl$theta, x_, a_, r_, lam_, gam_, M$d, M$c, ord_, lo_, up_)
    tg <- prox_box_metric(x_, a_, r_, lam_, gam_, M$d, M$c, ord_, pen_$rho, pen_$zeta, 150L, 0, lo_, up_, tight)
    t0 <- proc.time()[["elapsed"]]
    s  <- prox_box_metric(x_, a_, r_, lam_, gam_, M$d, M$c, ord_, pen_$rho, pen_$zeta, 150L, 0, lo_, up_, ctrl)
    ms <- 1000 * (proc.time()[["elapsed"]] - t0)
    noise_sd <- sqrt(delta_ / M$d)                                                     # per-coordinate proposal noise scale (diagonal part)
    res6 <- rbind(res6, data.frame(tau = tau_, lambda = lam_, delta = delta_, box = box, clarabel_status = cl$status, active = mean(cl$theta <= lo_ + 1e-9 | cl$theta >= up_ - 1e-9),
      err_vs_tight = max(abs(s$theta - tg$theta)), err_noise = max(abs(s$theta - tg$theta) / noise_sd), gap_vs_tight = rel_gap(s$diag$obj, tg$diag$obj),
      gap_vs_clarabel = rel_gap(s$diag$obj, f_cl), err_vs_clarabel = max(abs(s$theta - cl$theta)), ipm_used = s$diag$outer, ipm_iters = s$diag$iters,
      converged = ipm_converged(s, a_, M$d, gam_, lo_, up_), ms = ms))
  }
  print(res6[, c("tau", "lambda", "delta", "box", "active", "err_vs_tight", "err_noise", "gap_vs_clarabel", "err_vs_clarabel", "ipm_used", "ipm_iters", "converged", "ms")], digits = 3)
  cat(sprintf("   IPM used in %d/%d | converged %d | max err vs tight ref %.1e (%.1e of the noise sd) | max rel gap vs Clarabel %+.1e | ipm iters max %d, median %d | ms median %.0f, max %.0f\n",
              sum(res6$ipm_used), nrow(res6), sum(res6$converged), max(res6$err_vs_tight), max(res6$err_noise), max(res6$gap_vs_clarabel),
              max(res6$ipm_iters[res6$ipm_used == 1]), as.integer(median(res6$ipm_iters[res6$ipm_used == 1])), median(res6$ms), max(res6$ms)))
  stopifnot(all(res6$ipm_iters[res6$ipm_used == 1] < 100), max(res6$err_vs_tight) < 1e-7, max(res6$err_noise) < 1e-5, max(res6$gap_vs_clarabel) < 1e-8)

  cat("== P7: fused pmala_box_move = separate calls (bitwise), outside detection, and = pmala_move on a free box ==\n")
  set.seed(7); tau_ <- 0.9; cst <- ald_const(tau_); sg <- .3; lam_ <- 500; delta_ <- .1; gam_ <- delta_ / 2
  zz <- pmin(pmax(rexp(nn_, 1 / sg), 1e-8), 1e4); a_ <- 1 / (cst$t2 * sg * zz); r_ <- dat$y - cst$psi * zz
  M <- metric_dc("curv", a_, lam_, 0, 3); pen_ <- box_penalties(a_, M$d, M$c, gam_)
  th0 <- fit0 + 0.3; lo_ <- th0 - 0.03; up_ <- th0 + 0.03; xi <- rnorm(nn_)
  mv <- pmala_box_move(th0, a_, r_, lam_, gam_, M$d, M$c, ord_, pen_$rho, pen_$zeta, 150L, 0, xi, delta_, lo_, up_, ctrl)
  p1 <- prox_box_metric(th0, a_, r_, lam_, gam_, M$d, M$c, ord_, pen_$rho, pen_$zeta, 150L, 0, lo_, up_, ctrl)
  prop <- p1$theta + sqrt(delta_) * minv_sqrt_noise(xi, M$d, M$c, ord_)
  cat(sprintf("   forward ipm used %d | outside = %s | p %.1e | prop %.1e | q_fwd %.1e\n", p1$diag$outer, mv$outside, max(abs(mv$p - p1$theta)), max(abs(mv$prop - prop)),
              abs(mv$q_fwd - mnorm2(prop - p1$theta, M$d, M$c, ord_))))
  stopifnot(identical(mv$p, p1$theta), identical(mv$prop, prop), abs(mv$q_fwd - mnorm2(prop - p1$theta, M$d, M$c, ord_)) < 1e-9, mv$outside == !in_box(prop, lo_, up_))
  if (!mv$outside) {
    p2 <- prox_box_metric(prop, a_, r_, lam_, gam_, M$d, M$c, ord_, pen_$rho, pen_$zeta, 150L, 0, lo_, up_, ctrl)
    stopifnot(identical(mv$pstar, p2$theta), abs(mv$q_rev - mnorm2(th0 - p2$theta, M$d, M$c, ord_)) < 1e-9)
  } else stopifnot(all(is.na(mv$pstar)), is.na(mv$q_rev))
  mv2 <- pmala_box_move(th0, a_, r_, lam_, gam_, M$d, M$c, ord_, pen_$rho, pen_$zeta, 150L, 0, xi, delta_, rep(-Inf, nn_), p1$theta + 1e-9, ctrl)
  cat(sprintf("   tight upper bound just above T_B(theta): outside = %s, pstar NA = %s\n", mv2$outside, all(is.na(mv2$pstar))))
  stopifnot(mv2$outside, all(is.na(mv2$pstar)), is.na(mv2$q_rev))
  mv3 <- pmala_box_move(th0, a_, r_, lam_, gam_, M$d, M$c, ord_, pen_$rho, pen_$zeta, 150L, 0, xi, delta_, rep(-Inf, nn_), rep(Inf, nn_), ctrl)
  mv4 <- pmala_move(th0, a_, r_, lam_, gam_, M$d, M$c, ord_, pen_$rho, 150L, 0, xi, delta_)
  cat(sprintf("   free box vs pmala_move: prop %.1e, pstar %.1e, q_fwd %.1e, q_rev %.1e\n", max(abs(mv3$prop - mv4$prop)),
              max(abs(mv3$pstar - mv4$pstar)), abs(mv3$q_fwd - mv4$q_fwd), abs(mv3$q_rev - mv4$q_rev)))
  stopifnot(identical(mv3$prop, mv4$prop), identical(mv3$pstar, mv4$pstar), mv3$q_fwd == mv4$q_fwd, mv3$q_rev == mv4$q_rev)

  cat("== P8: deterministic under an early-exit tolerance of the unbounded step; IPM is deterministic across repeated calls ==\n")
  e1 <- prox_box_metric(th0, a_, r_, lam_, gam_, M$d, M$c, ord_, pen_$rho, pen_$zeta, 2000L, 1e-8, lo_, up_, ctrl)
  e2 <- prox_box_metric(th0, a_, r_, lam_, gam_, M$d, M$c, ord_, pen_$rho, pen_$zeta, 2000L, 1e-8, lo_, up_, ctrl)
  cat(sprintf("   identical repeat %s | ipm used %d | iters %d | err vs full-budget call %.1e\n", identical(e1, e2), e1$diag$outer, e1$diag$iters, max(abs(e1$theta - p1$theta))))
  stopifnot(identical(e1, e2))
  cat(sprintf("all optimisation-kernel tests passed (%.0f s)\n", proc.time()[["elapsed"]] - t_start))
  invisible(list(small = worst, realistic = res6))
}

# ---- Sampler tests ----------------------------------------------------------------------------------------------------------
run_tests <- function() {
  t_start <- proc.time()[["elapsed"]]
  bm_se <- function(v, nb = 50) { b <- floor(length(v) / nb); sd(colMeans(matrix(v[1:(b * nb)], b, nb))) / sqrt(nb) }

  cat("== T1: J = 1 reproduces the individual script's sampler (same seed -> identical trajectories and final RNG state) ==\n")
  ind <- new.env(); L <- readLines(file.path(individual_dir, "Individual_Sampler_PMALA_Augmented.R"))
  eval(parse(text = L[seq_len(grep("^# ---- Main", L)[1] - 1L)]), envir = ind)      # definitions only; its kernel loader is not called
  dat <- simulate_data(3, 80L, 0.1, "VS", "Normal")
  args_common <- list(y = dat$y, order = 2L, a0 = 1, b0 = 0.01, a_sigma = 0.1, b_sigma = 0.1, gibbs_iter = 400L, gibbs_burn = 200L,
                      delta_init = 0.2, lambda_init = NULL, adapt_target = 0.5, adapt_gain = 1, adapt_kappa = 0.6, delta_bounds = c(1e-8, 100),
                      metric = "curv", c_fixed = 0, rho = NULL, iters = 150L, mh = TRUE, adapt = TRUE, warm = 30L, gamma_warm = 1e4,
                      kappa = 3, adapt_all = TRUE, K = 1L, asis = TRUE, tol = 0, verbose = FALSE)
  set.seed(11); f_ind <- do.call(ind$gibbs_pmala_aug, c(args_common, list(tau = 0.1, control = NULL, init = "y", prior_scale = "none", cmap = FALSE)))
  rng_ind <- .Random.seed
  set.seed(11); f_jnt <- do.call(gibbs_joint_pmala, c(args_common, list(tau_list = 0.1)))
  rng_jnt <- .Random.seed
  cat(sprintf("   theta %.1e | lambda %.1e | sigma %.1e | delta %.1e | acc %.1e | RNG identical %s\n",
              max(abs(f_ind$theta - f_jnt$theta[, , 1])), max(abs(f_ind$lambda - f_jnt$lambda[, 1])), max(abs(f_ind$sigma - f_jnt$sigma[, 1])),
              max(abs(f_ind$delta - f_jnt$delta[, 1])), max(abs(f_ind$acc[-(1:30)] - f_jnt$acc[-(1:30), 1])), identical(rng_ind, rng_jnt)))
  stopifnot(identical(f_ind$theta, f_jnt$theta[, , 1]), identical(f_ind$lambda, f_jnt$lambda[, 1]), identical(f_ind$sigma, f_jnt$sigma[, 1]), identical(rng_ind, rng_jnt))

  cat("== T2: box P-MALA kernel vs grid integration of exp(-U) 1_B at n = 4 (curvature metric, kappa = 3) ==\n")
  set.seed(12); nn <- 4; ord <- 0L; lam <- 2; sg <- 0.5; tt <- 0.3; cst <- ald_const(tt)
  yy <- cumsum(rnorm(nn, 0, 0.3)); zz <- rexp(nn, 1 / sg); a <- 1 / (cst$t2 * sg * zz); r <- yy - cst$psi * zz
  lo <- r - 0.6 / sqrt(a); up <- r + c(0.4, 0.2, 0.3, 0.1) / sqrt(a)                   # box that cuts into the bulk of the conditional
  # midpoint-cell grid (80 cells per axis): an endpoint grid overweights the box edges of the truncated density by ~1% in sd
  ax <- lapply(seq_len(nn), function(i) { h <- (up[i] - lo[i]) / 80; seq(lo[i] + h / 2, up[i] - h / 2, length.out = 80L) }); G <- as.matrix(expand.grid(ax))
  lp <- -(G - rep(r, each = nrow(G)))^2 %*% (a / 2) - lam * rowSums(abs(G[, -1] - G[, -nn]))
  wgt <- exp(lp - max(lp)); wgt <- as.vector(wgt / sum(wgt))
  m_ex <- colSums(G * wgt); s_ex <- sqrt(colSums(G^2 * wgt) - m_ex^2)
  th <- pmin(pmax(r, lo), up); M2 <- 60000L; S <- matrix(NA, M2, nn); acc <- 0; outc <- 0
  for (i in seq_len(M2)) {
    st <- pmala_box_step(th, yy, zz, lam, sg, 0.5, cst, ord, lo, up, "curv", 0, iters = 150L, kappa = 3); th <- st$theta; acc <- acc + st$accept; outc <- outc + st$outside
    S[i, ] <- th
  }
  S1 <- S[-(1:5000), ]; m1 <- colMeans(S1); se1 <- apply(S1, 2, bm_se); s1 <- apply(S1, 2, sd)
  se_s1 <- apply(S1, 2, function(v) bm_se((v - mean(v))^2)) / (2 * s1)
  cat(sprintf("   acc %.2f | outside %.2f | all draws in box %s | max |mean z| = %.2f | max |sd z| = %.2f | max |sd ratio - 1| = %.3f\n",
              acc / M2, outc / M2, all(S >= rep(lo, each = M2) & S <= rep(up, each = M2)), max(abs(m1 - m_ex) / se1), max(abs(s1 - s_ex) / se_s1), max(abs(s1 / s_ex - 1))))
  stopifnot(all(S >= rep(lo, each = M2) & S <= rep(up, each = M2)), max(abs(m1 - m_ex) / se1) < 4, max(abs(s1 - s_ex) / se_s1) < 4)

  cat("== T3: box P-MALA + conjugate lambda + constrained ASIS vs grid integration of the lambda-marginalised target on the box ==\n")
  set.seed(13); mm <- nn - 1; a0_ <- 1; b0_ <- 0.5
  SDg <- rowSums(abs(G[, -1] - G[, -nn]))
  lp <- -(G - rep(r, each = nrow(G)))^2 %*% (a / 2) - (mm + a0_) * log(b0_ + SDg)
  wgt <- exp(lp - max(lp)); wgt <- as.vector(wgt / sum(wgt))
  m_ex <- colSums(G * wgt); s_ex <- sqrt(colSums(G^2 * wgt) - m_ex^2); lam_ex <- sum(wgt * (mm + a0_) / (b0_ + SDg))
  P1 <- asis_projector(nn, ord + 1L, ord); th <- pmin(pmax(r, lo), up); lam <- 2; M2 <- 80000L; S <- matrix(NA, M2, nn); Lm <- numeric(M2); acc <- 0; mv <- 0
  for (i in seq_len(M2)) {
    st <- pmala_box_step(th, yy, zz, lam, sg, 0.5, cst, ord, lo, up, "curv", 0, iters = 150L, kappa = 3); th <- st$theta; acc <- acc + st$accept
    lam <- rgamma(1, a0_ + mm, b0_ + sum(abs(diff(th))))
    as_ <- asis_box_step(th, lam, a, r, a0_, b0_, P1, ord, lo, up); lam <- as_$lambda; th <- as_$theta; mv <- mv + as_$moved
    S[i, ] <- th; Lm[i] <- lam
  }
  S1 <- S[-(1:5000), ]; L1 <- Lm[-(1:5000)]
  m1 <- colMeans(S1); se1 <- apply(S1, 2, bm_se); s1 <- apply(S1, 2, sd)
  se_s1 <- apply(S1, 2, function(v) bm_se((v - mean(v))^2)) / (2 * s1)
  cat(sprintf("   acc %.2f | asis moved %.2f | all in box %s | max |mean z| = %.2f | max |sd z| = %.2f | E lambda: chain %.3f (se %.3f) vs exact %.3f\n",
              acc / M2, mv / M2, all(S >= rep(lo, each = M2) & S <= rep(up, each = M2)), max(abs(m1 - m_ex) / se1), max(abs(s1 - s_ex) / se_s1), mean(L1), bm_se(L1), lam_ex))
  stopifnot(all(S >= rep(lo, each = M2) & S <= rep(up, each = M2)), max(abs(m1 - m_ex) / se1) < 4, max(abs(s1 - s_ex) / se_s1) < 4, abs(mean(L1) - lam_ex) / bm_se(L1) < 4)

  cat("== T3b: constrained generalised ASIS (enlarged held-fixed subspace) vs the same box reference; a wrong Jacobian must fail ==\n")
  bump <- cbind(1, c(0, 1, 0.5, 0), c(0.2, 0, 1, 0.3))      # 3-dim subspace of R^4 containing the constants (null(D), k = 0)
  Pg <- asis_projector(nn, NA, ord, basis = bump)
  for (qj in c(3, 1)) {
    set.seed(200 + qj); th <- pmin(pmax(r, lo), up); lam <- 2; S <- matrix(NA, M2, nn); Lm <- numeric(M2); mv <- 0
    for (i in seq_len(M2)) {
      st <- pmala_box_step(th, yy, zz, lam, sg, 0.5, cst, ord, lo, up, "curv", 0, iters = 150L, kappa = 3); th <- st$theta
      lam <- rgamma(1, a0_ + mm, b0_ + sum(abs(diff(th))))
      as_ <- asis_box_step(th, lam, a, r, a0_, b0_, Pg, ord, lo, up, q_jac = qj); lam <- as_$lambda; th <- as_$theta; mv <- mv + as_$moved
      S[i, ] <- th; Lm[i] <- lam
    }
    S1 <- S[-(1:5000), ]; L1 <- Lm[-(1:5000)]
    m1 <- colMeans(S1); se1 <- apply(S1, 2, bm_se); s1 <- apply(S1, 2, sd)
    se_s1 <- apply(S1, 2, function(v) bm_se((v - mean(v))^2)) / (2 * s1)
    zz_ <- c(max(abs(m1 - m_ex) / se1), max(abs(s1 - s_ex) / se_s1), abs(mean(L1) - lam_ex) / bm_se(L1)); right <- qj == 3
    cat(sprintf("   q = 3, Jacobian q = %d (%s) | asis moved %.2f | all in box %s | max |mean z| %.2f | max |sd z| %.2f | E lambda z %.2f\n",
                qj, if (right) "correct" else "WRONG", mv / M2, all(S >= rep(lo, each = M2) & S <= rep(up, each = M2)), zz_[1], zz_[2], zz_[3]))
    stopifnot(all(S >= rep(lo, each = M2) & S <= rep(up, each = M2)))
    if (right) stopifnot(max(zz_) < 4) else stopifnot(max(zz_) > 8)
  }

  cat("== T4: short joint run (n = 80, three levels): ordering holds in every kept draw; movement and solver usage reported ==\n")
  dat <- simulate_data(5, 80L, c(0.5, 0.9, 0.95), "VS", "Normal")
  set.seed(14)
  fit <- gibbs_joint_pmala(dat$y, c(0.5, 0.9, 0.95), 2L, 1, 0.01, 0.1, 0.1, 600L, 300L, 0.2, NULL, 0.5, 1, 0.6, c(1e-8, 100),
                           metric = "curv", c_fixed = 0, rho = NULL, iters = 150L, mh = TRUE, adapt = TRUE, warm = 30L, gamma_warm = 1e4,
                           kappa = 3, adapt_all = TRUE, K = 1L, asis = TRUE, tol = 0, verbose = FALSE)
  est <- apply(fit$theta, c(2, 3), mean); cm <- crossing_metrics(est, fit$theta)
  cat(sprintf("   acc %s | outside %s | ipm share %s | asis moved %s | draws with any adjacent crossing %s | max draw violation %.1e | mean-curve crossings %s\n",
              paste(sprintf("%.2f", fit$acc_post), collapse = "/"), paste(sprintf("%.2f", fit$outside_post), collapse = "/"), paste(sprintf("%.2f", fit$ipm_post), collapse = "/"),
              paste(sprintf("%.2f", fit$asis_moved_post), collapse = "/"), paste(cm$adjacent$draws_any_cross, collapse = "/"), max(cm$adjacent$draws_max_violation), paste(cm$adjacent$n_cross, collapse = "/")))
  stopifnot(all(cm$adjacent$draws_any_cross == 0), all(cm$all_pairs$n_cross == 0), all(fit$acc_post > 0))
  cat(sprintf("all sampler tests passed (%.0f s)\n", proc.time()[["elapsed"]] - t_start))
}

# ---- Main --------------------------------------------------------------------------------------------------------------------
args <- commandArgs(trailingOnly = TRUE)
if (length(args) && args[1] == "test_prox") { load_box_cpp(); run_prox_tests(); quit(save = "no") }
if (length(args) && args[1] == "test")      { load_box_cpp(); run_prox_tests(); run_tests(); quit(save = "no") }

load_box_cpp()
stopifnot(target_quantile %in% tau_list, all(diff(tau_list) > 0))
J <- length(tau_list); jt <- match(target_quantile, tau_list)
dat <- simulate_data(seed, n, tau_list, baseline_id, noise_id)
set.seed(seed + 1000)
fit <- gibbs_joint_pmala(dat$y, tau_list, order, a0, b0, a_sigma, b_sigma,
                         gibbs_iter, gibbs_burn, delta_init, lambda_init,
                         adapt_target, adapt_gain, adapt_kappa, delta_bounds,
                         metric = metric, c_fixed = c_metric, rho = admm_rho, iters = admm_iter,
                         mh = mh_correct, adapt = adapt_delta, warm = warm_sweeps, gamma_warm = gamma_warm,
                         kappa = kappa_metric, adapt_all = adapt_all, K = K_theta, asis = asis_lambda, tol = admm_tol,
                         zeta_scale = zeta_scale, ctrl = box_ctrl, asis_q = asis_q)

est <- apply(fit$theta, c(2, 3), mean)
lo  <- apply(fit$theta, c(2, 3), quantile, 0.025); hi <- apply(fit$theta, c(2, 3), quantile, 0.975)
post <- (gibbs_burn + 1):gibbs_iter
res <- data.frame(baseline = baseline_id, noise = noise_id, n = n, seed = seed, tau = tau_list, target = tau_list == target_quantile,
  mse = colMeans((est - dat$truth)^2), mad = colMeans(abs(est - dat$truth)), mciw = colMeans(hi - lo),
  coverage = colMeans(dat$truth >= lo & dat$truth <= hi),
  paper_individual_mse = vapply(tau_list, function(t) { v <- paper_mse[[baseline_id]][[noise_id]]; if (is.null(v)) NA_real_ else unname(v[as.character(t)]) %||% NA_real_ }, numeric(1)),
  acc_post = fit$acc_post, outside_rate = fit$outside_post, ipm_share = fit$ipm_post, asis_moved = fit$asis_moved_post, delta_final = fit$delta_final,
  lambda_mean = colMeans(fit$lambda[post, , drop = FALSE]), sigma_mean = colMeans(fit$sigma[post, , drop = FALSE]),
  gibbs_iter = gibbs_iter, gibbs_burn = gibbs_burn, b0 = b0, kappa = kappa_metric, admm_iter = admm_iter, seconds = fit$seconds)
res$mse_ratio_to_paper <- res$mse / res$paper_individual_mse
cm <- crossing_metrics(est, fit$theta)
cat("\n==== per-quantile results ====\n"); print(res[, c("tau", "target", "mse", "paper_individual_mse", "mse_ratio_to_paper", "mad", "mciw", "coverage", "acc_post", "outside_rate", "ipm_share", "asis_moved", "delta_final", "lambda_mean", "sigma_mean")], digits = 4, row.names = FALSE)
cat("\n==== crossings between adjacent levels (posterior means and draws) ====\n"); print(cm$adjacent, digits = 4, row.names = FALSE)
cat("\n==== crossings between all pairs ====\n"); print(cm$all_pairs, digits = 4, row.names = FALSE)
cat(sprintf("\ntotal time %.0f s\n", fit$seconds))

dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)
tag <- sprintf("%s_%s_n%d_seed%d_b0_%g_taus_%s", baseline_id, noise_id, n, seed, b0, paste(tau_list, collapse = "-"))
write.csv(res, file.path(out_dir, sprintf("joint_results_%s.csv", tag)), row.names = FALSE)
write.csv(cm$all_pairs, file.path(out_dir, sprintf("joint_crossings_%s.csv", tag)), row.names = FALSE)
saveRDS(list(fit = fit[c("tau", "lambda", "sigma", "delta", "acc", "outside", "ipm", "acc_post", "outside_post", "delta_final", "seconds")],
             est = est, lo = lo, hi = hi, truth = dat$truth, y = dat$y, res = res, crossings = cm), file.path(out_dir, sprintf("joint_summary_%s.rds", tag)))

cols <- hcl.colors(J, "Dark 3")
png(file.path(out_dir, sprintf("joint_target_fit_%s.png", tag)), width = 1400, height = 700, res = 130)
plot(dat$x, dat$y, pch = 16, cex = 0.4, col = "grey70", xlab = "index", ylab = "y",
     main = sprintf("Joint P-MALA, target tau = %.2f (levels %s) | %s | %s | MSE = %.5f (paper individual %.5f) | cov = %.3f",
                    target_quantile, paste(tau_list, collapse = ", "), baseline_id, noise_id, res$mse[jt], res$paper_individual_mse[jt], res$coverage[jt]))
polygon(c(dat$x, rev(dat$x)), c(lo[, jt], rev(hi[, jt])), col = adjustcolor("firebrick", 0.2), border = NA)
lines(dat$x, dat$truth[, jt], lwd = 2); lines(dat$x, est[, jt], col = "firebrick", lwd = 2, lty = 2)
legend("topleft", bty = "n", lwd = 2, lty = c(1, 2), col = c("black", "firebrick"), legend = c("true quantile", "posterior mean (95% band)"))
dev.off()

png(file.path(out_dir, sprintf("joint_all_levels_%s.png", tag)), width = 1400, height = 700, res = 130)
plot(dat$x, dat$y, pch = 16, cex = 0.4, col = "grey70", xlab = "index", ylab = "y", main = sprintf("All levels: truth (solid) vs posterior mean (dashed) | %s | %s", baseline_id, noise_id))
for (j in seq_len(J)) { lines(dat$x, dat$truth[, j], col = cols[j], lwd = 2); lines(dat$x, est[, j], col = cols[j], lwd = 2, lty = 2) }
legend("topleft", bty = "n", lwd = 2, col = cols, legend = sprintf("tau = %.2f", tau_list))
dev.off()

png(file.path(out_dir, sprintf("joint_traces_%s.png", tag)), width = 1400, height = 300 * J, res = 130)
par(mfrow = c(J, 4), mar = c(4, 4, 2, 1))
for (j in seq_len(J)) {
  plot(fit$lambda[, j], type = "l", main = sprintf("lambda, tau = %.2f", tau_list[j]), xlab = "sweep"); abline(v = gibbs_burn, lty = 3)
  plot(fit$sigma[, j],  type = "l", main = "sigma",  xlab = "sweep"); abline(v = gibbs_burn, lty = 3)
  plot(fit$delta[, j],  type = "l", log = "y", main = "delta", xlab = "sweep"); abline(v = gibbs_burn, lty = 3)
  plot(fit$theta[, n %/% 2, j], type = "l", main = sprintf("theta[%d] (kept)", n %/% 2), xlab = "kept sweep")
}
dev.off()
cat("saved:", file.path(out_dir, sprintf("joint_*_%s.{csv,rds,png}", tag)), "\n")
