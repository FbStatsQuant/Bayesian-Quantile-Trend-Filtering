source("/home/fb31/Bayesian-Quantile-Trend-Filtering/engineering/E07_Tuning_Free/joint_gibbs/validate/common2.R")
n <- 12; m <- n - 3; set.seed(2); w <- runif(n, .5, 3); r <- rnorm(n); iw <- runif(m, .5, 5)
mu <- banded_solve_logdet(w, r, iw)$mean
D <- diff(diag(n), differences = 3); Pm <- diag(w) + t(D) %*% diag(iw) %*% D; sdm <- sqrt(diag(solve(Pm)))
lo <- mu - 1.2 * sdm * runif(n, .5, 1.5) + 0.3 * sdm; up <- mu + 1.2 * sdm * runif(n, .5, 1.5) - 0.2 * sdm   # asymmetric box
# exact rejection sampler
X <- matrix(NA, 0, n); tot <- 0
while (nrow(X) < 80000) { d <- t(sapply(1:20000, function(i) banded_gauss_draw(w, r, iw, rnorm(n), rnorm(m)))); tot <- tot + 20000
  X <- rbind(X, d[apply(d, 1, function(v) all(v >= lo & v <= up)), , drop = FALSE]) }
cat("rejection acceptance", nrow(X) / tot, " kept", nrow(X), "\n")
N <- 400000; A <- matrix(0, N, n); th <- (lo + up) / 2
for (i in 1:N) { th <- ss_tgibbs(th, w, r, iw, lo, up, 1L); A[i, ] <- th }
ess <- function(x) posterior::ess_bulk(matrix(x, ncol = 1))
sa <- sapply(1:n, function(i) sd(A[, i]) / sqrt(ess(A[, i]))); sx <- apply(X, 2, sd) / sqrt(nrow(X))
z <- (colMeans(A) - colMeans(X)) / sqrt(sa^2 + sx^2)
cat("mean z-scores ss_tgibbs vs exact rejection:", round(z, 2), "  max|z|", round(max(abs(z)), 2), "\n")
cat("mean diff in sd units:", round((colMeans(A) - colMeans(X)) / apply(X, 2, sd), 4), "\n"); cat("sd ratio ss/exact:", round(apply(A, 2, sd) / apply(X, 2, sd), 3), "\n")
cat("cross-cov (1,2) ss %.4f exact %.4f\n" |> sprintf(cov(A[,1],A[,2]), cov(X[,1],X[,2])))
