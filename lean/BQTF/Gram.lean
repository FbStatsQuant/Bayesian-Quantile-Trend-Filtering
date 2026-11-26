import BQTF.Basic

/-!
# The Gram constant `g_r` (appendix, before Lemma `pf:lem:smooth`)

Owner: Neon-A. `G_w = w⁻¹ ∑_{k<w} b(k/w) b(k/w)ᵀ`, `b(x) = (1, x, …, x^{r−1})`,
`g_r = inf_{w ≥ r} λ_min(G_w) ∈ (0, 1]`, `C_s = 1 + r/g_r`.

The appendix asserts `g_r > 0` without proof; Theory's proof (theory/T10_gr_positivity/NOTE.md):
each `G_w` is positive definite (root counting), `G_w` is within `r/w` of the Hilbert matrix
`H = ∫_0^1 b bᵀ` in Frobenius norm (Riemann sums), and `H` is positive definite. `λ_min` is the
minimum of the quadratic form on unit vectors (`quadMin`).
-/

open Finset

noncomputable section

namespace BQTF

/-- `v ↦ vᵀ G_w v = w⁻¹ ∑_{k<w} (∑_a v_a (k/w)^a)²`. -/
def gramQuad (r w : ℕ) (v : Fin r → ℝ) : ℝ :=
  (∑ k ∈ range w, (∑ a : Fin r, v a * ((k : ℝ) / w) ^ (a : ℕ)) ^ 2) / w

/-- `λ_min(G_w) = min_{‖v‖₂ = 1} vᵀ G_w v`. -/
def quadMin (r w : ℕ) : ℝ := ⨅ v : {v : Fin r → ℝ // l2sq v = 1}, gramQuad r w v

/-- `g_r = inf_{w ≥ r} λ_min(G_w)`. -/
def gr (r : ℕ) : ℝ := ⨅ w : {w : ℕ // r ≤ w}, quadMin r w

/-- `C_s = 1 + r/g_r`. -/
def Cs (r : ℕ) : ℝ := 1 + r / gr r

/-- `g_r ∈ (0, 1]` (stated in the appendix before Lemma `pf:lem:smooth`; proved in T10). -/
theorem gr_pos (r : ℕ) (hr : 1 ≤ r) : 0 < gr r ∧ gr r ≤ 1 := by
  sorry

/-- `g_r ≤ λ_min(G_w)` for every `w ≥ r`, as a bound on the quadratic form. -/
theorem gr_le_gramQuad (r w : ℕ) (hr : 1 ≤ r) (hw : r ≤ w) (v : Fin r → ℝ) :
    gr r * l2sq v ≤ gramQuad r w v := by
  sorry

end BQTF
