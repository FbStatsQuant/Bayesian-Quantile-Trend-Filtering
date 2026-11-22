"""Independent validation of Theory's own Park-Casella Gibbs sampler (used in laplace_gibbs_spread.py
and vp_bias_check.py) against exact numerical integration, at n = 6 (T-03 provenance check, HQ rule).

Model: y = theta + N(0, 1/kappa), prior Laplace(lambda) on u = D3 theta (m = 3), flat on quadratics.
Integrating the flat quadratic coefficients analytically:
   p(u | y) ∝ exp(-lambda ||u||_1 - kappa/2 || P_perp (y - S u) ||^2),
   E[theta|y] = P_N y + P_perp S E[u|y],  Cov[theta|y] = P_N/kappa + P_perp S Cov[u|y] S' P_perp,
where S is any right-inverse of D3 and P_N the projector on quadratics.  E[u], Cov[u] by a 3-D grid.
The Gibbs sampler below is the same algorithm (and the same IG-scaling update) as in the scratch scripts.
"""
import numpy as np

rng = np.random.default_rng(42)
n, kappa, lam = 6, 16.0, 6.0
x = np.arange(1, n + 1) / n
D = np.diff(np.eye(n), 3, axis=0)
S = np.linalg.pinv(D)
Q, _ = np.linalg.qr(np.vander(x, 3)); PN = Q @ Q.T; Pp = np.eye(n) - PN
y = np.sin(2 * np.pi * x) + rng.normal(0, 1 / np.sqrt(kappa), n)

# --- exact (grid) ---
g = np.linspace(-1.2, 1.2, 241); du = g[1] - g[0]
U = np.stack(np.meshgrid(g, g, g, indexing="ij"), -1).reshape(-1, 3)
R = (y[None, :] - U @ S.T) @ Pp
logp = -lam * np.abs(U).sum(1) - 0.5 * kappa * (R**2).sum(1)
w = np.exp(logp - logp.max()); w /= w.sum()
Eu = w @ U; Cu = (U - Eu).T @ ((U - Eu) * w[:, None])
Eth = PN @ y + Pp @ S @ Eu
Vth = np.diag(PN / kappa + Pp @ S @ Cu @ S.T @ Pp)
print("grid mass at edges (should be ~0):", w.reshape(241, 241, 241)[[0, -1]].sum())

# --- Theory's Gibbs (same updates as scratch scripts) ---
th = y.copy(); draws = []
for it in range(200000):
    u = D @ th
    mu1 = 1.0 / (lam * np.maximum(np.abs(u), 1e-300))
    invt = lam**2 * rng.wald(mu1, 1.0)
    P = kappa * np.eye(n) + D.T @ np.diag(invt) @ D
    L = np.linalg.cholesky(P)
    mean = np.linalg.solve(P, kappa * y)
    th = mean + np.linalg.solve(L.T, rng.normal(size=n))
    if it >= 5000:
        draws.append(th)
dr = np.array(draws)
Eg, Vg = dr.mean(0), dr.var(0)
# batch-means standard errors
B = 50; bm = dr[: len(dr) // B * B].reshape(B, -1, n).mean(1); se = bm.std(0, ddof=1) / np.sqrt(B)
print("coord  E_grid    E_gibbs   z(mean)   Var_grid   Var_gibbs  ratio")
for i in range(n):
    print(f"{i:4d} {Eth[i]:9.5f} {Eg[i]:9.5f} {(Eg[i]-Eth[i])/se[i]:8.2f}  {Vth[i]:9.3e} {Vg[i]:9.3e} {Vg[i]/Vth[i]:6.3f}")
