# Sol-W2 questions

## Quadratic shift, `quad_shift` (appendix Lemma `pf:lem:qshift`)

The density-shift comparison and Jensen step are elementary. The proposed
one-coordinate conditioning does give the neighbor-shift lower bound. It
does not by itself give the two comparisons used after integrating out the
remaining coordinates. For fixed values of those coordinates, a section
can be centered at a nonzero value of the free coordinate. Evenness after
integration only compares opposite shifts.

A single specialized classical input suffices. For any finite-dimensional
linear map A, product Laplace law Q with rate λ > 0, and target Euclidean
norm, put H(b,s) = Q{x | ‖Ax + b‖₂ ≤ s}, for s > 0. For shifts b₀,b₁, radii s₀,s₁ > 0
and 0 < t < 1, require

    H((1−t)b₀+t b₁, (1−t)s₀+t s₁) ≥ H(b₀,s₀)^(1−t) H(b₁,s₁)^t.

The codomain and domain dimensions are arbitrary, including rank-deficient
A. This is Prékopa–Leindler specialized to an exponential of the negative
ℓ¹ norm times the indicator of a linear ball constraint, with no general
log-concave-measure API required. Symmetry gives H(b,s) ≤ H(0,s) by taking
opposite shifts and t = 1/2. This bounds the conditioned marginal by its
central value and gives the lower bound on the central slice at ϱ/4 from
the full small-ball probability. Restricting to b = 0 and taking logs
gives the concavity in radius needed for the dimension-free slope bound.
Neither the one-coordinate neighbor translation nor ordinary Jensen
supplies this radius comparison.

The pinned Mathlib has product and section integration
(`Measurable.lintegral_prod_right`, `lintegral_prod`, `Measure.pi`),
convexity of norms, and Jensen (`ConvexOn.map_integral_le`,
`ConcaveOn.le_map_integral`). It has no Prékopa–Leindler, Brunn–Minkowski,
or log-concave marginal theorem. The existing integration and convexity
lemmas support the setup and the Jensen step. The missing step compares
integrals of three different slice functions.

Estimate: 4–7 focused days to prove the specialized input in Lean using a
one-dimensional Prékopa–Leindler proof and product induction, then 1–2
days for the remaining shift proof. If an explicit assumption is approved,
the proposed minimal interface is the specialized H inequality above
(or its two consequences, central-slice maximality and centered radius
log-concavity). The frozen theorem and its dependencies are untouched.
The appendix's numerical constant follows from the stated integral once
K ≥ 0. I found no paper correction to propose for this lemma.

### Exact inputs at the call site

Write `B` for the matrix with column `j` deleted and identify the remaining
coordinates with `Fin d`. For `B : Matrix (Fin p) (Fin d) ℝ`,
`b : Fin p → ℝ`, and real `lam, s`, write

```lean
shiftSlice B lam b s := Qlam d lam {x | l2norm (B *ᵥ x + b) ≤ s}
```

The following are the two statements needed, for every `p d B lam` with
`0 < lam`. These are proposed interfaces.

```lean
∀ (b : Fin p → ℝ) (s : ℝ), 0 < s →
  shiftSlice B lam b s ≤ shiftSlice B lam 0 s

ConcaveOn ℝ (Set.Ioi (0 : ℝ))
  (fun s => Real.log (shiftSlice B lam 0 s).toReal)
```

The first at `s = ϱ` bounds the slice defining `f_j(t)`. Multiplication
by the one-coordinate Laplace density gives `f_j(t) ≤ f_j(0)`, which
suffices for the Jensen step. At `s = ϱ / 4`, the same input bounds every
slice by the centered one. Integrating the slice bound over the deleted
coordinate gives `Qlam m lam (BA A (ϱ / 4)) ≤ shiftSlice B lam 0 (ϱ / 4)`.

For the second, the only required consequence is the following inequality,
where `Λ s = Real.log (shiftSlice B lam 0 s).toReal`.

```lean
∀ (ϱ a : ℝ), 0 < ϱ → 0 ≤ a → a ≤ ϱ / 2 →
  Λ ϱ - Λ (ϱ - a) ≤ 4 * (-Λ (ϱ / 4)) * a / ϱ
```

Indeed, `ϱ - a` is the convex combination of `ϱ / 4` and `ϱ` with
weight `a / (3 * ϱ / 4)` on the lower endpoint. Concavity and
`Λ ϱ ≤ 0` imply even the factor `4 / 3` in place of `4`.
The centered slice at every positive radius has positive mass by continuity
of the linear map at zero and positivity of the Laplace density.

I found no elementary route to the requested dimension-free bound on
`f_j(0)`. Translating the neighboring coordinate gives the factor
`exp (-lam * |t|)` and loses radius `|t| * deltaA A`. The remaining
task is precisely the relative mass loss under that shrinkage. Scaling
all remaining coordinates and comparing Laplace densities directly gives
the lower bound `((ϱ - a) / ϱ)^d` on the mass ratio. Its logarithmic cost
involves `d`, whereas the lemma needs the cost in terms of
`-Λ (ϱ / 4)`. The Gaussian scale-mixture identity could yield the first
input independently by diagonalizing the conditional Gaussian covariance
and centering one coordinate interval at a time. That argument alone gives
no concavity in radius after mixing.

I checked the pinned Mathlib source at
`065356127b1dc0016f66b7283ce0ce2c4055aa55`. The nearest pieces are
`convexOn_norm`, `Convex.add`, `Convex.smul`,
`Measure.addHaar_smul`, `MeasureTheory.lintegral_prod`,
`ConvexOn.map_integral_le`, and Hölder via
`MeasureTheory.integral_mul_le_Lp_mul_Lq_of_nonneg` or
`ENNReal.lintegral_mul_le_Lp_mul_Lq`. The convexity and Haar lemmas give
the geometry of Minkowski combinations and the measure of a dilation.
Hölder gives an upper bound on the integral of a pointwise geometric
mean. The desired comparison needs a lower bound after evaluating at
weighted combinations of two different points. The Brunn–Minkowski
reference in `Analysis/Convex/Intrinsic.lean` is bibliographic. I found
no Prékopa–Leindler declaration or general Brunn–Minkowski volume inequality
in that source tree.

Working estimate for a dedicated worker is 4–7 focused days for the
specialized joint slice comparison and 1–2 days to assemble `quad_shift`.
That estimate assumes a one-dimensional monotone transport proof and
product induction. The main uncertainty is the transport and change-of-variable
glue for nonnegative sections that may vanish. A general-purpose Mathlib
contribution would be a larger task.
