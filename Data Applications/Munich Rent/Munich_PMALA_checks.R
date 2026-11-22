# =============================================================================
# Independent verification of the Munich-rent adaptation of the individual P-MALA sampler
#   code under test: Munich_PMALA_Individual_k2.R + prox_admm_metric_irregular.cpp
#   reference:       Simulations/Individual/Individual_Sampler_PMALA_Augmented.R + prox_admm_metric.cpp
# Run: Rscript Munich_PMALA_checks.R      (single-seed, local; ~minutes)
# Writes nothing except Rcpp build cache under %LOCALAPPDATA%/Temp/munich_checks.
# =============================================================================
t_start <- proc.time()[["elapsed"]]
root     <- "C:/Users/felip/OneDrive/Documents/Quantile Regression"
mun_dir  <- file.path(root, "Data Applications", "Munich Rent")
orig_dir <- file.path(root, "Simulations", "Individual")
scratch  <- "C:/Users/felip/AppData/Local/Temp/munich_checks"
dir.create(scratch, showWarnings = FALSE, recursive = TRUE)

# ---- load code under test (main block is guarded; sourced into globalenv) ----
source(file.path(mun_dir, "Munich_PMALA_Individual_k2.R"))
load_prox_cpp(file.path(mun_dir, "prox_admm_metric_irregular.cpp"))
stopifnot(exists("pmala_move"), exists("prox_admm_metric"))

# ---- load the ORIGINAL: only top-level function definitions, evaluated into env `orig` ----
orig <- new.env(parent = globalenv())
ex <- parse(file.path(orig_dir, "Individual_Sampler_PMALA_Augmented.R"), keep.source = FALSE)
n_def <- 0L
for (e in ex) {
  if (is.call(e) && (identical(e[[1]], as.name("<-")) || identical(e[[1]], as.name("="))) &&
      is.call(e[[3]]) && identical(e[[3]][[1]], as.name("function"))) { eval(e, envir = orig); n_def <- n_def + 1L }
}
Rcpp::sourceCpp(file.path(orig_dir, "prox_admm_metric.cpp"), env = orig, cacheDir = scratch)
stopifnot(exists("gibbs_pmala_aug", envir = orig, inherits = FALSE),
          exists("pmala_move", envir = orig, inherits = FALSE), exists("%||%", envir = orig, inherits = FALSE))
cat(sprintf("loaded: %d original function definitions + original kernel into env `orig`\n", n_def))

res <- character(0)
report <- function(tag, ok, msg) {
  line <- sprintf("%-4s %s | %s", tag, if (ok) "PASS" else "FAIL", msg); cat(line, "\n"); res[[length(res) + 1]] <<- line
  invisible(ok)
}
mx <- function(u, v) max(abs(u - v))
bm_se <- function(v, nb = 50) { b <- floor(length(v) / nb); sd(colMeans(matrix(v[1:(b * nb)], b, nb))) / sqrt(nb) }

# Independent operator: by induction D^(k+1) theta_j = k! (x_{j+k+1} - x_j) f[x_j, ..., x_{j+k+1}] (divided difference),
# and f[x_0..x_p] = sum_i theta_i / prod_{l != i} (x_i - x_l).  No recursion, no matrix products.
D_divdiff <- function(x, k) {
  n <- length(x); p <- k + 1; m <- n - p; D <- matrix(0, m, n)
  for (j in seq_len(m)) { idx <- j:(j + p)
    for (i in idx) D[j, i] <- factorial(k) * (x[j + p] - x[j]) / prod(x[i] - x[setdiff(idx, i)]) }
  D
}

dat <- load_munich(mun_dir); xm <- dat$x
cat(sprintf("Munich: N = %d, n = %d distinct fsize\n", length(dat$y), length(xm)))

