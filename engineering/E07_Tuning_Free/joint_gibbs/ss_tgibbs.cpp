// E-07 joint v2: exact single-site truncated Gibbs sweep for theta ~ N(Q^{-1} b, Q^{-1}) restricted to [lo, up] (componentwise),
// Q = diag(w) + D' diag(iw) D with D the third-difference operator (bandwidth 3), b = w * r.
// theta_i | theta_{-i} ~ N(m_i, 1 / Q_ii) truncated to [lo_i, up_i], m_i = (b_i - sum_{k != i} Q_ik theta_k) / Q_ii.  Always accepted.
#include <Rcpp.h>
#include <cmath>
using namespace Rcpp;

// standard normal truncated to [a, b] (a < b, may be infinite); every branch exact (rejection), no CDF inversion in the tails.
static double rtn_std(double a, double b) {
  bool flip = false;
  if (b <= 0.0) { double t = -a; a = -b; b = t; flip = true; }            // now b > 0
  double x;
  if (a <= 0.0) {                                                         // interval contains 0 (or starts at it)
    if (b - a < 2.5) {                                                    // narrow: uniform proposal, accept exp(-x^2/2)
      for (;;) { x = a + (b - a) * unif_rand(); if (unif_rand() <= std::exp(-0.5 * x * x)) break; }
    } else {                                                              // mass >= 0.49: plain normal rejection
      for (;;) { x = norm_rand(); if (x >= a && x <= b) break; }
    }
  } else {                                                                // a > 0: right tail
    double al = 0.5 * (a + std::sqrt(a * a + 4.0));                       // optimal exponential rate (Robert 1995)
    if (al * (b - a) >= 2.0 || !std::isfinite(b)) {                       // exponential proposal a + Exp(al), accept exp(-(x - al)^2 / 2)
      for (;;) { x = a + exp_rand() / al; if (x > b) continue; if (unif_rand() <= std::exp(-0.5 * (x - al) * (x - al))) break; }
    } else {                                                              // uniform proposal, accept exp((a^2 - x^2) / 2)
      for (;;) { x = a + (b - a) * unif_rand(); if (unif_rand() <= std::exp(0.5 * (a * a - x * x))) break; }
    }
  }
  return flip ? -x : x;
}

// [[Rcpp::export]]
NumericVector rtnorm_std(int n, double a, double b) { NumericVector o(n); for (int i = 0; i < n; ++i) o[i] = rtn_std(a, b); return o; }

// [[Rcpp::export]]
NumericVector ss_tgibbs(NumericVector theta, NumericVector w, NumericVector r, NumericVector iw, NumericVector lo, NumericVector up,
                        int sweeps = 1, bool symmetric = false) {
  const int n = theta.size(), m = n - 3;
  if (w.size() != n || r.size() != n || iw.size() != m || lo.size() != n || up.size() != n) stop("ss_tgibbs: size mismatch");
  const double c[4] = {-1.0, 3.0, -3.0, 1.0};
  std::vector<double> q(4 * n, 0.0);                                      // q[4 i + d] = Q_{i, i+d}
  for (int i = 0; i < n; ++i) q[4 * i] = w[i];
  for (int j = 0; j < m; ++j) for (int a = 0; a < 4; ++a) for (int b = a; b < 4; ++b) q[4 * (j + a) + (b - a)] += iw[j] * c[a] * c[b];
  NumericVector th = clone(theta);
  auto upd = [&](int i) {
    double s = w[i] * r[i];
    for (int d = 1; d <= 3; ++d) { if (i + d < n) s -= q[4 * i + d] * th[i + d]; if (i - d >= 0) s -= q[4 * (i - d) + d] * th[i - d]; }
    const double qii = q[4 * i], sd = 1.0 / std::sqrt(qii), mu = s / qii;
    double a = (lo[i] - mu) / sd, b = (up[i] - mu) / sd, x;
    if (!(a < b)) x = 0.5 * (lo[i] + up[i]);                              // degenerate box: stay on it
    else x = mu + sd * rtn_std(a, b);
    th[i] = std::min(std::max(x, lo[i]), up[i]);
  };
  for (int s = 0; s < sweeps; ++s) {
    for (int i = 0; i < n; ++i) upd(i);
    if (symmetric) for (int i = n - 1; i >= 0; --i) upd(i);
  }
  return th;
}
