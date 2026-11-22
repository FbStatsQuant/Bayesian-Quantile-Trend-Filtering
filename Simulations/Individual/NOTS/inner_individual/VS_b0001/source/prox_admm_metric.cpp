// Preconditioned proximal map for Bayesian quantile trend filtering (augmented form)
//
//   T(x) = argmin_theta  sum_i a_i/2 (theta_i - r_i)^2 + lambda ||D theta||_1
//                        + (1/(2 gamma)) (theta - x)' M (theta - x),      M = diag(d) + c D'D
// (d = 1, c = 0 gives the plain Euclidean prox; d = a, c = lambda^2/2 is the curvature-matched metric)
//
// D = (k+1)-th order difference operator (m = n-k-1 rows).  Solved by ADMM with v = D theta:
//   theta <- (Q + rho D'D)^{-1} (b + rho D'(v - u)),   Q = diag(a) + M/gamma,  b = a*r + M x/gamma
//   v     <- soft(D theta + u, lambda/rho)
//   u     <- u + D theta - v
// Cold start (v = D x, u = 0), fixed iteration budget with an optional residual-based early exit: T is a deterministic
// map of x, which is all the Metropolis-Hastings correction needs.  pmala_move() does forward prox, noise and reverse prox
// on ONE factorisation of the ADMM system and one of the metric.  Banded Cholesky, half-bandwidth p = k+1.
//
// Also exported: minv_sqrt_noise(xi, d, c, k) = L^{-T} xi with M = L L' (so it is N(0, M^{-1}) if xi ~ N(0, I)),
// and mnorm2(v, d, c, k) = v' M v.
#include <Rcpp.h>
#include <vector>
#include <cmath>
#include <algorithm>
using namespace Rcpp;

// ---- difference stencil: coefficients of the (p)-th difference, length p+1 -------------
static std::vector<double> diff_stencil(int p) {
  std::vector<double> s(1, 1.0);
  for (int d = 0; d < p; ++d) {              // repeatedly apply first difference
    std::vector<double> t(s.size() + 1, 0.0);
    for (size_t i = 0; i < s.size(); ++i) { t[i] -= s[i]; t[i + 1] += s[i]; }
    s = t;
  }
  return s;
}

// D x : length n - p
static void apply_D(const std::vector<double>& x, const std::vector<double>& st, std::vector<double>& out) {
  int p = (int)st.size() - 1, m = (int)x.size() - p;
  for (int j = 0; j < m; ++j) { double s = 0; for (int l = 0; l <= p; ++l) s += st[l] * x[j + l]; out[j] = s; }
}
// D' v : length n
static void apply_Dt(const std::vector<double>& v, const std::vector<double>& st, std::vector<double>& out) {
  int p = (int)st.size() - 1, m = (int)v.size(), n = m + p;
  std::fill(out.begin(), out.end(), 0.0);
  for (int j = 0; j < m; ++j) for (int l = 0; l <= p; ++l) out[j + l] += st[l] * v[j];
}

// band storage: B[d][i] = A(i, i+d), d = 0..p  (upper band by diagonal offset)
struct Band {
  int n, p; std::vector<std::vector<double>> B;
  Band(int n_, int p_) : n(n_), p(p_), B(p_ + 1, std::vector<double>(n_, 0.0)) {}
  double& at(int i, int d) { return B[d][i]; }
};

// D'D as a band (symmetric, half-bandwidth p)
static Band DtD_band(int n, const std::vector<double>& st) {
  int p = (int)st.size() - 1, m = n - p; Band A(n, p);
  for (int j = 0; j < m; ++j)
    for (int l = 0; l <= p; ++l) for (int l2 = l; l2 <= p; ++l2)
      A.at(j + l, l2 - l) += st[l] * st[l2];
  return A;
}