# =============================================================================
# C1 operator
# =============================================================================
Dop_m <- make_Dop(xm, 2L); D <- Dop_m$D; Dr <- D_divdiff(xm, 2L)
e1a <- mx(D, Dr) / max(abs(Dr))
# tol 1e-10 relative: entries are O(1) sums of a few products of O(1) weights; independent rounding paths differ at ~1e-15
okA <- dim(D)[1] == length(xm) - 3 && e1a < 1e-10
absD <- abs(D)
ann <- sapply(0:2, function(p) { v <- xm^p; max(abs(D %*% v) / (absD %*% abs(v))) })
# rounding scale of D v is eps * (|D| |v|); 1e-10 leaves 5 orders of slack.  x^3: exact value 2! (x_{j+3} - x_j)
d3 <- as.numeric(D %*% xm^3); ref3 <- 2 * (xm[4:length(xm)] - xm[1:(length(xm) - 3)])
e3 <- max(abs(d3 - ref3) / ref3)   # tol 1e-6: cancellation from |x^3| ~ 6e6 down to O(10)
okB <- all(ann < 1e-10) && e3 < 1e-6 && min(abs(d3)) >= 2
n_reg <- 150; Dreg <- make_Dop(seq_len(n_reg), 2L)$D; Ddiff <- diff(diag(n_reg), differences = 3)
okC <- identical(dim(Dreg), dim(Ddiff)) && all(Dreg == Ddiff)
S <- Dop_m$S; Dfrom <- matrix(0, nrow(S), length(xm)); for (j in seq_len(nrow(S))) Dfrom[j, j:(j + 3)] <- S[j, ]
okD <- all(Dfrom == D) && ncol(S) == 4
report("C1", okA && okB && okC && okD,
       sprintf("(a) |D - divdiff|/max|D| = %.1e (m=%d) (b) max rel |D x^p|, p=0,1,2: %.1e %.1e %.1e; D x^3 vs 2(x_{j+3}-x_j) rel %.1e, min|Dx^3| = %g (c) regular grid == diff(diag,3): %s (d) S rebuilds D exactly: %s",
               e1a, nrow(D), ann[1], ann[2], ann[3], e3, min(abs(d3)), okC, okD))
stopifnot(okA, okB, okC, okD)

# =============================================================================
# C2 kernel parity on a regular grid (irregular kernel with S vs original kernel with k = 2)
# =============================================================================
set.seed(21); n <- 150; Sreg <- make_Dop(seq_len(n), 2L)$S
worst <- 0; allid <- TRUE; nf <- 0
for (cfg in 1:3) {
  a <- rexp(n) * 20 + 1; r <- sin(seq_len(n) / 15) + rnorm(n, 0, 0.2); xx <- r + rnorm(n, 0, 0.3)
  lam <- c(30, 3, 300)[cfg]; gam <- c(0.05, 0.5, 0.1)[cfg]
  d <- if (cfg == 2) runif(n, 0.5, 2) else a; cc <- c(3 * lam^2 / 2, 0.7, 3 * lam^2 / 2)[cfg]
  rho <- 0.1 * (mean(d) + cc) / gam; xi <- rnorm(n); v <- rnorm(n); delta <- 2 * gam
  for (tl in c(0, 1e-8)) {
    it <- if (tl > 0) 2000L else 150L
    pairs <- list(
      prox = list(prox_admm_metric(xx, a, r, lam, gam, d, cc, Sreg, rho, it, tl), orig$prox_admm_metric(xx, a, r, lam, gam, d, cc, 2L, rho, it, tl)),
      move = list(unlist(pmala_move(xx, a, r, lam, gam, d, cc, Sreg, rho, it, tl, xi, delta)),
                  unlist(orig$pmala_move(xx, a, r, lam, gam, d, cc, 2L, rho, it, tl, xi, delta))))
    if (tl == 0) pairs <- c(pairs, list(
      noise  = list(minv_sqrt_noise(xi, d, cc, Sreg), orig$minv_sqrt_noise(xi, d, cc, 2L)),
      mnorm  = list(mnorm2(v, d, cc, Sreg), orig$mnorm2(v, d, cc, 2L)),
      logdet = list(metric_logdet(d, cc, Sreg), orig$metric_logdet(d, cc, 2L))))
    for (pp in pairs) { nf <- nf + 1; allid <- allid && identical(pp[[1]], pp[[2]])
      worst <- max(worst, max(abs(pp[[1]] - pp[[2]]) / (1 + abs(pp[[2]])))) }
  }
}
# tol 1e-12 relative: the arithmetic is the same sequence of operations, so anything above roundoff is a bug
report("C2", worst <= 1e-12, sprintf("%d output comparisons (3 configs; prox, pmala_move all fields incl. iters, tol 0 and 1e-8; noise, mnorm2, logdet): bitwise identical = %s, max rel diff = %.1e",
                                      nf, allid, worst))
