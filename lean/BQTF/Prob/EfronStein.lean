import Mathlib

/-!
# One-sided Efron–Stein inequality for product measures on `Fin n → ℝ`

Boucheron–Lugosi–Massart, *Concentration Inequalities*, Thm 3.1 and its one-sided corollary.

Proof: induction on `n`, splitting off coordinate `0` with `Fin.cons`
(`MeasurableEquiv.piFinSuccAbove _ 0`), the law of total variance on a product
(`evariance_prod_eq`), the one-dimensional identity
`Var h = ∫∫ (h a - h z)₊² dν dν` (`evariance_le_lintegral_posPart_sq`), and pointwise Jensen
for `x ↦ (x₊)²` (`ofReal_posPart_sq_integral_le`).
-/

open MeasureTheory ProbabilityTheory

namespace BQTF.Prob

section General

variable {Ω : Type*} [MeasurableSpace Ω] {ν : Measure Ω} [IsProbabilityMeasure ν]

/-- `∫ (h - c)² = Var h + (E h - c)²`, in `ℝ≥0∞`. -/
lemma lintegral_sq_sub_const {h : Ω → ℝ} (hh : MemLp h 2 ν) (c : ℝ) :
    ∫⁻ z, ENNReal.ofReal ((h z - c) ^ 2) ∂ν =
      evariance h ν + ENNReal.ofReal ((∫ z, h z ∂ν - c) ^ 2) := by
  have hc : MemLp (fun z => h z - c) 2 ν := hh.sub (memLp_const c)
  have hint : Integrable (fun z => (h z - c) ^ 2) ν := hc.integrable_sq
  rw [← ofReal_integral_eq_lintegral_ofReal hint (ae_of_all _ fun _ => sq_nonneg _),
    ← hh.ofReal_variance_eq, ← ENNReal.ofReal_add (variance_nonneg _ _) (sq_nonneg _)]
  congr 1
  have h1 := variance_eq_sub hc
  rw [variance_sub_const hh.aestronglyMeasurable] at h1
  have h2 : ∫ z, (h z - c) ∂ν = ∫ z, h z ∂ν - c := by
    rw [integral_sub (hh.integrable one_le_two) (integrable_const c)]
    simp
  simp only [Pi.pow_apply] at h1
  rw [h2] at h1
  linarith

/-- One-dimensional one-sided identity (only `≤` is needed):
`Var h ≤ ∫∫ ((h a - h z)₊)² dν(z) dν(a)`. -/
lemma evariance_le_lintegral_posPart_sq {h : Ω → ℝ} (hm : Measurable h) (hh : MemLp h 2 ν) :
    evariance h ν ≤
      ∫⁻ a, ∫⁻ z, ENNReal.ofReal ((max (h a - h z) 0) ^ 2) ∂ν ∂ν := by
  set P := ∫⁻ a, ∫⁻ z, ENNReal.ofReal ((max (h a - h z) 0) ^ 2) ∂ν ∂ν with hP
  set E := evariance h ν
  have hswap : ∫⁻ a, ∫⁻ z, ENNReal.ofReal ((max (h z - h a) 0) ^ 2) ∂ν ∂ν = P := by
    rw [hP, lintegral_lintegral_swap]
    exact Measurable.aemeasurable (by fun_prop)
  have hpt : ∀ x : ℝ, ENNReal.ofReal ((max x 0) ^ 2) + ENNReal.ofReal ((max (-x) 0) ^ 2) =
      ENNReal.ofReal (x ^ 2) := by
    intro x
    rw [← ENNReal.ofReal_add (sq_nonneg _) (sq_nonneg _)]
    congr 1
    rcases le_total x 0 with hx | hx
    · rw [max_eq_right hx, max_eq_left (by linarith)]; ring
    · rw [max_eq_left hx, max_eq_right (by linarith)]; ring
  have hsum : P + P = E + E := by
    calc P + P = ∫⁻ a, ∫⁻ z, ENNReal.ofReal ((max (h a - h z) 0) ^ 2) ∂ν ∂ν +
          ∫⁻ a, ∫⁻ z, ENNReal.ofReal ((max (h z - h a) 0) ^ 2) ∂ν ∂ν := by rw [hswap]
      _ = ∫⁻ a, ∫⁻ z, ENNReal.ofReal ((h z - h a) ^ 2) ∂ν ∂ν := by
        rw [← lintegral_add_left (by fun_prop)]
        refine lintegral_congr fun a => ?_
        rw [← lintegral_add_left (by fun_prop)]
        refine lintegral_congr fun z => ?_
        rw [show h z - h a = -(h a - h z) by ring, hpt, neg_sq]
      _ = ∫⁻ a, (E + ENNReal.ofReal ((h a - ∫ z, h z ∂ν) ^ 2)) ∂ν := by
        refine lintegral_congr fun a => ?_
        rw [lintegral_sq_sub_const hh (h a), sub_sq_comm]
      _ = E + E := by
        rw [lintegral_add_left measurable_const, lintegral_const, measure_univ, mul_one,
          ← evariance_eq_lintegral_ofReal h ν]
  by_contra hlt
  rw [not_le] at hlt
  exact (ENNReal.add_lt_add hlt hlt).ne hsum

