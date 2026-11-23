// E-07 joint v3: banded transport for the T-block (Fable Idea 1/2). Same stacked Givens QR as sampler/e07_banded.cpp.
// P(iw) = diag(w) + D' diag(iw) D = R'R (R upper triangular, bandwidth 3, positive diagonal), mu = P^{-1} W r.
//   banded_omega(w, r, iw0, theta)     : omega = R(iw0) (theta - mu(iw0))
//   banded_eval(w, r, iw, omega)       : theta = mu(iw) + R(iw)^{-1} omega, plus log det P(iw) and (w*r)'mu(iw)
//   banded_transport(w, r, iw0, iw1, theta) = banded_eval(w, r, iw1, banded_omega(w, r, iw0, theta))$theta
#include <Rcpp.h>
#include <cmath>
using namespace Rcpp;

static inline void rotate_in(std::vector<double>& R, std::vector<double>& d, int n, int s, double* xv, double xr) {
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
    xv[0] = xv[1]; xv[1] = xv[2]; xv[2] = xv[3]; xv[3] = 0.0;
  }
}

static void build_qr(const NumericVector& w, const NumericVector& r, const NumericVector& iw, std::vector<double>& R, std::vector<double>& d) {
  const int n = w.size(), m = n - 3;
  if (iw.size() != m || r.size() != n) stop("banded_*: size mismatch");
  R.assign(4 * n, 0.0); d.assign(n, 0.0);
  const double st[4] = {-1.0, 3.0, -3.0, 1.0};
  double xv[4];
  for (int j = 0; j < n; ++j) {
    double sw = std::sqrt(w[j]);
    xv[0] = sw; xv[1] = xv[2] = xv[3] = 0.0;
    rotate_in(R, d, n, j, xv, sw * r[j]);
    if (j < m) { double s = std::sqrt(iw[j]); for (int t = 0; t < 4; ++t) xv[t] = s * st[t]; rotate_in(R, d, n, j, xv, 0.0); }
  }
}

// solve R x = b (back substitution), return x and sum log R_kk
static NumericVector back_solve(const std::vector<double>& R, const std::vector<double>& b, int n, double* sumlog) {
  NumericVector x(n); double sl = 0.0;
  for (int k = n - 1; k >= 0; --k) {
    double acc = b[k];
    for (int t = 1; t < 4 && k + t < n; ++t) acc -= R[4 * k + t] * x[k + t];
    if (R[4 * k] == 0.0) stop("banded_*: singular R");
    x[k] = acc / R[4 * k]; sl += std::log(std::fabs(R[4 * k]));
  }
  if (sumlog) *sumlog = sl;
  return x;
}

// [[Rcpp::export]]
NumericVector banded_omega(NumericVector w, NumericVector r, NumericVector iw0, NumericVector theta) {
  const int n = w.size();
  if (theta.size() != n) stop("banded_omega: size mismatch");
  std::vector<double> R, d; build_qr(w, r, iw0, R, d);
  NumericVector mu = back_solve(R, d, n, nullptr);
  NumericVector om(n);
  for (int k = 0; k < n; ++k) {
    double acc = 0.0;
    for (int t = 0; t < 4 && k + t < n; ++t) acc += R[4 * k + t] * (theta[k + t] - mu[k + t]);
    om[k] = acc;
  }
  return om;
}

// [[Rcpp::export]]
List banded_eval(NumericVector w, NumericVector r, NumericVector iw, NumericVector omega) {
  const int n = w.size();
  if (omega.size() != n) stop("banded_eval: size mismatch");
  std::vector<double> R, d; build_qr(w, r, iw, R, d);
  double sl; NumericVector mu = back_solve(R, d, n, &sl);
  std::vector<double> om(omega.begin(), omega.end());
  NumericVector u = back_solve(R, om, n, nullptr);
  NumericVector th(n); double q = 0.0;
  for (int k = 0; k < n; ++k) { th[k] = mu[k] + u[k]; q += w[k] * r[k] * mu[k]; }
  return List::create(_["theta"] = th, _["logdet"] = 2.0 * sl, _["quad"] = q);
}

// [[Rcpp::export]]
NumericVector banded_transport(NumericVector w, NumericVector r, NumericVector iw0, NumericVector iw1, NumericVector theta) {
  NumericVector om = banded_omega(w, r, iw0, theta);
  List o = banded_eval(w, r, iw1, om);
  return o["theta"];
}

