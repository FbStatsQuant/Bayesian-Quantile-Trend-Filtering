// Box-constrained preconditioned proximal map for the joint (non-crossing) Bayesian quantile trend filter.
//
//   T_B(x) = argmin_{L <= theta <= U}  sum_i a_i/2 (theta_i - r_i)^2 + lambda ||D theta||_1
//                                       + (1/(2 gamma)) (theta - x)' M (theta - x),      M = diag(d) + c D'D
//
// D = (k+1)-th order difference operator (m = n-k-1 rows); every linear system is banded with half-bandwidth p = k+1.
// Two solvers, selected by ctrl[0] (= method):
//
// method 1 (default): UNBOUNDED ADMM FIRST, THEN A PRIMAL-DUAL INTERIOR-POINT METHOD.
//   Step 1: the unbounded kernel of prox_admm_metric.cpp (cold start, max_iter iterations).  If its output lies in [L, U]
//           it is the constrained minimiser (convexity) and is returned as is -- BITWISE the individual sampler's map.
//   Step 2: otherwise the QP  min_{theta,t} 1/2 theta'Q theta + q'theta + lambda 1't  s.t.  -t <= D theta <= t,  L <= theta <= U
//           (Q = diag(a) + M/gamma, q = -(a r + M x/gamma); coordinates with L_i = U_i are eliminated exactly) is solved by
//           Mehrotra's predictor-corrector method.  Eliminating t and the four slack/dual blocks leaves ONE banded SPD system
//           per Newton step,  (Q + D' W_t D + W_box) d_theta = rhs,  W_t = 4 W1 W2 / (W1 + W2),  so each iteration is O(n).
//           Warm-started from the clipped step-1 solution.  ipm_tol is an accuracy in THETA units: the primal residual, the
//           dual residual and the complementarity gap are tested against thresholds derived from it through the strong-
//           convexity modulus min(a + d/gamma) (see box_ipm).  The best iterate is returned; the loop stops at the tolerance,
//           on stall, or at ipm_max_iter (rules on the iterates only: the map stays deterministic).  Returned: clip(theta).
//   ctrl = c(1, try_unbounded = 1, ipm_max_iter = 100, ipm_tol = 1e-8, trace = 0)
//
// method 0: TWO-BLOCK ADMM, splits v = D theta (penalty rho) and b = theta (box indicator, penalty zeta_i per coordinate):
//   A w = a (r - x) + rho D'(v - u - D x) + zeta (b - h - x),   A = diag(a) + M/gamma + rho D'D + diag(zeta),  theta = x + w,
//   v <- soft(D theta + u, lambda/rho), u <- u + D theta - v,  b <- clip(theta + h), h <- h + theta - b.  Returns b.
//   ctrl = c(0, alpha = 1, adapt_every = 0, mu = 10, tau = 2, log10_bound = 4): over-relaxation alpha and residual-balanced
//   rescaling of zeta.  Kept for comparison only: with the curvature metric (c/gamma ~ 1e8) the dual ascent of the box split
//   needs ~1e4 iterations whenever a bound is active (see the tests).  zeta = 0 and an infinite box reproduce the unbounded
//   kernel bitwise.
//
// Diagnostics with every solve: iters (ADMM iterations for method 0; IPM iterations for method 1, 0 if step 1 sufficed),
// outer (method 1: 0 = unbounded accepted, 1 = IPM ran), n_active (coordinates at a bound), rp_D / rp_B (method 0: the two
// primal residuals; method 1: ||r_primal||_inf and the pre-clip bound violation), rd (dual residual), gap (method 1:
// complementarity s'y), obj (objective at the returned point), max_viol (0 by construction), zeta_scale (method 0).
//
// pmala_box_move(): forward map T_B(theta), proposal theta* = T_B(theta) + sqrt(delta) L^{-T} xi (M = L L'), support check,
// reverse map T_B(theta*), and the two M-norms of the Hastings term.  RNG stays in R (xi supplied).  If theta* is outside
// [L, U] the target density is zero: the move is rejected and the reverse map is skipped.
//
// This file #includes the unbounded kernel (one translation unit), so one DLL exports both kernels.  Compile with
// -I<method/individual>.
#include "prox_admm_metric.cpp"

struct BoxDiag { int iters, outer, n_active, conv; double rp_D, rp_B, rd, gap, obj, max_viol, zscale; };
struct BoxCtrl { int method; double alpha; int adapt_every; double mu, tau, bound; bool try_unbounded; int ipm_max_iter; double ipm_tol; bool trace; };

static inline double clampd(double v, double lo, double hi) { return v < lo ? lo : (v > hi ? hi : v); }

