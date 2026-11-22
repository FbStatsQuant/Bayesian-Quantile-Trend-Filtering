# E-05 COPY of method/individual/Individual_Sampler_PMALA_Augmented.R (the original is never edited).
# Only change: the curvature-metric cap 1e8 is read from getOption("bqtf.metric_cap", 1e8) (default = original behaviour).
# =============================================================================
# Bayesian quantile trend filtering: proper P-MALA (Pereyra 2016) on the
# ALD posterior via the Kozumi-Kobayashi normal-exponential augmentation.
#
# Model (paper's notation, sigma = ALD scale, tau = quantile level)
#   y_i = theta_i + eps_i,   eps_i ~ ALD(0, sigma, tau)
#   eps_i = psi z_i + sqrt(t2 sigma z_i) u_i,  u_i ~ N(0,1),  z_i ~ Exp(mean sigma)
#   psi = (1 - 2 tau) / (tau (1 - tau)),   t2 = 2 / (tau (1 - tau))
#   p(theta | lambda, sigma) ∝ (lambda/sigma)^m exp(-(lambda/sigma) ||D theta||_1),  D = (k+1)-th differences
#   (prior_scale = "sigma": Park & Casella 2008 scaling -- the effective penalty lambda/sigma is on the scale of the
#    check loss, so the smoothing does not weaken when the ALD scale sigma shrinks at extreme tau;
#    prior_scale = "none": exp(-lambda ||D theta||_1), the paper's current prior)
#   lambda ~ Gamma(a0, b0),  sigma ~ IG(a_sigma, b_sigma)
#
# One Gibbs sweep
#   Block 1  theta | z, lambda, sigma   P-MALA in the curvature metric P = diag(a) + (lambda^2/2) D'D, gamma = delta/2:
#            (P = Gaussian data precision + Laplace-difference precision; a function of the current z, lambda, sigma only,
#             so the kernel is a valid MH move on theta | z, lambda, sigma.  delta is then on posterior scale, O(0.1-1).)
#            U(theta|z) = sum_i a_i/2 (theta_i - r_i)^2 + lambda ||D theta||_1,
#            a_i = 1/(t2 sigma z_i), r_i = y_i - psi z_i
#            T(x) = argmin U(theta) + (1/(2 gamma)) ||theta - x||_M^2   (ADMM, fixed iterations, cold start,
#                   so T is a deterministic map and the MH correction below is exact for any accuracy)
#            theta* = T(theta) + sqrt(delta) L^{-T} xi,  P = L L'   i.e.  theta* ~ N(T(theta), delta P^{-1})
#            log alpha = U(theta) - U(theta*) + [||theta* - T(theta)||_P^2 - ||theta - T(theta*)||_P^2] / (2 delta)
#            Why P: isotropic noise has (k+1)-th differences of sd sqrt(20 delta), and lambda*m*sqrt(20 delta)
#            kills acceptance; P^{-1}-noise steps every direction at its own posterior scale (rough: ~1/lambda).
#            metric = "iso" recovers plain P-MALA (P = I), metric = "fixed" uses P = I + c D'D.
#   Block 2  z_i | theta, sigma        1/z_i ~ InvGauss(mean 1/(tau(1-tau)|e_i|), shape 1/(2 tau(1-tau) sigma))
#   Block 3  lambda | theta, sigma     Gamma(a0 + m, b0 + ||D theta||_1 / sigma)          [ / sigma only if prior_scale = "sigma"]
#   Block 4  sigma | theta, z, lambda  IG(a_sigma + 3n/2 + m, b_sigma + sum (y-theta-psi z)^2/(2 t2 z) + sum z + lambda ||D theta||_1)
#                                      [ + m and + lambda||D theta||_1 only if prior_scale = "sigma"]
#
# Usage:  Rscript Individual_Sampler_PMALA_Augmented.R            (pilot run)
#         Rscript Individual_Sampler_PMALA_Augmented.R test       (unit tests only)
# =============================================================================

suppressPackageStartupMessages(library(glmgen))
`%||%` <- function(a, b) if (is.null(a)) b else a

# ---- C++ kernel (banded ADMM prox in the M-metric) ----------------------------
# Rtools present: Rcpp::sourceCpp.  No Rtools (this laptop): build a DLL with mingw g++ once and .Call it.
load_prox_cpp <- function(src) {
  if (!file.exists(src)) {   # script run via Rscript: locate next to the script file
    a <- commandArgs(FALSE); f <- sub("^--file=", "", a[grepl("^--file=", a)])
    if (length(f)) src <- file.path(dirname(normalizePath(f)), "prox_admm_metric.cpp")
  }
  stopifnot(file.exists(src))
  ok <- tryCatch({ Rcpp::sourceCpp(src); TRUE }, error = function(e) FALSE)
  if (ok) return(invisible("sourceCpp"))
  dll <- file.path(tempdir(), "prox_admm_metric.dll")
  gpp <- "C:/mingw64/bin/g++.exe"
  cmd <- sprintf('"%s" -std=gnu++17 -O2 -w -shared -static-libgcc -static-libstdc++ -I"%s/include" -I"%s" -o "%s" "%s" -L"%s/bin/x64" -lR',
                 gpp, R.home(), system.file("include", package = "Rcpp"), dll, src, R.home())
  if (system(cmd) != 0) stop("could not compile prox_admm_metric.cpp (neither Rtools nor mingw g++ worked)")
  dyn.load(dll)
  assign("prox_admm_metric", function(x, a, r, lambda, gamma, d, c, k, rho, max_iter, tol = 0)
    .Call("C_prox_admm_metric", as.numeric(x), as.numeric(a), as.numeric(r), as.numeric(lambda),
          as.numeric(gamma), as.numeric(d), as.numeric(c), as.integer(k), as.numeric(rho), as.integer(max_iter), as.numeric(tol)), envir = globalenv())
  assign("pmala_move", function(theta, a, r, lambda, gamma, d, c, k, rho, max_iter, tol, xi, delta)
    .Call("C_pmala_move", as.numeric(theta), as.numeric(a), as.numeric(r), as.numeric(lambda), as.numeric(gamma), as.numeric(d),
          as.numeric(c), as.integer(k), as.numeric(rho), as.integer(max_iter), as.numeric(tol), as.numeric(xi), as.numeric(delta)), envir = globalenv())
  assign("minv_sqrt_noise", function(xi, d, c, k) .Call("C_minv_sqrt_noise", as.numeric(xi), as.numeric(d), as.numeric(c), as.integer(k)), envir = globalenv())
  assign("mnorm2", function(v, d, c, k) .Call("C_mnorm2", as.numeric(v), as.numeric(d), as.numeric(c), as.integer(k)), envir = globalenv())
  assign("metric_logdet", function(d, c, k) .Call("C_metric_logdet", as.numeric(d), as.numeric(c), as.integer(k)), envir = globalenv())
  invisible("mingw")
}

