import BQTF.Gram
import BQTF.Coord

/-!
# Interpolation inequality (appendix, Lemma `pf:lem:interp`)

Owner: Neon-A. The sup norm is bounded by the empirical norm and `TV^{(r)}`.
-/

noncomputable section

namespace BQTF

/-- Lemma `pf:lem:interp`: there is `C_I` depending only on `r` such that for `n > r` and every
`δ ∈ ℝⁿ`, `‖δ‖_∞ ≤ C_I {‖δ‖_n + ‖δ‖_n^{(2r−2)/(2r−1)} TV^{(r)}(δ)^{1/(2r−1)}}`. -/
theorem interp (r : ℕ) (hr : 2 ≤ r) :
    ∃ CI : ℝ, 0 < CI ∧ ∀ n : ℕ, r < n → ∀ (δ : Fin n → ℝ) (i : Fin n),
      |δ i| ≤ CI * (empNorm δ + empNorm δ ^ ((2 * r - 2 : ℝ) / (2 * r - 1)) *
        TVr r n δ ^ ((1 : ℝ) / (2 * r - 1))) := by
  sorry

end BQTF
