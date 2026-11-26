# Statement and docstring audit, 2026-11-26

**PASS WITH FINDINGS** at `7ea4cfc`, against `ba8793b`. Both new grid and event bounds faithfully implement the corresponding paper statements. The findings concern the scope or provenance of helper results and the description of the good event. All four examples in `AxiomCheck.lean` typechecked in the supplied checkout. For each theorem Lean printed exactly `propext`, `Classical.choice`, and `Quot.sound`.

| Audited item | Assessment or proposed replacement |
|---|---|
| Transfer header, product bound | OK. For fixed data satisfying all the level bounds, the sum runs over `Fin J`. The paper's final half bound is a further eventual estimate. |
| `prodPosterior_compl_orderSet_le` | OK. Both hypothesis and conclusion use termwise `ENNReal.ofReal (η l)`, allowing real η of either sign. The strict coordinate exceedance is the sup-norm tail for the stipulated nonempty coordinate set. |
| Gap header, spacing | OK. For positive f̄ the minimum with L is nondecreasing in the spacing. The stated equality condition is sufficient. Saturation at L can also give equality. |
| Gap header, sign and flatness | OK. At t = L the absolute CDF increment is bounded by f̄L, forcing f̄ ≥ 0. At f̄ = 0 the CDF is constant through q₁ + L inclusive. Since F(q₂) ≥ τ₂ > τ₁ = F(q₁), monotonicity gives the strict q₂ > q₁ + L. The displayed Lean lower bound itself uses totalized division. |
| EckartYoung header | OK. `eckartYoung_tail` sums squared singular values over `Ico J (finrank ℝ E)`. With descending zero-based indices, the first omitted component after keeping J is indexed J. The right side is the sum of squared image norms in an arbitrary orthonormal domain basis. |
| `PL.slice_convex` | OK. A common t in [0,1] combines the two inputs, shifts and radii, giving feasibility of the combined triple in the Euclidean norm. |
| `rademacher1_probability` | OK. The measure in Basic is half the sum of the Dirac laws at −1 and 1. |
| `rademacher_probability` | OK. It is the product of that probability law over `Fin n`, including n = 0. |
| `le_rademacherMax` | OK. The absolute dot product for any column j is bounded by the finite maximum for m > 0. |
| `continuous_rademacherMax` | OK. Continuity is in the real vector ξ for fixed columns and m > 0. |
| QuadShift header | Scope. The named theorem proves the product-Laplace slice specialization. Replace the classical-input paragraph with “For λ > 0, `prekopa_laplace` in `Shift/PrekopaLaplace` proves joint log-concavity of the product-Laplace slice mass in the shift and positive radius, in multiplicative form. This module uses its consequences `laplaceSlice_le_center` and `laplaceSlice_center_log_loss` from `Shift/SliceBounds`.” |
| Width header | Scope. The cited theorem quantifies over deterministic columns and Rademacher signs. Replace the sentence after the owner with “For m > 0 and columns of Euclidean norm at most B > 0, `integral_rademacherMax_le` in `Shift/Rademacher` bounds the expected maximum absolute Rademacher dot product by B√(2 log(2m)).” |
| SmallBall header | Provenance. `Lin/GaussianSmallBall` uses Mathlib's `stdGaussian_eq_map_pi_orthonormalBasis` in its diagonalization proof. Replace the classical-input paragraph with “`Lin/LaplaceMixture` proves the Gaussian scale mixture representation and `Lin/EckartYoung` proves the squared singular-value tail bound. In `Lin/GaussianSmallBall`, `gaussian_norm_sq_measure_le` uses Gaussian rotation invariance to diagonalize the squared norm, and `gaussianReal_abs_le_lower` proves the 0.48 min(t,1) lower bound for t ≥ 0.” |
| Concentration header | OK as a description of the inputs used here. The three modules supply `symmetrization_finset` (bounded measurable finite classes), `contraction_abs` (finite nonempty symmetric classes, zero-preserving coordinatewise contractions), and `efronStein_oneSided` (product probability law). Concentration applies each. |
| Joint/Gap owner | OK. Neon-B is an attribution. |
| Joint/SupNorm owner | OK. Neon-B is an attribution. |
| Joint/SupNormScale owner | OK. Sol-P1 is an attribution. |
| Joint/Transfer owner | OK. Neon-C is an attribution. |
| Joint/Main owner | OK. Sol-P2 is an attribution. |
| Spec overview, lines 1–31 | OK. `MainStatement`, `MainStatementScale`, `JointStatement`, and `JointStatementScale` give the stated unit/fixed-positive scale variants. The four proof names have those exact types in AxiomCheck. `orderSet` imposes monotonicity across levels at each coordinate. `jointWeight` multiplies unnormalized level weights and `jointPosterior` normalizes the weighted restricted volume. `LevelGrid`, `jointFarSet`, and `JointConclusion` encode the ordered spaced levels, any-level loss exceedance, and measurability plus the expected-mass bound. The vector, index, norm and lower-integral conventions match the definitions. |
| `level_gap_of_assB` | OK. `LevelGrid` supplies the lower bound gmin for every adjacent spacing. The conclusion adds the gap to level j and bounds it by level j+1 for j+1 < J. Paper comparison below. |
| `supNorm_concentration_events` | OK. The proof takes C_I from interpolation and C_E from the denominator theorem. The type exposes positive witnesses in the stated order and gives both bounds on the named intersection. Paper comparison below. |
| `distFn_quantile_eq_of_assB1` | OK. Under a probability law, positive radius, quantile inequalities and coordinatewise B, it identifies both the closed and open left-tail probabilities as real numbers with τ. |
| `bfun_eq_prod_div_factorial` | OK. The nonnegative integer argument is cast to ℝ. The real product runs from 0 through p−1 and the entire product is divided by p!. |
| `bfun_le_pow_div_factorial` | OK. Nonnegativity identifies the cast of t.toNat with t. This includes p = 0 and the empty-product convention. |
| Falling section heading | OK. SplineApprox uses both helpers, Smooth uses the product identity and Interp uses the bound. |
| Retained `distFn_quantile_eq` docstring | OK as a chain of consequences. Its type gives both tail probabilities. The two-valued score follows from its definition, and `integral_scoreZ_eq_zero` and `integral_scoreZ_sq` establish the stated moments. |
| Retained `level_gap` and `supNorm_concentration` docstrings | OK. The first wraps the B-only result using `DataHyp` and positivity of L and f̲. The second existentially packages the event provided by the named-event theorem. |
| Joint/SupNorm module header, existing sentence affected by new declaration | “Ω is existential” now applies to only one interface. Replace that sentence with “`supNorm_concentration_events` gives both bounds on `OmegaG … ∩ OmegaE …`. The wrapper `supNorm_concentration` packages this intersection as an existential event. Neither statement asserts its measurability, and the transfer argument uses a measurable hull.” |

