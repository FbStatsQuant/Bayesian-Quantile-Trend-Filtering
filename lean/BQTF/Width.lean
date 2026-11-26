import BQTF.SplineApprox
import BQTF.Shift.Rademacher

/-!
# Width of `K(ρ, T)` (appendix, Lemma `pf:lem:width`)

Owner: Neon-B. The classical input, `E max` of `2m` sub-Gaussian variables, is proved in
`Shift/Rademacher` (`integral_rademacherMax_le`).
-/

open MeasureTheory Finset
open scoped InnerProductSpace

noncomputable section

namespace BQTF

private theorem dot_eq_inner {n : ℕ} (u v : Fin n → ℝ) :
    dot u v = ⟪toE n u, toE n v⟫_ℝ := by
  rw [PiLp.inner_apply]
  change (∑ i, u i * v i) = ∑ i, ⟪u i, v i⟫_ℝ
  simp [mul_comm]

private theorem dot_comm {n : ℕ} (u v : Fin n → ℝ) : dot u v = dot v u := by
  simp [dot, mul_comm]

private theorem l2sq_eq_norm_sq {n : ℕ} (u : Fin n → ℝ) :
    l2sq u = ‖toE n u‖ ^ 2 := by
  rw [EuclideanSpace.real_norm_sq_eq]
  rfl

private theorem l2norm_eq_norm {n : ℕ} (u : Fin n → ℝ) :
    l2norm u = ‖toE n u‖ := by
  rw [l2norm, l2sq_eq_norm_sq, Real.sqrt_sq (norm_nonneg _)]

private theorem l2norm_eq_empNorm_mul {n : ℕ} (hn : 0 < n) (u : Fin n → ℝ) :
    l2norm u = Real.sqrt n * empNorm u := by
  have hn' : (0 : ℝ) < n := Nat.cast_pos.mpr hn
  have hs : 0 < Real.sqrt n := Real.sqrt_pos.2 hn'
  have hsq : 0 ≤ l2sq u := Finset.sum_nonneg fun i _ => sq_nonneg (u i)
  unfold empNorm l2norm
  rw [Real.sqrt_div hsq]
  field_simp

private theorem continuous_l2sq {n : ℕ} : Continuous (l2sq : (Fin n → ℝ) → ℝ) := by
  unfold l2sq
  fun_prop

private theorem compact_Kset (r n : ℕ) (hn : 0 < n) (ρ T : ℝ) (hρ : 0 ≤ ρ) :
    IsCompact (Kset r n ρ T) := by
  have hnorm : Continuous (empNorm : (Fin n → ℝ) → ℝ) := by
    unfold empNorm l2sq
    fun_prop
  have hTV : Continuous (TVr r n) := by unfold TVr l1norm diffOp; fun_prop
  have hclosed : IsClosed (Kset r n ρ T) :=
    (isClosed_le hnorm continuous_const).inter (isClosed_le hTV continuous_const)
  refine (isCompact_closedBall (0 : Fin n → ℝ) (Real.sqrt n * ρ)).of_isClosed_subset hclosed ?_
  intro δ hδ
  change empNorm δ ≤ ρ ∧ _ at hδ
  rw [Metric.mem_closedBall, dist_zero_right]
  refine (pi_norm_le_iff_of_nonneg (by positivity)).mpr fun i => ?_
  have hcoord : (δ i) ^ 2 ≤ l2sq δ :=
    Finset.single_le_sum (fun j _ => sq_nonneg (δ j)) (Finset.mem_univ i)
  have hc := Real.sqrt_le_sqrt hcoord
  rw [← sq_abs (δ i), Real.sqrt_sq (abs_nonneg _)] at hc
  exact (by simpa only [Real.norm_eq_abs, l2norm] using hc :
    ‖δ i‖ ≤ l2norm δ).trans (by
      rw [l2norm_eq_empNorm_mul hn]
      exact mul_le_mul_of_nonneg_left hδ.1 (Real.sqrt_nonneg _))

private theorem orthProj_toE {n : ℕ} (V : Submodule ℝ (Fin n → ℝ)) (v : Fin n → ℝ) :
    toE n (orthProj V v) = (V.map (toE n).toLinearMap).starProjection (toE n v) := by
  simp [orthProj]

