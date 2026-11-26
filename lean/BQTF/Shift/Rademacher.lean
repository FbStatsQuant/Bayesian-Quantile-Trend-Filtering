import BQTF.Basic

open Filter MeasureTheory ProbabilityTheory Finset
open scoped ENNReal

noncomputable section

namespace BQTF

/-- The one-dimensional Rademacher law `(δ_{−1} + δ_1)/2` is a probability measure. -/
instance rademacher1_probability : IsProbabilityMeasure rademacher1 := by
  constructor
  simp [rademacher1, smul_eq_mul]
  rw [← mul_two, ENNReal.inv_mul_cancel (by norm_num) (by simp)]

/-- The `n`-fold product Rademacher law is a probability measure. -/
instance rademacher_probability (n : ℕ) : IsProbabilityMeasure (rademacher n) := by
  unfold rademacher
  infer_instance

private theorem integral_rademacher1 (f : ℝ → ℝ) :
    ∫ x, f x ∂rademacher1 = (f (-1) + f 1) / 2 := by
  rw [rademacher1, integral_smul_measure,
    integral_add_measure (integrable_dirac (by simp)) (integrable_dirac (by simp))]
  simp [smul_eq_mul, div_eq_mul_inv, mul_comm]

private theorem ae_rademacher1_mem : ∀ᵐ x ∂rademacher1, x ∈ Set.Icc (-1 : ℝ) 1 := by
  rw [ae_iff]
  simp [rademacher1, Measure.smul_apply, Measure.add_apply]

/-- Every continuous real function of the sign vector is integrable, since its law is
supported on a compact cube. -/
theorem integrable_rademacher {n : ℕ} {f : (Fin n → ℝ) → ℝ} (hf : Continuous f) :
    Integrable f (rademacher n) := by
  let S : Set (Fin n → ℝ) := Set.univ.pi fun _ => Set.Icc (-1 : ℝ) 1
  have hS : IsCompact S := isCompact_univ_pi fun _ => isCompact_Icc
  obtain ⟨C, hC⟩ := hS.bddAbove_image hf.norm.continuousOn
  refine Integrable.of_bound hf.aestronglyMeasurable C ?_
  have hi (i : Fin n) : ∀ᵐ ξ ∂rademacher n, ξ i ∈ Set.Icc (-1 : ℝ) 1 :=
    (Measure.quasiMeasurePreserving_eval (fun _ => rademacher1) i).ae ae_rademacher1_mem
  filter_upwards [eventually_all.mpr hi] with ξ hξ
  exact hC ⟨ξ, Set.mem_univ_pi.mpr hξ, rfl⟩

private theorem integral_rademacher_coord {n : ℕ} (i : Fin n) (f : ℝ → ℝ)
    (hf : Measurable f) : ∫ ξ, f (ξ i) ∂rademacher n = (f (-1) + f 1) / 2 := by
  rw [← integral_rademacher1]
  have h := measurePreserving_eval (fun _ : Fin n => rademacher1) i
  have hg : AEStronglyMeasurable f ((rademacher n).map (Function.eval i)) :=
    hf.aestronglyMeasurable
  calc
    _ = ∫ x, f x ∂(rademacher n).map (Function.eval i) :=
      (integral_map h.measurable.aemeasurable hg).symm
    _ = _ := congrArg (fun μ => ∫ x, f x ∂μ) h.map_eq

private theorem integral_rademacher_mul {n : ℕ} (i j : Fin n) :
    ∫ ξ, ξ i * ξ j ∂rademacher n = if i = j then 1 else 0 := by
  split_ifs with hij
  · subst j
    rw [integral_rademacher_coord i (fun x => x * x) (by fun_prop)]
    norm_num
  · have hInd : iIndepFun (fun (i : Fin n) (ξ : Fin n → ℝ) => ξ i) (rademacher n) :=
      iIndepFun_pi (X := fun _ => id) (fun _ => aemeasurable_id)
    rw [(hInd.indepFun hij).integral_fun_mul_eq_mul_integral
      (measurable_pi_apply i).aestronglyMeasurable (measurable_pi_apply j).aestronglyMeasurable]
    change ((∫ ξ, id (ξ i) ∂rademacher n) * ∫ ξ, id (ξ j) ∂rademacher n) = _
    rw [integral_rademacher_coord i id measurable_id, integral_rademacher_coord j id measurable_id]
    norm_num