# ---- Settings ---------------------------------------------------------------
# Adopted defaults (2026-09-25, 30 cells x seed 1, adoption rule: not worse on MSE in any cell beyond seed noise, better on the
# target efficiency metric): ASIS lambda step ON (lambda-ESS per hour 87 vs 50, half-chain lambda drift 0.10 vs 0.26, MSE geometric
# mean ratio 0.96); early exit OFF (no wall-time gain at a 150-iteration budget); K = 1 (K = 3, 5 raise theta-ESS 3-4x but cost
# 3.6-6x); joint lambda jump OFF (lambda-ESS per hour 28-39, below ASIS).  See variant_adoption_summary.csv.
seed        <- 100
n           <- 500L
tau         <- 0.5
baseline_id <- "VS"
noise_id    <- "Normal"
order       <- 1L          # k: piecewise quadratic; D = 3rd differences
prior_scale <- "none"      # "none": Laplace prior exp(-lambda ||D theta||_1) (the paper's prior) | "sigma": Park-Casella scale sigma/lambda.
                           # "sigma" gives the same MSE but has a runaway mode (lambda enters sigma's rate and sigma enters lambda's:
                           # sigma -> 1e5, lambda -> (a0+m)/b0, theta detaches from the data; seen in 1 of 60 cell-runs), so "none" is the default.
a0 <- 1;  b0 <- 0.001      # Gamma prior on lambda: rate b0 << ||D theta||_1 of a smooth fit so lambda is data-driven (b0 >= 0.1 is clearly worse)
a_sigma <- 0.1; b_sigma <- 0.1     # IG prior on sigma (paper value; 0.01/0.01 gives identical results at n = 500)
gibbs_iter  <- 20000      # lambda equilibrates slowly for smooth truths (see notes); 30k/10k is the pilot setting
gibbs_burn  <- 5000
delta_init  <- 0.2        # posterior-scale step under metric = "curv"
adapt_target <- 0.55       # Robbins-Monro on log(delta) during burn-in
adapt_gain   <- 1.0
adapt_kappa  <- 0.6
delta_bounds <- c(1e-8, 100)
lambda_init  <- NULL       # NULL -> m (one unit of penalty per difference) under theta_init = "y"; a glmgen penalty under "tf"
metric       <- "curv"     # "curv": P = diag(a) + kappa (lambda_eff^2/2) D'D | "fixed": I + c_metric D'D | "iso": I
kappa_metric <- 3          # scale on the difference-precision term (3: delta ~ 0.1 at acceptance 0.5, ~2x the theta ESS of kappa = 1)
c_metric     <- 1e4        # only used by metric = "fixed"
theta_init   <- "y"        # "y": start at the data (rule) | "tf": glmgen fit at lambda_init
mh_correct   <- TRUE       # FALSE: accept every proposal (proximal ULA; not exact, diagnostic only)
adapt_delta  <- TRUE       # FALSE: keep delta = delta_init throughout
adapt_all    <- TRUE       # TRUE: diminishing Robbins-Monro adaptation for the whole run (gain it^-kappa_adapt -> 0, so the chain
                           #       remains ergodic; needed because lambda keeps drifting for smooth truths and the metric moves with it)
                           # FALSE: adapt during burn-in only, then freeze
warm_sweeps  <- 200L       # burn-in only: theta <- argmin U(theta | z, lambda, sigma) (prox with gamma_warm) for the first
gamma_warm   <- 1e4        # warm_sweeps sweeps, conjugate draws for the rest; the exact P-MALA kernel takes over afterwards
admm_iter    <- 150L       # ADMM iteration budget inside T(x)
admm_tol     <- 0          # residual-based early exit (relative primal and dual residuals); 0 = always run the full budget
K_theta      <- 1L         # P-MALA moves on theta per Gibbs sweep (all at the same z, lambda, sigma)
lamjump      <- FALSE      # joint (lambda, theta) Metropolis move once per sweep: lambda' = lambda exp(s xi), theta* = T_{lambda'}(theta) + noise
                           # in the lambda' metric; exact MH on the joint conditional of (theta, lambda) | z, sigma.  The prox at lambda'
                           # re-shrinks the roughness of theta to the lambda' scale, so lambda can jump while theta follows (the conjugate
                           # and ASIS draws only move lambda by a few % per sweep because ||D theta||_1 ~ m/lambda is locked to lambda).
lamjump_s    <- 0.3        # initial log-scale step of the lambda jump; Robbins-Monro adapted to acceptance 0.25
asis_lambda  <- FALSE       # ancillary-sufficient interweaving for lambda: after the conjugate draw, redraw lambda holding
                           # u~ = lambda * D theta and the polynomial part of theta fixed (theta rescales with lambda);
                           # 1-d slice sampler on log lambda, target p(lambda) * L(theta(lambda)).  Valid Gibbs variant (Yu & Meng 2011).
admm_rho     <- NULL       # ADMM penalty; NULL -> 0.1 * (mean(d) + c) / gamma at call time
tf_control   <- trendfilter.control.list(max_iter = 2000L, obj_tol = 1e-8)   # init fit only

# ---- Locate this script's folder (prox_admm_metric.cpp lives beside it) -------
# Works under Rscript, source(), and select-all + Run in RStudio, whatever the working directory; never calls setwd().
.norm <- function(p) {
  if (is.null(p) || length(p) != 1L || is.na(p) || !nzchar(p)) return(NA_character_)
  tryCatch(normalizePath(p, winslash = "/", mustWork = FALSE), error = function(e) NA_character_)
}
.script_dir <- function(target = "prox_admm_metric.cpp") {
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)                                   # Rscript
  p <- if (length(a)) .norm(sub("^--file=", "", a[[1L]])) else NA_character_
  if (is.na(p)) p <- .norm(tryCatch(sys.frame(1)$ofile, error = function(e) NULL))          # source()
  if (is.na(p) && requireNamespace("rstudioapi", quietly = TRUE) &&                          # RStudio: Run / Ctrl+Enter
      isTRUE(tryCatch(rstudioapi::isAvailable(), error = function(e) FALSE)))
    p <- .norm(tryCatch(rstudioapi::getActiveDocumentContext()$path, error = function(e) NA_character_))
  if (!is.na(p) && file.exists(file.path(dirname(p), target))) return(dirname(p))
  rel <- file.path("Simulations", "Individual")                                             # fallback: search known roots
  up <- character(0); d <- .norm(getwd())
  while (!is.na(d) && !(d %in% up)) { up <- c(up, d); d <- dirname(d) }
  cand <- c(up, file.path(up, rel),
            file.path(c("~", "~/Documents", "~/OneDrive/Documents"), "Quantile Regression", rel))
  hit <- cand[file.exists(file.path(cand, target))]
  if (length(hit)) return(.norm(hit[[1L]]))
  stop("Could not find ", target, ". Open this script from method/individual, or setwd() there.")
}
script_dir   <- .script_dir()
cpp_src      <- file.path(script_dir, "prox_admm_metric.cpp")
out_dir      <- file.path(script_dir, "results_pmala_aug")   # pilot csv + plots