private theorem dot_orthProj_swap {n : ℕ} (V : Submodule ℝ (Fin n → ℝ)) (u v : Fin n → ℝ) :
    dot (orthProj V u) v = dot u (orthProj V v) := by
  simp only [dot_eq_inner, orthProj_toE]
  exact Submodule.inner_starProjection_left_eq_right _ _ _

private theorem continuous_l2norm_proj {n : ℕ} (V : Submodule ℝ (Fin n → ℝ)) :
    Continuous (fun v => l2norm (orthProj V v)) := by
  simp only [l2norm_eq_norm, orthProj_toE]
  exact ((V.map (toE n).toLinearMap).starProjection.continuous.comp
    (toE n).toLinearMap.continuous_of_finiteDimensional).norm

private theorem integral_l2norm_proj_le {n : ℕ} (V : Submodule ℝ (Fin n → ℝ)) :
    ∫ ξ, l2norm (orthProj V ξ) ∂rademacher n ≤ Real.sqrt (Module.finrank ℝ V) := by
  let W := V.map (toE n).toLinearMap
  let b := stdOrthonormalBasis ℝ W
  let a (i : Fin (Module.finrank ℝ W)) := (toE n).symm (b i : EuclideanSpace ℝ (Fin n))
  have hsq (ξ : Fin n → ℝ) : l2sq (orthProj V ξ) = ∑ i, (dot ξ (a i)) ^ 2 := by
    rw [l2sq_eq_norm_sq, orthProj_toE]
    change ‖W.orthogonalProjectionOnto (toE n ξ)‖ ^ 2 = _
    rw [← b.sum_sq_norm_inner_right]
    apply Finset.sum_congr rfl
    intro i _
    have hi : ⟪b i, W.orthogonalProjectionOnto (toE n ξ)⟫_ℝ = dot ξ (a i) := by
      rw [dot_comm ξ, dot_eq_inner]
      simp only [a, LinearEquiv.apply_symm_apply]
      exact Submodule.inner_orthogonalProjectionOnto_eq_of_mem_left _ _
    simp only [hi, Real.norm_eq_abs, sq_abs]
  have ha (i : Fin (Module.finrank ℝ W)) : l2sq (a i) = 1 := by
    rw [l2sq_eq_norm_sq]
    simp only [a, LinearEquiv.apply_symm_apply]
    change ‖b i‖ ^ 2 = 1
    rw [b.orthonormal.norm_eq_one, one_pow]
  have hint : ∫ ξ, l2sq (orthProj V ξ) ∂rademacher n = Module.finrank ℝ V := by
    simp_rw [hsq]
    rw [integral_finsetSum _ (fun i _ => integrable_rademacher (by unfold dot; fun_prop))]
    simp_rw [integral_rademacher_dot_sq, ha, Finset.sum_const, Finset.card_univ, Fintype.card_fin,
      nsmul_eq_mul, mul_one, W, LinearEquiv.finrank_map_eq]
  have hcont : Continuous (fun ξ => l2sq (orthProj V ξ)) :=
    continuous_l2sq.comp (orthProj V).continuous_of_finiteDimensional
  have hconc : ConcaveOn ℝ (Set.Ici (0 : ℝ)) Real.sqrt := by
    rw [show Real.sqrt = (fun x : ℝ => x ^ (1 / 2 : ℝ)) from funext Real.sqrt_eq_rpow]
    exact Real.concaveOn_rpow (p := 1 / 2) (by norm_num) (by norm_num)
  have hJensen := hconc.le_map_integral (μ := rademacher n) Real.continuous_sqrt.continuousOn
    isClosed_Ici (Filter.Eventually.of_forall fun ξ => show 0 ≤ l2sq (orthProj V ξ) from
      Finset.sum_nonneg fun i _ => sq_nonneg _)
    (integrable_rademacher hcont) (integrable_rademacher (Real.continuous_sqrt.comp hcont))
  rw [hint] at hJensen
  exact hJensen

private theorem dot_sub_right {n : ℕ} (ξ u v : Fin n → ℝ) :
    dot ξ (u - v) = dot ξ u - dot ξ v := by
  simp only [dot, Pi.sub_apply, mul_sub, Finset.sum_sub_distrib]

private theorem dot_sum_smul {ι : Type*} [Fintype ι] {n : ℕ} (ξ : Fin n → ℝ)
    (a : ι → ℝ) (v : ι → Fin n → ℝ) :
    dot ξ (∑ j, a j • v j) = ∑ j, a j * dot ξ (v j) := by
  unfold dot
  simp only [Finset.sum_apply, Pi.smul_apply, smul_eq_mul, Finset.mul_sum]
  rw [Finset.sum_comm]
  exact Finset.sum_congr rfl fun j _ => Finset.sum_congr rfl fun i _ => by ring