/-- Jensen for `x ↦ (x₊)²`: `((∫ D)₊)² ≤ ∫ (D₊)²` on a probability space. -/
lemma ofReal_posPart_sq_integral_le {D : Ω → ℝ} (hD : MemLp D 2 ν) :
    ENNReal.ofReal ((max (∫ a, D a ∂ν) 0) ^ 2) ≤
      ∫⁻ a, ENNReal.ofReal ((max (D a) 0) ^ 2) ∂ν := by
  have hφm : AEStronglyMeasurable (fun a => max (D a) 0) ν :=
    (hD.aestronglyMeasurable.aemeasurable.max aemeasurable_const).aestronglyMeasurable
  have hφ : MemLp (fun a => max (D a) 0) 2 ν := by
    refine hD.mono hφm (ae_of_all _ fun a => ?_)
    simp only [Real.norm_eq_abs]
    rcases le_total (D a) 0 with hx | hx
    · rw [max_eq_right hx]; simp
    · rw [max_eq_left hx]
  have h1 : max (∫ a, D a ∂ν) 0 ≤ ∫ a, max (D a) 0 ∂ν :=
    max_le (integral_mono (hD.integrable one_le_two) (hφ.integrable one_le_two)
      fun a => le_max_left _ _) (integral_nonneg fun a => le_max_right _ _)
  have h2 := lintegral_sq_sub_const hφ 0
  simp only [sub_zero] at h2
  rw [h2]
  calc ENNReal.ofReal ((max (∫ a, D a ∂ν) 0) ^ 2)
      ≤ ENNReal.ofReal ((∫ a, max (D a) 0 ∂ν) ^ 2) :=
        ENNReal.ofReal_le_ofReal (pow_le_pow_left₀ (le_max_right _ _) h1 2)
    _ ≤ _ := le_add_self

