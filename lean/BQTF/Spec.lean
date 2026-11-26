import Mathlib

/-!
# BQTF: specification

Definitions and the main statements (as `Prop`s) for the Lean formalization of the posterior
contraction theorems of *Bayesian quantile trend filtering* (paper `paper/sections/theory.tex`,
proofs `paper/sections/appendix_theory.tex`):

* `MainStatement`       — Theorem `thm:main` at `σ = 1`;
* `MainStatementScale`  — Theorem `thm:main` at a fixed scale `σ = σ₀ > 0`
                          (last sentence of the theorem).

The joint (non-crossing) posterior is defined here as well, so that the statement of
Theorem `thm:joint` can be added later without moving definitions; that statement is not part
of the current audit.

Everything is stated on vectors `Fin n → ℝ` (the trend at the `n` design indices).

Lean conventions to keep in mind (see `docs/statements.md`):
* `Fin n → ℝ` carries the sup norm in Mathlib; every ℓ¹/ℓ² quantity below is an explicit sum.
* Indices are `0, …, n-1` (the paper uses `1, …, n`).
* Posterior probabilities are `ℝ≥0∞`-valued; no `toReal` is taken.
* `∫⁻` of a non-measurable function is a lower integral in Mathlib, so each statement also
  asserts measurability of `y ↦ Π(B ∣ y)`.
-/

open MeasureTheory ProbabilityTheory Finset
open scoped ENNReal NNReal

noncomputable section

namespace BQTF

/-! ## Check loss, difference operator, total variation, loss -/

/-- The check loss `ρ_τ(u) = u (τ − 1{u < 0})`. -/
def checkLoss (τ u : ℝ) : ℝ := u * (τ - if u < 0 then 1 else 0)

/-- The difference operator of order `r`, `D^{(r)} : ℝⁿ → ℝ^{n−r}`:
`(D^{(r)} θ)_i = ∑_{l=0}^{r} (−1)^{r−l} C(r,l) θ_{i+l}`, for `i = 0, …, n−r−1`.
For `r = 1` this is `θ_{i+1} − θ_i`. The paper uses `D = D^{(k+1)}` with `m = n − k − 1` rows;
the overall sign convention does not affect `‖Dθ‖₁`. -/
def diffOp (r n : ℕ) (θ : Fin n → ℝ) (i : Fin (n - r)) : ℝ :=
  ∑ l : Fin (r + 1), (-1 : ℝ) ^ (r - l.val) * (r.choose l.val : ℝ) *
    θ ⟨i.val + l.val, by have := i.isLt; have := l.isLt; omega⟩

/-- The ℓ¹ norm `‖v‖₁ = ∑ |v_i|`. -/
def l1norm {m : ℕ} (v : Fin m → ℝ) : ℝ := ∑ i, |v i|

/-- `TV(θ) = n^k ‖D^{(k+1)} θ‖₁` (paper: `TV(θ) = n^k ‖Dθ‖₁`). -/
def TV (k n : ℕ) (θ : Fin n → ℝ) : ℝ := (n : ℝ) ^ k * l1norm (diffOp (k + 1) n θ)

/-- The loss of Madrid Padilla and Chatterjee, `Δ²_n(v) = n⁻¹ ∑ min{|v_i|, v_i²}`. -/
def lossΔ {n : ℕ} (v : Fin n → ℝ) : ℝ := (∑ i, min |v i| (v i ^ 2)) / n

/-! ## Posterior -/

/-- Unnormalized posterior density of `θ` at level `τ`, scale `σ`, penalty `λ`, order `k`:
`exp{−σ⁻¹ ∑ ρ_τ(y_i − θ_i) − λ ‖D^{(k+1)} θ‖₁}`. It is the product of the asymmetric Laplace
working likelihood (eq. `ald`, constant factors dropped) and the prior (eq. `prior_theta`,
constant factor `λ^m` dropped); the dropped constants cancel in the posterior. -/
def postWeight (τ σ lam : ℝ) (k n : ℕ) (y θ : Fin n → ℝ) : ℝ≥0∞ :=
  ENNReal.ofReal (Real.exp (-(∑ i, checkLoss τ (y i - θ i)) / σ - lam * l1norm (diffOp (k + 1) n θ)))

/-- The posterior (eq. `post-fixed`, at scale `σ`):
`Π_λ(B ∣ y) = ∫_B w(θ) dθ / ∫_{ℝⁿ} w(θ) dθ` with `w = postWeight`, `dθ` Lebesgue measure. -/
def posterior (τ σ lam : ℝ) (k n : ℕ) (y : Fin n → ℝ) : Measure (Fin n → ℝ) :=
  (∫⁻ θ, postWeight τ σ lam k n y θ)⁻¹ • volume.withDensity (postWeight τ σ lam k n y)

