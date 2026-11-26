import BQTF.CheckLoss

/-!
# Separation of the true curves (appendix, Lemma `pf:lem:gap`)

Owner: Neon-B.

Under Assumption B at neighbouring levels, the true curves are at least
`g₀ = min{L, gmin/f̄}` apart at every index, where `gmin` is a lower bound on the spacing
(docs D6; the paper uses the smallest spacing itself, which gives a `g₀` at least as large, with
equality when `gmin` is the smallest spacing).

Spec does not assume `0 < f̄`. Following PLAN §5.5 note (a), `f̄ ≥ f̲ > 0` is derived from
Assumptions A and B (`fl_le_fu_of_dataHyp`), not added as a hypothesis. The one-coordinate core
`quantile_gap` needs no sign condition on `f̄` at all (B at `t = L > 0` already forces `f̄ ≥ 0`; if
`f̄ = 0`, B forces `F` to be flat near `q₁`, so `q₂ − q₁ > L`).

Nonvacuity: all `μ_i` uniform on `[0,1]`, `θ*_{ij} = τ_j` (constant curves, `TV = 0 ≤ V̄ = 0`),
`τ = (1/4, 3/4)`, `gmin = 1/2`, `f̲ = f̄ = 1`, `L = 1/4`: `DataHyp` holds at both levels for every
`n`, and the conclusion `τ_1 + min{1/4, 1/2} ≤ τ_2` is true.
-/

open MeasureTheory ProbabilityTheory

noncomputable section

namespace BQTF

/-- The separation `g₀ = min{L, gmin/f̄}` (Lemma `pf:lem:gap`, with `gmin` in place of
`min_j(τ_{j+1} − τ_j)`). -/
def gapConst (L gmin fu : ℝ) : ℝ := min L (gmin / fu)

/-- `g₀ > 0` when `L, gmin, f̄ > 0`. -/
theorem gapConst_pos {L gmin fu : ℝ} (hL : 0 < L) (hg : 0 < gmin) (hfu : 0 < fu) :
    0 < gapConst L gmin fu :=
  lt_min hL (div_pos hg hfu)

/-- PLAN §5.5 note (a): under `DataHyp` with `L > 0` and `n ≥ 1`, `f̲ ≤ f̄` (apply A and B at
`t = L` at one coordinate). With `0 < f̲` this gives `0 < f̄`. -/
theorem fl_le_fu_of_dataHyp {k n : ℕ} (hn : 1 ≤ n) {τ : ℝ} {μ : Fin n → Measure ℝ}
    {θs : Fin n → ℝ} {L fl fu Vb : ℝ} (hL : 0 < L) (h : DataHyp k n τ μ θs L fl fu Vb) :
    fl ≤ fu := by
  let i : Fin n := ⟨0, by omega⟩
  have hA := h.assA i L (by rw [abs_of_pos hL])
  have hB := h.assB i L (by rw [abs_of_pos hL])
  rw [abs_of_pos hL] at hA hB
  nlinarith

/-- Lemma `pf:lem:gap`, one coordinate: if `q₁` is a `τ₁`-quantile and `q₂` a `τ₂`-quantile of
the probability law `ν`, `τ₁ < τ₂`, and Assumption B holds at `q₁` with `(L, f̄)`, then
`q₂ − q₁ ≥ min{L, (τ₂ − τ₁)/f̄}`. -/
theorem quantile_gap {ν : Measure ℝ} [IsProbabilityMeasure ν] {τ₁ τ₂ q₁ q₂ L fu : ℝ}
    (hL : 0 < L) (hτ : τ₁ < τ₂) (h₁ : IsQuantile ν τ₁ q₁) (h₂ : IsQuantile ν τ₂ q₂)
    (hB : AssB1 ν q₁ L fu) :
    q₁ + min L ((τ₂ - τ₁) / fu) ≤ q₂ := by
  have hF₁ : distFn ν q₁ = τ₁ := (distFn_quantile_eq_of_assB1 hL h₁ hB).1
  have hF₂ : τ₂ ≤ distFn ν q₂ := h₂.2
  have hFlt : distFn ν q₁ < distFn ν q₂ := by linarith
  have hqlt : q₁ < q₂ := by
    by_contra hle
    push Not at hle
    exact not_lt_of_ge (distFn_mono ν hle) hFlt
  let d : ℝ := q₂ - q₁
  have hd : 0 < d := sub_pos.mpr hqlt
  rcases le_or_gt d L with hdL | hLd
  · have hBd := hB d (by rwa [abs_of_pos hd])
    rw [abs_of_pos hd] at hBd
    have hqeq : q₁ + d = q₂ := by dsimp [d]; ring
    rw [hqeq] at hBd
    have hdiff : τ₂ - τ₁ ≤ fu * d := by
      calc τ₂ - τ₁
          ≤ distFn ν q₂ - distFn ν q₁ := by linarith
        _ ≤ |distFn ν q₂ - distFn ν q₁| := le_abs_self _
        _ ≤ fu * d := hBd
    have hfu : 0 < fu := by nlinarith
    have hdiv : (τ₂ - τ₁) / fu ≤ d := (div_le_iff₀ hfu).mpr (by linarith)
    have hmin : min L ((τ₂ - τ₁) / fu) ≤ d := (min_le_right _ _).trans hdiv
    dsimp [d] at hmin
    linarith
  · have hmin : min L ((τ₂ - τ₁) / fu) ≤ d := (min_le_left _ _).trans hLd.le
    dsimp [d] at hmin
    linarith

