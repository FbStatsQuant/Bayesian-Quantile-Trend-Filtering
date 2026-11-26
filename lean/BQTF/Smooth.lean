import BQTF.Gram
import BQTF.Coord

/-!
# The smoothed truth (appendix, Lemma `pf:lem:smooth`)

Owner: Neon-A. A local polynomial smoother of `u* = Dθ*` with windows of `w` points.
-/

noncomputable section

namespace BQTF

/-- Lemma `pf:lem:smooth`: for every integer `r ≤ w ≤ m` there is `u_w ∈ ℝ^m` with
`‖u_w‖₂ ≤ C_s V* / (n^{r−1} √w)` and `‖S(u* − u_w)‖_n ≤ C_s V* (w/n)^{r−1/2}`, where
`V* = TV^{(r)}(θ*)`. -/
theorem smoothed_truth (r n : ℕ) (hr : 2 ≤ r) (hn : r < n) (θs : Fin n → ℝ) (w : ℕ)
    (hw : r ≤ w) (hwm : w ≤ n - r) :
    ∃ uw : Fin (n - r) → ℝ,
      l2norm uw ≤ Cs r * TVr r n θs / ((n : ℝ) ^ (r - 1) * Real.sqrt w) ∧
      empNorm (Smul r n (ustar r n θs - uw)) ≤
        Cs r * TVr r n θs * ((w : ℝ) / n) ^ ((r : ℝ) - 1 / 2) := by
  sorry

end BQTF
