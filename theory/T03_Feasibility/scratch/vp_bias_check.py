"""VP bias check (T-03, item C7a): Laplace-prior posterior-mean bias vs smoothing-spline bias.

Noiseless data y = theta* (kinked truth PQ), Gaussian likelihood precision kappa, prior
u = D3 theta iid Laplace(lambda), flat on quadratics.  Exact Park-Casella Gibbs,
Rao-Blackwellised posterior mean (average of conditional means).
Reference: Gaussian prior with the same variance (2/lambda^2) -> posterior mean = spline smoother
solving (kappa I + (lambda^2/2) D'D) theta = kappa y.
Numerics: Q = kappa I + D'WD has condition ~ 4 lambda^2/kappa, beyond double precision for
lambda >~ 1e6.  All banded Cholesky solves are done in numpy longdouble (80-bit, eps ~ 1e-19).
Draft prediction: bias2 ~ lambda V n^-3 / kappa (shift-lemma bound).
VP prediction:    bias2 ~ V^2 lambda^{5/3} n^-5 (x kappa-power), and Laplace bias2 ~ spline bias2.
"""
import sys
import numpy as np

LD = np.longdouble
DC = np.array([-1.0, 3.0, -3.0, 1.0])


def D3(v):
    return v[3:] * DC[3] + v[2:-1] * DC[2] + v[1:-2] * DC[1] + v[:-3] * DC[0]


def build_Q(n, w, kappa):
    """Band (lower) storage B[i, d] = Q[i, i-d], d=0..3, of Q = kappa I + D' diag(w) D (longdouble)."""
    B = np.zeros((n, 4), dtype=LD)
    w = w.astype(LD)
    c = DC.astype(LD)
    # D row j has entries c[a] at column j+a; it contributes w_j c[a] c[b] to Q[j+a, j+b]
    m = len(w)
    j = np.arange(m)
    for a in range(4):
        for b in range(4):
            if a >= b:
                B[j + a, a - b] += w * c[a] * c[b]
    B[:, 0] += LD(kappa)
    return B


def chol_band(B):
    n = B.shape[0]
    L = np.zeros_like(B)  # L[i, d] = L(i, i-d)
    for i in range(n):
        for d in range(min(3, i), -1, -1):
            k = i - d
            s = B[i, d]
            for e in range(1, 4):
                if d + e <= 3 and k - e >= 0:
                    s -= L[i, d + e] * L[k, e]
            if d == 0:
                if s <= 0:
                    raise np.linalg.LinAlgError("not PD")
                L[i, 0] = np.sqrt(s)
            else:
                L[i, d] = s / L[k, 0]
    return L


def solve_lower(L, b):
    n = len(b); x = np.zeros(n, dtype=LD)
    for i in range(n):
        s = b[i]
        for d in range(1, min(3, i) + 1):
            s -= L[i, d] * x[i - d]
        x[i] = s / L[i, 0]
    return x


def solve_upper(L, b):  # solves L' x = b
    n = len(b); x = np.zeros(n, dtype=LD)
    for i in range(n - 1, -1, -1):
        s = b[i]
        for d in range(1, 4):
            if i + d < n:
                s -= L[i + d, d] * x[i + d]
        x[i] = s / L[i, 0]
    return x


def truth_pq(n):
    x = np.arange(1, n + 1) / n
    t = 0.5 * (x - 0.5) ** 2
    for k, J in zip([0.3, 0.55, 0.8], [8.0, -12.0, 6.0]):
        t += 0.5 * J * np.clip(x - k, 0, None) ** 2
    return t


def run(n, lam, kappa=16.0, sweeps=600, burn=200, seed=0):
    rng = np.random.default_rng(seed)
    ts = truth_pq(n); y = ts.copy()
    yl = (kappa * y).astype(LD)
    # spline reference
    Ls = chol_band(build_Q(n, np.full(n - 3, 0.5 * lam**2), kappa))
    spl = np.asarray(solve_upper(Ls, solve_lower(Ls, yl)), dtype=float)
    th = spl.copy()
    acc = np.zeros(n); K = 0
    for it in range(sweeps):
        u = D3(th)
        # IG(mu, shape) scaling: X ~ IG(mu, s) <=> X = s * IG(mu/s, 1); avoids overflow for huge mu
        invt = lam**2 * rng.wald(1.0 / (lam * np.maximum(np.abs(u), 1e-300)), 1.0)
        L = chol_band(build_Q(n, invt, kappa))
        mean = solve_upper(L, solve_lower(L, yl))
        z = rng.normal(size=n).astype(LD)
        th = np.asarray(mean + solve_upper(L, z), dtype=float)
        if it >= burn:
            acc += np.asarray(mean, dtype=float); K += 1
    pm = acc / K
    V = n**2 * np.abs(np.diff(ts, 3)).sum()
    return dict(bias_lap=np.mean((pm - ts) ** 2), bias_spl=np.mean((spl - ts) ** 2), V=V)


if __name__ == "__main__":
    ns = [int(a) for a in sys.argv[1:]] or [300, 600, 1200]
    print("   n      a       lam     bias2_Laplace  bias2_spline  ratio   draft_bound=2lamV/(kappa n^3)  VP_scale=V^2 lam^(5/3) n^-5", flush=True)
    for n in ns:
        for a in [float(v) for v in __import__('os').environ.get('AS','2.0,2.25,2.5,2.67').split(',')]:
            lam = float(n) ** a
            try:
                r = run(n, lam, sweeps=500, burn=150, seed=n + int(100 * a))
            except np.linalg.LinAlgError:
                print(f"{n:5d} {a:5.2f} {lam:10.3e}  Cholesky failed", flush=True); continue
            db = 2 * lam * r['V'] / (16.0 * n**3)
            vp = r['V'] ** 2 * lam ** (5 / 3) * n ** -5.0
            print(f"{n:5d} {a:5.2f} {lam:10.3e} {r['bias_lap']:12.3e} {r['bias_spl']:12.3e} {r['bias_lap']/r['bias_spl']:7.3f} "
                  f"{db:14.3e} {vp:14.3e}", flush=True)