stopifnot(worst <= 1e-12)

# =============================================================================
# C3 kernel correctness on the irregular Munich grid
# =============================================================================
set.seed(31); n <- length(xm); S <- Dop_m$S; DtD <- crossprod(D)
e_mn <- e_ld <- e_nz <- e_id <- 0
for (cc in c(1, 1e3, 3 * 50^2 / 2)) {
  d <- runif(n, 0.5, 2); P <- diag(d) + cc * DtD; R <- chol(P)
  for (rep_ in 1:3) {
    v <- rnorm(n); xi <- rnorm(n)
    e_mn <- max(e_mn, abs(mnorm2(v, d, cc, S) - drop(t(v) %*% P %*% v)) / drop(t(v) %*% P %*% v))
    z <- minv_sqrt_noise(xi, d, cc, S); zr <- backsolve(R, xi)      # P = R'R, L = R'  =>  L'z = xi  <=>  R z = xi
    e_nz <- max(e_nz, max(abs(z - zr)) / max(abs(zr)))
    e_id <- max(e_id, abs(drop(t(z) %*% P %*% z) - sum(xi^2)) / sum(xi^2))
  }
  ldr <- as.numeric(determinant(P, logarithm = TRUE)$modulus)
  e_ld <- max(e_ld, abs(metric_logdet(d, cc, S) - ldr) / max(1, abs(ldr)))
}
# tolerances: mnorm2/logdet are backward-stable sums (1e-10); z depends on cond(P) (<= ~1e9 at c = 3750) -> 1e-6 relative
ok3a <- e_mn < 1e-10 && e_ld < 1e-10 && e_nz < 1e-6 && e_id < 1e-6
report("C3a", ok3a, sprintf("Munich grid, c in {1, 1e3, 3750}: mnorm2 rel %.1e | logdet rel %.1e | noise vs dense backsolve(chol) rel %.1e | z'Pz vs xi'xi rel %.1e",
                            e_mn, e_ld, e_nz, e_id))
stopifnot(ok3a)

set.seed(32)
r <- 8 + 2 * log(xm / 17) - 0.0002 * (xm - 80)^2 + rnorm(n, 0, 0.4); a <- rexp(n) * 5 + 0.5; xx <- r + rnorm(n, 0, 0.3)
lam <- 5; gam <- 0.5
obj_full <- function(th, d, cc) sum(a * (th - r)^2) / 2 + lam * sum(abs(D %*% th)) +
  (sum(d * (th - xx)^2) + cc * sum((D %*% (th - xx))^2)) / (2 * gam)