static BoxCtrl read_ctrl(NumericVector ctrl) {
  BoxCtrl k; k.method = 1; k.alpha = 1.0; k.adapt_every = 0; k.mu = 10.0; k.tau = 2.0; k.bound = 4.0; k.try_unbounded = true; k.ipm_max_iter = 100; k.ipm_tol = 1e-8; k.trace = false;
  if (ctrl.size() >= 1) k.method = (int)ctrl[0];
  if (k.method == 0) {
    if (ctrl.size() >= 2) k.alpha = ctrl[1];
    if (ctrl.size() >= 3) k.adapt_every = (int)ctrl[2];
    if (ctrl.size() >= 4) k.mu = ctrl[3];
    if (ctrl.size() >= 5) k.tau = ctrl[4];
    if (ctrl.size() >= 6) k.bound = ctrl[5];
    if (!R_finite(k.alpha) || k.alpha <= 0 || k.alpha >= 2 || k.adapt_every < 0 || !(k.mu > 1) || !(k.tau > 1) || !(k.bound >= 0))
      stop("box prox: method 0 ctrl = c(0, alpha in (0,2), adapt_every >= 0, mu > 1, tau > 1, bound >= 0)");
  } else if (k.method == 1) {
    if (ctrl.size() >= 2) k.try_unbounded = ctrl[1] != 0;
    if (ctrl.size() >= 3) k.ipm_max_iter = (int)ctrl[2];
    if (ctrl.size() >= 4) k.ipm_tol = ctrl[3];
    if (ctrl.size() >= 5) k.trace = ctrl[4] != 0;
    if (k.ipm_max_iter < 1 || !R_finite(k.ipm_tol) || k.ipm_tol <= 0) stop("box prox: method 1 ctrl = c(1, try_unbounded, ipm_max_iter >= 1, ipm_tol > 0, trace)");
  } else stop("box prox: ctrl[1] (method) must be 0 or 1");
  return k;
}

static double box_objective_core(const std::vector<double>& b, const std::vector<double>& st, NumericVector a, NumericVector r,
                                 NumericVector d, double c, double gamma, double lambda, const std::vector<double>& x) {
  int n = (int)b.size(), m = n - ((int)st.size() - 1);
  std::vector<double> Db(m), w(n), Dw(m);
  apply_D(b, st, Db);
  for (int i = 0; i < n; ++i) w[i] = b[i] - x[i];
  apply_D(w, st, Dw);
  double f = 0;
  for (int i = 0; i < n; ++i) f += 0.5 * a[i] * (b[i] - r[i]) * (b[i] - r[i]) + 0.5 * d[i] * w[i] * w[i] / gamma;
  for (int j = 0; j < m; ++j) f += lambda * std::fabs(Db[j]) + 0.5 * c * Dw[j] * Dw[j] / gamma;
  return f;
}

static void check_box_inputs(int n, int p, NumericVector a, NumericVector r, NumericVector d, double c, double gamma, double lambda,
                             double rho, NumericVector zeta, NumericVector lower, NumericVector upper) {
  if (n - p < 1) stop("n too small for the difference order");
  if (a.size() != n || r.size() != n || d.size() != n || zeta.size() != n || lower.size() != n || upper.size() != n)
    stop("box prox: a, r, d, zeta, lower, upper must all have length n");
  if (!R_finite(lambda) || lambda < 0 || !R_finite(gamma) || gamma <= 0 || !R_finite(c) || c < 0 || !R_finite(rho) || rho <= 0)
    stop("box prox: need lambda >= 0, gamma > 0, c >= 0, rho > 0");
  for (int i = 0; i < n; ++i) {
    if (!R_finite(a[i]) || a[i] < 0 || !R_finite(r[i]) || !R_finite(d[i]) || d[i] <= 0 || !R_finite(zeta[i]) || zeta[i] < 0)
      stop("box prox: need finite a >= 0, r, d > 0, zeta >= 0");
    if (ISNAN(lower[i]) || ISNAN(upper[i]) || lower[i] > upper[i] || lower[i] == R_PosInf || upper[i] == R_NegInf)
      stop("box prox: need lower <= upper with lower < +Inf and upper > -Inf");
  }
}

// A0 = diag(a) + M/gamma + rho D'D (the unbounded ADMM system; identical to build_system() of the unbounded kernel, unfactored)
static void build_box_system0(int n, int p, const std::vector<double>& st, NumericVector a, NumericVector d, double c,
                              double gamma, double rho, Band& A0) {
  Band DtD = DtD_band(n, st);
  for (int q = 0; q <= p; ++q) for (int i = 0; i < n; ++i) A0.B[q][i] = (c / gamma + rho) * DtD.B[q][i];
  for (int i = 0; i < n; ++i) A0.B[0][i] += a[i] + d[i] / gamma;
}
static BoxDiag empty_diag() { BoxDiag g; g.iters = 0; g.outer = 0; g.n_active = 0; g.conv = NA_INTEGER; g.rp_D = g.rp_B = g.rd = g.gap = g.obj = g.max_viol = g.zscale = NA_REAL; return g; }
static int count_active(const std::vector<double>& b, NumericVector lower, NumericVector upper) {
  int k = 0; for (size_t i = 0; i < b.size(); ++i) if (b[i] == lower[i] || b[i] == upper[i]) ++k; return k;
}

