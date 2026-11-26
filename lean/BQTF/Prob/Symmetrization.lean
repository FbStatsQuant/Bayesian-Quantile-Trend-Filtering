import BQTF.Basic

/-!
# Symmetrization for finite empirical processes (van der Vaart & Wellner, Lemma 2.3.6)

Owner: Neon-B.

Provides basic facts about `rademacher1` / `rademacher n` and the absolute-value symmetrization
inequality for finite index sets on `Measure.pi μ`:
`E_y sup_{t ∈ T} |∑_i (φ_i(t, y_i) − E φ_i(t, y_i))| ≤ 2 E_y E_ξ sup_{t ∈ T} |∑_i ξ_i φ_i(t, y_i)|`.
-/

open MeasureTheory ProbabilityTheory Finset
open scoped ENNReal

noncomputable section

namespace BQTF.Prob

/-! ### Rademacher measure properties -/

instance isProbabilityMeasure_rademacher1 : IsProbabilityMeasure rademacher1 := by
  constructor
  simp only [rademacher1, Measure.coe_smul, Measure.coe_add, Pi.smul_apply, Pi.add_apply,
    Measure.dirac_apply_of_mem (Set.mem_univ _), smul_eq_mul, one_div]
  rw [← mul_two, one_mul, ENNReal.inv_mul_cancel (by norm_num) (by norm_num)]

instance isProbabilityMeasure_rademacher (n : ℕ) : IsProbabilityMeasure (rademacher n) := by
  unfold rademacher
  infer_instance

lemma ae_rademacher1_eq_neg_one_or_one :
    ∀ᵐ x ∂rademacher1, x = -1 ∨ x = 1 := by
  rw [ae_iff]
  unfold rademacher1
  simp

lemma ae_rademacher_eq_neg_one_or_one (n : ℕ) :
    ∀ᵐ ξ ∂(rademacher n), ∀ i : Fin n, ξ i = -1 ∨ ξ i = 1 := by
  rw [ae_all_iff]
  intro i
  have hmp : MeasurePreserving (Function.eval i) (rademacher n) rademacher1 :=
    measurePreserving_eval (fun _ : Fin n => rademacher1) i
  exact hmp.quasiMeasurePreserving.ae ae_rademacher1_eq_neg_one_or_one

/-! ### Coordinatewise swap invariance on `(Measure.pi μ).prod (Measure.pi μ)` -/

private lemma measurePreserving_swap_12 {α β γ : Type*}
    [MeasurableSpace α] [MeasurableSpace β] [MeasurableSpace γ]
    (νa : Measure α) (νb : Measure β) (νc : Measure γ)
    [SFinite νa] [SFinite νb] [SFinite νc] :
    MeasurePreserving (fun p : α × β × γ => (p.2.1, p.1, p.2.2))
      (νa.prod (νb.prod νc)) (νb.prod (νa.prod νc)) := by
  have h1 := (measurePreserving_prodAssoc νa νb νc).symm MeasurableEquiv.prodAssoc
  have h2 : MeasurePreserving (Prod.map Prod.swap id)
      ((νa.prod νb).prod νc) ((νb.prod νa).prod νc) :=
    MeasurePreserving.prod Measure.measurePreserving_swap (MeasurePreserving.id _)
  have h3 := measurePreserving_prodAssoc νb νa νc
  have hcomp := h3.comp (h2.comp h1)
  have hfun : (⇑MeasurableEquiv.prodAssoc ∘ Prod.map Prod.swap id ∘
      ⇑MeasurableEquiv.prodAssoc.symm) =
      fun p : α × β × γ => (p.2.1, p.1, p.2.2) := by
    ext ⟨a, b, c⟩ <;> rfl
  rwa [hfun] at hcomp

private def swapCoord {n : ℕ} (k : Fin n)
    (p : (Fin n → ℝ) × (Fin n → ℝ)) : (Fin n → ℝ) × (Fin n → ℝ) :=
  (Function.update p.1 k (p.2 k), Function.update p.2 k (p.1 k))