# The fixed point is tested with rho = 10 (well conditioned for this D: singular values 6e-5..8); the script default
# rho = 0.1 (mean(d) + c) / gamma is also run and reported (at c = 0 it is 0.2, and 20000 iterations do not converge
# there: rel diff 2.5e-4 on the first run of this check; 200000 its give 7e-7. A convergence-speed matter, not correctness:
# T need not be exact for the MH move, and c = 0 only occurs in the warm-start prox).
c3b <- list()
for (cfg in list(list(d = rep(1, n), cc = 0), list(d = a, cc = 2), list(d = a, cc = 3 * lam^2 / 2))) {
  d <- cfg$d; cc <- cfg$cc; rho_def <- 0.1 * (mean(d) + cc) / gam
  th_k  <- prox_admm_metric(xx, a, r, lam, gam, d, cc, S, 10, 20000L, 0)
  th_kd <- prox_admm_metric(xx, a, r, lam, gam, d, cc, S, rho_def, 20000L, 0)
  th <- CVXR::Variable(n)
  ob <- CVXR::sum_squares(sqrt(a) * (th - r)) / 2 + lam * CVXR::p_norm(D %*% th, 1) +
        (CVXR::sum_squares(sqrt(d) * (th - xx)) + cc * CVXR::sum_squares(D %*% (th - xx))) / (2 * gam)
  prob <- CVXR::Problem(CVXR::Minimize(ob)); invisible(CVXR::psolve(prob, solver = "CLARABEL"))
  th_c <- as.numeric(CVXR::value(th))
  ok_k <- obj_full(th_k, d, cc); ok_c <- obj_full(th_c, d, cc)
  c3b[[length(c3b) + 1]] <- c(cc = cc, diff = max(abs(th_k - th_c)) / max(abs(th_c)), dobj = (ok_k - ok_c) / abs(ok_c), status = CVXR::status(prob) == "optimal", rho_def = rho_def,
                              diff_def = max(abs(th_kd - th_c)) / max(abs(th_c)), dobj_def = (obj_full(th_kd, d, cc) - ok_c) / abs(ok_c))
}
c3b <- do.call(rbind, c3b)
# tol: CVXR/Clarabel interior point is accurate to ~1e-7..1e-8; 1e-5 relative in theta, and the kernel's objective must not
# exceed the solver's by more than 1e-8 relative (a wrong operator would show up as O(1e-2) or larger in either)
ok3b <- all(c3b[, "diff"] < 1e-5) && all(c3b[, "dobj"] < 1e-8) && all(c3b[, "status"] == 1)
fm <- function(v) paste(sprintf("%.1e", v), collapse = ",")
report("C3b", ok3b, sprintf("prox (20000 ADMM its, rho 10) vs CVXR/Clarabel, Munich grid, c = %s: max|diff|/max|theta| = %s | (obj_kernel - obj_cvxr)/|obj| = %s || [info] default rho %s: diff %s, dobj %s",
                            paste(c3b[, "cc"], collapse = ","), fm(c3b[, "diff"]), fm(c3b[, "dobj"]),
                            paste(sprintf("%.2g", c3b[, "rho_def"]), collapse = ","), fm(c3b[, "diff_def"]), fm(c3b[, "dobj_def"])))
stopifnot(ok3b)

# =============================================================================
# C4 aggregation
# =============================================================================
set.seed(41); tt <- 0.3; sg <- 0.7; cst <- ald_const(tt); n4 <- 8
g4 <- sample(rep(1:n4, c(1, 5, 3, 7, 2, 4, 6, 2))); N4 <- length(g4)
y4 <- rnorm(N4, 3, 1); z4 <- rexp(N4, 1 / sg)
ai <- 1 / ((2 / (tt * (1 - tt))) * sg * z4); ri <- y4 - ((1 - 2 * tt) / (tt * (1 - tt))) * z4   # own a_i, r_i
ar <- agg_ar(y4, z4, sg, cst, g4, n4)
cons <- sapply(1:6, function(s) { th <- rnorm(n4, 3, 2) * s
  sum(ai / 2 * (th[g4] - ri)^2) - sum(ar$a / 2 * (th - ar$r)^2) })
scale4 <- sum(ai / 2 * (rnorm(n4, 3, 2)[g4] - ri)^2)
e4 <- diff(range(cons)) / abs(scale4)
A_own <- sapply(1:n4, function(j) sum(ai[g4 == j])); R_own <- sapply(1:n4, function(j) sum(ai[g4 == j] * ri[g4 == j])) / A_own
eA <- max(abs(ar$a - A_own) / A_own); eR <- max(abs(ar$r - R_own))
gid <- sample(N4)                        # one apartment per location, locations permuted
ar1 <- agg_ar(y4, z4, sg, cst, gid, N4)
id1 <- identical(ar1$a[gid], 1 / (cst$t2 * sg * z4)) && identical(ar1$r[gid], y4 - cst$psi * z4)
ar2 <- agg_ar(y4, z4, sg, cst, seq_len(N4), N4)
id2 <- identical(ar2$a, 1 / (cst$t2 * sg * z4)) && identical(ar2$r, y4 - cst$psi * z4)
# tol 1e-9 relative: the constant is exact algebra; residual is rounding of O(N) sums
ok4 <- e4 < 1e-9 && eA < 1e-12 && eR < 1e-12 && id1 && id2
report("C4", ok4, sprintf("N=%d, n=%d, unsorted g: spread of (per-apartment - aggregated) over 6 thetas / scale = %.1e | A, R vs own sums: %.1e, %.1e | one obs/location identical (g = 1..N): %s, (g permuted): %s",
                          N4, n4, e4, eA, eR, id2, id1))
