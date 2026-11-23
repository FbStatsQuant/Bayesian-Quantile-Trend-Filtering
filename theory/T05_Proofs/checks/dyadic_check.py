"""Verify Fable's dyadic staircase example (AUDIT_fable_B #1).
Z = +-2^{-k-1} w.p. 2^{-k-2} each (k>=0), tau=1/2. Exact (discrete) MGF of X(d)=rho(Z-d)-rho(Z).
Report g(omega) = inf_d -log E e^{-omega X(d)} / (omega*min(d^2,|d|)) on a log grid d in [1e-6, 40] (symmetric law: d>0 suffices),
and the secant constants on [-L, L]."""
import numpy as np
from fractions import Fraction
K = 70
k = np.arange(K); z = 2.0**(-k-1); p = 2.0**(-k-2)
Z = np.concatenate([z, -z]); P = np.concatenate([p, p]); P = P/P.sum()   # renormalise the truncated tail (mass 2^-K)
tau = 0.5
rho = lambda r: r*(tau-(r < 0))
def mgf(w, d): return np.sum(P*np.exp(-w*(rho(Z-d)-rho(Z))))
ds = np.unique(np.concatenate([np.logspace(-6, np.log10(40), 200001), z[z > 1e-6], z[z > 1e-6]*(1-1e-12), z[z>1e-6]*(1+1e-12)]))
for w in (2.0, 2.2, 2.5, 2.6, 2.66, 2.7):
    vals = np.array([-np.log(mgf(w, d))/(w*min(d*d, d)) for d in ds])
    i = np.argmin(vals)
    print(f"omega={w:5.2f}  inf g = {vals[i]: .5f} at d={ds[i]:.3e}   predicted local 1/3-omega/8 = {1/3-w/8: .5f}   max MGF = {max(mgf(w,d) for d in ds[::50]):.12f}")
# secant constants of F(d)-1/2 on (0, L]
F = lambda d: np.sum(P[(Z > 0) & (Z <= d)])
for L in (1.0, 0.5, 0.1, 0.01):
    g = np.logspace(-8, np.log10(L), 400001); r = np.array([F(x) for x in g[::40]])/g[::40]
    print(f"L={L}: secant inf ~ {r.min():.4f}, sup ~ {r.max():.4f}")
