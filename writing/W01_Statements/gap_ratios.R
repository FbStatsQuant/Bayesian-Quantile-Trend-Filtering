# W-01: gap ratios R = sigma_bar / sigma0 for the noise-law table (Table 2).
# sigma_bar = tau(1-tau)/f(q) (point density at the tau-quantile q),
# sigma0    = E rho_tau(eps - q) (the ALD-scale KL projection, the paper's learned sigma).
# Gaussian and t rows at tau = 0.5 reproduce theory/T03_Feasibility/STATEMENT_DRAFT.md v3.1.
laws <- list(
  Gaussian = list(q = qnorm, d = dnorm),
  Laplace  = list(q = function(p) ifelse(p < .5, log(2 * p), -log(2 * (1 - p))),
                  d = function(x) .5 * exp(-abs(x))),
  t2 = list(q = function(p) qt(p, 2), d = function(x) dt(x, 2)),
  t3 = list(q = function(p) qt(p, 3), d = function(x) dt(x, 3)))
for (nm in names(laws)) for (tau in c(.5, .9)) {
  q <- laws[[nm]]$q(tau); f <- laws[[nm]]$d(q); sbar <- tau * (1 - tau) / f
  rho <- function(x) (x - q) * (tau - (x < q))
  s0 <- integrate(function(x) rho(x) * laws[[nm]]$d(x), -Inf, q)$value +
        integrate(function(x) rho(x) * laws[[nm]]$d(x), q, Inf)$value
  cat(sprintf("%-8s tau=%.1f sigma_bar=%.4f sigma0=%.4f R=%.3f\n", nm, tau, sbar, s0, sbar / s0))
}
for (tau in c(.5, .9))
  cat(sprintf("Cauchy   tau=%.1f sigma_bar=%.4f sigma0=Inf\n", tau, tau * (1 - tau) / dcauchy(qcauchy(tau))))
