"""Check Astra's necessary condition sigma0 <= 2 tau(1-tau) R for the paper's designs,
R = lim n^-1 ||D^3 y||_1 = int_0^1 E|e1 - 3e2 + 3e3 - e4| du (noise only; signal third differences are O(n^-3)),
sigma0 = int_0^1 E rho_tau(eps_u - q_u) du (as in gap_ratio_check). MC for R; quadrature for sigma0."""
import numpy as np
from scipy import stats, integrate, optimize
rng = np.random.default_rng(0); N = 400000; ug = np.linspace(0, 1, 41)
sdm = np.sqrt(0.5)
def draw(fam, u, size):
    if fam == "Gaussian": return rng.normal(0, (1+u*u)/4, size)
    if fam == "Beta": return rng.beta(1, 11-10*u, size)
    comp = rng.random(size) < u
    return np.where(comp, rng.normal(-0.2, sdm, size), rng.normal(0.2, sdm, size))
def Rval(fam):
    vals = []
    for u in ug:
        e = draw(fam, u, (N, 4))
        vals.append(np.mean(np.abs(e[:,0]-3*e[:,1]+3*e[:,2]-e[:,3])))
    return np.trapz(vals, ug)
def F(fam):
    if fam == "Gaussian": return (lambda t,u: stats.norm.ppf(t)*(1+u*u)/4, lambda x,u: stats.norm.pdf(x,0,(1+u*u)/4), -np.inf, np.inf)
    if fam == "Beta": return (lambda t,u: 1-(1-t)**(1/(11-10*u)), lambda x,u: stats.beta.pdf(x,1,11-10*u), 0.0, 1.0)
    q = lambda t,u: optimize.brentq(lambda x: u*stats.norm.cdf(x,-0.2,sdm)+(1-u)*stats.norm.cdf(x,0.2,sdm)-t,-10,10)
    return (q, lambda x,u: u*stats.norm.pdf(x,-0.2,sdm)+(1-u)*stats.norm.pdf(x,0.2,sdm), -np.inf, np.inf)
def sigma0(fam, t):
    q, d, lo, hi = F(fam)
    def r(u):
        qq = q(t,u)
        return t*integrate.quad(lambda x:(x-qq)*d(x,u), qq, hi, limit=200)[0] + (1-t)*integrate.quad(lambda x:(qq-x)*d(x,u), lo, qq, limit=200)[0]
    return integrate.quad(r, 0, 1, limit=100)[0]
for fam in ["Gaussian", "Beta", "Mixed"]:
    R = Rval(fam)
    for t in [0.01, 0.05, 0.25, 0.5, 0.75, 0.95, 0.99]:
        s0 = sigma0(fam, t); bound = 2*t*(1-t)*R
        print(f"{fam:8s} tau={t:4.2f} R={R:.4f} sigma0={s0:.5f} 2t(1-t)R={bound:.5f} ratio sigma0/bound={s0/bound:.3f} {'OK' if s0 <= bound else 'VIOLATED'}")
