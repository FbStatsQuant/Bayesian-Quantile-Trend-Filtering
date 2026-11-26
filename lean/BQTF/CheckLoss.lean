import BQTF.Basic

/-!
# The check loss (appendix, Lemma `pf:lem:check`)

Owner: Neon-B. One coordinate at a time: `μ` is the law of one observation `y_i`, `q = θ*_i`, and
`Z = y_i − q`. Everything is stated for a probability measure `μ` on `ℝ` satisfying the
coordinate versions of Assumptions A and B (`AssA1`, `AssB1`), which are the coordinates of
`AssumptionA`, `AssumptionB` (`assumptionA_iff`, `assumptionB_iff`).
-/

open MeasureTheory ProbabilityTheory

noncomputable section

namespace BQTF

/-- `ℓ(t) = ρ_τ(z − t) − ρ_τ(z)` at `Z = z`. -/
def ell (τ t z : ℝ) : ℝ := checkLoss τ (z - t) - checkLoss τ z

/-- Knight's remainder `R(t)` at `Z = z` (Lemma `pf:lem:check`(c)):
`(t − z) 1(0 ≤ z < t)` for `t > 0`, `(z − t) 1(t < z < 0)` for `t < 0`, `0` for `t = 0`. -/
def remK (t z : ℝ) : ℝ :=
  if 0 < t then (if 0 ≤ z ∧ z < t then t - z else 0)
  else if t < 0 then (if t < z ∧ z < 0 then z - t else 0) else 0

/-- The score at `Z = z`: `τ − 1(z < 0)`. -/
def scoreZ (τ z : ℝ) : ℝ := τ - if z < 0 then 1 else 0

/-- `m(t) = E ℓ(t)` for `Z = y − q`, `y ∼ μ`. -/
def mFun (τ : ℝ) (μ : Measure ℝ) (q t : ℝ) : ℝ := ∫ y, ell τ t (y - q) ∂μ

/-- Assumption A at one coordinate. -/
def AssA1 (μ : Measure ℝ) (q L fl : ℝ) : Prop :=
  ∀ t, |t| ≤ L → fl * |t| ≤ |distFn μ (q + t) - distFn μ q|

/-- Assumption B at one coordinate. -/
def AssB1 (μ : Measure ℝ) (q L fu : ℝ) : Prop :=
  ∀ t, |t| ≤ L → |distFn μ (q + t) - distFn μ q| ≤ fu * |t|

theorem assumptionA_iff {n : ℕ} (μ : Fin n → Measure ℝ) (θs : Fin n → ℝ) (L fl : ℝ) :
    AssumptionA μ θs L fl ↔ ∀ i, AssA1 (μ i) (θs i) L fl := Iff.rfl

theorem assumptionB_iff {n : ℕ} (μ : Fin n → Measure ℝ) (θs : Fin n → ℝ) (L fu : ℝ) :
    AssumptionB μ θs L fu ↔ ∀ i, AssB1 (μ i) (θs i) L fu := Iff.rfl

/-- `C_1 = max{f̄/2, 1/L}` (before Lemma `pf:lem:check`). -/
def C1 (L fu : ℝ) : ℝ := max (fu / 2) (1 / L)

/-- Hypotheses of Lemma `pf:lem:check` at one coordinate. -/
structure CoordHyp (μ : Measure ℝ) (τ q L fl fu : ℝ) : Prop where
  prob : IsProbabilityMeasure μ
  hτ : 0 < τ ∧ τ < 1
  quantile : IsQuantile μ τ q
  hL : 0 < L
  hfl : 0 < fl
  assA : AssA1 μ q L fl
  assB : AssB1 μ q L fu

/-! ### Helper lemmas -/

lemma checkLoss_eq_max (τ u : ℝ) : checkLoss τ u = max (τ * u) ((τ - 1) * u) := by
  unfold checkLoss
  split_ifs with h
  · rw [max_eq_right] <;> nlinarith
  · rw [max_eq_left] <;> nlinarith

lemma CoordHyp.fl_le_fu {μ : Measure ℝ} {τ q L fl fu : ℝ} (h : CoordHyp μ τ q L fl fu) :
    fl ≤ fu := by
  have h1 := h.assA L (by rw [abs_of_pos h.hL])
  have h2 := h.assB L (by rw [abs_of_pos h.hL])
  rw [abs_of_pos h.hL] at h1 h2
  nlinarith [h.hL]

lemma CoordHyp.hfu {μ : Measure ℝ} {τ q L fl fu : ℝ} (h : CoordHyp μ τ q L fl fu) :
    0 < fu := lt_of_lt_of_le h.hfl h.fl_le_fu

lemma distFn_mono (μ : Measure ℝ) [IsFiniteMeasure μ] : Monotone (distFn μ) := by
  intro a b hab
  unfold distFn
  exact ENNReal.toReal_mono (measure_ne_top μ _) (measure_mono (Set.Iic_subset_Iic.mpr hab))

lemma measurable_scoreZ (τ : ℝ) : Measurable (scoreZ τ) := by
  unfold scoreZ
  exact measurable_const.sub (Measurable.ite (measurableSet_lt measurable_id measurable_const)
    measurable_const measurable_const)

lemma measurable_remK (t : ℝ) : Measurable (remK t) := by
  unfold remK
  split_ifs
  · exact Measurable.ite ((measurableSet_le measurable_const measurable_id).inter
      (measurableSet_lt measurable_id measurable_const))
      (measurable_const.sub measurable_id) measurable_const
  · exact Measurable.ite ((measurableSet_lt measurable_const measurable_id).inter
      (measurableSet_lt measurable_id measurable_const))
      (measurable_id.sub measurable_const) measurable_const
  · exact measurable_const

lemma measurable_checkLoss (τ : ℝ) : Measurable (checkLoss τ) := by
  have h : checkLoss τ = fun u => max (τ * u) ((τ - 1) * u) := funext (checkLoss_eq_max τ)
  rw [h]
  exact (measurable_const.mul measurable_id).max (measurable_const.mul measurable_id)

lemma measurable_ell (τ t : ℝ) : Measurable (fun z => ell τ t z) := by
  unfold ell
  exact ((measurable_checkLoss τ).comp (measurable_id.sub measurable_const)).sub
    (measurable_checkLoss τ)

