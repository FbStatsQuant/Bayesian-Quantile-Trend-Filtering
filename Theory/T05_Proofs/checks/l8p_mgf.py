"""L8' check: exact MGF identity and the bound
   log E exp(-w X(d)) <= -B(w,Delta) * w * m(d),  |d| <= Delta,
   B = exp(-w*Delta - w^2 Delta^2/8) - w/wbar - 0.0322 w^2 Delta / f,  wbar = f/(tau(1-tau)).
Also checks sup |psi'''| <= 1/(6 sqrt 3) for the two-point log-MGF."""
import numpy as np
from scipy import stats, integrate

def exact_mgf(dist, tau, w, d):
    q = dist.ppf(tau)
    Z = lambda s: s  # centred coords
    F = lambda s: dist.cdf(q + s)
    if d > 0:
        # E e^{-wX} = e^{-w(1-tau)d} [1 + w int_0^d e^{ws}(1-F(s)) ds]
        I = integrate.quad(lambda s: np.exp(w*s)*(1-F(s)), 0, d, limit=200)[0]
        val = np.exp(-w*(1-tau)*d)*(1 + w*I)
        m = integrate.quad(lambda s: F(s)-tau, 0, d, limit=200)[0]
    else:
        a = -d
        I = integrate.quad(lambda s: np.exp(w*s)*F(-s), 0, a, limit=200)[0]
        val = np.exp(-w*tau*a)*(1 + w*I)
        m = integrate.quad(lambda s: tau-F(-s), 0, a, limit=200)[0]
    return val, m

def mc_mgf(dist, tau, w, d, N=2_000_000, rng=np.random.default_rng(1)):
    q = dist.ppf(tau); Z = dist.rvs(size=N, random_state=rng) - q
    rho = lambda r: r*(tau-(r<0))
    X = rho(Z-d) - rho(Z)
    return np.mean(np.exp(-w*X)), np.mean(X)

# psi''' bound
t = np.linspace(-40, 40, 200001)
worst = 0
for tau in np.linspace(0.01, 0.99, 99):
    qq = (1-tau)*np.exp(t)/(tau+(1-tau)*np.exp(t))
    worst = max(worst, np.max(np.abs(qq*(1-qq)*(1-2*qq))))
print(f"sup|psi'''| = {worst:.5f}  vs 1/(6 sqrt3) = {1/(6*np.sqrt(3)):.5f}")

dists = {"normal": stats.norm(), "cauchy": stats.cauchy(), "laplace": stats.laplace(),
         "t2": stats.t(2), "lognormal": stats.lognorm(1.5)}
for name, dist in dists.items():
    for tau in (0.5, 0.9, 0.05):
        q = dist.ppf(tau)
        # local margin constants on [-L, L], L = 0.5: f = min density, fbar = max density
        L = 0.5; ss = np.linspace(-L, L, 2001)
        f = dist.pdf(q+ss).min()
        wbar = f/(tau*(1-tau))
        # MC agreement at one point
        v, m = exact_mgf(dist, tau, 0.7*wbar, 0.3)
        mv, mm = mc_mgf(dist, tau, 0.7*wbar, 0.3, N=400_000)
        worstB = np.inf; ok = True
        for eta in (0.1, 0.3):
            w = (1-eta)*wbar
            for Delta in (0.02, 0.05, 0.1, 0.2, min(0.5, L)):
                B = np.exp(-w*Delta - w**2*Delta**2/8) - w/wbar - 0.0322*w**2*Delta/f
                for d in np.linspace(-Delta, Delta, 41):
                    if d == 0: continue
                    val, m = exact_mgf(dist, tau, w, d)
                    lhs = np.log(val); rhs = -B*w*m
                    if lhs > rhs + 1e-10: ok = False
        print(f"{name:9s} tau={tau:4.2f} f={f:.3f} wbar={wbar:.3f}  exact={v:.5f} MC={mv:.5f} m={m:.5f}/{mm:.5f}  bound holds: {ok}")
