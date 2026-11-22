# =============================================================================
# Growth centiles (Fifth Dutch Growth Study): joint (non-crossing) P-MALA / Gibbs sampler, k = 2.
# COPY of Simulations/Joint/Joint_Sampler_PMALA_Augmented.R (2026-10-13), adapted to repeated observations:
#   theta_j lives on the G equally spaced 0.1-year age slots; child i sits at slot g_i.  Given z_j, the augmented likelihood of
#   level j collapses to one Gaussian pseudo-observation per slot (agg_ar: weight = sum of a_i, centre = a-weighted mean of r_i);
#   z_j and sigma_j stay per child.  The grid is regular, so D is the plain (k+1)-th difference and the C++ kernels
#   (Simulations/Joint/prox_box_metric.cpp, which #includes Simulations/Individual/prox_admm_metric.cpp) are used UNCHANGED.
#   With one observation per slot every function reduces to the original (agg_ar returns (a_i, r_i) exactly).
#   Everything else (blocks, box, metric, ASIS, adaptation, priors, defaults) is the original's.  The original's simulation
#   generator, paper-MSE table and test suites are not copied (the kernels they test are unchanged); the adaptation is checked
#   by Growth_Joint_checks.R.
#
# Target.  Levels tau_1 < ... < tau_J, each with its own (theta_j, z_j, lambda_j, sigma_j) and the individual model
#   y_i = theta_{g_i, j} + eps_ij,  eps_ij ~ ALD(0, sigma_j, tau_j)  (Kozumi-Kobayashi augmentation, Laplace prior on D theta_j,
#   lambda_j ~ Gamma(a0, b0), sigma_j ~ IG(a_sigma, b_sigma)),  coupled only by the order indicator
#   pi_C(Theta, Z, lambda, sigma | y)  propto  1{theta_1 <= theta_2 <= ... <= theta_J componentwise} prod_j pi_j(theta_j, z_j, lambda_j, sigma_j | y).
#
# One Gibbs sweep visits j = 1..J in increasing order and completes all of level j's updates before moving on, with the box
#   B_j = [ell_j, u_j],  ell_j = theta_{j-1} (already updated this sweep),  u_j = theta_{j+1} (previous sweep),  +-Inf at the ends.
#   Block 1  theta_j | z_j, lambda_j, sigma_j, B_j   P-MALA whose proximal map is the BOX-CONSTRAINED problem
#            T_B(x) = argmin_{theta in B_j} U_j(theta) + ||theta - x||_M^2 / (2 gamma),  M = diag(a) + kappa (lambda^2/2) D'D
#            U_j(theta) = sum_s a_s/2 (theta_s - r_s)^2 + lambda ||D theta||_1 on the per-slot aggregated (a, r).
#            Proposal theta* ~ N(T_B(theta), delta M^{-1}); outside B_j: reject; otherwise the usual MH ratio.
#   Block 2  z_j | theta_j, sigma_j          individual InvGauss draw, per child (e_i = y_i - theta_{g_i, j})
#   Block 3  lambda_j | theta_j              Gamma(a0 + m, b0 + ||D theta_j||_1), then the ASIS redraw restricted to the box
#   Block 4  sigma_j | theta_j, z_j          individual IG draw over the N children
#
# Usage:  Rscript Growth_Joint_PMALA_k2.R [sex=boy|girl] [out=DIR] [draws=DIR] [kernels=DIR] [gibbs_iter=N] [gibbs_burn=N]
#   kernels=DIR: folder with subfolders Joint/ (prox_box_metric.cpp) and Individual/ (prox_admm_metric.cpp), the layout of
#   Simulations/ (frozen run snapshots; the two files must not share a folder, or sourceCpp also compiles the #included one);
#   default: ../../Simulations/Joint and ../../Simulations/Individual relative to this script.
# =============================================================================

suppressPackageStartupMessages(library(glmgen))
`%||%` <- function(a, b) if (is.null(a)) b else a

