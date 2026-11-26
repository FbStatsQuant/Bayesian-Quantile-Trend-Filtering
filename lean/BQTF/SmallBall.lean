import BQTF.SplineApprox
import BQTF.Lin.EckartYoung
import BQTF.Lin.LaplaceMixture
import BQTF.Lin.GaussianSmallBall

/-!
# Small ball (appendix, Lemma `pf:lem:sb`)

Owner: Neon-A. `A = n^{−1/2} P^⊥ S`, `B_ϱ = {u : ‖A u‖₂ ≤ ϱ}`, `φ(ϱ) = −log Q_λ(B_ϱ)`.
The lemma is stated as a lower bound on `Q_λ(B_ϱ)` (equivalent to the paper's upper bound on
`φ`, and meaningful also when `Q_λ(B_ϱ) = 0` would make `log` degenerate).

The classical inputs are proved in the `Lin/` helper modules: the Gaussian scale mixture of the
Laplace law (`Lin/LaplaceMixture`), the Eckart–Young / Ky Fan tail bound (`Lin/EckartYoung`),
rotation invariance of the standard Gaussian and `P(|γ| ≤ t) ≥ 0.48 min{t, 1}`
(`Lin/GaussianSmallBall`).
-/

open MeasureTheory ProbabilityTheory Finset
open scoped ENNReal NNReal RealInnerProductSpace

noncomputable section

namespace BQTF

/-- `A u = n^{−1/2} P^⊥ S u`. -/
def Asb (r n : ℕ) (u : Fin (n - r) → ℝ) : Fin n → ℝ :=
  ((n : ℝ) ^ (-(1 / 2 : ℝ))) • Pperp r n (Smul r n u)

/-- `B_ϱ = {u : ‖A u‖₂ ≤ ϱ}`. -/
def Bsb (r n : ℕ) (ϱ : ℝ) : Set (Fin (n - r) → ℝ) := {u | l2norm (Asb r n u) ≤ ϱ}

/-! ## Auxiliary linear algebra and eigenvalue bounds -/

private lemma norm_sq_toE {n : ℕ} (v : Fin n → ℝ) : ‖toE n v‖ ^ 2 = l2sq v := by
  have hl2_nn : 0 ≤ l2sq v := Finset.sum_nonneg fun _ _ => sq_nonneg _
  rw [norm_toE, l2norm, Real.sq_sqrt hl2_nn]

/-- Linear map `G_V : ℝ^m → ℝ^n` given by `g ↦ A (√V ⊙ g)` on Euclidean spaces. -/
private def Gop (r n : ℕ) (V : Fin (n - r) → ℝ) :
    EuclideanSpace ℝ (Fin (n - r)) →ₗ[ℝ] EuclideanSpace ℝ (Fin n) where
  toFun g := toE n (Asb r n fun j => Real.sqrt (V j) * g j)
  map_add' g₁ g₂ := by
    rw [← map_add]
    congr 1
    unfold Asb
    rw [← smul_add, ← map_add]
    congr 2
    ext i
    simp only [Smul, Pi.add_apply, PiLp.add_apply, mul_add, add_mul, Finset.sum_add_distrib]
  map_smul' c g := by
    rw [RingHom.id_apply, ← map_smul]
    congr 1
    unfold Asb
    rw [smul_comm c, ← map_smul (Pperp r n) c]
    congr 2
    ext i
    simp only [Smul, Pi.smul_apply, PiLp.smul_apply, smul_eq_mul, Finset.mul_sum]
    refine Finset.sum_congr rfl fun j _ => by ring

/-- Action of `G_V` on the `j`-th standard basis vector `e_j`. -/
private lemma Gop_basisFun (r n : ℕ) (V : Fin (n - r) → ℝ) (j : Fin (n - r)) :
    Gop r n V (EuclideanSpace.basisFun (Fin (n - r)) ℝ j) =
      toE n (((n : ℝ) ^ (-(1 / 2 : ℝ)) * Real.sqrt (V j)) • Pperp r n (sCol r n j)) := by
  change toE n (Asb r n fun k => Real.sqrt (V k) *
      (EuclideanSpace.basisFun (Fin (n - r)) ℝ j) k) = _
  congr 1
  unfold Asb
  have hS : Smul r n (fun k => Real.sqrt (V k) *
      (EuclideanSpace.basisFun (Fin (n - r)) ℝ j) k) = Real.sqrt (V j) • sCol r n j := by
    ext i
    simp only [Smul, Pi.smul_apply, smul_eq_mul]
    rw [Finset.sum_eq_single j]
    · simp [EuclideanSpace.basisFun_apply]
    · intro k _ hkj
      simp [EuclideanSpace.basisFun_apply, hkj]
    · intro hj; exact (hj (Finset.mem_univ j)).elim
  rw [hS, map_smul, smul_smul]

/-- `‖P^⊥ v‖₂ ≤ ‖v‖₂` (orthogonal projections are contractions). -/
private lemma l2norm_Pperp_le (r n : ℕ) (v : Fin n → ℝ) :
    l2norm (Pperp r n v) ≤ l2norm v := by
  rw [← norm_toE, ← norm_toE]
  let W : Submodule ℝ (EuclideanSpace ℝ (Fin n)) := (polySpace r n).map (toE n).toLinearMap
  have hPperp : toE n (Pperp r n v) = Wᗮ.starProjection (toE n v) := by
    change toE n (v - (toE n).symm (W.starProjection (toE n v))) = _
    rw [map_sub, LinearEquiv.apply_symm_apply, Submodule.starProjection_orthogonal]
    rfl
  rw [hPperp]
  exact Wᗮ.norm_starProjection_apply_le (toE n v)

/-- Algebraic identity `(I − (P_J − P)) ∘ P^⊥ = I − P_J`. -/
private lemma sub_PJ_sub_P_comp_Pperp (r n J : ℕ) (v : Fin n → ℝ) :
    Pperp r n v - (PJ r n J (Pperp r n v) - Pproj r n (Pperp r n v)) = v - PJ r n J v := by
  have hP_idem : Pproj r n (Pproj r n v) = Pproj r n v := by
    let W : Submodule ℝ (EuclideanSpace ℝ (Fin n)) := (polySpace r n).map (toE n).toLinearMap
    change (toE n).symm (W.starProjection (toE n ((toE n).symm (W.starProjection (toE n v))))) =
      (toE n).symm (W.starProjection (toE n v))
    rw [LinearEquiv.apply_symm_apply]
    have hmem : W.starProjection (toE n v) ∈ W := Submodule.starProjection_apply_mem W _
    exact congrArg (toE n).symm (Submodule.starProjection_eq_self_iff.mpr hmem)
  have hP_mem : Pproj r n v ∈ polySpace r n := by
    let W : Submodule ℝ (EuclideanSpace ℝ (Fin n)) := (polySpace r n).map (toE n).toLinearMap
    have hmem : W.starProjection (toE n v) ∈ W := Submodule.starProjection_apply_mem W _
    rcases Submodule.mem_map.mp hmem with ⟨u, hu, heq⟩
    change (toE n).symm (W.starProjection (toE n v)) ∈ polySpace r n
    rw [← heq, LinearEquiv.coe_coe, LinearEquiv.symm_apply_apply]
    exact hu
  have hPJ_P : PJ r n J (Pproj r n v) = Pproj r n v := PJ_fixes_poly r n J _ hP_mem
  have hPperp_def : Pperp r n v = v - Pproj r n v := rfl
  rw [hPperp_def, map_sub, map_sub, hPJ_P, hP_idem]
  abel

