import BQTF.Shift.PrekopaLaplace.BrunnMinkowski

/-!
# One-dimensional Prékopa–Leindler

For measurable `f g h : ℝ → ℝ≥0∞` with `f x ^ (1 − t) * g y ^ t ≤ h ((1 − t) x + t y)`,
`(∫⁻ f) ^ (1 − t) * (∫⁻ g) ^ t ≤ ∫⁻ h` (`0 < t < 1`).

Route: a layer-cake formula for `min f 1` over levels in `(0, 1)`, Brunn–Minkowski on level
sets (linear version, both suprema `≥ 1`), normalisation by truncation levels `α ≤ sup f`,
`β ≤ sup g`, weighted AM–GM, and monotone convergence in the truncation level.
-/

open MeasureTheory Set
open scoped ENNReal

noncomputable section

namespace BQTF.PL

/-- Lebesgue measure of `{r ∈ (0,1) : r < v}`. -/
lemma volume_level (v : ℝ≥0∞) :
    volume (Ioo (0 : ℝ) 1 ∩ {r | ENNReal.ofReal r < v}) = min v 1 := by
  by_cases hv : 1 ≤ v
  · have : Ioo (0 : ℝ) 1 ∩ {r | ENNReal.ofReal r < v} = Ioo 0 1 := by
      refine inter_eq_left.2 fun r hr => ?_
      exact lt_of_lt_of_le (ENNReal.ofReal_lt_one.2 hr.2) hv
    rw [this, Real.volume_Ioo, min_eq_right hv]
    simp
  · push Not at hv
    have hvt : v ≠ ∞ := ne_top_of_lt hv
    set w := v.toReal
    have hw : v = ENNReal.ofReal w := (ENNReal.ofReal_toReal hvt).symm
    have hw1 : w < 1 := by
      rw [hw] at hv
      exact ENNReal.ofReal_lt_one.1 hv
    have : Ioo (0 : ℝ) 1 ∩ {r | ENNReal.ofReal r < v} = Ioo 0 w := by
      ext r
      simp only [mem_inter_iff, mem_Ioo, mem_ofPred_eq, hw]
      constructor
      · rintro ⟨⟨h0, _⟩, h⟩
        exact ⟨h0, (ENNReal.ofReal_lt_ofReal_iff'.1 h).1⟩
      · rintro ⟨h0, h⟩
        exact ⟨⟨h0, h.trans hw1⟩, ENNReal.ofReal_lt_ofReal_iff'.2 ⟨h, h0.trans h⟩⟩
    rw [this, Real.volume_Ioo, sub_zero, ← hw, min_eq_left hv.le]

/-- Layer cake for `min f 1`. -/
lemma lintegral_min_one {f : ℝ → ℝ≥0∞} (hf : Measurable f) :
    ∫⁻ x, min (f x) 1 = ∫⁻ r in Ioo (0 : ℝ) 1, volume {x | ENNReal.ofReal r < f x} := by
  let F : ℝ → ℝ → ℝ≥0∞ := fun x r => if ENNReal.ofReal r < f x then 1 else 0
  have hFm : Measurable (Function.uncurry F) := by
    refine Measurable.ite ?_ measurable_const measurable_const
    exact measurableSet_lt (ENNReal.measurable_ofReal.comp measurable_snd)
      (hf.comp measurable_fst)
  have h1 : ∀ x, ∫⁻ r in Ioo (0 : ℝ) 1, F x r = min (f x) 1 := by
    intro x
    have hs : MeasurableSet {r : ℝ | ENNReal.ofReal r < f x} :=
      measurableSet_lt ENNReal.measurable_ofReal measurable_const
    rw [← volume_level, inter_comm, ← Measure.restrict_apply hs, ← lintegral_indicator_one hs]
    refine lintegral_congr fun r => ?_
    simp only [F, Set.indicator_apply, mem_ofPred_eq, Pi.one_apply]
  have h2 : ∀ r, ∫⁻ x, F x r = volume {x | ENNReal.ofReal r < f x} := by
    intro r
    have hs : MeasurableSet {x : ℝ | ENNReal.ofReal r < f x} :=
      measurableSet_lt measurable_const hf
    rw [← lintegral_indicator_one hs]
    refine lintegral_congr fun x => ?_
    simp only [F, Set.indicator_apply, mem_ofPred_eq, Pi.one_apply]
  calc ∫⁻ x, min (f x) 1 = ∫⁻ x, ∫⁻ r in Ioo (0 : ℝ) 1, F x r := lintegral_congr fun x => (h1 x).symm
    _ = ∫⁻ r in Ioo (0 : ℝ) 1, ∫⁻ x, F x r := lintegral_lintegral_swap hFm.aemeasurable
    _ = _ := lintegral_congr fun r => h2 r

lemma measurable_level (φ : ℝ → ℝ≥0∞) :
    Measurable fun r : ℝ => volume {x | ENNReal.ofReal r < φ x} := by
  refine Antitone.measurable fun r r' hrr' => measure_mono fun x hx => ?_
  exact lt_of_le_of_lt (ENNReal.ofReal_le_ofReal hrr') hx

/-- Linear Prékopa–Leindler on `ℝ` (both suprema at least `1`, minimum hypothesis). -/
theorem pl_one_linear {t : ℝ} (ht0 : 0 < t) (ht1 : t < 1) {f g h : ℝ → ℝ≥0∞}
    (hf : Measurable f) (hg : Measurable g) (hh : Measurable h)
    (hfs : ∀ r : ℝ, r < 1 → ∃ x, ENNReal.ofReal r < f x)
    (hgs : ∀ r : ℝ, r < 1 → ∃ x, ENNReal.ofReal r < g x)
    (hfgh : ∀ x y, min (f x) (g y) ≤ h ((1 - t) * x + t * y)) :
    ENNReal.ofReal (1 - t) * (∫⁻ x, min (f x) 1) + ENNReal.ofReal t * ∫⁻ x, min (g x) 1
      ≤ ∫⁻ x, h x := by
  rw [lintegral_min_one hf, lintegral_min_one hg, ← lintegral_const_mul _ (measurable_level f),
    ← lintegral_const_mul _ (measurable_level g),
    ← lintegral_add_left ((measurable_level f).const_mul _)]
  calc _ ≤ ∫⁻ r in Ioo (0 : ℝ) 1, volume {x | ENNReal.ofReal r < h x} := by
        refine setLIntegral_mono (measurable_level h) fun r hr => ?_
        obtain ⟨x₀, hx₀⟩ := hfs r hr.2
        obtain ⟨y₀, hy₀⟩ := hgs r hr.2
        refine bm_one ht0 ht1 (measurableSet_lt measurable_const hf)
          (measurableSet_lt measurable_const hg) ⟨x₀, hx₀⟩ ⟨y₀, hy₀⟩ fun x hx y hy => ?_
        exact lt_of_lt_of_le (lt_min hx hy) (hfgh x y)
    _ = ∫⁻ x, min (h x) 1 := (lintegral_min_one hh).symm
    _ ≤ ∫⁻ x, h x := lintegral_mono fun x => min_le_left _ _

/-- Weighted AM–GM on `ℝ≥0∞`. -/
lemma rpow_mul_rpow_le_add {t : ℝ} (ht0 : 0 < t) (ht1 : t < 1) (a b : ℝ≥0∞) :
    a ^ (1 - t) * b ^ t ≤ ENNReal.ofReal (1 - t) * a + ENNReal.ofReal t * b := by
  have h1t : 0 < 1 - t := by linarith
  by_cases ha : a = ∞
  · rw [ha, ENNReal.mul_top (ENNReal.ofReal_pos.2 h1t).ne', top_add]
    exact le_top
  by_cases hb : b = ∞
  · rw [hb, ENNReal.mul_top (ENNReal.ofReal_pos.2 ht0).ne', add_top]
    exact le_top
  have key := Real.geom_mean_le_arith_mean2_weighted (w₁ := 1 - t) (w₂ := t)
    (p₁ := a.toReal) (p₂ := b.toReal) h1t.le ht0.le ENNReal.toReal_nonneg ENNReal.toReal_nonneg
    (by ring)
  calc a ^ (1 - t) * b ^ t = ENNReal.ofReal (a.toReal ^ (1 - t) * b.toReal ^ t) := by
        rw [ENNReal.ofReal_mul (by positivity),
          ← ENNReal.ofReal_rpow_of_nonneg ENNReal.toReal_nonneg h1t.le,
          ← ENNReal.ofReal_rpow_of_nonneg ENNReal.toReal_nonneg ht0.le,
          ENNReal.ofReal_toReal ha, ENNReal.ofReal_toReal hb]
    _ ≤ ENNReal.ofReal ((1 - t) * a.toReal + t * b.toReal) := ENNReal.ofReal_le_ofReal key
    _ = _ := by
        rw [ENNReal.ofReal_add (by positivity) (by positivity), ENNReal.ofReal_mul h1t.le,
          ENNReal.ofReal_mul ht0.le, ENNReal.ofReal_toReal ha, ENNReal.ofReal_toReal hb]

/-- `min a b ≤ a ^ (1 − t) b ^ t`. -/
lemma min_le_rpow_mul_rpow {t : ℝ} (ht0 : 0 ≤ t) (ht1 : t ≤ 1) (a b : ℝ≥0∞) :
    min a b ≤ a ^ (1 - t) * b ^ t := by
  have h1t : 0 ≤ 1 - t := by linarith
  calc min a b = (min a b) ^ ((1 - t) + t) := by simp
    _ = (min a b) ^ (1 - t) * (min a b) ^ t := ENNReal.rpow_add_of_nonneg _ _ h1t ht0
    _ ≤ a ^ (1 - t) * b ^ t := by
        gcongr
        · exact min_le_left _ _
        · exact min_le_right _ _

/-- Scaling identity for the geometric mean. -/
lemma scale_rpow {t : ℝ} (ht0 : 0 ≤ t) (ht1 : t ≤ 1) {α β : ℝ≥0∞}
    (hα0 : α ^ (1 - t) ≠ 0) (hαt : α ^ (1 - t) ≠ ∞) (u v : ℝ≥0∞) :
    (α⁻¹ * u) ^ (1 - t) * (β⁻¹ * v) ^ t = (α ^ (1 - t) * β ^ t)⁻¹ * (u ^ (1 - t) * v ^ t) := by
  have h1t : 0 ≤ 1 - t := by linarith
  rw [ENNReal.mul_rpow_of_nonneg _ _ h1t, ENNReal.mul_rpow_of_nonneg _ _ ht0, ENNReal.inv_rpow,
    ENNReal.inv_rpow, ENNReal.mul_inv (Or.inl hα0) (Or.inl hαt)]
  ring

/-- Truncated Prékopa–Leindler on `ℝ`. -/
theorem pl_one_trunc {t : ℝ} (ht0 : 0 < t) (ht1 : t < 1) {f g h : ℝ → ℝ≥0∞}
    (hf : Measurable f) (hg : Measurable g) (hh : Measurable h)
    (hfgh : ∀ x y, f x ^ (1 - t) * g y ^ t ≤ h ((1 - t) * x + t * y))
    {α β : ℝ≥0∞} (hα0 : α ≠ 0) (hαt : α ≠ ∞) (hβ0 : β ≠ 0) (hβt : β ≠ ∞)
    (hαf : α ≤ ⨆ x, f x) (hβg : β ≤ ⨆ x, g x) :
    (∫⁻ x, min (f x) α) ^ (1 - t) * (∫⁻ x, min (g x) β) ^ t ≤ ∫⁻ x, h x := by
  have h1t : 0 < 1 - t := by linarith
  have hαp0 : α ^ (1 - t) ≠ 0 := (ENNReal.rpow_pos (pos_iff_ne_zero.2 hα0) hαt).ne'
  have hαpt : α ^ (1 - t) ≠ ∞ := ENNReal.rpow_ne_top_of_nonneg h1t.le hαt
  set γ := α ^ (1 - t) * β ^ t with hγ
  have hγ0 : γ ≠ 0 := mul_ne_zero hαp0 (ENNReal.rpow_pos (pos_iff_ne_zero.2 hβ0) hβt).ne'
  have hγt : γ ≠ ∞ := ENNReal.mul_ne_top hαpt (ENNReal.rpow_ne_top_of_nonneg ht0.le hβt)
  have hsup : ∀ {φ : ℝ → ℝ≥0∞} {c : ℝ≥0∞}, c ≠ 0 → c ≠ ∞ → c ≤ ⨆ x, φ x →
      ∀ r : ℝ, r < 1 → ∃ x, ENNReal.ofReal r < c⁻¹ * φ x := by
    intro φ c hc0 hct hcφ r hr
    have : ENNReal.ofReal r * c < ⨆ x, φ x := by
      refine lt_of_lt_of_le ?_ hcφ
      simpa using ENNReal.mul_lt_mul_left hc0 hct (ENNReal.ofReal_lt_one.2 hr)
    obtain ⟨x, hx⟩ := lt_iSup_iff.1 this
    refine ⟨x, ?_⟩
    rw [mul_comm, ← div_eq_mul_inv, ENNReal.lt_div_iff_mul_lt (Or.inl hc0) (Or.inl hct)]
    exact hx
  have hmin : ∀ (φ : ℝ → ℝ≥0∞) {c : ℝ≥0∞}, c ≠ 0 → c ≠ ∞ →
      ∀ x, min (c⁻¹ * φ x) 1 = c⁻¹ * min (φ x) c := by
    intro φ c hc0 hct x
    have hmono : Monotone fun a : ℝ≥0∞ => c⁻¹ * a := fun a b hab => mul_le_mul_right hab _
    rw [hmono.map_min, ENNReal.inv_mul_cancel hc0 hct]
  have lin := pl_one_linear ht0 ht1 (f := fun x => α⁻¹ * f x) (g := fun x => β⁻¹ * g x)
    (h := fun x => γ⁻¹ * h x) (hf.const_mul _) (hg.const_mul _) (hh.const_mul _)
    (hsup hα0 hαt hαf) (hsup hβ0 hβt hβg) (by
      intro x y
      calc min (α⁻¹ * f x) (β⁻¹ * g y)
          ≤ (α⁻¹ * f x) ^ (1 - t) * (β⁻¹ * g y) ^ t := min_le_rpow_mul_rpow ht0.le ht1.le _ _
        _ = γ⁻¹ * (f x ^ (1 - t) * g y ^ t) := scale_rpow ht0.le ht1.le hαp0 hαpt _ _
        _ ≤ γ⁻¹ * h ((1 - t) * x + t * y) := by gcongr; exact hfgh x y)
  simp only [hmin f hα0 hαt, hmin g hβ0 hβt] at lin
  rw [lintegral_const_mul _ (hf.min measurable_const), lintegral_const_mul _
    (hg.min measurable_const), lintegral_const_mul _ hh] at lin
  have amgm := rpow_mul_rpow_le_add ht0 ht1 (α⁻¹ * ∫⁻ x, min (f x) α)
    (β⁻¹ * ∫⁻ x, min (g x) β)
  rw [scale_rpow ht0.le ht1.le hαp0 hαpt] at amgm
  have := amgm.trans lin
  exact (ENNReal.mul_le_mul_iff_right (ENNReal.inv_ne_zero.2 hγt)
    (ENNReal.inv_ne_top.2 hγ0)).1 this

/-- Monotone convergence for truncations at `n + 1`. -/
lemma iSup_lintegral_min_nat {φ : ℝ → ℝ≥0∞} (hφ : Measurable φ) :
    ⨆ n : ℕ, ∫⁻ x, min (φ x) ((n + 1 : ℕ) : ℝ≥0∞) = ∫⁻ x, φ x := by
  rw [← lintegral_iSup (fun n => hφ.min measurable_const)]
  · refine lintegral_congr fun x => ?_
    apply le_antisymm (iSup_le fun n => min_le_left _ _)
    by_cases hx : φ x = ∞
    · rw [hx]
      refine (ENNReal.iSup_natCast).symm.le.trans (iSup_mono fun n => ?_)
      simp
    · obtain ⟨n, hn⟩ := ENNReal.exists_nat_gt hx
      refine le_iSup_of_le n (le_min le_rfl (hn.le.trans ?_))
      exact_mod_cast Nat.le_succ n
  · intro m n hmn x
    refine min_le_min le_rfl ?_
    exact_mod_cast Nat.succ_le_succ hmn

/-- **Prékopa–Leindler on `ℝ`.** -/
theorem pl_one {t : ℝ} (ht0 : 0 < t) (ht1 : t < 1) {f g h : ℝ → ℝ≥0∞}
    (hf : Measurable f) (hg : Measurable g) (hh : Measurable h)
    (hfgh : ∀ x y, f x ^ (1 - t) * g y ^ t ≤ h ((1 - t) * x + t * y)) :
    (∫⁻ x, f x) ^ (1 - t) * (∫⁻ x, g x) ^ t ≤ ∫⁻ x, h x := by
  have h1t : 0 < 1 - t := by linarith
  have zero_case : ∀ {φ : ℝ → ℝ≥0∞}, (⨆ x, φ x) = 0 → ∫⁻ x, φ x = 0 := by
    intro φ hφ
    have : ∀ x, φ x = 0 := fun x => le_antisymm ((le_iSup φ x).trans hφ.le) zero_le
    simp [this]
  rcases eq_zero_or_pos (⨆ x, f x) with hSf | hSf
  · rw [zero_case hSf, ENNReal.zero_rpow_of_pos h1t, zero_mul]
    exact zero_le
  rcases eq_zero_or_pos (⨆ x, g x) with hSg | hSg
  · rw [zero_case hSg, ENNReal.zero_rpow_of_pos ht0, mul_zero]
    exact zero_le
  set N : ℕ → ℝ≥0∞ := fun n => ((n + 1 : ℕ) : ℝ≥0∞) with hN
  have hN0 : ∀ n, N n ≠ 0 := fun n => by simp [N]
  have hNt : ∀ n, N n ≠ ∞ := fun n => ENNReal.natCast_ne_top _
  have key : ∀ n, (∫⁻ x, min (f x) (N n)) ^ (1 - t) * (∫⁻ x, min (g x) (N n)) ^ t
      ≤ ∫⁻ x, h x := by
    intro n
    have := pl_one_trunc ht0 ht1 hf hg hh hfgh (α := min (N n) (⨆ x, f x))
      (β := min (N n) (⨆ x, g x)) (lt_min (pos_iff_ne_zero.2 (hN0 n)) hSf).ne'
      (ne_top_of_le_ne_top (hNt n) (min_le_left _ _)) (lt_min (pos_iff_ne_zero.2 (hN0 n)) hSg).ne'
      (ne_top_of_le_ne_top (hNt n) (min_le_left _ _)) (min_le_right _ _) (min_le_right _ _)
    have e : ∀ (φ : ℝ → ℝ≥0∞) x, min (φ x) (min (N n) (⨆ x, φ x)) = min (φ x) (N n) := by
      intro φ x
      rw [min_comm (N n), ← min_assoc, min_eq_left (le_iSup φ x)]
    simpa only [e] using this
  have hmono : ∀ {φ : ℝ → ℝ≥0∞}, Monotone fun n => ∫⁻ x, min (φ x) (N n) := by
    intro φ m n hmn
    refine lintegral_mono fun x => min_le_min le_rfl ?_
    simp only [N]
    exact_mod_cast Nat.succ_le_succ hmn
  have hlimf : ⨆ n, ∫⁻ x, min (f x) (N n) = ∫⁻ x, f x := iSup_lintegral_min_nat hf
  have hlimg : ⨆ n, ∫⁻ x, min (g x) (N n) = ∫⁻ x, g x := iSup_lintegral_min_nat hg
  have hA := (ENNReal.orderIsoRpow (1 - t) h1t).map_iSup fun n => ∫⁻ x, min (f x) (N n)
  have hB := (ENNReal.orderIsoRpow t ht0).map_iSup fun n => ∫⁻ x, min (g x) (N n)
  simp only [ENNReal.orderIsoRpow_apply] at hA hB
  rw [← hlimf, ← hlimg, hA, hB, ENNReal.iSup_mul]
  refine iSup_le fun i => ?_
  rw [ENNReal.mul_iSup]
  refine iSup_le fun j => ?_
  calc (∫⁻ x, min (f x) (N i)) ^ (1 - t) * (∫⁻ x, min (g x) (N j)) ^ t
      ≤ (∫⁻ x, min (f x) (N (max i j))) ^ (1 - t) * (∫⁻ x, min (g x) (N (max i j))) ^ t := by
        exact mul_le_mul' (ENNReal.rpow_le_rpow (hmono (φ := f) (le_max_left i j)) h1t.le)
          (ENNReal.rpow_le_rpow (hmono (φ := g) (le_max_right i j)) ht0.le)
    _ ≤ ∫⁻ x, h x := key _

end BQTF.PL