// ====================================================================================================================
// method 1, step 2: primal-dual interior point (Mehrotra predictor-corrector) on the epigraph QP
// ====================================================================================================================
// D' diag(w) D as a band, added into A
static void add_DtWD(Band& A, const std::vector<double>& st, const std::vector<double>& w) {
  int p = (int)st.size() - 1, m = (int)w.size();
  for (int j = 0; j < m; ++j) for (int l = 0; l <= p; ++l) for (int l2 = l; l2 <= p; ++l2) A.B[l2 - l][j + l] += w[j] * st[l] * st[l2];
}
static void box_ipm(const std::vector<double>& st, NumericVector a, NumericVector r, NumericVector d, double c, double gamma, double lambda,
                    NumericVector lower, NumericVector upper, const std::vector<double>& x, int max_iter, double tol,
                    std::vector<double>& theta, BoxDiag& dg, const std::vector<double>* x0 = nullptr, bool trace = false) {
  int n = (int)x.size(), p = (int)st.size() - 1, m = n - p;
  // Q = diag(qd) + (c/gamma) D'D,  q = -(a r + (d x + c D'D x)/gamma)
  std::vector<double> qd(n), qv(n), Dx(m), DtDx(n);
  for (int i = 0; i < n; ++i) qd[i] = a[i] + d[i] / gamma;
  apply_D(x, st, Dx); apply_Dt(Dx, st, DtDx);
  for (int i = 0; i < n; ++i) qv[i] = -(a[i] * r[i] + (d[i] * x[i] + c * DtDx[i]) / gamma);
  std::vector<int> fx(n, 0), hasU(n, 0), hasL(n, 0);
  for (int i = 0; i < n; ++i) {
    if (lower[i] == upper[i]) fx[i] = 1;
    else { if (R_finite(upper[i])) hasU[i] = 1; if (R_finite(lower[i])) hasL[i] = 1; }
  }
  // state: theta (n), t (m), slacks/duals s1,y1,s2,y2 (m), s3,y3 (U rows), s4,y4 (L rows); unused rows carry s = y = 0 and are skipped
  theta.resize(n);
  for (int i = 0; i < n; ++i) theta[i] = fx[i] ? lower[i] : clampd(x0 ? (*x0)[i] : x[i], lower[i], upper[i]);   // start: clipped unbounded solution if given
  double thscale = 1.0; for (int i = 0; i < n; ++i) thscale = std::max(thscale, std::fabs(theta[i]));
  double smin = 1e-2 * thscale;
  std::vector<double> t(m), Dth(m), s1(m), y1(m, 0.5 * lambda + 1e-8), s2(m), y2(m, 0.5 * lambda + 1e-8), s3(n, 0.0), y3(n, 0.0), s4(n, 0.0), y4(n, 0.0);   // y1 = y2 = lambda/2: the t-block starts dual feasible
  apply_D(theta, st, Dth);
  for (int j = 0; j < m; ++j) { t[j] = std::fabs(Dth[j]) + smin; s1[j] = t[j] - Dth[j]; s2[j] = t[j] + Dth[j]; }
  for (int i = 0; i < n; ++i) { if (hasU[i]) { s3[i] = std::max(upper[i] - theta[i], smin); y3[i] = 1.0; } if (hasL[i]) { s4[i] = std::max(theta[i] - lower[i], smin); y4[i] = 1.0; } }
  int N = 2 * m; for (int i = 0; i < n; ++i) N += hasU[i] + hasL[i];
  // work
  std::vector<double> Qth(n), rdth(n), rdt(m), r1(m), r2(m), r3(n, 0.0), r4(n, 0.0), tmp(m), tmpn(n), rho1(m), rho2(m), rho3(n), rho4(n),
                      W1(m), W2(m), W3(n), W4(n), Wt(m), ct(m), rhs(n), dth(n), dt(m), dy1(m), dy2(m), dy3(n), dy4(n), ds1(m), ds2(m), ds3(n), ds4(n),
                      dth_a(n), dt_a(m), dy1a(m), dy2a(m), dy3a(n), dy4a(n), ds1a(m), ds2a(m), ds3a(n), ds4a(n), Ddth(m), rc1(m), rc2(m), rc3(n), rc4(n);
  double qn = 1.0; for (int i = 0; i < n; ++i) qn = std::max(qn, std::fabs(qv[i]));
  auto residuals = [&](double& rp_inf, double& rd_inf, double& mu, double& pobj) {
    apply_D(theta, st, Dth); apply_Dt(Dth, st, tmpn);                     // tmpn = D'D theta
    for (int i = 0; i < n; ++i) Qth[i] = qd[i] * theta[i] + (c / gamma) * tmpn[i];
    for (int j = 0; j < m; ++j) tmp[j] = y1[j] - y2[j];
    apply_Dt(tmp, st, tmpn);
    rp_inf = 0; rd_inf = 0; double sy = 0; pobj = 0;
    for (int i = 0; i < n; ++i) {
      rdth[i] = fx[i] ? 0.0 : Qth[i] + qv[i] + tmpn[i] + y3[i] - y4[i];
      rd_inf = std::max(rd_inf, std::fabs(rdth[i]));
      r3[i] = hasU[i] ? theta[i] - upper[i] + s3[i] : 0.0; r4[i] = hasL[i] ? lower[i] - theta[i] + s4[i] : 0.0;
      rp_inf = std::max(rp_inf, std::max(std::fabs(r3[i]), std::fabs(r4[i])));
      sy += s3[i] * y3[i] + s4[i] * y4[i];
      pobj += 0.5 * Qth[i] * theta[i] + qv[i] * theta[i];
    }
    for (int j = 0; j < m; ++j) {
      rdt[j] = lambda - y1[j] - y2[j]; rd_inf = std::max(rd_inf, std::fabs(rdt[j]));
      r1[j] = Dth[j] - t[j] + s1[j]; r2[j] = -Dth[j] - t[j] + s2[j];
      rp_inf = std::max(rp_inf, std::max(std::fabs(r1[j]), std::fabs(r2[j])));
      sy += s1[j] * y1[j] + s2[j] * y2[j]; pobj += lambda * t[j];
    }
    mu = sy / N;
  };
  // Newton solve for given complementarity right-hand sides rc_k (S dy + Y ds = rc)
  auto newton = [&](const std::vector<double>& c1, const std::vector<double>& c2, const std::vector<double>& c3, const std::vector<double>& c4,
                    std::vector<double>& o_dth, std::vector<double>& o_dt, std::vector<double>& o_dy1, std::vector<double>& o_dy2,
                    std::vector<double>& o_dy3, std::vector<double>& o_dy4, std::vector<double>& o_ds1, std::vector<double>& o_ds2,
                    std::vector<double>& o_ds3, std::vector<double>& o_ds4) {
    for (int j = 0; j < m; ++j) {
      W1[j] = y1[j] / s1[j]; W2[j] = y2[j] / s2[j];
      rho1[j] = r1[j] + c1[j] / y1[j]; rho2[j] = r2[j] + c2[j] / y2[j];
      Wt[j] = 4.0 * W1[j] * W2[j] / (W1[j] + W2[j]);
      ct[j] = W1[j] * rho1[j] - W2[j] * rho2[j] - (W1[j] - W2[j]) * (W1[j] * rho1[j] + W2[j] * rho2[j] - rdt[j]) / (W1[j] + W2[j]);
    }
    apply_Dt(ct, st, tmpn);
    Band A(n, p);
    for (int q = 0; q <= p; ++q) std::fill(A.B[q].begin(), A.B[q].end(), 0.0);
    { Band DtD = DtD_band(n, st); for (int q = 0; q <= p; ++q) for (int i = 0; i < n; ++i) A.B[q][i] = (c / gamma) * DtD.B[q][i]; }
    add_DtWD(A, st, Wt);
    for (int i = 0; i < n; ++i) {
      W3[i] = hasU[i] ? y3[i] / s3[i] : 0.0; W4[i] = hasL[i] ? y4[i] / s4[i] : 0.0;
      rho3[i] = hasU[i] ? r3[i] + c3[i] / y3[i] : 0.0; rho4[i] = hasL[i] ? r4[i] + c4[i] / y4[i] : 0.0;
      A.B[0][i] += qd[i] + W3[i] + W4[i];
      rhs[i] = -rdth[i] - tmpn[i] - W3[i] * rho3[i] + W4[i] * rho4[i];
    }
    for (int i = 0; i < n; ++i) if (fx[i]) {                                  // eliminated coordinate: d theta_i = 0
      for (int q = 1; q <= p; ++q) { if (i + q < n) A.B[q][i] = 0.0; if (i - q >= 0) A.B[q][i - q] = 0.0; }
      A.B[0][i] = 1.0; rhs[i] = 0.0;
    }
    band_chol_ridge(A, "IPM Newton system");
    band_solve(A, rhs);
    for (int i = 0; i < n; ++i) o_dth[i] = fx[i] ? 0.0 : rhs[i];
    apply_D(o_dth, st, Ddth);
    for (int j = 0; j < m; ++j) {
      o_dt[j] = ((W1[j] - W2[j]) * Ddth[j] + W1[j] * rho1[j] + W2[j] * rho2[j] - rdt[j]) / (W1[j] + W2[j]);
      o_dy1[j] = W1[j] * (Ddth[j] - o_dt[j] + rho1[j]); o_dy2[j] = W2[j] * (-Ddth[j] - o_dt[j] + rho2[j]);
      o_ds1[j] = (c1[j] - s1[j] * o_dy1[j]) / y1[j]; o_ds2[j] = (c2[j] - s2[j] * o_dy2[j]) / y2[j];
    }
    for (int i = 0; i < n; ++i) {
      o_dy3[i] = hasU[i] ? W3[i] * (o_dth[i] + rho3[i]) : 0.0; o_dy4[i] = hasL[i] ? W4[i] * (-o_dth[i] + rho4[i]) : 0.0;
      o_ds3[i] = hasU[i] ? (c3[i] - s3[i] * o_dy3[i]) / y3[i] : 0.0; o_ds4[i] = hasL[i] ? (c4[i] - s4[i] * o_dy4[i]) / y4[i] : 0.0;
    }
  };
  auto maxstep = [&](const std::vector<double>& s, const std::vector<double>& ds, const std::vector<int>* mask) {
    double al = 1.0;
    for (size_t i = 0; i < s.size(); ++i) { if (mask && !(*mask)[i]) continue; if (ds[i] < 0) al = std::min(al, -s[i] / ds[i]); }
    return al; };
  auto step_p = [&](const std::vector<double>& a1, const std::vector<double>& a2, const std::vector<double>& a3, const std::vector<double>& a4) {
    return std::min(std::min(maxstep(s1, a1, nullptr), maxstep(s2, a2, nullptr)), std::min(maxstep(s3, a3, &hasU), maxstep(s4, a4, &hasL))); };
  auto step_d = [&](const std::vector<double>& a1, const std::vector<double>& a2, const std::vector<double>& a3, const std::vector<double>& a4) {
    return std::min(std::min(maxstep(y1, a1, nullptr), maxstep(y2, a2, nullptr)), std::min(maxstep(y3, a3, &hasU), maxstep(y4, a4, &hasL))); };
  // Stopping rule in THETA units.  tol is the wanted accuracy of theta: with lam_min(Q) >= qmin = min(a + d/gamma),
  //   ||theta - theta*|| <= ||r_dual|| / qmin  and  ||theta - theta*||^2 <= 2 gap / qmin,
  // so the thresholds are  rp <= tol (1 + thscale),  rd <= tol qmin,  gap = s'y <= tol^2 qmin / 2.  (A criterion relative to
  // ||q|| would be meaningless here: Q theta and q are ~1e9 and cancel.)  phi = the largest ratio to its threshold; the BEST
  // iterate is returned (an IPM pushed past its numerical floor can diverge) and the loop stops at phi <= 1, on stall (no 10%
  // improvement of phi for 10 iterations after the first 15), on non-finite values, or at max_iter.
  double qmin = R_PosInf; for (int i = 0; i < n; ++i) if (!fx[i]) qmin = std::min(qmin, qd[i]);
  if (!R_finite(qmin)) qmin = 1.0;
  // On stiff instances the dual threshold is below the rounding floor of the 1e9-scale gradient, so the loop usually ends on the
  // stall rule at its numerical floor (converged = 0 then); the returned best iterate is still accurate to ~1e-10 (tests P4/P6).
  const double tol_rp = tol * (1.0 + thscale), tol_rd = tol * qmin, tol_gap = 0.5 * tol * tol * qmin;
  double rp_inf = 0, rd_inf = 0, mu = 0, pobj = 0; int it = 0, since_best = 0;
  double phi_best = R_PosInf, rp_best = NA_REAL, rd_best = NA_REAL, gap_best = NA_REAL; std::vector<double> th_best(theta);
  for (it = 0; it < max_iter; ++it) {
    residuals(rp_inf, rd_inf, mu, pobj);
    double phi = std::max(std::max(rp_inf / tol_rp, rd_inf / tol_rd), mu * N / tol_gap);
    if (trace) Rprintf("  ipm %3d: rp %.2e rd %.2e gap %.2e pobj %.8g phi %.2e\n", it, rp_inf, rd_inf, mu * N, pobj, phi);
    if (!R_finite(phi)) break;
    // the starting point is excluded from best-tracking (its small primal residual is not a sign of optimality: the first
    // iterations trade it for the dual residual); it remains the fallback only if the first step is already non-finite
    if (it >= 1 && phi < phi_best) { if (phi < 0.9 * phi_best) since_best = 0; else ++since_best; phi_best = phi; th_best = theta; rp_best = rp_inf; rd_best = rd_inf; gap_best = mu * N; }
    else if (it >= 1) ++since_best;
    else { rp_best = rp_inf; rd_best = rd_inf; gap_best = mu * N; }
    if (phi_best <= 1.0 || (it >= 15 && since_best >= 10)) break;
    // predictor (affine scaling)
    for (int j = 0; j < m; ++j) { rc1[j] = -s1[j] * y1[j]; rc2[j] = -s2[j] * y2[j]; }
    for (int i = 0; i < n; ++i) { rc3[i] = -s3[i] * y3[i]; rc4[i] = -s4[i] * y4[i]; }
    newton(rc1, rc2, rc3, rc4, dth_a, dt_a, dy1a, dy2a, dy3a, dy4a, ds1a, ds2a, ds3a, ds4a);
    double ap = step_p(ds1a, ds2a, ds3a, ds4a), ad = step_d(dy1a, dy2a, dy3a, dy4a);
    double mu_aff = 0;
    for (int j = 0; j < m; ++j) mu_aff += (s1[j] + ap * ds1a[j]) * (y1[j] + ad * dy1a[j]) + (s2[j] + ap * ds2a[j]) * (y2[j] + ad * dy2a[j]);
    for (int i = 0; i < n; ++i) { if (hasU[i]) mu_aff += (s3[i] + ap * ds3a[i]) * (y3[i] + ad * dy3a[i]); if (hasL[i]) mu_aff += (s4[i] + ap * ds4a[i]) * (y4[i] + ad * dy4a[i]); }
    mu_aff /= N;
    double sig = std::pow(std::max(mu_aff, 0.0) / mu, 3.0); if (sig > 1.0) sig = 1.0;
    // corrector
    for (int j = 0; j < m; ++j) { rc1[j] = -s1[j] * y1[j] - ds1a[j] * dy1a[j] + sig * mu; rc2[j] = -s2[j] * y2[j] - ds2a[j] * dy2a[j] + sig * mu; }
    for (int i = 0; i < n; ++i) { rc3[i] = hasU[i] ? -s3[i] * y3[i] - ds3a[i] * dy3a[i] + sig * mu : 0.0; rc4[i] = hasL[i] ? -s4[i] * y4[i] - ds4a[i] * dy4a[i] + sig * mu : 0.0; }
    newton(rc1, rc2, rc3, rc4, dth, dt, dy1, dy2, dy3, dy4, ds1, ds2, ds3, ds4);
    ap = std::min(1.0, 0.99 * step_p(ds1, ds2, ds3, ds4)); ad = std::min(1.0, 0.99 * step_d(dy1, dy2, dy3, dy4));
    for (int i = 0; i < n; ++i) { theta[i] += ap * dth[i]; if (hasU[i]) { s3[i] += ap * ds3[i]; y3[i] += ad * dy3[i]; } if (hasL[i]) { s4[i] += ap * ds4[i]; y4[i] += ad * dy4[i]; } }
    for (int j = 0; j < m; ++j) { t[j] += ap * dt[j]; s1[j] += ap * ds1[j]; s2[j] += ap * ds2[j]; y1[j] += ad * dy1[j]; y2[j] += ad * dy2[j]; }
  }
  theta = th_best;
  dg.iters = it; dg.rp_D = rp_best; dg.rd = rd_best; dg.gap = gap_best; dg.conv = (phi_best <= 1.0) ? 1 : 0;
  double mv = 0; for (int i = 0; i < n; ++i) mv = std::max(mv, std::max(lower[i] - theta[i], theta[i] - upper[i]));
  dg.rp_B = std::max(0.0, mv);
}

