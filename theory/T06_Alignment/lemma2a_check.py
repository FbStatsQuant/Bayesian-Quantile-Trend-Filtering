# Numerical check of Lemma 2a (FABLE_A_three_lemmas.md §3.1): interlacing bounds on eig(D D^T), D = D^(3).
import numpy as np
for n in (20, 100, 400):
    m = n - 3
    D = np.zeros((m, n))
    for i in range(m):
        D[i, i:i + 4] = [-1, 3, -3, 1]
    mu = np.sort(np.linalg.eigvalsh(D @ D.T))
    r = np.arange(1, m + 1)
    lo = (2 * np.sin(np.pi * np.floor(r / 2) / n)) ** 6
    hi = (2 * np.sin(np.pi * np.floor((r + 3) / 2) / n)) ** 6
    hi2 = (np.pi * (r + 3) / n) ** 6
    print(n, "lower ok", np.all(lo <= mu * (1 + 1e-9) + 1e-12),
          "upper ok", np.all(mu <= hi * (1 + 1e-9) + 1e-12),
          "pi-bound ok", np.all(hi <= hi2 * (1 + 1e-12)))
