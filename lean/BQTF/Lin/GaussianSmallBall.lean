import Mathlib

/-!
# Gaussian rotation glue and small-ball bounds

Helper module for `BQTF.SmallBall` (Lemma `pf:lem:sb`). Proves:
* `BQTF.Lin.gaussian_norm_sq_measure_le`: orthonormal-basis rotation invariance for `‖G g‖²` under
  `g ~ N(0, I_m)`, reducing `‖G g‖²` to `∑ q, G.singularValues q ^ 2 * γ_q ^ 2`.
* `BQTF.Lin.gaussianReal_abs_le_lower`: `P(|γ| ≤ t) ≥ 0.48 * min t 1` for `γ ~ N(0, 1)`, `t ≥ 0`.
* `BQTF.Lin.gaussian_weighted_sum_small_ball`: for weights `0 ≤ μ q ≤ b / (q + 1)^{2r}` and
  `K = ⌈(8 b / ((2r − 1) ϱ²))^{1/(2r − 1)}⌉`,
  `P(∑ q, μ q * γ_q² ≤ ϱ²) ≥ (3 / 4) * exp(-β_r * K)`.
-/

open MeasureTheory ProbabilityTheory Finset
open scoped ENNReal NNReal RealInnerProductSpace

noncomputable section

namespace BQTF.Lin

/-! ## Part 1: Gaussian rotation / singular-value diagonalization -/

/-- For a linear map `G : EuclideanSpace ℝ (Fin m) →ₗ[ℝ] EuclideanSpace ℝ (Fin n)`, the law of
`‖G g‖²` under i.i.d. `N(0, 1)` coordinates `g` equals the law of
`∑ q : Fin m, G.singularValues q ^ 2 * (γ q) ^ 2` under i.i.d. `N(0, 1)` coordinates `γ`. -/
theorem gaussian_norm_sq_measure_le {m n : ℕ}
    (G : EuclideanSpace ℝ (Fin m) →ₗ[ℝ] EuclideanSpace ℝ (Fin n)) (t : ℝ) :
    (Measure.pi fun _ : Fin m => gaussianReal 0 1) {g | ‖G (WithLp.toLp 2 g)‖ ^ 2 ≤ t} =
      (Measure.pi fun _ : Fin m => gaussianReal 0 1)
        {γ | ∑ q : Fin m, G.singularValues q ^ 2 * (γ q) ^ 2 ≤ t} := by
  let μG : Measure (Fin m → ℝ) := Measure.pi fun _ : Fin m => gaussianReal 0 1
  have hm : Module.finrank ℝ (EuclideanSpace ℝ (Fin m)) = m := finrank_euclideanSpace_fin
  have hS : (G.adjoint ∘ₗ G).IsSymmetric := G.isSymmetric_adjoint_comp_self
  let b : OrthonormalBasis (Fin m) ℝ (EuclideanSpace ℝ (Fin m)) := hS.eigenvectorBasis hm
  have hstd : μG.map (WithLp.toLp 2) = μG.map (fun γ => ∑ q : Fin m, γ q • b q) := by
    rw [map_pi_eq_stdGaussian, ← stdGaussian_eq_map_pi_orthonormalBasis b]
  let S : Set (EuclideanSpace ℝ (Fin m)) := {v | ‖G v‖ ^ 2 ≤ t}
  have hG_cont : Continuous (fun v : EuclideanSpace ℝ (Fin m) => ‖G v‖ ^ 2) :=
    (G.continuous_of_finiteDimensional.norm).pow 2
  have hS_meas : MeasurableSet S := measurableSet_le hG_cont.measurable measurable_const
  have htoLp_meas : Measurable (WithLp.toLp 2 : (Fin m → ℝ) → EuclideanSpace ℝ (Fin m)) := by
    fun_prop
  have hcomb_meas : Measurable (fun γ : Fin m → ℝ => ∑ q : Fin m, γ q • b q) := by fun_prop
  have hmeas_eq := congrArg (fun ν => ν S) hstd
  rw [Measure.map_apply htoLp_meas hS_meas, Measure.map_apply hcomb_meas hS_meas] at hmeas_eq
  -- Simplify `‖G (∑ q, γ q • b q)‖ ^ 2` to `∑ q, G.singularValues q ^ 2 * (γ q) ^ 2`.
  have hdiag : ∀ γ : Fin m → ℝ,
      ‖G (∑ q : Fin m, γ q • b q)‖ ^ 2 =
        ∑ q : Fin m, G.singularValues q ^ 2 * (γ q) ^ 2 := by
    intro γ
    let v : EuclideanSpace ℝ (Fin m) := ∑ q : Fin m, γ q • b q
    have hnorm : ‖G v‖ ^ 2 = ⟪v, (G.adjoint ∘ₗ G) v⟫ := by
      rw [← real_inner_self_eq_norm_sq (G v)]
      exact (LinearMap.adjoint_inner_right G v (G v)).symm
    rw [hnorm]
    have hGv : (G.adjoint ∘ₗ G) v = ∑ p : Fin m, (γ p * hS.eigenvalues hm p) • b p := by
      dsimp only [v]
      rw [map_sum]
      refine Finset.sum_congr rfl fun p _ => ?_
      rw [map_smul, hS.apply_eigenvectorBasis hm p, smul_smul]
      rfl
    rw [hGv]
    dsimp only [v]
    rw [sum_inner]
    refine Finset.sum_congr rfl fun q _ => ?_
    rw [inner_sum, Finset.sum_eq_single q]
    · rw [real_inner_smul_left, real_inner_smul_right, real_inner_self_eq_norm_sq,
        b.orthonormal.1 q, one_pow, mul_one, ← G.sq_singularValues_fin hm q]
      ring
    · intro p _ hpq
      rw [real_inner_smul_left, real_inner_smul_right, b.orthonormal.2 hpq.symm, mul_zero, mul_zero]
    · intro hq; exact (hq (Finset.mem_univ q)).elim
  have hpre : (fun γ : Fin m → ℝ => ∑ q : Fin m, γ q • b q) ⁻¹' S =
      {γ | ∑ q : Fin m, G.singularValues q ^ 2 * (γ q) ^ 2 ≤ t} := by
    ext γ
    simp only [Set.mem_preimage, Set.mem_ofPred_eq, S, hdiag γ]
  rw [hpre] at hmeas_eq
  exact hmeas_eq

/-! ## Part 2: 1D standard Gaussian small-ball bound -/