// method 1 driver: unbounded ADMM, accept if feasible, else IPM
static void box_method1(const Band& A0, const std::vector<double>& st, NumericVector a, NumericVector r, NumericVector d, double c, double gamma,
                        double lambda, double rho, const BoxCtrl& K, NumericVector lower, NumericVector upper, const std::vector<double>& x,
                        int max_iter, double tol, std::vector<double>& b, BoxDiag& dg) {
  int n = (int)x.size(), m = n - ((int)st.size() - 1);
  dg = empty_diag(); dg.zscale = NA_REAL;
  std::vector<double> bu; const std::vector<double>* start = nullptr;
  if (K.try_unbounded) {
    std::vector<double> Dx(m), bvec(n); bu.resize(n); start = &bu;
    for (int i = 0; i < n; ++i) bvec[i] = a[i] * (r[i] - x[i]);                 // increment-form rhs (as build_rhs() of the unbounded kernel)
    apply_D(x, st, Dx);
    Band A = A0; band_chol_ridge(A, "ADMM system");
    int its = admm_core(A, st, bvec, x, Dx, lambda, rho, max_iter, tol, bu);
    bool feas = true;
    for (int i = 0; i < n; ++i) if (bu[i] < lower[i] || bu[i] > upper[i]) { feas = false; break; }
    if (feas) {
      b = bu; dg.iters = its; dg.outer = 0; dg.conv = 1; dg.rp_D = 0; dg.rp_B = 0; dg.rd = NA_REAL; dg.gap = NA_REAL;
      dg.n_active = count_active(b, lower, upper); dg.max_viol = 0; dg.obj = box_objective_core(b, st, a, r, d, c, gamma, lambda, x);
      return;
    }
  }
  std::vector<double> th;
  box_ipm(st, a, r, d, c, gamma, lambda, lower, upper, x, K.ipm_max_iter, K.ipm_tol, th, dg, start, K.trace);
  dg.outer = 1; b.resize(n);
  for (int i = 0; i < n; ++i) b[i] = clampd(th[i], lower[i], upper[i]);
  dg.n_active = count_active(b, lower, upper); dg.max_viol = 0; dg.obj = box_objective_core(b, st, a, r, d, c, gamma, lambda, x);
}