private lemma measurePreserving_swapCoord {n : ℕ}
    (μ : Fin n → Measure ℝ) [∀ i, IsProbabilityMeasure (μ i)] (k : Fin n) :
    MeasurePreserving (swapCoord k) ((Measure.pi μ).prod (Measure.pi μ))
      ((Measure.pi μ).prod (Measure.pi μ)) := by
  cases n with
  | zero => exact Fin.elim0 k
  | succ m =>
    let e : (Fin (m + 1) → ℝ) ≃ᵐ ℝ × (Fin m → ℝ) :=
      MeasurableEquiv.piFinSuccAbove (fun _ => ℝ) k
    have he : MeasurePreserving e (Measure.pi μ)
        ((μ k).prod (Measure.pi (fun j : Fin m => μ (k.succAbove j)))) :=
      measurePreserving_piFinSuccAbove μ k
    let ν1 := μ k
    let ν2 := Measure.pi (fun j : Fin m => μ (k.succAbove j))
    let mid : (ℝ × (Fin m → ℝ)) × (ℝ × (Fin m → ℝ)) → (ℝ × (Fin m → ℝ)) × (ℝ × (Fin m → ℝ)) :=
      fun q => ((q.2.1, q.1.2), (q.1.1, q.2.2))
    have hmid : MeasurePreserving mid ((ν1.prod ν2).prod (ν1.prod ν2))
        ((ν1.prod ν2).prod (ν1.prod ν2)) := by
      have ha1 := measurePreserving_prodAssoc ν1 ν2 (ν1.prod ν2)
      have hs1 : MeasurePreserving (Prod.map id (fun p : (Fin m → ℝ) × ℝ × (Fin m → ℝ) =>
            (p.2.1, p.1, p.2.2)))
          (ν1.prod (ν2.prod (ν1.prod ν2))) (ν1.prod (ν1.prod (ν2.prod ν2))) :=
        MeasurePreserving.prod (MeasurePreserving.id _) (measurePreserving_swap_12 ν2 ν1 ν2)
      have hs2 := measurePreserving_swap_12 ν1 ν1 (ν2.prod ν2)
      have hs3 : MeasurePreserving (Prod.map id (fun p : ℝ × (Fin m → ℝ) × (Fin m → ℝ) =>
            (p.2.1, p.1, p.2.2)))
          (ν1.prod (ν1.prod (ν2.prod ν2))) (ν1.prod (ν2.prod (ν1.prod ν2))) :=
        MeasurePreserving.prod (MeasurePreserving.id _) (measurePreserving_swap_12 ν1 ν2 ν2)
      have ha2 := (measurePreserving_prodAssoc ν1 ν2 (ν1.prod ν2)).symm MeasurableEquiv.prodAssoc
      have hcomp := ha2.comp (hs3.comp (hs2.comp (hs1.comp ha1)))
      have hfun : (⇑MeasurableEquiv.prodAssoc.symm ∘
          Prod.map id (fun p : ℝ × (Fin m → ℝ) × (Fin m → ℝ) => (p.2.1, p.1, p.2.2)) ∘
          (fun p : ℝ × ℝ × (Fin m → ℝ) × (Fin m → ℝ) => (p.2.1, p.1, p.2.2)) ∘
          Prod.map id (fun p : (Fin m → ℝ) × ℝ × (Fin m → ℝ) => (p.2.1, p.1, p.2.2)) ∘
          ⇑MeasurableEquiv.prodAssoc) = mid := by
        ext ⟨⟨a, u⟩, ⟨b, v⟩⟩ <;> rfl
      rwa [hfun] at hcomp
    have hfull := ((he.symm e).prod (he.symm e)).comp (hmid.comp (he.prod he))
    have hEq : (Prod.map (⇑e.symm) (⇑e.symm) ∘ mid ∘ Prod.map (⇑e) (⇑e)) = swapCoord k := by
      ext ⟨y, y'⟩ i
      · simp only [Function.comp_apply, Prod.map_apply, mid, swapCoord, e,
          MeasurableEquiv.piFinSuccAbove_apply, MeasurableEquiv.piFinSuccAbove_symm_apply]
        by_cases hik : i = k
        · subst hik; simp [Fin.insertNth_apply_same]
        · obtain ⟨j, rfl⟩ := Fin.exists_succAbove_eq hik
          simp [Fin.insertNth_apply_succAbove, hik, Fin.removeNth_apply]
      · simp only [Function.comp_apply, Prod.map_apply, mid, swapCoord, e,
          MeasurableEquiv.piFinSuccAbove_apply, MeasurableEquiv.piFinSuccAbove_symm_apply]
        by_cases hik : i = k
        · subst hik; simp [Fin.insertNth_apply_same]
        · obtain ⟨j, rfl⟩ := Fin.exists_succAbove_eq hik
          simp [Fin.insertNth_apply_succAbove, hik, Fin.removeNth_apply]
    rwa [hEq] at hfull