/-- Lemma `pf:lem:check`(a): `ℓ` is convex in `t`, `ℓ(0) = 0`, `ℓ` is 1-Lipschitz in `t`, and
`ℓ(t)` takes values in a fixed interval of length `|t|` (between `−τ t` and `(1−τ) t`). -/
theorem ell_props (τ z : ℝ) (hτ : 0 < τ ∧ τ < 1) :
    ConvexOn ℝ Set.univ (fun t => ell τ t z) ∧ ell τ 0 z = 0 ∧
    (∀ t t', |ell τ t z - ell τ t' z| ≤ |t - t'|) ∧
    (∀ t, min (-τ * t) ((1 - τ) * t) ≤ ell τ t z ∧ ell τ t z ≤ max (-τ * t) ((1 - τ) * t)) := by
  refine ⟨?_, ?_, ?_, ?_⟩
  · -- Convexity: `t ↦ max (τ * (z - t)) ((τ - 1) * (z - t)) - checkLoss τ z`
    refine ⟨convex_univ, fun x _ y _ a b ha hb hab => ?_⟩
    simp only [ell, checkLoss_eq_max, smul_eq_mul]
    have h1 : τ * (z - (a * x + b * y)) = a * (τ * (z - x)) + b * (τ * (z - y)) := by
      linear_combination -τ * z * hab
    have h2 : (τ - 1) * (z - (a * x + b * y)) =
        a * ((τ - 1) * (z - x)) + b * ((τ - 1) * (z - y)) := by
      linear_combination -(τ - 1) * z * hab
    have h3 : checkLoss τ z = a * checkLoss τ z + b * checkLoss τ z := by
      linear_combination -checkLoss τ z * hab
    have hle1 : a * (τ * (z - x)) + b * (τ * (z - y)) ≤
        a * max (τ * (z - x)) ((τ - 1) * (z - x)) + b * max (τ * (z - y)) ((τ - 1) * (z - y)) :=
      add_le_add (mul_le_mul_of_nonneg_left (le_max_left _ _) ha)
        (mul_le_mul_of_nonneg_left (le_max_left _ _) hb)
    have hle2 : a * ((τ - 1) * (z - x)) + b * ((τ - 1) * (z - y)) ≤
        a * max (τ * (z - x)) ((τ - 1) * (z - x)) + b * max (τ * (z - y)) ((τ - 1) * (z - y)) :=
      add_le_add (mul_le_mul_of_nonneg_left (le_max_right _ _) ha)
        (mul_le_mul_of_nonneg_left (le_max_right _ _) hb)
    have hmax : max (τ * (z - (a * x + b * y))) ((τ - 1) * (z - (a * x + b * y))) ≤
        a * max (τ * (z - x)) ((τ - 1) * (z - x)) + b * max (τ * (z - y)) ((τ - 1) * (z - y)) :=
      max_le (h1 ▸ hle1) (h2 ▸ hle2)
    have hexp : a * (max (τ * (z - x)) ((τ - 1) * (z - x)) - max (τ * z) ((τ - 1) * z)) +
        b * (max (τ * (z - y)) ((τ - 1) * (z - y)) - max (τ * z) ((τ - 1) * z)) =
        a * max (τ * (z - x)) ((τ - 1) * (z - x)) + b * max (τ * (z - y)) ((τ - 1) * (z - y)) -
        (a + b) * max (τ * z) ((τ - 1) * z) := by ring
    rw [hexp, hab, one_mul]
    linarith
  · -- `ell τ 0 z = 0`
    simp [ell]
  · -- 1-Lipschitz
    intro t t'
    simp only [ell, checkLoss]
    rw [abs_le]
    split_ifs <;> constructor <;>
      first | linarith [le_abs_self (t - t'), neg_abs_le (t - t')]
            | nlinarith [le_abs_self (t - t'), neg_abs_le (t - t')]
  · -- Interval bounds
    intro t
    simp only [ell, checkLoss]
    split_ifs
    · constructor
      · exact le_trans (min_le_right _ _) (by linarith)
      · exact le_trans (by linarith) (le_max_right _ _)
    · constructor
      · exact le_trans (min_le_left _ _) (by linarith)
      · exact le_trans (by linarith) (le_max_right _ _)
    · constructor
      · exact le_trans (min_le_right _ _) (by linarith)
      · exact le_trans (by linarith) (le_max_left _ _)
    · constructor
      · exact le_trans (min_le_left _ _) (by linarith)
      · exact le_trans (by linarith) (le_max_left _ _)

/-- The left-limit step of Lemma `pf:lem:check`(b) under Assumption B alone: if `q` is a
`τ`-quantile of the probability law `μ` and B holds at `q` with `L > 0`, then `F(q) = τ` and
`μ(−∞, q) = τ`. No sign condition on `f̄` is needed. -/
theorem distFn_quantile_eq_of_assB1 {μ : Measure ℝ} [IsProbabilityMeasure μ] {τ q L fu : ℝ}
    (hL : 0 < L) (hq : IsQuantile μ τ q) (hB : AssB1 μ q L fu) :
    distFn μ q = τ ∧ (μ (Set.Iio q)).toReal = τ := by
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
  have htend1 : Filter.Tendsto (fun m : ℕ => distFn μ (q - L / (m + 1 : ℝ)))
      Filter.atTop (nhds (μ (Set.Iio q)).toReal) := by
    have h1 := MeasureTheory.tendsto_measure_iUnion_atTop (μ := μ) hmono
    rw [← hIio] at h1
    exact (ENNReal.tendsto_toReal (measure_ne_top μ _)).comp h1
  have htend2 : Filter.Tendsto (fun m : ℕ => distFn μ (q - L / (m + 1 : ℝ)))
      Filter.atTop (nhds (distFn μ q)) := by
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
  have heq : (μ (Set.Iio q)).toReal = distFn μ q := tendsto_nhds_unique htend1 htend2
  have ⟨hq1, hq2⟩ := hq
  constructor <;> linarith

/-- Lemma `pf:lem:check`(b): `F(q) = τ`, i.e. `P(Z ≤ 0) = τ`; hence also `P(Z < 0) = τ`, so the
score `ζ = τ − 1(Z < 0)` has values in `{τ−1, τ}`, mean `0` and variance `τ(1−τ) ≤ 1/4`. -/
theorem distFn_quantile_eq {μ : Measure ℝ} {τ q L fl fu : ℝ} (h : CoordHyp μ τ q L fl fu) :
    distFn μ q = τ ∧ (μ (Set.Iio q)).toReal = τ := by
  have := h.prob
  exact distFn_quantile_eq_of_assB1 h.hL h.quantile h.assB

lemma integral_scoreZ_eq_zero {μ : Measure ℝ} {τ q L fl fu : ℝ} (h : CoordHyp μ τ q L fl fu) :
    ∫ y, scoreZ τ (y - q) ∂μ = 0 := by
  have := h.prob
  have hmeas : MeasurableSet (Set.Iio q) := measurableSet_Iio
  have hrewrite : (fun y : ℝ => scoreZ τ (y - q)) =
      fun y => τ - (Set.Iio q).indicator (fun _ => (1 : ℝ)) y := by
    ext y
    simp only [scoreZ, Set.indicator, Set.mem_Iio, sub_lt_zero]
  rw [hrewrite, integral_sub (integrable_const τ) ((integrable_const (1 : ℝ)).indicator hmeas)]
  simp only [integral_const, smul_eq_mul, integral_indicator_const _ hmeas, Measure.real,
    measure_univ, ENNReal.toReal_one, one_mul, mul_one]
  rw [(distFn_quantile_eq h).2, sub_self]

lemma integral_scoreZ_sq {μ : Measure ℝ} {τ q L fl fu : ℝ} (h : CoordHyp μ τ q L fl fu) :
    ∫ y, scoreZ τ (y - q) ^ 2 ∂μ = τ * (1 - τ) := by
  have := h.prob
  have hmeas : MeasurableSet (Set.Iio q) := measurableSet_Iio
  have hrewrite : (fun y : ℝ => scoreZ τ (y - q) ^ 2) =
      fun y => τ ^ 2 + (Set.Iio q).indicator (fun _ => (1 - 2 * τ : ℝ)) y := by
    ext y
    simp only [scoreZ, Set.indicator, Set.mem_Iio, sub_lt_zero]
    split_ifs <;> ring
  rw [hrewrite, integral_add (integrable_const _) ((integrable_const _).indicator hmeas)]
  simp only [integral_const, smul_eq_mul, integral_indicator_const _ hmeas, Measure.real,
    measure_univ, ENNReal.toReal_one, one_mul]
  rw [(distFn_quantile_eq h).2]
  ring

lemma integral_scoreZ_pow_four {μ : Measure ℝ} {τ q L fl fu : ℝ} (h : CoordHyp μ τ q L fl fu) :
    ∫ y, scoreZ τ (y - q) ^ 4 ∂μ = τ * (1 - τ) * (1 - 3 * (τ * (1 - τ))) := by
  have := h.prob
  have hmeas : MeasurableSet (Set.Iio q) := measurableSet_Iio
  have hrewrite : (fun y : ℝ => scoreZ τ (y - q) ^ 4) =
      fun y => τ ^ 4 + (Set.Iio q).indicator (fun _ => ((τ - 1) ^ 4 - τ ^ 4 : ℝ)) y := by
    ext y
    simp only [scoreZ, Set.indicator, Set.mem_Iio, sub_lt_zero]
    split_ifs <;> ring
  rw [hrewrite, integral_add (integrable_const _) ((integrable_const _).indicator hmeas)]
  simp only [integral_const, smul_eq_mul, integral_indicator_const _ hmeas, Measure.real,
    measure_univ, ENNReal.toReal_one, one_mul]
  rw [(distFn_quantile_eq h).2]
  ring

/-- Lemma `pf:lem:check`(c), Knight's identity: `ℓ(t) = −t ζ + R(t)` with `0 ≤ R(t) ≤ |t|`. -/
theorem knight (τ t z : ℝ) :
    ell τ t z = -t * scoreZ τ z + remK t z ∧ 0 ≤ remK t z ∧ remK t z ≤ |t| := by
  refine ⟨?_, ?_, ?_⟩
  · unfold ell checkLoss scoreZ remK
    by_cases ht : 0 < t
    · by_cases hz0 : z < 0
      · have hzt : z - t < 0 := by linarith
        have hnot : ¬(0 ≤ z ∧ z < t) := by intro ⟨h1, _⟩; linarith
        simp [ht, hz0, hzt, hnot]; ring
      · by_cases hzt : z < t
        · have hzt' : z - t < 0 := by linarith
          have hcond : 0 ≤ z ∧ z < t := ⟨not_lt.mp hz0, hzt⟩
          simp [ht, hz0, hzt', hcond]; ring
        · have hzt' : ¬(z - t < 0) := by linarith
          have hnot : ¬(0 ≤ z ∧ z < t) := by intro ⟨_, h2⟩; exact hzt h2
          simp [ht, hz0, hzt', hnot]; ring
    · by_cases ht' : t < 0
      · by_cases hz0 : z < 0
        · by_cases htz : t < z
          · have hzt' : ¬(z - t < 0) := by linarith
            have hcond : t < z ∧ z < 0 := ⟨htz, hz0⟩
            simp [ht, ht', hz0, hzt', hcond]; ring
          · by_cases heq : z = t
            · subst heq
              simp [ht, ht']
            · have hzt' : z - t < 0 := by linarith [lt_of_le_of_ne (not_lt.mp htz) heq]
              simp [ht, ht', hz0, hzt', htz]; ring
        · have hzt' : ¬(z - t < 0) := by linarith
          simp [ht, ht', hz0, hzt']; ring
      · have ht0 : t = 0 := le_antisymm (not_lt.mp ht) (not_lt.mp ht')
        subst ht0
        simp
  · simp only [remK]
    split_ifs <;> linarith
  · simp only [remK]
    split_ifs <;> linarith [le_abs_self t, neg_abs_le t]

private lemma integral_remK_eq_pos {μ : Measure ℝ} {τ q L fl fu : ℝ}
    (h : CoordHyp μ τ q L fl fu) {t : ℝ} (ht : 0 < t) :
    ∫ y, remK t (y - q) ∂μ = ∫ s in (0 : ℝ)..t, (distFn μ (q + s) - τ) := by
  have := h.prob
  let ν : Measure ℝ := volume.restrict (Set.Ioc 0 t)
  have : IsFiniteMeasure ν := ⟨by simp [ν]⟩
  let S : Set (ℝ × ℝ) := {p | q ≤ p.1 ∧ p.1 ≤ q + p.2}
  have hS : MeasurableSet S :=
    (measurableSet_le measurable_const measurable_fst).inter
      (measurableSet_le measurable_fst (measurable_const.add measurable_snd))
  let f : ℝ → ℝ → ℝ := fun y s => S.indicator (fun _ => (1 : ℝ)) (y, s)
  have hf_int : Integrable (Function.uncurry f) (μ.prod ν) :=
    (integrable_const (1 : ℝ)).indicator hS
  have hinner_y : ∀ y : ℝ, ∫ s, f y s ∂ν = remK t (y - q) := by
    intro y
    simp only [f, S, ν, Set.indicator, Set.mem_ofPred_eq]
    by_cases hy : q ≤ y
    · have hrew : (fun s : ℝ => if q ≤ y ∧ y ≤ q + s then (1 : ℝ) else 0) =
          (Set.Ici (y - q)).indicator (fun _ => (1 : ℝ)) := by
        ext s
        simp only [Set.indicator, Set.mem_Ici, hy, true_and]
        have hiff : y ≤ q + s ↔ y - q ≤ s := ⟨fun h => by linarith, fun h => by linarith⟩
        simp only [hiff]
      rw [hrew, integral_indicator measurableSet_Ici, Measure.restrict_restrict measurableSet_Ici]
      simp only [integral_const, smul_eq_mul, mul_one, Measure.real, Measure.restrict_apply_univ]
      by_cases hyt : y - q < t
      · have hcond : 0 ≤ y - q ∧ y - q < t := ⟨sub_nonneg.mpr hy, hyt⟩
        simp only [remK, ht, hcond, and_self, ↓reduceIte]
        by_cases hy0 : y - q = 0
        · have hinter : Set.Ici (y - q) ∩ Set.Ioc 0 t = Set.Ioc 0 t := by
            rw [hy0]; ext s; simp only [Set.mem_inter_iff, Set.mem_Ici, Set.mem_Ioc]
            exact ⟨fun h => h.2, fun h => ⟨h.1.le, h⟩⟩
          rw [hinter, Real.volume_Ioc, ENNReal.toReal_ofReal (sub_nonneg.mpr ht.le), hy0]
        · have hypos : 0 < y - q := lt_of_le_of_ne (sub_nonneg.mpr hy) (Ne.symm hy0)
          have hinter : Set.Ici (y - q) ∩ Set.Ioc 0 t = Set.Icc (y - q) t := by
            ext s; simp only [Set.mem_inter_iff, Set.mem_Ici, Set.mem_Ioc, Set.mem_Icc]
            exact ⟨fun ⟨h1, _, h3⟩ => ⟨h1, h3⟩, fun ⟨h1, h2⟩ => ⟨h1, lt_of_lt_of_le hypos h1, h2⟩⟩
          rw [hinter, Real.volume_Icc, ENNReal.toReal_ofReal (sub_nonneg.mpr hyt.le)]
      · have hnot : ¬(0 ≤ y - q ∧ y - q < t) := by tauto
        simp only [remK, ht, hnot, ↓reduceIte]
        have hsub : Set.Ici (y - q) ∩ Set.Ioc 0 t ⊆ {t} := by
          intro s ⟨h1, _, h3⟩
          exact Set.mem_singleton_iff.mpr (le_antisymm h3 (le_trans (not_lt.mp hyt) h1))
        have hzero : volume (Set.Ici (y - q) ∩ Set.Ioc 0 t) = 0 :=
          measure_mono_null hsub (by simp)
        simp [hzero]
    · have hzero : (fun s : ℝ => if q ≤ y ∧ y ≤ q + s then (1 : ℝ) else 0) = fun _ => 0 := by
        ext s; simp [hy]
      have hnot : ¬(0 ≤ y - q ∧ y - q < t) := by intro ⟨h1, _⟩; exact hy (by linarith)
      rw [hzero, integral_zero]
      simp only [remK, ht, hnot, ↓reduceIte]
  have hinner_s : ∀ s ∈ Set.Ioc 0 t, ∫ y, f y s ∂μ = distFn μ (q + s) - τ := by
    intro s hs
    have hspos : 0 < s := hs.1
    have hrew : (fun y : ℝ => f y s) = (Set.Icc q (q + s)).indicator (fun _ => (1 : ℝ)) := by
      ext y; simp [f, S, Set.indicator, Set.mem_Icc]
    rw [hrew, integral_indicator_const _ measurableSet_Icc]
    simp only [smul_eq_mul, mul_one, Measure.real]
    have hunion : Set.Iio q ∪ Set.Icc q (q + s) = Set.Iic (q + s) := by
      ext y; simp only [Set.mem_union, Set.mem_Iio, Set.mem_Icc, Set.mem_Iic]
      constructor
      · rintro (h1 | ⟨_, h2⟩) <;> linarith
      · intro h1; by_cases h2 : y < q; exact Or.inl h2; exact Or.inr ⟨not_lt.mp h2, h1⟩
    have hdisj : Disjoint (Set.Iio q) (Set.Icc q (q + s)) := by
      rw [Set.disjoint_left]; intro y h1 h2; exact not_lt.mpr h2.1 h1
    have hadd : μ (Set.Iic (q + s)) = μ (Set.Iio q) + μ (Set.Icc q (q + s)) := by
      rw [← hunion, measure_union hdisj measurableSet_Icc]
    have htoReal := congrArg ENNReal.toReal hadd
    rw [ENNReal.toReal_add (measure_ne_top μ _) (measure_ne_top μ _)] at htoReal
    rw [(distFn_quantile_eq h).2] at htoReal
    unfold distFn
    linarith
  have hswap := MeasureTheory.integral_integral_swap hf_int
  simp_rw [hinner_y] at hswap
  rw [hswap, intervalIntegral.integral_of_le ht.le]
  exact setIntegral_congr_fun measurableSet_Ioc hinner_s

private lemma integral_remK_eq_neg {μ : Measure ℝ} {τ q L fl fu : ℝ}
    (h : CoordHyp μ τ q L fl fu) {t : ℝ} (ht : t < 0) :
    ∫ y, remK t (y - q) ∂μ = ∫ s in (0 : ℝ)..t, (distFn μ (q + s) - τ) := by
  have := h.prob
  let ν : Measure ℝ := volume.restrict (Set.Ioo t 0)
  have : IsFiniteMeasure ν := ⟨by simp [ν]⟩
  let S : Set (ℝ × ℝ) := {p | q + p.2 < p.1 ∧ p.1 < q}
  have hS : MeasurableSet S :=
    (measurableSet_lt (measurable_const.add measurable_snd) measurable_fst).inter
      (measurableSet_lt measurable_fst measurable_const)
  let f : ℝ → ℝ → ℝ := fun y s => S.indicator (fun _ => (1 : ℝ)) (y, s)
  have hf_int : Integrable (Function.uncurry f) (μ.prod ν) :=
    (integrable_const (1 : ℝ)).indicator hS
  have hnot_pos : ¬(0 < t) := not_lt.mpr ht.le
  have hinner_y : ∀ y : ℝ, ∫ s, f y s ∂ν = remK t (y - q) := by
    intro y
    simp only [f, S, ν, Set.indicator, Set.mem_ofPred_eq]
    by_cases hy : y < q
    · have hrew : (fun s : ℝ => if q + s < y ∧ y < q then (1 : ℝ) else 0) =
          (Set.Iio (y - q)).indicator (fun _ => (1 : ℝ)) := by
        ext s
        simp only [Set.indicator, Set.mem_Iio, hy, and_true]
        have hiff : q + s < y ↔ s < y - q := ⟨fun h => by linarith, fun h => by linarith⟩
        simp only [hiff]
      rw [hrew, integral_indicator measurableSet_Iio, Measure.restrict_restrict measurableSet_Iio]
      simp only [integral_const, smul_eq_mul, mul_one, Measure.real, Measure.restrict_apply_univ]
      by_cases hyt : t < y - q
      · have hcond : t < y - q ∧ y - q < 0 := ⟨hyt, sub_neg.mpr hy⟩
        simp only [remK, hnot_pos, ht, hcond, and_self, ↓reduceIte]
        have hinter : Set.Iio (y - q) ∩ Set.Ioo t 0 = Set.Ioo t (y - q) := by
          ext s; simp only [Set.mem_inter_iff, Set.mem_Iio, Set.mem_Ioo]
          exact ⟨fun ⟨h1, h2, _⟩ => ⟨h2, h1⟩, fun ⟨h1, h2⟩ => ⟨h2, h1, lt_trans h2 (sub_neg.mpr hy)⟩⟩
        rw [hinter, Real.volume_Ioo, ENNReal.toReal_ofReal (sub_nonneg.mpr hyt.le)]
      · have hnot : ¬(t < y - q ∧ y - q < 0) := by tauto
        simp only [remK, hnot_pos, ht, hnot, ↓reduceIte]
        have hinter : Set.Iio (y - q) ∩ Set.Ioo t 0 = ∅ := by
          ext s; simp only [Set.mem_inter_iff, Set.mem_Iio, Set.mem_Ioo, Set.mem_empty_iff_false,
            iff_false, not_and]
          intro h1 h2; linarith [not_lt.mp hyt]
        simp [hinter]
    · have hzero : (fun s : ℝ => if q + s < y ∧ y < q then (1 : ℝ) else 0) = fun _ => 0 := by
        ext s; simp [hy]
      have hnot : ¬(t < y - q ∧ y - q < 0) := by intro ⟨_, h2⟩; exact hy (by linarith)
      rw [hzero, integral_zero]
      simp only [remK, hnot_pos, ht, hnot, ↓reduceIte]
  have hinner_s : ∀ s ∈ Set.Ioo t 0, ∫ y, f y s ∂μ = τ - distFn μ (q + s) := by
    intro s hs
    have hsneg : s < 0 := hs.2
    have hrew : (fun y : ℝ => f y s) = (Set.Ioo (q + s) q).indicator (fun _ => (1 : ℝ)) := by
      ext y; simp [f, S, Set.indicator, Set.mem_Ioo]
    rw [hrew, integral_indicator_const _ measurableSet_Ioo]
    simp only [smul_eq_mul, mul_one, Measure.real]
    have hunion : Set.Iic (q + s) ∪ Set.Ioo (q + s) q = Set.Iio q := by
      ext y; simp only [Set.mem_union, Set.mem_Iic, Set.mem_Ioo, Set.mem_Iio]
      constructor
      · rintro (h1 | ⟨_, h2⟩) <;> linarith
      · intro h1; by_cases h2 : y ≤ q + s; exact Or.inl h2; exact Or.inr ⟨not_le.mp h2, h1⟩
    have hdisj : Disjoint (Set.Iic (q + s)) (Set.Ioo (q + s) q) := by
      rw [Set.disjoint_left]; intro y h1 h2; exact not_lt.mpr h1 h2.1
    have hadd : μ (Set.Iio q) = μ (Set.Iic (q + s)) + μ (Set.Ioo (q + s) q) := by
      rw [← hunion, measure_union hdisj measurableSet_Ioo]
    have htoReal := congrArg ENNReal.toReal hadd
    rw [ENNReal.toReal_add (measure_ne_top μ _) (measure_ne_top μ _)] at htoReal
    rw [(distFn_quantile_eq h).2] at htoReal
    unfold distFn
    linarith
  have hswap := MeasureTheory.integral_integral_swap hf_int
  simp_rw [hinner_y] at hswap
  rw [hswap, intervalIntegral.integral_symm, intervalIntegral.integral_of_le ht.le,
    ← integral_neg, integral_Ioc_eq_integral_Ioo]
  refine setIntegral_congr_fun measurableSet_Ioo (fun s hs => ?_)
  rw [hinner_s s hs]
  ring

/-- Lemma `pf:lem:check`(d): `m(t) = E R(t) = ∫_0^t (F(q+s) − τ) ds ≥ 0`, with
`f̲ t²/2 ≤ m(t) ≤ f̄ t²/2` for `|t| ≤ L` and `m(t) ≤ C_1 t²` for all `t`. -/
theorem mFun_props {μ : Measure ℝ} {τ q L fl fu : ℝ} (h : CoordHyp μ τ q L fl fu) (t : ℝ) :
    mFun τ μ q t = ∫ y, remK t (y - q) ∂μ ∧
    mFun τ μ q t = ∫ s in (0 : ℝ)..t, (distFn μ (q + s) - τ) ∧
    0 ≤ mFun τ μ q t ∧
    (|t| ≤ L → fl / 2 * t ^ 2 ≤ mFun τ μ q t ∧ mFun τ μ q t ≤ fu / 2 * t ^ 2) ∧
    mFun τ μ q t ≤ C1 L fu * t ^ 2 := by
  have := h.prob
  have h_eq_remK : mFun τ μ q t = ∫ y, remK t (y - q) ∂μ := by
    unfold mFun
    have hsplit : (fun y : ℝ => ell τ t (y - q)) =
        fun y => -t * scoreZ τ (y - q) + remK t (y - q) := by
      ext y; exact (knight τ t (y - q)).1
    have hint1 : Integrable (fun y : ℝ => -t * scoreZ τ (y - q)) μ := by
      refine Integrable.of_bound
        ((measurable_const.mul ((measurable_scoreZ τ).comp (measurable_id.sub measurable_const))).aestronglyMeasurable)
        (|t| * (|τ| + 1)) (Filter.Eventually.of_forall fun y => ?_)
      rw [Real.norm_eq_abs, abs_mul, abs_neg]
      gcongr
      unfold scoreZ
      split_ifs
      · exact le_trans (abs_sub τ 1) (by simp)
      · rw [sub_zero]; linarith
    have hint2 : Integrable (fun y : ℝ => remK t (y - q)) μ := by
      refine Integrable.of_bound
        (((measurable_remK t).comp (measurable_id.sub measurable_const)).aestronglyMeasurable)
        |t| (Filter.Eventually.of_forall fun y => ?_)
      rw [Real.norm_eq_abs, abs_of_nonneg (knight τ t (y - q)).2.1]
      exact (knight τ t (y - q)).2.2
    rw [hsplit, integral_add hint1 hint2, integral_const_mul, integral_scoreZ_eq_zero h,
      mul_zero, zero_add]
  have h_eq_int : mFun τ μ q t = ∫ s in (0 : ℝ)..t, (distFn μ (q + s) - τ) := by
    rw [h_eq_remK]
    rcases lt_trichotomy 0 t with ht | rfl | ht
    · exact integral_remK_eq_pos h ht
    · simp [remK]
    · exact integral_remK_eq_neg h ht
  have h_nonneg : 0 ≤ mFun τ μ q t := by
    rw [h_eq_remK]
    exact integral_nonneg fun y => (knight τ t (y - q)).2.1
  have h_quad : |t| ≤ L → fl / 2 * t ^ 2 ≤ mFun τ μ q t ∧ mFun τ μ q t ≤ fu / 2 * t ^ 2 := by
    intro htL
    rw [h_eq_int]
    have hFq : distFn μ q = τ := (distFn_quantile_eq h).1
    have hFmono : Monotone (fun s : ℝ => distFn μ (q + s)) :=
      fun _ _ hab => distFn_mono μ (by linarith)
    have hFint : ∀ a b : ℝ, IntervalIntegrable (fun s => distFn μ (q + s) - τ) volume a b := by
      intro a b
      exact hFmono.intervalIntegrable.sub intervalIntegrable_const
    rcases le_total 0 t with ht | ht
    · have htL' : t ≤ L := by rwa [abs_of_nonneg ht] at htL
      have hlo : ∫ s in (0 : ℝ)..t, (fl * s) ≤ ∫ s in (0 : ℝ)..t, (distFn μ (q + s) - τ) := by
        apply intervalIntegral.integral_mono_on ht
        · exact (continuous_const.mul continuous_id).intervalIntegrable _ _
        · exact hFint 0 t
        · intro s ⟨hs0, hst⟩
          have hge : 0 ≤ distFn μ (q + s) - distFn μ q :=
            sub_nonneg.mpr (distFn_mono μ (by linarith))
          have hA := h.assA s (by rw [abs_of_nonneg hs0]; linarith)
          rw [abs_of_nonneg hs0, abs_of_nonneg hge, hFq] at hA
          exact hA
      have hhi : ∫ s in (0 : ℝ)..t, (distFn μ (q + s) - τ) ≤ ∫ s in (0 : ℝ)..t, (fu * s) := by
        apply intervalIntegral.integral_mono_on ht
        · exact hFint 0 t
        · exact (continuous_const.mul continuous_id).intervalIntegrable _ _
        · intro s ⟨hs0, hst⟩
          have hge : 0 ≤ distFn μ (q + s) - distFn μ q :=
            sub_nonneg.mpr (distFn_mono μ (by linarith))
          have hB := h.assB s (by rw [abs_of_nonneg hs0]; linarith)
          rw [abs_of_nonneg hs0, abs_of_nonneg hge, hFq] at hB
          exact hB
      have hlin : ∀ c : ℝ, ∫ s in (0 : ℝ)..t, (c * s) = c / 2 * t ^ 2 := by
        intro c
        rw [intervalIntegral.integral_const_mul, integral_id]
        ring
      rw [hlin fl] at hlo; rw [hlin fu] at hhi
      exact ⟨hlo, hhi⟩
    · have htL' : -t ≤ L := by rwa [abs_of_nonpos ht] at htL
      rw [intervalIntegral.integral_symm, ← intervalIntegral.integral_neg]
      have hlo : ∫ s in t..(0 : ℝ), (fl * (-s)) ≤ ∫ s in t..(0 : ℝ), -(distFn μ (q + s) - τ) := by
        apply intervalIntegral.integral_mono_on ht
        · exact (continuous_const.mul continuous_neg).intervalIntegrable _ _
        · exact (hFint t 0).neg
        · intro s ⟨hts, hs0⟩
          have hle : distFn μ (q + s) - distFn μ q ≤ 0 :=
            sub_nonpos.mpr (distFn_mono μ (by linarith))
          have hA := h.assA s (by rw [abs_of_nonpos hs0]; linarith)
          rw [abs_of_nonpos hs0, abs_of_nonpos hle, hFq] at hA
          linarith
      have hhi : ∫ s in t..(0 : ℝ), -(distFn μ (q + s) - τ) ≤ ∫ s in t..(0 : ℝ), (fu * (-s)) := by
        apply intervalIntegral.integral_mono_on ht
        · exact (hFint t 0).neg
        · exact (continuous_const.mul continuous_neg).intervalIntegrable _ _
        · intro s ⟨hts, hs0⟩
          have hle : distFn μ (q + s) - distFn μ q ≤ 0 :=
            sub_nonpos.mpr (distFn_mono μ (by linarith))
          have hB := h.assB s (by rw [abs_of_nonpos hs0]; linarith)
          rw [abs_of_nonpos hs0, abs_of_nonpos hle, hFq] at hB
          linarith
      have hlin : ∀ c : ℝ, ∫ s in t..(0 : ℝ), (c * (-s)) = c / 2 * t ^ 2 := by
        intro c
        simp_rw [mul_neg]
        rw [intervalIntegral.integral_neg, intervalIntegral.integral_const_mul, integral_id]
        ring
      rw [hlin fl] at hlo; rw [hlin fu] at hhi
      exact ⟨hlo, hhi⟩
  have h_global : mFun τ μ q t ≤ C1 L fu * t ^ 2 := by
    by_cases htL : |t| ≤ L
    · calc mFun τ μ q t ≤ fu / 2 * t ^ 2 := (h_quad htL).2
        _ ≤ C1 L fu * t ^ 2 := by
          apply mul_le_mul_of_nonneg_right (le_max_left _ _) (sq_nonneg t)
    · push Not at htL
      have hle_abs : mFun τ μ q t ≤ |t| := by
        rw [h_eq_remK]
        have hint : Integrable (fun y : ℝ => remK t (y - q)) μ := by
          refine Integrable.of_bound
            (((measurable_remK t).comp (measurable_id.sub measurable_const)).aestronglyMeasurable)
            |t| (Filter.Eventually.of_forall fun y => ?_)
          rw [Real.norm_eq_abs, abs_of_nonneg (knight τ t (y - q)).2.1]
          exact (knight τ t (y - q)).2.2
        calc ∫ y, remK t (y - q) ∂μ ≤ ∫ _y, |t| ∂μ :=
              integral_mono hint (integrable_const _) fun y => (knight τ t (y - q)).2.2
          _ = |t| := by simp
      have hdiv : |t| ≤ 1 / L * t ^ 2 := by
        have h1 : 1 ≤ |t| / L := (one_le_div h.hL).mpr htL.le
        calc |t| = |t| * 1 := (mul_one _).symm
          _ ≤ |t| * (|t| / L) := mul_le_mul_of_nonneg_left h1 (abs_nonneg t)
          _ = 1 / L * t ^ 2 := by rw [← mul_div_assoc, one_div, div_eq_inv_mul, ← sq, sq_abs]
      calc mFun τ μ q t ≤ |t| := hle_abs
        _ ≤ 1 / L * t ^ 2 := hdiv
        _ ≤ C1 L fu * t ^ 2 :=
          mul_le_mul_of_nonneg_right (le_max_right _ _) (sq_nonneg t)
  exact ⟨h_eq_remK, h_eq_int, h_nonneg, h_quad, h_global⟩

private lemma exp_neg_le_one_sub_add_sq {x : ℝ} (hx : 0 ≤ x) :
    Real.exp (-x) ≤ 1 - x + x ^ 2 / 2 := by
  let g : ℝ → ℝ := fun u => 1 - u + u ^ 2 / 2 - Real.exp (-u)
  have hderiv : ∀ u ∈ Set.Ici (0 : ℝ), HasDerivAt g (u - 1 + Real.exp (-u)) u := by
    intro u _
    have h1 : HasDerivAt (fun u : ℝ => 1 - u) (0 - 1) u :=
      (hasDerivAt_const u (1 : ℝ)).sub (hasDerivAt_id u)
    have h2 : HasDerivAt (fun u : ℝ => u ^ 2 / 2) ((2 * u ^ 1) / 2) u := by
      simpa using (hasDerivAt_pow 2 u).div_const 2
    have h3 : HasDerivAt (fun u : ℝ => Real.exp (-u)) (Real.exp (-u) * (-1)) u :=
      (Real.hasDerivAt_exp (-u)).comp u (hasDerivAt_neg u)
    convert (h1.add h2).sub h3 using 1; ring
  have hmono : MonotoneOn g (Set.Ici 0) := by
    apply monotoneOn_of_deriv_nonneg (convex_Ici 0)
    · exact (((continuous_const.sub continuous_id).add
        ((continuous_pow 2).div_const 2)).sub (Real.continuous_exp.comp continuous_neg)).continuousOn
    · intro u hu
      exact (hderiv u (interior_subset hu)).differentiableAt.differentiableWithinAt
    · intro u hu
      rw [(hderiv u (interior_subset hu)).deriv]
      linarith [Real.add_one_le_exp (-u)]
  have h0 : g 0 ≤ g x := hmono (Set.mem_Ici.mpr le_rfl) (Set.mem_Ici.mpr hx) hx
  simp only [g, neg_zero, Real.exp_zero] at h0
  linarith

private lemma integral_remK_sq_pos {μ : Measure ℝ} {τ q L fl fu : ℝ}
    (h : CoordHyp μ τ q L fl fu) {t : ℝ} (ht : 0 < t) :
    ∫ y, remK t (y - q) ^ 2 ∂μ = ∫ s in (0 : ℝ)..t, 2 * (t - s) * (distFn μ (q + s) - τ) := by
  have := h.prob
  let ν : Measure ℝ := volume.restrict (Set.Ioc 0 t)
  have : IsFiniteMeasure ν := ⟨by simp [ν]⟩
  let S : Set (ℝ × ℝ) := {p | q ≤ p.1 ∧ p.1 ≤ q + p.2 ∧ 0 < p.2 ∧ p.2 ≤ t}
  have hS : MeasurableSet S :=
    (measurableSet_le measurable_const measurable_fst).inter
      ((measurableSet_le measurable_fst (measurable_const.add measurable_snd)).inter
        ((measurableSet_lt measurable_const measurable_snd).inter
          (measurableSet_le measurable_snd measurable_const)))
  let f : ℝ → ℝ → ℝ := fun y s => S.indicator (fun p => 2 * (t - p.2)) (y, s)
  have hf_int : Integrable (Function.uncurry f) (μ.prod ν) := by
    refine Integrable.of_bound
      (((measurable_const.mul (measurable_const.sub measurable_snd)).indicator hS).aestronglyMeasurable)
      (2 * t) (Filter.Eventually.of_forall fun p => ?_)
    change ‖S.indicator (fun p : ℝ × ℝ => 2 * (t - p.2)) p‖ ≤ 2 * t
    by_cases hp : p ∈ S
    · rw [Set.indicator_of_mem hp, Real.norm_eq_abs, abs_of_nonneg (by linarith [hp.2.2.2])]
      linarith [hp.2.2.1]
    · rw [Set.indicator_of_notMem hp, norm_zero]
      linarith
  have hinner_y : ∀ y : ℝ, ∫ s, f y s ∂ν = remK t (y - q) ^ 2 := by
    intro y
    have hcongr : ∫ s, f y s ∂ν =
        ∫ s in Set.Ioc 0 t, (if q ≤ y ∧ y ≤ q + s then 2 * (t - s) else 0) := by
      refine setIntegral_congr_fun measurableSet_Ioc (fun s hs => ?_)
      simp only [f, S, Set.indicator, Set.mem_ofPred_eq, hs.1, hs.2, and_true]
    rw [hcongr]
    by_cases hy : q ≤ y
    · have hrew : (fun s : ℝ => if q ≤ y ∧ y ≤ q + s then 2 * (t - s) else 0) =
          (Set.Ici (y - q)).indicator (fun s => 2 * (t - s)) := by
        ext s
        simp only [Set.indicator, Set.mem_Ici, hy, true_and]
        have hiff : y ≤ q + s ↔ y - q ≤ s := ⟨fun h => by linarith, fun h => by linarith⟩
        simp only [hiff]
      rw [hrew, integral_indicator measurableSet_Ici, Measure.restrict_restrict measurableSet_Ici]
      by_cases hyt : y - q < t
      · have hcond : 0 ≤ y - q ∧ y - q < t := ⟨sub_nonneg.mpr hy, hyt⟩
        simp only [remK, ht, hcond, and_self, ↓reduceIte]
        have heq_int : ∫ s in Set.Ici (y - q) ∩ Set.Ioc 0 t, 2 * (t - s) =
            ∫ s in (y - q)..t, 2 * (t - s) := by
          rw [intervalIntegral.integral_of_le hyt.le]
          by_cases hy0 : y - q = 0
          · have hinter : Set.Ici (y - q) ∩ Set.Ioc 0 t = Set.Ioc (y - q) t := by
              rw [hy0]; ext s; simp only [Set.mem_inter_iff, Set.mem_Ici, Set.mem_Ioc]
              exact ⟨fun h => h.2, fun h => ⟨h.1.le, h⟩⟩
            rw [hinter]
          · have hypos : 0 < y - q := lt_of_le_of_ne (sub_nonneg.mpr hy) (Ne.symm hy0)
            have hinter : Set.Ici (y - q) ∩ Set.Ioc 0 t = Set.Icc (y - q) t := by
              ext s; simp only [Set.mem_inter_iff, Set.mem_Ici, Set.mem_Ioc, Set.mem_Icc]
              exact ⟨fun ⟨h1, _, h3⟩ => ⟨h1, h3⟩, fun ⟨h1, h2⟩ => ⟨h1, lt_of_lt_of_le hypos h1, h2⟩⟩
            rw [hinter, integral_Icc_eq_integral_Ioc]
        have hi_id : IntervalIntegrable (fun s : ℝ => s) volume (y - q) t :=
          Continuous.intervalIntegrable (by fun_prop) _ _
        rw [heq_int, intervalIntegral.integral_const_mul,
          intervalIntegral.integral_sub intervalIntegrable_const hi_id,
          intervalIntegral.integral_const, integral_id, smul_eq_mul]
        ring
      · have hnot : ¬(0 ≤ y - q ∧ y - q < t) := by tauto
        simp only [remK, ht, hnot, ↓reduceIte, zero_pow (by norm_num : 2 ≠ 0)]
        have hsub : Set.Ici (y - q) ∩ Set.Ioc 0 t ⊆ {t} := by
          intro s ⟨h1, _, h3⟩
          exact Set.mem_singleton_iff.mpr (le_antisymm h3 (le_trans (not_lt.mp hyt) h1))
        have hzero : volume (Set.Ici (y - q) ∩ Set.Ioc 0 t) = 0 :=
          measure_mono_null hsub (by simp)
        rw [Measure.restrict_eq_zero.mpr hzero, integral_zero_measure]
    · have hzero : (fun s : ℝ => if q ≤ y ∧ y ≤ q + s then 2 * (t - s) else 0) = fun _ => 0 := by
        ext s; simp [hy]
      have hnot : ¬(0 ≤ y - q ∧ y - q < t) := by intro ⟨h1, _⟩; exact hy (by linarith)
      rw [hzero, integral_zero]
      simp only [remK, ht, hnot, ↓reduceIte, zero_pow (by norm_num : 2 ≠ 0)]
  have hinner_s : ∀ s ∈ Set.Ioc 0 t, ∫ y, f y s ∂μ = 2 * (t - s) * (distFn μ (q + s) - τ) := by
    intro s hs
    have hspos : 0 < s := hs.1
    have hrew : (fun y : ℝ => f y s) = (Set.Icc q (q + s)).indicator (fun _ => 2 * (t - s)) := by
      ext y; simp [f, S, Set.indicator, Set.mem_Icc, hs.1, hs.2]
    rw [hrew, integral_indicator_const _ measurableSet_Icc, smul_eq_mul, Measure.real]
    have hunion : Set.Iio q ∪ Set.Icc q (q + s) = Set.Iic (q + s) := by
      ext y; simp only [Set.mem_union, Set.mem_Iio, Set.mem_Icc, Set.mem_Iic]
      constructor
      · rintro (h1 | ⟨_, h2⟩) <;> linarith
      · intro h1; by_cases h2 : y < q; exact Or.inl h2; exact Or.inr ⟨not_lt.mp h2, h1⟩
    have hdisj : Disjoint (Set.Iio q) (Set.Icc q (q + s)) := by
      rw [Set.disjoint_left]; intro y h1 h2; exact not_lt.mpr h2.1 h1
    have hadd : μ (Set.Iic (q + s)) = μ (Set.Iio q) + μ (Set.Icc q (q + s)) := by
      rw [← hunion, measure_union hdisj measurableSet_Icc]
    have htoReal := congrArg ENNReal.toReal hadd
    rw [ENNReal.toReal_add (measure_ne_top μ _) (measure_ne_top μ _),
      (distFn_quantile_eq h).2] at htoReal
    unfold distFn
    nlinarith
  have hswap := MeasureTheory.integral_integral_swap hf_int
  simp_rw [hinner_y] at hswap
  rw [hswap, intervalIntegral.integral_of_le ht.le]
  exact setIntegral_congr_fun measurableSet_Ioc hinner_s

private lemma integral_remK_sq_neg {μ : Measure ℝ} {τ q L fl fu : ℝ}
    (h : CoordHyp μ τ q L fl fu) {t : ℝ} (ht : t < 0) :
    ∫ y, remK t (y - q) ^ 2 ∂μ = ∫ s in t..(0 : ℝ), 2 * (s - t) * (τ - distFn μ (q + s)) := by
  have := h.prob
  let ν : Measure ℝ := volume.restrict (Set.Ioo t 0)
  have : IsFiniteMeasure ν := ⟨by simp [ν]⟩
  let S : Set (ℝ × ℝ) := {p | q + p.2 < p.1 ∧ p.1 < q ∧ t < p.2 ∧ p.2 < 0}
  have hS : MeasurableSet S :=
    (measurableSet_lt (measurable_const.add measurable_snd) measurable_fst).inter
      ((measurableSet_lt measurable_fst measurable_const).inter
        ((measurableSet_lt measurable_const measurable_snd).inter
          (measurableSet_lt measurable_snd measurable_const)))
  let f : ℝ → ℝ → ℝ := fun y s => S.indicator (fun p => 2 * (p.2 - t)) (y, s)
  have hf_int : Integrable (Function.uncurry f) (μ.prod ν) := by
    refine Integrable.of_bound
      (((measurable_const.mul (measurable_snd.sub measurable_const)).indicator hS).aestronglyMeasurable)
      (2 * (-t)) (Filter.Eventually.of_forall fun p => ?_)
    change ‖S.indicator (fun p : ℝ × ℝ => 2 * (p.2 - t)) p‖ ≤ 2 * (-t)
    by_cases hp : p ∈ S
    · rw [Set.indicator_of_mem hp, Real.norm_eq_abs, abs_of_nonneg (by linarith [hp.2.2.1])]
      linarith [hp.2.2.2]
    · rw [Set.indicator_of_notMem hp, norm_zero]
      linarith
  have hnot_pos : ¬(0 < t) := not_lt.mpr ht.le
  have hinner_y : ∀ y : ℝ, ∫ s, f y s ∂ν = remK t (y - q) ^ 2 := by
    intro y
    have hcongr : ∫ s, f y s ∂ν =
        ∫ s in Set.Ioo t 0, (if q + s < y ∧ y < q then 2 * (s - t) else 0) := by
      refine setIntegral_congr_fun measurableSet_Ioo (fun s hs => ?_)
      simp only [f, S, Set.indicator, Set.mem_ofPred_eq, hs.1, hs.2, and_true]
    rw [hcongr]
    by_cases hy : y < q
    · have hrew : (fun s : ℝ => if q + s < y ∧ y < q then 2 * (s - t) else 0) =
          (Set.Iio (y - q)).indicator (fun s => 2 * (s - t)) := by
        ext s
        simp only [Set.indicator, Set.mem_Iio, hy, and_true]
        have hiff : q + s < y ↔ s < y - q := ⟨fun h => by linarith, fun h => by linarith⟩
        simp only [hiff]
      rw [hrew, integral_indicator measurableSet_Iio, Measure.restrict_restrict measurableSet_Iio]
      by_cases hyt : t < y - q
      · have hcond : t < y - q ∧ y - q < 0 := ⟨hyt, sub_neg.mpr hy⟩
        simp only [remK, hnot_pos, ht, hcond, and_self, ↓reduceIte]
        have hinter : Set.Iio (y - q) ∩ Set.Ioo t 0 = Set.Ioo t (y - q) := by
          ext s; simp only [Set.mem_inter_iff, Set.mem_Iio, Set.mem_Ioo]
          exact ⟨fun ⟨h1, h2, _⟩ => ⟨h2, h1⟩, fun ⟨h1, h2⟩ => ⟨h2, h1, lt_trans h2 (sub_neg.mpr hy)⟩⟩
        have hi_id : IntervalIntegrable (fun s : ℝ => s) volume t (y - q) :=
          Continuous.intervalIntegrable (by fun_prop) _ _
        rw [hinter, ← integral_Ioc_eq_integral_Ioo, ← intervalIntegral.integral_of_le hyt.le,
          intervalIntegral.integral_const_mul,
          intervalIntegral.integral_sub hi_id intervalIntegrable_const,
          integral_id, intervalIntegral.integral_const, smul_eq_mul]
        ring
      · have hnot : ¬(t < y - q ∧ y - q < 0) := by tauto
        simp only [remK, hnot_pos, ht, hnot, ↓reduceIte, zero_pow (by norm_num : 2 ≠ 0)]
        have hinter : Set.Iio (y - q) ∩ Set.Ioo t 0 = ∅ := by
          ext s; simp only [Set.mem_inter_iff, Set.mem_Iio, Set.mem_Ioo, Set.mem_empty_iff_false,
            iff_false, not_and]
          intro h1 h2; linarith [not_lt.mp hyt]
        simp [hinter]
    · have hzero : (fun s : ℝ => if q + s < y ∧ y < q then 2 * (s - t) else 0) = fun _ => 0 := by
        ext s; simp [hy]
      have hnot : ¬(t < y - q ∧ y - q < 0) := by intro ⟨_, h2⟩; exact hy (by linarith)
      rw [hzero, integral_zero]
      simp only [remK, hnot_pos, ht, hnot, ↓reduceIte, zero_pow (by norm_num : 2 ≠ 0)]
  have hinner_s : ∀ s ∈ Set.Ioo t 0, ∫ y, f y s ∂μ = 2 * (s - t) * (τ - distFn μ (q + s)) := by
    intro s hs
    have hsneg : s < 0 := hs.2
    have hrew : (fun y : ℝ => f y s) = (Set.Ioo (q + s) q).indicator (fun _ => 2 * (s - t)) := by
      ext y; simp [f, S, Set.indicator, Set.mem_Ioo, hs.1, hs.2]
    rw [hrew, integral_indicator_const _ measurableSet_Ioo, smul_eq_mul, Measure.real]
    have hunion : Set.Iic (q + s) ∪ Set.Ioo (q + s) q = Set.Iio q := by
      ext y; simp only [Set.mem_union, Set.mem_Iic, Set.mem_Ioo, Set.mem_Iio]
      constructor
      · rintro (h1 | ⟨_, h2⟩) <;> linarith
      · intro h1; by_cases h2 : y ≤ q + s; exact Or.inl h2; exact Or.inr ⟨not_le.mp h2, h1⟩
    have hdisj : Disjoint (Set.Iic (q + s)) (Set.Ioo (q + s) q) := by
      rw [Set.disjoint_left]; intro y h1 h2; exact not_lt.mpr h1 h2.1
    have hadd : μ (Set.Iio q) = μ (Set.Iic (q + s)) + μ (Set.Ioo (q + s) q) := by
      rw [← hunion, measure_union hdisj measurableSet_Ioo]
    have htoReal := congrArg ENNReal.toReal hadd
    rw [ENNReal.toReal_add (measure_ne_top μ _) (measure_ne_top μ _),
      (distFn_quantile_eq h).2] at htoReal
    unfold distFn
    nlinarith
  have hswap := MeasureTheory.integral_integral_swap hf_int
  simp_rw [hinner_y] at hswap
  rw [hswap, intervalIntegral.integral_of_le ht.le, integral_Ioc_eq_integral_Ioo]
  exact setIntegral_congr_fun measurableSet_Ioo hinner_s

/-- Lemma `pf:lem:check`(e): `E R(t)² ≤ f̄|t|³/3` for `|t| ≤ L`, and
`E e^{−2R(t)} ≤ e^{−m(t)}` for `|t| ≤ min{L, 3f̲/(4f̄)}`. -/
theorem remK_moments {μ : Measure ℝ} {τ q L fl fu : ℝ} (h : CoordHyp μ τ q L fl fu) (t : ℝ) :
    (|t| ≤ L → ∫ y, remK t (y - q) ^ 2 ∂μ ≤ fu * |t| ^ 3 / 3) ∧
    (|t| ≤ min L (3 * fl / (4 * fu)) →
      ∫ y, Real.exp (-2 * remK t (y - q)) ∂μ ≤ Real.exp (-mFun τ μ q t)) := by
  have := h.prob
  have hsq : |t| ≤ L → ∫ y, remK t (y - q) ^ 2 ∂μ ≤ fu * |t| ^ 3 / 3 := by
    intro htL
    have hFq : distFn μ q = τ := (distFn_quantile_eq h).1
    have hFmono : Monotone (fun s : ℝ => distFn μ (q + s)) :=
      fun _ _ hab => distFn_mono μ (by linarith)
    rcases lt_trichotomy 0 t with ht | rfl | ht
    · rw [integral_remK_sq_pos h ht, abs_of_pos ht]
      have htL' : t ≤ L := by rwa [abs_of_pos ht] at htL
      have hFint : IntervalIntegrable (fun s => 2 * (t - s) * (distFn μ (q + s) - τ)) volume 0 t := by
        have hF : IntervalIntegrable (fun s => distFn μ (q + s) - τ) volume 0 t :=
          hFmono.intervalIntegrable.sub intervalIntegrable_const
        exact hF.continuousOn_mul (continuous_const.mul (continuous_const.sub continuous_id)).continuousOn
      have hle : ∫ s in (0 : ℝ)..t, 2 * (t - s) * (distFn μ (q + s) - τ) ≤
          ∫ s in (0 : ℝ)..t, 2 * (t - s) * (fu * s) := by
        apply intervalIntegral.integral_mono_on ht.le hFint
        · exact ((continuous_const.mul (continuous_const.sub continuous_id)).mul
            (continuous_const.mul continuous_id)).intervalIntegrable _ _
        · intro s ⟨hs0, hst⟩
          have hge : 0 ≤ distFn μ (q + s) - distFn μ q :=
            sub_nonneg.mpr (distFn_mono μ (by linarith))
          have hB := h.assB s (by rw [abs_of_nonneg hs0]; linarith)
          rw [abs_of_nonneg hs0, abs_of_nonneg hge, hFq] at hB
          exact mul_le_mul_of_nonneg_left hB (by linarith)
      have hcalc : ∫ s in (0 : ℝ)..t, 2 * (t - s) * (fu * s) = fu * t ^ 3 / 3 := by
        have hrew : (fun s : ℝ => 2 * (t - s) * (fu * s)) =
            fun s => (2 * fu * t) * s - (2 * fu) * s ^ 2 := by ext s; ring
        have hi1 : IntervalIntegrable (fun s : ℝ => (2 * fu * t) * s) volume 0 t :=
          Continuous.intervalIntegrable (by fun_prop) _ _
        have hi2 : IntervalIntegrable (fun s : ℝ => (2 * fu) * s ^ 2) volume 0 t :=
          Continuous.intervalIntegrable (by fun_prop) _ _
        rw [hrew, intervalIntegral.integral_sub hi1 hi2,
          intervalIntegral.integral_const_mul, intervalIntegral.integral_const_mul,
          integral_id, integral_pow]
        ring
      linarith
    · simp [remK]
    · rw [integral_remK_sq_neg h ht, abs_of_neg ht]
      have htL' : -t ≤ L := by rwa [abs_of_neg ht] at htL
      have hFint : IntervalIntegrable (fun s => 2 * (s - t) * (τ - distFn μ (q + s))) volume t 0 := by
        have hF : IntervalIntegrable (fun s => τ - distFn μ (q + s)) volume t 0 :=
          intervalIntegrable_const.sub hFmono.intervalIntegrable
        exact hF.continuousOn_mul (continuous_const.mul (continuous_id.sub continuous_const)).continuousOn
      have hle : ∫ s in t..(0 : ℝ), 2 * (s - t) * (τ - distFn μ (q + s)) ≤
          ∫ s in t..(0 : ℝ), 2 * (s - t) * (fu * (-s)) := by
        apply intervalIntegral.integral_mono_on ht.le hFint
        · exact ((continuous_const.mul (continuous_id.sub continuous_const)).mul
            (continuous_const.mul continuous_neg)).intervalIntegrable _ _
        · intro s ⟨hts, hs0⟩
          have hle0 : distFn μ (q + s) - distFn μ q ≤ 0 :=
            sub_nonpos.mpr (distFn_mono μ (by linarith))
          have hB := h.assB s (by rw [abs_of_nonpos hs0]; linarith)
          rw [abs_of_nonpos hs0, abs_of_nonpos hle0, hFq] at hB
          exact mul_le_mul_of_nonneg_left (by linarith) (by linarith)
      have hcalc : ∫ s in t..(0 : ℝ), 2 * (s - t) * (fu * (-s)) = fu * (-t) ^ 3 / 3 := by
        have hrew : (fun s : ℝ => 2 * (s - t) * (fu * (-s))) =
            fun s => (2 * fu * t) * s - (2 * fu) * s ^ 2 := by ext s; ring
        have hi1 : IntervalIntegrable (fun s : ℝ => (2 * fu * t) * s) volume t 0 :=
          Continuous.intervalIntegrable (by fun_prop) _ _
        have hi2 : IntervalIntegrable (fun s : ℝ => (2 * fu) * s ^ 2) volume t 0 :=
          Continuous.intervalIntegrable (by fun_prop) _ _
        rw [hrew, intervalIntegral.integral_sub hi1 hi2,
          intervalIntegral.integral_const_mul, intervalIntegral.integral_const_mul,
          integral_id, integral_pow]
        ring
      linarith
  refine ⟨hsq, ?_⟩
  intro ht_min
  have htL : |t| ≤ L := le_trans ht_min (min_le_left _ _)
  have ht_ratio : |t| ≤ 3 * fl / (4 * fu) := le_trans ht_min (min_le_right _ _)
  have hmp := mFun_props h t
  have hm_eq : mFun τ μ q t = ∫ y, remK t (y - q) ∂μ := hmp.1
  have hm_lo : fl / 2 * t ^ 2 ≤ mFun τ μ q t := (hmp.2.2.2.1 htL).1
  have hint_exp : Integrable (fun y : ℝ => Real.exp (-2 * remK t (y - q))) μ := by
    refine Integrable.of_bound
      ((Real.continuous_exp.measurable.comp (measurable_const.mul
        ((measurable_remK t).comp (measurable_id.sub measurable_const)))).aestronglyMeasurable)
      1 (Filter.Eventually.of_forall fun y => ?_)
    rw [Real.norm_eq_abs, abs_of_pos (Real.exp_pos _)]
    exact Real.exp_le_one_iff.mpr (by linarith [(knight τ t (y - q)).2.1])
  have hint_R : Integrable (fun y : ℝ => remK t (y - q)) μ := by
    refine Integrable.of_bound
      (((measurable_remK t).comp (measurable_id.sub measurable_const)).aestronglyMeasurable)
      |t| (Filter.Eventually.of_forall fun y => ?_)
    rw [Real.norm_eq_abs, abs_of_nonneg (knight τ t (y - q)).2.1]
    exact (knight τ t (y - q)).2.2
  have hint_R2 : Integrable (fun y : ℝ => remK t (y - q) ^ 2) μ := by
    refine Integrable.of_bound
      ((((measurable_remK t).comp (measurable_id.sub measurable_const)).pow_const 2).aestronglyMeasurable)
      (|t| ^ 2) (Filter.Eventually.of_forall fun y => ?_)
    rw [Real.norm_eq_abs, abs_of_nonneg (sq_nonneg _)]
    exact sq_le_sq' (by linarith [(knight τ t (y - q)).2.1, abs_nonneg t]) (knight τ t (y - q)).2.2
  have hpt : ∀ y : ℝ, Real.exp (-2 * remK t (y - q)) ≤
      1 - 2 * remK t (y - q) + 2 * remK t (y - q) ^ 2 := by
    intro y
    have h1 := exp_neg_le_one_sub_add_sq (x := 2 * remK t (y - q))
      (mul_nonneg (by norm_num) (knight τ t (y - q)).2.1)
    have harg : -2 * remK t (y - q) = -(2 * remK t (y - q)) := by ring
    rw [harg]
    linarith [h1]
  have hint_sub : Integrable (fun y : ℝ => 1 - 2 * remK t (y - q)) μ :=
    (integrable_const (1 : ℝ)).sub (hint_R.const_mul 2)
  have hint_rhs : Integrable (fun y : ℝ => 1 - 2 * remK t (y - q) + 2 * remK t (y - q) ^ 2) μ :=
    hint_sub.add (hint_R2.const_mul 2)
  have h1 : ∫ y, Real.exp (-2 * remK t (y - q)) ∂μ ≤
      1 - 2 * mFun τ μ q t + 2 * ∫ y, remK t (y - q) ^ 2 ∂μ := by
    calc ∫ y, Real.exp (-2 * remK t (y - q)) ∂μ
        ≤ ∫ y, (1 - 2 * remK t (y - q) + 2 * remK t (y - q) ^ 2) ∂μ :=
          integral_mono hint_exp hint_rhs hpt
      _ = (∫ _y, (1 : ℝ) ∂μ) - 2 * (∫ y, remK t (y - q) ∂μ) +
          2 * (∫ y, remK t (y - q) ^ 2 ∂μ) := by
          rw [integral_add hint_sub (hint_R2.const_mul 2),
            integral_sub (integrable_const (1 : ℝ)) (hint_R.const_mul 2),
            integral_const_mul, integral_const_mul]
      _ = 1 - 2 * mFun τ μ q t + 2 * ∫ y, remK t (y - q) ^ 2 ∂μ := by
          simp [hm_eq]
  have hfu : 0 < fu := h.hfu
  have h2 : 2 * (fu * |t| ^ 3 / 3) ≤ fl / 2 * t ^ 2 := by
    have h3 : 4 * fu * |t| ≤ 3 * fl := by
      have := (le_div_iff₀ (by positivity : (0 : ℝ) < 4 * fu)).mp ht_ratio
      linarith
    have habs3 : |t| ^ 3 = |t| * t ^ 2 := by rw [pow_succ', sq_abs]
    rw [habs3]
    nlinarith [sq_nonneg t]
  have h3 : 1 - mFun τ μ q t ≤ Real.exp (-mFun τ μ q t) := by
    linarith [Real.add_one_le_exp (-mFun τ μ q t)]
  linarith [hsq htL]

end BQTF