stopifnot(ok4)

# =============================================================================
# C5 sampler parity with the original on x = 1..n, one observation per location
# =============================================================================
set.seed(51); n5 <- 200; tau5 <- 0.3
y5 <- sin(2 * pi * seq_len(n5) / n5) + rnorm(n5, 0, 0.3)
Dop5 <- make_Dop(seq_len(n5), 2L)
run_pair <- function(iter, burn, asis, sd_) {
  set.seed(sd_)
  fn <- gibbs_pmala_aug(y5, seq_len(n5), tau5, Dop5, a0, b0, a_sigma, b_sigma, iter, burn, delta_init, lambda_init,
                        adapt_target, adapt_gain, adapt_kappa, delta_bounds, metric = "curv", c_fixed = c_metric, rho = NULL,
                        iters = 150L, mh = TRUE, adapt = TRUE, init = "y", warm = 200L, gamma_warm = 1e4, prior_scale = "none",
                        cmap = FALSE, kappa = 3, adapt_all = TRUE, K = 1L, asis = asis, tol = 0, lamjump = FALSE, verbose = FALSE)
  set.seed(sd_)
  fo <- orig$gibbs_pmala_aug(y5, tau5, 2L, a0, b0, a_sigma, b_sigma, iter, burn, delta_init, lambda_init,
                             adapt_target, adapt_gain, adapt_kappa, delta_bounds, trendfilter.control.list(),
                             metric = "curv", c_fixed = c_metric, rho = NULL, iters = 150L, mh = TRUE, adapt = TRUE, init = "y",
                             warm = 200L, gamma_warm = 1e4, prior_scale = "none", cmap = FALSE, kappa = 3, adapt_all = TRUE,
                             K = 1L, asis = asis, tol = 0, lamjump = FALSE, verbose = FALSE)
  an <- fn$acc; ao <- fo$acc; flips <- which(!(is.na(an) & is.na(ao)) & (is.na(an) | is.na(ao) | an != ao))
  f1 <- if (length(flips)) flips[1] else iter + 1L; pre <- seq_len(f1 - 1L); kp <- pre[pre > burn] - burn
  rel <- function(u, v) if (length(u)) max(abs(u - v) / abs(v)) else 0
  list(th = mx(fn$theta, fo$theta), lam = rel(fn$lambda, fo$lambda), sig = rel(fn$sigma, fo$sigma), del = rel(fn$delta, fo$delta),
       pre_th = if (length(kp)) mx(fn$theta[kp, , drop = FALSE], fo$theta[kp, , drop = FALSE]) else 0,
       pre_hyp = max(rel(fn$lambda[pre], fo$lambda[pre]), rel(fn$sigma[pre], fo$sigma[pre]), rel(fn$delta[pre], fo$delta[pre])),
       hyp_300 = max(rel(fn$lambda[201:300], fo$lambda[201:300]), rel(fn$sigma[201:300], fo$sigma[201:300])),
       flips = flips, acc = c(fn$acc_post, fo$acc_post),
       ident = identical(fn$theta, fo$theta) && identical(fn$lambda, fo$lambda) && identical(fn$sigma, fo$sigma) &&
               identical(fn$delta, fo$delta) && identical(fn$acc, fo$acc),
       secs = c(fn$seconds, fo$seconds))
}
# (i) code as written.  Expected: the only arithmetic difference is ||D theta||_1 (dense D %*% theta in the new U_cond / lambda
#     draw vs diff() in the original), ~1e-16 relative; a chaotic chain amplifies it, so an accept decision can eventually flip.
p1 <- run_pair(1500L, 500L, FALSE, 501)
p2 <- run_pair(500L, 250L, TRUE, 502)
set.seed(55); thr <- rnorm(n5) * 3; e_sd <- abs(sum(abs(Dtheta(thr, Dop5))) - sum(abs(diff(thr, differences = 3)))) / sum(abs(diff(thr, differences = 3)))
# (ii) decisive: same runs with the new code's Dtheta replaced IN THIS SESSION ONLY by the diff() form (file untouched).
#      If every other piece of the adaptation reduces exactly to the original, the chains must be bitwise identical.
Dtheta_file <- Dtheta
assign("Dtheta", function(theta, Dop) diff(theta, differences = Dop$k + 1L), envir = globalenv())
q1 <- run_pair(1500L, 500L, FALSE, 501); q2 <- run_pair(500L, 250L, TRUE, 502)
assign("Dtheta", Dtheta_file, envir = globalenv())
for (pp in list(list("C5", p1, "asis=FALSE 1500/500"), list("C5b", p2, "asis=TRUE 500/250"))) {
  q <- pp[[2]]
  report(pp[[1]], q$hyp_300 < 1e-6,
         sprintf("as written, %s: accept flips %d%s | before first flip: max|theta diff| %.1e, max rel diff lambda/sigma/delta %.1e (sweeps 201-300: %.1e) | whole chain: theta %.1e, lambda %.1e, sigma %.1e, delta %.1e | acc new/orig %.3f/%.3f | %.0fs/%.0fs",
                 pp[[3]], length(q$flips), if (length(q$flips)) sprintf(" (first at sweep %d)", q$flips[1]) else "",
                 q$pre_th, q$pre_hyp, q$hyp_300, q$th, q$lam, q$sig, q$del, q$acc[1], q$acc[2], q$secs[1], q$secs[2]))
}
# tol for the as-written runs: 1e-6 on lambda/sigma over the first 100 P-MALA sweeps (201-300).  Roundoff (~1e-16) is amplified
# roughly exponentially by the chain (first run: 1.8e-11 at sweep 300, 1e-3 by sweep 1237, then an accept flip), so a fixed
# tolerance over a long chain is meaningless; a real discrepancy would be O(1) from the first post-warm sweep.  Strict test: C5c.
report("C5c", q1$ident && q2$ident,
       sprintf("Dtheta := diff() in-session: bitwise identical chains (theta, lambda, sigma, delta, acc): asis=FALSE %s, asis=TRUE %s | rel diff of ||D theta||_1 dense vs diff on a random theta: %.1e",
               q1$ident, q2$ident, e_sd))