// ---------------------------------------------------------------------------------------------------------------------
// Exact reflective HMC for the box-truncated Gaussian  theta ~ N(mu, P^{-1}) restricted to lo <= theta <= up (Pakman & Paninski 2014).
// x = theta - mu, V ~ N(0, P^{-1}) (V = R^{-1} xi, xi ~ N(0, I)), flow x(t) = x cos t + V sin t, V(t) = -x sin t + V cos t, total time T;
// at a wall hit on coordinate i: x_i set exactly on the wall, V <- V - 2 V_i / (P^{-1})_ii P^{-1} e_i  (elastic in the P metric).
// No accept step, no bounce cap (hard safety limit 1e6 flagged in 'capped').  Returns theta, bounce count, and mu.
// [[Rcpp::export]]
List banded_rhmc(NumericVector w, NumericVector r, NumericVector iw, NumericVector theta, NumericVector lo, NumericVector up, double T) {
  const int n = w.size();
  if (theta.size() != n || lo.size() != n || up.size() != n) stop("banded_rhmc: size mismatch");
  std::vector<double> R, d; build_qr(w, r, iw, R, d);
  NumericVector mu = back_solve(R, d, n, nullptr);
  std::vector<double> xi(n); for (int k = 0; k < n; ++k) xi[k] = R::norm_rand();
  NumericVector V = back_solve(R, xi, n, nullptr);
  std::vector<double> x(n), lw(n), uw(n), Vv(n), u(n), A(n), ph(n);
  for (int k = 0; k < n; ++k) { x[k] = theta[k] - mu[k]; lw[k] = lo[k] - mu[k]; uw[k] = up[k] - mu[k]; Vv[k] = V[k]; }
  const double TWO_PI = 2.0 * M_PI;
  double tleft = T; long bounces = 0; bool capped = false; int last_i = -1, last_type = 0;   // type +1 upper, -1 lower
  std::vector<double> e(n, 0.0);
  while (true) {
    double tmin = tleft; int hi = -1, ht = 0;
    for (int k = 0; k < n; ++k) {
      double a = std::hypot(x[k], Vv[k]); A[k] = a; double p = std::atan2(Vv[k], x[k]); ph[k] = p;
      if (a <= 0.0) continue;
      if (uw[k] < a && uw[k] > -a) {            // upper wall (finite and within amplitude)
        double t = std::fmod(p - std::acos(uw[k] / a), TWO_PI); if (t < 0) t += TWO_PI;
        if (!(k == last_i && last_type == 1 && t < 1e-8) && t < tmin) { tmin = t; hi = k; ht = 1; }
      }
      if (lw[k] < a && lw[k] > -a) {            // lower wall
        double t = std::fmod(p + std::acos(lw[k] / a), TWO_PI); if (t < 0) t += TWO_PI;
        if (!(k == last_i && last_type == -1 && t < 1e-8) && t < tmin) { tmin = t; hi = k; ht = -1; }
      }
    }
    double c = std::cos(tmin), s = std::sin(tmin);
    for (int k = 0; k < n; ++k) { double xk = x[k], vk = Vv[k]; x[k] = xk * c + vk * s; Vv[k] = -xk * s + vk * c; }
    if (hi < 0) break;                                       // no hit before the end of the time budget
    tleft -= tmin; ++bounces; x[hi] = (ht == 1) ? uw[hi] : lw[hi]; last_i = hi; last_type = ht;
    // g = P^{-1} e_hi : R' u = e_hi (forward), R g = u (back)
    for (int k = 0; k < n; ++k) {
      double acc = (k == hi) ? 1.0 : 0.0;
      for (int t = 1; t < 4 && k - t >= 0; ++t) acc -= R[4 * (k - t) + t] * u[k - t];
      u[k] = acc / R[4 * k];
    }
    NumericVector g = back_solve(R, u, n, nullptr);
    double fac = 2.0 * Vv[hi] / g[hi];
    for (int k = 0; k < n; ++k) Vv[k] -= fac * g[k];
    if (tleft <= 0.0) break;
    if (bounces >= 1000000L) { capped = true; break; }
  }
  NumericVector th(n); for (int k = 0; k < n; ++k) th[k] = mu[k] + x[k];
  return List::create(_["theta"] = th, _["bounces"] = (double)bounces, _["mu"] = mu, _["capped"] = capped);
}
