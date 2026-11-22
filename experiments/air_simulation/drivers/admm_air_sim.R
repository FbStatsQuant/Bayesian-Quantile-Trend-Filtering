# =============================================================================
# Air-quality-like simulation (Brantley, Guinness & Chi 2020, Section 4.2 "Peak detection")
# fitted with the authors' own quantile trend filtering code (detrendr), following their simulation scripts.
#
#   y_i = theta_i + s_i + eps_i,   i = 1, ..., n,   eps_i ~ N(0, 0.25^2)
#
#   theta (drift): natural cubic spline basis on x = (i - 0.5)/n with df ~ Poisson(n/100) + 1,
#                  coefficients ~ Exp(rate 1)
#   s (signal):    sum of Gaussian-density peaks; #peaks ~ Bin(n, 0.005), centers ~ U(1, n-1) (rounded),
#                  bandwidths ~ U(2, 12), each scaled by an area ~ N(20, 4^2)
#
# Generator transcribed from the authors' detrendr package, R/simluate_peaks.R (generate_peaks),
# https://github.com/halleybrantley/detrendr -- note the "+ 1" on the spline df, which the paper text omits.
# Identical to generate_peaks_design() in the authors' simulation code (detrendify repo, Code/sim_generating_functions.R).
#
# Fit: the authors' procedure, from https://github.com/halleybrantley/detrendify (Code/Sim_detrendr.R, Code/Sim_Xing.R):
#   get_trend_BIC(y, tau = c(0.01, 0.05, 0.1), k = 3, lambdaSeq = n^seq(0, 1.4, length.out = 15), criteria = "eBIC")
#   * objective (paper eq. 3): sum_j [ rho_tau_j(y - theta_j) + lambda_j ||D^(3) theta_j||_1 ], theta_1 <= theta_2 <= theta_3
#     (non-crossing), solved exactly as one linear program (detrendr R/get_model.R, R/solve_functions.R).
#   * lambda (paper Section 3): all quantiles fit with a common lambda over the grid; lambda_j = argmin of the scaled eBIC
#     evaluated at tau_j, eBIC = 2 rho_tau(y - theta_j)/sigma + nu log n + 2 gamma log choose(n - k, nu), sigma = (1 - |1 - 2 tau|)/2,
#     gamma = 1, nu = #{|D theta_j| > 1e-9}; then the non-crossing trends are refit with the selected lambda_j
#     (detrendr R/get_trend_BIC.R, R/get_criteria.R).
#   * "ADMM": the paper's ADMM (Section 2.3, Algorithm 1) splits long series into overlapping windows. In the Section 4.2
#     simulation the reported methods (detrend_eBIC/_SIC/_valid/_Xing, Figures 8 and 10) solve the full-series LP above;
#     the windowed ADMM fit ("windows", 3 windows, overlap n/10) appears only in Supplement Figures 1-2, run on 10 seeds
#     (Code/Sim_windows.R; Manuscript/detrendify_supplement.tex). The paper (Section 2.3) reports the windowed and
#     single-window estimates are nearly indistinguishable.
#   * solver: the paper used Gurobi (Section 2.2); detrendr falls back to Rglpk, then lpSolve, when gurobi is absent.
#     The LP optimum is solver-independent up to solver tolerance (and up to ties if the LP has several optima).
#
# Target and metric as for the other samplers: theta_tau = theta + 0.25 * qnorm(tau), RMSE over all n points
# (paper lines 745-746; authors' Code/Fig8_sim_peaks_rmse.R).
# =============================================================================

suppressPackageStartupMessages({ library(splines); library(ggplot2); library(Matrix); library(detrendr) })
`%||%` <- function(a, b) if (is.null(a)) b else a

# ---- Settings ---------------------------------------------------------------
seed   <- 1
n      <- 500L
sd_eps <- 0.25
taus   <- c(0.1)   # paper's levels for the peaks design (Section 4.2)

