"""Exact global Fubini threshold omega_glob (re-run of the VP's unsaved check).
omega_glob = sup{omega : E exp(-omega X(d)) <= 1 for all d in [-Dmax, Dmax]}, with X(d) the
check-loss increment of noise Z centred at its tau-quantile. Exact MGF:
  d>0: e^{-w(1-tau)d}[1 + w int_0^d e^{ws}(1-F(s)) ds];   d<0 (d=-a): e^{-w tau a}[1 + w int_0^a e^{ws}F(-s) ds].
Reports omega_glob / omega_bar_local (omega_bar_local = f(q)/(tau(1-tau))), and sigma_bar_B/sigma0 = 1/(omega_glob*sigma0),
with sigma0 = E rho_tau(Z) (the paper's regime)."""
import numpy as np
from scipy import stats, integrate

DMAX, NS = 40.0, 400001

class Mix:
    def __init__(s, w, comps): s.w, s.c = np.array(w), comps
    def cdf(s, x): return sum(wi*c.cdf(x) for wi, c in zip(s.w, s.c))
    def pdf(s, x): return sum(wi*c.pdf(x) for wi, c in zip(s.w, s.c))
    def ppf(s, p):
        from scipy.optimize import brentq
        return brentq(lambda x: s.cdf(x)-p, -50, 50)

def max_mgf(dist, q, tau, w):
    s = np.linspace(0, DMAX, NS); ds = s[1]-s[0]
    Fr = dist.cdf(q+s); Fl = dist.cdf(q-s)
    # cumulative integrals int_0^d e^{ws}(1-F(s)) ds and int_0^a e^{ws}F(-s) ds, computed in log-safe form
    with np.errstate(divide='ignore'):
        gr = np.exp(w*s + np.log(np.clip(1-Fr, 0, None)))   # log-space: avoids inf*0 = nan
        gl = np.exp(w*s + np.log(np.clip(Fl, 0, None)))
    assert np.all(np.isfinite(gr)) and np.all(np.isfinite(gl)), "overflow: reduce DMAX"
    Ir = np.concatenate([[0], np.cumsum((gr[1:]+gr[:-1])/2*ds)])
    Il = np.concatenate([[0], np.cumsum((gl[1:]+gl[:-1])/2*ds)])
    Mr = np.exp(-w*(1-tau)*s)*(1+w*Ir); Ml = np.exp(-w*tau*s)*(1+w*Il)
    return max(Mr[1:].max(), Ml[1:].max())

def omega_glob(dist, tau):
    q = dist.ppf(tau)
    lo, hi = 1e-4, 50.0
    # the local threshold is an upper bound; start hi there
    fq = dist.pdf(q); wloc = fq/(tau*(1-tau)); hi = min(hi, wloc*1.0001)
    if max_mgf(dist, q, tau, hi*0.999) <= 1: return hi*0.999, wloc, q
    for _ in range(50):
        mid = (lo+hi)/2
        if max_mgf(dist, q, tau, mid) <= 1+1e-12: lo = mid
        else: hi = mid
    return lo, wloc, q

def sigma0(dist, q, tau):
    rho = lambda z: z*(tau-(z < 0))
    pdf = lambda x: dist.pdf(x)
    return integrate.quad(lambda x: rho(x-q)*pdf(x), -np.inf, np.inf, limit=400)[0]

dists = {
    "gaussian": stats.norm(), "laplace": stats.laplace(), "logistic": stats.logistic(),
    "uniform": stats.uniform(-1, 2),
    "mixture .9N(0,.1^2)+.1N(0,3^2)": Mix([0.9, 0.1], [stats.norm(0, 0.1), stats.norm(0, 3)]),
}
print(f"grid: d in [-{DMAX},{DMAX}], {NS} points per side")
for name, d in dists.items():
    for tau in (0.5, 0.75, 0.9):
        if name == "uniform" and tau != 0.5:  # bounded support: fine, include
            pass
        wg, wl, q = omega_glob(d, tau)
        s0 = sigma0(d, q, tau)
        print(f"{name:32s} tau={tau:4.2f}  omega_loc={wl:8.4f}  omega_glob={wg:8.4f}  ratio={wg/wl:6.3f}  "
              f"sigma_bar_loc/sigma0={1/(wl*s0):6.3f}  sigma_bar_B/sigma0={1/(wg*s0):6.3f}")