# ---- Data (same generator as the k2 campaign) --------------------------------
simulate_data <- function(seed, n, tau, baseline_id, noise_id) {
  RNGkind("Mersenne-Twister", "Inversion", "Rejection")
  set.seed(seed)
  x <- seq_len(n); xs <- x / n; mm <- n / 100
  baseline <- switch(baseline_id,
    PC = 2.5 * (x <= mm * 20) + 1 * (x >= mm * 20 + 1 & x <= mm * 40) +
      3.5 * (x >= mm * 40 + 1 & x <= mm * 60) + 1.5 * (x >= mm * 60 + 1),
    VS = 2 + sin(4 * xs - 2) + 2 * exp(-30 * (4 * xs - 2)^2),
    S  = sin(2 * pi * x / n), stop("Unknown baseline"))
  if (noise_id == "Mixed") {
    noise <- vapply(xs, function(xi) if (runif(1) < xi) rnorm(1, -.2, sqrt(.5)) else rnorm(1, .2, sqrt(.5)), numeric(1))
    q <- vapply(xs, function(xi) uniroot(function(t) xi * pnorm(t, -.2, sqrt(.5)) +
                  (1 - xi) * pnorm(t, .2, sqrt(.5)) - tau, c(-10, 10))$root, numeric(1))
  } else if (noise_id == "Beta") {
    noise <- vapply(xs, function(xi) rbeta(1, 1, 11 - 10 * xi), numeric(1))
    q <- qbeta(tau, 1, 11 - 10 * xs)
  } else if (noise_id == "Normal") {
    s <- (1 + xs^2) / 4
    noise <- rnorm(n, 0, s); q <- qnorm(tau) * s
  } else stop("Unknown noise")
  list(x = x, y = baseline + noise, baseline = baseline, truth = baseline + q)
}

# ---- Model pieces ------------------------------------------------------------
ald_const <- function(tau) list(psi = (1 - 2 * tau) / (tau * (1 - tau)),
                                t2  = 2 / (tau * (1 - tau)))

Dtheta <- function(theta, order) diff(theta, differences = order + 1L)

rho_tau <- function(u, tau) u * (tau - (u < 0))

# U(theta | z): exact conditional negative log-posterior (constants dropped)
U_cond <- function(theta, a, r, lambda, order) {
  sum(a * (theta - r)^2) / 2 + lambda * sum(abs(Dtheta(theta, order)))
}

# T(x) = prox of U in the M-metric, M = I + c D'D, by banded ADMM (fixed iterations, cold start).
# c = 0 and glmgen available: the same problem is weighted trend filtering (kept for cross-checks).
prox_T <- function(x, a, r, lambda, gamma, d, c, order, rho = NULL, iters = 200L, tol = 0) {
  if (is.null(rho)) rho <- 0.1 * (mean(d) + c) / gamma   # ~1/10 of the metric curvature
  prox_admm_metric(x, a, r, lambda, gamma, d, c, order, rho, iters, tol)
}
# metric (d, c) for the theta block:  P = diag(d) + c D'D
metric_dc <- function(metric, a, lambda, c_fixed, kappa = 1) {
  switch(metric,
    curv  = list(d = a,                    c = min(kappa * lambda^2 / 2, getOption("bqtf.metric_cap", 1e8))),   # kappa: scale on the difference-precision term; cap keeps
                                                                                # cond(P) < ~1e14 given min(a) ~ 4e-5 (ADMM system also has a ridge retry)
    fixed = list(d = rep(1, length(a)),    c = c_fixed),
    iso   = list(d = rep(1, length(a)),    c = 0),
    stop("unknown metric"))
}
prox_U_glmgen <- function(x, a, r, lambda, gamma, order, control) {   # c = 0 reference (weighted TF)
  w  <- a + 1 / gamma
  zt <- (a * r + x / gamma) / w
  if (lambda <= 0) return(zt)
  fit <- glmgen::trendfilter(x = seq_along(x), y = zt, weights = w, k = order,
                             lambda = lambda, thinning = FALSE, control = control)
  as.numeric(fit$beta[, 1])
}

# Inverse Gaussian sampler (Michael, Schucany & Haas 1976); mean mu, shape lam
rinvgauss <- function(n, mu, lam) {
  nu <- rnorm(n); yv <- nu^2
  xv <- mu + mu^2 * yv / (2 * lam) - (mu / (2 * lam)) * sqrt(4 * mu * lam * yv + mu^2 * yv^2)
  u  <- runif(n)
  ifelse(u <= mu / (mu + xv), xv, mu^2 / xv)
}

# Block 2: z_i | theta, sigma  via 1/z_i ~ InvGauss(1/(tau(1-tau)|e_i|), 1/(2 tau(1-tau) sigma))
draw_z <- function(e, tau, sigma) {
  ae <- pmax(abs(e), 1e-10)
  v  <- rinvgauss(length(e), mu = 1 / (tau * (1 - tau) * ae), lam = 1 / (2 * tau * (1 - tau) * sigma))
  pmin(pmax(1 / v, 1e-8), 1e4)                          # floor/cap keep a_i = 1/(t2 sigma z_i) in [~4e-5, ~1e8]: P = diag(a) + c D'D stays factorisable
                                                        # (z ~ Exp(sigma) with sigma < 1, so P(z > 1e4) is nil; the cap only removes degenerate draws)
}

# Block 4: sigma | theta, z
draw_sigma <- function(y, theta, z, cst, a_sigma, b_sigma, lambda_SD = 0, m = 0) {
  n <- length(y)
  ss <- sum((y - theta - cst$psi * z)^2 / (2 * cst$t2 * z)) + sum(z)
  1 / rgamma(1, shape = a_sigma + 1.5 * n + m, rate = b_sigma + ss + lambda_SD)   # m, lambda_SD: sigma-scaled prior
}

# Block 1: one preconditioned P-MALA move on theta | z, lambda, sigma
# MAP polish by EM on the augmented model (Kozumi-Kobayashi / MM for the check loss) at FIXED hyperparameters:
#   E-step  E[z_i | theta, sigma] = sqrt(chi_i/psi) (1 + 1/sqrt(chi_i psi)),  chi_i = e_i^2/(t2 sigma), psi = psi_c^2/(t2 sigma) + 2/sigma
#   M-step  theta <- argmin sum_i (theta_i - r_i)^2 / (2 t2 sigma zbar_i) + lam_eff ||D theta||_1   (weighted TF, banded ADMM)
# Converges to argmin sum rho_tau(y - theta)/sigma + lam_eff ||D theta||_1, the quantile trend filter at (lam_eff, sigma).
map_em <- function(theta, y, tau, lam_eff, sigma, order, iters = 100L, admm_iters = 300L) {
  cst <- ald_const(tau); psi_g <- cst$psi^2 / (cst$t2 * sigma) + 2 / sigma
  for (k in seq_len(iters)) {
    e <- y - theta; chi <- pmax(e^2, 1e-12) / (cst$t2 * sigma); w <- sqrt(chi * psi_g)
    zbar <- pmax(sqrt(chi / psi_g) * (1 + 1 / w), 1e-8)              # GIG(1/2, chi, psi) mean
    a <- 1 / (cst$t2 * sigma * zbar); r <- y - cst$psi * zbar
    theta <- prox_T(theta, a, r, lam_eff, 1e6, a, 0, order, rho = median(a), iters = admm_iters)
  }
  theta
}