/-- Rademacher covariance is the identity. -/
theorem integral_rademacher_dot_sq {n : ℕ} (a : Fin n → ℝ) :
    ∫ ξ, (dot ξ a) ^ 2 ∂rademacher n = l2sq a := by
  have hexpand (ξ : Fin n → ℝ) :
      (dot ξ a) ^ 2 = ∑ i, ∑ j, (a i * a j) * (ξ i * ξ j) := by
    unfold dot
    rw [pow_two, Finset.sum_mul]
    simp_rw [Finset.mul_sum]
    exact Finset.sum_congr rfl fun i _ =>
      Finset.sum_congr rfl fun j _ => by ring
  simp_rw [hexpand]
  rw [integral_finsetSum _ (fun i _ => integrable_rademacher (by fun_prop))]
  have hint (i : Fin n) :
      (∫ ξ, ∑ j, (a i * a j) * (ξ i * ξ j) ∂rademacher n) =
        ∑ j, ∫ ξ, (a i * a j) * (ξ i * ξ j) ∂rademacher n :=
    integral_finsetSum _ (fun j _ => integrable_rademacher (by fun_prop))
  simp_rw [hint, integral_const_mul, integral_rademacher_mul]
  unfold l2sq
  refine Finset.sum_congr rfl fun i _ => ?_
  rw [Finset.sum_eq_single i]
  · simp [pow_two]
  · intro j _ hji
    simp [Ne.symm hji]
  · simp

private theorem integral_exp_rademacher_dot {n : ℕ} (a : Fin n → ℝ) (t : ℝ) :
    ∫ ξ, Real.exp (t * dot ξ a) ∂rademacher n ≤ Real.exp (l2sq a * t ^ 2 / 2) := by
  have hexpand (ξ : Fin n → ℝ) :
      Real.exp (t * dot ξ a) = ∏ i, Real.exp ((t * a i) * ξ i) := by
    rw [← Real.exp_sum]
    congr 1
    simp only [dot, Finset.mul_sum]
    exact Finset.sum_congr rfl fun i _ => by ring
  simp_rw [hexpand]
  rw [rademacher, integral_fintype_prod_eq_prod (fun i x => Real.exp ((t * a i) * x))]
  simp_rw [integral_rademacher1]
  calc
    _ = ∏ i, Real.cosh (t * a i) := by
      apply Finset.prod_congr rfl
      intro i _
      rw [Real.cosh_eq]
      ring_nf
    _ ≤ ∏ i, Real.exp ((t * a i) ^ 2 / 2) :=
      Finset.prod_le_prod₀ (fun i _ => (Real.cosh_pos _).le) (fun i _ => Real.cosh_le_exp_half_sq _)
    _ = _ := by
      rw [← Real.exp_sum]
      congr 1
      simp only [l2sq, Finset.sum_mul, Finset.sum_div]
      exact Finset.sum_congr rfl fun i _ => by ring

private theorem univ_nonempty_of_pos {m : ℕ} (hm : 0 < m) : (univ : Finset (Fin m)).Nonempty :=
  ⟨⟨0, hm⟩, mem_univ _⟩

/-- The maximum absolute dot product over a nonempty finite collection of columns. -/
def rademacherMax {m n : ℕ} (hm : 0 < m) (v : Fin m → Fin n → ℝ) (ξ : Fin n → ℝ) : ℝ :=
  Finset.univ.sup' (univ_nonempty_of_pos hm) (fun j => |dot ξ (v j)|)

/-- Each column term is at most the maximum: `|⟨ξ, v_j⟩| ≤ rademacherMax hm v ξ`. -/
theorem le_rademacherMax {m n : ℕ} (hm : 0 < m) (v : Fin m → Fin n → ℝ) (ξ : Fin n → ℝ)
    (j : Fin m) : |dot ξ (v j)| ≤ rademacherMax hm v ξ := by
  unfold rademacherMax
  exact Finset.le_sup' (fun j => |dot ξ (v j)|) (Finset.mem_univ j)

/-- `ξ ↦ max_j |⟨ξ, v_j⟩|` is continuous. -/
theorem continuous_rademacherMax {m n : ℕ} (hm : 0 < m) (v : Fin m → Fin n → ℝ) :
    Continuous (rademacherMax hm v) := by
  exact Continuous.finset_sup'_apply (univ_nonempty_of_pos hm) (by unfold dot; fun_prop)

