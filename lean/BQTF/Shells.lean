import BQTF.Asym.CheckIntegrals
import BQTF.Asym.ShellRates
import BQTF.Score
import BQTF.Coord
import BQTF.Localization

/-!
# Shells (appendix, Proposition `pf:prop:shell`)

Owner: Neon-B. `E_a = {θ : ‖δ‖_∞ ≤ s_0, a n ε_n² < ‖δ‖₂² ≤ 2a n ε_n²}`,
`J = ⌊(f̲²/128) M n ε_n²⌋ − r`, `C_fine = 2^{2r+1} c_F² (256/f̲²)^{2r−1}`.
-/

open MeasureTheory ProbabilityTheory
open scoped ENNReal

noncomputable section

namespace BQTF

/-- The shell `E_a`. -/
def Eshell (k n : ℕ) (L fl fu a : ℝ) (θs : Fin n → ℝ) : Set (Fin n → ℝ) :=
  {θ | (∀ i, |θ i - θs i| ≤ s0 L fl fu) ∧ a * n * epsSq (k + 1) n < l2sq (θ - θs) ∧
       l2sq (θ - θs) ≤ 2 * a * n * epsSq (k + 1) n}

/-- `J = ⌊(f̲²/128) M n ε_n²⌋ − r` (natural-number floor and subtraction). -/
def Jshell (k n : ℕ) (fl M : ℝ) : ℕ := ⌊fl ^ 2 / 128 * M * n * epsSq (k + 1) n⌋₊ - (k + 1)

/-- `C_fine = 2^{2r+1} c_F² (256/f̲²)^{2r−1}`. -/
def Cfine (r : ℕ) (fl : ℝ) : ℝ := 2 ^ (2 * r + 1) * cF r ^ 2 * (256 / fl ^ 2) ^ (2 * r - 1)

private theorem shell_size (k : ℕ) (hk : 1 ≤ k) (fl M d : ℝ)
    (hfl : 0 < fl) (hM : 0 < M) (hd : 0 < d) :
    ∃ N : ℕ, k + 1 < N ∧ ∀ n ≥ N,
      1 ≤ Jshell k n fl M ∧ Jshell k n fl M ≤ n - (k + 1) ∧
      fl ^ 2 / 256 * M * n * epsSq (k + 1) n ≤ Jshell k n fl M ∧
      ((Jshell k n fl M + (k + 1 : ℕ) : ℕ) : ℝ) ≤ fl ^ 2 / 128 * M * n * epsSq (k + 1) n ∧
      Real.log (2 * n) ≤ d * (n * epsSq (k + 1) n) := by
  let D := fl ^ 2 / 256 * M
  have hD : 0 < D := by dsimp [D]; positivity
  let r := k + 1
  obtain ⟨N₁, hN₁⟩ := Asym.eventually_mul_epsSq_ge r (by dsimp [r]; omega)
    (((r : ℝ) + 1) / D)
  obtain ⟨N₂, hN₂⟩ := Filter.eventually_atTop.mp
    (Asym.epsSq_eventually_le r (by dsimp [r]; omega) (1 / (2 * D)) (by positivity))
  obtain ⟨N₃, hN₃⟩ := Filter.eventually_atTop.mp
    (Asym.log_twice_eventually_le r (by dsimp [r]; omega) d hd)
  refine ⟨max (r + 1) (max N₁ (max N₂ N₃)), ?_, ?_⟩
  · exact Nat.lt_of_lt_of_le (by omega : r < r + 1) (le_max_left _ _)
  intro n hn
  have hnr : r < n := lt_of_lt_of_le (by omega : r < r + 1) ((le_max_left _ _).trans hn)
  have hn₁ : N₁ ≤ n := (le_max_left _ _).trans ((le_max_right _ _).trans hn)
  have hn₂ : N₂ ≤ n := (le_max_left _ _).trans ((le_max_right _ _).trans
    ((le_max_right _ _).trans hn))
  have hn₃ : N₃ ≤ n := (le_max_right _ _).trans ((le_max_right _ _).trans
    ((le_max_right _ _).trans hn))
  let x := (n : ℝ) * epsSq r n
  have hnpos : 0 < (n : ℝ) := by exact_mod_cast (show 0 < n by omega)
  have hx : 0 < x := mul_pos hnpos (Real.rpow_pos_of_pos hnpos _)
  have hbig : (r : ℝ) + 1 ≤ D * x := by
    rw [mul_comm]
    exact (div_le_iff₀ hD).mp (hN₁ n hn₁).2
  have hf : ⌊2 * D * x⌋₊ ≤ n := by
    have h : (⌊2 * D * x⌋₊ : ℝ) ≤ n := by
      apply (Nat.floor_le (show 0 ≤ (2 * D * x : ℝ) by positivity)).trans
      have he := (le_div_iff₀ (show 0 < 2 * D by positivity)).mp (hN₂ n hn₂)
      dsimp [x]
      nlinarith only [mul_le_mul_of_nonneg_right he (show 0 ≤ (n : ℝ) by positivity)]
    exact_mod_cast h
  have hf' : (2 * D * x : ℝ) < ⌊2 * D * x⌋₊ + 1 := Nat.lt_floor_add_one _
  have hfloor : r ≤ ⌊2 * D * x⌋₊ := by
    have h : (r : ℝ) ≤ ⌊2 * D * x⌋₊ := by linarith
    exact_mod_cast h
  have hsub : ((⌊2 * D * x⌋₊ - r : ℕ) : ℝ) = (⌊2 * D * x⌋₊ : ℕ) - (r : ℝ) :=
    Nat.cast_sub hfloor
  have hJ : Jshell k n fl M = ⌊2 * D * x⌋₊ - r := by
    unfold Jshell
    congr 2
    dsimp [D, x]
    ring
  have hr' : (0 : ℝ) ≤ r := by positivity
  have hlow : D * x ≤ ((⌊2 * D * x⌋₊ - r : ℕ) : ℝ) := by
    rw [hsub]
    linarith
  refine ⟨?_, ?_, ?_, ?_, hN₃ n hn₃⟩
  · rw [hJ]
    have h : (1 : ℝ) ≤ ((⌊2 * D * x⌋₊ - r : ℕ) : ℝ) := by linarith
    exact_mod_cast h
  · rw [hJ]
    exact Nat.sub_le_sub_right hf _
  · rw [hJ]
    convert hlow using 1
    dsimp [D, x, r]
    ring
  · change ((Jshell k n fl M + r : ℕ) : ℝ) ≤ _
    rw [hJ, Nat.sub_add_cancel hfloor]
    convert Nat.floor_le (show 0 ≤ 2 * D * x by positivity) using 1
    dsimp [D, x, r]
    ring

