"""Follow-up to gibbs_validation_grid.py (mean z-scores 4-10 at n=6).
(a) Gaussian-twin control: t_j frozen at 2/lambda^2 -> exact Gaussian posterior known in closed form.
(b) Laplace Gibbs, second seed, longer chain, ESS-based standard errors (initial-positive-sequence).
(c) Finer grid (du/2 on a window chosen from the posterior sd) to bound grid error.
"""
import numpy as np

n, kappa, lam = 6, 16.0, 6.0
x = np.arange(1, n + 1) / n
D = np.diff(np.eye(n), 3, axis=0)
S = np.linalg.pinv(D)
Q, _ = np.linalg.qr(np.vander(x, 3)); PN = Q @ Q.T; Pp = np.eye(n) - PN
y = np.sin(2 * np.pi * x) + np.random.default_rng(42).normal(0, 1 / np.sqrt(kappa), n)


def ess(z):
    z = z - z.mean(); N = len(z)
    f = np.fft.rfft(z, 2 * N); ac = np.fft.irfft(f * np.conj(f))[:N] / (z @ z)
    s = 0.0
    for k in range(1, N - 1, 2):
        p = ac[k] + ac[k + 1]
        if p < 0: break
        s += p
    return N / (1 + 2 * s)


def gibbs(seed, iters, twin=False):
    rng = np.random.default_rng(seed); th = y.copy(); out = np.empty((iters, n))
    for it in range(iters):
        if twin:
            invt = np.full(n - 3, lam**2 / 2)
        else:
            u = D @ th
            invt = lam**2 * rng.wald(1.0 / (lam * np.maximum(np.abs(u), 1e-300)), 1.0)
        P = kappa * np.eye(n) + D.T @ (invt[:, None] * D)
        L = np.linalg.cholesky(P)
        th = np.linalg.solve(P, kappa * y) + np.linalg.solve(L.T, rng.normal(size=n))
        out[it] = th
    return out[5000:]


def grid(lo, hi, N):
    g = np.linspace(lo, hi, N); U = np.stack(np.meshgrid(g, g, g, indexing="ij"), -1).reshape(-1, 3)
    R = (y[None, :] - U @ S.T) @ Pp
    logp = -lam * np.abs(U).sum(1) - 0.5 * kappa * (R**2).sum(1)
    w = np.exp(logp - logp.max()); w /= w.sum()
    Eu = w @ U; Cu = (U - Eu).T @ ((U - Eu) * w[:, None])
    return PN @ y + Pp @ S @ Eu, np.diag(PN / kappa + Pp @ S @ Cu @ S.T @ Pp)


# (a) twin control vs closed form
Pt = kappa * np.eye(n) + (lam**2 / 2) * D.T @ D
Et, Vt = np.linalg.solve(Pt, kappa * y), np.diag(np.linalg.inv(Pt))
dt = gibbs(1, 105000, twin=True)
se = np.array([dt[:, i].std() / np.sqrt(ess(dt[:, i])) for i in range(n)])
print("(a) twin  z(mean):", np.round((dt.mean(0) - Et) / se, 2), " var ratio:", np.round(dt.var(0) / Vt, 3))

# (c) grids
E1, V1 = grid(-1.2, 1.2, 241)
E2, V2 = grid(-0.9, 0.9, 361)
print("(c) grid change in E (du .01 -> .005, window 1.2 -> 0.9):", np.round(E2 - E1, 6))

# (b) Laplace Gibbs, new seed, longer
dl = gibbs(7, 405000)
se = np.array([dl[:, i].std() / np.sqrt(ess(dl[:, i])) for i in range(n)])
print("(b) ESS per coord:", np.round([ess(dl[:, i]) for i in range(n)]))
print("(b) laplace z(mean) vs fine grid:", np.round((dl.mean(0) - E2) / se, 2))
print("(b) laplace var ratio vs fine grid:", np.round(dl.var(0) / V2, 3))
print("(b) abs mean diff:", np.round(dl.mean(0) - E2, 5), " post sd:", np.round(np.sqrt(V2), 4))
