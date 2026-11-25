# E-13a phase 2: distribution check of the z draw (Block 2) at tiny and normal residuals, OLD (textbook inverse-Gaussian root, the code
# before E-13a) vs NEW (draw_z of the individual and joint scripts, which must be the same code).
# Exact law, derived from the model and NOT from the sampler's parameterisation:
#   z | e, sigma  ∝  z^{-1/2} exp(-(e - psi z)^2 / (2 t2 sigma z) - z / sigma)  =  GIG(1/2, chi, psi'),
#   chi = e^2 / (t2 sigma),  psi' = psi^2 / (t2 sigma) + 2 / sigma;   so v = 1/z ~ InvGauss(mean sqrt(psi'/chi), shape psi'),
#   P(z <= t) = P(v >= 1/t) = 1 - F_IG(1/t),  F_IG(x) = Phi(sqrt(l/x)(x/mu - 1)) + exp(2 l/mu) Phi(-sqrt(l/x)(x/mu + 1)).
# Per case: N = 1e5 draws; Kolmogorov-Smirnov test against the exact CDF; share of draws at the 1e4 clamp; three quantiles vs exact.
# Usage: Rscript e13b_zdraw_test.R   (env E13_ROOT = code tree holding method/; default ".")
`%||%` <- function(a, b) if (is.null(a)) b else a
ROOT <- normalizePath(Sys.getenv("E13_ROOT", "."))
defs <- function(dir, file) {                                             # the script's definitions only (no kernel compile)
  e <- new.env(); L <- readLines(file.path(ROOT, "method", dir, file))
  owd <- setwd(file.path(ROOT, "method", dir)); on.exit(setwd(owd))
  eval(parse(text = L[seq_len(grep("^# ---- Main", L)[1] - 1L)]), envir = e); e
}
I <- defs("individual", "Individual_Sampler_PMALA_Augmented.R"); J <- defs("joint", "Joint_Sampler_PMALA_Augmented.R")
same <- function(f) identical(deparse(I[[f]]), deparse(J[[f]]))
shared <- c("rinvgauss", "draw_z", "pilot_fit", "warm_prox", "draw_sigma", "ald_const")
cat("shared code identical in both scripts:", paste(sprintf("%s %s", shared, vapply(shared, same, TRUE)), collapse = ", "), "\n")
stopifnot(all(vapply(shared, same, TRUE)))
old_rinvgauss <- function(n, mu, lam) {                                   # verbatim pre-E-13a code
  nu <- rnorm(n); yv <- nu^2
  xv <- mu + mu^2 * yv / (2 * lam) - (mu / (2 * lam)) * sqrt(4 * mu * lam * yv + mu^2 * yv^2)
  u  <- runif(n)
  ifelse(u <= mu / (mu + xv), xv, mu^2 / xv)
}
old_draw_z <- function(e, tau, sigma) {
  ae <- pmax(abs(e), 1e-10)
  v  <- old_rinvgauss(length(e), mu = 1 / (tau * (1 - tau) * ae), lam = 1 / (2 * tau * (1 - tau) * sigma))
  pmin(pmax(1 / v, 1e-8), 1e4)
}
exact_cdf <- function(e, tau, sigma) {
  cst <- I$ald_const(tau); chi <- e^2 / (cst$t2 * sigma); psp <- cst$psi^2 / (cst$t2 * sigma) + 2 / sigma
  mu <- sqrt(psp / chi); l <- psp
  function(t) { x <- 1 / t; s <- sqrt(l / x)
    1 - (pnorm(s * (x / mu - 1)) + exp(2 * l / mu + pnorm(-s * (x / mu + 1), log.p = TRUE))) }
}
exact_q <- function(F, p) uniroot(function(t) F(exp(t)) - p, c(-60, 15), tol = 1e-12)$root |> exp()
N <- 1e5L; rows <- list()
for (tau in c(0.3, 0.7)) for (e in c(1e-6, 1e-8, 1e-10, 1e-12, 0.05)) {
  sigma <- 0.12; F <- exact_cdf(e, tau, sigma); qp <- c(0.01, 0.5, 0.99); qe <- vapply(qp, function(p) exact_q(F, p), 0)
  for (v in c("old", "new")) {
    set.seed(20261125); z <- if (v == "old") old_draw_z(rep(e, N), tau, sigma) else I$draw_z(rep(e, N), tau, sigma)
    ks <- suppressWarnings(ks.test(z, F))
    qd <- quantile(z, qp, names = FALSE)
    rows[[length(rows) + 1L]] <- data.frame(tau = tau, e = e, version = v, KS_D = unname(ks$statistic), KS_p = ks$p.value,
      at_cap_1e4 = mean(z >= 1e4), at_floor_1e8 = mean(z <= 1e-8), q01_ratio = qd[1] / qe[1], q50_ratio = qd[2] / qe[2], q99_ratio = qd[3] / qe[3],
      mean_draw = mean(z))
  }
}
R <- do.call(rbind, rows)
R$verdict <- ifelse(R$KS_p > 0.001, "pass", "FAIL")             # 10 NEW cases: family-wise false-alarm rate about 1%
print(format(R, digits = 4), row.names = FALSE)
out <- Sys.getenv("E13_ZOUT", ""); if (nzchar(out)) write.csv(R, out, row.names = FALSE)
new_ok <- all(R$verdict[R$version == "new"] == "pass"); old_fail <- any(R$verdict[R$version == "old" & R$e <= 1e-8] == "FAIL")
cat(sprintf("\nNEW passes every case: %s | OLD fails at |e| <= 1e-8: %s\n", new_ok, old_fail))
stopifnot(new_ok)
