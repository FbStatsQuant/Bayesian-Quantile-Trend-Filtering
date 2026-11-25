# Exactness check of asis_step_g: same grid reference as canonical test 6 (n = 4, first differences), with the
# held-fixed subspace enlarged from constants (q = 1, = canonical) to linear (q = 2) and quadratic (q = 3) polynomials.
src <- "method/individual/Individual_Sampler_PMALA_Augmented.R"
lines <- readLines(src); main_at <- grep("^# ---- Main", lines)[1]
setwd(dirname(src)); eval(parse(text = lines[seq_len(main_at - 1)]), envir = globalenv()); setwd("../..")
source("experiments/pilots/lambda_mixing/asis_general.R")
load_prox_cpp(cpp_src)
bm_se <- function(v, nb = 50) { b <- floor(length(v) / nb); sd(colMeans(matrix(v[1:(b * nb)], b, nb))) / sqrt(nb) }   # as in run_tests()
set.seed(13); nn <- 4; ord <- 0L; mm <- nn - 1; a0_ <- 1; b0_ <- 0.5; sg <- 0.5; tt <- 0.3; cst <- ald_const(tt)
yy <- cumsum(rnorm(nn, 0, 0.3)); zz <- rexp(nn, 1 / sg); a <- 1 / (cst$t2 * sg * zz); r <- yy - cst$psi * zz
ax <- lapply(seq_len(nn), function(i) seq(r[i] - 5 / sqrt(a[i]), r[i] + 5 / sqrt(a[i]), length.out = 45L)); G <- as.matrix(expand.grid(ax))
SDg <- rowSums(abs(G[, -1] - G[, -nn]))
lp <- -(G - rep(r, each = nrow(G)))^2 %*% (a / 2) - (mm + a0_) * log(b0_ + SDg)
wgt <- exp(lp - max(lp)); wgt <- as.vector(wgt / sum(wgt))
m_ex <- colSums(G * wgt); s_ex <- sqrt(colSums(G^2 * wgt) - m_ex^2); lam_ex <- sum(wgt * (mm + a0_) / (b0_ + SDg))
ok <- TRUE
for (case in list(c(1, 1), c(2, 2), c(3, 3), c(3, 1))) {   # (q, q used in the Jacobian); last = deliberately wrong (power check)
  q <- case[1]; qj <- case[2]
  Q <- qr.Q(qr(outer(seq_len(nn) / nn, 0:(q - 1), `^`)))
  set.seed(100 + q); th <- r; lam <- 2; M2 <- 80000L; S <- matrix(NA, M2, nn); L <- numeric(M2)
  for (i in seq_len(M2)) {
    st <- pmala_step(th, yy, zz, lam, sg, 1.0, cst, ord, "curv", 0, iters = 300L, kappa = 3); th <- st$theta
    lam <- rgamma(1, a0_ + mm, b0_ + sum(abs(diff(th))))
    as_ <- asis_step_g(th, lam, a, r, a0_, b0_, Q, ord, q_jac = qj); lam <- as_$lambda; th <- as_$theta
    S[i, ] <- th; L[i] <- lam
  }
  S1 <- S[-(1:5000), ]; L1 <- L[-(1:5000)]
  m1 <- colMeans(S1); se1 <- apply(S1, 2, bm_se); s1 <- apply(S1, 2, sd)
  se_s1 <- apply(S1, 2, function(v) bm_se((v - mean(v))^2)) / (2 * s1)
  zm <- max(abs(m1 - m_ex) / se1); zs <- max(abs(s1 - s_ex) / se_s1); zl <- abs(mean(L1) - lam_ex) / bm_se(L1)
  cat(sprintf("q = %d (jac %d) | max |mean z| %.2f | max |sd z| %.2f | E lambda chain %.3f (se %.3f) vs exact %.3f (z %.2f)\n",
              q, qj, zm, zs, mean(L1), bm_se(L1), lam_ex, zl))
  pass <- max(zm, zs, zl) < 4; cat(if (pass) '   pass\n' else '   FAIL\n')
  ok <- ok && (pass == (q == qj))
}
cat(if (ok) "ALL AS EXPECTED (correct Jacobians pass, wrong one fails)\n" else "UNEXPECTED\n")