private theorem shell_score_decomp (r n J : ℕ) (hr : 1 ≤ r) (hn : r < n)
    (ζ δ : Fin n → ℝ) :
    dot δ ζ = dot δ (PJ r n J ζ) + dot (tScore r n J ζ) (diffOp r n δ) := by
  let u := diffOp r n δ
  have hpoly : δ - Smul r n u ∈ polySpace r n := by
    apply (diffOp_eq_zero_iff r n hr hn _).mp
    rw [diffOp_sub, diffOp_Smul r n hr hn]
    exact sub_self _
  have hp := PJ_fixes_poly r n J _ hpoly
  rw [map_sub] at hp
  have hres : δ - PJ r n J δ = Smul r n u - PJ r n J (Smul r n u) := by
    rw [sub_eq_sub_iff_add_eq_add]
    simpa only [add_comm (Smul r n u)] using (sub_eq_sub_iff_add_eq_add.mp hp).symm
  have hsum : Smul r n u = ∑ j, u j • sCol r n j := by
    ext i
    simp [Smul, Finset.sum_apply]
  have hterm : dot (Smul r n u - PJ r n J (Smul r n u)) ζ = dot (tScore r n J ζ) u := by
    rw [hsum, map_sum, ← Finset.sum_sub_distrib]
    simp_rw [map_smul, ← smul_sub]
    unfold dot tScore
    simp_rw [Finset.sum_apply, Finset.sum_mul, Pi.smul_apply, smul_eq_mul, mul_assoc]
    rw [Finset.sum_comm]
    apply Finset.sum_congr rfl
    intro j _
    rw [← Finset.mul_sum, mul_comm]
    rfl
  have horth : dot (PJ r n J δ) ζ = dot δ (PJ r n J ζ) := dot_orthProj _ _ _
  have hd : dot (δ - PJ r n J δ) ζ = dot δ ζ - dot (PJ r n J δ) ζ := by
    simp [dot, sub_mul, Finset.sum_sub_distrib]
  rw [hres, hterm] at hd
  rw [← horth]
  linarith

private theorem l2sq_nonneg_shell {n : ℕ} (v : Fin n → ℝ) : 0 ≤ l2sq v :=
  Finset.sum_nonneg fun _ _ => sq_nonneg _

private theorem measurableSet_shell (k n : ℕ) (L fl fu a : ℝ) (θs : Fin n → ℝ) :
    MeasurableSet (Eshell k n L fl fu a θs) := by
  have hi (i : Fin n) : Measurable (fun θ : Fin n → ℝ => |θ i - θs i|) :=
    ((measurable_pi_apply i).sub_const _).abs
  have hs : Measurable (fun θ => l2sq (θ - θs)) :=
    (continuous_l2sq n).measurable.comp (measurable_id.sub_const _)
  unfold Eshell
  rw [Set.ofPred_and, Set.ofPred_forall, Set.ofPred_and]
  exact (MeasurableSet.iInter fun i => measurableSet_le (hi i) measurable_const).inter
    ((measurableSet_lt measurable_const hs).inter (measurableSet_le hs measurable_const))

private theorem measurable_score_vector {n : ℕ} (τ : ℝ) (θs : Fin n → ℝ) :
    Measurable (fun y => score τ (y - θs)) := by
  apply Measurable.of_eval
  intro i
  exact (measurable_scoreZ τ).comp ((measurable_pi_apply i).sub_const _)

private theorem measurableSet_shell_score (r n J : ℕ) (τ : ℝ) (θs : Fin n → ℝ) :
    MeasurableSet (OmegaZeta r n J τ θs) := by
  have hζ := measurable_score_vector τ θs
  have hp := (PJ r n J).continuous_of_finiteDimensional.measurable.comp hζ
  have ht : Measurable (fun y => tScore r n J (score τ (y - θs))) := by
    apply Measurable.of_eval
    intro j
    exact (continuous_dot n).measurable.comp (measurable_const.prodMk hζ)
  unfold OmegaZeta
  rw [Set.ofPred_and, Set.ofPred_and, Set.ofPred_forall]
  exact (measurableSet_le ((continuous_l2sq n).measurable.comp hp) measurable_const).inter
    ((MeasurableSet.iInter fun j =>
      measurableSet_le ((measurable_pi_apply j).comp ht).abs measurable_const).inter
      (measurableSet_le ((continuous_l2sq (n-r)).measurable.comp ht) measurable_const))

