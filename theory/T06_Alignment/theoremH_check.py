"""Check Theorem H's leverage lemma (diag of spline projector <= 9/h) and trimmed Lemma F constant (<= 2.85 h^{5/2})."""
import numpy as np
def S_cols(n):
    i = np.arange(1, n+1)[:, None]; k = np.arange(1, n-2)[None, :]
    t = i - k - 1
    return np.where(i >= k + 3, t*(t-1)/2.0, 0.0)
for n in (60, 200, 600):
    S = S_cols(n); m = n - 3
    i = np.arange(1, n+1); Nb = np.vstack([np.ones(n), i, i*i]).T
    for h in (3, 5, 10, 20):
        Jp = m // h
        knots = [h*j for j in range(1, Jp)]          # trimmed: drop last knot J'h
        B = np.hstack([Nb, S[:, [k-1 for k in knots]]])
        Q, _ = np.linalg.qr(B)
        lev = (Q**2).sum(1).max()
        R = S - Q @ (Q.T @ S)
        dist = np.sqrt((R**2).sum(0)).max()
        print(f"n={n:4d} h={h:3d}  max leverage*h = {lev*h:6.3f} (<=9?)   max dist/h^2.5 = {dist/h**2.5:6.3f} (<=2.85?)")
