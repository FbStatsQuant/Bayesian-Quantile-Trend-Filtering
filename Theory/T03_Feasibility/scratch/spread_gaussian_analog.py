"""Gaussian-analogue check of the posterior-spread heuristic (T-03 scratch).

Analogue: Gaussian working likelihood with curvature kappa per observation (kappa ~ omega*f
for the ALD / check loss), Gaussian prior on u = D^(3) theta with the SAME variance as
Laplace(lambda) (var 2/lambda^2), flat on the 3-dim null space of D.
Posterior covariance (kappa I + (lambda^2/2) D'D)^{-1}; spread := tr / n.
Split: spread = 3/(n kappa) [parametric null-space part] + rough part
  rough = (1/n) sum_j 1 / (kappa + (lambda^2/2) e_j),  e_j = nonzero eigenvalues of D D'.
Direct inversion is ill-conditioned for lambda ~ n^2..n^3, so e_j are computed exactly by
eigvalsh only where precise (small n) and otherwise by the standard approximation
e_j ~ (2 sin(pi j/(2n)))^6; both are reported where they overlap.
Prediction: rough ~ c * kappa^{-5/6} * lambda^{-1/3}, independent of n, while
1 << n lambda^{-1/3} << n.
"""
import numpy as np


def eig_exact(n):
    D = np.diff(np.eye(n), n=3, axis=0)
    return np.linalg.eigvalsh(D @ D.T)


def eig_approx(n):
    j = np.arange(1, n - 2)
    return (2 * np.sin(np.pi * j / (2 * n))) ** 6


def rough(e, n, lam, kappa=1.0):
    return np.sum(1.0 / (kappa + 0.5 * lam**2 * e)) / n


if __name__ == "__main__":
    # 1) exact vs approx eigenvalues at moderate lambda (where float is fine)
    n = 400
    ee, ea = eig_exact(n), eig_approx(n)
    for lam in [1e2, 1e3, 1e4]:
        print(f"n={n} lam={lam:.0e}: rough exact={rough(ee,n,lam):.4e} approx={rough(ea,n,lam):.4e}")
    print()
    print("  n      a        lam      rough     rough*lam^(1/3)   J_eff=n*rough")
    for n in [250, 500, 1000, 2000, 4000, 8000]:
        e = eig_approx(n)
        for a in [1.5, 2.0, 15 / 7, 2.25, 7 / 3, 2.5, 2.75]:
            lam = float(n) ** a
            r = rough(e, n, lam)
            print(f"{n:5d} {a:6.3f} {lam:10.3e} {r:10.4e} {r*lam**(1/3):10.4f} {n*r:10.2f}")
    n = 4000
    e = eig_approx(n)
    lams = np.logspace(3, 9, 13)
    rr = np.array([rough(e, n, l) for l in lams])
    print(f"\nn={n}: d log(rough)/d log(lambda) = {np.polyfit(np.log(lams), np.log(rr), 1)[0]:.4f} (pred -1/3)")
    ks = np.array([0.25, 0.5, 1, 2, 4])
    rk = np.array([rough(e, n, 1e7, k) for k in ks])
    print(f"n={n}: d log(rough)/d log(kappa)  = {np.polyfit(np.log(ks), np.log(rk), 1)[0]:.4f} (pred -5/6)")
