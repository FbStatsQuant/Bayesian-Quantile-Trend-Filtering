import BQTF.CheckLoss

/-!
# Separation of the true curves (appendix, Lemma `pf:lem:gap`)

Owner: TBD (assigned at the Theorem 2 trigger).

Under Assumption B at neighbouring levels, the true curves are at least
`g₀ = min{L, gmin/f̄}` apart at every index, where `gmin` is a lower bound on the spacing
(docs D6; the paper uses the smallest spacing itself, which gives a larger `g₀`).

Spec does not assume `0 < f̄`. Following PLAN §5.5 note (a), `f̄ ≥ f̲ > 0` is derived from
Assumptions A and B (`fl_le_fu_of_dataHyp`), not added as a hypothesis. The one-coordinate core
`quantile_gap` needs no sign condition on `f̄` at all (if `f̄ ≤ 0`, B forces `F` to be flat near
`q₁`, so `q₂ − q₁ > L`).

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

private lemma distFn_eq_of_assB1 {ν : Measure ℝ} [IsProbabilityMeasure ν] {τ q L fu : ℝ}
    (hL : 0 < L) (hq : IsQuantile ν τ q) (hB : AssB1 ν q L fu) :
    distFn ν q = τ := by
  have hIio : Set.Iio q = ⋃ m : ℕ, Set.Iic (q - L / (m + 1 : ℝ)) := by
    ext x
    simp only [Set.mem_Iio, Set.mem_iUnion, Set.mem_Iic]
    constructor
    · intro hx
      have hpos : 0 < q - x := sub_pos.mpr hx
      obtain ⟨m, hm⟩ := exists_nat_gt (L / (q - x))
      refine ⟨m, ?_⟩
      have hmpos : (0 : ℝ) < (m : ℝ) + 1 := by positivity
      have hlt : L / (q - x) < (m : ℝ) + 1 := lt_trans hm (by linarith)
      have hdiv : L / ((m : ℝ) + 1) < q - x := by
        rw [div_lt_iff₀ hmpos]
        rw [div_lt_iff₀ hpos] at hlt
        linarith
      linarith
    · rintro ⟨m, hm⟩
      have hpos : (0 : ℝ) < L / ((m : ℝ) + 1) := div_pos hL (by positivity)
      linarith
  have hmono : Monotone (fun m : ℕ => Set.Iic (q - L / (m + 1 : ℝ))) := by
    intro a b hab
    apply Set.Iic_subset_Iic.mpr
    have ha : (0 : ℝ) < (a : ℝ) + 1 := by positivity
    have hb : (a : ℝ) + 1 ≤ (b : ℝ) + 1 := by exact_mod_cast Nat.add_le_add_right hab 1
    have hdiv : L / ((b : ℝ) + 1) ≤ L / ((a : ℝ) + 1) :=
      div_le_div_of_nonneg_left hL.le ha hb
    linarith
  have htend1 : Filter.Tendsto (fun m : ℕ => distFn ν (q - L / (m + 1 : ℝ)))
      Filter.atTop (nhds (ν (Set.Iio q)).toReal) := by
    have h1 := MeasureTheory.tendsto_measure_iUnion_atTop (μ := ν) hmono
    rw [← hIio] at h1
    exact (ENNReal.tendsto_toReal (measure_ne_top ν _)).comp h1
  have htend2 : Filter.Tendsto (fun m : ℕ => distFn ν (q - L / (m + 1 : ℝ)))
      Filter.atTop (nhds (distFn ν q)) := by
    rw [Metric.tendsto_atTop]
    intro ε hε
    let C : ℝ := max fu 0
    obtain ⟨N, hN⟩ := exists_nat_gt (C * L / ε)
    refine ⟨N, fun m hm => ?_⟩
    rw [Real.dist_eq]
    have hmpos : (0 : ℝ) < (m : ℝ) + 1 := by positivity
    have h1le : (1 : ℝ) ≤ (m : ℝ) + 1 := by linarith [Nat.cast_nonneg (α := ℝ) m]
    have hstep_pos : 0 < L / ((m : ℝ) + 1) := div_pos hL hmpos
    have ht_le : |-(L / ((m : ℝ) + 1))| ≤ L := by
      rw [abs_neg, abs_of_pos hstep_pos]
      exact div_le_self hL.le h1le
    have hBm := hB (-(L / ((m : ℝ) + 1))) ht_le
    rw [← sub_eq_add_neg, abs_neg, abs_of_pos hstep_pos] at hBm
    have hleC : fu * (L / ((m : ℝ) + 1)) ≤ C * (L / ((m : ℝ) + 1)) :=
      mul_le_mul_of_nonneg_right (le_max_left fu 0) hstep_pos.le
    have hlt : C * L / ε < (m : ℝ) + 1 := by
      have : (N : ℝ) ≤ (m : ℝ) := by exact_mod_cast hm
      linarith
    have hlt2 : C * (L / ((m : ℝ) + 1)) < ε := by
      rw [mul_div_assoc', div_lt_iff₀ hmpos]
      rw [div_lt_iff₀ hε] at hlt
      linarith
    exact lt_of_le_of_lt (hBm.trans hleC) hlt2
  have heq : (ν (Set.Iio q)).toReal = distFn ν q := tendsto_nhds_unique htend1 htend2
  have ⟨hq1, hq2⟩ := hq
  linarith

/-- Lemma `pf:lem:gap`, one coordinate: if `q₁` is a `τ₁`-quantile and `q₂` a `τ₂`-quantile of
the probability law `ν`, `τ₁ < τ₂`, and Assumption B holds at `q₁` with `(L, f̄)`, then
`q₂ − q₁ ≥ min{L, (τ₂ − τ₁)/f̄}`. -/
theorem quantile_gap {ν : Measure ℝ} [IsProbabilityMeasure ν] {τ₁ τ₂ q₁ q₂ L fu : ℝ}
    (hL : 0 < L) (hτ : τ₁ < τ₂) (h₁ : IsQuantile ν τ₁ q₁) (h₂ : IsQuantile ν τ₂ q₂)
    (hB : AssB1 ν q₁ L fu) :
    q₁ + min L ((τ₂ - τ₁) / fu) ≤ q₂ := by
  have hF₁ : distFn ν q₁ = τ₁ := distFn_eq_of_assB1 hL h₁ hB
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

/-- Lemma `pf:lem:gap`: under `DataHyp` at every level of a grid with spacing `≥ gmin`,
`θ*_{i,j+1} − θ*_{ij} ≥ g₀ = min{L, gmin/f̄}` for all `n`, all `i` and all consecutive levels. -/
theorem level_gap {k n J : ℕ} {τ : Fin J → ℝ} {gmin : ℝ} (hτ : LevelGrid J τ gmin)
    {μ : Fin n → Measure ℝ} {θs : Fin J → Fin n → ℝ} {L fl fu Vb : ℝ} (hL : 0 < L)
    (hfl : 0 < fl) (h : ∀ j, DataHyp k n (τ j) μ (θs j) L fl fu Vb)
    (i : Fin n) (j : ℕ) (hj : j + 1 < J) :
    θs ⟨j, by omega⟩ i + gapConst L gmin fu ≤ θs ⟨j + 1, hj⟩ i := by
  let j₀ : Fin J := ⟨j, by omega⟩
  let j₁ : Fin J := ⟨j + 1, hj⟩
  have hn : 1 ≤ n := by have := i.isLt; omega
  have hfu : 0 < fu := lt_of_lt_of_le hfl (fl_le_fu_of_dataHyp hn hL (h j₀))
  have : IsProbabilityMeasure (μ i) := (h j₀).prob i
  have hlt : τ j₀ < τ j₁ := hτ.strictMono (show j₀ < j₁ by simp [j₀, j₁, Fin.lt_def])
  have hgap := quantile_gap hL hlt ((h j₀).quantile i) ((h j₁).quantile i) ((h j₀).assB i)
  have hsp : gmin ≤ τ j₁ - τ j₀ := by
    have := hτ.spacing j hj
    dsimp [j₀, j₁]
    linarith
  have hdiv : gmin / fu ≤ (τ j₁ - τ j₀) / fu := div_le_div_of_nonneg_right hsp hfu.le
  have hmin : gapConst L gmin fu ≤ min L ((τ j₁ - τ j₀) / fu) := min_le_min_left L hdiv
  dsimp [j₀, j₁] at hgap hmin ⊢
  linarith

end BQTF
