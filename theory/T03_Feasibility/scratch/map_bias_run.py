import numpy as np
from map_bias import tf_noiseless, truths
for n in [250, 500, 1000, 2000]:
    T = truths(n)
    for name, ts in T.items():
        V = n**2*np.abs(np.diff(ts,3)).sum()
        for a in [1.25, 1.5, 1.75]:
            mu = float(n)**a
            try:
                th,kkt,feas = tf_noiseless(ts, mu, iters=8000)
            except Exception as e:
                print(name,n,a,"fail",e); continue
            b2 = np.mean((th-ts)**2)
            print(f"{name:2s} n={n:5d} a={a:4.2f} mu={mu:9.3e} bias2={b2:9.3e} bound2muV/n3={2*mu*V/n**3:9.3e} kkt={kkt:7.1e} feas={feas:5.3f}", flush=True)
