import BQTF.Basic

/-!
# The check loss (appendix, Lemma `pf:lem:check`)

Owner: Neon-B. One coordinate at a time: `μ` is the law of one observation `y_i`, `q = θ*_i`, and
`Z = y_i − q`. Everything is stated for a probability measure `μ` on `ℝ` satisfying the
coordinate versions of Assumptions A and B (`AssA1`, `AssB1`), which are the coordinates of
`AssumptionA`, `AssumptionB` (`assumptionA_iff`, `assumptionB_iff`).
-/

open MeasureTheory ProbabilityTheory

noncomputable section

namespace BQTF

/-- `ℓ(t) = ρ_τ(z − t) − ρ_τ(z)` at `Z = z`. -/
def ell (τ t z : ℝ) : ℝ := checkLoss τ (z - t) - checkLoss τ z

/-- Knight's remainder `R(t)` at `Z = z` (Lemma `pf:lem:check`(c)):
`(t − z) 1(0 ≤ z < t)` for `t > 0`, `(z − t) 1(t < z < 0)` for `t < 0`, `0` for `t = 0`. -/
def remK (t z : ℝ) : ℝ :=
  if 0 < t then (if 0 ≤ z ∧ z < t then t - z else 0)
  else if t < 0 then (if t < z ∧ z < 0 then z - t else 0) else 0

/-- The score at `Z = z`: `τ − 1(z < 0)`. -/
def scoreZ (τ z : ℝ) : ℝ := τ - if z < 0 then 1 else 0

/-- `m(t) = E ℓ(t)` for `Z = y − q`, `y ∼ μ`. -/
def mFun (τ : ℝ) (μ : Measure ℝ) (q t : ℝ) : ℝ := ∫ y, ell τ t (y - q) ∂μ

/-- Assumption A at one coordinate. -/
def AssA1 (μ : Measure ℝ) (q L fl : ℝ) : Prop :=
  ∀ t, |t| ≤ L → fl * |t| ≤ |distFn μ (q + t) - distFn μ q|

/-- Assumption B at one coordinate. -/
def AssB1 (μ : Measure ℝ) (q L fu : ℝ) : Prop :=
  ∀ t, |t| ≤ L → |distFn μ (q + t) - distFn μ q| ≤ fu * |t|

theorem assumptionA_iff {n : ℕ} (μ : Fin n → Measure ℝ) (θs : Fin n → ℝ) (L fl : ℝ) :
    AssumptionA μ θs L fl ↔ ∀ i, AssA1 (μ i) (θs i) L fl := Iff.rfl

theorem assumptionB_iff {n : ℕ} (μ : Fin n → Measure ℝ) (θs : Fin n → ℝ) (L fu : ℝ) :
    AssumptionB μ θs L fu ↔ ∀ i, AssB1 (μ i) (θs i) L fu := Iff.rfl

/-- `C_1 = max{f̄/2, 1/L}` (before Lemma `pf:lem:check`). -/
def C1 (L fu : ℝ) : ℝ := max (fu / 2) (1 / L)

/-- Hypotheses of Lemma `pf:lem:check` at one coordinate. -/
structure CoordHyp (μ : Measure ℝ) (τ q L fl fu : ℝ) : Prop where
  prob : IsProbabilityMeasure μ
  hτ : 0 < τ ∧ τ < 1
  quantile : IsQuantile μ τ q
  hL : 0 < L
  hfl : 0 < fl
  assA : AssA1 μ q L fl
  assB : AssB1 μ q L fu

/-- Lemma `pf:lem:check`(a): `ℓ` is convex in `t`, `ℓ(0) = 0`, `ℓ` is 1-Lipschitz in `t`, and
`ℓ(t)` takes values in a fixed interval of length `|t|` (between `−τ t` and `(1−τ) t`). -/
theorem ell_props (τ z : ℝ) (hτ : 0 < τ ∧ τ < 1) :
    ConvexOn ℝ Set.univ (fun t => ell τ t z) ∧ ell τ 0 z = 0 ∧
    (∀ t t', |ell τ t z - ell τ t' z| ≤ |t - t'|) ∧
    (∀ t, min (-τ * t) ((1 - τ) * t) ≤ ell τ t z ∧ ell τ t z ≤ max (-τ * t) ((1 - τ) * t)) := by
  sorry

/-- Lemma `pf:lem:check`(b): `F(q) = τ`, i.e. `P(Z ≤ 0) = τ`; hence also `P(Z < 0) = τ`, so the
score `ζ = τ − 1(Z < 0)` has values in `{τ−1, τ}`, mean `0` and variance `τ(1−τ) ≤ 1/4`. -/
theorem distFn_quantile_eq {μ : Measure ℝ} {τ q L fl fu : ℝ} (h : CoordHyp μ τ q L fl fu) :
    distFn μ q = τ ∧ (μ (Set.Iio q)).toReal = τ := by
  sorry

/-- Lemma `pf:lem:check`(c), Knight's identity: `ℓ(t) = −t ζ + R(t)` with `0 ≤ R(t) ≤ |t|`. -/
theorem knight (τ t z : ℝ) :
    ell τ t z = -t * scoreZ τ z + remK t z ∧ 0 ≤ remK t z ∧ remK t z ≤ |t| := by
  sorry

/-- Lemma `pf:lem:check`(d): `m(t) = E R(t) = ∫_0^t (F(q+s) − τ) ds ≥ 0`, with
`f̲ t²/2 ≤ m(t) ≤ f̄ t²/2` for `|t| ≤ L` and `m(t) ≤ C_1 t²` for all `t`. -/
theorem mFun_props {μ : Measure ℝ} {τ q L fl fu : ℝ} (h : CoordHyp μ τ q L fl fu) (t : ℝ) :
    mFun τ μ q t = ∫ y, remK t (y - q) ∂μ ∧
    mFun τ μ q t = ∫ s in (0 : ℝ)..t, (distFn μ (q + s) - τ) ∧
    0 ≤ mFun τ μ q t ∧
    (|t| ≤ L → fl / 2 * t ^ 2 ≤ mFun τ μ q t ∧ mFun τ μ q t ≤ fu / 2 * t ^ 2) ∧
    mFun τ μ q t ≤ C1 L fu * t ^ 2 := by
  sorry

/-- Lemma `pf:lem:check`(e): `E R(t)² ≤ f̄|t|³/3` for `|t| ≤ L`, and
`E e^{−2R(t)} ≤ e^{−m(t)}` for `|t| ≤ min{L, 3f̲/(4f̄)}`. -/
theorem remK_moments {μ : Measure ℝ} {τ q L fl fu : ℝ} (h : CoordHyp μ τ q L fl fu) (t : ℝ) :
    (|t| ≤ L → ∫ y, remK t (y - q) ^ 2 ∂μ ≤ fu * |t| ^ 3 / 3) ∧
    (|t| ≤ min L (3 * fl / (4 * fu)) →
      ∫ y, Real.exp (-2 * remK t (y - q)) ∂μ ≤ Real.exp (-mFun τ μ q t)) := by
  sorry

end BQTF