pmala_step <- function(theta, y, z, lambda, sigma, delta, cst, order, metric = "curv", c_fixed = 0,
                       rho = NULL, iters = 200L, mh = TRUE, kappa = 1, tol = 0) {
  gamma <- delta / 2
  a <- 1 / (cst$t2 * sigma * z)
  r <- y - cst$psi * z
  M <- metric_dc(metric, a, lambda, c_fixed, kappa); d <- M$d; c <- M$c
  if (is.null(rho)) rho <- 0.1 * (mean(d) + c) / gamma
  if (!mh) {                                                                       # proximal ULA: no correction (diagnostic)
    p    <- prox_T(theta, a, r, lambda, gamma, d, c, order, rho, iters, tol)
    prop <- p + sqrt(delta) * minv_sqrt_noise(rnorm(length(theta)), d, c, order)
    return(list(theta = prop, accept = TRUE, log_alpha = 0))
  }
  mv <- pmala_move(theta, a, r, lambda, gamma, d, c, order, rho, iters, tol, rnorm(length(theta)), delta)   # shared factorisation:
  prop <- mv$prop                                                                  # T(theta), theta* ~ N(T(theta), delta P^-1), T(theta*)
  log_alpha <- (U_cond(theta, a, r, lambda, order) - U_cond(prop, a, r, lambda, order)) + (mv$q_fwd - mv$q_rev) / (2 * delta)
  if (!is.finite(log_alpha)) log_alpha <- -Inf                                    # NaN/Inf (degenerate z or overflow): reject
  accept <- log(runif(1)) < log_alpha
  list(theta = if (accept) prop else theta, accept = accept,
       log_alpha = min(0, log_alpha))
}

# Joint (lambda, theta) move.  Proposal: eta' = log lambda + s xi_0;  theta* ~ N(T_{lambda'}(theta), delta P_{lambda'}^{-1}) with
# T_{lambda'} the prox of U_{lambda'} in the P_{lambda'} metric.  Reverse: lambda' -> lambda, theta* -> theta with T_lambda, P_lambda.
# log alpha = [log pi(theta*, lambda') - log pi(theta, lambda)] + [log q(theta, lambda | theta*, lambda') - log q(theta*, lambda' | theta, lambda)],
# log pi(theta, lambda | z, sigma) = -U_lambda(theta) + (a0 - 1 + m) log lambda - b0 lambda,   U_lambda = sum a (theta - r)^2 / 2 + lambda ||D theta||_1,
# log q(theta* | .) = -||theta* - T||_P^2 / (2 delta) + (1/2) log det P (+ const), log q(lambda' | lambda) in lambda-space carries 1/lambda'.
lamjump_step <- function(theta, lambda, a, r, a0, b0, m, delta, s, order, kappa, rho = NULL, iters = 150L, tol = 0) {
  gamma <- delta / 2; n <- length(theta)
  lam1 <- lambda * exp(s * rnorm(1))
  M0 <- metric_dc("curv", a, lambda, 0, kappa); M1 <- metric_dc("curv", a, lam1, 0, kappa)
  rho0 <- if (is.null(rho)) 0.1 * (mean(M0$d) + M0$c) / gamma else rho
  rho1 <- if (is.null(rho)) 0.1 * (mean(M1$d) + M1$c) / gamma else rho
  p1   <- prox_admm_metric(theta, a, r, lam1, gamma, M1$d, M1$c, order, rho1, iters, tol)          # T_{lambda'}(theta)
  prop <- p1 + sqrt(delta) * minv_sqrt_noise(rnorm(n), M1$d, M1$c, order)
  p0   <- prox_admm_metric(prop, a, r, lambda, gamma, M0$d, M0$c, order, rho0, iters, tol)         # T_lambda(theta*)
  lpi1 <- -U_cond(prop, a, r, lam1, order) + (a0 - 1 + m) * log(lam1) - b0 * lam1
  lpi0 <- -U_cond(theta, a, r, lambda, order) + (a0 - 1 + m) * log(lambda) - b0 * lambda
  lq_fwd <- -mnorm2(prop - p1, M1$d, M1$c, order) / (2 * delta) + 0.5 * metric_logdet(M1$d, M1$c, order) - log(lam1)
  lq_rev <- -mnorm2(theta - p0, M0$d, M0$c, order) / (2 * delta) + 0.5 * metric_logdet(M0$d, M0$c, order) - log(lambda)
  log_alpha <- (lpi1 - lpi0) + (lq_rev - lq_fwd)
  if (!is.finite(log_alpha)) log_alpha <- -Inf
  accept <- log(runif(1)) < log_alpha
  list(theta = if (accept) prop else theta, lambda = if (accept) lam1 else lambda, accept = accept, log_alpha = min(0, log_alpha))
}

