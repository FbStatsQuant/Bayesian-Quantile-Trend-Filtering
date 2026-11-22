"""Deep small-ball regime: local slope d log phi / d log x -> 2/5 ? (Gaussian, saddle point)."""
import numpy as np
from small_ball import cov_eigs, log_sb_gauss
for n in [1000, 4000, 16000]:
    lam = n**2.25
    mu = cov_eigs(n, lam); typ = np.sqrt(mu.sum())
    fr = np.logspace(-1, -7, 25)
    xs, ph = [], []
    for f in fr:
        eps = f*typ
        xs.append(n**2.5/(lam*eps)); ph.append(-log_sb_gauss(mu, eps))
    xs, ph = np.array(xs), np.array(ph)
    loc = np.diff(np.log(ph))/np.diff(np.log(xs))
    print(f"n={n}: x from {xs[0]:.1e} to {xs[-1]:.1e} (discrete limit x~n^2.5={n**2.5:.1e})")
    for i in range(0, len(loc), 3):
        print(f"   x={xs[i]:9.2e} phi={ph[i]:10.2f} phi/x^0.4={ph[i]/xs[i]**0.4:7.3f} local slope={loc[i]:.3f}")