# ---- Locate this script's folder (data/fdgs.csv beside it) -----------------------------------------------------------------
.norm <- function(p) {
  if (is.null(p) || length(p) != 1L || is.na(p) || !nzchar(p)) return(NA_character_)
  tryCatch(normalizePath(p, winslash = "/", mustWork = FALSE), error = function(e) NA_character_)
}
.script_dir <- function(target = file.path("data", "fdgs.csv")) {
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  p <- if (length(a)) .norm(sub("^--file=", "", a[[1L]])) else NA_character_
  if (is.na(p)) p <- .norm(tryCatch(sys.frame(1)$ofile, error = function(e) NULL))
  if (is.na(p) && requireNamespace("rstudioapi", quietly = TRUE) &&
      isTRUE(tryCatch(rstudioapi::isAvailable(), error = function(e) FALSE)))
    p <- .norm(tryCatch(rstudioapi::getActiveDocumentContext()$path, error = function(e) NA_character_))
  if (!is.na(p) && file.exists(file.path(dirname(p), target))) return(dirname(p))
  rel <- file.path("Data Applications", "Growth")
  up <- character(0); d <- .norm(getwd())
  while (!is.na(d) && !(d %in% up)) { up <- c(up, d); d <- dirname(d) }
  cand <- c(up, file.path(up, rel), file.path(c("~", "~/Documents", "~/OneDrive/Documents"), "Quantile Regression", rel))
  hit <- cand[file.exists(file.path(cand, target))]
  if (length(hit)) return(.norm(hit[[1L]]))
  stop("Could not find ", target, ". Open this script from Data Applications/Growth, or setwd() there.")
}
script_dir <- .script_dir()

# ---- Settings (the joint script's saved values; only tau_list, the data and the seed differ) -----------------------------
tau_list    <- c(0.1, 0.3, 0.5, 0.7, 0.9)   # ordered quantile levels sampled jointly
sex         <- "boy"       # "boy" | "girl"
seed        <- 2026
order       <- 2L          # k = 2: piecewise quadratic; D = 3rd differences
a0 <- 1;  b0 <- 0.01       # Gamma prior on lambda (joint script value)
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
admm_iter    <- 150L
admm_tol     <- 0
K_theta      <- 1L
asis_lambda  <- TRUE
admm_rho     <- NULL
zeta_scale   <- 1
box_ctrl     <- c(method = 1, try_unbounded = 1, ipm_max_iter = 100, ipm_tol = 1e-8, trace = 0)   # see prox_box_metric.cpp

# key=value overrides (sex, out, draws, kernels, gibbs_iter, gibbs_burn, seed)
kv <- grep("=", commandArgs(trailingOnly = TRUE), value = TRUE)
kv <- as.list(setNames(sub("^[^=]*=", "", kv), sub("=.*$", "", kv)))   # list: kv[["absent"]] is NULL
if (!is.null(kv$sex))        sex <- kv$sex
if (!is.null(kv$gibbs_iter)) gibbs_iter <- as.integer(kv$gibbs_iter)
if (!is.null(kv$gibbs_burn)) gibbs_burn <- as.integer(kv$gibbs_burn)
if (!is.null(kv$seed))       seed <- as.numeric(kv$seed)
stopifnot(sex %in% c("boy", "girl"))
kernel_root <- kv$kernels %||% file.path(dirname(dirname(script_dir)), "Simulations")
joint_dir <- file.path(kernel_root, "Joint")
ind_dir   <- file.path(kernel_root, "Individual")
out_dir   <- kv$out   %||% file.path(script_dir, "results_joint_k2", sex)
draws_dir <- kv$draws %||% out_dir