/-- `P(|γ| ≤ t) ≥ 0.48 * min t 1` for `γ ~ N(0, 1)` and `t ≥ 0`. -/
theorem gaussianReal_abs_le_lower (t : ℝ) (ht : 0 ≤ t) :
    ENNReal.ofReal (0.48 * min t 1) ≤ gaussianReal 0 1 {x : ℝ | |x| ≤ t} := by
  let s : ℝ := min t 1
  have hs0 : 0 ≤ s := le_min ht zero_le_one
  have hs1 : s ≤ 1 := min_le_right t 1
  have hst : s ≤ t := min_le_left t 1
  have hsub : Set.Icc (-s) s ⊆ {x : ℝ | |x| ≤ t} := fun x hx =>
    (abs_le.mpr hx).trans hst
  refine le_trans ?_ (measure_mono hsub)
  rw [gaussianReal_apply_eq_integral 0 one_ne_zero (Set.Icc (-s) s)]
  apply ENNReal.ofReal_le_ofReal
  let c : ℝ := (Real.sqrt (2 * Real.pi))⁻¹ * Real.exp (-(1 / 2 : ℝ))
  have hc_le : ∀ x ∈ Set.Icc (-s) s, c ≤ gaussianPDFReal 0 1 x := by
    intro x hx
    rw [gaussianPDFReal_def]
    simp only [sub_zero, NNReal.coe_one, mul_one]
    have hxsq : x ^ 2 ≤ 1 := by
      have habs : |x| ≤ 1 := (abs_le.mpr hx).trans hs1
      nlinarith [abs_nonneg x, sq_abs x]
    have hexp : Real.exp (-(1 / 2 : ℝ)) ≤ Real.exp (-x ^ 2 / 2) :=
      Real.exp_le_exp.mpr (by linarith)
    exact mul_le_mul_of_nonneg_left hexp (by positivity)
  have hint_const : IntegrableOn (fun _ : ℝ => c) (Set.Icc (-s) s) volume :=
    integrableOn_const (by rw [Real.volume_Icc]; exact ENNReal.ofReal_ne_top)
  have hint_pdf : IntegrableOn (gaussianPDFReal 0 1) (Set.Icc (-s) s) volume :=
    (integrable_gaussianPDFReal 0 1).restrict
  have hint_le : ∫ _ in Set.Icc (-s) s, c ≤ ∫ x in Set.Icc (-s) s, gaussianPDFReal 0 1 x :=
    setIntegral_mono_on hint_const hint_pdf measurableSet_Icc hc_le
  have hconst_eval : ∫ _ in Set.Icc (-s) s, c = (2 * s) * c := by
    rw [setIntegral_const, smul_eq_mul, Measure.real_def, Real.volume_Icc,
      ENNReal.toReal_ofReal (by linarith)]
    ring
  rw [hconst_eval] at hint_le
  refine le_trans ?_ hint_le
  -- Show `0.48 ≤ 2 * c`, i.e., `0.48 * √(2 * π) * √(exp 1) ≤ 2`.
  have hconst_num : (0.48 : ℝ) ≤ 2 * c := by
    dsimp only [c]
    have hsqrt_e : Real.exp (-(1 / 2 : ℝ)) = (Real.sqrt (Real.exp 1))⁻¹ := by
      rw [Real.sqrt_eq_rpow, ← Real.rpow_neg (Real.exp_pos 1).le,
        ← Real.exp_mul, one_mul]
    rw [hsqrt_e]
    have hpi_pos : 0 < Real.pi := Real.pi_pos
    have hexp_pos : 0 < Real.exp 1 := Real.exp_pos 1
    have hden_pos : 0 < Real.sqrt (2 * Real.pi * Real.exp 1) := by positivity
    have hprod : (Real.sqrt (2 * Real.pi))⁻¹ * (Real.sqrt (Real.exp 1))⁻¹ =
        (Real.sqrt (2 * Real.pi * Real.exp 1))⁻¹ := by
      rw [← mul_inv, ← Real.sqrt_mul (by positivity)]
    rw [hprod, ← div_eq_mul_inv, le_div_iff₀ hden_pos]
    have hsq : ((0.48 : ℝ) * Real.sqrt (2 * Real.pi * Real.exp 1)) ^ 2 ≤ (2 : ℝ) ^ 2 := by
      rw [mul_pow, Real.sq_sqrt (by positivity)]
      have hpi_lt : Real.pi < 3.1416 := Real.pi_lt_d4
      have he_lt : Real.exp 1 < 2.7182818286 := Real.exp_one_lt_d9
      nlinarith
    exact le_of_sq_le_sq hsq (by norm_num)
  nlinarith

/-! ## Part 3: Gaussian second moment, tail sum, and head/tail small-ball bound -/

/-- `E[γ²] = 1` for `γ ~ N(0, 1)` (in `ℝ≥0∞`). -/
lemma lintegral_ofReal_sq_gaussianReal :
    ∫⁻ x : ℝ, ENNReal.ofReal (x ^ 2) ∂(gaussianReal 0 1) = 1 := by
  have hvar : Var[id; gaussianReal 0 1] = 1 := by
    simp
  have hmean : ∫ x : ℝ, x ∂(gaussianReal 0 1) = 0 := by
    simp
  have hmem : MemLp id 2 (gaussianReal 0 1) := memLp_id_gaussianReal 2
  have hvar_eq : Var[id; gaussianReal 0 1] = ∫ x : ℝ, x ^ 2 ∂(gaussianReal 0 1) := by
    rw [variance_eq_integral hmem.aemeasurable]
    simp [hmean]
  have hint_sq : Integrable (fun x : ℝ => x ^ 2) (gaussianReal 0 1) := hmem.integrable_sq
  rw [← ofReal_integral_eq_lintegral_ofReal hint_sq (ae_of_all _ fun x => sq_nonneg x),
    ← hvar_eq, hvar, ENNReal.ofReal_one]