// ====================================================================================================================
// method 0: two-block ADMM (box split with penalty zeta)
// ====================================================================================================================
static void factor_box_system(const Band& A0, NumericVector zeta, double s, Band& A) {
  A = A0;
  for (int i = 0; i < A.n; ++i) A.B[0][i] += s * zeta[i];
  band_chol_ridge(A, "box ADMM system");
}
static void box_admm_core(const Band& A0, const std::vector<double>& st, NumericVector a, NumericVector r, NumericVector d, double c,
                          double gamma, double lambda, double rho, NumericVector zeta, const BoxCtrl& K,
                          NumericVector lower, NumericVector upper, const std::vector<double>& x, int max_iter, double tol,
                          std::vector<double>& b, BoxDiag& dg) {
  int n = (int)x.size(), m = n - ((int)st.size() - 1);
  std::vector<double> v(m), u(m, 0.0), h(n, 0.0), theta(x), Dx(m), tmp(m), rhs(n), Dw(m), Dth(m), vold(m), bold(n), dv(n);
  apply_D(x, st, Dx); v = Dx; b.resize(n);
  for (int i = 0; i < n; ++i) b[i] = clampd(x[i], lower[i], upper[i]);
  double thr = lambda / rho, bn = 0;
  for (int i = 0; i < n; ++i) { double tt = a[i] * (r[i] - x[i]); bn += tt * tt; }
  bn = std::sqrt(bn);
  double zscale = 1.0; Band A(A0.n, A0.p); factor_box_system(A0, zeta, zscale, A);
  const double zmin = std::pow(10.0, -K.bound), zmax = std::pow(10.0, K.bound), al = K.alpha;
  dg = empty_diag(); dg.rp_D = dg.rp_B = dg.rd = 0; int it = 0;
  for (it = 0; it < max_iter; ++it) {
    for (int j = 0; j < m; ++j) tmp[j] = v[j] - u[j] - Dx[j];
    apply_Dt(tmp, st, rhs);
    for (int i = 0; i < n; ++i) rhs[i] = a[i] * (r[i] - x[i]) + rho * rhs[i] + zscale * zeta[i] * (b[i] - h[i] - x[i]);
    band_solve(A, rhs);
    for (int i = 0; i < n; ++i) theta[i] = x[i] + rhs[i];
    apply_D(rhs, st, Dw);
    for (int j = 0; j < m; ++j) Dth[j] = Dx[j] + Dw[j];
    vold = v; bold = b;
    double rpD = 0, rpB = 0, tn = 0, bnrm = 0;
    for (int j = 0; j < m; ++j) {
      double Dh = (al == 1.0) ? Dth[j] : al * Dth[j] + (1.0 - al) * vold[j];
      double q = Dh + u[j];
      v[j] = (q > thr) ? q - thr : (q < -thr ? q + thr : 0.0);
      u[j] = q - v[j];
      rpD += (Dth[j] - v[j]) * (Dth[j] - v[j]); tn += Dth[j] * Dth[j];
    }
    for (int i = 0; i < n; ++i) {
      double th = (al == 1.0) ? theta[i] : al * theta[i] + (1.0 - al) * bold[i];
      double q = th + h[i];
      b[i] = clampd(q, lower[i], upper[i]);
      h[i] = q - b[i];
      rpB += (theta[i] - b[i]) * (theta[i] - b[i]); tn += theta[i] * theta[i]; bnrm += b[i] * b[i];
    }
    for (int j = 0; j < m; ++j) tmp[j] = v[j] - vold[j];
    apply_Dt(tmp, st, dv);
    double rd = 0, sB = 0, hn = 0;
    for (int i = 0; i < n; ++i) {
      double zb = zscale * zeta[i] * (b[i] - bold[i]); double s = rho * dv[i] + zb; rd += s * s; sB += zb * zb;
      double mu_i = zscale * zeta[i] * h[i]; hn += mu_i * mu_i;
    }
    dg.rp_D = std::sqrt(rpD); dg.rp_B = std::sqrt(rpB); dg.rd = std::sqrt(rd);
    if (tol > 0 && std::sqrt(rpD + rpB) <= tol * (std::sqrt(tn) + 1e-12) && dg.rd <= tol * (bn + 1e-12)) { ++it; break; }
    if (K.adapt_every > 0 && (it + 1) % K.adapt_every == 0 && it + 1 < max_iter) {
      double rrel = dg.rp_B / std::max(std::sqrt(bnrm), 1e-300), srel = std::sqrt(sB) / (std::sqrt(hn) + 1e-300), f = 1.0;
      if (rrel > K.mu * srel) f = K.tau; else if (srel > K.mu * rrel) f = 1.0 / K.tau;
      if (f != 1.0) {
        double zs = std::min(std::max(zscale * f, zmin), zmax); f = zs / zscale;
        if (f != 1.0) { zscale = zs; for (int i = 0; i < n; ++i) h[i] /= f; factor_box_system(A0, zeta, zscale, A); }
      }
    }
  }
  dg.iters = it; dg.outer = 1; dg.zscale = zscale; dg.gap = NA_REAL;
  dg.n_active = count_active(b, lower, upper); dg.max_viol = 0;
  dg.obj = box_objective_core(b, st, a, r, d, c, gamma, lambda, x);
}