/-- Lemma `pf:lem:gap` on a level grid under Assumption B alone (no Assumption A, no TV bound):
if every `μ_i` is a probability law, `θ*_{ij}` is a `τ_j`-quantile of `μ_i` at every level `j`,
Assumption B holds at every level with constants `(L, f̄)`, `L > 0` and `f̄ > 0`, then
`θ*_{i,j+1} − θ*_{ij} ≥ g₀ = min{L, gmin/f̄}` for all `i` and all consecutive levels. With `gmin`
the smallest spacing, this is the paper's bound. -/
theorem level_gap_of_assB {n J : ℕ} {τ : Fin J → ℝ} {gmin : ℝ} (hτ : LevelGrid J τ gmin)
    {μ : Fin n → Measure ℝ} (hprob : ∀ i, IsProbabilityMeasure (μ i))
    {θs : Fin J → Fin n → ℝ} {L fu : ℝ} (hL : 0 < L) (hfu : 0 < fu)
    (hq : ∀ j i, IsQuantile (μ i) (τ j) (θs j i)) (hB : ∀ j, AssumptionB μ (θs j) L fu)
    (i : Fin n) (j : ℕ) (hj : j + 1 < J) :
    θs ⟨j, by omega⟩ i + gapConst L gmin fu ≤ θs ⟨j + 1, hj⟩ i := by
  let j₀ : Fin J := ⟨j, by omega⟩
  let j₁ : Fin J := ⟨j + 1, hj⟩
  have : IsProbabilityMeasure (μ i) := hprob i
  have hlt : τ j₀ < τ j₁ := hτ.strictMono (show j₀ < j₁ by simp [j₀, j₁, Fin.lt_def])
  have hgap := quantile_gap hL hlt (hq j₀ i) (hq j₁ i) (hB j₀ i)
  have hsp : gmin ≤ τ j₁ - τ j₀ := by
    have := hτ.spacing j hj
    dsimp [j₀, j₁]
    linarith
  have hdiv : gmin / fu ≤ (τ j₁ - τ j₀) / fu := div_le_div_of_nonneg_right hsp hfu.le
  have hmin : gapConst L gmin fu ≤ min L ((τ j₁ - τ j₀) / fu) := min_le_min_left L hdiv
  dsimp [j₀, j₁] at hgap hmin ⊢
  linarith

/-- Lemma `pf:lem:gap`: under `DataHyp` at every level of a grid with spacing `≥ gmin`,
`θ*_{i,j+1} − θ*_{ij} ≥ g₀ = min{L, gmin/f̄}` for all `n`, all `i` and all consecutive levels. -/
theorem level_gap {k n J : ℕ} {τ : Fin J → ℝ} {gmin : ℝ} (hτ : LevelGrid J τ gmin)
    {μ : Fin n → Measure ℝ} {θs : Fin J → Fin n → ℝ} {L fl fu Vb : ℝ} (hL : 0 < L)
    (hfl : 0 < fl) (h : ∀ j, DataHyp k n (τ j) μ (θs j) L fl fu Vb)
    (i : Fin n) (j : ℕ) (hj : j + 1 < J) :
    θs ⟨j, by omega⟩ i + gapConst L gmin fu ≤ θs ⟨j + 1, hj⟩ i := by
  let j₀ : Fin J := ⟨j, by omega⟩
  have hn : 1 ≤ n := by have := i.isLt; omega
  have hfu : 0 < fu := lt_of_lt_of_le hfl (fl_le_fu_of_dataHyp hn hL (h j₀))
  exact level_gap_of_assB hτ (h j₀).prob hL hfu (fun j => (h j).quantile) (fun j => (h j).assB)
    i j hj

end BQTF