method    <- "eBIC"   # "eBIC"  detrend_eBIC: quantiles fit jointly with the non-crossing constraint, lambda_j by eBIC
                      #         (the paper's proposed method; Code/Sim_detrendr.R)
                      # "Xing"  detrend_Xing: each quantile fit separately (no non-crossing), lambda by eBIC (Code/Sim_Xing.R)
                      # "SIC"   detrend_SIC:  joint non-crossing fit, lambda_j by SIC
                      # "valid" detrend_valid: joint non-crossing fit, lambda_j by check loss on every 5th observation held out
k_diff    <- 3L                                 # detrendr's k = order of differencing: D^(3), the paper's k = 2 (piecewise quadratic)
lambdaSeq <- n^seq(0, 1.4, length.out = 15)     # lambda grid of Code/Sim_detrendr.R and Code/Sim_Xing.R
solver    <- NULL                               # NULL: detrendr's choice (gurobi if installed, else Rglpk, else lpSolve)

# ---- Data -------------------------------------------------------------------
simulate_air <- function(seed, n, sd_eps = 0.25) {
  RNGkind("Mersenne-Twister", "Inversion", "Rejection")
  set.seed(seed)
  x  <- seq(0.5, n, 1) / n
  df <- rpois(1, n / 100) + 1
  B  <- ns(x, df = df)                                  # n x df natural cubic spline basis
  beta  <- rexp(ncol(B), 1)
  theta <- as.numeric(B %*% beta)

  n_peaks <- rbinom(1, n, 0.005)
  centers <- round(runif(n_peaks) * (n - 2) + 1)
  areas   <- rnorm(n_peaks, 20, 4)
  widths  <- runif(n_peaks) * 10 + 2
  s <- numeric(n)
  for (j in seq_len(n_peaks)) s <- s + areas[j] * dnorm(seq_len(n), mean = centers[j], sd = widths[j])

  eps <- sd_eps * rnorm(n)
  list(t = seq_len(n), x = x, y = theta + s + eps, theta = theta, s = s, eps = eps,
       df = df, B = B, beta = beta, peaks = data.frame(center = centers, area = areas, width = widths))
}

dat <- simulate_air(seed, n, sd_eps)
cat(sprintf("n = %d | spline df = %d | peaks = %d\n", n, dat$df, nrow(dat$peaks)))
print(dat$peaks)

# ---- Plots ------------------------------------------------------------------
pd <- data.frame(t = dat$t, y = dat$y, theta = dat$theta, s = dat$s, eps = dat$eps)

print(ggplot(pd, aes(t, theta)) + geom_line(linewidth = 0.8) +
        labs(title = sprintf("Drift theta: natural cubic spline, df = %d, Exp(1) coefficients", dat$df),
             x = "t", y = expression(theta)) + theme_bw())

print(ggplot(pd, aes(t, s)) + geom_line(linewidth = 0.6, colour = "firebrick") +
        labs(title = sprintf("Signal s: %d Gaussian peaks", nrow(dat$peaks)), x = "t", y = "s") + theme_bw())

print(ggplot(pd, aes(t, eps)) + geom_point(size = 0.6, colour = "grey40") +
        labs(title = sprintf("Noise eps ~ N(0, %.2f^2)", sd_eps), x = "t", y = expression(epsilon)) + theme_bw())

print(ggplot(pd, aes(t, s + eps)) + geom_point(size = 0.6, colour = "grey40") +
        labs(title = "s + eps (y with the drift removed)", x = "t", y = expression(s + epsilon)) + theme_bw())

print(ggplot(pd, aes(t, y)) + geom_point(size = 0.6, colour = "grey50") +
        labs(title = "y = theta + s + eps", x = "t", y = "y") + theme_bw())

# ---- detrendr ---------------------------------------------------------------
# install: remotes::install_github("halleybrantley/detrendr")  (last commit 17e3e7c, 2019-05-09)
sha <- packageDescription("detrendr")$RemoteSha
if (is.null(sha) || !startsWith(sha, "17e3e7c"))
  warning("detrendr is not the GitHub version 17e3e7c used here (RemoteSha = ", sha %||% "none", ")")
