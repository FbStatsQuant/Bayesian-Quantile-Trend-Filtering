import BQTF.Basic
import BQTF.CheckLoss
import BQTF.Prob.Symmetrization
import BQTF.Prob.Contraction
import BQTF.Prob.EfronStein

/-!
# Concentration of the empirical check-loss process (appendix, Lemma `pf:lem:conc`)

Owner: Neon-B. Classical inputs expected (see PLAN.md tracker): symmetrization (absolute-value
form, van der Vaart and Wellner Lemma 2.3.6), the contraction principle (absolute-value form,
Ledoux and Talagrand Theorem 4.12), and the Efron–Stein inequality.
-/

open MeasureTheory ProbabilityTheory Finset
open scoped ENNReal

noncomputable section

namespace BQTF

/-- `G_K = sup_{δ ∈ K} |L̂(δ) − L(δ)|` at data `y`. -/
def GK {n : ℕ} (τ : ℝ) (μ : Fin n → Measure ℝ) (θs : Fin n → ℝ) (K : Set (Fin n → ℝ))
    (y : Fin n → ℝ) : ℝ :=
  sSup ((fun δ => |lossHat τ (y - θs) δ - lossExp τ μ θs δ|) '' K)

/-! ### Coordinatewise check-loss and empirical process helpers -/

private lemma lossHat_eq_sum_ell {n : ℕ} (τ : ℝ) (y θs δ : Fin n → ℝ) :
    lossHat τ (y - θs) δ = ∑ i, ell τ (δ i) (y i - θs i) := rfl

private lemma abs_ell_le {τ t z : ℝ} (hτ : 0 < τ ∧ τ < 1) :
    |ell τ t z| ≤ |t| := by
  have h := ell_props τ z hτ
  have h1 := h.2.2.1 t 0
  rw [h.2.1, sub_zero, sub_zero] at h1
  exact h1

private lemma abs_ell_sub_ell_le {τ t z₁ z₂ : ℝ} (hτ : 0 < τ ∧ τ < 1) :
    |ell τ t z₁ - ell τ t z₂| ≤ |t| := by
  have h1 := (ell_props τ z₁ hτ).2.2.2 t
  have h2 := (ell_props τ z₂ hτ).2.2.2 t
  rcases le_total 0 t with ht | ht
  · have hle : -τ * t ≤ (1 - τ) * t := by nlinarith [hτ.1, hτ.2]
    rw [min_eq_left hle, max_eq_right hle] at h1 h2
    rw [abs_of_nonneg ht, abs_le]
    constructor <;> linarith
  · have hle : (1 - τ) * t ≤ -τ * t := by nlinarith [hτ.1, hτ.2]
    rw [min_eq_right hle, max_eq_left hle] at h1 h2
    rw [abs_of_nonpos ht, abs_le]
    constructor <;> linarith

private lemma lossExp_eq_sum_integral_ell {n : ℕ} (τ : ℝ) (hτ : 0 < τ ∧ τ < 1)
    (μ : Fin n → Measure ℝ) [∀ i, IsProbabilityMeasure (μ i)] (θs δ : Fin n → ℝ) :
    lossExp τ μ θs δ = ∑ i, ∫ x, ell τ (δ i) (x - θs i) ∂(μ i) := by
  unfold lossExp
  simp_rw [lossHat_eq_sum_ell]
  have hint : ∀ i : Fin n, Integrable (fun y : Fin n → ℝ => ell τ (δ i) (y i - θs i))
      (Measure.pi μ) := fun i =>
    Integrable.of_bound
      (((measurable_ell τ (δ i)).comp ((measurable_pi_apply i).sub measurable_const)).aestronglyMeasurable)
      |δ i| (Filter.Eventually.of_forall fun y => by rw [Real.norm_eq_abs]; exact abs_ell_le hτ)
  rw [integral_finsetSum _ fun i _ => hint i]
  refine Finset.sum_congr rfl fun i _ => ?_
  have hmp : MeasurePreserving (Function.eval i) (Measure.pi μ) (μ i) :=
    measurePreserving_eval μ i
  have hm : Measurable (fun x : ℝ => ell τ (δ i) (x - θs i)) :=
    (measurable_ell τ (δ i)).comp (measurable_id.sub measurable_const)
  conv_rhs => rw [← hmp.map_eq]
  rw [integral_map hmp.measurable.aemeasurable hm.aestronglyMeasurable]

private def empProc {n : ℕ} (τ : ℝ) (μ : Fin n → Measure ℝ) (θs y δ : Fin n → ℝ) : ℝ :=
  |lossHat τ (y - θs) δ - lossExp τ μ θs δ|