private theorem S_as_sum (r n : ℕ) (u : Fin (n - r) → ℝ) :
    Smul r n u = ∑ j, u j • sCol r n j := by
  ext i
  simp [Smul, Finset.sum_apply, Pi.smul_apply, smul_eq_mul]

private theorem N_in_polySpace (r n : ℕ) (hn : r ≤ n) (c : Fin r → ℝ) :
    Nmul r n c ∈ polySpace r n := by
  have hN (p : Fin r) : Ncol r n p ∈ polySpace r n :=
    (Ncol_orthonormal r n hn).2 ▸ Submodule.subset_span (Set.mem_range_self p)
  have he : Nmul r n c = ∑ p, c p • Ncol r n p := by
    ext i
    simp [Nmul, Finset.sum_apply, Pi.smul_apply, smul_eq_mul]
  rw [he]
  exact Submodule.sum_mem _ fun p _ => Submodule.smul_mem _ _ (hN p)

private theorem width_pointwise (r n J : ℕ) (hr : 2 ≤ r) (hn : r < n) (ρ T : ℝ)
    (hm : 0 < n - r) (ξ δ : Fin n → ℝ)
    (hδ : δ ∈ Kset r n ρ T) :
    dot ξ δ ≤ Real.sqrt n * ρ * l2norm (PJ r n J ξ) +
      (T / (n : ℝ) ^ (r - 1)) *
        rademacherMax hm (fun j => sCol r n j - PJ r n J (sCol r n j)) ξ := by
  let P := PJ r n J
  let R : (Fin n → ℝ) →ₗ[ℝ] (Fin n → ℝ) := LinearMap.id - P
  let v (j : Fin (n - r)) := sCol r n j - P (sCol r n j)
  let M := rademacherMax hm v ξ
  have hn₀ : 0 < n := by omega
  have hn' : (0 : ℝ) < n := Nat.cast_pos.mpr hn₀
  have hp : 0 < (n : ℝ) ^ (r - 1) := by positivity
  obtain ⟨⟨c, u⟩, hcoord⟩ := (coordMap_bijective r n (by omega) hn).1.surjective δ
  have hDu : diffOp r n δ = u := by
    rw [← hcoord]
    exact (coordMap_bijective r n (by omega) hn).2 (c, u)
  have hu : l1norm u ≤ T / (n : ℝ) ^ (r - 1) := by
    apply (le_div_iff₀ hp).mpr
    have hTV := hδ.2
    simpa only [TVr, hDu, mul_comm] using hTV
  have hRn : R (Nmul r n c) = 0 := by
    change Nmul r n c - P (Nmul r n c) = 0
    rw [PJ_fixes_poly r n J _ (N_in_polySpace r n hn.le c), sub_self]
  have hRδ : R δ = ∑ j, u j • v j := by
    rw [← hcoord]
    change R (Nmul r n c + Smul r n u) = _
    rw [map_add, hRn, zero_add, S_as_sum, map_sum]
    simp only [map_smul]
    rfl
  have hsplit : dot ξ δ = dot (P ξ) δ + dot ξ (R δ) := by
    change _ = dot (orthProj (VJ r n J) ξ) δ + dot ξ (δ - orthProj (VJ r n J) δ)
    rw [dot_sub_right, dot_orthProj_swap]
    ring
  have hhead : dot (P ξ) δ ≤ (Real.sqrt n * ρ) * l2norm (P ξ) := by
    calc
      _ ≤ l2norm (P ξ) * l2norm δ := by
        rw [dot_eq_inner, l2norm_eq_norm, l2norm_eq_norm]
        exact real_inner_le_norm _ _
      _ ≤ _ := by
        rw [l2norm_eq_empNorm_mul hn₀ δ, mul_comm (Real.sqrt n * ρ)]
        exact mul_le_mul_of_nonneg_left
          (mul_le_mul_of_nonneg_left hδ.1 (Real.sqrt_nonneg _)) (Real.sqrt_nonneg _)
  have hM : 0 ≤ M := (abs_nonneg _).trans (le_rademacherMax hm v ξ ⟨0, hm⟩)
  have htail : dot ξ (R δ) ≤ (T / (n : ℝ) ^ (r - 1)) * M := by
    rw [hRδ, dot_sum_smul]
    calc
      _ ≤ ∑ j, |u j| * M := by
        apply Finset.sum_le_sum
        intro j _
        calc
          _ ≤ |u j * dot ξ (v j)| := le_abs_self _
          _ = |u j| * |dot ξ (v j)| := abs_mul _ _
          _ ≤ _ := mul_le_mul_of_nonneg_left (le_rademacherMax hm v ξ j) (abs_nonneg _)
      _ = l1norm u * M := (Finset.sum_mul ..).symm
      _ ≤ _ := mul_le_mul_of_nonneg_right hu hM
  rw [hsplit]
  exact add_le_add hhead htail

