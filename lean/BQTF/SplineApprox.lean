import BQTF.Coord

/-!
# Spline approximation (appendix, Lemma `pf:lem:F`)

Owner: Neon-A. `V_J` (discrete splines with `J'` equally spaced knots), `P_J`, the bounds
`h ≤ 2n/J`, `dim V_J ≤ J + r`, `(I − P_J) N = 0` and eq. `pf:eq:F`.
-/

open Finset

noncomputable section

namespace BQTF

/-- `c_∞ = (1 + 2^{r−1}) (2r)^{r−1} / (r−1)!`. -/
def cInf (r : ℕ) : ℝ := (1 + 2 ^ (r - 1)) * (2 * r : ℝ) ^ (r - 1) / (Nat.factorial (r - 1))

/-- `c_F = √r c_∞`. -/
def cF (r : ℕ) : ℝ := Real.sqrt r * cInf r

/-- `c_op = √3 r c_∞`. -/
def cOp (r : ℕ) : ℝ := Real.sqrt 3 * r * cInf r

/-- Setting of Lemma `pf:lem:F`: `h = ⌈m/J⌉ ≤ 2n/J` and `dim V_J ≤ J + r`. -/
theorem hJ_le (r n J : ℕ) (hn : r < n) (hJpos : 1 ≤ J) (hJm : J ≤ n - r) :
    1 ≤ hJ (n - r) J ∧ (hJ (n - r) J : ℝ) ≤ 2 * n / J ∧
    Module.finrank ℝ (VJ r n J) ≤ J + r := by
  sorry

/-- Lemma `pf:lem:F`, "consequently": `(I − P_J) N = 0`, i.e. `P_J` fixes `𝒫`. -/
theorem PJ_fixes_poly (r n J : ℕ) (θ : Fin n → ℝ) (hθ : θ ∈ polySpace r n) :
    PJ r n J θ = θ := by
  sorry

/-- Lemma `pf:lem:F`, eq. `pf:eq:F`: `max_j ‖(I − P_J) s_j‖₂ ≤ c_F h^{r−1/2}` and
`‖(I − P_J) S‖_op ≤ c_op h^r` (the operator bound written as `‖(I − P_J) S u‖₂ ≤ c_op h^r ‖u‖₂`). -/
theorem spline_approx (r n J : ℕ) (hr : 2 ≤ r) (hn : r < n) (hJpos : 1 ≤ J) (hJm : J ≤ n - r) :
    (∀ j : Fin (n - r), l2norm (sCol r n j - PJ r n J (sCol r n j))
        ≤ cF r * (hJ (n - r) J : ℝ) ^ ((r : ℝ) - 1 / 2)) ∧
    (∀ u : Fin (n - r) → ℝ, l2norm (Smul r n u - PJ r n J (Smul r n u))
        ≤ cOp r * (hJ (n - r) J : ℝ) ^ r * l2norm u) := by
  sorry

end BQTF