/-- `finrank (range (P_J − P)) ≤ J` for `1 ≤ J ≤ n - r` and `r < n`. -/
private lemma finrank_range_PJ_sub_P_le (r n J : ℕ) (hn : r < n) (hJpos : 1 ≤ J) (hJm : J ≤ n - r) :
    Module.finrank ℝ (LinearMap.range (PJ r n J - Pproj r n)) ≤ J := by
  let U : Submodule ℝ (EuclideanSpace ℝ (Fin n)) := (VJ r n J).map (toE n).toLinearMap
  let W : Submodule ℝ (EuclideanSpace ℝ (Fin n)) := (polySpace r n).map (toE n).toLinearMap
  have hWU : W ≤ U := Submodule.map_mono le_sup_left
  let D : EuclideanSpace ℝ (Fin n) →ₗ[ℝ] EuclideanSpace ℝ (Fin n) :=
    U.starProjection.toLinearMap - W.starProjection.toLinearMap
  have hrange_eq : Module.finrank ℝ (LinearMap.range (PJ r n J - Pproj r n)) =
      Module.finrank ℝ (LinearMap.range D) := by
    have hconj : PJ r n J - Pproj r n = (toE n).symm.toLinearMap ∘ₗ D ∘ₗ (toE n).toLinearMap := by
      ext v i; rfl
    rw [hconj]
    have h1 : LinearMap.range ((toE n).symm.toLinearMap ∘ₗ D ∘ₗ (toE n).toLinearMap) =
        (LinearMap.range (D ∘ₗ (toE n).toLinearMap)).map (toE n).symm.toLinearMap :=
      LinearMap.range_comp _ _
    rw [h1, LinearEquiv.finrank_map_eq (toE n).symm]
    have h2 : LinearMap.range (D ∘ₗ (toE n).toLinearMap) = LinearMap.range D :=
      LinearMap.range_comp_of_range_eq_top D (toE n).range
    rw [h2]
  rw [hrange_eq]
  let UW : Submodule ℝ (EuclideanSpace ℝ (Fin n)) := U ⊓ Wᗮ
  have hD_le : LinearMap.range D ≤ UW := by
    rintro y ⟨x, rfl⟩
    refine ⟨?_, ?_⟩
    · exact Submodule.sub_mem U (Submodule.starProjection_apply_mem U x)
        (hWU (Submodule.starProjection_apply_mem W x))
    · change D x ∈ Wᗮ
      rw [W.mem_orthogonal]
      intro w hw
      change ⟪w, U.starProjection x - W.starProjection x⟫ = 0
      have hU : ⟪w, x - U.starProjection x⟫ = 0 :=
        (U.mem_orthogonal _).mp (U.sub_starProjection_mem_orthogonal x) w (hWU hw)
      have hW : ⟪w, x - W.starProjection x⟫ = 0 :=
        (W.mem_orthogonal _).mp (W.sub_starProjection_mem_orthogonal x) w hw
      rw [inner_sub_right] at hU hW ⊢
      linarith
  have hfin_D : Module.finrank ℝ (LinearMap.range D) ≤ Module.finrank ℝ UW :=
    Submodule.finrank_mono hD_le
  have hdisj : UW ⊓ W = ⊥ := by
    rw [eq_bot_iff]
    intro x hx
    have h1 : x ∈ Wᗮ := hx.1.2
    have h2 : x ∈ W := hx.2
    exact inner_self_eq_zero.mp ((W.mem_orthogonal x).mp h1 x h2)
  have hsup_le : UW ⊔ W ≤ U := sup_le inf_le_left hWU
  have hadd := Submodule.finrank_sup_add_finrank_inf_eq UW W
  rw [hdisj, finrank_bot, add_zero] at hadd
  have hfin_sup : Module.finrank ℝ (UW ⊔ W : Submodule ℝ (EuclideanSpace ℝ (Fin n))) ≤
      Module.finrank ℝ U :=
    Submodule.finrank_mono hsup_le
  have hfin_U : Module.finrank ℝ U ≤ J + r := by
    rw [LinearEquiv.finrank_map_eq (toE n)]
    exact (hJ_le r n J hn hJpos hJm).2.2
  have hfin_W : Module.finrank ℝ W = r := by
    rw [LinearEquiv.finrank_map_eq (toE n)]
    have hli := monomial_linearIndependent r n (le_of_lt hn)
    change Module.finrank ℝ (Submodule.span ℝ (Set.range (monomial r n))) = r
    rw [finrank_span_eq_card hli, Fintype.card_fin]
  omega

