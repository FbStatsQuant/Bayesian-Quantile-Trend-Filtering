"""Check Tibshirani (2014) Lemma 2 for k=2: theta = H alpha with
H_ij = (i/n)^(j-1) (j<=3);  H_ij = (i-j+1)(i-j+2)/n^2 for i>=j, 0 otherwise (j>=4).
Claim: D3 H = [0 | (2/n^2) I_{n-3}]  =>  alpha_j = (n^2/2) (D3 theta)_{j-3}, j>=4,
so Laplace(lambda) on D3 theta  <=>  alpha_j iid Laplace(2 lambda / n^2), j>=4; flat on alpha_1..3.
Also reports column empirical norms ||h_j||_{2,n} (Large Prior Assumption 1 analogue)."""
import numpy as np
for n in [50, 400]:
    i = np.arange(1, n+1)[:, None]; j = np.arange(1, n+1)[None, :]
    H = np.where(j <= 3, (i/n)**(j-1).astype(float), np.where(i >= j, (i-j+1)*(i-j+2)/n**2, 0.0))
    D = np.diff(np.eye(n), n=3, axis=0)
    DH = D @ H
    target = np.zeros((n-3, n)); target[:, 3:] = (2/n**2)*np.eye(n-3)
    print(n, "max|D3 H - [0|(2/n^2)I]| =", np.abs(DH-target).max(), " (sign check:", np.sign(DH[0,3]), ")")
    cn = np.sqrt((H**2).mean(axis=0))
    print("   max col norm ||h_j||_{2,n} =", cn.max().round(4), " (j>=4 max:", cn[3:].max().round(4), " ~ (1/5)^(1/2)=0.447)")
    print("   cond(H) =", f"{np.linalg.cond(H):.2e}")