# ---- C++ kernel: the unbounded kernel (#included) and the bounded one (unchanged from the joint script) -------------------
load_box_cpp <- function(joint_dir, ind_dir) {
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

# ---- Data: Fifth Dutch Growth Study (mice::fdgs), one sex, height in cm on 0.1-year age slots ------------------------------
load_growth <- function(dir, sex) {
  d <- read.csv(file.path(dir, "data", "fdgs.csv"))
  d <- d[d$sex == sex & !is.na(d$hgt), ]
  s <- as.integer(round(10 * d$age))                         # slot index in tenths of a year (integer: no floating ties)
  sl <- sort(unique(s)); stopifnot(all(diff(sl) == 1L))       # every slot occupied: regular grid, D needs no reweighting
  o <- order(s)
  list(y = d$hgt[o], age = d$age[o], x = sl / 10, g = match(s[o], sl))
}

# ---- Model pieces (verbatim from the joint script unless marked) ---------------------------------------------------------
ald_const <- function(tau) list(psi = (1 - 2 * tau) / (tau * (1 - tau)), t2 = 2 / (tau * (1 - tau)))
Dtheta  <- function(theta, order) diff(theta, differences = order + 1L)
rho_tau <- function(u, tau) u * (tau - (u < 0))
U_cond  <- function(theta, a, r, lambda, order) sum(a * (theta - r)^2) / 2 + lambda * sum(abs(Dtheta(theta, order)))
# [new] Repeated observations: per-child Gaussian terms a_i/2 (theta_{g_i} - r_i)^2, a_i = 1/(t2 sigma z_i), r_i = y_i - psi z_i,
# sum within each slot to A_s/2 (theta_s - R_s)^2 + const, A_s = sum a_i, R_s = sum (a_i/A_s) r_i.
# (Weights a_i/A_s instead of sum(a_i r_i)/A_s: with one child per slot the weight is exactly 1, so R = r bitwise.)
agg_ar <- function(y, z, sigma, cst, g, n) {
  a_i <- 1 / (cst$t2 * sigma * z); r_i <- y - cst$psi * z
  A <- as.numeric(rowsum(a_i, g, reorder = TRUE))
  stopifnot(length(A) == n)                                    # every slot carries at least one child
  list(a = A, r = as.numeric(rowsum((a_i / A[g]) * r_i, g, reorder = TRUE)))
}
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
draw_sigma <- function(y, theta, z, cst, a_sigma, b_sigma, lambda_SD = 0, m = 0) {   # y, theta = theta[g], z per child: n here is N
  n <- length(y)
  ss <- sum((y - theta - cst$psi * z)^2 / (2 * cst$t2 * z)) + sum(z)
  1 / rgamma(1, shape = a_sigma + 1.5 * n + m, rate = b_sigma + ss + lambda_SD)
}
pmala_step <- function(theta, y, z, lambda, sigma, delta, cst, order, g, metric = "curv", c_fixed = 0,
                       rho = NULL, iters = 200L, mh = TRUE, kappa = 1, tol = 0) {
  gamma <- delta / 2
  ar <- agg_ar(y, z, sigma, cst, g, length(theta)); a <- ar$a; r <- ar$r                 # [changed] per-slot (a, r)
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
asis_step <- function(theta, lambda, a, r, a0, b0, Q, w = 1, max_steps = 30L) {
  th_par <- Q %*% crossprod(Q, theta); th_perp <- theta - th_par
  logf <- function(eta) { lam <- exp(eta); th <- th_par + (lambda / lam) * th_perp
    a0 * eta - b0 * lam - sum(a * (th - r)^2) / 2 }
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
null_basis <- function(n, order) qr.Q(qr(outer(seq_len(n) / n, 0:order, `^`)))

# ---- Box pieces (verbatim unless marked) -----------------------------------------------------------------------------------
box_penalties <- function(a, d, c, gamma, rho = NULL, zeta_scale = 1)
  list(rho = if (is.null(rho)) 0.1 * (mean(d) + c) / gamma else rho, zeta = zeta_scale * (a + d / gamma))
in_box <- function(theta, lower, upper) all(theta >= lower & theta <= upper)
prox_box <- function(x, a, r, lambda, gamma, d, c, order, lower, upper, rho = NULL, zeta_scale = 1, iters = 200L, tol = 0, ctrl = box_ctrl) {
  pen <- box_penalties(a, d, c, gamma, rho, zeta_scale)
  prox_box_metric(x, a, r, lambda, gamma, d, c, order, pen$rho, pen$zeta, iters, tol, lower, upper, ctrl)
}
pmala_box_step <- function(theta, y, z, lambda, sigma, delta, cst, order, g, lower, upper, metric = "curv", c_fixed = 0,
                           rho = NULL, iters = 200L, mh = TRUE, kappa = 1, tol = 0, zeta_scale = 1, ctrl = box_ctrl) {
  gamma <- delta / 2
  ar <- agg_ar(y, z, sigma, cst, g, length(theta)); a <- ar$a; r <- ar$r                 # [changed] per-slot (a, r)
  M <- metric_dc(metric, a, lambda, c_fixed, kappa); d <- M$d; c <- M$c
  pen <- box_penalties(a, d, c, gamma, rho, zeta_scale)
  if (!mh) {
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
asis_scale_domain <- function(p, v, lower, upper) {
  lo <- 0; hi <- Inf
  for (i in seq_along(p)) {
    if (v[i] == 0) { if (p[i] < lower[i] || p[i] > upper[i]) return(c(Inf, -Inf)) }
    else { e <- sort(c((lower[i] - p[i]) / v[i], (upper[i] - p[i]) / v[i])); lo <- max(lo, e[1]); hi <- min(hi, e[2]) }
  }
  c(lo, hi)
}
asis_box_step <- function(theta, lambda, a, r, a0, b0, Q, lower, upper, w = 1, max_steps = 30L) {
  th_par <- as.numeric(Q %*% crossprod(Q, theta)); th_perp <- theta - th_par
  dom <- asis_scale_domain(th_par, th_perp, lower, upper); unchanged <- list(lambda = lambda, theta = theta, moved = FALSE)
  if (!(dom[1] < dom[2]) || dom[2] <= 0) return(unchanged)
  eta0 <- log(lambda); eta_lo <- eta0 - log(dom[2]); eta_hi <- eta0 - log(dom[1])
  logf <- function(eta) {
    if (eta < eta_lo || eta > eta_hi) return(-Inf)
    lam <- exp(eta); th <- th_par + (lambda / lam) * th_perp
    if (!in_box(th, lower, upper)) return(-Inf)
    a0 * eta - b0 * lam - sum(a * (th - r)^2) / 2
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
# y, g: per child (g_i in 1..n = age slot of child i); theta: n x J.
# init_scale [new]: spread of the ordered initial curves; NULL -> pooled within-slot sd of y (the original uses sd(y), which on
#   repeated data would include the growth trend itself); pass sd(y) to reproduce the original's initial state.
gibbs_joint_pmala <- function(y, g, tau_list, order, a0, b0, a_sigma, b_sigma,
                              gibbs_iter, gibbs_burn, delta_init, lambda_init,
                              adapt_target, adapt_gain, adapt_kappa, delta_bounds,
                              metric = "curv", c_fixed = 0, rho = NULL, iters = 200L,
                              mh = TRUE, adapt = TRUE, warm = 0L, gamma_warm = 1e3,
                              kappa = 1, adapt_all = TRUE, K = 1L, asis = FALSE, tol = 0,
                              zeta_scale = 1, ctrl = box_ctrl, verbose = TRUE, keep_every = 1L, init_scale = NULL) {
  stopifnot(length(tau_list) >= 1, all(diff(tau_list) > 0), all(tau_list > 0 & tau_list < 1), warm <= gibbs_burn, gibbs_burn < gibbs_iter)
  N <- length(y); n <- max(g); m <- n - order - 1L; J <- length(tau_list)
  stopifnot(length(g) == N, all(g %in% seq_len(n)), all(tabulate(g, n) > 0))
  Q <- if (asis) null_basis(n, order) else NULL
  cst <- lapply(tau_list, ald_const)
  # init: theta_j = ybar + s (Phi^-1(tau_j) - median Phi^-1(tau)) for J > 1 (ordered, data-based, no RNG); exactly ybar for J = 1.
  # ybar = per-slot mean of y (= y with one child per slot).  Hyperparameters at the individual defaults: sigma = 1, z = sigma, lambda = m.
  ybar <- as.numeric(rowsum(y, g, reorder = TRUE)) / tabulate(g, n)
  s_init <- init_scale %||% max(sd(y - ybar[g]), 0.1)
  off <- if (J == 1) 0 else s_init * (qnorm(tau_list) - median(qnorm(tau_list)))
  theta <- sapply(off, function(o) ybar + o); if (!is.matrix(theta)) theta <- matrix(theta, n, J)
  sigma <- rep(1, J); z <- matrix(1, N, J); lambda <- rep(if (is.null(lambda_init)) m else lambda_init, J); delta <- rep(delta_init, J)
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
        ar <- agg_ar(y, zj, sg, cs, g, n); a <- ar$a; r <- ar$r
        th <- if (free) prox_T(th, a, r, lam, gamma_warm, a, 0, order, rho = median(a), iters = 2L * iters)
              else prox_box(th, a, r, lam, gamma_warm, a, 0, order, lower, upper, rho = median(a), zeta_scale = zeta_scale, iters = 2L * iters, ctrl = ctrl)$theta
        st <- list(theta = th, accept = NA, log_alpha = NA, outside = NA, ipm = NA)
      } else {                                                                 # Block 1: K P-MALA moves at fixed (z, lambda, sigma, box)
        acc_k <- la_k <- out_k <- ipm_k <- numeric(K)
        for (kk in seq_len(K)) {
          st <- if (free) c(pmala_step(th, y, zj, lam, sg, dl, cs, order, g, metric, c_fixed, rho, iters, mh, kappa, tol), list(outside = FALSE, ipm = 0))
                else pmala_box_step(th, y, zj, lam, sg, dl, cs, order, g, lower, upper, metric, c_fixed, rho, iters, mh, kappa, tol, zeta_scale, ctrl)
          th <- st$theta; acc_k[kk] <- st$accept; la_k[kk] <- exp(st$log_alpha); out_k[kk] <- st$outside; ipm_k[kk] <- st$ipm
        }
        st <- list(theta = th, accept = mean(acc_k), log_alpha = log(mean(la_k)), outside = mean(out_k), ipm = mean(ipm_k))
      }
      n_acc[j] <- n_acc[j] + if (is.na(st$accept)) 0 else st$accept
      zj  <- draw_z(y - th[g], tau_list[j], sg)                                # Block 2 (per child)
      SD  <- sum(abs(Dtheta(th, order)))
      lam <- rgamma(1, shape = a0 + m, rate = b0 + SD)                         # Block 3 (sufficient parameterisation)
      moved <- NA
      if (asis && it > warm) {                                                 # Block 3b: ancillary redraw (restricted to the box), theta rescales
        ar <- agg_ar(y, zj, sg, cs, g, n)
        as_ <- if (free) asis_step(th, lam, ar$a, ar$r, a0, b0, Q) else asis_box_step(th, lam, ar$a, ar$r, a0, b0, Q, lower, upper)
        moved <- if (free) TRUE else as_$moved
        lam <- as_$lambda; th <- as_$theta; SD <- sum(abs(Dtheta(th, order)))
      }
      sg <- draw_sigma(y, th[g], zj, cs, a_sigma, b_sigma, lambda_SD = 0, m = 0)   # Block 4 (per child)
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
       delta_final = delta, final = list(theta = theta, z = z, sigma = sigma, lambda = lambda),
       seconds = proc.time()[["elapsed"]] - t0)
}

# ---- Crossing metrics (verbatim) -------------------------------------------------------------------------------------------
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

# ---- Main --------------------------------------------------------------------------------------------------------------------
if (sys.nframe() == 0L) {                                      # skipped when source()d by the check script
load_box_cpp(joint_dir, ind_dir)
dat <- load_growth(script_dir, sex); J <- length(tau_list); n <- length(dat$x)
cat(sprintf("Growth (%s): N = %d children at n = %d age slots (%.1f-%.1f y), k = %d, levels %s | %d sweeps, %d burn-in, b0 = %g\n",
            sex, length(dat$y), n, min(dat$x), max(dat$x), order, paste(tau_list, collapse = ","), gibbs_iter, gibbs_burn, b0))
set.seed(seed + if (sex == "girl") 2L else 1L)
fit <- gibbs_joint_pmala(dat$y, dat$g, tau_list, order, a0, b0, a_sigma, b_sigma,
                         gibbs_iter, gibbs_burn, delta_init, lambda_init,
                         adapt_target, adapt_gain, adapt_kappa, delta_bounds,
                         metric = metric, c_fixed = c_metric, rho = admm_rho, iters = admm_iter,
                         mh = mh_correct, adapt = adapt_delta, warm = warm_sweeps, gamma_warm = gamma_warm,
                         kappa = kappa_metric, adapt_all = adapt_all, K = K_theta, asis = asis_lambda, tol = admm_tol,
                         zeta_scale = zeta_scale, ctrl = box_ctrl)
est <- apply(fit$theta, c(2, 3), mean)
lo  <- apply(fit$theta, c(2, 3), quantile, 0.025); hi <- apply(fit$theta, c(2, 3), quantile, 0.975)
post <- (gibbs_burn + 1):gibbs_iter
ess_th <- sapply(seq_len(J), function(j) coda::effectiveSize(coda::mcmc(fit$theta[, , j])))
diag_tab <- data.frame(sex = sex, tau = tau_list, k = order, a0 = a0, b0 = b0, gibbs_iter = gibbs_iter, gibbs_burn = gibbs_burn,
  frac_below = colMeans(dat$y < est[dat$g, , drop = FALSE]),
  acc_post = fit$acc_post, outside_rate = fit$outside_post, ipm_share = fit$ipm_post, asis_moved = fit$asis_moved_post, delta_final = fit$delta_final,
  lambda_mean = colMeans(fit$lambda[post, , drop = FALSE]), sigma_mean = colMeans(fit$sigma[post, , drop = FALSE]),
  ess_theta_median = apply(ess_th, 2, median), ess_theta_min = apply(ess_th, 2, min),
  ess_lambda = apply(fit$lambda[post, , drop = FALSE], 2, function(v) as.numeric(coda::effectiveSize(v))),
  seconds = fit$seconds)
summ_tab <- do.call(rbind, lapply(seq_len(J), function(j) data.frame(age = dat$x, tau = tau_list[j], estimate = est[, j], lower = lo[, j], upper = hi[, j])))
cm <- crossing_metrics(est, fit$theta)
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE); dir.create(draws_dir, showWarnings = FALSE, recursive = TRUE)
write.csv(diag_tab, file.path(out_dir, "sampler_diagnostics.csv"), row.names = FALSE)
write.csv(summ_tab, file.path(out_dir, "posterior_summary.csv"), row.names = FALSE)
write.csv(cm$all_pairs, file.path(out_dir, "crossings.csv"), row.names = FALSE)
saveRDS(list(sex = sex, x = dat$x, tau = tau_list, theta = fit$theta, lambda = fit$lambda, sigma = fit$sigma, delta = fit$delta,
             acc = fit$acc, outside = fit$outside, ipm = fit$ipm, SD = fit$SD, seconds = fit$seconds),
        file.path(draws_dir, sprintf("fit_joint_%s.rds", sex)))
png(file.path(out_dir, "traces.png"), width = 1400, height = 300 * J, res = 130)
par(mfrow = c(J, 4), mar = c(4, 4, 2, 1)); jm <- which.min(abs(dat$x - 10))
for (j in seq_len(J)) {
  plot(fit$lambda[, j], type = "l", main = sprintf("lambda, tau = %.2f", tau_list[j]), xlab = "sweep"); abline(v = gibbs_burn, lty = 3)
  plot(fit$sigma[, j],  type = "l", main = "sigma",  xlab = "sweep"); abline(v = gibbs_burn, lty = 3)
  plot(fit$delta[, j],  type = "l", log = "y", main = "delta", xlab = "sweep"); abline(v = gibbs_burn, lty = 3)
  plot(fit$theta[, jm, j], type = "l", main = sprintf("theta at %.1f y (kept)", dat$x[jm]), xlab = "kept sweep")
}
dev.off()
cat("\n==== per-level results ====\n"); print(diag_tab, digits = 4, row.names = FALSE)
cat("\n==== crossings between adjacent levels (posterior means and draws) ====\n"); print(cm$adjacent, digits = 4, row.names = FALSE)
cat(sprintf("\ntotal time %.0f s\n", fit$seconds))
}