/-- Elementary column norm bound `‖s_j‖₂ ≤ c_F (2 n)^{r − 1/2}` used for the `J = 0` trace bound. -/
private lemma l2norm_sCol_le_cF (r n : ℕ) (hr : 2 ≤ r) (hn : r < n) (j : Fin (n - r)) :
    l2norm (sCol r n j) ≤ cF r * (2 * (n : ℝ)) ^ ((r : ℝ) - 1 / 2) := by
  have hn0 : (0 : ℝ) < n := Nat.cast_pos.mpr (by omega)
  have hfac_pos : (0 : ℝ) < ((r - 1).factorial : ℝ) := Nat.cast_pos.mpr (Nat.factorial_pos _)
  have hentry : ∀ i : Fin n, |sCol r n j i| ≤ (n : ℝ) ^ (r - 1) / ((r - 1).factorial : ℝ) := by
    intro i
    unfold sCol bfun
    split_ifs with ht
    · rw [abs_of_nonneg (Nat.cast_nonneg _)]
      rw [le_div_iff₀ hfac_pos]
      have hchoose_nat : (((i : ℤ) - j - 1).toNat.choose (r - 1)) * (r - 1).factorial ≤
          n ^ (r - 1) := by
        have h1 : (((i : ℤ) - j - 1).toNat.choose (r - 1)) * (r - 1).factorial =
            ((i : ℤ) - j - 1).toNat.descFactorial (r - 1) := by
          rw [Nat.mul_comm, Nat.descFactorial_eq_factorial_mul_choose]
        rw [h1]
        have h2 : ((i : ℤ) - j - 1).toNat.descFactorial (r - 1) ≤
            ((i : ℤ) - j - 1).toNat ^ (r - 1) := Nat.descFactorial_le_pow _ _
        have h3 : ((i : ℤ) - j - 1).toNat ≤ n := by have := i.isLt; omega
        exact h2.trans (Nat.pow_le_pow_left h3 (r - 1))
      exact_mod_cast hchoose_nat
    · rw [abs_zero]; positivity
  have hcF_ge : (1 : ℝ) / ((r - 1).factorial : ℝ) ≤ cF r := by
    unfold cF cInf
    have hsqrt : (1 : ℝ) ≤ Real.sqrt r := by
      rw [← Real.sqrt_one]
      exact Real.sqrt_le_sqrt (by exact_mod_cast (by omega : 1 ≤ r))
    have h1 : (1 : ℝ) ≤ 1 + (2 : ℝ) ^ (r - 1) := by linarith [pow_nonneg (by norm_num : (0 : ℝ) ≤ 2) (r - 1)]
    have h2 : (1 : ℝ) ≤ (2 * (r : ℝ)) ^ (r - 1) :=
      one_le_pow₀ (by have : (2 : ℝ) ≤ r := Nat.ofNat_le_cast.mpr hr; linarith)
    have h12 : (1 : ℝ) ≤ (1 + (2 : ℝ) ^ (r - 1)) * (2 * (r : ℝ)) ^ (r - 1) := by nlinarith
    have hnum : (1 : ℝ) ≤ Real.sqrt r * ((1 + (2 : ℝ) ^ (r - 1)) * (2 * (r : ℝ)) ^ (r - 1)) := by
      nlinarith
    rw [← mul_div_assoc]
    exact div_le_div_of_nonneg_right hnum hfac_pos.le
  have hl2_sq : l2sq (sCol r n j) ≤ (cF r * (2 * (n : ℝ)) ^ ((r : ℝ) - 1 / 2)) ^ 2 := by
    unfold l2sq
    have hsum : ∑ i : Fin n, sCol r n j i ^ 2 ≤
        (n : ℝ) * ((n : ℝ) ^ (r - 1) / ((r - 1).factorial : ℝ)) ^ 2 := by
      calc ∑ i : Fin n, sCol r n j i ^ 2
          ≤ ∑ _i : Fin n, ((n : ℝ) ^ (r - 1) / ((r - 1).factorial : ℝ)) ^ 2 := by
            refine Finset.sum_le_sum fun i _ => ?_
            rw [← sq_abs]
            exact pow_le_pow_left₀ (abs_nonneg _) (hentry i) 2
        _ = (n : ℝ) * ((n : ℝ) ^ (r - 1) / ((r - 1).factorial : ℝ)) ^ 2 := by
            rw [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
    refine hsum.trans ?_
    have hrpow_sq : ((2 * (n : ℝ)) ^ ((r : ℝ) - 1 / 2)) ^ 2 = (2 * (n : ℝ)) ^ (2 * r - 1) := by
      rw [← Real.rpow_natCast ((2 * (n : ℝ)) ^ ((r : ℝ) - 1 / 2)) 2,
        ← Real.rpow_mul (by positivity)]
      have hexp : ((r : ℝ) - 1 / 2) * (2 : ℕ) = ((2 * r - 1 : ℕ) : ℝ) := by
        rw [Nat.cast_sub (by omega)]; push_cast; ring
      rw [hexp, Real.rpow_natCast]
    rw [mul_pow, hrpow_sq]
    have hpow_n : (n : ℝ) * ((n : ℝ) ^ (r - 1)) ^ 2 = (n : ℝ) ^ (2 * r - 1) := by
      rw [← pow_mul, ← pow_succ']
      congr 1; omega
    have hle_2n : (n : ℝ) ^ (2 * r - 1) ≤ (2 * (n : ℝ)) ^ (2 * r - 1) :=
      pow_le_pow_left₀ hn0.le (by linarith) _
    have hcf_sq : (1 / ((r - 1).factorial : ℝ)) ^ 2 ≤ cF r ^ 2 :=
      pow_le_pow_left₀ (by positivity) hcF_ge 2
    calc (n : ℝ) * ((n : ℝ) ^ (r - 1) / ((r - 1).factorial : ℝ)) ^ 2
        = (1 / ((r - 1).factorial : ℝ)) ^ 2 * ((n : ℝ) * ((n : ℝ) ^ (r - 1)) ^ 2) := by ring
      _ = (1 / ((r - 1).factorial : ℝ)) ^ 2 * (n : ℝ) ^ (2 * r - 1) := by rw [hpow_n]
      _ ≤ cF r ^ 2 * (2 * (n : ℝ)) ^ (2 * r - 1) :=
          mul_le_mul hcf_sq hle_2n (by positivity) (sq_nonneg _)
  unfold l2norm
  have hrhs_nn : 0 ≤ cF r * (2 * (n : ℝ)) ^ ((r : ℝ) - 1 / 2) := by
    have : 0 ≤ cF r := (by positivity : (0 : ℝ) ≤ 1 / ((r - 1).factorial : ℝ)).trans hcF_ge
    positivity
  exact (Real.sqrt_le_sqrt hl2_sq).trans_eq (Real.sqrt_sq hrhs_nn)

/-- Singular-value decay bound (first paragraph of the proof of Lemma `pf:lem:sb`):
for `V` with `0 ≤ V_j` and `∑ V_j ≤ 4 m / λ²`, the squared singular values of `G_V` satisfy
`σ_q(G_V)² ≤ b / (q + 1)^{2r}` with `b = 8 · 6^{2r−1} c_F² n^{2r−1} / λ²`. -/
private lemma singularValues_sq_decay {r n : ℕ} (hr : 2 ≤ r) (hn : r < n)
    {lam : ℝ} (hlam : 0 < lam) {V : Fin (n - r) → ℝ}
    (hV_nn : ∀ j, 0 ≤ V j) (hV_sum : ∑ j, V j ≤ 4 * ((n - r : ℕ) : ℝ) / lam ^ 2) :
    let b : ℝ := 8 * (6 : ℝ) ^ (2 * r - 1) * cF r ^ 2 * (n : ℝ) ^ (2 * r - 1) / lam ^ 2
    ∀ q : Fin (n - r), (Gop r n V).singularValues q ^ 2 ≤ b / ((q.val + 1 : ℝ) ^ (2 * r)) := by
  intro b q
  let m : ℕ := n - r
  let G := Gop r n V
  have hn0 : (0 : ℝ) < n := Nat.cast_pos.mpr (by omega)
  have hm_le_n : (m : ℝ) ≤ (n : ℝ) := by exact_mod_cast Nat.sub_le n r
  have hV_sum_n : ∑ j : Fin m, V j ≤ 4 * (n : ℝ) / lam ^ 2 :=
    hV_sum.trans (div_le_div_of_nonneg_right (by linarith) (sq_nonneg lam))
  let b0 : ℝ := (2 : ℝ) ^ (2 * r + 1) * cF r ^ 2 * (n : ℝ) ^ (2 * r - 1) / lam ^ 2
  have hcF_nn : 0 ≤ cF r := by unfold cF cInf; positivity
  have hb0_nn : 0 ≤ b0 := by positivity
  have hb_eq : b = 2 * (3 : ℝ) ^ (2 * r - 1) * b0 := by
    dsimp only [b, b0]
    have h6 : (6 : ℝ) ^ (2 * r - 1) = (3 : ℝ) ^ (2 * r - 1) * (2 : ℝ) ^ (2 * r - 1) := by
      rw [← mul_pow]; norm_num
    have h2 : (2 : ℝ) ^ (2 * r + 1) = 4 * (2 : ℝ) ^ (2 * r - 1) := by
      have : 2 * r + 1 = (2 * r - 1) + 2 := by omega
      rw [this, pow_add]; ring
    rw [h6, h2]; ring
  have hfinE : Module.finrank ℝ (EuclideanSpace ℝ (Fin m)) = m := finrank_euclideanSpace_fin
  -- Part A: Total trace bound `∑_{k < m} σ_k(G)² ≤ b0`.
  have htrace : ∑ k ∈ Finset.Ico 0 m, G.singularValues k ^ 2 ≤ b0 := by
    have hEY := BQTF.Lin.eckartYoung_tail (EuclideanSpace.basisFun (Fin m) ℝ) G 0 0 (by simp)
    rw [hfinE, sub_zero] at hEY
    refine hEY.trans ?_
    have hterm : ∀ j : Fin m, ‖G (EuclideanSpace.basisFun (Fin m) ℝ j)‖ ^ 2 ≤
        V j * (cF r ^ 2 * (2 : ℝ) ^ (2 * r - 1) * (n : ℝ) ^ (2 * r - 2)) := by
      intro j
      rw [Gop_basisFun, norm_sq_toE]
      have hsc : l2sq (((n : ℝ) ^ (-(1 / 2 : ℝ)) * Real.sqrt (V j)) • Pperp r n (sCol r n j)) =
          ((n : ℝ) ^ (-(1 / 2 : ℝ)) * Real.sqrt (V j)) ^ 2 * l2sq (Pperp r n (sCol r n j)) := by
        unfold l2sq
        rw [Finset.mul_sum]
        refine Finset.sum_congr rfl fun i _ => by simp only [Pi.smul_apply, smul_eq_mul]; ring
      rw [hsc]
      have hcoef : ((n : ℝ) ^ (-(1 / 2 : ℝ)) * Real.sqrt (V j)) ^ 2 = V j / (n : ℝ) := by
        rw [mul_pow, Real.sq_sqrt (hV_nn j), ← Real.rpow_natCast ((n : ℝ) ^ (-(1 / 2 : ℝ))) 2,
          ← Real.rpow_mul hn0.le]
        norm_num
        rw [Real.rpow_neg_one, inv_mul_eq_div]
      rw [hcoef]
      have hl2 : l2sq (Pperp r n (sCol r n j)) ≤ cF r ^ 2 * (2 * (n : ℝ)) ^ (2 * r - 1) := by
        have h1 : l2norm (Pperp r n (sCol r n j)) ≤ cF r * (2 * (n : ℝ)) ^ ((r : ℝ) - 1 / 2) :=
          (l2norm_Pperp_le r n _).trans (l2norm_sCol_le_cF r n hr hn j)
        have h2 := pow_le_pow_left₀ (Real.sqrt_nonneg _) h1 2
        have hl2_nn : 0 ≤ l2sq (Pperp r n (sCol r n j)) := Finset.sum_nonneg fun _ _ => sq_nonneg _
        change Real.sqrt (l2sq (Pperp r n (sCol r n j))) ^ 2 ≤ _ at h2
        rw [Real.sq_sqrt hl2_nn, mul_pow,
          ← Real.rpow_natCast ((2 * (n : ℝ)) ^ ((r : ℝ) - 1 / 2)) 2,
          ← Real.rpow_mul (by positivity)] at h2
        have hexp : ((r : ℝ) - 1 / 2) * (2 : ℕ) = ((2 * r - 1 : ℕ) : ℝ) := by
          rw [Nat.cast_sub (by omega)]; push_cast; ring
        rw [hexp, Real.rpow_natCast] at h2
        exact h2
      have hpow_div : (2 * (n : ℝ)) ^ (2 * r - 1) / (n : ℝ) =
          (2 : ℝ) ^ (2 * r - 1) * (n : ℝ) ^ (2 * r - 2) := by
        rw [mul_pow, mul_div_assoc]
        congr 1
        have hsplit : (n : ℝ) ^ (2 * r - 1) = (n : ℝ) ^ (2 * r - 2) * (n : ℝ) := by
          conv_lhs => rw [show 2 * r - 1 = (2 * r - 2) + 1 by omega, pow_succ]
        rw [hsplit, mul_div_cancel_right₀ _ hn0.ne']
      calc V j / (n : ℝ) * l2sq (Pperp r n (sCol r n j))
          ≤ V j / (n : ℝ) * (cF r ^ 2 * (2 * (n : ℝ)) ^ (2 * r - 1)) :=
            mul_le_mul_of_nonneg_left hl2 (div_nonneg (hV_nn j) hn0.le)
        _ = V j * (cF r ^ 2 * ((2 * (n : ℝ)) ^ (2 * r - 1) / (n : ℝ))) := by ring
        _ = V j * (cF r ^ 2 * (2 : ℝ) ^ (2 * r - 1) * (n : ℝ) ^ (2 * r - 2)) := by
            rw [hpow_div]; ring
    calc ∑ j : Fin m, ‖G (EuclideanSpace.basisFun (Fin m) ℝ j)‖ ^ 2
        ≤ ∑ j : Fin m, V j * (cF r ^ 2 * (2 : ℝ) ^ (2 * r - 1) * (n : ℝ) ^ (2 * r - 2)) :=
          Finset.sum_le_sum fun j _ => hterm j
      _ = (∑ j : Fin m, V j) * (cF r ^ 2 * (2 : ℝ) ^ (2 * r - 1) * (n : ℝ) ^ (2 * r - 2)) := by
          rw [← Finset.sum_mul]
      _ ≤ (4 * (n : ℝ) / lam ^ 2) * (cF r ^ 2 * (2 : ℝ) ^ (2 * r - 1) * (n : ℝ) ^ (2 * r - 2)) :=
          mul_le_mul_of_nonneg_right hV_sum_n (by positivity)
      _ = b0 := by
          dsimp only [b0]
          have h2 : (2 : ℝ) ^ (2 * r + 1) = 4 * (2 : ℝ) ^ (2 * r - 1) := by
            have : 2 * r + 1 = (2 * r - 1) + 2 := by omega
            rw [this, pow_add]; ring
          have hn_pow : (n : ℝ) ^ (2 * r - 1) = (n : ℝ) * (n : ℝ) ^ (2 * r - 2) := by
            conv_lhs => rw [show 2 * r - 1 = (2 * r - 2) + 1 by omega, pow_succ']
          rw [h2, hn_pow]; ring
  -- Part B: Tail bound `∑_{k = J}^{m-1} σ_k(G)² ≤ b0 / J^{2r - 1}` for `1 ≤ J ≤ m`.
  have htail : ∀ J : ℕ, 1 ≤ J → J ≤ m →
      ∑ k ∈ Finset.Ico J m, G.singularValues k ^ 2 ≤ b0 / (J : ℝ) ^ (2 * r - 1) := by
    intro J hJpos hJm
    have hJ0 : (0 : ℝ) < J := Nat.cast_pos.mpr (by omega)
    let Pdiff : EuclideanSpace ℝ (Fin n) →ₗ[ℝ] EuclideanSpace ℝ (Fin n) :=
      (toE n).toLinearMap ∘ₗ (PJ r n J - Pproj r n) ∘ₗ (toE n).symm.toLinearMap
    let H : EuclideanSpace ℝ (Fin m) →ₗ[ℝ] EuclideanSpace ℝ (Fin n) := Pdiff ∘ₗ G
    have hH_rank : Module.finrank ℝ (LinearMap.range H) ≤ J := by
      have hsub : LinearMap.range H ≤ LinearMap.range Pdiff := LinearMap.range_comp_le_range _ _
      have h1 : Module.finrank ℝ (LinearMap.range H) ≤ Module.finrank ℝ (LinearMap.range Pdiff) :=
        Submodule.finrank_mono hsub
      have h2 : Module.finrank ℝ (LinearMap.range Pdiff) =
          Module.finrank ℝ (LinearMap.range (PJ r n J - Pproj r n)) := by
        dsimp only [Pdiff]
        rw [LinearMap.range_comp, LinearEquiv.finrank_map_eq (toE n),
          LinearMap.range_comp_of_range_eq_top _ (toE n).symm.range]
      exact h1.trans (h2.le.trans (finrank_range_PJ_sub_P_le r n J hn hJpos hJm))
    have hEY := BQTF.Lin.eckartYoung_tail (EuclideanSpace.basisFun (Fin m) ℝ) G H J hH_rank
    rw [hfinE] at hEY
    refine hEY.trans ?_
    have hcol : ∀ j : Fin m, ‖(G - H) (EuclideanSpace.basisFun (Fin m) ℝ j)‖ ^ 2 ≤
        V j * (cF r ^ 2 * (2 : ℝ) ^ (2 * r - 1) * (n : ℝ) ^ (2 * r - 2) / (J : ℝ) ^ (2 * r - 1)) := by
      intro j
      have hGH_eq : (G - H) (EuclideanSpace.basisFun (Fin m) ℝ j) =
          toE n (((n : ℝ) ^ (-(1 / 2 : ℝ)) * Real.sqrt (V j)) •
            (sCol r n j - PJ r n J (sCol r n j))) := by
        rw [LinearMap.sub_apply]
        change G (EuclideanSpace.basisFun (Fin m) ℝ j) -
            Pdiff (G (EuclideanSpace.basisFun (Fin m) ℝ j)) = _
        rw [Gop_basisFun]
        dsimp only [Pdiff]
        simp only [LinearMap.comp_apply, LinearEquiv.coe_coe, LinearEquiv.symm_apply_apply]
        rw [← map_sub]
        congr 1
        rw [LinearMap.sub_apply, map_smul, map_smul, ← smul_sub, ← smul_sub]
        congr 1
        exact sub_PJ_sub_P_comp_Pperp r n J (sCol r n j)
      rw [hGH_eq, norm_sq_toE]
      have hsc : l2sq (((n : ℝ) ^ (-(1 / 2 : ℝ)) * Real.sqrt (V j)) •
            (sCol r n j - PJ r n J (sCol r n j))) =
          ((n : ℝ) ^ (-(1 / 2 : ℝ)) * Real.sqrt (V j)) ^ 2 *
            l2sq (sCol r n j - PJ r n J (sCol r n j)) := by
        unfold l2sq
        rw [Finset.mul_sum]
        refine Finset.sum_congr rfl fun i _ => by simp only [Pi.smul_apply, smul_eq_mul]; ring
      rw [hsc]
      have hcoef : ((n : ℝ) ^ (-(1 / 2 : ℝ)) * Real.sqrt (V j)) ^ 2 = V j / (n : ℝ) := by
        rw [mul_pow, Real.sq_sqrt (hV_nn j), ← Real.rpow_natCast ((n : ℝ) ^ (-(1 / 2 : ℝ))) 2,
          ← Real.rpow_mul hn0.le]
        norm_num
        rw [Real.rpow_neg_one, inv_mul_eq_div]
      rw [hcoef]
      have hsp := (spline_approx r n J hr hn hJpos hJm).1 j
      have hh1 : 1 ≤ hJ (n - r) J := (hJ_le r n J hn hJpos hJm).1
      have hhle := (hJ_le r n J hn hJpos hJm).2.1
      have hh0 : (0 : ℝ) < hJ (n - r) J := Nat.cast_pos.mpr hh1
      have hnorm_le : l2norm (sCol r n j - PJ r n J (sCol r n j)) ≤
          cF r * (2 * (n : ℝ) / J) ^ ((r : ℝ) - 1 / 2) := by
        refine hsp.trans (mul_le_mul_of_nonneg_left ?_ hcF_nn)
        exact Real.rpow_le_rpow hh0.le hhle (by have : (2 : ℝ) ≤ r := Nat.ofNat_le_cast.mpr hr; linarith)
      have hsq_le : l2sq (sCol r n j - PJ r n J (sCol r n j)) ≤
          cF r ^ 2 * (2 * (n : ℝ) / J) ^ (2 * r - 1) := by
        have h1 := pow_le_pow_left₀ (Real.sqrt_nonneg _) hnorm_le 2
        have hl2_nn : 0 ≤ l2sq (sCol r n j - PJ r n J (sCol r n j)) :=
          Finset.sum_nonneg fun _ _ => sq_nonneg _
        change Real.sqrt (l2sq (sCol r n j - PJ r n J (sCol r n j))) ^ 2 ≤ _ at h1
        rw [Real.sq_sqrt hl2_nn, mul_pow,
          ← Real.rpow_natCast ((2 * (n : ℝ) / J) ^ ((r : ℝ) - 1 / 2)) 2,
          ← Real.rpow_mul (by positivity)] at h1
        have hexp : ((r : ℝ) - 1 / 2) * (2 : ℕ) = ((2 * r - 1 : ℕ) : ℝ) := by
          rw [Nat.cast_sub (by omega)]; push_cast; ring
        rw [hexp, Real.rpow_natCast] at h1
        exact h1
      have hpow_div : (2 * (n : ℝ) / J) ^ (2 * r - 1) / (n : ℝ) =
          (2 : ℝ) ^ (2 * r - 1) * (n : ℝ) ^ (2 * r - 2) / (J : ℝ) ^ (2 * r - 1) := by
        rw [div_pow, mul_pow, div_div, mul_comm ((J : ℝ) ^ (2 * r - 1)) (n : ℝ), ← div_div,
          mul_div_assoc]
        congr 1
        have hsplit : (n : ℝ) ^ (2 * r - 1) = (n : ℝ) ^ (2 * r - 2) * (n : ℝ) := by
          conv_lhs => rw [show 2 * r - 1 = (2 * r - 2) + 1 by omega, pow_succ]
        rw [hsplit, mul_div_cancel_right₀ _ hn0.ne']
      calc V j / (n : ℝ) * l2sq (sCol r n j - PJ r n J (sCol r n j))
          ≤ V j / (n : ℝ) * (cF r ^ 2 * (2 * (n : ℝ) / J) ^ (2 * r - 1)) :=
            mul_le_mul_of_nonneg_left hsq_le (div_nonneg (hV_nn j) hn0.le)
        _ = V j * (cF r ^ 2 * ((2 * (n : ℝ) / J) ^ (2 * r - 1) / (n : ℝ))) := by ring
        _ = V j * (cF r ^ 2 * (2 : ℝ) ^ (2 * r - 1) * (n : ℝ) ^ (2 * r - 2) / (J : ℝ) ^ (2 * r - 1)) := by
            rw [hpow_div]; ring
    calc ∑ j : Fin m, ‖(G - H) (EuclideanSpace.basisFun (Fin m) ℝ j)‖ ^ 2
        ≤ ∑ j : Fin m,
            V j * (cF r ^ 2 * (2 : ℝ) ^ (2 * r - 1) * (n : ℝ) ^ (2 * r - 2) / (J : ℝ) ^ (2 * r - 1)) :=
          Finset.sum_le_sum fun j _ => hcol j
      _ = (∑ j : Fin m, V j) *
            (cF r ^ 2 * (2 : ℝ) ^ (2 * r - 1) * (n : ℝ) ^ (2 * r - 2) / (J : ℝ) ^ (2 * r - 1)) := by
          rw [← Finset.sum_mul]
      _ ≤ (4 * (n : ℝ) / lam ^ 2) *
            (cF r ^ 2 * (2 : ℝ) ^ (2 * r - 1) * (n : ℝ) ^ (2 * r - 2) / (J : ℝ) ^ (2 * r - 1)) :=
          mul_le_mul_of_nonneg_right hV_sum_n (by positivity)
      _ = b0 / (J : ℝ) ^ (2 * r - 1) := by
          dsimp only [b0]
          have h2 : (2 : ℝ) ^ (2 * r + 1) = 4 * (2 : ℝ) ^ (2 * r - 1) := by
            have : 2 * r + 1 = (2 * r - 1) + 2 := by omega
            rw [this, pow_add]; ring
          have hn_pow : (n : ℝ) ^ (2 * r - 1) = (n : ℝ) * (n : ℝ) ^ (2 * r - 2) := by
            conv_lhs => rw [show 2 * r - 1 = (2 * r - 2) + 1 by omega, pow_succ']
          rw [h2, hn_pow]; ring
  -- Part C: Deduce `σ_q(G)² ≤ b / (q + 1)^{2r}` from Parts A and B.
  by_cases hq0 : q.val = 0
  · rw [hq0]
    simp only [Nat.cast_zero, zero_add, one_pow, div_one]
    have hmem : (0 : ℕ) ∈ Finset.Ico 0 m := Finset.mem_Ico.mpr ⟨le_rfl, by omega⟩
    have h1 : G.singularValues 0 ^ 2 ≤ ∑ k ∈ Finset.Ico 0 m, G.singularValues k ^ 2 :=
      Finset.single_le_sum (f := fun k => G.singularValues k ^ 2) (fun _ _ => sq_nonneg _) hmem
    have hcoef : (1 : ℝ) ≤ 2 * (3 : ℝ) ^ (2 * r - 1) := by
      have : (1 : ℝ) ≤ (3 : ℝ) ^ (2 * r - 1) := one_le_pow₀ (by norm_num)
      linarith
    rw [hb_eq]
    calc G.singularValues 0 ^ 2 ≤ b0 := h1.trans htrace
      _ = 1 * b0 := (one_mul b0).symm
      _ ≤ (2 * (3 : ℝ) ^ (2 * r - 1)) * b0 := mul_le_mul_of_nonneg_right hcoef hb0_nn
  · -- `1 ≤ q.val`: set `J = (q.val + 1) / 2`.
    let q1 : ℕ := q.val + 1
    let J : ℕ := q1 / 2
    have hq1_ge2 : 2 ≤ q1 := by omega
    have hJ1 : 1 ≤ J := by dsimp only [J]; omega
    have hJq : J ≤ q.val := by dsimp only [J, q1]; omega
    have hJm : J ≤ m := by have := q.isLt; omega
    have hsub : Finset.Ico J q1 ⊆ Finset.Ico J m := by
      intro k hk
      rw [Finset.mem_Ico] at hk ⊢
      exact ⟨hk.1, hk.2.trans_le (by have := q.isLt; dsimp only [q1]; omega)⟩
    have hsum_ge : ((q1 - J : ℕ) : ℝ) * G.singularValues q ^ 2 ≤
        ∑ k ∈ Finset.Ico J q1, G.singularValues k ^ 2 := by
      calc ((q1 - J : ℕ) : ℝ) * G.singularValues q ^ 2
          = ∑ _k ∈ Finset.Ico J q1, G.singularValues q ^ 2 := by
            rw [Finset.sum_const, Nat.card_Ico, nsmul_eq_mul]
        _ ≤ ∑ k ∈ Finset.Ico J q1, G.singularValues k ^ 2 := by
            refine Finset.sum_le_sum fun k hk => ?_
            have hk_le : k ≤ q.val := by
              have := (Finset.mem_Ico.mp hk).2
              dsimp only [q1] at this; omega
            exact pow_le_pow_left₀ (G.singularValues_nonneg _)
              (G.singularValues_antitone hk_le) 2
    have hsum_le : ∑ k ∈ Finset.Ico J q1, G.singularValues k ^ 2 ≤ b0 / (J : ℝ) ^ (2 * r - 1) :=
      (Finset.sum_le_sum_of_subset_of_nonneg hsub fun _ _ _ => sq_nonneg _).trans
        (htail J hJ1 hJm)
    have hchain : ((q1 - J : ℕ) : ℝ) * G.singularValues q ^ 2 ≤ b0 / (J : ℝ) ^ (2 * r - 1) :=
      hsum_ge.trans hsum_le
    have hqJ_pos : (0 : ℝ) < (q1 - J : ℕ) := Nat.cast_pos.mpr (by omega)
    have hJ_pos : (0 : ℝ) < J := Nat.cast_pos.mpr (by omega)
    have hq1_pos : (0 : ℝ) < q1 := Nat.cast_pos.mpr (by omega)
    have h2_qJ : (q1 : ℝ) ≤ 2 * ((q1 - J : ℕ) : ℝ) := by
      exact_mod_cast (by dsimp only [J, q1]; omega : q1 ≤ 2 * (q1 - J))
    have h3_J : (q1 : ℝ) ≤ 3 * (J : ℝ) := by
      exact_mod_cast (by dsimp only [J, q1]; omega : q1 ≤ 3 * J)
    have hq1_cast : (q.val + 1 : ℝ) = (q1 : ℝ) := by dsimp only [q1]; push_cast; rfl
    rw [hq1_cast, hb_eq]
    have hinv1 : (1 : ℝ) / ((q1 - J : ℕ) : ℝ) ≤ 2 / (q1 : ℝ) := by
      rw [div_le_div_iff₀ hqJ_pos hq1_pos]; linarith
    have hinv2 : (1 : ℝ) / (J : ℝ) ^ (2 * r - 1) ≤
        (3 : ℝ) ^ (2 * r - 1) / (q1 : ℝ) ^ (2 * r - 1) := by
      rw [div_le_div_iff₀ (pow_pos hJ_pos _) (pow_pos hq1_pos _), one_mul, ← mul_pow]
      exact pow_le_pow_left₀ hq1_pos.le h3_J _
    have hpow_q1 : (q1 : ℝ) ^ (2 * r) = (q1 : ℝ) * (q1 : ℝ) ^ (2 * r - 1) := by
      conv_lhs => rw [show 2 * r = (2 * r - 1) + 1 by omega, pow_succ']
    calc G.singularValues q ^ 2
        ≤ (b0 / (J : ℝ) ^ (2 * r - 1)) / ((q1 - J : ℕ) : ℝ) :=
          (le_div_iff₀' hqJ_pos).mpr hchain
      _ = b0 * ((1 / ((q1 - J : ℕ) : ℝ)) * (1 / (J : ℝ) ^ (2 * r - 1))) := by ring
      _ ≤ b0 * ((2 / (q1 : ℝ)) * ((3 : ℝ) ^ (2 * r - 1) / (q1 : ℝ) ^ (2 * r - 1))) := by
          refine mul_le_mul_of_nonneg_left ?_ hb0_nn
          exact mul_le_mul hinv1 hinv2 (by positivity) (by positivity)
      _ = 2 * (3 : ℝ) ^ (2 * r - 1) * b0 / (q1 : ℝ) ^ (2 * r) := by
          rw [hpow_q1]; ring

/-! ## Main theorem -/

/-- Lemma `pf:lem:sb`: there is `C_sb` depending only on `r` such that for all `n > r`, `λ > 0`,
`ϱ > 0`: `φ(ϱ) ≤ C_sb {1 + (n^{r−1/2}/(λϱ))^{2/(2r−1)}}`. -/
theorem small_ball (r : ℕ) (hr : 2 ≤ r) :
    ∃ Csb : ℝ, 0 < Csb ∧ ∀ n : ℕ, r < n → ∀ lam ϱ : ℝ, 0 < lam → 0 < ϱ →
      ENNReal.ofReal (Real.exp (-(Csb * (1 + ((n : ℝ) ^ ((r : ℝ) - 1 / 2) / (lam * ϱ)) ^
          ((2 : ℝ) / (2 * r - 1))))))
        ≤ Qlam (n - r) lam (Bsb r n ϱ) := by
  have hr_real : (2 : ℝ) ≤ r := Nat.ofNat_le_cast.mpr hr
  have h2r1_pos : (0 : ℝ) < 2 * (r : ℝ) - 1 := by linarith
  have hcF_pos : 0 < cF r := by
    unfold cF cInf
    have hr_pos : (0 : ℝ) < r := Nat.cast_pos.mpr (by omega)
    have hfac_pos : (0 : ℝ) < ((r - 1).factorial : ℝ) := Nat.cast_pos.mpr (Nat.factorial_pos _)
    positivity
  let β : ℝ := BQTF.Lin.betaR r
  have hβ_pos : 0 < β := BQTF.Lin.betaR_pos r hr
  let α : ℝ :=
    (64 * (6 : ℝ) ^ (2 * r - 1) * cF r ^ 2 / (2 * (r : ℝ) - 1)) ^ ((1 : ℝ) / (2 * r - 1))
  have hα_pos : 0 < α := Real.rpow_pos_of_pos (by positivity) _
  let Csb : ℝ := max (Real.log (8 / 3 : ℝ) + β) (β * α)
  have hCsb_pos : 0 < Csb := lt_of_lt_of_le (mul_pos hβ_pos hα_pos) (le_max_right _ _)
  refine ⟨Csb, hCsb_pos, fun n hn lam ϱ hlam hϱ => ?_⟩
  let m : ℕ := n - r
  have hn0 : (0 : ℝ) < n := Nat.cast_pos.mpr (by omega)
  have hr_exp : 0 < lam ^ 2 / 2 := by positivity
  have : IsProbabilityMeasure (expMeasure (lam ^ 2 / 2)) := isProbabilityMeasure_expMeasure hr_exp
  let μV : Measure (Fin m → ℝ) := Measure.pi fun _ : Fin m => expMeasure (lam ^ 2 / 2)
  let μG : Measure (Fin m → ℝ) := Measure.pi fun _ : Fin m => gaussianReal 0 1
  let F : (Fin m → ℝ) × (Fin m → ℝ) → (Fin m → ℝ) :=
    fun vg j => Real.sqrt (vg.1 j) * vg.2 j
  have hF_meas : Measurable F := by
    refine Measurable.of_eval fun j => ?_
    exact (Real.continuous_sqrt.measurable.comp ((measurable_pi_apply j).comp measurable_fst)).mul
      ((measurable_pi_apply j).comp measurable_snd)
  -- Measurability of `Bsb r n ϱ`.
  have hBsb_meas : MeasurableSet (Bsb r n ϱ) := by
    have hAsb_cont : Continuous (Asb r n) := by
      unfold Asb
      have hSmul_cont : Continuous (Smul r n) := by
        refine continuous_pi fun i => continuous_finsetSum _ fun j _ => ?_
        exact (continuous_apply j).mul continuous_const
      exact (continuous_const (y := (n : ℝ) ^ (-(1 / 2 : ℝ)))).smul
        ((Pperp r n).continuous_of_finiteDimensional.comp hSmul_cont)
    have hl2_cont : Continuous (fun u : Fin m → ℝ => l2norm (Asb r n u)) :=
      Real.continuous_sqrt.comp (continuous_finsetSum _ fun i _ =>
        ((continuous_apply i).comp hAsb_cont).pow 2)
    exact measurableSet_le hl2_cont.measurable measurable_const
  -- Rewrite `Qlam m lam (Bsb r n ϱ)` via Andrews–Mallows and Tonelli.
  have hQ_eq : Qlam m lam (Bsb r n ϱ) =
      ∫⁻ V : Fin m → ℝ, μG {g : Fin m → ℝ | l2norm (Asb r n fun j => Real.sqrt (V j) * g j) ≤ ϱ}
        ∂μV := by
    rw [BQTF.Lin.Qlam_eq_map_exp_gaussian m hlam, Measure.map_apply hF_meas hBsb_meas,
      Measure.prod_apply (hF_meas hBsb_meas)]
    rfl
  rw [hQ_eq]
  -- Define the good variance event `𝒱` and the deterministic small-ball parameters `b, K`.
  let Vset : Set (Fin m → ℝ) := {V | (∀ j, 0 ≤ V j) ∧ ∑ j, V j ≤ 4 * (m : ℝ) / lam ^ 2}
  have hVset_meas : MeasurableSet Vset := by
    have hVset_eq : Vset = (⋂ j : Fin m, {V : Fin m → ℝ | (0 : ℝ) ≤ V j}) ∩
        {V : Fin m → ℝ | ∑ j : Fin m, V j ≤ 4 * (m : ℝ) / lam ^ 2} := by
      ext V; simp [Vset]
    rw [hVset_eq]
    exact (MeasurableSet.iInter fun j => measurableSet_le measurable_const (measurable_pi_apply j)).inter
      (measurableSet_le (Finset.measurable_sum _ fun j _ => measurable_pi_apply j) measurable_const)
  let b : ℝ := 8 * (6 : ℝ) ^ (2 * r - 1) * cF r ^ 2 * (n : ℝ) ^ (2 * r - 1) / lam ^ 2
  have hb_pos : 0 < b := by positivity
  let K : ℕ := Nat.ceil ((8 * b / ((2 * (r : ℝ) - 1) * ϱ ^ 2)) ^ ((1 : ℝ) / (2 * r - 1)))
  -- For every `V ∈ Vset`, the Gaussian conditional probability is at least `(3/4) * exp(-β K)`.
  have hcond : ∀ V ∈ Vset,
      ENNReal.ofReal ((3 / 4 : ℝ) * Real.exp (-(β * K))) ≤
        μG {g : Fin m → ℝ | l2norm (Asb r n fun j => Real.sqrt (V j) * g j) ≤ ϱ} := by
    intro V hV
    have hset_eq : {g : Fin m → ℝ | l2norm (Asb r n fun j => Real.sqrt (V j) * g j) ≤ ϱ} =
        {g : Fin m → ℝ | ‖Gop r n V (WithLp.toLp 2 g)‖ ^ 2 ≤ ϱ ^ 2} := by
      ext g
      simp only [Set.mem_ofPred_eq]
      have hnorm_eq : ‖Gop r n V (WithLp.toLp 2 g)‖ =
          l2norm (Asb r n fun j => Real.sqrt (V j) * g j) :=
        norm_toE _
      rw [hnorm_eq]
      constructor
      · intro h; exact pow_le_pow_left₀ (Real.sqrt_nonneg _) h 2
      · intro h; exact le_of_sq_le_sq h hϱ.le
    rw [hset_eq, BQTF.Lin.gaussian_norm_sq_measure_le (Gop r n V) (ϱ ^ 2)]
    exact BQTF.Lin.gaussian_weighted_sum_small_ball hr
      (fun q => (Gop r n V).singularValues q ^ 2)
      (fun q => sq_nonneg _) hb_pos hϱ
      (singularValues_sq_decay hr hn hlam hV.1 hV.2)
  -- Restrict the outer integral to `Vset` and apply Markov (`1 / 2 ≤ μV Vset`).
  have hlow_38 : ENNReal.ofReal ((3 / 8 : ℝ) * Real.exp (-(β * K))) ≤
      ∫⁻ V : Fin m → ℝ,
        μG {g : Fin m → ℝ | l2norm (Asb r n fun j => Real.sqrt (V j) * g j) ≤ ϱ} ∂μV := by
    have h1 : ∫⁻ V in Vset, ENNReal.ofReal ((3 / 4 : ℝ) * Real.exp (-(β * K))) ∂μV ≤
        ∫⁻ V : Fin m → ℝ,
          μG {g : Fin m → ℝ | l2norm (Asb r n fun j => Real.sqrt (V j) * g j) ≤ ϱ} ∂μV := by
      refine (setLIntegral_mono' hVset_meas hcond).trans (setLIntegral_le_lintegral Vset _)
    rw [setLIntegral_const] at h1
    have hmarkov : (1 / 2 : ℝ≥0∞) ≤ μV Vset := BQTF.Lin.expMeasure_sum_le_markov m hlam
    have hhalf_eq : (1 / 2 : ℝ≥0∞) = ENNReal.ofReal (1 / 2 : ℝ) := by
      rw [ENNReal.ofReal_div_of_pos (by norm_num), ENNReal.ofReal_one, ENNReal.ofReal_ofNat]
    calc ENNReal.ofReal ((3 / 8 : ℝ) * Real.exp (-(β * K)))
        = ENNReal.ofReal ((3 / 4 : ℝ) * Real.exp (-(β * K))) * (1 / 2 : ℝ≥0∞) := by
          rw [hhalf_eq, ← ENNReal.ofReal_mul (by positivity)]; congr 1; ring
      _ ≤ ENNReal.ofReal ((3 / 4 : ℝ) * Real.exp (-(β * K))) * μV Vset :=
          mul_le_mul_of_nonneg_left hmarkov zero_le
      _ ≤ _ := h1
  -- Compare `exp(-Csb * (1 + x^{2/(2r-1)}))` with `(3 / 8) * exp(-β K)`.
  refine le_trans ?_ hlow_38
  apply ENNReal.ofReal_le_ofReal
  let x : ℝ := (n : ℝ) ^ ((r : ℝ) - 1 / 2) / (lam * ϱ)
  have hx_pos : 0 < x := by positivity
  have h8b_eq : 8 * b / ((2 * (r : ℝ) - 1) * ϱ ^ 2) =
      (64 * (6 : ℝ) ^ (2 * r - 1) * cF r ^ 2 / (2 * (r : ℝ) - 1)) * x ^ 2 := by
    dsimp only [b, x]
    rw [div_pow, ← Real.rpow_natCast ((n : ℝ) ^ ((r : ℝ) - 1 / 2)) 2, ← Real.rpow_mul hn0.le]
    have hexp : ((r : ℝ) - 1 / 2) * (2 : ℕ) = ((2 * r - 1 : ℕ) : ℝ) := by
      rw [Nat.cast_sub (by omega)]; push_cast; ring
    rw [hexp, Real.rpow_natCast]
    field_simp [h2r1_pos.ne', hlam.ne', hϱ.ne']
    ring
  have harg_eq : (8 * b / ((2 * (r : ℝ) - 1) * ϱ ^ 2)) ^ ((1 : ℝ) / (2 * r - 1)) =
      α * x ^ ((2 : ℝ) / (2 * r - 1)) := by
    rw [h8b_eq, Real.mul_rpow (by positivity) (sq_nonneg x)]
    congr 1
    rw [← Real.rpow_natCast x 2, ← Real.rpow_mul hx_pos.le]
    congr 1; push_cast; ring
  have hK_le : (K : ℝ) ≤ 1 + α * x ^ ((2 : ℝ) / (2 * r - 1)) := by
    have hlt := Nat.ceil_lt_add_one (show (0 : ℝ) ≤ (8 * b / ((2 * (r : ℝ) - 1) * ϱ ^ 2)) ^
        ((1 : ℝ) / (2 * r - 1)) by positivity)
    dsimp only [K]
    rw [harg_eq] at hlt ⊢
    linarith
  have h38_eq : (3 / 8 : ℝ) * Real.exp (-(β * K)) =
      Real.exp (-(Real.log (8 / 3 : ℝ) + β * K)) := by
    rw [neg_add, Real.exp_add, Real.exp_neg (Real.log (8 / 3 : ℝ)),
      Real.exp_log (by norm_num : (0 : ℝ) < 8 / 3)]
    norm_num
  rw [h38_eq]
  apply Real.exp_le_exp.mpr
  have hC1 : Real.log (8 / 3 : ℝ) + β ≤ Csb := le_max_left _ _
  have hC2 : β * α ≤ Csb := le_max_right _ _
  have hxp_nn : 0 ≤ x ^ ((2 : ℝ) / (2 * r - 1)) := Real.rpow_nonneg hx_pos.le _
  have hbound : Real.log (8 / 3 : ℝ) + β * (K : ℝ) ≤
      Csb * (1 + x ^ ((2 : ℝ) / (2 * r - 1))) := by
    calc Real.log (8 / 3 : ℝ) + β * (K : ℝ)
        ≤ Real.log (8 / 3 : ℝ) + β * (1 + α * x ^ ((2 : ℝ) / (2 * r - 1))) :=
          add_le_add le_rfl (mul_le_mul_of_nonneg_left hK_le hβ_pos.le)
      _ = (Real.log (8 / 3 : ℝ) + β) + (β * α) * x ^ ((2 : ℝ) / (2 * r - 1)) := by ring
      _ ≤ Csb + Csb * x ^ ((2 : ℝ) / (2 * r - 1)) :=
          add_le_add hC1 (mul_le_mul_of_nonneg_right hC2 hxp_nn)
      _ = Csb * (1 + x ^ ((2 : ℝ) / (2 * r - 1))) := by ring
  linarith

end BQTF