# ASIS (ancillary-sufficient interweaving) step for lambda.  Sufficient parameterisation: lambda | theta ~ Gamma (conjugate,
# done in Block 3).  Ancillary parameterisation: u~ = lambda * D theta, whose prior Laplace(1)^m does not involve lambda.
# With u~ and the polynomial part theta_par = Q Q' theta (Q: orthonormal basis of null(D)) held fixed, a new lambda' implies
#   theta(lambda') = theta_par + (lambda / lambda') (theta - theta_par),
# and lambda' | u~, theta_par, z, sigma has density  p(lambda') * exp{-sum_i a_i (theta_i(lambda') - r_i)^2 / 2}
# (the lambda^m prior constant cancels the Jacobian of u = u~/lambda).  Sampled by a stepping-out/shrinkage slice sampler
# on eta = log lambda' (Jacobian: + eta).  O(n) per density evaluation.  Returns the new lambda and the rescaled theta.
asis_step <- function(theta, lambda, a, r, a0, b0, Q, w = 1, max_steps = 30L) {
  th_par <- Q %*% crossprod(Q, theta); th_perp <- theta - th_par
  logf <- function(eta) { lam <- exp(eta); th <- th_par + (lambda / lam) * th_perp
    a0 * eta - b0 * lam - sum(a * (th - r)^2) / 2 }          # (a0 - 1) log lam - b0 lam + eta (Jacobian) = a0 eta - b0 lam
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

# ---- Gibbs sampler -----------------------------------------------------------
gibbs_pmala_aug <- function(y, tau, order, a0, b0, a_sigma, b_sigma,
                            gibbs_iter, gibbs_burn, delta_init, lambda_init,
                            adapt_target, adapt_gain, adapt_kappa, delta_bounds,
                            control, metric = "curv", c_fixed = 0, rho = NULL, iters = 200L,
                            mh = TRUE, adapt = TRUE, init = "y", warm = 0L, gamma_warm = 1e3,
                            prior_scale = "sigma", cmap = FALSE, kappa = 1, adapt_all = TRUE, K = 1L, asis = FALSE,
                            tol = 0, lamjump = FALSE, lamjump_s = 0.3, verbose = TRUE) {
  s_lj <- lamjump_s; acc_lj <- numeric(gibbs_iter)
  Q <- if (asis) null_basis(length(y), order) else NULL
  ps <- prior_scale == "sigma"
  # cmap: alongside the posterior mean of the theta samples, accumulate the mean over post-burn-in sweeps of the
  # CONDITIONAL MODE  argmin_theta U(theta | z, lambda, sigma)  (one weighted trend-filtering solve per sweep, banded ADMM).
  # Each conditional mode is sparse in D theta; averaging it over exact posterior draws of (z, lambda, sigma) gives a
  # smooth point estimate that does not carry the sample-level roughness of an l1 posterior.
  n <- length(y); m <- n - order - 1L
  cst <- ald_const(tau)
  # init (init = "y"): theta at the data; hyperparameters at data-free defaults, NOT at their conditionals
  # given theta = y -- those (sigma -> 0, z -> 0, lambda -> (a0+m)/||D y||_1) are a degenerate self-consistent
  # mode of the joint posterior (interpolate the data, scale -> 0) that a Gibbs chain never leaves.
  # sigma0 = 1, z0 = sigma0 (prior mean), lambda0 = (a0+m)/b0 (conjugate mean at zero roughness).
  if (init == "y") {
    theta  <- y
    sigma  <- 1
    z      <- rep(sigma, n)
    lambda <- if (is.null(lambda_init)) m else lambda_init      # one unit of penalty per difference
  } else {
    theta  <- as.numeric(glmgen::trendfilter(seq_len(n), y, k = order, lambda = lambda_init,
                                             thinning = FALSE, control = control)$beta[, 1])
    sigma  <- sum(rho_tau(y - theta, tau)) / n
    z      <- draw_z(y - theta, tau, sigma)
    lambda <- rgamma(1, shape = a0 + m, rate = b0 + sum(abs(Dtheta(theta, order))) / (if (ps) sigma else 1))
  }
  delta  <- delta_init
  keep <- gibbs_iter - gibbs_burn
  theta_s  <- matrix(NA_real_, keep, n); cmap_sum <- numeric(n)
  lambda_s <- sigma_s <- delta_s <- acc_s <- SD_s <- numeric(gibbs_iter)
  n_acc <- 0L
  t0 <- proc.time()[["elapsed"]]
  for (it in seq_len(gibbs_iter)) {
    lam_eff <- if (ps) lambda / sigma else lambda                               # penalty on the check-loss scale
    if (it <= warm) {                                                          # warm start: optimisation step only
      a <- 1 / (cst$t2 * sigma * z); r <- y - cst$psi * z                        # conditional MAP = weighted TF:
      theta <- prox_T(theta, a, r, lam_eff, gamma_warm, a, 0, order, rho = median(a), iters = 2L * iters)  # Euclidean-in-a prox, gamma large
      st <- list(theta = theta, accept = NA, log_alpha = NA)
    } else {                                                                   # Block 1: K P-MALA moves at fixed (z, lambda, sigma)
      acc_k <- la_k <- numeric(K)
      for (kk in seq_len(K)) {
        st <- pmala_step(theta, y, z, lam_eff, sigma, delta, cst, order, metric, c_fixed, rho, iters, mh, kappa, tol)
        theta <- st$theta; acc_k[kk] <- st$accept; la_k[kk] <- exp(st$log_alpha)
      }
      st <- list(theta = theta, accept = mean(acc_k), log_alpha = log(mean(la_k)))
    }
    n_acc <- n_acc + if (is.na(st$accept)) 0 else st$accept
    z      <- draw_z(y - theta, tau, sigma)                                     # Block 2
    SD     <- sum(abs(Dtheta(theta, order)))
    lambda <- rgamma(1, shape = a0 + m, rate = b0 + if (ps) SD / sigma else SD)  # Block 3 (sufficient parameterisation)
    if (asis && it > warm && !ps) {                                              # Block 3b: ancillary redraw, theta rescales
      a_ <- 1 / (cst$t2 * sigma * z); r_ <- y - cst$psi * z
      as_ <- asis_step(theta, lambda, a_, r_, a0, b0, Q); lambda <- as_$lambda; theta <- as_$theta
      SD <- sum(abs(Dtheta(theta, order)))
    }
    if (lamjump && it > warm && !ps) {                                           # Block 3c: joint (lambda, theta) jump
      a_ <- 1 / (cst$t2 * sigma * z); r_ <- y - cst$psi * z
      lj <- lamjump_step(theta, lambda, a_, r_, a0, b0, m, delta, s_lj, order, kappa, rho, iters, tol)
      theta <- lj$theta; lambda <- lj$lambda; acc_lj[it] <- lj$accept; SD <- sum(abs(Dtheta(theta, order)))
      if (adapt) { s_lj <- exp(log(s_lj) + adapt_gain * it^(-adapt_kappa) * (exp(lj$log_alpha) - 0.25)); s_lj <- min(max(s_lj, 1e-3), 3) }
    }
    sigma  <- draw_sigma(y, theta, z, cst, a_sigma, b_sigma,                    # Block 4
                         lambda_SD = if (ps) lambda * SD else 0, m = if (ps) m else 0)
    if (adapt && it > warm && (adapt_all || it <= gibbs_burn)) {                # adapt delta (diminishing gain)
      delta <- exp(log(delta) + adapt_gain * it^(-adapt_kappa) * (exp(st$log_alpha) - adapt_target))
      delta <- min(max(delta, delta_bounds[1]), delta_bounds[2])
    }
    if (!is.finite(sigma) || !is.finite(lambda) || !all(is.finite(theta)))
      stop(sprintf("non-finite state at sweep %d: sigma %g lambda %g theta finite %d", it, sigma, lambda, all(is.finite(theta))))
    lambda_s[it] <- lambda; sigma_s[it] <- sigma; delta_s[it] <- delta; acc_s[it] <- st$accept; SD_s[it] <- SD
    if (it > gibbs_burn) {
      theta_s[it - gibbs_burn, ] <- theta
      if (cmap) { a <- 1 / (cst$t2 * sigma * z); r <- y - cst$psi * z
        cmap_sum <- cmap_sum + prox_T(theta, a, r, lam_eff, gamma_warm, a, 0, order, rho = median(a), iters = 2L * iters) }
    }
    if (verbose && it %% 500 == 0)
      cat(sprintf("it %5d | acc %.3f | delta %.2e | lambda %8.2f | sigma %.4f | %.0fs\n",
                  it, n_acc / it, delta, lambda, sigma, proc.time()[["elapsed"]] - t0))
  }
  list(theta = theta_s, theta_cmap = if (cmap) cmap_sum / keep else NULL,
       lambda = lambda_s, sigma = sigma_s, delta = delta_s, acc = acc_s, SD = SD_s,
       acc_post = mean(acc_s[(gibbs_burn + 1):gibbs_iter]), delta_final = delta,
       acc_lamjump = if (lamjump) mean(acc_lj[(gibbs_burn + 1):gibbs_iter]) else NA, s_lamjump = s_lj,
       seconds = proc.time()[["elapsed"]] - t0)
}

# ---- Unit tests --------------------------------------------------------------
run_tests <- function() {
  cat("== test 1: augmentation reproduces the ALD(0, sigma, tau) ==\n")
  set.seed(7); tt <- 0.3; sg <- 0.7; cst <- ald_const(tt); N <- 2e5
  zz <- rexp(N, rate = 1 / sg)
  ee <- cst$psi * zz + sqrt(cst$t2 * sg * zz) * rnorm(N)
  F_ald <- function(u) ifelse(u < 0, tt * exp((1 - tt) * u / sg), 1 - (1 - tt) * exp(-tt * u / sg))
  grid <- c(-2, -1, -0.3, 0, 0.3, 1, 2, 4)
  dev <- max(abs(ecdf(ee)(grid) - F_ald(grid)))
  cat(sprintf("   max |ecdf - F_ALD| = %.4f  (MC sd ~ %.4f)  P(eps<0) = %.4f vs tau = %.2f\n",
              dev, 0.5 / sqrt(N), mean(ee < 0), tt))
  stopifnot(dev < 0.01)

  cat("== test 2: z conditional (InvGauss on 1/z) matches the GIG kernel ==\n")
  set.seed(8); e0 <- 0.4; sg <- 0.7; tt <- 0.3; cst <- ald_const(tt)
  zs <- draw_z(rep(e0, 2e5), tt, sg)
  chi <- e0^2 / (cst$t2 * sg); psi_g <- cst$psi^2 / (cst$t2 * sg) + 2 / sg
  # GIG(1/2, chi, psi) moments via Bessel K: E z = sqrt(chi/psi) K_{3/2}(w)/K_{1/2}(w), w = sqrt(chi psi)
  w <- sqrt(chi * psi_g)
  Ez <- sqrt(chi / psi_g) * besselK(w, 1.5) / besselK(w, 0.5)
  cat(sprintf("   E z: sample %.5f vs GIG %.5f\n", mean(zs), Ez))
  stopifnot(abs(mean(zs) - Ez) / Ez < 0.01)

  cat("== test 3: prox_U returns the minimiser of the weighted objective ==\n")
  set.seed(9); nn <- 120; ord <- 2L; lam <- 3; gam <- 0.05
  a <- rexp(nn) * 20 + 1; r <- sin(seq_len(nn) / 15) + rnorm(nn, 0, 0.2); x <- r + rnorm(nn, 0, 0.3)
  p_g <- prox_U_glmgen(x, a, r, lam, gam, ord, trendfilter.control.list(max_iter = 5000L, obj_tol = 1e-10))
  p_c <- prox_T(x, a, r, lam, gam, rep(1, nn), 0, ord, iters = 5000L)
  obj <- function(th) U_cond(th, a, r, lam, ord) + sum((th - x)^2) / (2 * gam)
  worse <- replicate(300, obj(p_c + rnorm(nn, 0, 1e-3)) > obj(p_c))
  cat(sprintf("   perturbations with larger objective: %d / 300 | ||ADMM - glmgen|| = %.2e\n", sum(worse), sqrt(sum((p_c - p_g)^2))))
  stopifnot(all(worse), sqrt(sum((p_c - p_g)^2)) < 1e-4)
  cat("== test 3b: metric prox (c > 0) is the minimiser of U + ||.||_M^2/(2 gamma) ==\n")
  cc <- 50; Dm <- diff(diag(nn), differences = ord + 1); Mm <- diag(nn) + cc * crossprod(Dm)
  p_m <- prox_T(x, a, r, lam, gam, rep(1, nn), cc, ord, iters = 5000L)
  objm <- function(th) U_cond(th, a, r, lam, ord) + as.numeric(t(th - x) %*% Mm %*% (th - x)) / (2 * gam)
  worse <- replicate(300, objm(p_m + rnorm(nn, 0, 1e-4)) > objm(p_m))
  cat(sprintf("   perturbations with larger objective: %d / 300\n", sum(worse)))
  stopifnot(all(worse))

  # batch-means standard error of a column mean
  bm_se <- function(v, nb = 50) { b <- floor(length(v) / nb); sd(colMeans(matrix(v[1:(b * nb)], b, nb))) / sqrt(nb) }
  run_pmala <- function(M, th, yy, zz, lam, sg, delta, cst, ord, cc, iters = 300L, metric = "fixed", step = pmala_step) {
    S <- matrix(NA, M, length(th)); acc <- 0
    for (i in seq_len(M)) {
      st <- step(th, yy, zz, lam, sg, delta, cst, ord, metric, cc, iters = iters); th <- st$theta; acc <- acc + st$accept
      S[i, ] <- th
    }
    list(S = S, acc = acc / M)
  }

  cat("== test 4a: lambda = 0, c = 20 -> conditional is N(r_i, 1/a_i) exactly; prox and metric non-trivial ==\n")
  set.seed(10); nn <- 8; ord <- 1L; sg <- 0.5; tt <- 0.3; cst <- ald_const(tt)
  yy <- cumsum(rnorm(nn, 0, 0.3)); zz <- rexp(nn, 1 / sg)
  a <- 1 / (cst$t2 * sg * zz); r <- yy - cst$psi * zz
  M <- 60000L; out <- run_pmala(M, r, yy, zz, 0, sg, 1.0, cst, ord, cc = 20); S1 <- out$S[-(1:5000), ]
  m1 <- colMeans(S1); se1 <- apply(S1, 2, bm_se); s1 <- apply(S1, 2, sd)
  se_s1 <- apply(S1, 2, function(v) bm_se((v - mean(v))^2)) / (2 * s1)   # delta-method se of sd
  zsc <- (m1 - r) / se1; zsd <- (s1 - 1 / sqrt(a)) / se_s1
  cat(sprintf("   acc %.2f | max |mean z| = %.2f | max |sd z| = %.2f | max |sd ratio - 1| = %.3f\n",
              out$acc, max(abs(zsc)), max(abs(zsd)), max(abs(s1 * sqrt(a) - 1))))
  stopifnot(max(abs(zsc)) < 4, max(abs(zsd)) < 4)

  cat("== test 4b: lambda > 0, c = 5, n = 4, first differences -> P-MALA vs exact grid integration of U ==\n")
  set.seed(11); nn <- 4; ord <- 0L; lam <- 2; sg <- 0.5; tt <- 0.3; cst <- ald_const(tt)
  yy <- cumsum(rnorm(nn, 0, 0.3)); zz <- rexp(nn, 1 / sg)
  a <- 1 / (cst$t2 * sg * zz); r <- yy - cst$psi * zz
  # exact reference: 4-d grid, r_i +/- 5 posterior-sd-scale, 45 points per axis
  ax <- lapply(seq_len(nn), function(i) seq(r[i] - 5 / sqrt(a[i]), r[i] + 5 / sqrt(a[i]), length.out = 45L))
  G <- as.matrix(expand.grid(ax))
  lp <- -(G - rep(r, each = nrow(G)))^2 %*% (a / 2) - lam * rowSums(abs(G[, -1] - G[, -nn]))
  wgt <- exp(lp - max(lp)); wgt <- wgt / sum(wgt)
  m_ex <- colSums(G * as.vector(wgt)); s_ex <- sqrt(colSums(G^2 * as.vector(wgt)) - m_ex^2)
  out <- run_pmala(M, r, yy, zz, lam, sg, 0.6, cst, ord, cc = 5); S1 <- out$S[-(1:5000), ]
  m1 <- colMeans(S1); se1 <- apply(S1, 2, bm_se); s1 <- apply(S1, 2, sd)
  se_s1 <- apply(S1, 2, function(v) bm_se((v - mean(v))^2)) / (2 * s1)   # delta-method se of sd
  cat(sprintf("   P-MALA acc %.2f | max |mean z| = %.2f | max |sd z| = %.2f | exact sd ~ %.3f | max |sd ratio - 1| = %.3f\n",
              out$acc, max(abs(m1 - m_ex) / se1), max(abs(s1 - s_ex) / se_s1), mean(s_ex), max(abs(s1 / s_ex - 1))))
  stopifnot(max(abs(m1 - m_ex) / se1) < 4, max(abs(s1 - s_ex) / se_s1) < 4)

  cat("== test 4c: same target, curvature metric P = diag(a) + 3 lambda^2/2 D'D (kappa = 3), delta = 1 ==\n")
  pm_k3 <- function(...) pmala_step(..., kappa = 3)
  out <- run_pmala(M, r, yy, zz, lam, sg, 1.0, cst, ord, 0, metric = "curv", step = pm_k3); S1 <- out$S[-(1:5000), ]
  m1 <- colMeans(S1); se1 <- apply(S1, 2, bm_se); s1 <- apply(S1, 2, sd)
  se_s1 <- apply(S1, 2, function(v) bm_se((v - mean(v))^2)) / (2 * s1)
  cat(sprintf("   P-MALA acc %.2f | max |mean z| = %.2f | max |sd z| = %.2f | max |sd ratio - 1| = %.3f\n",
              out$acc, max(abs(m1 - m_ex) / se1), max(abs(s1 - s_ex) / se_s1), max(abs(s1 / s_ex - 1))))

  cat("== test 5: fused pmala_move reproduces the separate proxes (tol = 0) and the early exit matches to 1e-6 ==\n")
  set.seed(12); nn <- 200; ord <- 2L; sg <- 0.3; tt <- 0.5; cst <- ald_const(tt); lam <- 300
  yy <- sin(seq_len(nn) / 30) + rnorm(nn, 0, 0.2); zz <- rexp(nn, 1 / sg); th0 <- yy + rnorm(nn, 0, 0.05)
  a <- 1 / (cst$t2 * sg * zz); r <- yy - cst$psi * zz; Mm <- metric_dc("curv", a, lam, 0, 3); delta <- 0.2; gam <- delta / 2
  rho <- 0.1 * (mean(Mm$d) + Mm$c) / gam; xi <- rnorm(nn)
  mv <- pmala_move(th0, a, r, lam, gam, Mm$d, Mm$c, ord, rho, 150L, 0, xi, delta)
  p1 <- prox_T(th0, a, r, lam, gam, Mm$d, Mm$c, ord, rho, 150L); prop <- p1 + sqrt(delta) * minv_sqrt_noise(xi, Mm$d, Mm$c, ord)
  p2 <- prox_T(prop, a, r, lam, gam, Mm$d, Mm$c, ord, rho, 150L)
  d1 <- max(abs(mv$p - p1)); d2 <- max(abs(mv$prop - prop)); d3 <- max(abs(mv$pstar - p2))
  d4 <- abs(mv$q_fwd - mnorm2(prop - p1, Mm$d, Mm$c, ord)); d5 <- abs(mv$q_rev - mnorm2(th0 - p2, Mm$d, Mm$c, ord))
  mv2 <- pmala_move(th0, a, r, lam, gam, Mm$d, Mm$c, ord, rho, 2000L, 1e-8, xi, delta)
  ref <- prox_T(th0, a, r, lam, gam, Mm$d, Mm$c, ord, rho, 20000L)
  cat(sprintf("   fused vs separate: %.1e %.1e %.1e %.1e %.1e | early exit at %d/%d its, ||T - T_ref(20k)|| = %.1e (150 its: %.1e)\n",
              d1, d2, d3, d4, d5, mv2$iters[1], mv2$iters[2], max(abs(mv2$p - ref)), max(abs(p1 - ref))))
  stopifnot(max(d1, d2, d3) < 1e-10, max(d4, d5) < 1e-6, max(abs(mv2$p - ref)) < 1e-6)

  cat("== test 6: ASIS-interwoven (theta, lambda) Gibbs vs grid integration of the lambda-marginalised target, n = 4 ==\n")
  # joint: exp(-sum a (th-r)^2/2) lam^m e^{-lam ||D th||_1} lam^{a0-1} e^{-b0 lam};  marginal over lambda: (b0 + ||D th||_1)^{-(m+a0)}
  set.seed(13); nn <- 4; ord <- 0L; mm <- nn - 1; a0_ <- 1; b0_ <- 0.5; sg <- 0.5; tt <- 0.3; cst <- ald_const(tt)
  yy <- cumsum(rnorm(nn, 0, 0.3)); zz <- rexp(nn, 1 / sg); a <- 1 / (cst$t2 * sg * zz); r <- yy - cst$psi * zz
  ax <- lapply(seq_len(nn), function(i) seq(r[i] - 5 / sqrt(a[i]), r[i] + 5 / sqrt(a[i]), length.out = 45L)); G <- as.matrix(expand.grid(ax))
  SDg <- rowSums(abs(G[, -1] - G[, -nn]))
  lp <- -(G - rep(r, each = nrow(G)))^2 %*% (a / 2) - (mm + a0_) * log(b0_ + SDg)
  wgt <- exp(lp - max(lp)); wgt <- as.vector(wgt / sum(wgt))
  m_ex <- colSums(G * wgt); s_ex <- sqrt(colSums(G^2 * wgt) - m_ex^2); lam_ex <- sum(wgt * (mm + a0_) / (b0_ + SDg))
  Q <- null_basis(nn, ord); th <- r; lam <- 2; M2 <- 80000L; S <- matrix(NA, M2, nn); L <- numeric(M2); acc <- 0
  for (i in seq_len(M2)) {
    st <- pmala_step(th, yy, zz, lam, sg, 1.0, cst, ord, "curv", 0, iters = 300L, kappa = 3); th <- st$theta; acc <- acc + st$accept
    lam <- rgamma(1, a0_ + mm, b0_ + sum(abs(diff(th))))
    as_ <- asis_step(th, lam, a, r, a0_, b0_, Q); lam <- as_$lambda; th <- as_$theta
    S[i, ] <- th; L[i] <- lam
  }
  S1 <- S[-(1:5000), ]; L1 <- L[-(1:5000)]
  m1 <- colMeans(S1); se1 <- apply(S1, 2, bm_se); s1 <- apply(S1, 2, sd)
  se_s1 <- apply(S1, 2, function(v) bm_se((v - mean(v))^2)) / (2 * s1)
  cat(sprintf("   acc %.2f | max |mean z| = %.2f | max |sd z| = %.2f | E lambda: chain %.3f (se %.3f) vs exact %.3f\n",
              acc / M2, max(abs(m1 - m_ex) / se1), max(abs(s1 - s_ex) / se_s1), mean(L1), bm_se(L1), lam_ex))
  stopifnot(max(abs(m1 - m_ex) / se1) < 4, max(abs(s1 - s_ex) / se_s1) < 4, abs(mean(L1) - lam_ex) / bm_se(L1) < 4)

  cat("== test 7: joint (lambda, theta) jump move + conjugate lambda draw vs the same grid reference ==\n")
  th <- r; lam <- 2; S <- matrix(NA, M2, nn); L <- numeric(M2); accj <- 0
  for (i in seq_len(M2)) {
    st <- pmala_step(th, yy, zz, lam, sg, 1.0, cst, ord, "curv", 0, iters = 300L, kappa = 3); th <- st$theta
    lam <- rgamma(1, a0_ + mm, b0_ + sum(abs(diff(th))))
    lj <- lamjump_step(th, lam, a, r, a0_, b0_, mm, 1.0, 0.5, ord, 3, iters = 300L); th <- lj$theta; lam <- lj$lambda; accj <- accj + lj$accept
    S[i, ] <- th; L[i] <- lam
  }
  S1 <- S[-(1:5000), ]; L1 <- L[-(1:5000)]
  m1 <- colMeans(S1); se1 <- apply(S1, 2, bm_se); s1 <- apply(S1, 2, sd)
  se_s1 <- apply(S1, 2, function(v) bm_se((v - mean(v))^2)) / (2 * s1)
  cat(sprintf("   jump acc %.2f | max |mean z| = %.2f | max |sd z| = %.2f | E lambda: chain %.3f (se %.3f) vs exact %.3f\n",
              accj / M2, max(abs(m1 - m_ex) / se1), max(abs(s1 - s_ex) / se_s1), mean(L1), bm_se(L1), lam_ex))
  stopifnot(max(abs(m1 - m_ex) / se1) < 4, max(abs(s1 - s_ex) / se_s1) < 4, abs(mean(L1) - lam_ex) / bm_se(L1) < 4)
  cat("all tests passed\n")
}

# ---- Main --------------------------------------------------------------------
args <- commandArgs(trailingOnly = TRUE)
if (length(args) && args[1] == "test") { load_prox_cpp(cpp_src); run_tests(); quit(save = "no") }

load_prox_cpp(cpp_src)
dat <- simulate_data(seed, n, tau, baseline_id, noise_id)
set.seed(seed + 1000)
fit <- gibbs_pmala_aug(dat$y, tau, order, a0, b0, a_sigma, b_sigma,
                       gibbs_iter, gibbs_burn, delta_init, lambda_init,
                       adapt_target, adapt_gain, adapt_kappa, delta_bounds, tf_control,
                       metric = metric, c_fixed = c_metric, rho = admm_rho, iters = admm_iter,
                       mh = mh_correct, adapt = adapt_delta, init = theta_init, warm = warm_sweeps, gamma_warm = gamma_warm,
                       K = K_theta, asis = asis_lambda, tol = admm_tol, lamjump = lamjump, lamjump_s = lamjump_s,
                       prior_scale = prior_scale, cmap = FALSE, kappa = kappa_metric, adapt_all = adapt_all)

est  <- colMeans(fit$theta)
lo   <- apply(fit$theta, 2, quantile, 0.025); hi <- apply(fit$theta, 2, quantile, 0.975)
post <- (gibbs_burn + 1):gibbs_iter
res <- data.frame(
  baseline = baseline_id, noise = noise_id, tau = tau, n = n, seed = seed, metric = metric, kappa = kappa_metric, prior_scale = prior_scale, a0 = a0, b0 = b0,
  theta_init = theta_init, warm_sweeps = warm_sweeps, admm_iter = admm_iter,
  mh_correct = mh_correct, adapt_delta = adapt_delta,
  mse = mean((est - dat$truth)^2), mad = mean(abs(est - dat$truth)),
  mciw = mean(hi - lo), coverage = mean(dat$truth >= lo & dat$truth <= hi),
  acc_post = fit$acc_post, delta_final = fit$delta_final,
  lambda_mean = mean(fit$lambda[post]), sigma_mean = mean(fit$sigma[post]),
  seconds = fit$seconds)
print(t(res))
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)
write.csv(res, file.path(out_dir, "pmala_aug_pilot.csv"), row.names = FALSE)

