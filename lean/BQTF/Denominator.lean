import BQTF.PriorMass
import BQTF.CheckLoss

/-!
# Denominator (appendix, Lemma `pf:lem:evid`)

Owner: Neon-B. The event `Ω_E` is defined as the set where the denominator bound holds, for a
constant `C_E`; the lemma provides `C_E` and bounds `P(Ω_Eᶜ)`.
-/

open MeasureTheory ProbabilityTheory
open scoped ENNReal

noncomputable section

namespace BQTF

/-- The lower bound `V_r (√n ε_n / 2)^r e^{−C_E n ε_n²}` of Lemma `pf:lem:evid`. -/
def denomBound (k n : ℕ) (CE : ℝ) : ℝ≥0∞ :=
  Vr (k + 1) * ENNReal.ofReal ((Real.sqrt n * Real.sqrt (epsSq (k + 1) n) / 2) ^ (k + 1)) *
    ENNReal.ofReal (Real.exp (-(CE * n * epsSq (k + 1) n)))

/-- `Ω_E`: the data `y` for which `N(ℝⁿ) ≥ V_r (√n ε_n/2)^r e^{−C_E n ε_n²}`. -/
def OmegaE (k n : ℕ) (τ lam : ℝ) (θs : Fin n → ℝ) (CE : ℝ) : Set (Fin n → ℝ) :=
  {y | denomBound k n CE ≤ Nmass (k + 1) τ lam y θs Set.univ}

/-- Lemma `pf:lem:evid`: there are `C_E` and `n₁` (the paper's `C_E = (5/4) C_1 + 1 + C_pr`;
existential here, with the dependence on `(c, k, L, f̲, f̄, V̄)`) such that for `n ≥ n₁`,
`P(Ω_Eᶜ) ≤ (5/4)(n ε_n²)⁻¹`. -/
theorem denominator (k : ℕ) (hk : 1 ≤ k) (c L fl fu Vb : ℝ) (hc : 0 < c) (hL : 0 < L)
    (hfl : 0 < fl) :
    ∃ CE : ℝ, ∃ n₁ : ℕ, 0 < CE ∧ k + 1 < n₁ ∧ ∀ n, n₁ ≤ n → ∀ τ : ℝ, 0 < τ → τ < 1 →
      ∀ (μ : Fin n → Measure ℝ) (θs : Fin n → ℝ), DataHyp k n τ μ θs L fl fu Vb →
        Measure.pi μ (OmegaE k n τ (lamSeq c k n) θs CE)ᶜ
          ≤ ENNReal.ofReal (5 / 4 / (n * epsSq (k + 1) n)) := by
  sorry

end BQTF