stopifnot(p1$hyp_300 < 1e-6, p2$hyp_300 < 1e-6, q1$ident, q2$ident)

# =============================================================================
# C6 theta block on an irregular grid with repeated observations vs exact grid integration
# =============================================================================
set.seed(61); x6 <- c(0, 1, 3, 3.5); k6 <- 1L; n6 <- 4; tt <- 0.3; sg <- 0.5; lam6 <- 1.5
g6 <- sample(rep(1:n6, c(3, 1, 4, 2))); N6 <- length(g6)
z6 <- rexp(N6, 1 / sg); y6 <- 0.5 * x6[g6] + rnorm(N6, 0, 0.5)
t2_ <- 2 / (tt * (1 - tt)); psi_ <- (1 - 2 * tt) / (tt * (1 - tt))
ai <- 1 / (t2_ * sg * z6); ri <- y6 - psi_ * z6
Dr6 <- D_divdiff(x6, k6)                 # independent operator (2 x 4)
grid_moments <- function(ax) {
  G <- as.matrix(expand.grid(ax)); U <- numeric(nrow(G))
  for (i in seq_len(N6)) U <- U + ai[i] / 2 * (G[, g6[i]] - ri[i])^2          # per APARTMENT
  for (j in seq_len(nrow(Dr6))) U <- U + lam6 * abs(G %*% Dr6[j, ])
  w <- exp(-(U - min(U))); w <- as.vector(w / sum(w))
  m <- colSums(G * w); s <- sqrt(colSums(G^2 * w) - m^2)
  edge <- max(sapply(seq_len(n6), function(j) sum(w[G[, j] == min(ax[[j]]) | G[, j] == max(ax[[j]])])))
  list(m = m, s = s, edge = edge)
}
Aj <- sapply(1:n6, function(j) sum(ai[g6 == j])); cj <- sapply(1:n6, function(j) sum(ai[g6 == j] * ri[g6 == j])) / Aj  # box only
gm1 <- grid_moments(lapply(1:n6, function(j) seq(cj[j] - 8 / sqrt(Aj[j]), cj[j] + 8 / sqrt(Aj[j]), length.out = 31L)))
gm  <- grid_moments(lapply(1:n6, function(j) seq(gm1$m[j] - 7 * gm1$s[j], gm1$m[j] + 7 * gm1$s[j], length.out = 45L)))
Dop6 <- make_Dop(x6, k6); cst6 <- ald_const(tt)
M6 <- 60000L; th <- cj; Sm <- matrix(NA_real_, M6, n6); acc6 <- 0
for (i in seq_len(M6)) {
  st <- pmala_step(th, y6, z6, lam6, sg, 0.5, cst6, Dop6, g6, "curv", 0, iters = 300L, kappa = 3)
  th <- st$theta; acc6 <- acc6 + st$accept; Sm[i, ] <- th
}
S1 <- Sm[-(1:5000), ]; m1 <- colMeans(S1); s1 <- apply(S1, 2, sd); se1 <- apply(S1, 2, bm_se)
se_s1 <- apply(S1, 2, function(v) bm_se((v - mean(v))^2)) / (2 * s1)
zm <- max(abs(m1 - gm$m) / se1); zs <- max(abs(s1 - gm$s) / se_s1)
# |z| < 4 over 8 statistics: false-alarm probability ~ 5e-4 under a correct sampler
ok6 <- zm < 4 && zs < 4 && gm$edge < 1e-6
report("C6", ok6, sprintf("x=(0,1,3,3.5), k=1, N=%d apts on 4 locations, %d P-MALA moves (delta 0.5, kappa 3): acc %.2f | max|mean z| %.2f | max|sd z| %.2f | max|sd ratio-1| %.3f | grid edge mass %.1e",
                          N6, M6, acc6 / M6, zm, zs, max(abs(s1 / gm$s - 1)), gm$edge))
