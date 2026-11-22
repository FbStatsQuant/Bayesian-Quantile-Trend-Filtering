"""Centred small-ball exponent of the BQTF prior (T-03 scratch).

theta = (quadratic part, flat) + S u, u_j iid Laplace(rate lambda), S = right inverse of D^(3).
Centred small-ball (quadratic part optimised out):
    phi(eps) = -log P( || P_perp S u ||_n <= eps ),  ||v||_n^2 = v'v / n.
Claim (twice-integrated-walk heuristic): phi(eps) ~ C * (n^{5/2} / (lambda eps))^{2/5}
for 1/lambda << eps << n^{5/2}/lambda; in particular phi depends on (n, lambda, eps) only through
n^{5/2}/(lambda eps).

Part A (Gaussian increments with the Laplace variance 2/lambda^2): exact-in-distribution
eigenvalues mu_j of the covariance of P_perp S u in ||.||_n, then the standard saddle-point
(Chernoff, log-sharp) evaluation  log P(sum mu_j Z_j^2 <= eps^2) ~ inf_t [t eps^2 - 1/2 sum log(1+2 t mu_j)].
Part B (Laplace vs Gaussian): plain Monte Carlo of P(||P_perp S u||_n <= eps) at moderate
probabilities, same variance, to check that Laplace increments give the same small-ball curve.
"""
import numpy as np
from scipy.optimize import minimize_scalar


def cov_eigs(n, lam):
    # rough-part covariance in ||.||_n: (2/lam^2)(1/n) P S S' P ; nonzero eigenvalues = (2/(n lam^2)) / e_j
    # with e_j the eigenvalues of D D' (exact relation since S = D^+ on the rough space).
    j = np.arange(1, n - 2)
    e = (2 * np.sin(np.pi * j / (2 * n))) ** 6  # standard approximation (see spread script)
    return 2.0 / (n * lam**2 * e)


def log_sb_gauss(mu, eps):
    def f(logt):
        t = np.exp(logt)
        return t * eps**2 - 0.5 * np.sum(np.log1p(2 * t * mu))
    r = minimize_scalar(f, bounds=(-60, 120), method="bounded")
    return r.fun  # log P (Chernoff, log-asymptotically sharp)


def partA():
    print("Part A: Gaussian increments, saddle point.  x = n^{5/2}/(lambda eps)")
    print("   n     lambda        eps        x      phi     phi/x^(2/5)")
    rows = []
    for n in [500, 1000, 2000, 4000]:
        for lam in [n**2.0, n**2.25, n**2.5]:
            mu = cov_eigs(n, lam)
            typ = np.sqrt(mu.sum())
            for frac in [0.3, 0.1, 0.03, 0.01]:
                eps = frac * typ
                phi = -log_sb_gauss(mu, eps)
                x = n**2.5 / (lam * eps)
                rows.append((n, lam, eps, x, phi))
                print(f"{n:5d} {lam:11.3e} {eps:10.3e} {x:9.2e} {phi:8.2f} {phi/x**0.4:8.3f}")
    rows = np.array(rows)
    sl = np.polyfit(np.log(rows[:, 3]), np.log(rows[:, 4]), 1)
    print(f"pooled fit: log phi = {sl[0]:.3f} log x + {sl[1]:.3f}   (pred slope 0.400)")
    m = rows[:, 4] > 20
    sl2 = np.polyfit(np.log(rows[m, 3]), np.log(rows[m, 4]), 1)
    print(f"fit on phi>20 (deeper small-ball regime): slope {sl2[0]:.3f}")


def rough_norm(U, n, Q):
    # U: (B, m) increments -> theta = triple cumsum (padded), remove quadratic, return ||.||_n
    th = np.concatenate([np.zeros((U.shape[0], 3)), U], axis=1)
    th = np.cumsum(np.cumsum(np.cumsum(th, axis=1), axis=1), axis=1)
    th = th - (th @ Q) @ Q.T
    return np.sqrt((th**2).sum(axis=1) / n)


def partB(n=400, lam=1.0, B=200_000, seed=1):
    rng = np.random.default_rng(seed)
    x = np.arange(1, n + 1) / n
    Q, _ = np.linalg.qr(np.vander(x, 3))
    m = n - 3
    ng, nl = [], []
    for _ in range(B // 20000):
        G = rng.normal(0, np.sqrt(2) / lam, size=(20000, m))
        L = rng.laplace(0, 1 / lam, size=(20000, m))
        ng.append(rough_norm(G, n, Q)); nl.append(rough_norm(L, n, Q))
    ng, nl = np.concatenate(ng), np.concatenate(nl)
    med = np.median(ng)
    print(f"\nPart B: n={n}, lambda={lam}, B={B}: P(||P S u||_n <= eps), Gaussian vs Laplace (same variance)")
    print("   eps/median   P_gauss     P_laplace   saddle(Gauss)")
    mu = cov_eigs(n, lam)
    for q in [0.8, 0.6, 0.5, 0.4, 0.33, 0.28, 0.24]:
        eps = q * med
        pg, pl = (ng <= eps).mean(), (nl <= eps).mean()
        print(f"   {q:6.2f}     {pg:9.2e}   {pl:9.2e}   {np.exp(log_sb_gauss(mu, eps)):9.2e}")


if __name__ == "__main__":
    partA()
    partB()