static List diag_list(const BoxDiag& dg) {
  return List::create(_["iters"] = dg.iters, _["outer"] = dg.outer, _["n_active"] = dg.n_active, _["converged"] = dg.conv, _["rp_D"] = dg.rp_D,
                      _["rp_B"] = dg.rp_B, _["rd"] = dg.rd, _["gap"] = dg.gap, _["obj"] = dg.obj, _["max_viol"] = dg.max_viol, _["zeta_scale"] = dg.zscale);
}
// dispatcher: one bounded prox on the base ADMM system A0
static void box_solve(const Band& A0, const std::vector<double>& st, NumericVector a, NumericVector r, NumericVector d, double c, double gamma,
                      double lambda, double rho, NumericVector zeta, const BoxCtrl& K, NumericVector lower, NumericVector upper,
                      const std::vector<double>& x, int max_iter, double tol, std::vector<double>& b, BoxDiag& dg) {
  if (K.method == 1) box_method1(A0, st, a, r, d, c, gamma, lambda, rho, K, lower, upper, x, max_iter, tol, b, dg);
  else box_admm_core(A0, st, a, r, d, c, gamma, lambda, rho, zeta, K, lower, upper, x, max_iter, tol, b, dg);
}

// [[Rcpp::export]]
List prox_box_metric(NumericVector x, NumericVector a, NumericVector r, double lambda, double gamma,
                     NumericVector d, double c, int k, double rho, NumericVector zeta, int max_iter, double tol,
                     NumericVector lower, NumericVector upper, NumericVector ctrl) {
  int n = x.size(), p = k + 1;
  check_box_inputs(n, p, a, r, d, c, gamma, lambda, rho, zeta, lower, upper);
  BoxCtrl K = read_ctrl(ctrl);
  if (max_iter < 1) stop("box prox: max_iter >= 1");
  for (int i = 0; i < n; ++i) if (!R_finite(x[i])) stop("box prox: x must be finite");
  std::vector<double> st = diff_stencil(p), xv(x.begin(), x.end()), b;
  Band A0(n, p); build_box_system0(n, p, st, a, d, c, gamma, rho, A0);
  BoxDiag dg;
  box_solve(A0, st, a, r, d, c, gamma, lambda, rho, zeta, K, lower, upper, xv, max_iter, tol, b, dg);
  return List::create(_["theta"] = NumericVector(b.begin(), b.end()), _["diag"] = diag_list(dg));
}

