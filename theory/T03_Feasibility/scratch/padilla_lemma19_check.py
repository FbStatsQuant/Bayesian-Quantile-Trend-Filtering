"""Check Padilla & Chatterjee Lemma 19 (r=3): claimed ||P_R delta||_inf <= C TV3(delta)/n^{r-1}, TV3 = n^2 ||D3 delta||_1.
Equivalent claim: ||M||_max = O(1) for M = pinv(D3). VP: correct bound is ||P_R delta||_inf <~ TV3(delta)."""
import numpy as np
for n in [100, 200, 400, 800]:
    D = np.diff(np.eye(n), 3, axis=0)
    M = np.linalg.pinv(D)
    x = np.arange(1, n+1)/n
    d = 0.5*np.clip(x-0.5, 0, None)**2          # single kink in theta''
    Q, _ = np.linalg.qr(np.vander(x, 3)); PRd = d - Q @ (Q.T @ d)
    TV3 = n**2*np.abs(D@d).sum()
    print(f"n={n}: max|pinv(D3)|={np.abs(M).max():.3e} (n^2/2={n**2/2:.3e}); kink: ||P_R d||_inf={np.abs(PRd).max():.4f}, "
          f"TV3={TV3:.3f}, ratio sup/TV3={np.abs(PRd).max()/TV3:.4f}, Padilla bound C*TV3/n^2={TV3/n**2:.2e}")
