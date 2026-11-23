source("/home/fb31/Bayesian-Quantile-Trend-Filtering/engineering/E07_Tuning_Free/joint_gibbs/common_v3.R")
set.seed(11)
for (n in c(4, 6)) for (rep in 1:3) {
  m <- n - 3; D <- diff(diag(n), differences = 3)
  w <- rexp(n) + 0.3; r <- rnorm(n); iw <- rexp(m) * 2 + 0.2
  P <- diag(w) + crossprod(D, iw * D); mu <- solve(P, w * r); Sg <- solve(P); sdv <- sqrt(diag(Sg))
  lo <- mu - sdv * runif(n, 0.1, 1.2); up <- mu + sdv * runif(n, -0.4, 1.2); up <- pmax(up, lo + 0.3 * sdv)
  # rejection sampling
  Lc <- chol(Sg); N <- 4e6; X <- matrix(rnorm(N * n), N, n) %*% Lc; X <- sweep(X, 2, mu, "+")
  ok <- rowSums(X < rep(lo, each = N) | X > rep(up, each = N)) == 0; Xa <- X[ok, , drop = FALSE]; pacc <- mean(ok)
  # start inside box
  th <- (lo + up) / 2; K <- 40000; out <- matrix(0, K, n); bn <- numeric(K)
  for (k in 1:K) { h <- banded_rhmc(w, r, iw, th, lo, up, pi / 2); th <- h$theta; out[k, ] <- th; bn[k] <- h$bounces }
  se <- apply(Xa, 2, sd) / sqrt(nrow(Xa)); essh <- sapply(1:n, function(i) posterior::ess_bulk(out[, i]))
  seh <- apply(out, 2, sd) / sqrt(essh)
  z <- (colMeans(out) - colMeans(Xa)) / sqrt(se^2 + seh^2)
  cdiff <- max(abs(cov(out) - cov(Xa))); cs <- max(abs(cov(Xa)))
  inbox <- all(sweep(out, 2, lo, "-") >= -1e-12) && all(sweep(out, 2, up, "-") <= 1e-12)
  cat(sprintf("n=%d rep=%d  P(box)=%.3f  rej n=%d | max |z| of mean diff %.2f | max |cov diff| %.4f (scale %.3f) | min ESS %.0f | bounces mean %.2f max %d | in box %s\n",
    n, rep, pacc, nrow(Xa), max(abs(z)), cdiff, cs, min(essh), mean(bn), max(bn), inbox))
}