private lemma empProc_lipschitz {n : ℕ} (τ : ℝ) (hτ : 0 < τ ∧ τ < 1)
    (μ : Fin n → Measure ℝ) [∀ i, IsProbabilityMeasure (μ i)] (θs y δ₁ δ₂ : Fin n → ℝ) :
    |empProc τ μ θs y δ₁ - empProc τ μ θs y δ₂| ≤ 2 * (n : ℝ) * ‖δ₁ - δ₂‖ := by
  have hhat : |lossHat τ (y - θs) δ₁ - lossHat τ (y - θs) δ₂| ≤ (n : ℝ) * ‖δ₁ - δ₂‖ := by
    rw [lossHat_eq_sum_ell, lossHat_eq_sum_ell, ← Finset.sum_sub_distrib]
    calc |∑ i, (ell τ (δ₁ i) (y i - θs i) - ell τ (δ₂ i) (y i - θs i))|
        ≤ ∑ i : Fin n, |ell τ (δ₁ i) (y i - θs i) - ell τ (δ₂ i) (y i - θs i)| :=
          Finset.abs_sum_le_sum_abs _ _
      _ ≤ ∑ i : Fin n, |δ₁ i - δ₂ i| :=
          Finset.sum_le_sum fun i _ => (ell_props τ (y i - θs i) hτ).2.2.1 (δ₁ i) (δ₂ i)
      _ ≤ ∑ _i : Fin n, ‖δ₁ - δ₂‖ :=
          Finset.sum_le_sum fun i _ => by
            simpa [Real.norm_eq_abs] using norm_le_pi_norm (δ₁ - δ₂) i
      _ = (n : ℝ) * ‖δ₁ - δ₂‖ := by simp
  have hexp : |lossExp τ μ θs δ₁ - lossExp τ μ θs δ₂| ≤ (n : ℝ) * ‖δ₁ - δ₂‖ := by
    rw [lossExp_eq_sum_integral_ell τ hτ μ θs δ₁, lossExp_eq_sum_integral_ell τ hτ μ θs δ₂,
      ← Finset.sum_sub_distrib]
    calc |∑ i, ((∫ x, ell τ (δ₁ i) (x - θs i) ∂(μ i)) - ∫ x, ell τ (δ₂ i) (x - θs i) ∂(μ i))|
        ≤ ∑ i : Fin n, |(∫ x, ell τ (δ₁ i) (x - θs i) ∂(μ i)) -
            ∫ x, ell τ (δ₂ i) (x - θs i) ∂(μ i)| := Finset.abs_sum_le_sum_abs _ _
      _ ≤ ∑ i : Fin n, |δ₁ i - δ₂ i| := Finset.sum_le_sum fun i _ => by
          have hi1 : Integrable (fun x => ell τ (δ₁ i) (x - θs i)) (μ i) :=
            Integrable.of_bound
              (((measurable_ell τ (δ₁ i)).comp (measurable_id.sub measurable_const)).aestronglyMeasurable)
              |δ₁ i| (Filter.Eventually.of_forall fun x => by rw [Real.norm_eq_abs]; exact abs_ell_le hτ)
          have hi2 : Integrable (fun x => ell τ (δ₂ i) (x - θs i)) (μ i) :=
            Integrable.of_bound
              (((measurable_ell τ (δ₂ i)).comp (measurable_id.sub measurable_const)).aestronglyMeasurable)
              |δ₂ i| (Filter.Eventually.of_forall fun x => by rw [Real.norm_eq_abs]; exact abs_ell_le hτ)
          rw [← integral_sub hi1 hi2]
          calc |∫ x, (ell τ (δ₁ i) (x - θs i) - ell τ (δ₂ i) (x - θs i)) ∂(μ i)|
              ≤ ∫ x, |ell τ (δ₁ i) (x - θs i) - ell τ (δ₂ i) (x - θs i)| ∂(μ i) :=
                abs_integral_le_integral_abs
            _ ≤ ∫ _x, |δ₁ i - δ₂ i| ∂(μ i) :=
                integral_mono (hi1.sub hi2).abs (integrable_const _) fun x =>
                  (ell_props τ (x - θs i) hτ).2.2.1 (δ₁ i) (δ₂ i)
            _ = |δ₁ i - δ₂ i| := by simp
      _ ≤ ∑ _i : Fin n, ‖δ₁ - δ₂‖ :=
          Finset.sum_le_sum fun i _ => by
            simpa [Real.norm_eq_abs] using norm_le_pi_norm (δ₁ - δ₂) i
      _ = (n : ℝ) * ‖δ₁ - δ₂‖ := by simp
  calc |empProc τ μ θs y δ₁ - empProc τ μ θs y δ₂|
      ≤ |(lossHat τ (y - θs) δ₁ - lossExp τ μ θs δ₁) -
          (lossHat τ (y - θs) δ₂ - lossExp τ μ θs δ₂)| := abs_abs_sub_abs_le_abs_sub _ _
    _ = |(lossHat τ (y - θs) δ₁ - lossHat τ (y - θs) δ₂) -
          (lossExp τ μ θs δ₁ - lossExp τ μ θs δ₂)| := by ring_nf
    _ ≤ |lossHat τ (y - θs) δ₁ - lossHat τ (y - θs) δ₂| +
          |lossExp τ μ θs δ₁ - lossExp τ μ θs δ₂| := abs_sub _ _
    _ ≤ 2 * (n : ℝ) * ‖δ₁ - δ₂‖ := by linarith