/-- Algebraic telescoping bound: for `p ≥ 1` and `K ≥ 1`,
`∑_{j = K}^{m - 1} 1 / (j + 1)^{p + 1} ≤ 1 / (p * K^p)`. -/
lemma sum_inv_pow_tail_le (p K m : ℕ) (hp : 1 ≤ p) (hK : 1 ≤ K) :
    ∑ q ∈ (Finset.univ : Finset (Fin m)).filter (fun q => K ≤ q.val),
        (1 : ℝ) / ((q.val + 1 : ℝ) ^ (p + 1)) ≤
      1 / ((p : ℝ) * (K : ℝ) ^ p) := by
  have hp_pos : (0 : ℝ) < p := Nat.cast_pos.mpr (by omega)
  -- Elementary step inequality: `p / (x + 1)^(p + 1) ≤ 1 / x^p - 1 / (x + 1)^p` for `x > 0`.
  have hstep : ∀ x : ℝ, 0 < x →
      (p : ℝ) / (x + 1) ^ (p + 1) ≤ 1 / x ^ p - 1 / (x + 1) ^ p := by
    intro x hx
    have hx1 : 0 < x + 1 := by linarith
    have hbern : ∀ k : ℕ, 1 ≤ k → x ^ k + (k : ℝ) * x ^ (k - 1) ≤ (x + 1) ^ k := by
      intro k hk
      induction k with
      | zero => omega
      | succ k ih =>
        by_cases hk0 : k = 0
        · subst hk0; simp
        · have ih' := ih (by omega)
          have hpow : x ^ (k + 1) = x ^ k * x := pow_succ x k
          have hpow1 : (x + 1) ^ (k + 1) = (x + 1) ^ k * (x + 1) := pow_succ (x + 1) k
          have hksub : k + 1 - 1 = k := Nat.add_sub_cancel k 1
          have hksub' : x ^ k = x ^ (k - 1) * x := by
            conv_lhs => rw [show k = (k - 1) + 1 by omega, pow_succ]
          rw [hksub, hpow1]
          push_cast
          have h1 : (x ^ k + (k : ℝ) * x ^ (k - 1)) * (x + 1) ≤ (x + 1) ^ k * (x + 1) :=
            mul_le_mul_of_nonneg_right ih' hx1.le
          have hnn : 0 ≤ (k : ℝ) * x ^ (k - 1) := by positivity
          nlinarith [hpow, hksub']
    have h1 := hbern p hp
    have h2 : (p : ℝ) * x ^ p ≤ (x + 1) * ((x + 1) ^ p - x ^ p) := by
      have hxp : x ^ p = x ^ (p - 1) * x := by
        conv_lhs => rw [show p = (p - 1) + 1 by omega, pow_succ]
      have hnn : 0 ≤ (p : ℝ) * x ^ (p - 1) := by positivity
      nlinarith
    have hden_pos : 0 < x ^ p * (x + 1) ^ (p + 1) := by positivity
    rw [div_sub_div _ _ (pow_ne_zero p hx.ne') (pow_ne_zero p hx1.ne'), one_mul, mul_one,
      div_le_div_iff₀ (pow_pos hx1 (p + 1)) (mul_pos (pow_pos hx p) (pow_pos hx1 p))]
    have hpow : (x + 1) ^ (p + 1) = (x + 1) ^ p * (x + 1) := pow_succ (x + 1) p
    rw [hpow]
    nlinarith [pow_pos hx1 p]
  -- Rewrite the filtered Fin sum as an `Ico K m` sum and telescope.
  have hsum_eq : ∑ q ∈ (Finset.univ : Finset (Fin m)).filter (fun q => K ≤ q.val),
      (1 : ℝ) / ((q.val + 1 : ℝ) ^ (p + 1)) =
      ∑ j ∈ Finset.Ico K m, (1 : ℝ) / ((j + 1 : ℝ) ^ (p + 1)) := by
    refine Finset.sum_nbij (fun q => q.val) ?_ ?_ ?_ ?_
    · intro q hq
      simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hq
      exact Finset.mem_Ico.mpr ⟨hq, q.isLt⟩
    · intro q₁ _ q₂ _ h; exact Fin.ext h
    · intro j hj
      rw [Finset.mem_coe, Finset.mem_Ico] at hj
      exact ⟨⟨j, hj.2⟩, by simp [hj.1], rfl⟩
    · intro q _; rfl
  rw [hsum_eq]
  by_cases hKm : m ≤ K
  · rw [Finset.Ico_eq_empty (not_lt.mpr hKm), Finset.sum_empty]
    positivity
  have hlt : K < m := not_le.mp hKm
  have htele : (p : ℝ) * ∑ j ∈ Finset.Ico K m, (1 : ℝ) / ((j + 1 : ℝ) ^ (p + 1)) ≤
      1 / (K : ℝ) ^ p := by
    rw [Finset.mul_sum]
    calc ∑ j ∈ Finset.Ico K m, (p : ℝ) * ((1 : ℝ) / ((j + 1 : ℝ) ^ (p + 1)))
        ≤ ∑ j ∈ Finset.Ico K m, ((1 : ℝ) / (j : ℝ) ^ p - 1 / ((j + 1 : ℝ) ^ p)) := by
          refine Finset.sum_le_sum fun j hj => ?_
          rw [mul_one_div]
          have hj_pos : (0 : ℝ) < j := Nat.cast_pos.mpr (by have := (Finset.mem_Ico.mp hj).1; omega)
          exact hstep (j : ℝ) hj_pos
      _ = 1 / (K : ℝ) ^ p - 1 / (m : ℝ) ^ p := by
          have h := Finset.sum_Ico_sub (f := fun j : ℕ => (1 : ℝ) / (j : ℝ) ^ p) hlt.le
          have hneg : ∑ j ∈ Finset.Ico K m, ((1 : ℝ) / (j : ℝ) ^ p - 1 / ((j + 1 : ℝ) ^ p)) =
              -(∑ j ∈ Finset.Ico K m, ((1 : ℝ) / ((j + 1 : ℕ) : ℝ) ^ p - 1 / (j : ℝ) ^ p)) := by
            rw [← Finset.sum_neg_distrib]
            refine Finset.sum_congr rfl fun j _ => ?_
            push_cast; ring
          rw [hneg, h]; ring
      _ ≤ 1 / (K : ℝ) ^ p := by
          have : (0 : ℝ) ≤ 1 / (m : ℝ) ^ p := by positivity
          linarith
  rw [le_div_iff₀ (by positivity)]
  calc (∑ j ∈ Finset.Ico K m, (1 : ℝ) / ((j + 1 : ℝ) ^ (p + 1))) * ((p : ℝ) * (K : ℝ) ^ p)
      = ((p : ℝ) * ∑ j ∈ Finset.Ico K m, (1 : ℝ) / ((j + 1 : ℝ) ^ (p + 1))) * (K : ℝ) ^ p := by
        ring
    _ ≤ (1 / (K : ℝ) ^ p) * (K : ℝ) ^ p :=
        mul_le_mul_of_nonneg_right htele (by positivity)
    _ = 1 := one_div_mul_cancel (pow_ne_zero p (Nat.cast_pos.mpr (by omega)).ne')

/-- Elementary factorial lower bound: `(K / e)^K ≤ K!`. -/
lemma pow_div_exp_le_factorial (K : ℕ) : ((K : ℝ) / Real.exp 1) ^ K ≤ (K.factorial : ℝ) := by
  have hsum := Real.sum_le_exp_of_nonneg (Nat.cast_nonneg K) (K + 1)
  have hterm : (K : ℝ) ^ K / (K.factorial : ℝ) ≤
      ∑ i ∈ Finset.range (K + 1), (K : ℝ) ^ i / (i.factorial : ℝ) :=
    Finset.single_le_sum (f := fun i => (K : ℝ) ^ i / (i.factorial : ℝ))
      (fun i _ => by positivity) (Finset.mem_range.mpr (Nat.lt_succ_self K))
  have h1 : (K : ℝ) ^ K / (K.factorial : ℝ) ≤ Real.exp (K : ℝ) := hterm.trans hsum
  have hfac_pos : (0 : ℝ) < K.factorial := Nat.cast_pos.mpr (Nat.factorial_pos K)
  have hexp_pow : (Real.exp 1) ^ K = Real.exp (K : ℝ) := by
    rw [← Real.exp_nat_mul, mul_one]
  rw [div_pow, hexp_pow, div_le_iff₀ (Real.exp_pos _)]
  rw [div_le_iff₀ hfac_pos] at h1
  linarith

/-- Small-ball constant `β_r = r + log(max{1, √(2r − 1) / 2} / 0.48)` from Lemma `pf:lem:sb`. -/
def betaR (r : ℕ) : ℝ :=
  (r : ℝ) + Real.log (max 1 (Real.sqrt (2 * (r : ℝ) - 1) / 2) / 0.48)

lemma betaR_pos (r : ℕ) (hr : 2 ≤ r) : 0 < betaR r := by
  unfold betaR
  have h1 : (1 : ℝ) ≤ max 1 (Real.sqrt (2 * (r : ℝ) - 1) / 2) / 0.48 := by
    have hm : (1 : ℝ) ≤ max 1 (Real.sqrt (2 * (r : ℝ) - 1) / 2) := le_max_left _ _
    rw [one_le_div (by norm_num)]
    linarith
  have hlog : 0 ≤ Real.log (max 1 (Real.sqrt (2 * (r : ℝ) - 1) / 2) / 0.48) :=
    Real.log_nonneg h1
  have hr_pos : (0 : ℝ) < r := Nat.cast_pos.mpr (by omega)
  linarith

/-- **Gaussian weighted-sum small-ball bound** (second paragraph of the proof of Lemma `pf:lem:sb`):
if `0 ≤ μ q ≤ b / (q + 1)^{2r}` for all `q : Fin m`, then for
`K = ⌈(8 b / ((2r − 1) ϱ²))^{1/(2r − 1)}⌉`,
`P(∑ q, μ q * γ_q² ≤ ϱ²) ≥ (3 / 4) * exp(-β_r * K)`. -/
theorem gaussian_weighted_sum_small_ball {m r : ℕ} (hr : 2 ≤ r)
    (μ : Fin m → ℝ) (hμ_nn : ∀ q, 0 ≤ μ q)
    {b ϱ : ℝ} (hb : 0 < b) (hϱ : 0 < ϱ)
    (hμ_bd : ∀ q : Fin m, μ q ≤ b / ((q.val + 1 : ℝ) ^ (2 * r))) :
    let K : ℕ := Nat.ceil ((8 * b / ((2 * (r : ℝ) - 1) * ϱ ^ 2)) ^ ((1 : ℝ) / (2 * r - 1)))
    ENNReal.ofReal ((3 / 4 : ℝ) * Real.exp (-(betaR r * K))) ≤
      (Measure.pi fun _ : Fin m => gaussianReal 0 1)
        {γ | ∑ q : Fin m, μ q * (γ q) ^ 2 ≤ ϱ ^ 2} := by
  intro K
  have hr_real : (2 : ℝ) ≤ r := Nat.ofNat_le_cast.mpr hr
  have h2r1_pos : (0 : ℝ) < 2 * (r : ℝ) - 1 := by linarith
  have h2r1_nat : 2 * r - 1 = (2 * r - 1 : ℕ) := rfl
  have h2r1_cast : ((2 * r - 1 : ℕ) : ℝ) = 2 * (r : ℝ) - 1 := by
    rw [Nat.cast_sub (by omega)]; push_cast; ring
  have hK_pos_real : (0 : ℝ) < (8 * b / ((2 * (r : ℝ) - 1) * ϱ ^ 2)) ^ ((1 : ℝ) / (2 * r - 1)) :=
    Real.rpow_pos_of_pos (by positivity) _
  have hK1 : 1 ≤ K := Nat.one_le_iff_ne_zero.mpr (Nat.ceil_pos.mpr hK_pos_real).ne'
  have hK_pos : (0 : ℝ) < K := Nat.cast_pos.mpr (by omega)
  have hK_ge : (8 * b / ((2 * (r : ℝ) - 1) * ϱ ^ 2)) ^ ((1 : ℝ) / (2 * r - 1)) ≤ (K : ℝ) :=
    Nat.le_ceil _
  have hK_pow : 8 * b / ((2 * (r : ℝ) - 1) * ϱ ^ 2) ≤ (K : ℝ) ^ (2 * r - 1) := by
    have h1 := Real.rpow_le_rpow hK_pos_real.le hK_ge h2r1_pos.le
    rw [← Real.rpow_mul (by positivity), one_div_mul_cancel h2r1_pos.ne', Real.rpow_one] at h1
    conv_rhs at h1 => rw [← h2r1_cast, Real.rpow_natCast]
    exact h1
  -- Split coordinates into `Head := {q | q.val < K}` and `Tail := {q | ¬ q.val < K}`.
  let pHead : Fin m → Prop := fun q => q.val < K
  let μG : Measure (Fin m → ℝ) := Measure.pi fun _ : Fin m => gaussianReal 0 1
  let μH : Measure ({q : Fin m // pHead q} → ℝ) := Measure.pi fun _ => gaussianReal 0 1
  let μT : Measure ({q : Fin m // ¬ pHead q} → ℝ) := Measure.pi fun _ => gaussianReal 0 1
  let tq : Fin m → ℝ := fun q => Real.sqrt (ϱ ^ 2 * (q.val + 1 : ℝ) ^ (2 * r) / (2 * b * K))
  let Ehead : Set ({q : Fin m // pHead q} → ℝ) := Set.univ.pi fun q => {x : ℝ | |x| ≤ tq q.1}
  let Etail : Set ({q : Fin m // ¬ pHead q} → ℝ) :=
    {γT | ∑ q : {q : Fin m // ¬ pHead q}, μ q.1 * (γT q) ^ 2 ≤ ϱ ^ 2 / 2}
  -- Step 1: Inclusion of `Ehead ×ˢ Etail` into the full event via `piEquivPiSubtypeProd`.
  let e := MeasurableEquiv.piEquivPiSubtypeProd (fun _ : Fin m => ℝ) pHead
  have hmp : MeasurePreserving e μG (μH.prod μT) :=
    measurePreserving_piEquivPiSubtypeProd (fun _ : Fin m => gaussianReal 0 1) pHead
  have hsub : e ⁻¹' (Ehead ×ˢ Etail) ⊆ {γ : Fin m → ℝ | ∑ q : Fin m, μ q * (γ q) ^ 2 ≤ ϱ ^ 2} := by
    intro γ hγ
    rcases hγ with ⟨hH, hT⟩
    change ∑ q : Fin m, μ q * (γ q) ^ 2 ≤ ϱ ^ 2
    rw [← Finset.sum_filter_add_sum_filter_not Finset.univ pHead]
    have hHead_le : ∑ q ∈ Finset.univ.filter pHead, μ q * (γ q) ^ 2 ≤ ϱ ^ 2 / 2 := by
      have hterm : ∀ q ∈ Finset.univ.filter pHead, μ q * (γ q) ^ 2 ≤ ϱ ^ 2 / (2 * (K : ℝ)) := by
        intro q hq
        have hq' : pHead q := (Finset.mem_filter.mp hq).2
        have hγq : |γ q| ≤ tq q := by
          have := hH ⟨q, hq'⟩ (Set.mem_univ _)
          simpa [e] using this
        have hsq : (γ q) ^ 2 ≤ ϱ ^ 2 * (q.val + 1 : ℝ) ^ (2 * r) / (2 * b * K) := by
          have h1 : |γ q| ^ 2 ≤ (tq q) ^ 2 :=
            pow_le_pow_left₀ (abs_nonneg _) hγq 2
          rw [sq_abs, Real.sq_sqrt (by positivity)] at h1
          exact h1
        calc μ q * (γ q) ^ 2
            ≤ (b / ((q.val + 1 : ℝ) ^ (2 * r))) *
                (ϱ ^ 2 * (q.val + 1 : ℝ) ^ (2 * r) / (2 * b * K)) :=
              mul_le_mul (hμ_bd q) hsq (sq_nonneg _) (by positivity)
          _ = ϱ ^ 2 / (2 * (K : ℝ)) := by
              have hq_pos : (0 : ℝ) < (q.val + 1 : ℝ) ^ (2 * r) := by positivity
              field_simp [hb.ne', hK_pos.ne', hq_pos.ne']
      calc ∑ q ∈ Finset.univ.filter pHead, μ q * (γ q) ^ 2
          ≤ ∑ _q ∈ Finset.univ.filter pHead, (ϱ ^ 2 / (2 * (K : ℝ))) :=
            Finset.sum_le_sum hterm
        _ = ((Finset.univ.filter pHead).card : ℝ) * (ϱ ^ 2 / (2 * (K : ℝ))) := by
            rw [Finset.sum_const, nsmul_eq_mul]
        _ ≤ (K : ℝ) * (ϱ ^ 2 / (2 * (K : ℝ))) := by
            have hcard : (Finset.univ.filter pHead).card ≤ K := by
              have h1 : (Finset.univ.filter pHead).card ≤ (Finset.range K).card := by
                refine Finset.card_le_card_of_injOn (fun q => q.val) ?_ ?_
                · intro q hq
                  rw [Finset.mem_coe, Finset.mem_filter] at hq
                  exact Finset.mem_coe.mpr (Finset.mem_range.mpr hq.2)
                · intro q₁ _ q₂ _ h; exact Fin.ext h
              simpa using h1
            exact mul_le_mul_of_nonneg_right (Nat.cast_le.mpr hcard) (by positivity)
        _ = ϱ ^ 2 / 2 := by field_simp [hK_pos.ne']
    have hTail_le : ∑ q ∈ Finset.univ.filter (fun q => ¬ pHead q), μ q * (γ q) ^ 2 ≤ ϱ ^ 2 / 2 := by
      have heq : ∑ q ∈ Finset.univ.filter (fun q => ¬ pHead q), μ q * (γ q) ^ 2 =
          ∑ q : {q : Fin m // ¬ pHead q}, μ q.1 * (γ q.1) ^ 2 := by
        symm
        refine Finset.sum_nbij (fun q => q.1) ?_ ?_ ?_ ?_
        · intro q _; exact Finset.mem_filter.mpr ⟨Finset.mem_univ _, q.2⟩
        · intro q₁ _ q₂ _ h; exact Subtype.ext h
        · intro q hq
          rw [Finset.mem_coe, Finset.mem_filter] at hq
          exact ⟨⟨q, hq.2⟩, Finset.mem_coe.mpr (Finset.mem_univ _), rfl⟩
        · intro q _; rfl
      rw [heq]
      simpa [e, Etail] using hT
    linarith
  -- Step 2: Product lower bound `μH Ehead * μT Etail ≤ μG {…}`.
  have hEhead_meas : MeasurableSet Ehead :=
    MeasurableSet.univ_pi fun _ => measurableSet_le measurable_abs measurable_const
  have hEtail_meas : MeasurableSet Etail :=
    measurableSet_le
      (Finset.measurable_sum _ fun q _ => measurable_const.mul ((measurable_pi_apply q).pow_const 2))
      measurable_const
  have hprod_le : μH Ehead * μT Etail ≤
      μG {γ : Fin m → ℝ | ∑ q : Fin m, μ q * (γ q) ^ 2 ≤ ϱ ^ 2} := by
    calc μH Ehead * μT Etail
        = (μH.prod μT) (Ehead ×ˢ Etail) := (Measure.prod_prod Ehead Etail).symm
      _ = μG (e ⁻¹' (Ehead ×ˢ Etail)) := (hmp.measure_preimage (hEhead_meas.prod hEtail_meas).nullMeasurableSet).symm
      _ ≤ μG {γ : Fin m → ℝ | ∑ q : Fin m, μ q * (γ q) ^ 2 ≤ ϱ ^ 2} := measure_mono hsub
  -- Step 3: Tail bound `3 / 4 ≤ μT Etail` via Markov's inequality.
  have hTail_sum : ∑ q : {q : Fin m // ¬ pHead q}, μ q.1 ≤ ϱ ^ 2 / 8 := by
    have h1 : ∑ q : {q : Fin m // ¬ pHead q}, μ q.1 =
        ∑ q ∈ (Finset.univ : Finset (Fin m)).filter (fun q => K ≤ q.val), μ q := by
      refine Finset.sum_nbij (fun q => q.1) ?_ ?_ ?_ ?_
      · intro q _
        have hge : K ≤ q.1.val := not_lt.mp q.2
        exact Finset.mem_filter.mpr ⟨Finset.mem_univ _, hge⟩
      · intro q₁ _ q₂ _ h; exact Subtype.ext h
      · intro q hq
        rw [Finset.mem_coe, Finset.mem_filter] at hq
        exact ⟨⟨q, not_lt.mpr hq.2⟩, Finset.mem_coe.mpr (Finset.mem_univ _), rfl⟩
      · intro q _; rfl
    rw [h1]
    calc ∑ q ∈ (Finset.univ : Finset (Fin m)).filter (fun q => K ≤ q.val), μ q
        ≤ ∑ q ∈ (Finset.univ : Finset (Fin m)).filter (fun q => K ≤ q.val),
            b * ((1 : ℝ) / ((q.val + 1 : ℝ) ^ ((2 * r - 1) + 1))) := by
          refine Finset.sum_le_sum fun q _ => ?_
          rw [show (2 * r - 1) + 1 = 2 * r by omega, mul_one_div]
          exact hμ_bd q
      _ = b * ∑ q ∈ (Finset.univ : Finset (Fin m)).filter (fun q => K ≤ q.val),
            (1 : ℝ) / ((q.val + 1 : ℝ) ^ ((2 * r - 1) + 1)) := by
          rw [← Finset.mul_sum]
      _ ≤ b * (1 / (((2 * r - 1 : ℕ) : ℝ) * (K : ℝ) ^ (2 * r - 1))) :=
          mul_le_mul_of_nonneg_left (sum_inv_pow_tail_le (2 * r - 1) K m (by omega) hK1) hb.le
      _ ≤ ϱ ^ 2 / 8 := by
          rw [h2r1_cast, mul_one_div, div_le_div_iff₀ (by positivity) (by norm_num)]
          rw [div_le_iff₀ (by positivity)] at hK_pow
          linarith
  have hTail_prob : ENNReal.ofReal (3 / 4 : ℝ) ≤ μT Etail := by
    have hlint : ∫⁻ γT, ENNReal.ofReal (∑ q : {q : Fin m // ¬ pHead q}, μ q.1 * (γT q) ^ 2) ∂μT ≤
        ENNReal.ofReal (ϱ ^ 2 / 8) := by
      have hsum_ofReal : ∀ γT : {q : Fin m // ¬ pHead q} → ℝ,
          ENNReal.ofReal (∑ q, μ q.1 * (γT q) ^ 2) =
            ∑ q, ENNReal.ofReal (μ q.1) * ENNReal.ofReal ((γT q) ^ 2) := by
        intro γT
        rw [ENNReal.ofReal_sum_of_nonneg fun q _ => mul_nonneg (hμ_nn q.1) (sq_nonneg _)]
        refine Finset.sum_congr rfl fun q _ => ENNReal.ofReal_mul (hμ_nn q.1)
      simp_rw [hsum_ofReal]
      have hmeas_t : ∀ q ∈ (Finset.univ : Finset {q : Fin m // ¬ pHead q}),
          Measurable (fun γT : {q : Fin m // ¬ pHead q} → ℝ =>
            ENNReal.ofReal (μ q.1) * ENNReal.ofReal ((γT q) ^ 2)) :=
        fun q _ => measurable_const.mul ((measurable_pi_apply q).pow_const 2).ennreal_ofReal
      rw [lintegral_finsetSum _ hmeas_t]
      have hterm : ∀ q : {q : Fin m // ¬ pHead q},
          ∫⁻ γT, ENNReal.ofReal (μ q.1) * ENNReal.ofReal ((γT q) ^ 2) ∂μT =
            ENNReal.ofReal (μ q.1) := by
        intro q
        rw [lintegral_const_mul _ ((measurable_pi_apply q).pow_const 2).ennreal_ofReal]
        have hmp_q := measurePreserving_eval (fun _ : {q : Fin m // ¬ pHead q} => gaussianReal 0 1) q
        have heval : ∫⁻ γT, ENNReal.ofReal ((γT q) ^ 2) ∂μT =
            ∫⁻ x : ℝ, ENNReal.ofReal (x ^ 2) ∂(gaussianReal 0 1) :=
          hmp_q.lintegral_comp (by fun_prop : Measurable fun x : ℝ => ENNReal.ofReal (x ^ 2))
        rw [heval, lintegral_ofReal_sq_gaussianReal, mul_one]
      simp_rw [hterm]
      rw [← ENNReal.ofReal_sum_of_nonneg fun q _ => hμ_nn q.1]
      exact ENNReal.ofReal_le_ofReal hTail_sum
    have hmarkov : ENNReal.ofReal (ϱ ^ 2 / 2) * μT Etailᶜ ≤ ENNReal.ofReal (ϱ ^ 2 / 8) := by
      have hsub_c : Etailᶜ ⊆
          {γT | ENNReal.ofReal (ϱ ^ 2 / 2) ≤
            ENNReal.ofReal (∑ q : {q : Fin m // ¬ pHead q}, μ q.1 * (γT q) ^ 2)} := by
        intro γT hγT
        have hlt : ϱ ^ 2 / 2 < ∑ q : {q : Fin m // ¬ pHead q}, μ q.1 * (γT q) ^ 2 := by
          simpa [Etail] using hγT
        exact ENNReal.ofReal_le_ofReal hlt.le
      calc ENNReal.ofReal (ϱ ^ 2 / 2) * μT Etailᶜ
          ≤ ENNReal.ofReal (ϱ ^ 2 / 2) *
              μT {γT | ENNReal.ofReal (ϱ ^ 2 / 2) ≤
                ENNReal.ofReal (∑ q, μ q.1 * (γT q) ^ 2)} :=
            mul_le_mul_of_nonneg_left (measure_mono hsub_c) zero_le
        _ ≤ ∫⁻ γT, ENNReal.ofReal (∑ q, μ q.1 * (γT q) ^ 2) ∂μT :=
            mul_meas_ge_le_lintegral₀
              ((Finset.measurable_sum _ fun q _ =>
                measurable_const.mul ((measurable_pi_apply q).pow_const 2)).ennreal_ofReal.aemeasurable)
              _
        _ ≤ ENNReal.ofReal (ϱ ^ 2 / 8) := hlint
    have hcompl_le : μT Etailᶜ ≤ ENNReal.ofReal (1 / 4 : ℝ) := by
      have hc0 : ENNReal.ofReal (ϱ ^ 2 / 2) ≠ 0 := (ENNReal.ofReal_pos.mpr (by positivity)).ne'
      have hctop : ENNReal.ofReal (ϱ ^ 2 / 2) ≠ ∞ := ENNReal.ofReal_ne_top
      have heq : ENNReal.ofReal (ϱ ^ 2 / 8) =
          ENNReal.ofReal (ϱ ^ 2 / 2) * ENNReal.ofReal (1 / 4 : ℝ) := by
        rw [← ENNReal.ofReal_mul (by positivity)]; congr 1; ring
      rw [heq] at hmarkov
      calc μT Etailᶜ = (ENNReal.ofReal (ϱ ^ 2 / 2))⁻¹ * (ENNReal.ofReal (ϱ ^ 2 / 2) * μT Etailᶜ) := by
            rw [← mul_assoc, ENNReal.inv_mul_cancel hc0 hctop, one_mul]
        _ ≤ (ENNReal.ofReal (ϱ ^ 2 / 2))⁻¹ *
              (ENNReal.ofReal (ϱ ^ 2 / 2) * ENNReal.ofReal (1 / 4 : ℝ)) :=
            mul_le_mul_of_nonneg_left hmarkov zero_le
        _ = ENNReal.ofReal (1 / 4 : ℝ) := by
            rw [← mul_assoc, ENNReal.inv_mul_cancel hc0 hctop, one_mul]
    have hadd := measure_add_measure_compl (μ := μT) hEtail_meas
    rw [measure_univ] at hadd
    have hsub34 : (1 : ℝ≥0∞) - ENNReal.ofReal (1 / 4 : ℝ) = ENNReal.ofReal (3 / 4 : ℝ) := by
      rw [← ENNReal.ofReal_one, ← ENNReal.ofReal_sub _ (by norm_num)]; norm_num
    rw [← hsub34]
    exact tsub_le_iff_right.mpr (hadd.symm.le.trans (add_le_add le_rfl hcompl_le))
  -- Step 4: Head bound `exp(-β_r * K) ≤ μH Ehead`.
  have hHead_prob : ENNReal.ofReal (Real.exp (-(betaR r * K))) ≤ μH Ehead := by
    rw [Measure.pi_pi]
    let θr : ℝ := 2 / Real.sqrt (2 * (r : ℝ) - 1)
    let cr : ℝ := 0.48 * min θr 1
    have hθr_pos : 0 < θr := by positivity
    have hcr_pos : 0 < cr := by positivity
    have hcr_le1 : cr ≤ 1 := by
      have : min θr 1 ≤ 1 := min_le_right _ _
      dsimp only [cr]; linarith
    -- For each `q ∈ Head`, `tq q ≥ θr * ((q.val + 1) / K)^r`, hence `P(|γ| ≤ tq q) ≥ cr * ((q.val + 1) / K)^r`.
    have hfac : ∀ q : {q : Fin m // pHead q},
        ENNReal.ofReal (cr * (((q.1.val + 1 : ℝ) / K) ^ r)) ≤
          gaussianReal 0 1 {x : ℝ | |x| ≤ tq q.1} := by
      intro q
      have htq_ge : θr * ((q.1.val + 1 : ℝ) / K) ^ r ≤ tq q.1 := by
        have hsq : (θr * ((q.1.val + 1 : ℝ) / K) ^ r) ^ 2 ≤
            ϱ ^ 2 * (q.1.val + 1 : ℝ) ^ (2 * r) / (2 * b * K) := by
          rw [mul_pow, div_pow, ← pow_mul, mul_comm r 2]
          rw [div_pow, Real.sq_sqrt h2r1_pos.le]
          have hq_nn : (0 : ℝ) ≤ (q.1.val + 1 : ℝ) ^ (2 * r) := by positivity
          have hpowK : (K : ℝ) ^ (2 * r) = (K : ℝ) ^ (2 * r - 1) * (K : ℝ) := by
            conv_lhs => rw [show 2 * r = (2 * r - 1) + 1 by omega, pow_succ]
          rw [hpowK]
          have hcoef : (2 : ℝ) ^ 2 / (2 * (r : ℝ) - 1) / ((K : ℝ) ^ (2 * r - 1) * K) ≤
              ϱ ^ 2 / (2 * b * K) := by
            rw [div_div, div_le_div_iff₀ (by positivity) (by positivity)]
            rw [div_le_iff₀ (by positivity)] at hK_pow
            nlinarith [hK_pos]
          calc (2 : ℝ) ^ 2 / (2 * (r : ℝ) - 1) *
                  ((q.1.val + 1 : ℝ) ^ (2 * r) / ((K : ℝ) ^ (2 * r - 1) * K))
              = ((2 : ℝ) ^ 2 / (2 * (r : ℝ) - 1) / ((K : ℝ) ^ (2 * r - 1) * K)) *
                  (q.1.val + 1 : ℝ) ^ (2 * r) := by ring
            _ ≤ (ϱ ^ 2 / (2 * b * K)) * (q.1.val + 1 : ℝ) ^ (2 * r) :=
                mul_le_mul_of_nonneg_right hcoef hq_nn
            _ = ϱ ^ 2 * (q.1.val + 1 : ℝ) ^ (2 * r) / (2 * b * K) := by ring
        calc θr * ((q.1.val + 1 : ℝ) / K) ^ r
            = Real.sqrt ((θr * ((q.1.val + 1 : ℝ) / K) ^ r) ^ 2) :=
              (Real.sqrt_sq (by positivity)).symm
          _ ≤ Real.sqrt (ϱ ^ 2 * (q.1.val + 1 : ℝ) ^ (2 * r) / (2 * b * K)) :=
              Real.sqrt_le_sqrt hsq
      have hq_le1 : ((q.1.val + 1 : ℝ) / K) ^ r ≤ 1 := by
        have hle : (q.1.val + 1 : ℝ) / K ≤ 1 := by
          rw [div_le_one hK_pos]
          have : q.1.val + 1 ≤ K := q.2
          exact_mod_cast this
        exact pow_le_one₀ (by positivity) hle
      have hmin_ge : min θr 1 * ((q.1.val + 1 : ℝ) / K) ^ r ≤ min (tq q.1) 1 := by
        refine le_min ?_ ?_
        · exact (mul_le_mul_of_nonneg_right (min_le_left _ _) (by positivity)).trans htq_ge
        · calc min θr 1 * ((q.1.val + 1 : ℝ) / K) ^ r
              ≤ 1 * 1 := mul_le_mul (min_le_right _ _) hq_le1 (by positivity) zero_le_one
            _ = 1 := one_mul 1
      calc ENNReal.ofReal (cr * ((q.1.val + 1 : ℝ) / K) ^ r)
          = ENNReal.ofReal (0.48 * (min θr 1 * ((q.1.val + 1 : ℝ) / K) ^ r)) := by
            congr 1; dsimp only [cr]; ring
        _ ≤ ENNReal.ofReal (0.48 * min (tq q.1) 1) :=
            ENNReal.ofReal_le_ofReal (mul_le_mul_of_nonneg_left hmin_ge (by norm_num))
        _ ≤ gaussianReal 0 1 {x : ℝ | |x| ≤ tq q.1} :=
            gaussianReal_abs_le_lower (tq q.1) (Real.sqrt_nonneg _)
    -- Compare product over `Head` (`⊆ range K`) with product over all of `range K`.
    have hprod_fac : ENNReal.ofReal (∏ j ∈ Finset.range K, cr * (((j + 1 : ℝ) / K) ^ r)) ≤
        ∏ q : {q : Fin m // pHead q}, gaussianReal 0 1 {x : ℝ | |x| ≤ tq q.1} := by
      have h1 : ENNReal.ofReal (∏ q : {q : Fin m // pHead q}, cr * (((q.1.val + 1 : ℝ) / K) ^ r)) ≤
          ∏ q : {q : Fin m // pHead q}, gaussianReal 0 1 {x : ℝ | |x| ≤ tq q.1} := by
        rw [ENNReal.ofReal_prod_of_nonneg fun q _ => by positivity]
        gcongr with q _
        exact hfac q
      refine le_trans ?_ h1
      apply ENNReal.ofReal_le_ofReal
      -- Reindex the `Head` product into a subset `S ⊆ Finset.range K`.
      let S : Finset ℕ := (Finset.univ.filter pHead).image (fun q => q.val)
      have hS_sub : S ⊆ Finset.range K := by
        intro j hj
        rcases Finset.mem_image.mp hj with ⟨q, hq, rfl⟩
        exact Finset.mem_range.mpr (Finset.mem_filter.mp hq).2
      have hS_eq : ∏ q : {q : Fin m // pHead q}, cr * (((q.1.val + 1 : ℝ) / K) ^ r) =
          ∏ j ∈ S, cr * (((j + 1 : ℝ) / K) ^ r) := by
        refine Finset.prod_nbij (fun q => q.1.val) ?_ ?_ ?_ ?_
        · intro q _
          exact Finset.mem_image.mpr ⟨q.1, Finset.mem_filter.mpr ⟨Finset.mem_univ _, q.2⟩, rfl⟩
        · intro q₁ _ q₂ _ h; exact Subtype.ext (Fin.ext h)
        · intro j hj
          rw [Finset.mem_coe] at hj
          rcases Finset.mem_image.mp hj with ⟨q, hq, rfl⟩
          exact ⟨⟨q, (Finset.mem_filter.mp hq).2⟩, Finset.mem_coe.mpr (Finset.mem_univ _), rfl⟩
        · intro q _; rfl
      rw [hS_eq, ← Finset.prod_sdiff hS_sub]
      have hrem_le1 : ∏ j ∈ Finset.range K \ S, cr * (((j + 1 : ℝ) / K) ^ r) ≤ 1 := by
        have hle : ∏ j ∈ Finset.range K \ S, cr * (((j + 1 : ℝ) / K) ^ r) ≤
            ∏ _j ∈ Finset.range K \ S, (1 : ℝ) := by
          gcongr with j hj
          have hjK : j < K := Finset.mem_range.mp (Finset.mem_sdiff.mp hj).1
          have hle1 : ((j + 1 : ℝ) / K) ^ r ≤ 1 :=
            pow_le_one₀ (by positivity)
              ((div_le_one hK_pos).mpr (by exact_mod_cast (by omega : j + 1 ≤ K)))
          calc cr * ((j + 1 : ℝ) / K) ^ r
              ≤ 1 * 1 := mul_le_mul hcr_le1 hle1 (by positivity) zero_le_one
            _ = 1 := one_mul 1
        simpa using hle
      have hS_nn : 0 ≤ ∏ j ∈ S, cr * (((j + 1 : ℝ) / K) ^ r) :=
        Finset.prod_nonneg fun _ _ => by positivity
      nlinarith
    -- Evaluate `∏_{j < K} cr * ((j + 1) / K)^r = cr^K * (K! / K^K)^r ≥ exp(-β_r * K)`.
    refine le_trans ?_ hprod_fac
    apply ENNReal.ofReal_le_ofReal
    have hprod_eval : ∏ j ∈ Finset.range K, cr * (((j + 1 : ℝ) / K) ^ r) =
        cr ^ K * ((K.factorial : ℝ) / (K : ℝ) ^ K) ^ r := by
      rw [Finset.prod_mul_distrib, Finset.prod_const, Finset.card_range,
        Finset.prod_pow (Finset.range K) r (fun j : ℕ => ((j + 1 : ℝ) / K)),
        Finset.prod_div_distrib, Finset.prod_const, Finset.card_range]
      have hfac_prod : ∏ j ∈ Finset.range K, ((j + 1 : ℝ)) = (K.factorial : ℝ) := by
        induction K with
        | zero => simp
        | succ k ih =>
          rw [Finset.prod_range_succ, ih, Nat.factorial_succ]
          push_cast; ring
      rw [hfac_prod]
    rw [hprod_eval]
    have hstirl : Real.exp (-(K : ℝ)) ≤ (K.factorial : ℝ) / (K : ℝ) ^ K := by
      rw [le_div_iff₀ (pow_pos hK_pos K)]
      have h1 := pow_div_exp_le_factorial K
      rw [div_pow, ← Real.exp_nat_mul, mul_one, div_le_iff₀ (Real.exp_pos _)] at h1
      have h2 : Real.exp (-(K : ℝ)) * (K : ℝ) ^ K = (K : ℝ) ^ K / Real.exp (K : ℝ) := by
        rw [Real.exp_neg, inv_mul_eq_div]
      rw [h2, div_le_iff₀ (Real.exp_pos _)]
      exact h1
    have hpow_stirl : Real.exp (-((r : ℝ) * K)) ≤ ((K.factorial : ℝ) / (K : ℝ) ^ K) ^ r := by
      have h1 := pow_le_pow_left₀ (Real.exp_pos _).le hstirl r
      rw [← Real.exp_nat_mul] at h1
      simpa [mul_neg, mul_comm] using h1
    have hcr_inv : cr⁻¹ = max 1 (Real.sqrt (2 * (r : ℝ) - 1) / 2) / 0.48 := by
      dsimp only [cr, θr]
      have hmin_inv : (min (2 / Real.sqrt (2 * (r : ℝ) - 1)) 1)⁻¹ =
          max 1 (Real.sqrt (2 * (r : ℝ) - 1) / 2) := by
        by_cases h : 2 / Real.sqrt (2 * (r : ℝ) - 1) ≤ 1
        · rw [min_eq_left h]
          have hge : 1 ≤ Real.sqrt (2 * (r : ℝ) - 1) / 2 := by
            rw [div_le_one (Real.sqrt_pos.mpr h2r1_pos)] at h
            rw [one_le_div (by norm_num)]
            exact h
          rw [max_eq_right hge, inv_div]
        · push Not at h
          rw [min_eq_right h.le, inv_one]
          have hle : Real.sqrt (2 * (r : ℝ) - 1) / 2 ≤ 1 := by
            rw [one_lt_div (Real.sqrt_pos.mpr h2r1_pos)] at h
            rw [div_le_one (by norm_num)]
            exact h.le
          rw [max_eq_left hle]
      rw [mul_inv, hmin_inv, mul_comm, ← div_eq_mul_inv]
    have hcr_pow : cr ^ K = Real.exp (-(Real.log (max 1 (Real.sqrt (2 * (r : ℝ) - 1) / 2) / 0.48) * K)) := by
      rw [← hcr_inv, Real.log_inv, neg_mul, neg_neg, mul_comm, Real.exp_nat_mul, Real.exp_log hcr_pos]
    calc Real.exp (-(betaR r * K))
        = Real.exp (-(Real.log (max 1 (Real.sqrt (2 * (r : ℝ) - 1) / 2) / 0.48) * K)) *
            Real.exp (-((r : ℝ) * K)) := by
          rw [← Real.exp_add]; congr 1; unfold betaR; ring
      _ = cr ^ K * Real.exp (-((r : ℝ) * K)) := by rw [← hcr_pow]
      _ ≤ cr ^ K * ((K.factorial : ℝ) / (K : ℝ) ^ K) ^ r :=
          mul_le_mul_of_nonneg_left hpow_stirl (by positivity)
  -- Step 5: Combine head and tail.
  calc ENNReal.ofReal ((3 / 4 : ℝ) * Real.exp (-(betaR r * K)))
      = ENNReal.ofReal (Real.exp (-(betaR r * K))) * ENNReal.ofReal (3 / 4 : ℝ) := by
        rw [mul_comm, ENNReal.ofReal_mul (Real.exp_pos _).le]
    _ ≤ μH Ehead * μT Etail := mul_le_mul' hHead_prob hTail_prob
    _ ≤ μG {γ : Fin m → ℝ | ∑ q : Fin m, μ q * (γ q) ^ 2 ≤ ϱ ^ 2} := hprod_le

end BQTF.Lin