private def swapSet {n : ℕ} (s : Finset (Fin n))
    (p : (Fin n → ℝ) × (Fin n → ℝ)) : (Fin n → ℝ) × (Fin n → ℝ) :=
  (fun i => if i ∈ s then p.2 i else p.1 i, fun i => if i ∈ s then p.1 i else p.2 i)

private lemma measurePreserving_swapSet {n : ℕ}
    (μ : Fin n → Measure ℝ) [∀ i, IsProbabilityMeasure (μ i)] (s : Finset (Fin n)) :
    MeasurePreserving (swapSet s) ((Measure.pi μ).prod (Measure.pi μ))
      ((Measure.pi μ).prod (Measure.pi μ)) := by
  classical
  induction s using Finset.induction_on with
  | empty =>
    have h : swapSet (∅ : Finset (Fin n)) = id := by
      ext ⟨y, y'⟩ i <;> simp [swapSet]
    rw [h]
    exact MeasurePreserving.id _
  | @insert k s hk ih =>
    have hcomp : swapSet (insert k s) = swapCoord k ∘ swapSet s := by
      ext ⟨y, y'⟩ i <;>
      · simp only [Function.comp_apply, swapSet, swapCoord, Finset.mem_insert]
        by_cases hik : i = k
        · subst hik; simp [hk]
        · simp [hik]
    rw [hcomp]
    exact (measurePreserving_swapCoord μ k).comp ih

/-! ### Symmetrization theorem -/

private lemma integral_pi_eval_prob {n : ℕ} (μ : Fin n → Measure ℝ)
    [∀ i, IsProbabilityMeasure (μ i)] (i : Fin n) (g : ℝ → ℝ) :
    ∫ y, g (y i) ∂(Measure.pi μ) = ∫ x, g x ∂(μ i) := by
  let f : Fin n → ℝ → ℝ := fun m x => if m = i then g x else 1
  have hrew : (fun y : Fin n → ℝ => g (y i)) = fun y => ∏ m : Fin n, f m (y m) := by
    ext y; simp [f]
  rw [hrew, MeasureTheory.integral_fintype_prod_eq_prod]
  have hprod : ∀ m : Fin n,
      (∫ x, f m x ∂(μ m)) = if m = i then ∫ x, g x ∂(μ i) else 1 := by
    intro m
    by_cases hm : m = i
    · subst hm; simp [f]
    · simp [f, hm]
  simp_rw [hprod]
  simp