private theorem inv_one_sub_le_exp {x : ℝ} (hx : 0 ≤ x) (hx' : x ≤ 1 / 2) :
    (1 - x)⁻¹ ≤ Real.exp (2 * x) := by
  have hv : 0 < 1 - x := by linarith
  rw [← Real.exp_log (inv_pos.mpr hv), Real.exp_le_exp, Real.log_inv]
  have hb := Real.log_le_sub_one_of_pos (inv_pos.mpr hv)
  rw [Real.log_inv] at hb
  refine hb.trans ?_
  rw [sub_le_iff_le_add, inv_eq_one_div, div_le_iff₀ hv]
  nlinarith [mul_nonneg hx (show 0 ≤ 1 - 2 * x by linarith)]

private theorem Qlam_score_bound {m : ℕ} {lam : ℝ} (hlam : 0 < lam) (t : Fin m → ℝ)
    (ht : ∀ j, (2 * t j / lam) ^ 2 ≤ 1 / 2) :
    (∫⁻ u, ENNReal.ofReal (Real.exp (dot (fun j => 2 * t j) u)) ∂Qlam m lam)
      ≤ ENNReal.ofReal (Real.exp (8 * l2sq t / lam ^ 2)) := by
  have hsmall (j : Fin m) : |2 * t j| < lam := by
    have hp : |2 * t j / lam| < 1 := by
      rw [← sq_lt_sq₀ (abs_nonneg _) (by norm_num : (0 : ℝ) ≤ 1), sq_abs]
      exact (ht j).trans_lt (by norm_num)
    rwa [abs_div, abs_of_pos hlam, div_lt_one hlam] at hp
  rw [Qlam_lintegral_exp_dot hlam _ hsmall]
  calc
    _ ≤ ∏ j, ENNReal.ofReal (Real.exp (2 * (2 * t j / lam) ^ 2)) :=
      Finset.prod_le_prod fun j _ =>
        ENNReal.ofReal_le_ofReal (inv_one_sub_le_exp (sq_nonneg _) (ht j))
    _ = _ := by
      rw [← ENNReal.ofReal_prod_of_nonneg (fun _ _ => Real.exp_nonneg _), ← Real.exp_sum]
      congr 2
      unfold l2sq
      rw [div_eq_mul_inv, mul_comm, ← mul_assoc, Finset.mul_sum]
      apply Finset.sum_congr rfl
      intro j _
      ring

private theorem shell_score_integral {k n J : ℕ} {L fl fu a lam : ℝ} (hn : k + 1 < n)
    (hlam : 0 < lam) (ha : 0 < a) (θs ζ : Fin n → ℝ)
    (hPJ : (l2sq (PJ (k + 1) n J ζ)) ≤ fl ^ 2 / 128 * a * n * epsSq (k + 1) n)
    (hfl : 0 < fl)
    (ht : ∀ j, (2 * tScore (k + 1) n J ζ j / lam) ^ 2 ≤ 1 / 2) :
    let t := tScore (k + 1) n J ζ
    (∫⁻ θ in Eshell k n L fl fu a θs, ENNReal.ofReal (Real.exp (2 * dot (θ - θs) ζ))
        ∂(nu (k + 1) n lam)) ≤
      Vr (k + 1) * ENNReal.ofReal ((2 * a * n * epsSq (k + 1) n) ^ ((k + 1 : ℝ) / 2)) *
        ENNReal.ofReal (Real.exp (fl / 4 * a * n * epsSq (k + 1) n -
          2 * dot t (ustar (k + 1) n θs) + 8 * l2sq t / lam ^ 2)) := by
  let r := k + 1
  let t := tScore r n J ζ
  let x := a * (n : ℝ) * epsSq r n
  let R := Real.sqrt (2 * x)
  let B := fl / 4 * x - 2 * dot t (ustar r n θs)
  let H (u : Fin (n - r) → ℝ) := ENNReal.ofReal (Real.exp (dot (fun j => 2 * t j) u))
  let U := {θ : Fin n → ℝ | l2norm (NT r n (θ - θs)) ≤ R}
  have hn' : 0 < (n : ℝ) := by exact_mod_cast (show 0 < n by omega)
  have hx : 0 < x := mul_pos (mul_pos ha hn') (Real.rpow_pos_of_pos hn' _)
  have hH : Measurable H := by
    exact (Real.measurable_exp.comp ((continuous_dot (n-r)).measurable.comp
      (measurable_const.prodMk measurable_id))).ennreal_ofReal
  have hpow : R ^ r = (2 * a * n * epsSq r n) ^ ((k + 1 : ℝ) / 2) := by
    have hr : (r : ℝ) = k + 1 := by simp [r]
    rw [← hr]
    dsimp [R]
    rw [Real.sqrt_eq_rpow, ← Real.rpow_mul_natCast (by positivity)]
    rw [show 2 * x = 2 * a * n * epsSq r n by dsimp [x]; ring,
      show (1 / 2 : ℝ) * r = (r : ℝ) / 2 by ring]
  have hproj (θ : Fin n → ℝ) (hθ : θ ∈ Eshell k n L fl fu a θs) :
      dot (θ - θs) (PJ r n J ζ) ≤ fl / 8 * x := by
    have hθ' : l2sq (θ - θs) ≤ 2 * x := by
      simpa only [x, mul_assoc] using hθ.2.2
    have hPJ' : l2sq (PJ r n J ζ) ≤ fl ^ 2 / 128 * x := by
      simpa only [x, mul_assoc] using hPJ
    have hp : l2norm (θ - θs) * l2norm (PJ r n J ζ) ≤ fl / 8 * x := by
      rw [← sq_le_sq₀ (by unfold l2norm; positivity) (by positivity)]
      unfold l2norm
      rw [mul_pow, Real.sq_sqrt (l2sq_nonneg_shell _), Real.sq_sqrt (l2sq_nonneg_shell _)]
      calc
        _ ≤ (2 * x) * (fl ^ 2 / 128 * x) :=
          mul_le_mul hθ' hPJ' (l2sq_nonneg_shell _) (by positivity)
        _ = _ := by ring
    exact (le_abs_self _).trans ((abs_dot_le _ _).trans hp)
  have hU (θ : Fin n → ℝ) (hθ : θ ∈ Eshell k n L fl fu a θs) : θ ∈ U := by
    obtain ⟨⟨c, u⟩, rfl⟩ := (coordMap_bijective r n (by dsimp [r]; omega) hn).1.2 θ
    change l2norm (NT r n (coordMap r n (c,u) - θs)) ≤ R
    rw [← sub_cbar_eq r n (by dsimp [r]; omega) hn]
    apply Real.sqrt_le_sqrt
    have h := pythagoras r n (by dsimp [r]; omega) hn θs c u
    have hθ' : l2sq (coordMap r n (c,u) - θs) ≤ 2 * x := by
      simpa only [x, mul_assoc] using hθ.2.2
    linarith [l2sq_nonneg_shell (Pperp r n (Smul r n (u - ustar r n θs)))]
  have he (θ : Fin n → ℝ) (hθ : θ ∈ Eshell k n L fl fu a θs) :
      2 * dot (θ - θs) ζ ≤ B + dot (fun j => 2 * t j) (diffOp r n θ) := by
    rw [shell_score_decomp r n J (by dsimp [r]; omega) hn, diffOp_sub]
    have hdot : 2 * dot t (diffOp r n θ - diffOp r n θs) =
        dot (fun j => 2 * t j) (diffOp r n θ) - 2 * dot t (ustar r n θs) := by
      simp [dot, ustar, mul_sub, Finset.sum_sub_distrib, Finset.mul_sum, mul_assoc]
    dsimp [B]
    change 2 * (dot (θ - θs) (PJ r n J ζ) + dot t _) ≤ _
    rw [mul_add, hdot]
    linarith [hproj θ hθ]
  let Y := Eshell k n L fl fu a θs
  calc
    _ = ∫⁻ θ, Y.indicator (fun θ => ENNReal.ofReal (Real.exp (2 * dot (θ - θs) ζ))) θ
        ∂(nu r n lam) := (lintegral_indicator (measurableSet_shell ..) _).symm
    _ ≤ ∫⁻ θ, ENNReal.ofReal (Real.exp B) * U.indicator (fun θ => H (diffOp r n θ)) θ
        ∂(nu r n lam) := by
      apply lintegral_mono
      intro θ
      by_cases hθ : θ ∈ Y
      · change Y.indicator _ θ ≤ ENNReal.ofReal (Real.exp B) * U.indicator _ θ
        rw [Set.indicator_of_mem hθ, Set.indicator_of_mem (hU θ hθ)]
        dsimp [H]
        rw [← ENNReal.ofReal_mul (Real.exp_nonneg _), ← Real.exp_add]
        exact ENNReal.ofReal_le_ofReal (Real.exp_le_exp.mpr (he θ hθ))
      · change Y.indicator _ θ ≤ _
        rw [Set.indicator_of_notMem hθ]
        exact bot_le
    _ = ENNReal.ofReal (Real.exp B) *
        (Vr r * (ENNReal.ofReal (R ^ r) * ∫⁻ u, H u ∂(Qlam (n-r) lam))) := by
      rw [lintegral_const_mul' _ _ ENNReal.ofReal_ne_top]
      rw [vol_formula r n (by dsimp [r]; omega) hn lam hlam θs H hH
        (fun _ => R) measurable_const (fun _ => Real.sqrt_nonneg _)]
      rw [lintegral_const_mul _ hH]
    _ ≤ ENNReal.ofReal (Real.exp B) *
        (Vr r * (ENNReal.ofReal (R ^ r) * ENNReal.ofReal (Real.exp (8 * l2sq t / lam ^ 2)))) := by
      gcongr
      exact Qlam_score_bound hlam t ht
    _ = _ := by
      rw [hpow]
      have hB : fl / 4 * a * n * epsSq r n - 2 * dot t (ustar r n θs) = B := by
        dsimp [B, x]
        ring
      change _ = Vr r * _ * ENNReal.ofReal (Real.exp
        (fl / 4 * a * n * epsSq r n - 2 * dot t (ustar r n θs) + 8 * l2sq t / lam ^ 2))
      rw [hB]
      rw [Real.exp_add, ENNReal.ofReal_mul (Real.exp_nonneg _)]
      ac_rfl

private theorem shell_score_sizes {k n J : ℕ} {c fl M Vb d : ℝ}
    (hk : 1 ≤ k) (hn : k + 1 < n) (hJ : 1 ≤ J) (hJm : J ≤ n - (k + 1))
    (hc : 0 < c) (hfl : 0 < fl) (hM : 0 < M) {τ : ℝ} {y θs : Fin n → ℝ}
    (hy : y ∈ OmegaZeta (k + 1) n J τ θs)
    (hTV : TV k n θs ≤ Vb)
    (hJlow : fl ^ 2 / 256 * M * n * epsSq (k + 1) n ≤ J)
    (hlog : Real.log (2 * n) ≤ d * (n * epsSq (k + 1) n)) :
    let r := k + 1
    let p := 2 * r - 1
    let D := fl ^ 2 / 256 * M
    let K := 2 ^ p * cF r ^ 2 / D ^ p
    let x := (n : ℝ) * epsSq r n
    let t := tScore r n J (score τ (y - θs))
    let lam := lamSeq c k n
    0 ≤ d → 4 * (K / c ^ 2) * d ≤ 1 / 2 → (K * Vb ^ 2) * d ≤ 1 →
    (∀ j, (2 * t j / lam) ^ 2 ≤ 1 / 2) ∧
    8 * l2sq t / lam ^ 2 ≤ 2 * (Cfine r fl / (c ^ 2 * M ^ p)) * x ∧
    |dot t (ustar r n θs)| ≤ x := by
  let r := k + 1
  let p := 2 * r - 1
  let D := fl ^ 2 / 256 * M
  let K := 2 ^ p * cF r ^ 2 / D ^ p
  let x := (n : ℝ) * epsSq r n
  let t := tScore r n J (score τ (y - θs))
  let lam := lamSeq c k n
  let h := BQTF.hJ (n - r) J
  change 0 ≤ d → 4 * (K / c ^ 2) * d ≤ 1 / 2 → (K * Vb ^ 2) * d ≤ 1 →
    (∀ j, (2 * t j / lam) ^ 2 ≤ 1 / 2) ∧
    8 * l2sq t / lam ^ 2 ≤ 2 * (Cfine r fl / (c ^ 2 * M ^ p)) * x ∧
    |dot t (ustar r n θs)| ≤ x
  intro hd hsmall hshift
  have hp : p = 2 * k + 1 := by dsimp [p, r]; omega
  have hn' : 0 < (n : ℝ) := by exact_mod_cast (show 0 < n by omega)
  have hx' : 1 ≤ x := by
    dsimp [x]
    rw [Asym.mul_epsSq_eq _ _ (by dsimp [r]; omega) (by omega)]
    exact Real.one_le_rpow (by exact_mod_cast (show 1 ≤ n by omega)) (by positivity)
  have hx : 0 < x := zero_lt_one.trans_le hx'
  have hxp : 0 < x ^ p := pow_pos hx _
  have hxn : x ^ p * x = n := by
    rw [← pow_succ, show p + 1 = 2 * r by dsimp [p, r]; omega]
    exact Asym.mul_epsSq_pow _ _ (by dsimp [r]; omega) (by omega)
  have hD : 0 < D := by dsimp [D]; positivity
  have hK : 0 ≤ K := by dsimp [K]; positivity
  have hlam : 0 < lam := mul_pos hc (Real.rpow_pos_of_pos hn' _)
  have hlogs : 0 ≤ Real.log (2 * n) := Real.log_nonneg (by
    have : (1 : ℝ) ≤ n := by exact_mod_cast (show 1 ≤ n by omega)
    linarith)
  have hcF : 0 ≤ cF r := by unfold cF cInf; positivity
  have hProj : (h : ℝ) ≤ 2 * n / (D * x) := by
    apply ((hJ_le r n J hn hJ hJm).2.1).trans
    apply div_le_div_of_nonneg_left (by positivity) (by positivity)
    simpa only [D, x, mul_assoc] using hJlow
  have hpow : cF r ^ 2 * (h : ℝ) ^ p ≤ K * (n : ℝ) ^ p / x ^ p := by
    calc
      _ ≤ cF r ^ 2 * (2 * n / (D * x)) ^ p :=
        mul_le_mul_of_nonneg_left (pow_le_pow_left₀ (by positivity) hProj _) (sq_nonneg _)
      _ = _ := by
        dsimp [K]
        rw [div_pow, mul_pow (2 : ℝ), mul_pow D]
        field_simp
  have hlamSq : lam ^ 2 = c ^ 2 * (n : ℝ) ^ p := by
    dsimp [lam, lamSeq]
    rw [mul_pow, ← Real.rpow_mul_natCast hn'.le, hp, ← Real.rpow_natCast (n : ℝ) (2 * k + 1)]
    congr 2
    push_cast
    ring
  have hscaled : cF r ^ 2 * (h : ℝ) ^ p / lam ^ 2 ≤ (K / c ^ 2) / x ^ p := by
    calc
      _ ≤ (K * (n : ℝ) ^ p / x ^ p) / lam ^ 2 :=
        div_le_div_of_nonneg_right hpow (by positivity)
      _ = _ := by rw [hlamSq]; field_simp
  have hSupSq (j : Fin (n - r)) : (t j) ^ 2 ≤ cF r ^ 2 * (h : ℝ) ^ p * Real.log (2 * n) := by
    have H := pow_le_pow_left₀ (abs_nonneg _) (hy.2.1 j) 2
    have he : ((h : ℝ) ^ ((r : ℝ) - 1 / 2)) ^ 2 = (h : ℝ) ^ p := by
      rw [← Real.rpow_mul_natCast (by positivity), hp, ← Real.rpow_natCast]
      push_cast
      congr 1
      simp only [r, Nat.cast_add, Nat.cast_one]
      ring
    rw [sq_abs, mul_pow, mul_pow, he, Real.sq_sqrt hlogs] at H
    exact H
  have hl2 : l2sq t ≤ cF r ^ 2 * (h : ℝ) ^ p * (n : ℝ) := by
    have hm : ((n - r : ℕ) : ℝ) ≤ n := by exact_mod_cast Nat.sub_le n r
    calc
      _ ≤ cF r ^ 2 * (n - r : ℕ) * (h : ℝ) ^ p := hy.2.2
      _ = (cF r ^ 2 * (h : ℝ) ^ p) * (n - r : ℕ) := by ring
      _ ≤ _ := mul_le_mul_of_nonneg_left hm (by positivity)
  have hpFine : Cfine r fl / (c ^ 2 * M ^ p) = 4 * (K / c ^ 2) := by
    have hrp : 2 * r + 1 = p + 2 := by dsimp [p, r]; omega
    have hrat : (256 / fl ^ 2) / M = D⁻¹ := by
      dsimp [D]
      field_simp
    have hratPow : (256 / fl ^ 2) ^ p / M ^ p = (D ^ p)⁻¹ := by
      rw [← div_pow, hrat, inv_pow]
    calc
      _ = 4 * (2 ^ p * cF r ^ 2 * ((256 / fl ^ 2) ^ p / M ^ p) / c ^ 2) := by
        unfold Cfine
        rw [hrp, pow_add]
        ring
      _ = _ := by rw [hratPow]; dsimp [K]; ring
  refine ⟨?_, ?_, ?_⟩
  · intro j
    have hxx : x ≤ x ^ p := by
      obtain ⟨q, hq⟩ := Nat.exists_eq_succ_of_ne_zero (by omega : p ≠ 0)
      rw [hq, pow_succ]
      exact le_mul_of_one_le_left hx.le (one_le_pow₀ hx')
    calc
      _ = 4 * ((t j) ^ 2 / lam ^ 2) := by ring
      _ ≤ 4 * ((cF r ^ 2 * (h : ℝ) ^ p / lam ^ 2) * Real.log (2 * n)) := by
        rw [← mul_div_right_comm]
        gcongr
        exact hSupSq j
      _ ≤ 4 * ((K / c ^ 2 / x ^ p) * (d * x)) := by
        gcongr
      _ ≤ 4 * (K / c ^ 2) * d := by
        have hh := mul_le_mul_of_nonneg_left hxx (show 0 ≤ d by exact hd)
        rw [show 4 * (K / c ^ 2 / x ^ p * (d * x)) =
          (4 * (K / c ^ 2)) * ((d * x) / x ^ p) by ring]
        exact mul_le_mul_of_nonneg_left ((div_le_iff₀ hxp).mpr hh) (by positivity)
      _ ≤ _ := hsmall
  · calc
      _ ≤ 8 * ((cF r ^ 2 * (h : ℝ) ^ p / lam ^ 2) * (n : ℝ)) := by
        rw [← mul_div_right_comm, mul_div_assoc]
        gcongr
      _ ≤ 8 * ((K / c ^ 2 / x ^ p) * (n : ℝ)) := by gcongr
      _ = _ := by rw [hpFine, ← hxn]; field_simp; ring
  · let u := ustar r n θs
    let H := cF r * (h : ℝ) ^ ((r : ℝ) - 1 / 2) * Real.sqrt (Real.log (2 * n))
    have hH : 0 ≤ H := by dsimp [H]; positivity
    have hu : l1norm u ≤ Vb / (n : ℝ) ^ k :=
      (le_div_iff₀ (by positivity : 0 < (n : ℝ) ^ k)).mpr (by
        simpa only [TV, u, ustar, r, mul_comm] using hTV)
    have hu₀ : 0 ≤ l1norm u := Finset.sum_nonneg fun _ _ => abs_nonneg _
    have hdot : |dot t u| ≤ H * (Vb / (n : ℝ) ^ k) := by
      calc
        _ ≤ ∑ j, |t j * u j| := Finset.abs_sum_le_sum_abs ..
        _ ≤ H * l1norm u := by
          simp only [abs_mul, l1norm, Finset.mul_sum]
          exact Finset.sum_le_sum fun j _ => mul_le_mul_of_nonneg_right (hy.2.1 j) (abs_nonneg _)
        _ ≤ _ := mul_le_mul_of_nonneg_left hu hH
    have hsquare : H ^ 2 = cF r ^ 2 * (h : ℝ) ^ p * Real.log (2 * n) := by
      have he : ((h : ℝ) ^ ((r : ℝ) - 1 / 2)) ^ 2 = (h : ℝ) ^ p := by
        rw [← Real.rpow_mul_natCast (by positivity), hp, ← Real.rpow_natCast]
        push_cast
        congr 1
        simp only [r, Nat.cast_add, Nat.cast_one]
        ring
      dsimp [H]
      rw [mul_pow, mul_pow, he, Real.sq_sqrt hlogs]
    rw [← sq_le_sq₀ (abs_nonneg _) hx.le]
    calc
      _ ≤ (H * (Vb / (n : ℝ) ^ k)) ^ 2 := pow_le_pow_left₀ (abs_nonneg _) hdot _
      _ = (cF r ^ 2 * (h : ℝ) ^ p) * (Real.log (2 * n) * (Vb / (n : ℝ) ^ k) ^ 2) := by
        rw [mul_pow, hsquare]
        ring
      _ ≤ (K * (n : ℝ) ^ p / x ^ p) * (Real.log (2 * n) * (Vb / (n : ℝ) ^ k) ^ 2) :=
        mul_le_mul_of_nonneg_right hpow (by positivity)
      _ = (K * Vb ^ 2) * (x * Real.log (2 * n)) := by
        have he : (n : ℝ) ^ p = ((n : ℝ) ^ k) ^ 2 * n := by
          rw [hp, pow_succ, ← pow_mul, Nat.mul_comm 2 k]
        rw [he, div_pow]
        calc
          _ = (K * Vb ^ 2) * ((n / x ^ p) * Real.log (2 * n)) := by field_simp
          _ = _ := by rw [show (n : ℝ) / x ^ p = x from (div_eq_iff hxp.ne').mpr (by
            rw [mul_comm]; exact hxn.symm)]
      _ ≤ ((K * Vb ^ 2) * d) * x ^ 2 := by
        rw [show ((K * Vb ^ 2) * d) * x ^ 2 = (K * Vb ^ 2) * (x * (d * x)) by ring]
        gcongr
      _ ≤ _ := by nlinarith only [mul_le_mul_of_nonneg_right hshift (sq_nonneg x)]

private theorem shell_average {k n J : ℕ} {L fl fu Vb a τ lam B : ℝ}
    {μ : Fin n → Measure ℝ} {θs : Fin n → ℝ}
    (hn : k + 1 < n) (hL : 0 < L) (hfl : 0 < fl) (ha : 0 < a) (hlam : 0 < lam)
    (hτ : 0 < τ ∧ τ < 1) (hdata : DataHyp k n τ μ θs L fl fu Vb)
    (hscore : ∀ y ∈ OmegaZeta (k + 1) n J τ θs,
      (∫⁻ θ in Eshell k n L fl fu a θs,
          ENNReal.ofReal (Real.exp (2 * dot (θ - θs) (score τ (y - θs)))) ∂nu (k + 1) n lam)
        ≤ Vr (k + 1) * ENNReal.ofReal ((2 * a * n * epsSq (k + 1) n) ^ ((k + 1 : ℝ) / 2)) *
          ENNReal.ofReal (Real.exp B)) :
    (∫⁻ y, Set.indicator (OmegaZeta (k + 1) n J τ θs)
          (fun y => Nmass (k + 1) τ lam y θs (Eshell k n L fl fu a θs)) y ∂(Measure.pi μ))
      ≤ Vr (k + 1) * ENNReal.ofReal ((2 * a * n * epsSq (k + 1) n) ^ ((k + 1 : ℝ) / 2)) *
        ENNReal.ofReal (Real.exp ((B - fl / 2 * a * n * epsSq (k + 1) n) / 2)) := by
  let r := k + 1
  let E := Eshell k n L fl fu a θs
  let Z := OmegaZeta r n J τ θs
  let P := Measure.pi μ
  let ν := nu r n lam
  let PZ := P.restrict Z
  let νE := ν.restrict E
  let D := -(fl / 2 * a * (n : ℝ) * epsSq r n)
  let W := Vr r * ENNReal.ofReal ((2 * a * n * epsSq r n) ^ ((k + 1 : ℝ) / 2))
  let S (p : (Fin n → ℝ) × (Fin n → ℝ)) := dot (p.2 - θs) (score τ (p.1 - θs))
  let R (p : (Fin n → ℝ) × (Fin n → ℝ)) := ∑ i, remK (p.2 i - θs i) (p.1 i - θs i)
  let f p := ENNReal.ofReal (Real.exp (S p))
  let g p := ENNReal.ofReal (Real.exp (-R p))
  have hμ (i : Fin n) : IsProbabilityMeasure (μ i) := hdata.prob i
  have : IsProbabilityMeasure (laplace lam) := laplace_probability hlam
  have : SFinite ν := by dsimp [ν, nu, Qlam]; infer_instance
  have hZ : MeasurableSet Z := measurableSet_shell_score ..
  have hE : MeasurableSet E := measurableSet_shell ..
  have hf : Measurable f := by
    apply (Real.measurable_exp.comp _).ennreal_ofReal
    exact (continuous_dot n).measurable.comp
      ((measurable_snd.sub_const _).prodMk ((measurable_score_vector τ θs).comp measurable_fst))
  have hg : Measurable g := by
    apply (Real.measurable_exp.comp _).ennreal_ofReal
    apply Measurable.neg
    apply Finset.measurable_sum
    intro i _
    change Measurable (fun p : (Fin n → ℝ) × (Fin n → ℝ) =>
      remK (p.2 i - θs i) (p.1 i - θs i))
    have h₁ : Measurable (fun p : (Fin n → ℝ) × (Fin n → ℝ) => p.2 i - θs i) :=
      ((measurable_pi_apply i).comp measurable_snd).sub_const _
    have h₂ : Measurable (fun p : (Fin n → ℝ) × (Fin n → ℝ) => p.1 i - θs i) :=
      ((measurable_pi_apply i).comp measurable_fst).sub_const _
    exact (measurable_remK_pair τ).comp (h₁.prodMk h₂)
  have hfg (p : (Fin n → ℝ) × (Fin n → ℝ)) :
      f p * g p = ENNReal.ofReal (Real.exp (-lossHat τ (p.1 - θs) (p.2 - θs))) := by
    have h (i : Fin n) := (knight τ (p.2 i - θs i) (p.1 i - θs i)).1
    dsimp [f, g, S, R]
    rw [← ENNReal.ofReal_mul (Real.exp_nonneg _), ← Real.exp_add]
    congr 2
    unfold lossHat dot score
    change _ = -(∑ i, ell τ (p.2 i - θs i) (p.1 i - θs i))
    simp_rw [h, Finset.sum_add_distrib, neg_mul, Finset.sum_neg_distrib]
    simp [scoreZ, add_comm]
  have hf₂ (p) : f p ^ (2 : ℝ) = ENNReal.ofReal (Real.exp (2 * S p)) := by
    rw [ENNReal.rpow_two]
    dsimp [f]
    rw [← ENNReal.ofReal_pow (Real.exp_nonneg _), ← Real.exp_nat_mul]
    norm_num
  have hg₂ (p) : g p ^ (2 : ℝ) = ENNReal.ofReal (Real.exp (-2 * R p)) := by
    rw [ENNReal.rpow_two]
    dsimp [g]
    rw [← ENNReal.ofReal_pow (Real.exp_nonneg _), ← Real.exp_nat_mul]
    congr 2
    push_cast
    ring
  have hfirst : (∫⁻ p, f p ^ (2 : ℝ) ∂PZ.prod νE) ≤ W * ENNReal.ofReal (Real.exp B) := by
    rw [lintegral_prod _ (hf.pow_const _).aemeasurable]
    simp_rw [hf₂]
    apply (setLIntegral_mono' hZ hscore).trans
    rw [lintegral_const, Measure.restrict_apply_univ]
    simpa using mul_le_mul_right (prob_le_one (μ := P) (s := Z)) (W * ENNReal.ofReal (Real.exp B))
  have hmass : ν E ≤ W := by
    let x := 2 * a * (n : ℝ) * epsSq r n
    have hx : 0 ≤ x := by dsimp [x, epsSq]; positivity
    calc
      _ ≤ ν {θ | l2norm (θ - θs) ≤ Real.sqrt x} := by
        apply measure_mono
        intro θ hθ
        exact Real.sqrt_le_sqrt hθ.2.2
      _ ≤ Vr r * ENNReal.ofReal ((Real.sqrt x) ^ r) :=
        nu_ball_le r n (by dsimp [r]; omega) hn lam hlam θs _ (Real.sqrt_nonneg _)
      _ = W := by
        have hr : (r : ℝ) = k + 1 := by simp [r]
        dsimp [W]
        rw [← hr, Real.sqrt_eq_rpow, ← Real.rpow_mul_natCast hx]
        rw [show (1 / 2 : ℝ) * r = (r : ℝ) / 2 by ring]
  have hsecond : (∫⁻ p, g p ^ (2 : ℝ) ∂PZ.prod νE) ≤ W * ENNReal.ofReal (Real.exp D) := by
    rw [lintegral_prod_symm _ (hg.pow_const _).aemeasurable]
    simp_rw [hg₂]
    calc
      _ ≤ ∫⁻ θ in E, ENNReal.ofReal (Real.exp D) ∂ν := by
        apply setLIntegral_mono' hE
        intro θ hθ
        have hδ (i : Fin n) : |(θ - θs) i| ≤ min L (3 * fl / (4 * fu)) :=
          (hθ.1 i).trans (min_le_right _ _)
        apply (setLIntegral_le_lintegral Z _).trans
        apply (lintegral_exp_remK_le hdata hτ hL hfl hδ).trans
        apply ENNReal.ofReal_le_ofReal
        apply Real.exp_le_exp.mpr
        exact neg_le_neg (by
          linarith only [mul_le_mul_of_nonneg_left hθ.2.1.le (show 0 ≤ fl / 2 by positivity)])
      _ ≤ _ := by
        rw [lintegral_const, Measure.restrict_apply_univ, mul_comm]
        exact mul_le_mul_left hmass _
  calc
    _ = ∫⁻ p, f p * g p ∂PZ.prod νE := by
      have hfgm : Measurable (fun p => f p * g p) := hf.mul hg
      rw [lintegral_indicator hZ, lintegral_prod _ hfgm.aemeasurable]
      simp_rw [hfg]
      rfl
    _ ≤ (∫⁻ p, f p ^ (2 : ℝ) ∂PZ.prod νE) ^ (1 / 2 : ℝ) *
        (∫⁻ p, g p ^ (2 : ℝ) ∂PZ.prod νE) ^ (1 / 2 : ℝ) := by
      simpa only [Pi.mul_apply, one_div] using ENNReal.lintegral_mul_le_Lp_mul_Lq (PZ.prod νE)
        Real.HolderConjugate.two_two hf.aemeasurable hg.aemeasurable
    _ ≤ (W * ENNReal.ofReal (Real.exp B)) ^ (1 / 2 : ℝ) *
        (W * ENNReal.ofReal (Real.exp D)) ^ (1 / 2 : ℝ) := by gcongr
    _ = _ := by
      let s : ℝ := 1 / 2
      change (W * ENNReal.ofReal (Real.exp B)) ^ s *
        (W * ENNReal.ofReal (Real.exp D)) ^ s = W * ENNReal.ofReal (Real.exp _)
      rw [ENNReal.mul_rpow_of_nonneg W (ENNReal.ofReal (Real.exp B)) (by positivity : 0 ≤ s),
        ENNReal.mul_rpow_of_nonneg W (ENNReal.ofReal (Real.exp D)) (by positivity : 0 ≤ s)]
      calc
        _ = (W ^ s * W ^ s) *
            (ENNReal.ofReal (Real.exp B) ^ s * ENNReal.ofReal (Real.exp D) ^ s) := by ac_rfl
        _ = _ := by
          rw [← ENNReal.rpow_add_of_nonneg s s (by positivity) (by positivity),
            show s + s = 1 by norm_num [s], ENNReal.rpow_one]
          rw [ENNReal.ofReal_rpow_of_pos (Real.exp_pos B),
            ENNReal.ofReal_rpow_of_pos (Real.exp_pos D), ← Real.exp_mul, ← Real.exp_mul]
          rw [← ENNReal.ofReal_mul (Real.exp_nonneg _), ← Real.exp_add]
          rw [show B * s + D * s = (B - fl / 2 * a * n * epsSq r n) / 2 by
            dsimp [D, s]
            ring]

/-- Proposition `pf:prop:shell`: for `M > 0` there is `n₃` such that for `n ≥ n₃`:
`1 ≤ J ≤ m`, `J ≥ (f̲²/256) M n ε_n²`, and for every `a ≥ M`
`E[N(E_a) 1_{Ω_ζ(J)}] ≤ V_r (2a n ε_n²)^{r/2} exp{−(f̲/8) a n ε_n² + (1 + C_fine/(c² M^{2r−1})) n ε_n²}`.
(The paper's `n₃` depends on `(M, c, r, f̲, V̄)`; here it may depend on all of
`(M, c, k, L, f̲, f̄, V̄)`, which suffices for Theorem `thm:main`.) -/
theorem shells (k : ℕ) (hk : 1 ≤ k) (c L fl fu Vb : ℝ) (hc : 0 < c) (hL : 0 < L) (hfl : 0 < fl)
    (M : ℝ) (hM : 0 < M) :
    ∃ n₃ : ℕ, k + 1 < n₃ ∧ ∀ n, n₃ ≤ n →
      1 ≤ Jshell k n fl M ∧ Jshell k n fl M ≤ n - (k + 1) ∧
      fl ^ 2 / 256 * M * n * epsSq (k + 1) n ≤ Jshell k n fl M ∧
      ∀ a, M ≤ a → ∀ τ : ℝ, 0 < τ → τ < 1 →
        ∀ (μ : Fin n → Measure ℝ) (θs : Fin n → ℝ), DataHyp k n τ μ θs L fl fu Vb →
          ∫⁻ y, Set.indicator (OmegaZeta (k + 1) n (Jshell k n fl M) τ θs)
              (fun y => Nmass (k + 1) τ (lamSeq c k n) y θs (Eshell k n L fl fu a θs)) y
              ∂(Measure.pi μ)
            ≤ Vr (k + 1) * ENNReal.ofReal ((2 * a * n * epsSq (k + 1) n) ^ ((k + 1 : ℝ) / 2)) *
              ENNReal.ofReal (Real.exp (-(fl / 8 * a * n * epsSq (k + 1) n) +
                (1 + Cfine (k + 1) fl / (c ^ 2 * M ^ (2 * (k + 1) - 1))) * n * epsSq (k + 1) n)) := by
  let r := k + 1
  let p := 2 * r - 1
  let D := fl ^ 2 / 256 * M
  let K := 2 ^ p * cF r ^ 2 / D ^ p
  let d := 1 / (8 * (1 + K / c ^ 2 + K * Vb ^ 2))
  have hD : 0 < D := by dsimp [D]; positivity
  have hK : 0 ≤ K := by dsimp [K]; positivity
  have hd : 0 < d := by dsimp [d]; positivity
  have hd₁ : 4 * (K / c ^ 2) * d ≤ 1 / 2 := by
    dsimp [d]
    rw [mul_one_div, div_le_iff₀ (by positivity)]
    linarith [show 0 ≤ K * Vb ^ 2 by positivity]
  have hd₂ : (K * Vb ^ 2) * d ≤ 1 := by
    dsimp [d]
    rw [mul_one_div, div_le_iff₀ (by positivity)]
    linarith [show 0 ≤ K / c ^ 2 by positivity, show 0 ≤ K * Vb ^ 2 by positivity]
  obtain ⟨N, hN, hsizes⟩ := shell_size k hk fl M d hfl hM hd
  refine ⟨N, hN, fun n hn => ?_⟩
  have hn' : k + 1 < n := hN.trans_le hn
  obtain ⟨hJ, hJm, hJlow, hJhigh, hlog⟩ := hsizes n hn
  refine ⟨hJ, hJm, hJlow, fun a ha τ hτ₀ hτ₁ μ θs hdata => ?_⟩
  let J := Jshell k n fl M
  let lam := lamSeq c k n
  let x := (n : ℝ) * epsSq r n
  let penalty := Cfine r fl / (c ^ 2 * M ^ p)
  let B := fl / 4 * a * n * epsSq r n + 2 * (1 + penalty) * x
  have hpos : 0 < (n : ℝ) := by exact_mod_cast (show 0 < n by omega)
  have heps : 0 < epsSq r n := Real.rpow_pos_of_pos hpos _
  have hx : 0 < x := mul_pos hpos heps
  have hlam : 0 < lam := mul_pos hc (Real.rpow_pos_of_pos hpos _)
  have heq : (B - fl / 2 * a * n * epsSq r n) / 2 =
      -(fl / 8 * a * n * epsSq r n) + (1 + penalty) * n * epsSq r n := by
    dsimp [B, x]
    ring
  rw [← heq]
  apply shell_average hn' hL hfl (hM.trans_le ha) hlam ⟨hτ₀, hτ₁⟩ hdata
  intro y hy
  let ζ := score τ (y - θs)
  let t := tScore r n J ζ
  obtain ⟨ht, hl2, hshift⟩ := shell_score_sizes hk hn' hJ hJm hc hfl hM hy hdata.signal
    hJlow hlog hd.le hd₁ hd₂
  have hPJ : l2sq (PJ r n J ζ) ≤ fl ^ 2 / 128 * a * n * epsSq r n := by
    have hcast : ((J + r : ℕ) : ℝ) = (J : ℝ) + (r : ℝ) := Nat.cast_add _ _
    have hPJ' := hy.1
    rw [← hcast] at hPJ'
    apply hPJ'.trans (hJhigh.trans ?_)
    gcongr
  apply (shell_score_integral hn' hlam (hM.trans_le ha) θs ζ hPJ hfl ht).trans
  apply mul_le_mul_right
  apply ENNReal.ofReal_le_ofReal
  apply Real.exp_le_exp.mpr
  have hdot : -(dot t (ustar r n θs)) ≤ x := (neg_le_abs _).trans hshift
  dsimp [B]
  linarith only [hdot, hl2]

end BQTF
