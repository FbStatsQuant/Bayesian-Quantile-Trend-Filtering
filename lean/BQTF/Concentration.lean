import BQTF.Basic

/-!
# Concentration of the empirical check-loss process (appendix, Lemma `pf:lem:conc`)

Owner: Neon-B. Classical inputs expected (see PLAN.md tracker): symmetrization (absolute-value
form, van der Vaart and Wellner Lemma 2.3.6), the contraction principle (absolute-value form,
Ledoux and Talagrand Theorem 4.12), and the Efron–Stein inequality.
-/

open MeasureTheory ProbabilityTheory

noncomputable section

namespace BQTF

/-- `G_K = sup_{δ ∈ K} |L̂(δ) − L(δ)|` at data `y`. -/
def GK {n : ℕ} (τ : ℝ) (μ : Fin n → Measure ℝ) (θs : Fin n → ℝ) (K : Set (Fin n → ℝ))
    (y : Fin n → ℝ) : ℝ :=
  sSup ((fun δ => |lossHat τ (y - θs) δ - lossExp τ μ θs δ|) '' K)

/-- Lemma `pf:lem:conc`: for `K` compact and symmetric (and nonempty), `G_K` is integrable,
`E G_K ≤ 4 E sup_K ⟨ξ, δ⟩` and `Var(G_K) ≤ sup_K ‖δ‖₂²`. Only independence of the
observations is used. -/
theorem concentration {n : ℕ} (τ : ℝ) (hτ : 0 < τ ∧ τ < 1) (μ : Fin n → Measure ℝ)
    (hμ : ∀ i, IsProbabilityMeasure (μ i)) (θs : Fin n → ℝ) (K : Set (Fin n → ℝ))
    (hK : IsCompact K) (hsymm : ∀ δ ∈ K, -δ ∈ K) (hne : K.Nonempty) :
    Integrable (GK τ μ θs K) (Measure.pi μ) ∧
    ∫ y, GK τ μ θs K y ∂(Measure.pi μ) ≤
      4 * ∫ ξ, sSup ((fun δ => dot ξ δ) '' K) ∂(rademacher n) ∧
    variance (GK τ μ θs K) (Measure.pi μ) ≤ sSup (l2sq '' K) := by
  sorry

end BQTF
