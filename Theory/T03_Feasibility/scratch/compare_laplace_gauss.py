"""Compare Laplace-prior Gibbs rough spread (valid cells: lam|Dth|/m within 0.95-1.10) to the exact
Gaussian-analogue rough spread at the same (n, lambda, kappa=16)."""
import numpy as np, re
from spread_gaussian_analog import eig_approx, rough
rows = []
for f in ["laplace_gibbs_S.out", "laplace_gibbs_PQ.out"]:
    for line in open(f):
        p = line.split()
        if len(p) == 8 and p[0].isdigit():
            n, a, lam = int(p[0]), float(p[1]), float(p[2]); rr, ratio = float(p[5]), float(p[7])
            if 0.95 <= ratio <= 1.10:
                g = rough(eig_approx(n), n, lam, kappa=16.0)
                rows.append((('S' if '_S' in f else 'PQ'), n, a, lam, rr, g, rr/g, ratio))
print("truth  n     a      lam      rough_Lap  rough_Gauss  Lap/Gauss  ratio")
for r in rows:
    print(f"{r[0]:3s} {r[1]:5d} {r[2]:5.2f} {r[3]:10.3e} {r[4]:10.3e} {r[5]:10.3e} {r[6]:8.3f} {r[7]:7.3f}")
R = np.array([[r[3], r[4], r[1]] for r in rows])
for n in sorted(set(R[:,2])):
    m = R[:,2]==n
    if m.sum() >= 2:
        print(f"n={int(n)}: Laplace local slope d log rough / d log lam = {np.polyfit(np.log(R[m,0]), np.log(R[m,1]),1)[0]:.3f}")
