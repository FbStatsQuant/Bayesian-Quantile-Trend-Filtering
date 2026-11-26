import BQTF.SplineApprox

/-!
# Small ball (appendix, Lemma `pf:lem:sb`)

Owner: Neon-A. `A = n^{−1/2} P^⊥ S`, `B_ϱ = {u : ‖A u‖₂ ≤ ϱ}`, `φ(ϱ) = −log Q_λ(B_ϱ)`.
The lemma is stated as a lower bound on `Q_λ(B_ϱ)` (equivalent to the paper's upper bound on
`φ`, and meaningful also when `Q_λ(B_ϱ) = 0` would make `log` degenerate).

Classical inputs expected (see PLAN.md tracker): the Gaussian scale mixture of the Laplace law,
the Eckart–Young / Ky Fan tail bound, rotation invariance of the standard Gaussian, and
`P(|γ| ≤ t) ≥ 0.48 min{t, 1}`.
-/

open MeasureTheory
open scoped ENNReal

noncomputable section

namespace BQTF

/-- `A u = n^{−1/2} P^⊥ S u`. -/
def Asb (r n : ℕ) (u : Fin (n - r) → ℝ) : Fin n → ℝ :=
  ((n : ℝ) ^ (-(1 / 2 : ℝ))) • Pperp r n (Smul r n u)

/-- `B_ϱ = {u : ‖A u‖₂ ≤ ϱ}`. -/
def Bsb (r n : ℕ) (ϱ : ℝ) : Set (Fin (n - r) → ℝ) := {u | l2norm (Asb r n u) ≤ ϱ}

/-- Lemma `pf:lem:sb`: there is `C_sb` depending only on `r` such that for all `n > r`, `λ > 0`,
`ϱ > 0`: `φ(ϱ) ≤ C_sb {1 + (n^{r−1/2}/(λϱ))^{2/(2r−1)}}`. -/
theorem small_ball (r : ℕ) (hr : 2 ≤ r) :
    ∃ Csb : ℝ, 0 < Csb ∧ ∀ n : ℕ, r < n → ∀ lam ϱ : ℝ, 0 < lam → 0 < ϱ →
      ENNReal.ofReal (Real.exp (-(Csb * (1 + ((n : ℝ) ^ ((r : ℝ) - 1 / 2) / (lam * ϱ)) ^
          ((2 : ℝ) / (2 * r - 1))))))
        ≤ Qlam (n - r) lam (Bsb r n ϱ) := by
  sorry

end BQTF
