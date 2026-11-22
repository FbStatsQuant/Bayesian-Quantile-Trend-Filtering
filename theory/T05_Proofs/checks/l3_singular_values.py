"""L3 ingredients: (i) singular values of the N x N cumulative-sum matrix C_N equal
1/(2 sin((2k-1) pi/(2(2N+1)))); (ii) S = C^3[:, 3:] (columns 4..n) has entries (i-j-2)(i-j-1)/2;
(iii) sigma_r(A) <= 91.1 n^{5/2} r^{-3} for A = n^{-1/2} P_perp S."""
import numpy as np
for N in [5, 50, 400]:
    C = np.tril(np.ones((N, N)))
    sv = np.sort(np.linalg.svd(C, compute_uv=False))[::-1]
    k = np.arange(1, N + 1)
    pred = 1 / (2 * np.sin((2 * k - 1) * np.pi / (2 * (2 * N + 1))))
    print(f"N={N}: max rel err sv(C) vs formula = {np.max(np.abs(sv - pred) / pred):.2e}")
for n in [50, 300, 1200]:
    C = np.tril(np.ones((n, n))); C3 = C @ C @ C
    S = C3[:, 3:]
    D = np.diff(np.eye(n), 3, axis=0)
    print(f"n={n}: ||D S - I||_max = {np.abs(D @ S - np.eye(n - 3)).max():.1e}", end="; ")
    x = np.arange(1, n + 1) / n
    Q, _ = np.linalg.qr(np.vander(x, 3)); Pp = np.eye(n) - Q @ Q.T
    A = Pp @ S / np.sqrt(n)
    s = np.sort(np.linalg.svd(A, compute_uv=False))[::-1]
    r = np.arange(1, len(s) + 1)
    ratio = s / (n ** 2.5 * r ** -3.0)
    print(f"max_r sigma_r(A)/(n^2.5 r^-3) = {ratio.max():.4f} (bound 91.1); at r=1: {ratio[0]:.4f}")
