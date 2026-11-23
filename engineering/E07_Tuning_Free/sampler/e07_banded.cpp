// E-07 copy of engineering/E02_Rate_Sims/banded_ls.cpp (k = 2, third differences) plus banded_solve_logdet.
// E-02: exact Gaussian draw  theta ~ N(Q^{-1} W r, Q^{-1}),  Q = diag(w) + D' diag(iw) D,  D = third differences,
// by perturb-and-solve:  theta = argmin || W^{1/2}(theta - r) - xi1 ||^2 + || diag(iw)^{1/2} D theta - xi2 ||^2,
// xi1 ~ N(0, I_n), xi2 ~ N(0, I_m).  The normal equations are Q theta = W r + W^{1/2} xi1 + D' diag(iw)^{1/2} xi2, so theta has
// mean Q^{-1} W r and covariance Q^{-1} (W + D' diag(iw) D) Q^{-1} = Q^{-1}: exact.
// Solved by sequential Givens QR of the banded (n + m) x n stacked matrix (Lawson-Hanson row accumulation), O(n), never forming Q.
// Backward stable in the stacked matrix, whose condition number is ~ sqrt(cond(Q)): this is what makes lambda up to ~1e9 feasible,
// where a Cholesky of Q (cond ~ 64 lambda^2 / min w) fails.
#include <Rcpp.h>
#include <cmath>
using namespace Rcpp;

// R stored as R[k*4 + t] = R(k, k+t), t = 0..3 (upper band, bandwidth 3).
static inline void rotate_in(std::vector<double>& R, std::vector<double>& d, int n, int s, double* xv, double xr) {
  // xv[0..3] = row entries at columns s..s+3 (entries beyond n-1 are 0); xr = its right-hand side
  for (int k = s; k < n; ++k) {
    if (k > s + 3) break;
    double b = xv[0];
    if (b != 0.0) {
      double a = R[4 * k];
      double rr = std::hypot(a, b), c = a / rr, sn = b / rr;
      for (int t = 0; t < 4; ++t) {
        double Rt = R[4 * k + t], xt = xv[t];
        R[4 * k + t] = c * Rt + sn * xt;
        xv[t] = -sn * Rt + c * xt;
      }
      double dk = d[k];
      d[k] = c * dk + sn * xr;
      xr = -sn * dk + c * xr;
    }
    xv[0] = xv[1]; xv[1] = xv[2]; xv[2] = xv[3]; xv[3] = 0.0;   // shift: entries now relative to column k+1
  }
}

// [[Rcpp::export]]
NumericVector banded_gauss_draw(NumericVector w, NumericVector r, NumericVector iw, NumericVector xi1, NumericVector xi2) {
  const int n = w.size(), m = n - 3;
  if (iw.size() != m || r.size() != n || xi1.size() != n || xi2.size() != m) stop("banded_gauss_draw: size mismatch");
  std::vector<double> R(4 * n, 0.0), d(n, 0.0);
  const double st[4] = {-1.0, 3.0, -3.0, 1.0};
  double xv[4];
  for (int j = 0; j < n; ++j) {
    // data row j: sqrt(w_j) theta_j = sqrt(w_j) r_j + xi1_j
    double sw = std::sqrt(w[j]);
    xv[0] = sw; xv[1] = xv[2] = xv[3] = 0.0;
    rotate_in(R, d, n, j, xv, sw * r[j] + xi1[j]);
    // difference row j: sqrt(iw_j) (D theta)_j = xi2_j   (columns j..j+3)
    if (j < m) {
      double s = std::sqrt(iw[j]);
      for (int t = 0; t < 4; ++t) xv[t] = s * st[t];
      rotate_in(R, d, n, j, xv, xi2[j]);
    }
  }
  NumericVector th(n);
  for (int k = n - 1; k >= 0; --k) {
    double acc = d[k];
    for (int t = 1; t < 4 && k + t < n; ++t) acc -= R[4 * k + t] * th[k + t];
    if (R[4 * k] == 0.0) stop("banded_gauss_draw: singular R");
    th[k] = acc / R[4 * k];
  }
  return th;
}


// E-07: the same stacked banded QR with zero noise, also returning log det(Q) = 2 sum log|R_kk| (for the collapsed lambda step).
// [[Rcpp::export]]
List banded_solve_logdet(NumericVector w, NumericVector r, NumericVector iw) {
  const int n = w.size(), m = n - 3;
  if (iw.size() != m || r.size() != n) stop("banded_solve_logdet: size mismatch");
  std::vector<double> R(4 * n, 0.0), d(n, 0.0);
  const double st[4] = {-1.0, 3.0, -3.0, 1.0};
  double xv[4];
  for (int j = 0; j < n; ++j) {
    double sw = std::sqrt(w[j]);
    xv[0] = sw; xv[1] = xv[2] = xv[3] = 0.0;
    rotate_in(R, d, n, j, xv, sw * r[j]);
    if (j < m) { double s = std::sqrt(iw[j]); for (int t = 0; t < 4; ++t) xv[t] = s * st[t]; rotate_in(R, d, n, j, xv, 0.0); }
  }
  NumericVector th(n); double ld = 0.0;
  for (int k = n - 1; k >= 0; --k) {
    double acc = d[k];
    for (int t = 1; t < 4 && k + t < n; ++t) acc -= R[4 * k + t] * th[k + t];
    if (R[4 * k] == 0.0) stop("banded_solve_logdet: singular R");
    th[k] = acc / R[4 * k]; ld += std::log(std::fabs(R[4 * k]));
  }
  return List::create(_["mean"] = th, _["logdet"] = 2.0 * ld);
}
