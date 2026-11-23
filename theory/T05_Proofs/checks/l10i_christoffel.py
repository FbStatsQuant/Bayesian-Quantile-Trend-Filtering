"""L10-I check: C_eq(w) := max over nodes k of b(x_k)^T G_w^{-1} b(x_k), with x_k = (k-1)/(w-1), b = (1,x,x^2),
G_w = w^{-1} sum_k b b^T.  Claim: sup_{w>=3} C_eq(w) <= 9 (continuous Christoffel value (p+1)^2 = 9 at endpoints).
Also checks the discrete interpolation inequality ||d||_inf <= 2 sqrt(C) ||d||_n + K1 ||d||_n^{4/5} T^{1/5} on random and
adversarial vectors (spikes, local quadratics, kinks)."""
import numpy as np
Cs = []
for w in list(range(3, 60)) + [100, 1000, 10000]:
    x = np.arange(w)/(w-1); B = np.vstack([np.ones(w), x, x**2]).T
    G = B.T @ B / w; Gi = np.linalg.inv(G)
    Cs.append((w, np.max(np.einsum('ij,jk,ik->i', B, Gi, B))))
print("C_eq(w) for w=3..: ", [(w, round(c, 4)) for w, c in Cs[:8]], "... w=10000:", round(Cs[-1][1], 4))
C = max(c for _, c in Cs); print("sup C_eq =", C)
K1 = max((6*C*(2*np.sqrt(C))**0.5)**0.4, (18*np.sqrt(C))**0.2)
print("K1 =", K1)
rng = np.random.default_rng(0); worst = 0
for n in (20, 200, 2000):
    for trial in range(300):
        kind = trial % 4
        i = np.arange(n)
        if kind == 0: d = rng.standard_normal(n)
        elif kind == 1: d = np.zeros(n); d[rng.integers(n)] = 1.0
        elif kind == 2:
            c = rng.integers(n); w = rng.integers(3, n); d = np.clip(1-((i-c)/w)**2, 0, None)
        else: d = np.cumsum(np.cumsum(np.cumsum(rng.standard_normal(n)*(rng.random(n) < 0.02))))
        T = n**2*np.abs(np.diff(d, 3)).sum(); a = np.sqrt(np.mean(d**2)); s = np.abs(d).max()
        bound = 2*np.sqrt(C)*a + K1*a**0.8*T**0.2
        worst = max(worst, s/bound)
print("max ||d||_inf / bound over tests =", round(worst, 4), "(must be <= 1)")