private lemma measurable_finset_sup' {α β : Type*} [MeasurableSpace α]
    (T : Finset β) (hT : T.Nonempty) {f : β → α → ℝ} (hf : ∀ t ∈ T, Measurable (f t)) :
    Measurable (fun x => T.sup' hT fun t => f t x) := by
  classical
  induction hT using Finset.Nonempty.cons_induction with
  | singleton a =>
    simpa using hf a (Finset.mem_singleton_self a)
  | cons a s ha hs ih =>
    have hrew : (fun x => (s.cons a ha).sup' (Finset.cons_nonempty ha) fun t => f t x) =
        fun x => max (f a x) (s.sup' hs fun t => f t x) := by
      ext x
      rw [Finset.sup'_cons]
    rw [hrew]
    exact (hf a (Finset.mem_cons_self a s)).max
      (ih fun t ht => hf t (Finset.mem_cons_of_mem ht))

/-- **Symmetrization for finite empirical processes (absolute-value form; vdV–W Lemma 2.3.6).**
For independent coordinates `y_i ∼ μ_i`, a finite nonempty index set `T`, and uniformly bounded
measurable functions `φ i t : ℝ → ℝ`,
`E_y sup_{t ∈ T} |∑_i (φ_i(t, y_i) − E φ_i(t, y_i))| ≤ 2 E_y E_ξ sup_{t ∈ T} |∑_i ξ_i φ_i(t, y_i)|`. -/
theorem symmetrization_finset {n : ℕ} {α : Type*}
    (μ : Fin n → Measure ℝ) [∀ i, IsProbabilityMeasure (μ i)]
    (T : Finset α) (hT : T.Nonempty)
    (φ : Fin n → α → ℝ → ℝ)
    (hmeas : ∀ i t, Measurable (φ i t))
    (M : ℝ) (hbound : ∀ i t x, |φ i t x| ≤ M) :
    ∫ y, (T.sup' hT fun t => |∑ i, (φ i t (y i) - ∫ x, φ i t x ∂(μ i))|) ∂(Measure.pi μ) ≤
      2 * ∫ y, (∫ ξ, (T.sup' hT fun t => |∑ i, ξ i * φ i t (y i)|) ∂(rademacher n))
        ∂(Measure.pi μ) := by
  classical
  let P := Measure.pi μ
  let R := rademacher n
  let m : Fin n → α → ℝ := fun i t => ∫ x, φ i t x ∂(μ i)
  have hm_bound : ∀ i t, |m i t| ≤ M := fun i t => by
    calc |∫ x, φ i t x ∂(μ i)|
        ≤ ∫ x, |φ i t x| ∂(μ i) := abs_integral_le_integral_abs
      _ ≤ ∫ _x, M ∂(μ i) := integral_mono
          (Integrable.of_bound ((hmeas i t).abs.aestronglyMeasurable) M
            (Filter.Eventually.of_forall fun x => by rw [Real.norm_eq_abs, abs_abs]; exact hbound i t x))
          (integrable_const M) (fun x => hbound i t x)
      _ = M := by simp
  -- Step 1: Jensen — replace `m i t` by an independent copy `y'`
  let G : (Fin n → ℝ) × (Fin n → ℝ) → ℝ :=
    fun p => T.sup' hT fun t => |∑ i, (φ i t (p.1 i) - φ i t (p.2 i))|
  have hG_meas : Measurable G := by
    refine measurable_finset_sup' T hT fun t _ => ?_
    refine (Finset.measurable_sum _ fun i _ => ?_).abs
    exact ((hmeas i t).comp ((measurable_pi_apply i).comp measurable_fst)).sub
      ((hmeas i t).comp ((measurable_pi_apply i).comp measurable_snd))
  have hG_bound : ∀ p, |G p| ≤ 2 * (n : ℝ) * M := fun p => by
    have hnn : 0 ≤ G p := le_trans (abs_nonneg _) (Finset.le_sup' (f := fun t =>
      |∑ i, (φ i t (p.1 i) - φ i t (p.2 i))|) hT.choose_spec)
    rw [abs_of_nonneg hnn]
    refine Finset.sup'_le hT _ fun t _ => ?_
    calc |∑ i, (φ i t (p.1 i) - φ i t (p.2 i))|
        ≤ ∑ i : Fin n, |φ i t (p.1 i) - φ i t (p.2 i)| := Finset.abs_sum_le_sum_abs _ _
      _ ≤ ∑ _i : Fin n, (2 * M) := Finset.sum_le_sum fun i _ => by
          calc |φ i t (p.1 i) - φ i t (p.2 i)|
              ≤ |φ i t (p.1 i)| + |φ i t (p.2 i)| := abs_sub _ _
            _ ≤ M + M := add_le_add (hbound i t _) (hbound i t _)
            _ = 2 * M := by ring
      _ = 2 * (n : ℝ) * M := by simp; ring
  have hG_int : Integrable G (P.prod P) :=
    Integrable.of_bound hG_meas.aestronglyMeasurable (2 * (n : ℝ) * M)
      (Filter.Eventually.of_forall fun p => by rw [Real.norm_eq_abs]; exact hG_bound p)
  have hjensen_pt : ∀ y : Fin n → ℝ,
      (T.sup' hT fun t => |∑ i, (φ i t (y i) - m i t)|) ≤ ∫ y', G (y, y') ∂P := by
    intro y
    refine Finset.sup'_le hT _ fun t ht => ?_
    have hint_diff : ∀ i : Fin n, Integrable (fun y' : Fin n → ℝ => φ i t (y i) - φ i t (y' i)) P :=
      fun i => Integrable.of_bound
        ((measurable_const.sub ((hmeas i t).comp (measurable_pi_apply i))).aestronglyMeasurable)
        (2 * M) (Filter.Eventually.of_forall fun y' => by
          rw [Real.norm_eq_abs]
          calc |φ i t (y i) - φ i t (y' i)| ≤ |φ i t (y i)| + |φ i t (y' i)| := abs_sub _ _
            _ ≤ 2 * M := by linarith [hbound i t (y i), hbound i t (y' i)])
    have heq_int : ∑ i, (φ i t (y i) - m i t) =
        ∫ y', (∑ i, (φ i t (y i) - φ i t (y' i))) ∂P := by
      rw [integral_finsetSum _ fun i _ => hint_diff i]
      refine Finset.sum_congr rfl fun i _ => ?_
      have hint_i : Integrable (fun y' : Fin n → ℝ => φ i t (y' i)) P :=
        Integrable.of_bound (((hmeas i t).comp (measurable_pi_apply i)).aestronglyMeasurable) M
          (Filter.Eventually.of_forall fun y' => by rw [Real.norm_eq_abs]; exact hbound i t _)
      rw [integral_sub (integrable_const _) hint_i, integral_pi_eval_prob μ i (φ i t)]
      simp [m]
    have hGy_int : Integrable (fun y' => G (y, y')) P :=
      Integrable.of_bound
        ((hG_meas.comp (measurable_const.prodMk measurable_id)).aestronglyMeasurable)
        (2 * (n : ℝ) * M) (Filter.Eventually.of_forall fun y' => by
          rw [Real.norm_eq_abs]; exact hG_bound (y, y'))
    have habs_int : Integrable (fun y' : Fin n → ℝ => |∑ i, (φ i t (y i) - φ i t (y' i))|) P :=
      (integrable_finsetSum _ fun i _ => hint_diff i).abs
    calc |∑ i, (φ i t (y i) - m i t)|
        = |∫ y', (∑ i, (φ i t (y i) - φ i t (y' i))) ∂P| := by rw [heq_int]
      _ ≤ ∫ y', |∑ i, (φ i t (y i) - φ i t (y' i))| ∂P := abs_integral_le_integral_abs
      _ ≤ ∫ y', G (y, y') ∂P := integral_mono habs_int hGy_int fun y' =>
          Finset.le_sup' (f := fun s => |∑ i, (φ i s (y i) - φ i s (y' i))|) ht
  have hlhs_int : Integrable (fun y => T.sup' hT fun t => |∑ i, (φ i t (y i) - m i t)|) P := by
    refine Integrable.of_bound ?_ (2 * (n : ℝ) * M) (Filter.Eventually.of_forall fun y => ?_)
    · exact (measurable_finset_sup' T hT fun t _ =>
        (Finset.measurable_sum _ fun i _ =>
          ((hmeas i t).comp (measurable_pi_apply i)).sub measurable_const).abs).aestronglyMeasurable
    · rw [Real.norm_eq_abs, abs_of_nonneg (le_trans (abs_nonneg _)
        (Finset.le_sup' (f := fun t => |∑ i, (φ i t (y i) - m i t)|) hT.choose_spec))]
      refine Finset.sup'_le hT _ fun t _ => ?_
      calc |∑ i, (φ i t (y i) - m i t)|
          ≤ ∑ i : Fin n, |φ i t (y i) - m i t| := Finset.abs_sum_le_sum_abs _ _
        _ ≤ ∑ _i : Fin n, (2 * M) := Finset.sum_le_sum fun i _ => by
            calc |φ i t (y i) - m i t| ≤ |φ i t (y i)| + |m i t| := abs_sub _ _
              _ ≤ 2 * M := by linarith [hbound i t (y i), hm_bound i t]
        _ = 2 * (n : ℝ) * M := by simp; ring
  have hstep1 :
      ∫ y, (T.sup' hT fun t => |∑ i, (φ i t (y i) - m i t)|) ∂P ≤ ∫ p, G p ∂(P.prod P) := by
    rw [MeasureTheory.integral_prod G hG_int]
    exact integral_mono hlhs_int hG_int.integral_prod_left hjensen_pt
  -- Step 2: Insert Rademacher signs via coordinatewise swap invariance
  let H : (Fin n → ℝ) → (Fin n → ℝ) × (Fin n → ℝ) → ℝ :=
    fun ξ p => T.sup' hT fun t => |∑ i, ξ i * (φ i t (p.1 i) - φ i t (p.2 i))|
  have hswap_eq : ∀ ξ : Fin n → ℝ, (∀ i, ξ i = -1 ∨ ξ i = 1) →
      ∫ p, G p ∂(P.prod P) = ∫ p, H ξ p ∂(P.prod P) := by
    intro ξ hξ
    let s : Finset (Fin n) := Finset.univ.filter fun i => ξ i = -1
    have hmp := measurePreserving_swapSet μ s
    have hcomp : ∫ p, G (swapSet s p) ∂(P.prod P) = ∫ p, G p ∂(P.prod P) := by
      rw [← integral_map hmp.measurable.aemeasurable hG_meas.aestronglyMeasurable, hmp.map_eq]
    rw [← hcomp]
    congr 1; ext p
    simp only [G, H, swapSet]
    refine Finset.sup'_congr hT rfl fun t _ => ?_
    congr 1
    refine Finset.sum_congr rfl fun i _ => ?_
    rcases hξ i with hi | hi
    · have him : i ∈ s := Finset.mem_filter.mpr ⟨Finset.mem_univ i, hi⟩
      simp [him, hi]
    · have him : i ∉ s := by simp [s, hi]; norm_num
      simp [him, hi]
  have hH_meas : Measurable (Function.uncurry H) := by
    refine measurable_finset_sup' T hT fun t _ => ?_
    refine (Finset.measurable_sum _ fun i _ => ?_).abs
    exact ((measurable_pi_apply i).comp measurable_fst).mul
      (((hmeas i t).comp ((measurable_pi_apply i).comp (measurable_fst.comp measurable_snd))).sub
       ((hmeas i t).comp ((measurable_pi_apply i).comp (measurable_snd.comp measurable_snd))))
  have hH_int : Integrable (Function.uncurry H) (R.prod (P.prod P)) := by
    refine Integrable.of_bound hH_meas.aestronglyMeasurable (2 * (n : ℝ) * M) ?_
    have hae : ∀ᵐ q ∂(R.prod (P.prod P)), ∀ i : Fin n, q.1 i = -1 ∨ q.1 i = 1 :=
      Measure.quasiMeasurePreserving_fst.ae (ae_rademacher_eq_neg_one_or_one n)
    filter_upwards [hae] with ⟨ξ, p⟩ hξ
    dsimp only at hξ
    change |H ξ p| ≤ 2 * (n : ℝ) * M
    have hnn : 0 ≤ H ξ p := le_trans (abs_nonneg _) (Finset.le_sup' (f := fun t =>
      |∑ i, ξ i * (φ i t (p.1 i) - φ i t (p.2 i))|) hT.choose_spec)
    rw [abs_of_nonneg hnn]
    refine Finset.sup'_le hT _ fun t _ => ?_
    calc |∑ i, ξ i * (φ i t (p.1 i) - φ i t (p.2 i))|
        ≤ ∑ i : Fin n, |ξ i * (φ i t (p.1 i) - φ i t (p.2 i))| := Finset.abs_sum_le_sum_abs _ _
      _ ≤ ∑ _i : Fin n, (2 * M) := Finset.sum_le_sum fun i _ => by
          rw [abs_mul]
          have hξ1 : |ξ i| = 1 := by rcases hξ i with h | h <;> simp [h]
          rw [hξ1, one_mul]
          calc |φ i t (p.1 i) - φ i t (p.2 i)| ≤ |φ i t (p.1 i)| + |φ i t (p.2 i)| := abs_sub _ _
            _ ≤ 2 * M := by linarith [hbound i t (p.1 i), hbound i t (p.2 i)]
      _ = 2 * (n : ℝ) * M := by simp; ring
  have hstep2 : ∫ p, G p ∂(P.prod P) = ∫ p, (∫ ξ, H ξ p ∂ R) ∂(P.prod P) := by
    have h1 : ∫ p, G p ∂(P.prod P) = ∫ ξ, (∫ p, H ξ p ∂(P.prod P)) ∂ R := by
      have hconst : ∫ p, G p ∂(P.prod P) = ∫ _ξ, (∫ p, G p ∂(P.prod P)) ∂ R := by simp
      rw [hconst]
      refine integral_congr_ae ?_
      filter_upwards [ae_rademacher_eq_neg_one_or_one n] with ξ hξ
      exact hswap_eq ξ hξ
    rw [h1, MeasureTheory.integral_integral_swap hH_int]
  -- Step 3: Triangle inequality + symmetry between `y` and `y'`
  let F : (Fin n → ℝ) → (Fin n → ℝ) → ℝ :=
    fun y ξ => T.sup' hT fun t => |∑ i, ξ i * φ i t (y i)|
  have hF_meas : Measurable (Function.uncurry F) := by
    refine measurable_finset_sup' T hT fun t _ => ?_
    refine (Finset.measurable_sum _ fun i _ => ?_).abs
    exact ((measurable_pi_apply i).comp measurable_snd).mul
      ((hmeas i t).comp ((measurable_pi_apply i).comp measurable_fst))
  have hF_int_y : ∀ y : Fin n → ℝ, Integrable (fun ξ => F y ξ) R := fun y => by
    refine Integrable.of_bound
      ((hF_meas.comp (measurable_const.prodMk measurable_id)).aestronglyMeasurable)
      ((n : ℝ) * M) ?_
    filter_upwards [ae_rademacher_eq_neg_one_or_one n] with ξ hξ
    rw [Real.norm_eq_abs, abs_of_nonneg (le_trans (abs_nonneg _)
      (Finset.le_sup' (f := fun t => |∑ i, ξ i * φ i t (y i)|) hT.choose_spec))]
    refine Finset.sup'_le hT _ fun t _ => ?_
    calc |∑ i, ξ i * φ i t (y i)|
        ≤ ∑ i : Fin n, |ξ i * φ i t (y i)| := Finset.abs_sum_le_sum_abs _ _
      _ ≤ ∑ _i : Fin n, M := Finset.sum_le_sum fun i _ => by
          rw [abs_mul]
          have hξ1 : |ξ i| = 1 := by rcases hξ i with h | h <;> simp [h]
          rw [hξ1, one_mul]; exact hbound i t (y i)
      _ = (n : ℝ) * M := by simp
  have hEF_meas : Measurable (fun y => ∫ ξ, F y ξ ∂ R) :=
    hF_meas.stronglyMeasurable.integral_prod_right'.measurable
  have hEF_bound : ∀ y, |∫ ξ, F y ξ ∂ R| ≤ (n : ℝ) * M := fun y => by
    calc |∫ ξ, F y ξ ∂ R|
        ≤ ∫ ξ, |F y ξ| ∂ R := abs_integral_le_integral_abs
      _ ≤ ∫ _ξ, (n : ℝ) * M ∂ R := by
          refine integral_mono_ae (hF_int_y y).abs (integrable_const _) ?_
          filter_upwards [ae_rademacher_eq_neg_one_or_one n] with ξ hξ
          rw [abs_of_nonneg (le_trans (abs_nonneg _)
            (Finset.le_sup' (f := fun t => |∑ i, ξ i * φ i t (y i)|) hT.choose_spec))]
          refine Finset.sup'_le hT _ fun t _ => ?_
          calc |∑ i, ξ i * φ i t (y i)|
              ≤ ∑ i : Fin n, |ξ i * φ i t (y i)| := Finset.abs_sum_le_sum_abs _ _
            _ ≤ ∑ _i : Fin n, M := Finset.sum_le_sum fun i _ => by
                rw [abs_mul]
                have hξ1 : |ξ i| = 1 := by rcases hξ i with h | h <;> simp [h]
                rw [hξ1, one_mul]; exact hbound i t (y i)
            _ = (n : ℝ) * M := by simp
      _ = (n : ℝ) * M := by simp
  have htri : ∀ p : (Fin n → ℝ) × (Fin n → ℝ),
      ∫ ξ, H ξ p ∂ R ≤ (∫ ξ, F p.1 ξ ∂ R) + (∫ ξ, F p.2 ξ ∂ R) := by
    intro p
    rw [← integral_add (hF_int_y p.1) (hF_int_y p.2)]
    have hHp_int : Integrable (fun ξ => H ξ p) R := by
      refine Integrable.of_bound
        ((hH_meas.comp (measurable_id.prodMk measurable_const)).aestronglyMeasurable)
        (2 * (n : ℝ) * M) ?_
      filter_upwards [ae_rademacher_eq_neg_one_or_one n] with ξ hξ
      rw [Real.norm_eq_abs, abs_of_nonneg (le_trans (abs_nonneg _)
        (Finset.le_sup' (f := fun t => |∑ i, ξ i * (φ i t (p.1 i) - φ i t (p.2 i))|) hT.choose_spec))]
      refine Finset.sup'_le hT _ fun t _ => ?_
      calc |∑ i, ξ i * (φ i t (p.1 i) - φ i t (p.2 i))|
          ≤ ∑ i : Fin n, |ξ i * (φ i t (p.1 i) - φ i t (p.2 i))| := Finset.abs_sum_le_sum_abs _ _
        _ ≤ ∑ _i : Fin n, (2 * M) := Finset.sum_le_sum fun i _ => by
            rw [abs_mul]
            have hξ1 : |ξ i| = 1 := by rcases hξ i with h | h <;> simp [h]
            rw [hξ1, one_mul]
            calc |φ i t (p.1 i) - φ i t (p.2 i)| ≤ |φ i t (p.1 i)| + |φ i t (p.2 i)| := abs_sub _ _
              _ ≤ 2 * M := by linarith [hbound i t (p.1 i), hbound i t (p.2 i)]
        _ = 2 * (n : ℝ) * M := by simp; ring
    refine integral_mono hHp_int ((hF_int_y p.1).add (hF_int_y p.2)) fun ξ => ?_
    refine Finset.sup'_le hT _ fun t ht => ?_
    have hsum_sub : ∑ i, ξ i * (φ i t (p.1 i) - φ i t (p.2 i)) =
        (∑ i, ξ i * φ i t (p.1 i)) - (∑ i, ξ i * φ i t (p.2 i)) := by
      simp_rw [mul_sub, Finset.sum_sub_distrib]
    rw [hsum_sub]
    calc |(∑ i, ξ i * φ i t (p.1 i)) - (∑ i, ξ i * φ i t (p.2 i))|
        ≤ |∑ i, ξ i * φ i t (p.1 i)| + |∑ i, ξ i * φ i t (p.2 i)| := abs_sub _ _
      _ ≤ F p.1 ξ + F p.2 ξ :=
          add_le_add (Finset.le_sup' (f := fun s => |∑ i, ξ i * φ i s (p.1 i)|) ht)
            (Finset.le_sup' (f := fun s => |∑ i, ξ i * φ i s (p.2 i)|) ht)
  have hEF1_int : Integrable (fun p : (Fin n → ℝ) × (Fin n → ℝ) => ∫ ξ, F p.1 ξ ∂ R) (P.prod P) :=
    Integrable.of_bound ((hEF_meas.comp measurable_fst).aestronglyMeasurable) ((n : ℝ) * M)
      (Filter.Eventually.of_forall fun p => by rw [Real.norm_eq_abs]; exact hEF_bound p.1)
  have hEF2_int : Integrable (fun p : (Fin n → ℝ) × (Fin n → ℝ) => ∫ ξ, F p.2 ξ ∂ R) (P.prod P) :=
    Integrable.of_bound ((hEF_meas.comp measurable_snd).aestronglyMeasurable) ((n : ℝ) * M)
      (Filter.Eventually.of_forall fun p => by rw [Real.norm_eq_abs]; exact hEF_bound p.2)
  have hstep3 : ∫ p, (∫ ξ, H ξ p ∂ R) ∂(P.prod P) ≤ 2 * ∫ y, (∫ ξ, F y ξ ∂ R) ∂ P := by
    calc ∫ p, (∫ ξ, H ξ p ∂ R) ∂(P.prod P)
        ≤ ∫ p, ((∫ ξ, F p.1 ξ ∂ R) + (∫ ξ, F p.2 ξ ∂ R)) ∂(P.prod P) :=
          integral_mono hH_int.integral_prod_right (hEF1_int.add hEF2_int) htri
      _ = (∫ p, (∫ ξ, F p.1 ξ ∂ R) ∂(P.prod P)) + (∫ p, (∫ ξ, F p.2 ξ ∂ R) ∂(P.prod P)) :=
          integral_add hEF1_int hEF2_int
      _ = (∫ y, (∫ ξ, F y ξ ∂ R) ∂ P) + (∫ y', (∫ ξ, F y' ξ ∂ R) ∂ P) := by
          rw [MeasureTheory.integral_prod _ hEF1_int, MeasureTheory.integral_prod_symm _ hEF2_int]
          simp
      _ = 2 * ∫ y, (∫ ξ, F y ξ ∂ R) ∂ P := by ring
  linarith [hstep1, hstep2, hstep3]

end BQTF.Prob