/-- Lemma `pf:lem:width`: for independent Rademacher signs `ξ`, all `ρ, T > 0` and
`1 ≤ J ≤ m`, `E sup_{K(ρ,T)} ⟨ξ, δ⟩ ≤ √n {ρ √(J + r) + 2^r c_F √(log 2n) T J^{−(r−1/2)}}`. -/
theorem width (r n : ℕ) (hr : 2 ≤ r) (hn : r < n) (ρ T : ℝ) (hρ : 0 < ρ) (hT : 0 < T)
    (J : ℕ) (hJpos : 1 ≤ J) (hJm : J ≤ n - r) :
    ∫ ξ, sSup ((fun δ => dot ξ δ) '' Kset r n ρ T) ∂(rademacher n)
      ≤ Real.sqrt n * (ρ * Real.sqrt (J + r) + 2 ^ r * cF r * Real.sqrt (Real.log (2 * n)) * T *
          (J : ℝ) ^ (-((r : ℝ) - 1 / 2))) := by
  let a := (r : ℝ) - 1 / 2
  let m := n - r
  let h := (hJ m J : ℝ)
  let B := cF r * h ^ a
  let v (j : Fin m) := sCol r n j - PJ r n J (sCol r n j)
  let K := Kset r n ρ T
  have hn₀ : 0 < n := by omega
  have hn' : (0 : ℝ) < n := Nat.cast_pos.mpr hn₀
  have hJ' : (0 : ℝ) < J := by exact_mod_cast (show 0 < J by omega)
  have hr' : (2 : ℝ) ≤ r := by exact_mod_cast hr
  have hm : 0 < m := by omega
  have ha : 0 ≤ a := by dsimp [a]; linarith
  obtain ⟨hh₁, hh, hdim⟩ := hJ_le r n J hn hJpos hJm
  have hhpos : 0 < h := Nat.cast_pos.mpr (zero_lt_one.trans_le hh₁)
  have hcF : 0 < cF r := by unfold cF cInf; positivity
  have hB : 0 < B := by dsimp [B]; positivity
  have hv (j : Fin m) : l2sq (v j) ≤ B ^ 2 := by
    have hs := pow_le_pow_left₀ (Real.sqrt_nonneg (l2sq (v j)))
      ((spline_approx r n J hr hn hJpos hJm).1 j) 2
    have hnonneg : 0 ≤ l2sq (v j) := Finset.sum_nonneg fun i _ => sq_nonneg _
    simpa only [l2norm, Real.sq_sqrt hnonneg] using hs
  have hK := compact_Kset r n hn₀ ρ T hρ.le
  have hdot : Continuous (Function.uncurry (dot : (Fin n → ℝ) → (Fin n → ℝ) → ℝ)) := by
    unfold Function.uncurry dot
    fun_prop
  have hsup : Continuous (fun ξ => sSup ((fun δ => dot ξ δ) '' K)) :=
    hK.continuous_sSup hdot
  have hKne : K.Nonempty := by
    refine ⟨0, ?_⟩
    have hd0 : diffOp r n (0 : Fin n → ℝ) = 0 := by ext i; simp [diffOp]
    simp [K, Kset, empNorm, l2sq, TVr, hd0, l1norm, hρ.le, hT.le]
  let f (ξ : Fin n → ℝ) := l2norm (PJ r n J ξ)
  let g := rademacherMax hm v
  have hf : Continuous f := continuous_l2norm_proj (VJ r n J)
  have hg : Continuous g := continuous_rademacherMax hm v
  have hpoint (ξ : Fin n → ℝ) : sSup ((fun δ => dot ξ δ) '' K) ≤
      (Real.sqrt n * ρ) * f ξ + (T / (n : ℝ) ^ (r - 1)) * g ξ := by
    apply csSup_le (hKne.image _)
    rintro _ ⟨δ, hδ, rfl⟩
    exact width_pointwise r n J hr hn ρ T hm ξ δ hδ
  have hhead : ∫ ξ, f ξ ∂rademacher n ≤ Real.sqrt (J + r) := by
    refine (integral_l2norm_proj_le (VJ r n J)).trans (Real.sqrt_le_sqrt ?_)
    exact_mod_cast hdim
  have htail := integral_rademacherMax_le hm v hB hv
  have hlog : Real.log (2 * (m : ℝ)) ≤ Real.log (2 * (n : ℝ)) := by
    apply Real.log_le_log (by positivity)
    gcongr
    exact_mod_cast Nat.sub_le n r
  have hpow : h ^ a ≤ (2 : ℝ) ^ a * (n : ℝ) ^ a / (J : ℝ) ^ a := by
    apply (Real.rpow_le_rpow hhpos.le hh ha).trans_eq
    rw [Real.div_rpow (by positivity) hJ'.le, Real.mul_rpow (by norm_num) hn'.le]
  have hnPow : (n : ℝ) ^ a = (n : ℝ) ^ (r - 1) * Real.sqrt n := by
    rw [Real.sqrt_eq_rpow, ← Real.rpow_natCast, Nat.cast_sub (by omega : 1 ≤ r),
      Nat.cast_one, ← Real.rpow_add hn']
    congr 1
    dsimp [a]
    ring
  have htwoPow : (2 : ℝ) ^ a * Real.sqrt 2 = (2 : ℝ) ^ r := by
    rw [Real.sqrt_eq_rpow, ← Real.rpow_add (by norm_num : (0 : ℝ) < 2), ← Real.rpow_natCast]
    congr 1
    dsimp [a]
    ring
  have htailScale : (T / (n : ℝ) ^ (r - 1)) * (B * Real.sqrt (2 * Real.log (2 * m))) ≤
      Real.sqrt n * (2 ^ r * cF r * Real.sqrt (Real.log (2 * n)) * T * (J : ℝ) ^ (-a)) := by
    calc
      _ ≤ (T / (n : ℝ) ^ (r - 1)) *
          ((cF r * ((2 : ℝ) ^ a * (n : ℝ) ^ a / (J : ℝ) ^ a)) *
            Real.sqrt (2 * Real.log (2 * n))) := by
        unfold B
        gcongr
      _ = _ := by
        rw [Real.sqrt_mul (by norm_num : (0 : ℝ) ≤ 2), hnPow, Real.rpow_neg hJ'.le]
        have hnne : (n : ℝ) ^ (r - 1) ≠ 0 := by positivity
        have hJne : (J : ℝ) ^ a ≠ 0 := (Real.rpow_pos_of_pos hJ' _).ne'
        calc
          _ = ((2 : ℝ) ^ a * Real.sqrt 2) * Real.sqrt n * cF r *
              Real.sqrt (Real.log (2 * (n : ℝ))) * T * ((J : ℝ) ^ a)⁻¹ := by
            field_simp
          _ = _ := by rw [htwoPow]; ring
  calc
    _ ≤ ∫ ξ, (Real.sqrt n * ρ) * f ξ + (T / (n : ℝ) ^ (r - 1)) * g ξ ∂rademacher n :=
      integral_mono (integrable_rademacher hsup) (integrable_rademacher (by fun_prop)) hpoint
    _ = (Real.sqrt n * ρ) * (∫ ξ, f ξ ∂rademacher n) +
        (T / (n : ℝ) ^ (r - 1)) * ∫ ξ, g ξ ∂rademacher n := by
      rw [integral_add (integrable_rademacher (by fun_prop)) (integrable_rademacher (by fun_prop)),
        integral_const_mul, integral_const_mul]
    _ ≤ (Real.sqrt n * ρ) * Real.sqrt (J + r) +
        Real.sqrt n * (2 ^ r * cF r * Real.sqrt (Real.log (2 * n)) * T * (J : ℝ) ^ (-a)) :=
      add_le_add (mul_le_mul_of_nonneg_left hhead (by positivity))
        ((mul_le_mul_of_nonneg_left htail (by positivity)).trans htailScale)
    _ = _ := by ring

end BQTF