/-- Log-sum-exp bounds the expected maximum of the two signs of each column. -/
theorem integral_rademacherMax_le {m n : ℕ} (hm : 0 < m) (v : Fin m → Fin n → ℝ)
    {B : ℝ} (hB : 0 < B) (hv : ∀ j, l2sq (v j) ≤ B ^ 2) :
    ∫ ξ, rademacherMax hm v ξ ∂rademacher n ≤ B * Real.sqrt (2 * Real.log (2 * m)) := by
  let M := rademacherMax hm v
  have hM := continuous_rademacherMax hm v
  have h2m : 1 < (2 : ℝ) * m := by
    have hm' : (1 : ℝ) ≤ m := by exact_mod_cast hm
    linarith
  let L := Real.log (2 * (m : ℝ))
  have hL : 0 < L := Real.log_pos h2m
  let q := Real.sqrt (2 * L)
  have hq : 0 < q := by dsimp [q]; positivity
  let t := q / B
  have ht : 0 < t := div_pos hq hB
  have hterm (a : Fin n → ℝ) (ha : l2sq a ≤ B ^ 2) :
      ∫ ξ, Real.exp (t * dot ξ a) ∂rademacher n ≤ Real.exp (B ^ 2 * t ^ 2 / 2) :=
    (integral_exp_rademacher_dot a t).trans (Real.exp_le_exp.mpr (by gcongr))
  have hneg (a : Fin n → ℝ) (ha : l2sq a ≤ B ^ 2) :
      ∫ ξ, Real.exp (t * -dot ξ a) ∂rademacher n ≤ Real.exp (B ^ 2 * t ^ 2 / 2) := by
    have hdot (ξ : Fin n → ℝ) : dot ξ (-a) = -dot ξ a := by
      simp only [dot, Pi.neg_apply, mul_neg, Finset.sum_neg_distrib]
    have hsq : l2sq (-a) = l2sq a := by simp [l2sq]
    simpa only [hdot] using hterm (-a) (hsq.trans_le ha)
  have hdom (ξ : Fin n → ℝ) : Real.exp (t * M ξ) ≤
      ∑ j, (Real.exp (t * dot ξ (v j)) + Real.exp (t * -dot ξ (v j))) := by
    obtain ⟨j, hj, heq⟩ := Finset.exists_mem_eq_sup' (univ_nonempty_of_pos hm)
      (fun j => |dot ξ (v j)|)
    change M ξ = |dot ξ (v j)| at heq
    rw [heq]
    refine le_trans ?_ (Finset.single_le_sum (f := fun j =>
      Real.exp (t * dot ξ (v j)) + Real.exp (t * -dot ξ (v j))) (fun _ _ => by positivity) hj)
    rcases le_total 0 (dot ξ (v j)) with h | h
    · rw [abs_of_nonneg h]
      exact le_add_of_nonneg_right (Real.exp_nonneg _)
    · rw [abs_of_nonpos h]
      exact le_add_of_nonneg_left (Real.exp_nonneg _)
  have hExpected : ∫ ξ, Real.exp (t * M ξ) ∂rademacher n ≤
      (2 * (m : ℝ)) * Real.exp (B ^ 2 * t ^ 2 / 2) := by
    refine (integral_mono (integrable_rademacher (by fun_prop))
      (integrable_rademacher (by unfold dot; fun_prop)) hdom).trans ?_
    rw [integral_finsetSum _ (fun j _ => integrable_rademacher (by unfold dot; fun_prop))]
    have hadd (j : Fin m) :
        (∫ ξ, Real.exp (t * dot ξ (v j)) + Real.exp (t * -dot ξ (v j)) ∂rademacher n) =
          (∫ ξ, Real.exp (t * dot ξ (v j)) ∂rademacher n) +
            ∫ ξ, Real.exp (t * -dot ξ (v j)) ∂rademacher n :=
      integral_add (integrable_rademacher (by unfold dot; fun_prop))
        (integrable_rademacher (by unfold dot; fun_prop))
    simp_rw [hadd]
    calc
      _ ≤ ∑ _ : Fin m, (Real.exp (B ^ 2 * t ^ 2 / 2) + Real.exp (B ^ 2 * t ^ 2 / 2)) :=
        Finset.sum_le_sum fun j _ => add_le_add (hterm _ (hv j)) (hneg _ (hv j))
      _ = _ := by simp; ring
  have hJensen := convexOn_exp.map_integral_le (μ := rademacher n)
    (f := fun ξ => t * M ξ) Real.continuous_exp.continuousOn isClosed_univ
    (Filter.Eventually.of_forall fun _ => Set.mem_univ _)
    (integrable_rademacher (by fun_prop))
    (integrable_rademacher (show Continuous (fun ξ => Real.exp (t * M ξ)) by fun_prop))
  rw [integral_const_mul] at hJensen
  have hlog : t * (∫ ξ, M ξ ∂rademacher n) ≤ L + B ^ 2 * t ^ 2 / 2 := by
    apply Real.exp_le_exp.mp
    rw [Real.exp_add, Real.exp_log (zero_lt_one.trans h2m)]
    exact hJensen.trans hExpected
  have hsq : q ^ 2 = 2 * L := Real.sq_sqrt (by positivity)
  have hcost : B ^ 2 * t ^ 2 / 2 = L := by
    dsimp [t]
    rw [div_pow]
    field_simp
    nlinarith
  apply (mul_le_mul_iff_right₀ ht).mp
  calc
    _ ≤ L + B ^ 2 * t ^ 2 / 2 := hlog
    _ = t * (B * q) := by rw [hcost]; dsimp [t]; field_simp; nlinarith

end BQTF