stopifnot(ok6)

# =============================================================================
# C7 end-to-end smoke on the Munich data, tau = 0.5
# =============================================================================
set.seed(800 + 500)
f7 <- gibbs_pmala_aug(dat$y, dat$g, 0.5, Dop_m, a0, b0, a_sigma, b_sigma, 1500L, 500L, delta_init, lambda_init,
                      adapt_target, adapt_gain, adapt_kappa, delta_bounds, metric = metric, c_fixed = c_metric, rho = admm_rho,
                      iters = admm_iter, mh = mh_correct, adapt = adapt_delta, init = theta_init, warm = warm_sweeps,
                      gamma_warm = gamma_warm, K = K_theta, asis = asis_lambda, tol = admm_tol, lamjump = lamjump,
                      lamjump_s = lamjump_s, prior_scale = prior_scale, cmap = FALSE, kappa = kappa_metric, adapt_all = adapt_all,
                      verbose = FALSE)
est7 <- colMeans(f7$theta); fb <- mean(dat$y < est7[dat$g])
fin <- all(is.finite(f7$theta)) && all(is.finite(f7$lambda)) && all(is.finite(f7$sigma))
# frac below: binomial sd at N = 2035 is 0.011, so 0.03 is ~2.7 sd plus smoothing bias
ok7 <- fin && f7$acc_post > 0.2 && f7$acc_post < 0.9 && abs(fb - 0.5) < 0.03
report("C7", ok7, sprintf("Munich tau=0.5, 1500/500: finite %s | acc_post %.3f | delta_final %.3g | lambda mean %.1f | sigma mean %.4f | frac below %.4f | %.0fs",
                          fin, f7$acc_post, f7$delta_final, mean(f7$lambda[501:1500]), mean(f7$sigma[501:1500]), fb, f7$seconds))
stopifnot(ok7)

cat(sprintf("\nALL CHECKS PASSED | total runtime %.0f s\n", proc.time()[["elapsed"]] - t_start))