/-! ## The joint (non-crossing) posterior — for Theorem `thm:joint` (statement added later) -/

/-- The ordering set `𝒞 = {Θ = (θ_1, …, θ_J) : θ_{i1} ≤ ⋯ ≤ θ_{iJ} for every i}`
(eq. `joint_order`, weak inequalities). Here `Θ j = θ_j`. -/
def orderSet (J n : ℕ) : Set (Fin J → Fin n → ℝ) := {Θ | ∀ i, Monotone fun j => Θ j i}

/-- Unnormalized joint density `∏_j w_j(θ_j)`. -/
def jointWeight {J : ℕ} (τ σ lam : Fin J → ℝ) (k n : ℕ) (y : Fin n → ℝ)
    (Θ : Fin J → Fin n → ℝ) : ℝ≥0∞ :=
  ∏ j, postWeight (τ j) (σ j) (lam j) k n y (Θ j)

/-- The joint posterior (eq. `joint-fixed`) written with the per-level normalizing constants
cancelled: `Π_𝒞(B ∣ y) = ∫_{B ∩ 𝒞} ∏_j w_j(θ_j) dΘ / ∫_𝒞 ∏_j w_j(θ_j) dΘ`.
(When every per-level normalizer is in `(0, ∞)` — which holds for `n ≥ 1` whenever each level
has `τ_j ∈ (0,1)`, `σ_j > 0` and `λ_j ≥ 0` — this equals the paper's ratio of integrals of
`∏_j Π_j(dθ_j ∣ y)`; that equality is a lemma, not a definition.) -/
def jointPosterior {J : ℕ} (τ σ lam : Fin J → ℝ) (k n : ℕ) (y : Fin n → ℝ) :
    Measure (Fin J → Fin n → ℝ) :=
  (∫⁻ Θ in orderSet J n, jointWeight τ σ lam k n y Θ)⁻¹ •
    (volume.restrict (orderSet J n)).withDensity (jointWeight τ σ lam k n y)

/-! ## Data and assumptions -/

/-- The distribution function `F(t) = μ(−∞, t]` of a measure on `ℝ`, as a real number. -/
def distFn (μ : Measure ℝ) (t : ℝ) : ℝ := (μ (Set.Iic t)).toReal

/-- `q` is a `τ`-quantile of `μ`: `μ(−∞, q) ≤ τ ≤ μ(−∞, q]`. Under Assumptions A and B
together this determines `q` uniquely: B excludes an atom at `q`, so `F(q) = τ`, and A then gives
`F(q − s) < τ < F(q + s)` for `0 < s ≤ L`, which by monotonicity excludes every other quantile. -/
def IsQuantile (μ : Measure ℝ) (τ q : ℝ) : Prop :=
  (μ (Set.Iio q)).toReal ≤ τ ∧ τ ≤ distFn μ q

/-- Assumption A (lower bound near the quantile), in coordinatewise form:
`|F_i(θ*_i + t) − F_i(θ*_i)| ≥ f̲ |t|` for all `i` and all `|t| ≤ L`. The paper's form, with
`δ ∈ ℝⁿ`, `‖δ‖_∞ ≤ L` and all `i`, is equivalent (the condition on coordinate `i` involves
`δ_i` only). -/
def AssumptionA {n : ℕ} (μ : Fin n → Measure ℝ) (θs : Fin n → ℝ) (L fl : ℝ) : Prop :=
  ∀ i t, |t| ≤ L → fl * |t| ≤ |distFn (μ i) (θs i + t) - distFn (μ i) (θs i)|

/-- Assumption B (upper bound near the quantile), coordinatewise:
`|F_i(θ*_i + t) − F_i(θ*_i)| ≤ f̄ |t|` for all `i` and all `|t| ≤ L`. -/
def AssumptionB {n : ℕ} (μ : Fin n → Measure ℝ) (θs : Fin n → ℝ) (L fu : ℝ) : Prop :=
  ∀ i t, |t| ≤ L → |distFn (μ i) (θs i + t) - distFn (μ i) (θs i)| ≤ fu * |t|

/-- The hypotheses of Theorem `thm:main` at sample size `n`, on the law of the data and the
target: `y_1, …, y_n` independent with laws `μ_i` (the data law is `Measure.pi μ`), `θ*_i` a
`τ`-quantile of `μ_i`, Assumptions A and B with constants `(L, f̲, f̄)`, and `V* = TV(θ*) ≤ V̄`. -/
structure DataHyp (k n : ℕ) (τ : ℝ) (μ : Fin n → Measure ℝ) (θs : Fin n → ℝ)
    (L fl fu Vb : ℝ) : Prop where
  prob : ∀ i, IsProbabilityMeasure (μ i)
  quantile : ∀ i, IsQuantile (μ i) τ (θs i)
  assA : AssumptionA μ θs L fl
  assB : AssumptionB μ θs L fu
  signal : TV k n θs ≤ Vb

