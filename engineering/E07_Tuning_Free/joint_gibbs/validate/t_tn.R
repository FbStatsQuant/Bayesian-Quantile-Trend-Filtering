source("/home/fb31/Bayesian-Quantile-Trend-Filtering/engineering/E07_Tuning_Free/joint_gibbs/validate/common2.R")
set.seed(1)
tm <- function(a, b) { Z <- pnorm(b) - pnorm(a); mu <- (dnorm(a) - dnorm(b)) / Z; v <- 1 + (a*dnorm(a) - b*dnorm(b)) / Z - mu^2; c(mu, v) }
cases <- list(c(-Inf, Inf), c(-1, 2), c(0.1, 0.2), c(-0.001, 0.001), c(2, Inf), c(5, 5.1), c(8, Inf), c(-Inf, -3), c(-12, -10), c(1, 3), c(-4, 0.5), c(30,31))
for (cs in cases) { x <- rtnorm_std(2e5, cs[1], cs[2]); ex <- if (cs[1] > 20) c(NA, NA) else tm(cs[1], cs[2])
  cat(sprintf("[%g,%g] mean %.5f (exact %.5f) var %.5f (exact %.5f) in-range %s\n", cs[1], cs[2], mean(x), ex[1], var(x), ex[2], all(x >= cs[1] & x <= cs[2]))) }
# ss_tgibbs vs pCN-in-box (same box): n=14, random w, iw, ordered-box constraint
n <- 14; m <- n - 3; set.seed(2); w <- runif(n, .5, 3); r <- rnorm(n); iw <- runif(m, .5, 5)
lo <- r - 0.5 + rnorm(n, 0, .1); up <- r + 0.3 + rnorm(n, 0, .1); th0 <- (lo + up) / 2
N <- 100000; A <- B <- matrix(0, N, n); th <- th0
for (i in 1:N) { th <- ss_tgibbs(th, w, r, iw, lo, up, 1L); A[i, ] <- th }
th <- th0; rr <- 0.95; nacc <- 0
for (i in 1:N) { mu <- banded_solve_logdet(w, r, iw)$mean; for (k in 1:3) { xd <- banded_gauss_draw(w, r, iw, rnorm(n), rnorm(m)); p <- mu + rr * (th - mu) + sqrt(1 - rr^2) * (xd - mu); if (all(p >= lo & p <= up)) { th <- p; nacc <- nacc + 1 } }; B[i, ] <- th }
ess <- function(x) posterior::ess_bulk(matrix(x, ncol = 1))
sa <- sapply(1:n, function(i) sd(A[, i]) / sqrt(ess(A[, i]))); sb <- sapply(1:n, function(i) sd(B[, i]) / sqrt(ess(B[, i])))
z <- (colMeans(A) - colMeans(B)) / sqrt(sa^2 + sb^2)
cat("ss_tgibbs vs pCN-in-box, mean difference z-scores:", round(z, 2), "\n max|z| =", round(max(abs(z)), 2), "\n")
zs <- (apply(A, 2, sd) - apply(B, 2, sd)); cat("sd diff (abs):", round(zs, 4), "\n")
cat("pcn acc", nacc / (3 * N), "\n"); cat("ESS ss:", round(sapply(1:n, function(i) ess(A[, i]))), "\nESS pcn:", round(sapply(1:n, function(i) ess(B[, i]))), "\n")
