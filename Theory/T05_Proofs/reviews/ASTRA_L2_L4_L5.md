# Independent referee report on L2, L4 and L5

Line numbers refer to the reviewed drafts. All three lemma inequalities needed in the skeleton follow under the stated model.

## L2 — ACCEPT WITH FIXES

1. **CONFIRMED — The linear branch of the summed upper bound needs its own constant.** L2 lines 19–25 and 45–49 imply
   $$
   M/n \le \min\{\|\delta\|_1/n,\ C_1\|\delta\|_n^2\},\qquad C_1=\max(\bar f/2,1/L).
   $$
   The draft statement at line 111 places a common constant outside the minimum. The displayed L2 value can be too small for that convention. For a uniform law on $[-4,4]$ at its median, take $L=4$ and $f=\bar f=1/8$. Then $C_1=1/4$, whereas $m(t)/t\to1/2$ as $t\to\infty$. State the summed inequality above, or use $\max(1,C_1)$ outside the minimum. L6 lines 25–27 and 51–59 use only the quadratic branch and can keep the original constant.
2. **CONFIRMED — The lower-margin proof uses continuity at the target.** L2 lines 7, 37–43 and 53 use $F_i(0)=\tau$. For the generalized-inverse quantile, $F_i(0-)\le\tau\le F_i(0)$ in centered coordinates. Taking the left limit in the upper half of A2 gives equality throughout. Thus no extra assumption is needed, but line 53 incorrectly says the upper half is used only for the upper bound. The lower half alone permits a jump at zero with $F_i(-t)=\tau-t^2$ for small positive $t$ and $F_i(0)>\tau$. With positive right slope the lower half holds locally, yet $m_i(-t)=t^3/3$. Amend line 53 and give the signed version of line 43: for $a>0$, $m_i(-a)=\int_0^a[\tau-F_i(-s)]\,ds$. For $a>L$ its lower bound uses $\tau-F_i(-L/2)$, while the printed expression uses the positive-side CDF. This yields the same $fLa/4$ on the negative side without any symmetry of the law.

The clipped-increment identity and its bounded layer-cake integral give the expected Knight identity even for infinite-mean data. P&C Lemma 13, equation (19), uses the same integral after identifying the CDF value at the target. The variance bound is coordinatewise. Independence enters when L6 sums variances. The lower constant in L2 line 19 is uniform in the law and suffices for skeleton line 49.

## L4 — ACCEPT

1. **CONFIRMED — The direct proof covers the downstream shifts.** L4 lines 7–15 use the normalized rate-(\lambda) density and a translation of a measurable set. The density ratio bound is pointwise and dimension independent. This covers both L6 line 32 and the lower-dimensional translated section in L4q line 60. For accurate use of the citation at L4 line 19 and statement line 102, describe ADH Proposition 2.11 as the centered-norm-ball version, with scale $1/\lambda$ (or rescale the variable to unit scale). The extension to every measurable set follows from lines 13–15. In line 20 write $\lambda\|D\theta^*\|_1\le\lambda Vn^{-2}$, since A3 is a budget. The upper bound on the shift cost is exactly the direction required at skeleton line 33.

## L5 — ACCEPT

1. **CONFIRMED — The common normalization and propriety hold for every finite data vector.** L5 lines 7–16 and 22–28 use an invertible linear change of variables. Applying $D$ recovers $u$, and the remaining component uniquely determines $c$. In theta coordinates the pushforward density is $K e^{-\lambda\|D\theta\|_1}$, with $K=(\lambda/2)^{n-3}/|\det[N\ S]|$ finite and positive. The bound in line 26 is integrable even after multiplication by $K$, and the strictly positive density gives a positive denominator. The likelihood factor is jointly continuous in data and parameters. For Borel events the integrand is nonnegative measurable and the product prior is sigma-finite, so the integrals define measurable functions of the data. L6 lines 27–32 and 43–45 keep the specified Lebesgue normalization for the absolute evidence bound. Skeleton line 49 also has finite prior mass on the restricted set: for each $u$, the sup-norm constraint confines $c$ to a translated Euclidean ball of radius $\sqrt n\,\Delta$, by orthogonal projection. No moment or uniform bound on the quadratic truth enters.
2. **CONFIRMED — The invariances apply to the claimed posterior.** At L5 lines 28–30, constant Jacobians cancel in the posterior ratio. Simultaneous translation of data, truth and parameter by a null-space vector preserves Lebesgue measure, the penalty and each loss increment. No fix is needed for the model with $n\ge4$.

## Summary

L2 — ACCEPT WITH FIXES. Correct the common constant in the summed upper bound and identify where quantile continuity enters the lower margin. L4 — ACCEPT. The direct translation proof gives the full shift bound. L5 — ACCEPT. The posterior is proper and quadratically equivariant for every finite data vector. All three inputs used by the skeleton hold under the stated assumptions.
