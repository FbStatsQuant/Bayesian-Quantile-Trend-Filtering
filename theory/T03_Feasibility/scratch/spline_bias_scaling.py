"""Spline (Gaussian-prior posterior mean) bias for the kinked truth PQ, noiseless, long double.
Since Laplace posterior-mean bias2 = spline bias2 within 0.5% wherever Gibbs is computable
(vp_bias_check*.out), this traces the posterior-mean bias along lambda = n^a to large n.
Also prints a risk proxy = bias2 + rough spread (0.3 kappa^-5/6 lambda^-1/3) + 3/(n kappa).
Draft (l1-shift) law: bias2 ~ n^{a-3};  VP (quadratic-shift) law: bias2 ~ n^{5a/3-5}."""
import numpy as np
from vp_bias_check import build_Q, chol_band, solve_lower, solve_upper, truth_pq, LD
kappa = 16.0
rows = []
for a in [2.0, 2.25, 2.5, 2.67]:
    prev = None
    for n in [600, 1200, 2400, 4800, 9600, 19200]:
        lam = float(n) ** a
        try:
            L = chol_band(build_Q(n, np.full(n - 3, 0.5 * lam**2), kappa))
        except np.linalg.LinAlgError:
            print(f"a={a} n={n}: chol failed"); continue
        ts = truth_pq(n)
        th = np.asarray(solve_upper(L, solve_lower(L, (kappa * ts).astype(LD))), float)
        b2 = np.mean((th - ts) ** 2)
        risk = b2 + 0.3 * kappa ** (-5 / 6) * lam ** (-1 / 3) + 3 / (n * kappa)
        sl = "" if prev is None else f" local slope bias {np.log(b2/prev[0])/np.log(n/prev[1]):6.2f}"
        print(f"a={a:4.2f} n={n:6d} lam={lam:9.2e} bias2={b2:9.3e} risk_proxy={risk:9.3e}{sl}"
              f"   [draft slope {a-3:5.2f}, VP slope {5*a/3-5:5.2f}]", flush=True)
        prev = (b2, n)