## D11 and D12

**D11 can be tightened.** Suggested text for the difference table follows. “`level_gap_of_assB` proves the grid form of Lemma gap for probability laws and their quantiles under Assumption B with L > 0 and f̄ > 0. Any lower bound gmin on the adjacent spacings gives min(L, gmin/f̄). For J ≥ 2, choosing the minimum spacing gives exactly the paper's g₀. `quantile_gap` is its coordinatewise core and `level_gap` its joint-data wrapper.” For J < 2 the adjacent-pair assertion is vacuous.

**D12 can be tightened.** Suggested text follows. “At unit scale, `supNorm_concentration_events` proves the posterior tail and complement-probability bounds of Lemma sup on `OmegaG … ∩ OmegaE … CE` for suitable positive C_I and C_E and all sufficiently large n. `supRad_tendsto` and `etaSeq_tendsto` give the two limits. `supNorm_concentration` retains the existential-event interface used downstream.”

Specifically, `OmegaG` is the empirical-process threshold event in the localization proof. `OmegaE` is the event that the denominator exceeds or equals the deterministic lower bound, a valid choice for the existential event in the paper's denominator lemma. The two intersection orders agree. With r = k+1, `supRad`, `etaSeq` and `massRate` give the paper's radius, tail and exponent −1/(2r). The event theorem chooses its constants. Its type does not identify them with independently preselected witnesses of interpolation or denominator estimates.

## Frozen hypotheses

| Binder | Satisfiability in the intended use |
|---|---|
| `prekopa_laplace.hs₀` | Yes. The centering call uses the positive radius s, and the centered log-loss call uses ϱ > 0. |
| `prekopa_laplace.hs₁` | Yes. The second endpoints in those calls are s and ϱ/4 respectively, both positive. |
| `supRad_tendsto.hc` | Yes. The main theorem and the paper choose c > 0 in λ = c n^((2k+1)/2). |
| `quad_shift.hpos` | Yes. In `PriorMass.lean`, `hball₈` lower-bounds this exact mass by a positive exponential and supplies `hpos` at the call. More generally, for positive radius and rate, the linear preimage of the ball contains a neighborhood of zero and the product Laplace law gives it positive mass. |

Each binder is available throughout the stated application.

## Lean head rulings (2026-11-26)

- **QuadShift, Width, SmallBall and Joint/SupNorm headers: all four HOLD. Fixed** in f64025a, using the proposed replacement text verbatim. The only addition is to SmallBall, which now names Mathlib's `stdGaussian_eq_map_pi_orthonormalBasis` as the rotation-invariance input. Every cited name was checked to exist: `prekopa_laplace`, `laplaceSlice_le_center`, `laplaceSlice_center_log_loss`, `integral_rademacherMax_le`, `gaussian_norm_sq_measure_le`, `gaussianReal_abs_le_lower` and `stdGaussian_eq_map_pi_orthonormalBasis`. Sol's review raised the Width point independently.
- **D11 and D12 tightened** in docs/statements.md §4 and in the README summary, using the suggested text.
- **Frozen binders:** noted, no change, since all four are satisfiable in their intended uses.
