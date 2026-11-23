"""beta = tau(1-tau)/(f sigma0) for the paper designs: worst-case f (min over u) and design-averaged f (arithmetic and harmonic mean over u).
sigma0 = int_0^1 E rho_tau(eps_u - q_u) du. Threshold (conjectural proxy, Fable A/B): beta < ~6 (A-rule lower tail at learned sigma)."""
import numpy as np
from scipy import stats, integrate, optimize
sdm = np.sqrt(0.5); ug = np.linspace(0, 1, 401)
fam = {
 "Gaussian": (lambda t,u: stats.norm.ppf(t)*(1+u*u)/4, lambda x,u: stats.norm.pdf(x,0,(1+u*u)/4), -np.inf, np.inf),
 "Beta": (lambda t,u: 1-(1-t)**(1/(11-10*u)), lambda x,u: stats.beta.pdf(x,1,11-10*u), 0.0, 1.0),
 "Mixed": (lambda t,u: optimize.brentq(lambda x: u*stats.norm.cdf(x,-0.2,sdm)+(1-u)*stats.norm.cdf(x,0.2,sdm)-t,-10,10),
           lambda x,u: u*stats.norm.pdf(x,-0.2,sdm)+(1-u)*stats.norm.pdf(x,0.2,sdm), -np.inf, np.inf)}
def risk(F,t,u):
    q,d,lo,hi = F; qq = q(t,u)
    return t*integrate.quad(lambda x:(x-qq)*d(x,u), qq, hi, limit=200)[0] + (1-t)*integrate.quad(lambda x:(qq-x)*d(x,u), lo, qq, limit=200)[0]
print(f"{'design':8s} {'tau':>5s} {'b_worst':>8s} {'b_avg':>7s} {'b_harm':>7s}   (proxy threshold ~6, conjectural)")
for nm, F in fam.items():
    for t in [0.01, 0.05, 0.25, 0.5, 0.75, 0.9, 0.95, 0.99]:
        fu = np.array([F[1](F[0](t,u),u) for u in ug])
        s0 = integrate.quad(lambda u: risk(F,t,u), 0, 1, limit=100)[0]
        tt = t*(1-t)
        bw = tt/(fu.min()*s0); ba = tt/(fu.mean()*s0); bh = tt*np.mean(1/fu)/s0
        flag = lambda b: "ok" if b < 6 else "FAIL"
        print(f"{nm:8s} {t:5.2f} {bw:8.2f} {ba:7.2f} {bh:7.2f}   worst:{flag(bw):4s} avg:{flag(ba)}")