// banded Cholesky A = L L' in place (L stored as lower band: L[d][i] = L(i+d, i)); returns false if a pivot is <= 0
static bool band_chol_try(Band& A) {
  int n = A.n, p = A.p;
  for (int j = 0; j < n; ++j) {
    double s = A.at(j, 0);
    for (int d = 1; d <= p && j - d >= 0; ++d) s -= A.B[d][j - d] * A.B[d][j - d];
    if (s <= 0) return false;
    double ljj = std::sqrt(s); A.at(j, 0) = ljj;
    for (int i = j + 1; i <= j + p && i < n; ++i) {
      double t = A.B[i - j][j];                       // A(j, i) stored at B[i-j][j]
      for (int d = 1; d <= p && j - d >= 0 && i - (j - d) <= p; ++d) t -= A.B[i - (j - d)][j - d] * A.B[d][j - d];
      A.B[i - j][j] = t / ljj;                        // L(i, j)
    }
  }
  return true;
}
static void band_chol(Band& A, const char* what) {
  if (!band_chol_try(A)) stop("banded Cholesky (%s): matrix not positive definite", what);
}
// Cholesky with a relative ridge retry (roundoff on badly scaled systems): the ridge is part of the solver, so the
// resulting map is still a deterministic function of its inputs.
static void band_chol_ridge(Band& A, const char* what) {
  Band A0 = A; double dmax = 0; for (int i = 0; i < A.n; ++i) dmax = std::max(dmax, A0.B[0][i]);
  double eps = 1e-12;
  for (int k = 0; k < 6; ++k) {
    A = A0; for (int i = 0; i < A.n; ++i) A.B[0][i] += eps * dmax;
    if (band_chol_try(A)) return;
    eps *= 100;
  }
  stop("banded Cholesky (%s): not positive definite even with ridge", what);
}
// solve L L' x = b
static void band_solve(const Band& L, std::vector<double>& x) {
  int n = L.n, p = L.p;
  for (int i = 0; i < n; ++i) {                        // forward: L y = b
    double s = x[i];
    for (int d = 1; d <= p && i - d >= 0; ++d) s -= L.B[d][i - d] * x[i - d];
    x[i] = s / L.B[0][i];
  }
  for (int i = n - 1; i >= 0; --i) {                   // backward: L' x = y
    double s = x[i];
    for (int d = 1; d <= p && i + d < n; ++d) s -= L.B[d][i] * x[i + d];
    x[i] = s / L.B[0][i];
  }
}
// solve L' x = b only (for M^{-1/2} noise)
static void band_solve_Lt(const Band& L, std::vector<double>& x) {
  int n = L.n, p = L.p;
  for (int i = n - 1; i >= 0; --i) {
    double s = x[i];
    for (int d = 1; d <= p && i + d < n; ++d) s -= L.B[d][i] * x[i + d];
    x[i] = s / L.B[0][i];
  }
}


