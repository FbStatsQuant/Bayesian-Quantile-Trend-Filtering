"""Independent check (Theory, Python/scipy) of writing/W01_Statements Tables tab:simnoise and tab:simjoint.
R = sigma_bar/sigma0, sigma_bar = tau(1-tau)/min_u f_u(q_u), sigma0 = int_0^1 E rho_tau(eps_u - q_u) du."""
import numpy as np
from scipy import stats, integrate, optimize
ug = np.linspace(0, 1, 2001); sdm = np.sqrt(0.5)
def fams():
    G = dict(q=lambda t,u: stats.norm.ppf(t)*(1+u*u)/4, d=lambda x,u: stats.norm.pdf(x,0,(1+u*u)/4), lo=-np.inf, hi=np.inf)
    B = dict(q=lambda t,u: 1-(1-t)**(1/(11-10*u)), d=lambda x,u: stats.beta.pdf(x,1,11-10*u), lo=0.0, hi=1.0)
    def mq(t,u): return optimize.brentq(lambda x: u*stats.norm.cdf(x,-0.2,sdm)+(1-u)*stats.norm.cdf(x,0.2,sdm)-t,-10,10,xtol=1e-14)
    M = dict(q=mq, d=lambda x,u: u*stats.norm.pdf(x,-0.2,sdm)+(1-u)*stats.norm.pdf(x,0.2,sdm), lo=-np.inf, hi=np.inf)
    return dict(Gaussian=G, Beta=B, Mixed=M)
def risk(F,t,u):
    q=F['q'](t,u)
    up=integrate.quad(lambda x:(x-q)*F['d'](x,u),q,F['hi'],epsabs=1e-13,limit=200)[0]
    dn=integrate.quad(lambda x:(q-x)*F['d'](x,u),F['lo'],q,epsabs=1e-13,limit=200)[0]
    return t*up+(1-t)*dn
for nm,F in fams().items():
    for t in [0.05,0.25,0.5,0.75,0.95,0.90,0.93,0.96,0.97,0.98,0.99]:
        fu=np.array([F['d'](F['q'](t,u),u) for u in ug]); i=fu.argmin(); fmin=fu[i]
        s0=integrate.quad(lambda u: risk(F,t,u),0,1,limit=200,epsabs=1e-12)[0]
        sbar=t*(1-t)/fmin
        print(f"{nm:8s} tau={t:4.2f} fmin={fmin:.4f} (u*={ug[i]:.2f}) sigma0={s0:.5f} sbar={sbar:.4f} R={sbar/s0:.3f}")
