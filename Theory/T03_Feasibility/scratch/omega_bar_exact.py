"""Exact learning-rate threshold for the Fubini (integrated-likelihood-ratio) route (T-03, CEO item on sigma-bar).

Check-loss increment for displacement delta>0, Z = y - theta*, F_Z(0) = tau:
   X = rho(Z - delta) - rho(Z) = (1-tau) delta - clip(Z, 0, delta)      (bounded, no moments)
   E e^{-w X} = e^{-w(1-tau)delta} [1 + int_0^delta w e^{w s} (1 - F(s)) ds]
   m(delta) = E X = int_0^delta (F(s) - tau) ds.
(delta<0 is symmetric with tau <-> 1-tau, F(s) <-> 1-F(-s).)
Second-order expansion at 0: log E e^{-wX} = 1/2 (w^2 tau(1-tau) - w f(0)) delta^2 + o(delta^2),
so the per-coordinate MGF is < 1 near 0 iff  w < w_bar := f(q_tau)/(tau(1-tau))   -- exact, not a Bernstein artefact.
w_bar(Delta) := sup{ w : log E e^{-wX(delta)} < 0 for all 0 < |delta| <= Delta }  (computed numerically).
Paper regime: w0 = 1/sigma0, sigma0 = E rho_tau(eps - q_tau).  Gap ratio R = w0/w_bar = tau(1-tau)/(f(q) sigma0).
"""
import numpy as np
from scipy import stats, integrate, optimize


def mgf_log(w, d, F, tau):
    if d > 0:
        I = integrate.quad(lambda s: w * np.exp(w * s) * (1 - F(s)), 0, d, limit=200)[0]
        return -w * (1 - tau) * d + np.log1p(I)
    else:  # delta<0: X = rho(Z+|d|) - rho(Z) ; mirror
        d = -d
        I = integrate.quad(lambda s: w * np.exp(w * s) * F(-s), 0, d, limit=200)[0]
        return -w * tau * d + np.log1p(I)


def w_bar_Delta(F, tau, Delta, wmax):
    grid = np.concatenate([-np.geomspace(1e-3, Delta, 40), np.geomspace(1e-3, Delta, 40)])
    ok = lambda w: all(mgf_log(w, d, F, tau) < 0 for d in grid)
    lo, hi = 1e-6, wmax
    if ok(hi):
        return hi
    for _ in range(40):
        mid = 0.5 * (lo + hi)
        lo, hi = (mid, hi) if ok(mid) else (lo, mid)
    return lo


def case(name, dist, tau, Deltas=(0.25, 1.0, 4.0)):
    q = dist.ppf(tau)
    F = lambda s: dist.cdf(q + s)
    f = dist.pdf(q)
    wbar = f / (tau * (1 - tau))
    sig0 = integrate.quad(lambda e: (e - q) * (tau - (e < q)) * dist.pdf(e), -np.inf, np.inf, limit=400)[0]
    w0 = 1 / sig0
    wb = [w_bar_Delta(F, tau, D * dist.std() if np.isfinite(dist.std()) else D, 3 * wbar) for D in Deltas]
    print(f"{name:28s} tau={tau:4.2f}  w_bar(local)={wbar:8.4f}  w_bar(Delta)={['%.4f' % x for x in wb]}  "
          f"w0=1/sigma0={w0:8.4f}  R=w0/w_bar={w0 / wbar:6.3f}")


if __name__ == "__main__":
    print("Delta values are multiples of the noise sd (raw units for Cauchy).")
    for tau in [0.5, 0.75, 0.9, 0.95]:
        case("Gaussian N(0,1)", stats.norm(), tau)
    case("Laplace (ALD-correct, tau=.5)", stats.laplace(), 0.5)
    case("Student t3", stats.t(3), 0.5)
    case("Student t2", stats.t(2), 0.5)
    case("Uniform(-1,1)", stats.uniform(-1, 2), 0.5)
    mix = stats.rv_continuous  # contaminated normal via custom
    class CN(stats.rv_continuous):
        def _pdf(self, x): return 0.9 * stats.norm.pdf(x, 0, 0.1) + 0.1 * stats.norm.pdf(x, 0, 3)
        def _cdf(self, x): return 0.9 * stats.norm.cdf(x, 0, 0.1) + 0.1 * stats.norm.cdf(x, 0, 3)
    cn = CN(name="cn")
    cn.std = lambda: np.sqrt(0.9 * 0.01 + 0.1 * 9)
    case("0.9 N(0,.1^2)+0.1 N(0,3^2)", cn, 0.5)