// ---- ADMM core on a prefactored system -------------------------------------------------------
// Runs the ADMM for T(x) given the Cholesky factor of A = diag(a) + M/gamma + rho D'D (shared by every prox call with the
// same (a, d, c, gamma, rho)).  Early exit when the relative primal residual ||D theta - v|| / (||D theta|| + eps) and the
// relative dual residual rho ||D'(v - v_old)|| / (||b|| + eps) both fall below tol; the rule depends on the iterates only, so
// T remains a deterministic function of its inputs.  tol <= 0 disables the exit (fixed max_iter, the previous behaviour).
// INCREMENT FORM (2026-09-29): the theta-update solves for w = theta - x,
//   A w = a (r - x) + rho D'(v - u - D x),        theta = x + w,
// which is algebraically identical to A theta = a r + M x / gamma + rho D'(v - u) (subtract A x from both sides), so T is the
// same function.  Numerically it is not: at small gamma the absolute right-hand side is of order ||M|| |x| / gamma and the
// solve's relative round-off becomes an absolute error ~ eps cond(A) |x| in theta that does not shrink with gamma; the
// Hastings term divides it by delta and the chain stops accepting.  The increment right-hand side is O(|T(x) - x|).
static int admm_core(const Band& A, const std::vector<double>& st, const std::vector<double>& b,
                     const std::vector<double>& x, const std::vector<double>& Dx0, double lambda, double rho, int max_iter, double tol,
                     std::vector<double>& theta) {
  int n = (int)b.size(), m = (int)Dx0.size();
  std::vector<double> v(Dx0), u(m, 0.0), Dth(m), Dw(m), tmp(m), rhs(n), vold(m), dv(n);
  double thr = lambda / rho, bn = 0; for (int i = 0; i < n; ++i) bn += b[i] * b[i]; bn = std::sqrt(bn);
  theta.assign(x.begin(), x.end());
  int it = 0;
  for (it = 0; it < max_iter; ++it) {
    for (int j = 0; j < m; ++j) tmp[j] = (v[j] - Dx0[j]) - u[j];
    apply_Dt(tmp, st, rhs);
    for (int i = 0; i < n; ++i) rhs[i] = b[i] + rho * rhs[i];
    band_solve(A, rhs);                                                  // rhs <- w = theta - x
    for (int i = 0; i < n; ++i) theta[i] = x[i] + rhs[i];
    apply_D(rhs, st, Dw);
    for (int j = 0; j < m; ++j) Dth[j] = Dx0[j] + Dw[j];
    vold = v;
    double rp = 0, dn = 0;
    for (int j = 0; j < m; ++j) {
      double w = Dth[j] + u[j];
      v[j] = (w > thr) ? w - thr : (w < -thr ? w + thr : 0.0);
      u[j] = w - v[j];
      rp += (Dth[j] - v[j]) * (Dth[j] - v[j]); dn += Dth[j] * Dth[j];
    }
    if (tol > 0) {
      for (int j = 0; j < m; ++j) tmp[j] = v[j] - vold[j];
      apply_Dt(tmp, st, dv); double rd = 0; for (int i = 0; i < n; ++i) rd += dv[i] * dv[i];
      if (std::sqrt(rp) <= tol * (std::sqrt(dn) + 1e-12) && rho * std::sqrt(rd) <= tol * (bn + 1e-12)) { ++it; break; }
    }
  }
  return it;
}
static void build_system(int n, int p, const std::vector<double>& st, NumericVector a, NumericVector d, double c,
                         double gamma, double rho, Band& A) {
  Band DtD = DtD_band(n, st);
  for (int q = 0; q <= p; ++q) for (int i = 0; i < n; ++i) A.B[q][i] = (c / gamma + rho) * DtD.B[q][i];
  for (int i = 0; i < n; ++i) A.B[0][i] += a[i] + d[i] / gamma;
  band_chol_ridge(A, "ADMM system");
}
static void build_rhs(int n, const std::vector<double>& st, NumericVector a, NumericVector r, NumericVector d, double c,
                      double gamma, const std::vector<double>& xv, std::vector<double>& Dx, std::vector<double>& b) {
  int m = (int)Dx.size(); std::vector<double> DtDx(n);
  apply_D(xv, st, Dx); (void)DtDx; (void)d; (void)c; (void)gamma;
  for (int i = 0; i < n; ++i) b[i] = a[i] * (r[i] - xv[i]);            // increment form: b = a (r - x)
  (void)m;
}

