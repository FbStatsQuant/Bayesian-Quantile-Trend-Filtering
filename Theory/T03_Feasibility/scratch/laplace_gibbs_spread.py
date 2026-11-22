"""Posterior spread under the ACTUAL Laplace prior on D^(3) theta (T-03 scratch).

Likelihood: Gaussian with precision kappa per observation (stand-in for the ALD curvature
kappa = f(q_tau)/sigma; isolates the prior effect).  Prior: u = D3 theta iid Laplace(lambda),
flat on quadratics.  Park-Casella Gibbs: u_j | t_j ~ N(0, t_j), t_j ~ Exp(lambda^2/2);
1/t_j | theta ~ InvGauss(mean lambda/|u_j|, shape lambda^2);
theta | t, y ~ N(Q^{-1} kappa y, Q^{-1}),  Q = kappa I + D' diag(1/t) D  (banded, bw 3).
Outputs posterior bias2, total spread, rough spread (quadratic removed), lambda||D theta||_1/m.
Prediction: rough spread ~ C kappa^{-5/6} lambda^{-1/3} (C ~ 0.3-0.4), flat in n.
"""
import sys
import numpy as np
from scipy.linalg import cholesky_banded, cho_solve_banded, solve_triangular
from scipy.sparse import diags


def run(n, lam, kappa=16.0, truth="S", sweeps=3000, burn=1000, seed=0):
    rng = np.random.default_rng(seed)
    x = np.arange(1, n + 1) / n
    if truth == "S":
        ts = np.sin(2 * np.pi * x)
    else:
        ts = 0.5 * (x - 0.5) ** 2
        for k, J in zip([0.3, 0.55, 0.8], [8.0, -12.0, 6.0]):
            ts += 0.5 * J * np.clip(x - k, 0, None) ** 2
    y = ts + rng.normal(0, 1 / np.sqrt(kappa), n)
    D = diags([-1.0, 3.0, -3.0, 1.0], [0, 1, 2, 3], shape=(n - 3, n)).tocsr()
    Qx, _ = np.linalg.qr(np.vander(x, 3))
    th = y.copy()
    s1 = np.zeros(n); s2 = np.zeros(n); rough_acc = []; ratio = []
    draws_c = []
    for it in range(sweeps):
        u = D @ th
        mu_ig = lam / np.maximum(np.abs(u), 1e-300)
        invt = np.minimum(rng.wald(mu_ig, lam**2), min(1e4 * lam**2, 1e14))  # safeguard cap, non-binding for lam<=1e5
        Q = (D.T @ diags(invt) @ D).tocsr() + diags(np.full(n, kappa))
        # upper banded storage
        ab = np.zeros((4, n))
        Qd = Q.todia()
        for off, dat in zip(Qd.offsets, Qd.data):
            if 0 <= off <= 3:
                ab[3 - off, off:] = dat[off:]
        cb = cholesky_banded(ab)  # upper: Q = U'U
        mean = cho_solve_banded((cb, False), kappa * y)
        z = rng.normal(size=n)
        # solve U th0 = z  -> th0 ~ N(0, Q^{-1})
        from scipy.linalg import solve_banded
        th = mean + solve_banded((0, 3), cb, z)
        if it >= burn:
            s1 += th; s2 += th**2
            ratio.append(lam * np.abs(D @ th).sum() / (n - 3))
            if it % 5 == 0:
                draws_c.append(th.copy())
    K = sweeps - burn
    m1 = s1 / K
    var = s2 / K - m1**2
    W = np.array(draws_c) - m1
    W = W - (W @ Qx) @ Qx.T
    rough = np.mean((W**2).sum(axis=1) / n)
    return dict(bias2=np.mean((m1 - ts) ** 2), spread=var.mean(), rough=rough,
                ratio=np.mean(ratio), mse_post=np.mean((m1 - ts) ** 2) + var.mean())


if __name__ == "__main__":
    truth = sys.argv[1] if len(sys.argv) > 1 else "S"
    print(f"truth={truth}, kappa=16 (Gaussian sd 0.25).  pred rough ~ C*16^(-5/6)*lam^(-1/3) = C*0.099*lam^(-1/3)")
    print("    n      a       lam      bias2     spread     rough   rough*lam^(1/3)/0.099  lam|Dth|/m")
    for n in [250, 500, 1000, 2000]:
        for a in [1.5, 2.0, 2.25, 2.5]:
            lam = float(n) ** a
            r = run(n, lam, truth=truth, sweeps=2500, burn=800, seed=n + int(10 * a))
            print(f"{n:5d} {a:6.3f} {lam:10.3e} {r['bias2']:9.2e} {r['spread']:9.2e} {r['rough']:9.2e} "
                  f"{r['rough']*lam**(1/3)/0.0992:10.3f} {r['ratio']:10.3f}", flush=True)
