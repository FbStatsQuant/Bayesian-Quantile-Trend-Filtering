.libPaths(c("/home/fb31/Bayesian-Quantile-Trend-Filtering/ops/Rlib", .libPaths()))
SCR <- "/home/fb31/Bayesian-Quantile-Trend-Filtering/runs/archive-owls-session-scratch-20261125/12592220-6c98-4d66-a1f5-aba8b81d5bdd/scratchpad"
Sys.setenv(E07_CACHE = file.path(SCR, "cache"))
source("/home/fb31/Bayesian-Quantile-Trend-Filtering/engineering/E07_Tuning_Free/joint_gibbs/e07_joint_v3.R")
e07v3_load(cache = file.path(SCR, "cache"))
set.seed(5); n <- 20; m <- n - 3
D <- diff(diag(n), differences = 3)
w <- rexp(n) + 0.5; r <- rnorm(n); x <- rexp(m) + 0.2; th <- rnorm(n)
Pd <- function(eta) diag(w) + exp(2 * eta) * crossprod(D, x * D)
mud <- function(eta) solve(Pd(eta), w * r)
# (i) iw0 = iw1 returns theta
e0 <- 0.3
o1 <- banded_transport(w, r, exp(2*e0)*x, exp(2*e0)*x, th); cat("(i) max|transport(eta0,eta0)-theta| =", max(abs(o1 - th)), "\n")
# (ii) dense
for (e1 in c(-1, 0.8, 2.5)) {
  R0 <- chol(Pd(e0)); R1 <- chol(Pd(e1))
  om_d <- drop(R0 %*% (th - mud(e0))); th_d <- drop(mud(e1) + backsolve(R1, om_d))
  om <- banded_omega(w, r, exp(2*e0)*x, th); ev <- banded_eval(w, r, exp(2*e1)*x, om)
  tt <- banded_transport(w, r, exp(2*e0)*x, exp(2*e1)*x, th)
  cat(sprintf("(ii) eta1=%.1f: |omega diff| %.2e |theta' diff| %.2e |transport diff| %.2e |logdet diff| %.2e |quad diff| %.2e\n", e1,
    max(abs(om - om_d)), max(abs(ev$theta - th_d)), max(abs(tt - th_d)), abs(ev$logdet - determinant(Pd(e1))$modulus[1]*2),
    abs(ev$quad - sum(w * r * mud(e1)))))
}
# (iii) stack-shift conditional at J = 2, n = 20
J <- 2; W <- lapply(1:J, function(j) rexp(n) + 0.5); Rr <- lapply(1:J, function(j) rnorm(n)); IW <- lapply(1:J, function(j) rexp(m) + 0.2)
TH <- lapply(1:J, function(j) rnorm(n))
P <- lapply(1:J, function(j) diag(W[[j]]) + crossprod(D, IW[[j]] * D)); mu <- lapply(1:J, function(j) solve(P[[j]], W[[j]] * Rr[[j]]))
PS <- Reduce(`+`, P); b_d <- Reduce(`+`, lapply(1:J, function(j) drop(P[[j]] %*% (mu[[j]] - TH[[j]]))))
# direct: log density of Delta up to const, its gradient at 0 and Hessian by finite differences
ld <- function(Dl) sum(sapply(1:J, function(j) { t <- TH[[j]] + Dl; -0.5 * sum(t * (P[[j]] %*% t)) + sum(t * W[[j]] * Rr[[j]]) }))
g0 <- sapply(1:n, function(i) { h <- 1e-5; e <- numeric(n); e[i] <- h; (ld(e) - ld(-e)) / (2 * h) })
cat("(iii) gradient at Delta=0 vs b_d: max diff", max(abs(g0 - b_d)), "\n")
b_fn <- stack_shift_b(TH, W, Rr, IW)    # function in e07_joint_v3.R
cat("     b via R helper vs dense: max diff", max(abs(b_fn - b_d)), "\n")
Ws <- Reduce(`+`, W); IWs <- Reduce(`+`, IW); rc <- b_fn / Ws
mean_banded <- banded_solve_logdet(Ws, rc, IWs)$mean
cat("     banded mean vs dense PS^-1 b: max diff", max(abs(mean_banded - solve(PS, b_d))), "\n")
N <- 40000; S <- t(replicate(N, banded_gauss_draw(Ws, rc, IWs, rnorm(n), rnorm(m))))
cat(sprintf("     empirical mean err (max, in mc-se units) %.2f ; cov max|diff| %.4f (scale %.3f)\n",
  max(abs(colMeans(S) - mean_banded) / (sqrt(diag(solve(PS))) / sqrt(N))), max(abs(cov(S) - solve(PS))), max(abs(solve(PS)))))