// One complete P-MALA move with a SHARED factorisation: forward prox T(theta), proposal theta* = T(theta) + sqrt(delta) P^{-1/2} xi,
// reverse prox T(theta*), and the two P-norms of the Hastings term.  xi ~ N(0, I) is supplied by R (RNG stays in R).
// Returns prop, p = T(theta), pstar = T(prop), q_fwd = ||prop - p||_P^2, q_rev = ||theta - pstar||_P^2, iterations used.
// [[Rcpp::export]]
List pmala_move(NumericVector theta, NumericVector a, NumericVector r, double lambda, double gamma,
                NumericVector d, double c, int k, double rho, int max_iter, double tol, NumericVector xi, double delta) {
  int n = theta.size(), p = k + 1, m = n - p;
  if (m < 1) stop("n too small for the difference order");
  std::vector<double> st = diff_stencil(p);
  Band A(n, p); build_system(n, p, st, a, d, c, gamma, rho, A);          // one factorisation for both proxes
  std::vector<double> th(theta.begin(), theta.end()), Dx(m), b(n), pf(n), pr(n), prop(n);
  build_rhs(n, st, a, r, d, c, gamma, th, Dx, b);
  int it1 = admm_core(A, st, b, th, Dx, lambda, rho, max_iter, tol, pf);      // forward prox
  // metric P = diag(d) + c D'D, factor once for the noise and the two norms
  Band M = DtD_band(n, st);
  for (int q = 0; q <= p; ++q) for (int i = 0; i < n; ++i) M.B[q][i] *= c;
  for (int i = 0; i < n; ++i) M.B[0][i] += d[i];
  std::vector<double> z(xi.begin(), xi.end());
  { Band Mc = M; band_chol(Mc, "metric P"); band_solve_Lt(Mc, z); }        // z = L^{-T} xi ~ N(0, P^{-1})
  double sq = std::sqrt(delta);
  for (int i = 0; i < n; ++i) prop[i] = pf[i] + sq * z[i];
  build_rhs(n, st, a, r, d, c, gamma, prop, Dx, b);
  int it2 = admm_core(A, st, b, prop, Dx, lambda, rho, max_iter, tol, pr);      // reverse prox, same factor
  // P-norms: v' P v = sum d v^2 + c ||D v||^2
  auto pnorm2 = [&](const std::vector<double>& v) {
    std::vector<double> Dv(m); apply_D(v, st, Dv); double s1 = 0, s2 = 0;
    for (int i = 0; i < n; ++i) s1 += d[i] * v[i] * v[i];
    for (int j = 0; j < m; ++j) s2 += Dv[j] * Dv[j];
    return s1 + c * s2; };
  std::vector<double> v1(n), v2(n);
  for (int i = 0; i < n; ++i) { v1[i] = prop[i] - pf[i]; v2[i] = th[i] - pr[i]; }
  return List::create(_["prop"] = NumericVector(prop.begin(), prop.end()), _["p"] = NumericVector(pf.begin(), pf.end()),
                      _["pstar"] = NumericVector(pr.begin(), pr.end()), _["q_fwd"] = pnorm2(v1), _["q_rev"] = pnorm2(v2),
                      _["iters"] = IntegerVector::create(it1, it2));
}

// [[Rcpp::export]]
NumericVector prox_admm_metric(NumericVector x, NumericVector a, NumericVector r,
                               double lambda, double gamma, NumericVector d, double c, int k,
                               double rho, int max_iter, double tol = 0.0) {
  int n = x.size(), p = k + 1, m = n - p;
  if (m < 1) stop("n too small for the difference order");
  std::vector<double> st = diff_stencil(p);
  Band A(n, p); build_system(n, p, st, a, d, c, gamma, rho, A);
  std::vector<double> xv(x.begin(), x.end()), Dx(m), b(n), theta(n);
  build_rhs(n, st, a, r, d, c, gamma, xv, Dx, b);
  admm_core(A, st, b, xv, Dx, lambda, rho, max_iter, tol, theta);
  return NumericVector(theta.begin(), theta.end());
}

