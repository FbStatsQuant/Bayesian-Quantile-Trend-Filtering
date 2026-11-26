import BQTF.SplineApprox
import BQTF.CheckLoss

/-!
# Score events (appendix, Lemma `pf:lem:score`)

Owner: Neon-B. `t = Sᵀ(I − P_J)ζ`, i.e. `t_j = ⟨(I − P_J) s_j, ζ⟩`, and the event `Ω_ζ(J)`.
Classical inputs: Hoeffding (in Mathlib: `measure_sum_ge_le_of_iIndepFun`), Chebyshev.
-/

open MeasureTheory ProbabilityTheory
open scoped ENNReal

noncomputable section

namespace BQTF

/-- `t_j = ⟨(I − P_J) s_j, ζ⟩`. -/
def tScore (r n J : ℕ) (ζ : Fin n → ℝ) : Fin (n - r) → ℝ :=
  fun j => dot (sCol r n j - PJ r n J (sCol r n j)) ζ

/-- `Ω_ζ(J) = {‖P_J ζ‖₂² ≤ J + r, ‖t‖_∞ ≤ c_F h^{r−1/2} √(log 2n), ‖t‖₂² ≤ c_F² m h^{2r−1}}`,
with `ζ = τ − 1(y − θ* < 0)`. -/
def OmegaZeta (r n J : ℕ) (τ : ℝ) (θs : Fin n → ℝ) : Set (Fin n → ℝ) :=
  {y | l2sq (PJ r n J (score τ (y - θs))) ≤ J + r ∧
       (∀ j, |tScore r n J (score τ (y - θs)) j| ≤
          cF r * (hJ (n - r) J : ℝ) ^ ((r : ℝ) - 1 / 2) * Real.sqrt (Real.log (2 * n))) ∧
       l2sq (tScore r n J (score τ (y - θs))) ≤
          cF r ^ 2 * (n - r : ℕ) * (hJ (n - r) J : ℝ) ^ (2 * r - 1)}

/-- Lemma `pf:lem:score`: for every `1 ≤ J ≤ m`,
`P(Ω_ζ(J)ᶜ) ≤ 4/(9(J + r)) + 1/(2n) + 8r/(3J)`. -/
theorem score_events (k : ℕ) (hk : 1 ≤ k) (n : ℕ) (hn : k + 1 < n) (J : ℕ) (hJpos : 1 ≤ J)
    (hJm : J ≤ n - (k + 1)) (τ L fl fu Vb : ℝ) (hτ : 0 < τ ∧ τ < 1) (hL : 0 < L) (hfl : 0 < fl)
    (μ : Fin n → Measure ℝ) (θs : Fin n → ℝ) (h : DataHyp k n τ μ θs L fl fu Vb) :
    Measure.pi μ (OmegaZeta (k + 1) n J τ θs)ᶜ ≤
      ENNReal.ofReal (4 / (9 * (J + (k + 1 : ℝ))) + 1 / (2 * n) + 8 * (k + 1 : ℝ) / (3 * J)) := by
  sorry

end BQTF
