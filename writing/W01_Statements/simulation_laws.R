# W-01b: assumptions (A2), (A4) and (A3) for the paper's simulation designs
# (paper/sections/simulations.tex): u_i = i/n, y_i = f(u_i) + eps_i,
#   Gaussian      eps ~ N(0, s(u)^2), s(u) = (1 + u^2)/4
#   Beta          eps ~ Beta(1, 11 - 10u)
#   mixed normal  eps ~ u N(-0.2, 0.5) + (1 - u) N(0.2, 0.5)   (0.5 = variance)
# Truth: theta*_i = f(u_i) + F_u^{-1}(tau), f = f_VS or f_S.
#
# Conventions (heteroscedastic noise; flagged in statements.tex):
#   f_min    = min over u in [0,1] of the point density of eps_u at its tau-quantile
#              (the worst case over u; it is the L -> 0 limit of the secant constant
#              in (A2), so R below is a best case for (A4) at any fixed L);
#   sigma_bar = tau(1-tau)/f_min;
#   sigma0    = int_0^1 E rho_tau(eps_u - q_u) du (the limit of the paper's learned
#              sigma, n^{-1} sum_i E rho_tau(eps_i - q_i));
#   R         = sigma_bar / sigma0.
# The (A3) constant is V = TV_2(theta*) = n^2 ||D^(3) theta*||_1, at n = 500, 2000, 8000.

taus <- c(0.05, 0.25, 0.50, 0.75, 0.95)
ug <- seq(0, 1, length.out = 2001)
sdm <- sqrt(0.5)

fam <- list(
  Gaussian = list(
    q = function(tau, u) qnorm(tau) * (1 + u^2) / 4,
    d = function(x, u) dnorm(x, 0, (1 + u^2) / 4),
    p = function(x, u) pnorm(x, 0, (1 + u^2) / 4),
    lo = function(u) -Inf, hi = function(u) Inf),
  Beta = list(
    q = function(tau, u) 1 - (1 - tau)^(1 / (11 - 10 * u)),
    d = function(x, u) dbeta(x, 1, 11 - 10 * u),
    p = function(x, u) pbeta(x, 1, 11 - 10 * u),
    lo = function(u) 0, hi = function(u) 1),
  Mixed = list(
    q = function(tau, u) uniroot(function(x) u * pnorm(x, -0.2, sdm) + (1 - u) * pnorm(x, 0.2, sdm) - tau,
                                 c(-10, 10), tol = 1e-15)$root,
    d = function(x, u) u * dnorm(x, -0.2, sdm) + (1 - u) * dnorm(x, 0.2, sdm),
    p = function(x, u) u * pnorm(x, -0.2, sdm) + (1 - u) * pnorm(x, 0.2, sdm),
    lo = function(u) -Inf, hi = function(u) Inf))

check_risk <- function(F, tau, u) {          # E rho_tau(eps - q)
  q <- F$q(tau, u)
  up <- integrate(function(x) (x - q) * F$d(x, u), q, F$hi(u), rel.tol = 1e-10)$value
  dn <- integrate(function(x) (q - x) * F$d(x, u), F$lo(u), q, rel.tol = 1e-10)$value
  tau * up + (1 - tau) * dn
}

cat("== (A2)/(A4): worst-case point density, sigma0, gap ratio R ==\n")
for (nm in names(fam)) for (tau in taus) {
  F <- fam[[nm]]
  qs <- sapply(ug, function(u) F$q(tau, u))
  dens <- mapply(function(x, u) F$d(x, u), qs, ug)
  s0u <- sapply(ug, function(u) check_risk(F, tau, u))
  s0 <- sum((head(s0u, -1) + tail(s0u, -1)) / 2) * diff(ug)[1]    # trapezoid in u
  fmin <- min(dens); sbar <- tau * (1 - tau) / fmin
  edge <- if (nm == "Beta") sprintf(" min dist to support edge=%.4f", min(pmin(qs, 1 - qs))) else ""
  cat(sprintf("%-8s tau=%.2f f_min=%.4f (u=%.2f) f_max=%.4f sigma0=%.4f sigma_bar=%.4f R=%.3f%s\n",
              nm, tau, fmin, ug[which.min(dens)], max(dens), s0, sbar, sbar / s0, edge))
}

fVS <- function(u) 2 + sin(4 * u - 2) + 2 * exp(-30 * (4 * u - 2)^2)
fS <- function(u) sin(2 * pi * u)
tv2 <- function(theta, n) n^2 * sum(abs(diff(theta, differences = 3)))

cat("\n== (A3): V = TV_2(theta*) ==\n")
for (sig in c("VS", "S")) {
  f <- if (sig == "VS") fVS else fS
  for (n in c(500, 2000, 8000)) {
    u <- (1:n) / n
    cat(sprintf("%-2s n=%5d signal only V=%.1f\n", sig, n, tv2(f(u), n)))
  }
  for (nm in names(fam)) for (tau in taus) {
    vals <- sapply(c(500, 2000, 8000), function(n) {
      u <- (1:n) / n
      tv2(f(u) + sapply(u, function(uu) fam[[nm]]$q(tau, uu)), n)
    })
    cat(sprintf("%-2s %-8s tau=%.2f V(500)=%.1f V(2000)=%.1f V(8000)=%.1f\n",
                sig, nm, tau, vals[1], vals[2], vals[3]))
  }
}
