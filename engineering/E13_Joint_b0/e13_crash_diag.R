# E-13a: offline diagnosis of a saved joint-sampler crash (runs/E13-joint-b0-20261125/crash/<id>.rds from e13_run.R,
# or diag/<tag>_crash.rds from e13_diag.R).  Rebuilds the metric P = diag(a) + c D'D exactly as pmala_box_step / pmala_box_move do
# (a = 1/(t2 sigma z), c = min(kappa lambda^2/2, 1e8)), re-runs the kernel's own banded Cholesky on it (metric_logdet calls the
# same band_chol "metric P"), and reports why it fails.  Light: run through owls_run -j 1.
# Usage: Rscript e13_crash_diag.R <crash rds>
`%||%` <- function(a, b) if (is.null(a)) b else a
f <- commandArgs(trailingOnly = TRUE)[1]; cr <- readRDS(f)
owd <- setwd(file.path(Sys.getenv("E13_ROOT", "."), "method", "joint")); L <- readLines("Joint_Sampler_PMALA_Augmented.R")
eval(parse(text = L[seq_len(grep("^# ---- Main", L)[1] - 1L)]), envir = globalenv()); load_box_cpp(); setwd(owd)
kappa <- cr$extra$kappa %||% 3; k <- cr$order
a <- 1 / (cr$cst$t2 * cr$sigma * cr$z); lam <- cr$lambda
c_raw <- kappa * lam^2 / 2; c <- min(c_raw, 1e8)
n <- length(a); D <- diff(diag(n), differences = k + 1L); DtD <- crossprod(D)
P <- diag(a) + c * DtD
band_ok <- function(d, cc) !inherits(tryCatch(metric_logdet(d, cc, k), error = function(e) e), "error")
ev <- eigen(P, symmetric = TRUE, only.values = TRUE)$values
Q <- null_basis(n, k)                                                        # null space of D (degree <= k polynomials)
lam_null <- eigen(crossprod(Q, a * Q), symmetric = TRUE, only.values = TRUE)$values
cat(sprintf("crash: %s\nsweep %s level %s | lambda %.4g | c_raw %.3g -> c %.3g (cap binds: %s) | sigma %.4g | delta %.3g\n",
            cr$msg, cr$sweep %||% cr$base$sweep, cr$level %||% cr$base$level, lam, c_raw, c, c_raw > 1e8, cr$sigma, cr$delta))
cat(sprintf("z: min %.3g median %.3g max %.3g, at cap 1e4: %d | a = 1/(t2 sigma z): min %.3g median %.3g max %.3g\n",
            min(cr$z), median(cr$z), max(cr$z), sum(cr$z >= 1e4), min(a), median(a), max(a)))
cat(sprintf("eigen(P) (LAPACK, double): min %.3g max %.3g, condition %.3g ; smallest eigenvalue resolvable ~ eps*max = %.3g\n",
            min(ev), max(ev), max(ev) / abs(min(ev)), .Machine$double.eps * max(ev)))
cat(sprintf("P on the polynomial null space of D = Q' diag(a) Q: eigenvalues %s\n", paste(sprintf("%.3g", lam_null), collapse = ", ")))
cat(sprintf("kernel banded Cholesky of P (no ridge): %s | R chol (LAPACK): %s\n", if (band_ok(a, c)) "OK" else "FAILS",
            tryCatch({ chol(P); "OK" }, error = function(e) "FAILS")))
# how much smaller c, or how much larger a, would make the same band Cholesky pass
cs <- c / 10^(0:10); ok_c <- vapply(cs, function(cc) band_ok(a, cc), TRUE)
cat(sprintf("band chol with c divided by 10^j, j = 0..10: %s\n", paste(ifelse(ok_c, "ok", "x"), collapse = " ")))
sc <- 10^(0:10); ok_a <- vapply(sc, function(s) band_ok(a * s, c), TRUE)
cat(sprintf("band chol with a multiplied by 10^j, j = 0..10: %s\n", paste(ifelse(ok_a, "ok", "x"), collapse = " ")))
box_w <- cr$upper - cr$lower; fin <- is.finite(box_w)
cat(sprintf("box width (finite part): min %.3g median %.3g; theta at lower %d, at upper %d\n",
            if (any(fin)) min(box_w[fin]) else NA, if (any(fin)) median(box_w[fin]) else NA,
            sum(cr$theta <= cr$lower + 1e-10), sum(cr$theta >= cr$upper - 1e-10)))
cat(sprintf("||D theta||_1 = %.3g ; residual |y - theta|: median %.3g max %.3g\n", sum(abs(diff(cr$theta, differences = k + 1L))),
            median(abs(cr$y - cr$theta)), max(abs(cr$y - cr$theta))))