private lemma continuous_empProc {n : ℕ} (τ : ℝ) (hτ : 0 < τ ∧ τ < 1)
    (μ : Fin n → Measure ℝ) [∀ i, IsProbabilityMeasure (μ i)] (θs y : Fin n → ℝ) :
    Continuous (empProc τ μ θs y) := by
  refine Metric.continuous_iff.mpr fun δ ε hε => ?_
  refine ⟨ε / (2 * (n : ℝ) + 1), div_pos hε (by positivity), fun δ' hδ' => ?_⟩
  rw [Real.dist_eq]
  rw [dist_eq_norm] at hδ'
  have hlip := empProc_lipschitz τ hτ μ θs y δ' δ
  have hpos : (0 : ℝ) < 2 * (n : ℝ) + 1 := by positivity
  have h1 : 2 * (n : ℝ) * ‖δ' - δ‖ ≤ (2 * (n : ℝ) + 1) * ‖δ' - δ‖ := by
    nlinarith [norm_nonneg (δ' - δ)]
  have h2 : (2 * (n : ℝ) + 1) * ‖δ' - δ‖ < ε := by
    have := (lt_div_iff₀' hpos).mp hδ'
    linarith
  linarith

private lemma empProc_le_bound {n : ℕ} (τ : ℝ) (hτ : 0 < τ ∧ τ < 1)
    (μ : Fin n → Measure ℝ) [∀ i, IsProbabilityMeasure (μ i)] (θs y δ : Fin n → ℝ) :
    empProc τ μ θs y δ ≤ 2 * (n : ℝ) * ‖δ‖ := by
  have h0 : empProc τ μ θs y 0 = 0 := by
    unfold empProc
    have hhat0 : lossHat τ (y - θs) 0 = 0 := by
      rw [lossHat_eq_sum_ell]
      refine Finset.sum_eq_zero fun i _ => (ell_props τ (y i - θs i) hτ).2.1
    have hexp0 : lossExp τ μ θs 0 = 0 := by
      rw [lossExp_eq_sum_integral_ell τ hτ μ θs 0]
      refine Finset.sum_eq_zero fun i _ => ?_
      simp_rw [Pi.zero_apply, (ell_props τ _ hτ).2.1]
      simp
    simp [hhat0, hexp0]
  have hlip := empProc_lipschitz τ hτ μ θs y δ 0
  rw [h0, sub_zero, sub_zero] at hlip
  exact le_trans (le_abs_self _) hlip

private lemma measurable_empProc_y {n : ℕ} (τ : ℝ) (μ : Fin n → Measure ℝ) (θs δ : Fin n → ℝ) :
    Measurable (fun y => empProc τ μ θs y δ) := by
  unfold empProc
  refine ((Finset.measurable_sum _ fun i _ => ?_).sub measurable_const).abs
  exact (measurable_ell τ (δ i)).comp ((measurable_pi_apply i).sub measurable_const)

private lemma measurable_finset_sup' {α β : Type*} [MeasurableSpace α]
    (T : Finset β) (hT : T.Nonempty) {f : β → α → ℝ} (hf : ∀ t ∈ T, Measurable (f t)) :
    Measurable (fun x => T.sup' hT fun t => f t x) := by
  classical
  induction hT using Finset.Nonempty.cons_induction with
  | singleton a =>
    simpa only [Finset.sup'_singleton] using hf a (Finset.mem_singleton_self a)
  | cons a s ha hs ih =>
    have hrew : (fun x => (s.cons a ha).sup' (Finset.cons_nonempty ha) fun t => f t x) =
        fun x => max (f a x) (s.sup' hs fun t => f t x) := by
      ext x
      rw [Finset.sup'_cons]
    rw [hrew]
    exact (hf a (Finset.mem_cons_self a s)).max
      (ih fun t ht => hf t (Finset.mem_cons_of_mem ht))

/-! ### Compact-to-finite reduction via dense symmetric exhaustion -/

private lemma exists_symmetric_exhaustion {n : ℕ} {K : Set (Fin n → ℝ)}
    (hsymm : ∀ δ ∈ K, -δ ∈ K) (hne : K.Nonempty) :
    ∃ T : ℕ → Finset (Fin n → ℝ),
      (∀ m, (T m).Nonempty) ∧
      (∀ m, (T m : Set (Fin n → ℝ)) ⊆ K) ∧
      (∀ m, ∀ δ ∈ T m, -δ ∈ T m) ∧
      Monotone T ∧
      K ⊆ closure (⋃ m, (T m : Set (Fin n → ℝ))) := by
  classical
  obtain ⟨s, hs_cnt, hs_dense⟩ := TopologicalSpace.exists_countable_dense K
  obtain ⟨δ₀, hδ₀⟩ := hne
  let D : Set (Fin n → ℝ) := insert δ₀ (Subtype.val '' s)
  have hD_cnt : D.Countable := (hs_cnt.image _).insert δ₀
  have hD_ne : D.Nonempty := Set.insert_nonempty _ _
  have hD_sub : D ⊆ K := Set.insert_subset hδ₀ (Subtype.coe_image_subset K s)
  have hK_clos : K ⊆ closure D := by
    intro x hx
    have hmem : (⟨x, hx⟩ : K) ∈ closure s := hs_dense ⟨x, hx⟩
    have hval : x ∈ Subtype.val '' closure s := ⟨⟨x, hx⟩, hmem, rfl⟩
    exact closure_mono (Set.subset_insert δ₀ _)
      (image_closure_subset_closure_image continuous_subtype_val hval)
  obtain ⟨d, hd⟩ := hD_cnt.exists_eq_range hD_ne
  let T : ℕ → Finset (Fin n → ℝ) :=
    fun m => (Finset.range (m + 1)).image d ∪ (Finset.range (m + 1)).image (fun k => -d k)
  refine ⟨T, ?_, ?_, ?_, ?_, ?_⟩
  · intro m
    refine ⟨d 0, Finset.mem_union_left _ (Finset.mem_image.mpr ⟨0, Finset.mem_range.mpr (Nat.zero_lt_succ m), rfl⟩)⟩
  · intro m δ hδ
    rcases Finset.mem_union.mp hδ with h1 | h2
    · rcases Finset.mem_image.mp h1 with ⟨k, _, rfl⟩
      exact hD_sub (hd.symm ▸ Set.mem_range_self k)
    · rcases Finset.mem_image.mp h2 with ⟨k, _, rfl⟩
      exact hsymm _ (hD_sub (hd.symm ▸ Set.mem_range_self k))
  · intro m δ hδ
    rcases Finset.mem_union.mp hδ with h1 | h2
    · rcases Finset.mem_image.mp h1 with ⟨k, hk, rfl⟩
      exact Finset.mem_union_right _ (Finset.mem_image.mpr ⟨k, hk, rfl⟩)
    · rcases Finset.mem_image.mp h2 with ⟨k, hk, rfl⟩
      rw [neg_neg]
      exact Finset.mem_union_left _ (Finset.mem_image.mpr ⟨k, hk, rfl⟩)
  · intro m₁ m₂ hle
    exact Finset.union_subset_union
      (Finset.image_subset_image (Finset.range_mono (Nat.add_le_add_right hle 1)))
      (Finset.image_subset_image (Finset.range_mono (Nat.add_le_add_right hle 1)))
  · refine Set.Subset.trans hK_clos (closure_mono ?_)
    intro x hx
    rw [hd] at hx
    rcases hx with ⟨k, rfl⟩
    refine Set.mem_iUnion.mpr ⟨k, ?_⟩
    exact Finset.mem_union_left _ (Finset.mem_image.mpr ⟨k, Finset.mem_range.mpr (Nat.lt_succ_self k), rfl⟩)

private lemma tendsto_finset_sup'_sSup {n : ℕ} {K : Set (Fin n → ℝ)}
    (hK : IsCompact K) (hne : K.Nonempty)
    {T : ℕ → Finset (Fin n → ℝ)} (hTne : ∀ m, (T m).Nonempty)
    (hTK : ∀ m, (T m : Set (Fin n → ℝ)) ⊆ K)
    (hTmono : Monotone T) (hdense : K ⊆ closure (⋃ m, (T m : Set (Fin n → ℝ))))
    {g : (Fin n → ℝ) → ℝ} (hg : Continuous g) :
    Filter.Tendsto (fun m => (T m).sup' (hTne m) g) Filter.atTop (nhds (sSup (g '' K))) := by
  obtain ⟨δstar, hδstar, hmax⟩ := hK.exists_isMaxOn hne hg.continuousOn
  have hsSup_eq : sSup (g '' K) = g δstar := by
    apply le_antisymm
    · refine csSup_le (hne.image g) ?_
      rintro _ ⟨δ, hδ, rfl⟩
      exact hmax hδ
    · exact le_csSup (hK.image hg).bddAbove ⟨δstar, hδstar, rfl⟩
  rw [hsSup_eq]
  refine Metric.tendsto_atTop.mpr fun ε hε => ?_
  obtain ⟨η, hη, hcont⟩ := Metric.continuousAt_iff.mp hg.continuousAt ε hε
  obtain ⟨δ', hδ'mem, hδ'dist⟩ := Metric.mem_closure_iff.mp (hdense hδstar) η hη
  rcases Set.mem_iUnion.mp hδ'mem with ⟨m₀, hm₀⟩
  refine ⟨m₀, fun m hm => ?_⟩
  have hδ'm : δ' ∈ T m := hTmono hm hm₀
  have hle : (T m).sup' (hTne m) g ≤ g δstar :=
    Finset.sup'_le (hTne m) _ fun δ hδ => hmax (hTK m hδ)
  have hge : g δ' ≤ (T m).sup' (hTne m) g := Finset.le_sup' (f := g) hδ'm
  have hdiff : |g δ' - g δstar| < ε := by
    simpa [Real.dist_eq] using hcont (by rwa [dist_comm])
  rw [Real.dist_eq, abs_lt]
  have hdiff_l := (abs_lt.mp hdiff).1
  constructor <;> linarith

private lemma gk_measurable_and_bounded {n : ℕ} (τ : ℝ) (hτ : 0 < τ ∧ τ < 1)
    (μ : Fin n → Measure ℝ) [∀ i, IsProbabilityMeasure (μ i)] (θs : Fin n → ℝ)
    {K : Set (Fin n → ℝ)} (hK : IsCompact K) (hsymm : ∀ δ ∈ K, -δ ∈ K) (hne : K.Nonempty) :
    Measurable (GK τ μ θs K) ∧
    ∃ R : ℝ, 0 ≤ R ∧ (∀ δ ∈ K, ‖δ‖ ≤ R) ∧
      ∀ y, 0 ≤ GK τ μ θs K y ∧ GK τ μ θs K y ≤ 2 * (n : ℝ) * R := by
  obtain ⟨T, hTne, hTK, _, hTmono, hdense⟩ := exists_symmetric_exhaustion hsymm hne
  have hmeas : Measurable (GK τ μ θs K) := by
    refine measurable_of_tendsto_metrizable (f := fun m y => (T m).sup' (hTne m) (empProc τ μ θs y))
      (fun m => measurable_finset_sup' (T m) (hTne m) fun δ _ => measurable_empProc_y τ μ θs δ) ?_
    rw [tendsto_pi_nhds]
    intro y
    exact tendsto_finset_sup'_sSup hK hne hTne hTK hTmono hdense (continuous_empProc τ hτ μ θs y)
  obtain ⟨R₀, hR₀⟩ := hK.isBounded.subset_closedBall (0 : Fin n → ℝ)
  let R : ℝ := max R₀ 0
  have hR_nn : 0 ≤ R := le_max_right _ _
  have hK_R : ∀ δ ∈ K, ‖δ‖ ≤ R := fun δ hδ => by
    have h1 : ‖δ‖ ≤ R₀ := by simpa [Metric.mem_closedBall, dist_zero_right] using hR₀ hδ
    exact le_trans h1 (le_max_left _ _)
  refine ⟨hmeas, R, hR_nn, hK_R, fun y => ?_⟩
  constructor
  · obtain ⟨δ₀, hδ₀⟩ := id hne
    exact le_trans (abs_nonneg _)
      (le_csSup (hK.image (continuous_empProc τ hτ μ θs y)).bddAbove ⟨δ₀, hδ₀, rfl⟩)
  · refine csSup_le (hne.image _) ?_
    rintro _ ⟨δ, hδ, rfl⟩
    calc empProc τ μ θs y δ
        ≤ 2 * (n : ℝ) * ‖δ‖ := empProc_le_bound τ hτ μ θs y δ
      _ ≤ 2 * (n : ℝ) * R := by gcongr; exact hK_R δ hδ

/-! ### Variance bound via one-sided Efron–Stein -/

/-- Variance bound in Lemma `pf:lem:conc`, parameterized by the one-sided Efron–Stein inequality
(owned by CP-OPUS1 in `BQTF/Prob/EfronStein.lean`). -/
theorem concentration_variance_of_efronStein {n : ℕ} (τ : ℝ) (hτ : 0 < τ ∧ τ < 1)
    (μ : Fin n → Measure ℝ) (hμ : ∀ i, IsProbabilityMeasure (μ i))
    (θs : Fin n → ℝ) (K : Set (Fin n → ℝ))
    (hK : IsCompact K) (hsymm : ∀ δ ∈ K, -δ ∈ K) (hne : K.Nonempty)
    (hES : ∀ {f : (Fin n → ℝ) → ℝ}, Measurable f → MemLp f 2 (Measure.pi μ) →
      evariance f (Measure.pi μ) ≤
        ∑ i, ∫⁻ y, ∫⁻ z, ENNReal.ofReal ((max (f y - f (Function.update y i z)) 0) ^ 2)
          ∂(μ i) ∂(Measure.pi μ)) :
    variance (GK τ μ θs K) (Measure.pi μ) ≤ sSup (l2sq '' K) := by
  have : ∀ i, IsProbabilityMeasure (μ i) := hμ
  let P := Measure.pi μ
  let f := GK τ μ θs K
  obtain ⟨hmeas, R, hR_nn, _, hf_bound⟩ := gk_measurable_and_bounded τ hτ μ θs hK hsymm hne
  have hmem : MemLp f 2 P :=
    MemLp.of_bound hmeas.aestronglyMeasurable (2 * (n : ℝ) * R)
      (Filter.Eventually.of_forall fun y => by
        rw [Real.norm_eq_abs, abs_of_nonneg (hf_bound y).1]
        exact (hf_bound y).2)
  have hl2_cont : Continuous (l2sq (n := n)) :=
    continuous_finsetSum _ fun i _ => (continuous_apply i).pow 2
  have hl2_bdd : BddAbove (l2sq '' K) := (hK.image hl2_cont).bddAbove
  have hsSup_nn : 0 ≤ sSup (l2sq '' K) := by
    obtain ⟨δ₀, hδ₀⟩ := id hne
    have h0 : 0 ≤ l2sq δ₀ := Finset.sum_nonneg fun i _ => sq_nonneg _
    exact le_trans h0 (le_csSup hl2_bdd ⟨δ₀, hδ₀, rfl⟩)
  have hmeas_inner : ∀ i : Fin n, Measurable (fun y : Fin n → ℝ =>
      ∫⁻ z, ENNReal.ofReal ((max (f y - f (Function.update y i z)) 0) ^ 2) ∂(μ i)) := by
    intro i
    have hupd : Measurable (fun p : (Fin n → ℝ) × ℝ => Function.update p.1 i p.2) := by
      refine Measurable.of_eval fun j => ?_
      by_cases hji : j = i
      · subst hji
        simp only [Function.update_self]
        exact measurable_snd
      · simp only [Function.update_of_ne hji]
        exact (measurable_pi_apply j).comp measurable_fst
    have hpair : Measurable (fun p : (Fin n → ℝ) × ℝ =>
        ENNReal.ofReal ((max (f p.1 - f (Function.update p.1 i p.2)) 0) ^ 2)) :=
      (((hmeas.comp measurable_fst).sub (hmeas.comp hupd)).max measurable_const).pow_const 2 |>.ennreal_ofReal
    exact hpair.lintegral_prod_right'
  have hpt : ∀ y : Fin n → ℝ,
      ∑ i : Fin n, ∫⁻ z, ENNReal.ofReal ((max (f y - f (Function.update y i z)) 0) ^ 2) ∂(μ i) ≤
        ENNReal.ofReal (sSup (l2sq '' K)) := by
    intro y
    obtain ⟨δhat, hδhat, hmax⟩ := hK.exists_isMaxOn hne (continuous_empProc τ hτ μ θs y).continuousOn
    have hfy : f y = empProc τ μ θs y δhat := by
      apply le_antisymm
      · refine csSup_le (hne.image _) ?_
        rintro _ ⟨δ, hδ, rfl⟩
        exact hmax hδ
      · exact le_csSup (hK.image (continuous_empProc τ hτ μ θs y)).bddAbove ⟨δhat, hδhat, rfl⟩
    have hcoord : ∀ (i : Fin n) (z : ℝ),
        (max (f y - f (Function.update y i z)) 0) ^ 2 ≤ (δhat i) ^ 2 := by
      intro i z
      have hfupd : empProc τ μ θs (Function.update y i z) δhat ≤ f (Function.update y i z) :=
        le_csSup (hK.image (continuous_empProc τ hτ μ θs (Function.update y i z))).bddAbove
          ⟨δhat, hδhat, rfl⟩
      have hhat_diff : lossHat τ (y - θs) δhat - lossHat τ (Function.update y i z - θs) δhat =
          ell τ (δhat i) (y i - θs i) - ell τ (δhat i) (z - θs i) := by
        rw [lossHat_eq_sum_ell, lossHat_eq_sum_ell, ← Finset.sum_sub_distrib]
        rw [Finset.sum_eq_single i]
        · simp [Function.update_self]
        · intro j _ hji
          simp [Function.update_of_ne hji]
        · intro hi; exact absurd (Finset.mem_univ i) hi
      have hdiff_le : f y - f (Function.update y i z) ≤ |δhat i| := by
        calc f y - f (Function.update y i z)
            ≤ empProc τ μ θs y δhat - empProc τ μ θs (Function.update y i z) δhat := by
              linarith
          _ ≤ |empProc τ μ θs y δhat - empProc τ μ θs (Function.update y i z) δhat| :=
              le_abs_self _
          _ ≤ |(lossHat τ (y - θs) δhat - lossExp τ μ θs δhat) -
                (lossHat τ (Function.update y i z - θs) δhat - lossExp τ μ θs δhat)| :=
              abs_abs_sub_abs_le_abs_sub _ _
          _ = |lossHat τ (y - θs) δhat - lossHat τ (Function.update y i z - θs) δhat| := by
              ring_nf
          _ = |ell τ (δhat i) (y i - θs i) - ell τ (δhat i) (z - θs i)| := by rw [hhat_diff]
          _ ≤ |δhat i| := abs_ell_sub_ell_le hτ
      have hmax_le : max (f y - f (Function.update y i z)) 0 ≤ |δhat i| :=
        max_le hdiff_le (abs_nonneg _)
      have hmax_nn : 0 ≤ max (f y - f (Function.update y i z)) 0 := le_max_right _ _
      calc (max (f y - f (Function.update y i z)) 0) ^ 2
          ≤ |δhat i| ^ 2 := by nlinarith
        _ = (δhat i) ^ 2 := sq_abs _
    calc ∑ i : Fin n, ∫⁻ z, ENNReal.ofReal ((max (f y - f (Function.update y i z)) 0) ^ 2) ∂(μ i)
        ≤ ∑ i : Fin n, ∫⁻ _z, ENNReal.ofReal ((δhat i) ^ 2) ∂(μ i) :=
          Finset.sum_le_sum fun i _ =>
            lintegral_mono fun z => ENNReal.ofReal_le_ofReal (hcoord i z)
      _ = ∑ i : Fin n, ENNReal.ofReal ((δhat i) ^ 2) := by
          refine Finset.sum_congr rfl fun i _ => by simp
      _ = ENNReal.ofReal (l2sq δhat) := by
          rw [l2sq, ENNReal.ofReal_sum_of_nonneg fun i _ => sq_nonneg _]
      _ ≤ ENNReal.ofReal (sSup (l2sq '' K)) :=
          ENNReal.ofReal_le_ofReal (le_csSup hl2_bdd ⟨δhat, hδhat, rfl⟩)
  have hevar : evariance f P ≤ ENNReal.ofReal (sSup (l2sq '' K)) := by
    calc evariance f P
        ≤ ∑ i : Fin n, ∫⁻ y, ∫⁻ z,
            ENNReal.ofReal ((max (f y - f (Function.update y i z)) 0) ^ 2) ∂(μ i) ∂P :=
          hES hmeas hmem
      _ = ∫⁻ y, ∑ i : Fin n, ∫⁻ z,
            ENNReal.ofReal ((max (f y - f (Function.update y i z)) 0) ^ 2) ∂(μ i) ∂P := by
          rw [lintegral_finsetSum _ fun i _ => hmeas_inner i]
      _ ≤ ∫⁻ _y, ENNReal.ofReal (sSup (l2sq '' K)) ∂P := lintegral_mono hpt
      _ = ENNReal.ofReal (sSup (l2sq '' K)) := by simp
  unfold variance
  calc (evariance f P).toReal
      ≤ (ENNReal.ofReal (sSup (l2sq '' K))).toReal :=
        ENNReal.toReal_mono ENNReal.ofReal_ne_top hevar
    _ = sSup (l2sq '' K) := ENNReal.toReal_ofReal hsSup_nn

/-! ### Expectation bound (finite step and compact-to-finite limit) -/

private lemma measurable_gRad {n : ℕ} (τ : ℝ) (θs : Fin n → ℝ)
    (T : Finset (Fin n → ℝ)) (hTne : T.Nonempty) :
    Measurable (fun y : Fin n → ℝ =>
      ∫ ξ, (T.sup' hTne fun δ => |∑ i, ξ i * ell τ (δ i) (y i - θs i)|) ∂(rademacher n)) := by
  have hpair : Measurable (fun p : (Fin n → ℝ) × (Fin n → ℝ) =>
      T.sup' hTne fun δ => |∑ i, p.2 i * ell τ (δ i) (p.1 i - θs i)|) := by
    refine measurable_finset_sup' T hTne fun δ _ => ?_
    refine (Finset.measurable_sum _ fun i _ => ?_).abs
    exact ((measurable_pi_apply i).comp measurable_snd).mul
      ((measurable_ell τ (δ i)).comp (((measurable_pi_apply i).comp measurable_fst).sub measurable_const))
  exact hpair.stronglyMeasurable.integral_prod_right'.measurable

private lemma concentration_symmetrize_finset {n : ℕ} (τ : ℝ) (hτ : 0 < τ ∧ τ < 1)
    (μ : Fin n → Measure ℝ) [∀ i, IsProbabilityMeasure (μ i)] (θs : Fin n → ℝ)
    (K : Set (Fin n → ℝ)) (R : ℝ) (hR_nn : 0 ≤ R) (hK_R : ∀ δ ∈ K, ‖δ‖ ≤ R)
    (T : Finset (Fin n → ℝ)) (hTne : T.Nonempty)
    (hTK : (T : Set (Fin n → ℝ)) ⊆ K) :
    ∫ y, (T.sup' hTne fun δ => empProc τ μ θs y δ) ∂(Measure.pi μ) ≤
      2 * ∫ y, (∫ ξ, (T.sup' hTne fun δ => |∑ i, ξ i * ell τ (δ i) (y i - θs i)|) ∂(rademacher n))
        ∂(Measure.pi μ) := by
  let clamp : ℝ → ℝ := fun t => max (-R) (min R t)
  let φ : Fin n → (Fin n → ℝ) → ℝ → ℝ :=
    fun i δ x => ell τ (clamp (δ i)) (x - θs i)
  have hclamp_abs : ∀ t : ℝ, |clamp t| ≤ R := fun t => by
    rw [abs_le]
    exact ⟨le_max_left _ _, max_le (by linarith) (min_le_left _ _)⟩
  have hclamp_on : ∀ δ ∈ T, ∀ i : Fin n, clamp (δ i) = δ i := fun δ hδ i => by
    have hle : |δ i| ≤ R :=
      le_trans (by simpa [Real.norm_eq_abs] using norm_le_pi_norm δ i) (hK_R δ (hTK hδ))
    have habs := abs_le.mp hle
    simp only [clamp, min_eq_right habs.2, max_eq_right habs.1]
  have hφ_meas : ∀ i δ, Measurable (φ i δ) := fun i δ =>
    (measurable_ell τ (clamp (δ i))).comp (measurable_id.sub measurable_const)
  have hφ_bound : ∀ i δ x, |φ i δ x| ≤ R := fun i δ x =>
    le_trans (abs_ell_le hτ) (hclamp_abs (δ i))
  have hsym := BQTF.Prob.symmetrization_finset μ T hTne φ hφ_meas R hφ_bound
  have hlhs_eq :
      (fun y => T.sup' hTne fun δ => empProc τ μ θs y δ) =
      fun y => T.sup' hTne fun δ => |∑ i, (φ i δ (y i) - ∫ x, φ i δ x ∂(μ i))| := by
    funext y
    refine Finset.sup'_congr hTne rfl fun δ hδ => ?_
    unfold empProc
    rw [lossHat_eq_sum_ell, lossExp_eq_sum_integral_ell τ hτ μ θs δ, ← Finset.sum_sub_distrib]
    congr 1
    refine Finset.sum_congr rfl fun i _ => ?_
    simp only [φ, hclamp_on δ hδ i]
  have hrhs_eq :
      (fun y : Fin n → ℝ => ∫ ξ, (T.sup' hTne fun δ => |∑ i, ξ i * φ i δ (y i)|) ∂(rademacher n)) =
      fun y : Fin n → ℝ => ∫ ξ, (T.sup' hTne fun δ => |∑ i, ξ i * ell τ (δ i) (y i - θs i)|) ∂(rademacher n) := by
    funext y
    congr 1
    funext ξ
    refine Finset.sup'_congr hTne rfl fun δ hδ => ?_
    congr 1
    refine Finset.sum_congr rfl fun i _ => ?_
    simp only [φ, hclamp_on δ hδ i]
  rw [hlhs_eq, ← hrhs_eq]
  exact hsym

private lemma sup'_abs_nonneg {α : Type*} (T : Finset α) (hT : T.Nonempty) (g : α → ℝ) :
    0 ≤ T.sup' hT (fun a => |g a|) := by
  obtain ⟨a, ha⟩ := id hT
  exact le_trans (abs_nonneg (g a)) (Finset.le_sup' (f := fun x => |g x|) ha)

private lemma concentration_contract_finset {n : ℕ} (τ : ℝ) (hτ : 0 < τ ∧ τ < 1)
    (μ : Fin n → Measure ℝ) [∀ i, IsProbabilityMeasure (μ i)] (θs : Fin n → ℝ)
    (T : Finset (Fin n → ℝ)) (hTne : T.Nonempty)
    (hContr : ∀ (φ : Fin n → ℝ → ℝ), (∀ i, φ i 0 = 0) →
      (∀ i u v, |φ i u - φ i v| ≤ |u - v|) →
      ∫ ξ, T.sup' hTne (fun δ => |∑ i, ξ i * φ i (δ i)|) ∂(rademacher n) ≤
        2 * ∫ ξ, T.sup' hTne (fun δ => dot ξ δ) ∂(rademacher n)) :
    ∫ y, (∫ ξ, (T.sup' hTne fun δ => |∑ i, ξ i * ell τ (δ i) (y i - θs i)|) ∂(rademacher n))
        ∂(Measure.pi μ) ≤
      2 * ∫ ξ, (T.sup' hTne fun δ => dot ξ δ) ∂(rademacher n) := by
  have hgRad_le : ∀ y : Fin n → ℝ,
      (∫ ξ, (T.sup' hTne fun δ => |∑ i, ξ i * ell τ (δ i) (y i - θs i)|) ∂(rademacher n)) ≤
        2 * ∫ ξ, (T.sup' hTne fun δ => dot ξ δ) ∂(rademacher n) := fun y =>
    hContr
      (fun i t => ell τ t (y i - θs i))
      (fun i => (ell_props τ (y i - θs i) hτ).2.1)
      (fun i u v => (ell_props τ (y i - θs i) hτ).2.2.1 u v)
  have hgRad_nn : ∀ y : Fin n → ℝ,
      0 ≤ ∫ ξ, (T.sup' hTne fun δ => |∑ i, ξ i * ell τ (δ i) (y i - θs i)|) ∂(rademacher n) :=
    fun y => integral_nonneg fun ξ => sup'_abs_nonneg T hTne (fun δ => ∑ i, ξ i * ell τ (δ i) (y i - θs i))
  have hgRad_int : Integrable (fun y : Fin n → ℝ =>
      ∫ ξ, (T.sup' hTne fun δ => |∑ i, ξ i * ell τ (δ i) (y i - θs i)|) ∂(rademacher n))
      (Measure.pi μ) :=
    Integrable.of_bound (measurable_gRad τ θs T hTne).aestronglyMeasurable
      (2 * ∫ ξ, (T.sup' hTne fun δ => dot ξ δ) ∂(rademacher n))
      (Filter.Eventually.of_forall fun y => by
        rw [Real.norm_eq_abs, abs_of_nonneg (hgRad_nn y)]
        exact hgRad_le y)
  calc (∫ y, (∫ ξ, (T.sup' hTne fun δ => |∑ i, ξ i * ell τ (δ i) (y i - θs i)|) ∂(rademacher n))
          ∂(Measure.pi μ))
      ≤ ∫ _y, (2 * ∫ ξ, (T.sup' hTne fun δ => dot ξ δ) ∂(rademacher n)) ∂(Measure.pi μ) :=
        integral_mono hgRad_int (integrable_const _) hgRad_le
    _ = 2 * ∫ ξ, (T.sup' hTne fun δ => dot ξ δ) ∂(rademacher n) := by
        rw [integral_const, probReal_univ, one_smul]

private lemma concentration_expectation_finset {n : ℕ} (τ : ℝ) (hτ : 0 < τ ∧ τ < 1)
    (μ : Fin n → Measure ℝ) [∀ i, IsProbabilityMeasure (μ i)] (θs : Fin n → ℝ)
    (K : Set (Fin n → ℝ)) (R : ℝ) (hR_nn : 0 ≤ R) (hK_R : ∀ δ ∈ K, ‖δ‖ ≤ R)
    (T : Finset (Fin n → ℝ)) (hTne : T.Nonempty)
    (hTK : (T : Set (Fin n → ℝ)) ⊆ K)
    (hContr : ∀ (φ : Fin n → ℝ → ℝ), (∀ i, φ i 0 = 0) →
      (∀ i u v, |φ i u - φ i v| ≤ |u - v|) →
      ∫ ξ, T.sup' hTne (fun δ => |∑ i, ξ i * φ i (δ i)|) ∂(rademacher n) ≤
        2 * ∫ ξ, T.sup' hTne (fun δ => dot ξ δ) ∂(rademacher n)) :
    ∫ y, (T.sup' hTne fun δ => empProc τ μ θs y δ) ∂(Measure.pi μ) ≤
      4 * ∫ ξ, (T.sup' hTne fun δ => dot ξ δ) ∂(rademacher n) := by
  have h1 := concentration_symmetrize_finset τ hτ μ θs K R hR_nn hK_R T hTne hTK
  have h2 := concentration_contract_finset τ hτ μ θs T hTne hContr
  linarith

/-- Expectation bound in Lemma `pf:lem:conc`, parameterized by the Ledoux–Talagrand
contraction inequality (owned by CP-OPUS2 in `BQTF/Prob/Contraction.lean`). -/
theorem concentration_expectation_of_contraction {n : ℕ} (τ : ℝ) (hτ : 0 < τ ∧ τ < 1)
    (μ : Fin n → Measure ℝ) [∀ i, IsProbabilityMeasure (μ i)] (θs : Fin n → ℝ)
    (K : Set (Fin n → ℝ)) (hK : IsCompact K) (hsymm : ∀ δ ∈ K, -δ ∈ K) (hne : K.Nonempty)
    (R : ℝ) (hR_nn : 0 ≤ R) (hK_R : ∀ δ ∈ K, ‖δ‖ ≤ R)
    (hContr : ∀ (T : Finset (Fin n → ℝ)) (hT : T.Nonempty),
      (∀ δ ∈ T, -δ ∈ T) → ∀ (φ : Fin n → ℝ → ℝ), (∀ i, φ i 0 = 0) →
      (∀ i u v, |φ i u - φ i v| ≤ |u - v|) →
      ∫ ξ, T.sup' hT (fun δ => |∑ i, ξ i * φ i (δ i)|) ∂(rademacher n) ≤
        2 * ∫ ξ, T.sup' hT (fun δ => dot ξ δ) ∂(rademacher n)) :
    ∫ y, GK τ μ θs K y ∂(Measure.pi μ) ≤
      4 * ∫ ξ, sSup ((fun δ => dot ξ δ) '' K) ∂(rademacher n) := by
  let P := Measure.pi μ
  let Rrad := rademacher n
  obtain ⟨T, hTne, hTK, hTsymm, hTmono, hdense⟩ := exists_symmetric_exhaustion hsymm hne
  have hfin : ∀ m : ℕ,
      ∫ y, ((T m).sup' (hTne m) fun δ => empProc τ μ θs y δ) ∂P ≤
        4 * ∫ ξ, ((T m).sup' (hTne m) fun δ => dot ξ δ) ∂ Rrad := fun m =>
    concentration_expectation_finset τ hτ μ θs K R hR_nn hK_R (T m) (hTne m) (hTK m)
      (hContr (T m) (hTne m) (hTsymm m))
  have htend_lhs : Filter.Tendsto
      (fun m => ∫ y, ((T m).sup' (hTne m) fun δ => empProc τ μ θs y δ) ∂P)
      Filter.atTop (nhds (∫ y, GK τ μ θs K y ∂P)) := by
    refine MeasureTheory.tendsto_integral_of_dominated_convergence
      (fun _ => 2 * (n : ℝ) * R) ?_ (integrable_const _) ?_ ?_
    · intro m
      exact (measurable_finset_sup' (T m) (hTne m) fun δ _ => measurable_empProc_y τ μ θs δ).aestronglyMeasurable
    · intro m
      refine Filter.Eventually.of_forall fun y => ?_
      rw [Real.norm_eq_abs, abs_of_nonneg (le_trans (abs_nonneg _)
        (Finset.le_sup' (f := fun δ => empProc τ μ θs y δ) (hTne m).choose_spec))]
      refine Finset.sup'_le (hTne m) _ fun δ hδ => ?_
      exact le_trans (empProc_le_bound τ hτ μ θs y δ) (by gcongr; exact hK_R δ (hTK m hδ))
    · refine Filter.Eventually.of_forall fun y => ?_
      exact tendsto_finset_sup'_sSup hK hne hTne hTK hTmono hdense (continuous_empProc τ hτ μ θs y)
  have htend_rhs : Filter.Tendsto
      (fun m => 4 * ∫ ξ, ((T m).sup' (hTne m) fun δ => dot ξ δ) ∂ Rrad)
      Filter.atTop (nhds (4 * ∫ ξ, sSup ((fun δ => dot ξ δ) '' K) ∂ Rrad)) := by
    refine Filter.Tendsto.const_mul 4 ?_
    refine MeasureTheory.tendsto_integral_of_dominated_convergence
      (fun _ => (n : ℝ) * R) ?_ (integrable_const _) ?_ ?_
    · intro m
      exact (measurable_finset_sup' (T m) (hTne m) fun δ _ =>
        Finset.measurable_sum _ fun i _ => (measurable_pi_apply i).mul measurable_const).aestronglyMeasurable
    · intro m
      filter_upwards [BQTF.Prob.ae_rademacher_eq_neg_one_or_one n] with ξ hξ
      have hnn : 0 ≤ (T m).sup' (hTne m) fun δ => dot ξ δ := by
        obtain ⟨δ₀, hδ₀⟩ := hTne m
        have h1 : dot ξ δ₀ ≤ (T m).sup' (hTne m) fun δ => dot ξ δ :=
          Finset.le_sup' (f := fun δ => dot ξ δ) hδ₀
        have h2 : dot ξ (-δ₀) ≤ (T m).sup' (hTne m) fun δ => dot ξ δ :=
          Finset.le_sup' (f := fun δ => dot ξ δ) (hTsymm m δ₀ hδ₀)
        have h3 : dot ξ (-δ₀) = -dot ξ δ₀ := by simp [dot, Finset.sum_neg_distrib]
        linarith
      rw [Real.norm_eq_abs, abs_of_nonneg hnn]
      refine Finset.sup'_le (hTne m) _ fun δ hδ => ?_
      calc dot ξ δ
          ≤ |dot ξ δ| := le_abs_self _
        _ ≤ ∑ i : Fin n, |ξ i * δ i| := Finset.abs_sum_le_sum_abs _ _
        _ ≤ ∑ _i : Fin n, R := Finset.sum_le_sum fun i _ => by
            rw [abs_mul]
            have hξ1 : |ξ i| = 1 := by rcases hξ i with h | h <;> simp [h]
            rw [hξ1, one_mul]
            exact le_trans (by simpa [Real.norm_eq_abs] using norm_le_pi_norm δ i) (hK_R δ (hTK m hδ))
        _ = (n : ℝ) * R := by simp
    · refine Filter.Eventually.of_forall fun ξ => ?_
      have hcont : Continuous (fun δ : Fin n → ℝ => dot ξ δ) :=
        continuous_finsetSum _ fun i _ => continuous_const.mul (continuous_apply i)
      exact tendsto_finset_sup'_sSup hK hne hTne hTK hTmono hdense hcont
  exact le_of_tendsto_of_tendsto htend_lhs htend_rhs (Filter.Eventually.of_forall hfin)

/-! ### Main concentration theorem (Lemma `pf:lem:conc`) -/

/-- Lemma `pf:lem:conc`: for `K` compact and symmetric (and nonempty), `G_K` is integrable,
`E G_K ≤ 4 E sup_K ⟨ξ, δ⟩` and `Var(G_K) ≤ sup_K ‖δ‖₂²`. Only independence of the
observations is used. -/
theorem concentration {n : ℕ} (τ : ℝ) (hτ : 0 < τ ∧ τ < 1) (μ : Fin n → Measure ℝ)
    (hμ : ∀ i, IsProbabilityMeasure (μ i)) (θs : Fin n → ℝ) (K : Set (Fin n → ℝ))
    (hK : IsCompact K) (hsymm : ∀ δ ∈ K, -δ ∈ K) (hne : K.Nonempty) :
    Integrable (GK τ μ θs K) (Measure.pi μ) ∧
    ∫ y, GK τ μ θs K y ∂(Measure.pi μ) ≤
      4 * ∫ ξ, sSup ((fun δ => dot ξ δ) '' K) ∂(rademacher n) ∧
    variance (GK τ μ θs K) (Measure.pi μ) ≤ sSup (l2sq '' K) := by
  have : ∀ i, IsProbabilityMeasure (μ i) := hμ
  obtain ⟨hGK_meas, R, hR_nn, hK_R, hGK_bound⟩ :=
    gk_measurable_and_bounded τ hτ μ θs hK hsymm hne
  have hGK_int : Integrable (GK τ μ θs K) (Measure.pi μ) :=
    Integrable.of_bound hGK_meas.aestronglyMeasurable (2 * (n : ℝ) * R)
      (Filter.Eventually.of_forall fun y => by
        rw [Real.norm_eq_abs, abs_of_nonneg (hGK_bound y).1]
        exact (hGK_bound y).2)
  refine ⟨hGK_int,
    concentration_expectation_of_contraction τ hτ μ θs K hK hsymm hne R hR_nn hK_R
      (fun T hT hs φ h0 hL => BQTF.Prob.contraction_abs T hT hs φ h0 hL),
    concentration_variance_of_efronStein τ hτ μ hμ θs K hK hsymm hne
      (fun hfm hf => BQTF.Prob.efronStein_oneSided μ hfm hf)⟩

end BQTF
