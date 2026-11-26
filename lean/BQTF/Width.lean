import BQTF.SplineApprox

/-!
# Width of `K(ρ, T)` (appendix, Lemma `pf:lem:width`)

Owner: Neon-B. Classical input expected: `E max` of `2m` sub-Gaussian variables.
-/

open MeasureTheory

noncomputable section

namespace BQTF

/-- Lemma `pf:lem:width`: for independent Rademacher signs `ξ`, all `ρ, T > 0` and
`1 ≤ J ≤ m`, `E sup_{K(ρ,T)} ⟨ξ, δ⟩ ≤ √n {ρ √(J + r) + 2^r c_F √(log 2n) T J^{−(r−1/2)}}`. -/
theorem width (r n : ℕ) (hr : 2 ≤ r) (hn : r < n) (ρ T : ℝ) (hρ : 0 < ρ) (hT : 0 < T)
    (J : ℕ) (hJpos : 1 ≤ J) (hJm : J ≤ n - r) :
    ∫ ξ, sSup ((fun δ => dot ξ δ) '' Kset r n ρ T) ∂(rademacher n)
      ≤ Real.sqrt n * (ρ * Real.sqrt (J + r) + 2 ^ r * cF r * Real.sqrt (Real.log (2 * n)) * T *
          (J : ℝ) ^ (-((r : ℝ) - 1 / 2))) := by
  sorry

end BQTF
