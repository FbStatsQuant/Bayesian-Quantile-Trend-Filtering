"""Noiseless MAP bias of k=2 trend filtering (T-03 scratch).

bias2(mu) = ||theta_hat_mu - theta*||_n^2,
theta_hat_mu = argmin 1/2||theta* - theta||^2 + mu ||D3 theta||_1  (Gaussian-analogue MAP on noiseless
data; mu = lambda / kappa).  The worst case over {TV^(3) <= V} obeys bias2 <= 2 mu V n^{-3} (basic
inequality).  Two truths: S = sin(2 pi x) (dense D3 theta*), PQ = C^1 piecewise quadratic with 3 knots
(sparse D3 theta*).
Solver: ADMM on z = D theta with banded solves; reports the KKT residual (dual feasibility of
v = least-squares solution of D'v = theta* - theta, relative to mu) so convergence is checked.
"""
import numpy as np
from scipy.linalg import solveh_banded
from scipy.sparse import diags


def D3s(n):
    return diags([-1.0, 3.0, -3.0, 1.0], [0, 1, 2, 3], shape=(n - 3, n)).tocsr()


def banded_upper(M, bw):
    n = M.shape[0]
    ab = np.zeros((bw + 1, n))
    Md = M.toarray() if hasattr(M, "toarray") else M
    for k in range(bw + 1):
        ab[bw - k, k:] = np.diagonal(Md, k)
    return ab


def tf_noiseless(ts, mu, iters=6000, rho_scale=1.0):
    n = len(ts)
    D = D3s(n)
    DtD = (D.T @ D).tocsr()
    rho = rho_scale * mu / max(np.abs(D @ ts).max(), 1e-12) * 1e-3
    rho = max(rho, 1e-6)
    def factor(rho):
        A = diags([1.0], [0], shape=(n, n)) + rho * DtD
        return banded_upper(A, 3)
    ab = factor(rho)
    z = D @ ts; w = np.zeros(n - 3)
    for it in range(iters):
        th = solveh_banded(ab, ts + rho * (D.T @ (z - w)))
        Dth = D @ th
        zold = z
        z = np.sign(Dth + w) * np.maximum(np.abs(Dth + w) - mu / rho, 0)
        w = w + Dth - z
        if it % 200 == 199:  # residual balancing
            r = np.linalg.norm(Dth - z); s = rho * np.linalg.norm(D.T @ (z - zold))
            if r > 10 * s:
                rho *= 2; w /= 2; ab = factor(rho)
            elif s > 10 * r:
                rho /= 2; w *= 2; ab = factor(rho)
    th = solveh_banded(ab, ts + rho * (D.T @ (z - w)))
    v = rho * w  # scaled dual -> dual variable
    kkt = np.abs(ts - th - D.T @ v).max() / max(np.abs(ts).max(), 1e-12)
    feas = np.abs(v).max() / mu
    return th, kkt, feas


def truths(n):
    x = np.arange(1, n + 1) / n
    S = np.sin(2 * np.pi * x)
    knots, jumps = [0.3, 0.55, 0.8], [8.0, -12.0, 6.0]
    PQ = 0.5 * (x - 0.5) ** 2
    for k, J in zip(knots, jumps):
        PQ += 0.5 * J * np.clip(x - k, 0, None) ** 2
    return {"S": S, "PQ": PQ}


if __name__ == "__main__":
    import sys
    ns = [int(a) for a in sys.argv[1:]] or [250, 500, 1000]
    for n in ns:
        T = truths(n)
        for name, ts in T.items():
            V = n**2 * np.abs(np.diff(ts, 3)).sum()
            for a in [1.5, 1.75, 2.0, 15 / 7, 2.25, 7 / 3, 2.5, 2.75]:
                mu = float(n) ** a
                th, kkt, feas = tf_noiseless(ts, mu)
                b2 = np.mean((th - ts) ** 2)
                print(f"{name:2s} n={n:5d} V={V:7.2f} a={a:5.3f} mu={mu:9.3e} bias2={b2:9.3e} "
                      f"bound={2*mu*V/n**3:9.3e} kkt={kkt:8.1e} max|v|/mu={feas:5.3f} "
                      f"knots={np.sum(np.abs(np.diff(th,3))>1e-6*np.abs(np.diff(th,3)).max())}", flush=True)