// objective of the bounded problem at an arbitrary point (for tests; +Inf outside the box)
// [[Rcpp::export]]
double box_objective(NumericVector theta, NumericVector x, NumericVector a, NumericVector r, double lambda, double gamma,
                     NumericVector d, double c, int k, NumericVector lower, NumericVector upper) {
  int n = theta.size(), p = k + 1;
  std::vector<double> st = diff_stencil(p), t(theta.begin(), theta.end()), xv(x.begin(), x.end());
  for (int i = 0; i < n; ++i) if (t[i] < lower[i] || t[i] > upper[i]) return R_PosInf;
  return box_objective_core(t, st, a, r, d, c, gamma, lambda, xv);
}

// [[Rcpp::export]]
List pmala_box_move(NumericVector theta, NumericVector a, NumericVector r, double lambda, double gamma,
                    NumericVector d, double c, int k, double rho, NumericVector zeta, int max_iter, double tol,
                    NumericVector xi, double delta, NumericVector lower, NumericVector upper, NumericVector ctrl) {
  int n = theta.size(), p = k + 1, m = n - p;
  check_box_inputs(n, p, a, r, d, c, gamma, lambda, rho, zeta, lower, upper);
  BoxCtrl K = read_ctrl(ctrl);
  if (max_iter < 1 || xi.size() != n || !R_finite(delta) || delta <= 0) stop("box move: bad max_iter, xi or delta");
  for (int i = 0; i < n; ++i) if (!R_finite(theta[i])) stop("box move: theta must be finite");
  std::vector<double> st = diff_stencil(p);
  Band A0(n, p); build_box_system0(n, p, st, a, d, c, gamma, rho, A0);                // one base system for both maps
  std::vector<double> th(theta.begin(), theta.end()), pf, pr, prop(n);
  BoxDiag dgf, dgr = empty_diag();
  box_solve(A0, st, a, r, d, c, gamma, lambda, rho, zeta, K, lower, upper, th, max_iter, tol, pf, dgf);          // T_B(theta)
  Band M = DtD_band(n, st);                                                            // metric P = diag(d) + c D'D
  for (int q = 0; q <= p; ++q) for (int i = 0; i < n; ++i) M.B[q][i] *= c;
  for (int i = 0; i < n; ++i) M.B[0][i] += d[i];
  std::vector<double> z(xi.begin(), xi.end());
  { Band Mc = M; band_chol(Mc, "metric P"); band_solve_Lt(Mc, z); }                  // z = L^{-T} xi ~ N(0, P^{-1})
  double sq = std::sqrt(delta);
  bool outside = false;
  for (int i = 0; i < n; ++i) { prop[i] = pf[i] + sq * z[i]; if (prop[i] < lower[i] || prop[i] > upper[i]) outside = true; }
  auto pnorm2 = [&](const std::vector<double>& v) {
    std::vector<double> Dv(m); apply_D(v, st, Dv); double s1 = 0, s2 = 0;
    for (int i = 0; i < n; ++i) s1 += d[i] * v[i] * v[i];
    for (int j = 0; j < m; ++j) s2 += Dv[j] * Dv[j];
    return s1 + c * s2; };
  std::vector<double> v1(n);
  for (int i = 0; i < n; ++i) v1[i] = prop[i] - pf[i];
  double q_fwd = pnorm2(v1), q_rev = NA_REAL;
  NumericVector pstar(n, NA_REAL);
  if (!outside) {
    box_solve(A0, st, a, r, d, c, gamma, lambda, rho, zeta, K, lower, upper, prop, max_iter, tol, pr, dgr);       // T_B(theta*)
    std::vector<double> v2(n);
    for (int i = 0; i < n; ++i) v2[i] = th[i] - pr[i];
    q_rev = pnorm2(v2);
    pstar = NumericVector(pr.begin(), pr.end());
  }
  return List::create(_["prop"] = NumericVector(prop.begin(), prop.end()), _["p"] = NumericVector(pf.begin(), pf.end()),
                      _["pstar"] = pstar, _["q_fwd"] = q_fwd, _["q_rev"] = q_rev, _["outside"] = outside,
                      _["diag_fwd"] = diag_list(dgf), _["diag_rev"] = diag_list(dgr));
}