// [[Rcpp::export]]
NumericVector minv_sqrt_noise(NumericVector xi, NumericVector d, double c, int k) {
  int n = xi.size(), p = k + 1;
  std::vector<double> st = diff_stencil(p);
  Band M = DtD_band(n, st);
  for (int q = 0; q <= p; ++q) for (int i = 0; i < n; ++i) M.B[q][i] *= c;
  for (int i = 0; i < n; ++i) M.B[0][i] += d[i];
  band_chol(M, "metric P");
  std::vector<double> z(xi.begin(), xi.end());
  band_solve_Lt(M, z);                                 // z = L^{-T} xi  ~ N(0, M^{-1})
  return NumericVector(z.begin(), z.end());
}


// log det P for P = diag(d) + c D'D (from the banded Cholesky): needed when a proposal's metric differs between forward and reverse.
// [[Rcpp::export]]
double metric_logdet(NumericVector d, double c, int k) {
  int n = d.size(), p = k + 1;
  std::vector<double> st = diff_stencil(p);
  Band M = DtD_band(n, st);
  for (int q = 0; q <= p; ++q) for (int i = 0; i < n; ++i) M.B[q][i] *= c;
  for (int i = 0; i < n; ++i) M.B[0][i] += d[i];
  band_chol(M, "metric P");
  double s = 0; for (int i = 0; i < n; ++i) s += std::log(M.B[0][i]);
  return 2.0 * s;
}

// [[Rcpp::export]]
double mnorm2(NumericVector v, NumericVector d, double c, int k) {
  int n = v.size(), p = k + 1, m = n - p;
  std::vector<double> st = diff_stencil(p), vv(v.begin(), v.end()), Dv(m);
  apply_D(vv, st, Dv);
  double s = 0, t = 0;
  for (int i = 0; i < n; ++i) s += d[i] * vv[i] * vv[i];
  for (int j = 0; j < m; ++j) t += Dv[j] * Dv[j];
  return s + c * t;
}

// ---- plain .Call entry points (for a manual g++ build without Rtools; sourceCpp ignores these) ----
extern "C" SEXP C_prox_admm_metric(SEXP x, SEXP a, SEXP r, SEXP lambda, SEXP gamma, SEXP d, SEXP c, SEXP k, SEXP rho, SEXP max_iter, SEXP tol) {
  BEGIN_RCPP
  return wrap(prox_admm_metric(as<NumericVector>(x), as<NumericVector>(a), as<NumericVector>(r),
                               as<double>(lambda), as<double>(gamma), as<NumericVector>(d), as<double>(c), as<int>(k),
                               as<double>(rho), as<int>(max_iter), as<double>(tol)));
  END_RCPP
}
extern "C" SEXP C_pmala_move(SEXP theta, SEXP a, SEXP r, SEXP lambda, SEXP gamma, SEXP d, SEXP c, SEXP k, SEXP rho, SEXP max_iter, SEXP tol, SEXP xi, SEXP delta) {
  BEGIN_RCPP
  return wrap(pmala_move(as<NumericVector>(theta), as<NumericVector>(a), as<NumericVector>(r), as<double>(lambda), as<double>(gamma),
                         as<NumericVector>(d), as<double>(c), as<int>(k), as<double>(rho), as<int>(max_iter), as<double>(tol),
                         as<NumericVector>(xi), as<double>(delta)));
  END_RCPP
}
extern "C" SEXP C_minv_sqrt_noise(SEXP xi, SEXP d, SEXP c, SEXP k) {
  BEGIN_RCPP
  return wrap(minv_sqrt_noise(as<NumericVector>(xi), as<NumericVector>(d), as<double>(c), as<int>(k)));
  END_RCPP
}
extern "C" SEXP C_metric_logdet(SEXP d, SEXP c, SEXP k) {
  BEGIN_RCPP
  return wrap(metric_logdet(as<NumericVector>(d), as<double>(c), as<int>(k)));
  END_RCPP
}
extern "C" SEXP C_mnorm2(SEXP v, SEXP d, SEXP c, SEXP k) {
  BEGIN_RCPP
  return wrap(mnorm2(as<NumericVector>(v), as<NumericVector>(d), as<double>(c), as<int>(k)));
  END_RCPP
}