/-! ## Rates -/

/-- The penalty `λ = c n^{(2k+1)/2}` (equivalently `λ_TV = λ / n^k = c n^{1/2}`). -/
def lamSeq (c : ℝ) (k n : ℕ) : ℝ := c * (n : ℝ) ^ ((2 * k + 1 : ℝ) / 2)

/-- The contraction rate `n^{−(2k+1)/(2k+2)}` (in the loss `Δ²_n`). -/
def rate (k n : ℕ) : ℝ := (n : ℝ) ^ (-((2 * k + 1 : ℝ) / (2 * k + 2)))

/-- The bound `n^{−1/(2k+2)}` on the expected posterior mass. -/
def massRate (k n : ℕ) : ℝ := (n : ℝ) ^ (-(1 / (2 * k + 2 : ℝ)))

/-- The event `{θ : Δ²_n(θ − θ*) > M n^{−(2k+1)/(2k+2)}}`. -/
def farSet {n : ℕ} (k : ℕ) (θs : Fin n → ℝ) (M : ℝ) : Set (Fin n → ℝ) :=
  {θ | M * rate k n < lossΔ (θ - θs)}

/-! ## Theorem `thm:main` -/

/-- The conclusion of Theorem `thm:main` at one `n`: `y ↦ Π_λ(farSet ∣ y)` is measurable and
`E_{θ*} Π_λ(Δ²_n(θ − θ*) > M n^{−(2k+1)/(2k+2)} ∣ y) ≤ C n^{−1/(2k+2)}`, where `E_{θ*}` is the
expectation under the product law `⊗_i μ_i` of `y`. -/
def MainConclusion (k n : ℕ) (τ σ lam : ℝ) (μ : Fin n → Measure ℝ) (θs : Fin n → ℝ)
    (M C : ℝ) : Prop :=
  Measurable (fun y => posterior τ σ lam k n y (farSet k θs M)) ∧
  ∫⁻ y, posterior τ σ lam k n y (farSet k θs M) ∂(Measure.pi μ)
    ≤ ENNReal.ofReal (C * massRate k n)

/-- **Theorem `thm:main`** (σ = 1). For every order `k ≥ 1` and constants `c > 0`, `L > 0`,
`f̲ > 0`, `f̄`, `V̄`, there are constants `M, C > 0` and `n₀` such that for every `n ≥ n₀`, every
level `τ ∈ (0,1)`, and every law of `y` and target `θ*` satisfying `DataHyp` (independence,
quantile, Assumptions A and B, `V* ≤ V̄`), the posterior with `σ = 1` and `λ = c n^{(2k+1)/2}`
satisfies `MainConclusion`.

The constants are chosen before `n`, `τ`, the law and `θ*`: this is the paper's
"depending only on `c, k, L, f̲, f̄, V̄`" and "uniform over all laws". -/
def MainStatement : Prop :=
  ∀ (k : ℕ), 1 ≤ k → ∀ (c L fl fu Vb : ℝ), 0 < c → 0 < L → 0 < fl →
    ∃ (M C : ℝ) (n₀ : ℕ), 0 < M ∧ 0 < C ∧
      ∀ n, n₀ ≤ n → ∀ (τ : ℝ), 0 < τ → τ < 1 →
        ∀ (μ : Fin n → Measure ℝ) (θs : Fin n → ℝ), DataHyp k n τ μ θs L fl fu Vb →
          MainConclusion k n τ 1 (lamSeq c k n) μ θs M C

/-- **Theorem `thm:main`, general scale.** The same with any fixed `σ = σ₀ > 0`; the constants
may also depend on `σ₀`. -/
def MainStatementScale : Prop :=
  ∀ (k : ℕ), 1 ≤ k → ∀ (σ₀ c L fl fu Vb : ℝ), 0 < σ₀ → 0 < c → 0 < L → 0 < fl →
    ∃ (M C : ℝ) (n₀ : ℕ), 0 < M ∧ 0 < C ∧
      ∀ n, n₀ ≤ n → ∀ (τ : ℝ), 0 < τ → τ < 1 →
        ∀ (μ : Fin n → Measure ℝ) (θs : Fin n → ℝ), DataHyp k n τ μ θs L fl fu Vb →
          MainConclusion k n τ σ₀ (lamSeq c k n) μ θs M C

end BQTF
