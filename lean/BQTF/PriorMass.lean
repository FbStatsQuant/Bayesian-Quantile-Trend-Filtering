import BQTF.SmallBall
import BQTF.QuadShift
import BQTF.Smooth

/-!
# Prior mass (appendix, Proposition `pf:prop:prior`)

Owner: head (assembly of `small_ball`, `quad_shift`, `smoothed_truth`).
-/

open MeasureTheory
open scoped ENNReal

noncomputable section

namespace BQTF

/-- Proposition `pf:prop:prior`: with `λ = c n^{r−1/2}` and `V* ≤ V̄`, there is `n₁` depending
only on `(c, V̄, r)` such that for `n ≥ n₁` there is `u°` with `‖P^⊥ S(u* − u°)‖_n ≤ ε_n/2` and
`−log Q_λ(u° + B_{ε_n/2}) ≤ C_pr n ε_n²`. The constant `C_pr` is existential here, with the
paper's dependence `(c, V̄, r)` (its explicit value is not needed for Theorem `thm:main`). -/
theorem prior_mass (k : ℕ) (hk : 1 ≤ k) (c Vb : ℝ) (hc : 0 < c) :
    ∃ Cpr : ℝ, ∃ n₁ : ℕ, 0 < Cpr ∧ k + 1 < n₁ ∧ ∀ n, n₁ ≤ n → ∀ θs : Fin n → ℝ,
      TVr (k + 1) n θs ≤ Vb →
      ∃ u0 : Fin (n - (k + 1)) → ℝ,
        empNorm (Pperp (k + 1) n (Smul (k + 1) n (ustar (k + 1) n θs - u0)))
          ≤ Real.sqrt (epsSq (k + 1) n) / 2 ∧
        ENNReal.ofReal (Real.exp (-(Cpr * n * epsSq (k + 1) n)))
          ≤ Qlam (n - (k + 1)) (lamSeq c k n)
              {u | u - u0 ∈ Bsb (k + 1) n (Real.sqrt (epsSq (k + 1) n) / 2)} := by
  sorry

end BQTF
