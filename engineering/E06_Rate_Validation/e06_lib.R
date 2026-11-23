# =============================================================================
# E-06 rate validation: extensions on top of the E-02 library (exact banded Gibbs, MAP, Delta2).
# Sourced AFTER e02_lib.R; it redefines the noise laws (make_data looks them up globally) and adds
# the sigma arms and lambda schedules of the E-06 design (DESIGN.md).
#
# Noise laws: Gaussian, Laplace, t3, t2, Cauchy, each scaled so that the density at the median equals
# the Gaussian N(0, 0.5^2) one, f(0) = 0.7979.  So the laws share their local information at tau = 1/2
# and differ only in their tails.
# =============================================================================
F0 <- dnorm(0, 0, 0.5)
STD <- list(   # standard law: quantile, density, sampler (inversion, so seeds give the same uniforms across laws)
  gauss   = list(q = qnorm, d = dnorm),
  laplace = list(q = function(p) ifelse(p < 0.5, log(2 * p), -log(2 * (1 - p))), d = function(e) exp(-abs(e)) / 2),
  t3      = list(q = function(p) qt(p, 3), d = function(e) dt(e, 3)),
  t2      = list(q = function(p) qt(p, 2), d = function(e) dt(e, 2)),
  cauchy  = list(q = qcauchy, d = dcauchy))
noise_scale <- function(noise) STD[[noise]]$d(0) / F0
noise_q <- function(noise, tau, s = NULL) noise_scale(noise) * STD[[noise]]$q(tau)
noise_d <- function(noise, s = NULL) { k <- noise_scale(noise); function(e) STD[[noise]]$d(e / k) / k }
noise_r <- function(noise, n, s = NULL) noise_scale(noise) * STD[[noise]]$q(runif(n))

# sigma_bar = tau(1 - tau) / f(q_tau): the Theorem A threshold (Theory SKELETON, sigma >= sigma_bar).
sigma_bar <- function(noise, tau) tau * (1 - tau) / noise_d(noise)(noise_q(noise, tau))
# sigma0 = E rho_tau(eps - q_tau), the pseudo-true ALD scale (the paper's regime).  Cauchy has no first moment:
# its sigma0-arm uses the Gaussian ratio sigma0/sigma_bar at the same tau (equal curvature kappa * tau(1 - tau)).
sigma0 <- function(noise, tau, s = NULL) {
  if (noise == "cauchy") return(sigma_bar("cauchy", tau) * sigma0("gauss", tau) / sigma_bar("gauss", tau))
  q <- noise_q(noise, tau); dens <- noise_d(noise)
  integrate(function(e) rho_tau(e - q, tau) * dens(e), -Inf, Inf, rel.tol = 1e-10, subdivisions = 2000L)$value
}
sigma_arm <- function(arm, noise, tau) switch(arm, Abar = 1.1 * sigma_bar(noise, tau), S0 = sigma0(noise, tau), stop("unknown arm"))

# lambda schedules on the MAP penalty Lam = lambda * sigma, calibrated at n0 = 500 (Lam_star per truth x noise x tau):
#   Lam(n) = Lam_star * (n / 500)^a.  lambda = Lam / sigma, so the two sigma arms share the MAP and differ only in
#   the posterior temperature.  Predicted slopes of the Delta2 contraction radius (Theory, HQ E-06 brief).
SCHED <- data.frame(sched = c("primary", "fallback", "padilla"), a = c(5/2, 9/4, 15/7),
                    pred = c(-5/6, -3/4, -5/7), label = c("n^{5/2}/V", "(n^3/V)^{3/4}", "Padilla"), stringsAsFactors = FALSE)
N0 <- 500