/-- `evariance` is invariant under a measure-preserving measurable equivalence. -/
lemma evariance_comp_measurePreserving {Ω' : Type*} [MeasurableSpace Ω'] {μ : Measure Ω}
    {μ' : Measure Ω'} {e : Ω ≃ᵐ Ω'} (he : MeasurePreserving e μ μ') (X : Ω' → ℝ) :
    evariance (X ∘ e) μ = evariance X μ' := by
  simp only [evariance, Function.comp_apply, he.integral_comp']
  exact he.lintegral_comp_emb e.measurableEmbedding (fun y => ‖X y - μ'[X]‖ₑ ^ 2)

end General

section Product

variable {β α : Type*} [MeasurableSpace β] [MeasurableSpace α]
  (ν : Measure β) (π : Measure α) [IsProbabilityMeasure ν] [IsProbabilityMeasure π]

/-- Law of total variance on a product: splitting off the first factor. -/
lemma evariance_prod_eq {F : β × α → ℝ} (hFm : Measurable F) (hF : MemLp F 2 (ν.prod π)) :
    evariance F (ν.prod π) =
      ∫⁻ w, evariance (fun a => F (a, w)) ν ∂π + evariance (fun w => ∫ a, F (a, w) ∂ν) π := by
  set M := ∫ p, F p ∂(ν.prod π)
  have hFint : Integrable F (ν.prod π) := hF.integrable one_le_two
  have hM : M = ∫ w, ∫ a, F (a, w) ∂ν ∂π := integral_prod_symm F hFint
  have hgm : Measurable fun w => ∫ a, F (a, w) ∂ν :=
    (hFm.stronglyMeasurable.integral_prod_left').measurable
  have hae : ∀ᵐ w ∂π, MemLp (fun a => F (a, w)) 2 ν := by
    filter_upwards [hF.integrable_sq.prod_left_ae] with w hw
    exact (memLp_two_iff_integrable_sq
      (hFm.comp measurable_prodMk_right : Measurable fun a => F (a, w)).aestronglyMeasurable).2 hw
  calc evariance F (ν.prod π) = ∫⁻ p, ENNReal.ofReal ((F p - M) ^ 2) ∂(ν.prod π) :=
        evariance_eq_lintegral_ofReal _ _
    _ = ∫⁻ w, ∫⁻ a, ENNReal.ofReal ((F (a, w) - M) ^ 2) ∂ν ∂π :=
        lintegral_prod_symm _ (Measurable.aemeasurable (by fun_prop))
    _ = ∫⁻ w, (evariance (fun a => F (a, w)) ν +
          ENNReal.ofReal ((∫ a, F (a, w) ∂ν - M) ^ 2)) ∂π :=
        lintegral_congr_ae (hae.mono fun w hw => lintegral_sq_sub_const hw M)
    _ = ∫⁻ w, evariance (fun a => F (a, w)) ν ∂π +
          ∫⁻ w, ENNReal.ofReal ((∫ a, F (a, w) ∂ν - M) ^ 2) ∂π :=
        lintegral_add_right _ (by fun_prop)
    _ = _ := by rw [evariance_eq_lintegral_ofReal (fun w => ∫ a, F (a, w) ∂ν) π, ← hM]

end Product

section Pi

variable {n : ℕ} (μ : Fin n → Measure ℝ) [∀ i, IsProbabilityMeasure (μ i)]

/-- Resampling one coordinate preserves the product measure (Tonelli form). -/
lemma lintegral_lintegral_update (j : Fin n) {H : (Fin n → ℝ) → ENNReal} (hH : Measurable H) :
    ∫⁻ w, ∫⁻ z, H (Function.update w j z) ∂(μ j) ∂(Measure.pi μ) = ∫⁻ w, H w ∂(Measure.pi μ) := by
  have := lintegral_eq_of_lmarginal_eq (μ := μ) {j} (f := ∫⋯∫⁻_{j}, H ∂μ) (g := H)
    (hH.lmarginal μ) hH ?_
  · simpa [lmarginal_singleton] using this
  ext x
  simp [lmarginal_singleton, Function.update_idem]

/-- Null sets are preserved by resampling one coordinate. -/
lemma ae_ae_update (j : Fin n) {P : (Fin n → ℝ) → Prop} (hP : ∀ᵐ w ∂(Measure.pi μ), P w) :
    ∀ᵐ w ∂(Measure.pi μ), ∀ᵐ z ∂(μ j), P (Function.update w j z) := by
  set N := toMeasurable (Measure.pi μ) {w | ¬ P w}
  have hNm : MeasurableSet N := measurableSet_toMeasurable _ _
  have hN0 : Measure.pi μ N = 0 := by
    rw [measure_toMeasurable]; exact ae_iff.1 hP
  have hH : Measurable (N.indicator (1 : (Fin n → ℝ) → ENNReal)) :=
    measurable_one.indicator hNm
  have key : ∫⁻ w, ∫⁻ z, N.indicator 1 (Function.update w j z) ∂(μ j) ∂(Measure.pi μ) = 0 := by
    rw [lintegral_lintegral_update μ j hH, lintegral_indicator_one hNm, hN0]
  have hinner : Measurable fun w => ∫⁻ z, N.indicator 1 (Function.update w j z) ∂(μ j) :=
    (hH.comp measurable_update').lintegral_prod_right'
  rw [lintegral_eq_zero_iff hinner] at key
  filter_upwards [key] with w hw
  rw [Pi.zero_apply] at hw
  replace hw := (lintegral_eq_zero_iff (f := fun z => N.indicator 1 (Function.update w j z))
    (hH.comp (measurable_update w))).1 hw
  filter_upwards [hw] with z hz
  have : Function.update w j z ∉ N := by
    intro hmem
    simp [Set.indicator_of_mem hmem] at hz
  by_contra hPz
  exact this (subset_toMeasurable _ _ hPz)

end Pi

/-- The main inequality, by induction on the dimension. -/
theorem efronStein_oneSided_aux : ∀ (n : ℕ) (μ : Fin n → Measure ℝ)
    (_ : ∀ i, IsProbabilityMeasure (μ i)) (f : (Fin n → ℝ) → ℝ), Measurable f →
    MemLp f 2 (Measure.pi μ) →
    evariance f (Measure.pi μ) ≤
      ∑ i, ∫⁻ y, ∫⁻ z, ENNReal.ofReal ((max (f y - f (Function.update y i z)) 0) ^ 2)
        ∂(μ i) ∂(Measure.pi μ) := by
  intro n
  induction n with
  | zero =>
    intro μ hμ f hfm hf
    have hf0 : f = fun _ => f 0 := funext fun y => congrArg f (Subsingleton.elim _ _)
    rw [hf0]
    simp [evariance]
  | succ n ih =>
    intro μ hμ f hfm hf
    set ν := μ 0
    set μ' : Fin n → Measure ℝ := fun j => μ j.succ
    set π' := Measure.pi μ'
    set e := MeasurableEquiv.piFinSuccAbove (fun _ : Fin (n + 1) => ℝ) 0
    have hpres : MeasurePreserving e (Measure.pi μ) (ν.prod π') :=
      measurePreserving_piFinSuccAbove μ 0
    have hesymm : ∀ p : ℝ × (Fin n → ℝ), e.symm p = Fin.cons p.1 p.2 := by
      rintro ⟨a, w⟩
      exact Fin.insertNth_zero' a w
    -- transfer of lintegrals through `e`
    have htr : ∀ G : (Fin (n + 1) → ℝ) → ENNReal,
        ∫⁻ y, G y ∂(Measure.pi μ) = ∫⁻ p, G (Fin.cons p.1 p.2) ∂(ν.prod π') := by
      intro G
      rw [← hpres.symm.lintegral_comp_emb e.symm.measurableEmbedding G]
      simp only [hesymm]
    set F : ℝ × (Fin n → ℝ) → ℝ := fun p => f (Fin.cons p.1 p.2)
    have hFe : F = f ∘ e.symm := funext fun p => by simp [F, hesymm]
    have hFm : Measurable F := by rw [hFe]; exact hfm.comp e.symm.measurable
    have hFL2 : MemLp F 2 (ν.prod π') := by rw [hFe]; exact hf.comp_measurePreserving hpres.symm
    have hvar : evariance f (Measure.pi μ) = evariance F (ν.prod π') := by
      rw [← evariance_comp_measurePreserving hpres F, hFe]
      congr 1
      funext y
      simp
    set g : (Fin n → ℝ) → ℝ := fun w => ∫ a, F (a, w) ∂ν
    have hgm : Measurable g := (hFm.stronglyMeasurable.integral_prod_left').measurable
    have hsplit := evariance_prod_eq ν π' hFm hFL2
    have hgL2 : MemLp g 2 π' := by
      refine (evariance_lt_top_iff_memLp hgm.aestronglyMeasurable).1 ?_
      refine lt_of_le_of_lt ?_ hFL2.evariance_lt_top
      rw [hsplit]
      exact le_add_self
    have hae : ∀ᵐ w ∂π', MemLp (fun a => F (a, w)) 2 ν := by
      filter_upwards [hFL2.integrable_sq.prod_left_ae] with w hw
      exact (memLp_two_iff_integrable_sq
        (hFm.comp measurable_prodMk_right : Measurable fun a => F (a, w)).aestronglyMeasurable).2 hw
    -- coordinate 0
    have hA : ∫⁻ w, evariance (fun a => F (a, w)) ν ∂π' ≤
        ∫⁻ y, ∫⁻ z, ENNReal.ofReal ((max (f y - f (Function.update y 0 z)) 0) ^ 2)
          ∂(μ 0) ∂(Measure.pi μ) := by
      rw [htr]
      simp only [Fin.update_cons_zero]
      rw [lintegral_prod_symm _ (Measurable.aemeasurable ?_)]
      · refine lintegral_mono_ae ?_
        filter_upwards [hae] with w hw
        exact evariance_le_lintegral_posPart_sq (hFm.comp measurable_prodMk_right) hw
      · have hm0 : Measurable fun q : (ℝ × (Fin n → ℝ)) × ℝ =>
            ENNReal.ofReal ((max (F q.1 - F (q.2, q.1.2)) 0) ^ 2) := by fun_prop
        exact hm0.lintegral_prod_right'
    -- coordinates `j.succ`
    have hT : ∀ j : Fin n,
        ∫⁻ w, ∫⁻ z, ENNReal.ofReal ((max (g w - g (Function.update w j z)) 0) ^ 2)
          ∂(μ' j) ∂π' ≤
        ∫⁻ y, ∫⁻ z, ENNReal.ofReal ((max (f y - f (Function.update y j.succ z)) 0) ^ 2)
          ∂(μ j.succ) ∂(Measure.pi μ) := by
      intro j
      rw [htr]
      simp only [← Fin.cons_update]
      rw [lintegral_prod_symm _ (Measurable.aemeasurable ?_)]
      · refine lintegral_mono_ae ?_
        filter_upwards [hae, ae_ae_update μ' j hae] with w hw hw'
        have hm1 : Measurable fun q : ℝ × ℝ =>
            ENNReal.ofReal ((max (F (q.1, w) - F (q.1, Function.update w j q.2)) 0) ^ 2) := by
          fun_prop
        rw [lintegral_lintegral_swap hm1.aemeasurable]
        refine lintegral_mono_ae ?_
        filter_upwards [hw'] with z hz
        have hD := ofReal_posPart_sq_integral_le (hw.sub hz)
        simp only [Pi.sub_apply] at hD
        rw [integral_sub (hw.integrable one_le_two) (hz.integrable one_le_two)] at hD
        exact hD
      · have hm2 : Measurable fun q : (ℝ × (Fin n → ℝ)) × ℝ =>
            ENNReal.ofReal ((max (F q.1 - F (q.1.1, Function.update q.1.2 j q.2)) 0) ^ 2) := by
          fun_prop
        exact hm2.lintegral_prod_right'
    rw [Fin.sum_univ_succ, hvar, hsplit]
    exact add_le_add hA ((ih μ' (fun j => hμ j.succ) g hgm hgL2).trans (Finset.sum_le_sum fun j _ => hT j))

theorem efronStein_oneSided {n : ℕ} (μ : Fin n → Measure ℝ) [∀ i, IsProbabilityMeasure (μ i)]
    {f : (Fin n → ℝ) → ℝ} (hfm : Measurable f) (hf : MemLp f 2 (Measure.pi μ)) :
    evariance f (Measure.pi μ) ≤
      ∑ i, ∫⁻ y, ∫⁻ z, ENNReal.ofReal ((max (f y - f (Function.update y i z)) 0) ^ 2)
        ∂(μ i) ∂(Measure.pi μ) :=
  efronStein_oneSided_aux n μ inferInstance f hfm hf

end BQTF.Prob