png(file.path(out_dir, "pmala_aug_fit.png"), width = 1400, height = 700, res = 130)
plot(dat$x, dat$y, pch = 16, cex = 0.4, col = "grey70", xlab = "index", ylab = "y",
     main = sprintf("Augmented P-MALA, metric %s, b0 = %g | %s | %s | tau = %.2f | MSE = %.5f | cov = %.3f",
                    metric, b0, baseline_id, noise_id, tau, res$mse, res$coverage))
polygon(c(dat$x, rev(dat$x)), c(lo, rev(hi)), col = adjustcolor("firebrick", 0.2), border = NA)
lines(dat$x, dat$truth, lwd = 2); lines(dat$x, est, col = "firebrick", lwd = 2, lty = 2)
dev.off()

png(file.path(out_dir, "pmala_aug_traces.png"), width = 1400, height = 900, res = 130)
par(mfrow = c(2, 2))
plot(fit$lambda, type = "l", main = "lambda", xlab = "sweep"); abline(v = gibbs_burn, lty = 3)
plot(fit$sigma,  type = "l", main = "sigma",  xlab = "sweep"); abline(v = gibbs_burn, lty = 3)
plot(fit$delta,  type = "l", log = "y", main = "delta (adapted in burn-in)", xlab = "sweep"); abline(v = gibbs_burn, lty = 3)
plot(fit$theta[, n %/% 2], type = "l", main = sprintf("theta[%d] (post burn-in)", n %/% 2), xlab = "kept sweep")
dev.off()
