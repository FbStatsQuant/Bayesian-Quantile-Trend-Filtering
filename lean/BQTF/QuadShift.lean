import BQTF.Basic

/-!
# Quadratic shift (appendix, Lemma `pf:lem:qshift`)

Owner: Neon-B. A general matrix `A` with columns `a_1, …, a_m` (`m ≥ 2`),
`B_ϱ = {u : ‖A u‖₂ ≤ ϱ}`, `φ(ϱ) = −log Q_λ(B_ϱ)`, `δ_A = max_{j<m} ‖a_{j+1} − a_j‖₂`.

Classical inputs expected (see PLAN.md tracker): Prékopa (marginals of log-concave densities are
log-concave) and Borell (`s ↦ log Q{‖A v‖ ≤ s}` is concave).
-/

open MeasureTheory Matrix
open scoped ENNReal

noncomputable section

namespace BQTF

/-- `B_ϱ(A) = {u : ‖A u‖₂ ≤ ϱ}` for a matrix `A ∈ ℝ^{p×m}`. -/
def BA {p m : ℕ} (A : Matrix (Fin p) (Fin m) ℝ) (ϱ : ℝ) : Set (Fin m → ℝ) :=
  {u | l2norm (A *ᵥ u) ≤ ϱ}

/-- `δ_A = max_{j < m} ‖a_{j+1} − a_j‖₂` (0-based: columns `j` and `j+1`, `j + 1 < m`). -/
def deltaA {p m : ℕ} (A : Matrix (Fin p) (Fin m) ℝ) : ℝ :=
  ⨆ j : {j : ℕ // j + 1 < m},
    l2norm (fun i => A i ⟨j.1 + 1, j.2⟩ - A i ⟨j.1, by have := j.2; omega⟩)

/-- Lemma `pf:lem:qshift`: if `δ_A ≤ λϱ/2` then for every `h ∈ ℝ^m`,
`Q_λ(h + B_ϱ) ≥ Q_λ(B_ϱ) exp{−c_K λ² ‖h‖₂²}` with `c_K = (1 + K/2)/(1 − e^{−2})`,
`K = 4 δ_A φ(ϱ/4)/(λϱ)`. The hypothesis `Q_λ(B_{ϱ/4}) > 0` (always true, since `B_{ϱ/4}`
contains a neighbourhood of `0`) makes `φ(ϱ/4)` finite. -/
theorem quad_shift {p m : ℕ} (hm : 2 ≤ m) (A : Matrix (Fin p) (Fin m) ℝ) (lam ϱ : ℝ)
    (hlam : 0 < lam) (hϱ : 0 < ϱ) (hpos : 0 < Qlam m lam (BA A (ϱ / 4)))
    (hδ : deltaA A ≤ lam * ϱ / 2) (h : Fin m → ℝ) :
    let K := 4 * deltaA A * (-Real.log (Qlam m lam (BA A (ϱ / 4))).toReal) / (lam * ϱ)
    let cK := (1 + K / 2) / (1 - Real.exp (-2))
    Qlam m lam (BA A ϱ) * ENNReal.ofReal (Real.exp (-(cK * lam ^ 2 * l2sq h)))
      ≤ Qlam m lam {u | u - h ∈ BA A ϱ} := by
  sorry

end BQTF