// ---- plain .Call entry points (manual g++ build without Rtools) ----
extern "C" SEXP C_prox_box_metric(SEXP x, SEXP a, SEXP r, SEXP lambda, SEXP gamma, SEXP d, SEXP c, SEXP k, SEXP rho, SEXP zeta,
                                  SEXP max_iter, SEXP tol, SEXP lower, SEXP upper, SEXP ctrl) {
  BEGIN_RCPP
  return wrap(prox_box_metric(as<NumericVector>(x), as<NumericVector>(a), as<NumericVector>(r), as<double>(lambda), as<double>(gamma),
                              as<NumericVector>(d), as<double>(c), as<int>(k), as<double>(rho), as<NumericVector>(zeta),
                              as<int>(max_iter), as<double>(tol), as<NumericVector>(lower), as<NumericVector>(upper), as<NumericVector>(ctrl)));
  END_RCPP
}
extern "C" SEXP C_box_objective(SEXP theta, SEXP x, SEXP a, SEXP r, SEXP lambda, SEXP gamma, SEXP d, SEXP c, SEXP k, SEXP lower, SEXP upper) {
  BEGIN_RCPP
  return wrap(box_objective(as<NumericVector>(theta), as<NumericVector>(x), as<NumericVector>(a), as<NumericVector>(r), as<double>(lambda),
                            as<double>(gamma), as<NumericVector>(d), as<double>(c), as<int>(k), as<NumericVector>(lower), as<NumericVector>(upper)));
  END_RCPP
}
extern "C" SEXP C_pmala_box_move(SEXP theta, SEXP a, SEXP r, SEXP lambda, SEXP gamma, SEXP d, SEXP c, SEXP k, SEXP rho, SEXP zeta,
                                 SEXP max_iter, SEXP tol, SEXP xi, SEXP delta, SEXP lower, SEXP upper, SEXP ctrl) {
  BEGIN_RCPP
  return wrap(pmala_box_move(as<NumericVector>(theta), as<NumericVector>(a), as<NumericVector>(r), as<double>(lambda), as<double>(gamma),
                             as<NumericVector>(d), as<double>(c), as<int>(k), as<double>(rho), as<NumericVector>(zeta),
                             as<int>(max_iter), as<double>(tol), as<NumericVector>(xi), as<double>(delta),
                             as<NumericVector>(lower), as<NumericVector>(upper), as<NumericVector>(ctrl)));
  END_RCPP
}