# detrendr::get_model tests `if (tau >= 1 || tau <= 0)`. Since R 4.3.0 `||` on a vector tau is an error, so the joint
# (non-crossing) fits stop before solving. Replace that one condition by its vectorised form; nothing else changes.
if (getRversion() >= "4.3.0") {
  gm <- detrendr::get_model
  if (identical(body(gm)[[2]][[2]], quote(tau >= 1 || tau <= 0))) {
    body(gm)[[2]][[2]] <- quote(any(tau >= 1 | tau <= 0))
    assignInNamespace("get_model", gm, ns = "detrendr")
  }
}
cat(sprintf("\nLP solver: %s\n", solver %||% (if (requireNamespace("gurobi", quietly = TRUE)) "gurobi"
                                               else if (requireNamespace("Rglpk", quietly = TRUE)) "Rglpk" else "lpSolve")))

# ---- Fit ----------------------------------------------------------------------
t0 <- proc.time()[["elapsed"]]
if (method == "Xing") {
  fits  <- lapply(taus, function(tau) get_trend_BIC(dat$y, tau, k_diff, lambdaSeq = lambdaSeq, criteria = "eBIC", solver = solver))
  trend <- sapply(fits, function(f) as.numeric(f$trend))
  lambda_hat <- sapply(fits, `[[`, "lambda")
} else {
  fit   <- get_trend_BIC(dat$y, taus, k_diff, lambdaSeq = lambdaSeq, criteria = method, solver = solver)
  trend <- as.matrix(fit$trend)
  lambda_hat <- fit$lambda
}
seconds <- proc.time()[["elapsed"]] - t0

D   <- get_Dk(n, k_diff)
res <- vector("list", length(taus)); qd <- vector("list", length(taus))
for (j in seq_along(taus)) {
  truth <- dat$theta + sd_eps * qnorm(taus[j])                  # theta_tau: tau-quantile of y - s
  est   <- trend[, j]
  res[[j]] <- data.frame(tau = taus[j], rmse = sqrt(mean((est - truth)^2)), mad = mean(abs(est - truth)),
                         lambda = lambda_hat[j], nu = sum(abs(as.numeric(D %*% est)) > 1e-9))
  qd[[j]] <- data.frame(t = dat$t, tau = taus[j], truth = truth, est = est)
}
res <- do.call(rbind, res)
cat(sprintf("\nmethod = detrend_%s | lambda grid n^seq(0, 1.4, length.out = 15) | %.1f s\n", method, seconds))
print(res, digits = 4)

# ---- Plot: true vs estimated quantile ---------------------------------------
qd <- do.call(rbind, qd)
lab <- sprintf("tau = %.2f   |   RMSE = %.4f", res$tau, res$rmse)
qd$panel <- factor(lab[match(qd$tau, res$tau)], levels = lab)
est_lab  <- sprintf("detrend_%s estimate", method)

print(ggplot(qd, aes(t)) +
        geom_line(aes(y = truth, colour = "true", linetype = "true"), linewidth = 0.7) +
        geom_line(aes(y = est, colour = "estimated", linetype = "estimated"), linewidth = 0.7) +
        facet_wrap(~ panel, ncol = 1, scales = "free_y") +
        scale_colour_manual(NULL, breaks = c("true", "estimated"), values = c(true = "black", estimated = "firebrick"),
                            labels = c(true = expression(theta[tau] == theta + 0.25 * Phi^-1 * (tau)), estimated = est_lab)) +
        scale_linetype_manual(NULL, breaks = c("true", "estimated"), values = c(true = "solid", estimated = "dashed"),
                              labels = c(true = expression(theta[tau] == theta + 0.25 * Phi^-1 * (tau)), estimated = est_lab)) +
        labs(title = sprintf("True vs estimated quantile trend (n = %d, seed = %d, k = 2)", n, seed),
             x = "t", y = "quantile") +
        theme_bw() + theme(legend.position = "top"))
