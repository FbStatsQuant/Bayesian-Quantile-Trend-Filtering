"""Large-J_eff regime: lambda in [1e2,1e5], n up to 4000; slope of rough spread in lambda, Laplace vs Gaussian."""
import numpy as np
from laplace_gibbs_spread import run
from spread_gaussian_analog import eig_approx, rough
for n in [1000, 2000, 4000]:
    L, G = [], []
    lams = [1e2, 1e3, 1e4, 1e5]
    for lam in lams:
        r = run(n, lam, truth="PQ", sweeps=3000, burn=1000, seed=7 + n)
        g = rough(eig_approx(n), n, lam, kappa=16.0)
        L.append(r['rough']); G.append(g)
        print(f"n={n:5d} lam={lam:8.1e} rough_Lap={r['rough']:.3e} rough_Gauss={g:.3e} Lap/Gauss={r['rough']/g:.3f} "
              f"J_eff~{n*g*16:.1f} ratio={r['ratio']:.3f} bias2={r['bias2']:.2e}", flush=True)
    sL = np.polyfit(np.log(lams), np.log(L), 1)[0]; sG = np.polyfit(np.log(lams), np.log(G), 1)[0]
    print(f"n={n}: slope Laplace {sL:.3f}, Gaussian {sG:.3f} (pred -1/3)", flush=True)
