import BQTF.Shells
import BQTF.Asym.Rates

/-! Assembly of Theorem `thm:main` at scale one. -/

open MeasureTheory ProbabilityTheory
open scoped ENNReal

noncomputable section

namespace BQTF

private theorem measurable_eval {n : ℕ} (i : Fin n) :
    Measurable (fun v : Fin n → ℝ => v i) :=
  measurable_pi_apply i

private theorem measurable_checkLoss (τ : ℝ) : Measurable (checkLoss τ) := by
  have h : Measurable (fun u : ℝ => if u < 0 then (1 : ℝ) else 0) :=
    measurable_const.piecewise measurableSet_Iio measurable_const
  exact measurable_id.mul (measurable_const.sub h)

private theorem measurable_posterior_apply (k n : ℕ) (τ σ lam : ℝ)
    {B : Set (Fin n → ℝ)} (hB : MeasurableSet B) :
    Measurable (fun y => posterior τ σ lam k n y B) := by
  have hw : Measurable (fun p : (Fin n → ℝ) × (Fin n → ℝ) =>
      postWeight τ σ lam k n p.1 p.2) := by
    unfold postWeight l1norm
    apply Measurable.ennreal_ofReal
    apply Real.measurable_exp.comp
    refine ((Finset.measurable_sum _ fun i _ => ?_).neg.div_const σ).sub
      (measurable_const.mul (Finset.measurable_sum _ fun i _ => ?_))
    · exact (measurable_checkLoss τ).comp
        (((measurable_eval i).comp measurable_fst).sub ((measurable_eval i).comp measurable_snd))
    · unfold diffOp
      exact (Finset.measurable_sum _ fun _ _ =>
        measurable_const.mul ((measurable_eval _).comp measurable_snd)).abs
  simp only [posterior, Measure.smul_apply, smul_eq_mul, withDensity_apply _ hB]
  exact (hw.lintegral_prod_right' (ν := volume)).inv.mul
    (hw.lintegral_prod_right' (ν := volume.restrict B))

private theorem measurableSet_farSet {n : ℕ} (k : ℕ) (θs : Fin n → ℝ) (M : ℝ) :
    MeasurableSet (farSet k θs M) := by
  apply measurableSet_lt measurable_const
  have h (i : Fin n) : Measurable (fun θ : Fin n → ℝ => θ i - θs i) :=
    (measurable_eval i).sub_const _
  exact (Finset.measurable_sum _ fun i _ => (h i).abs.min ((h i).pow_const 2)).div_const _

private theorem measurableSet_Eshell (k n : ℕ) (L fl fu a : ℝ) (θs : Fin n → ℝ) :
    MeasurableSet (Eshell k n L fl fu a θs) := by
  have h (i : Fin n) : Measurable (fun θ : Fin n → ℝ => θ i - θs i) :=
    (measurable_eval i).sub_const _
  have hs : Measurable (fun θ : Fin n → ℝ => l2sq (θ - θs)) :=
    Finset.measurable_sum _ fun i _ => (h i).pow_const 2
  unfold Eshell
  rw [Set.ofPred_and, Set.ofPred_forall, Set.ofPred_and]
  exact (MeasurableSet.iInter fun i => measurableSet_le (h i).abs measurable_const).inter
    ((measurableSet_lt measurable_const hs).inter (measurableSet_le hs measurable_const))

private theorem farSet_subset_shells {k n : ℕ} {L fl fu M : ℝ} {c : ℝ} (θs : Fin n → ℝ)
    (hn : 0 < n) (hM : 0 < M)
    (hlocal : ∀ δ ∈ Kn k n c, ∀ i, |δ i| ≤ s0 L fl fu) :
    farSet k θs M ⊆ {θ | θ - θs ∉ Kn k n c} ∪
      ⋃ j : ℕ, Eshell k n L fl fu ((2 : ℝ) ^ j * M) θs := by
  intro θ hθ
  by_cases hK : θ - θs ∈ Kn k n c
  · right
    have hn' : 0 < (n : ℝ) := by exact_mod_cast hn
    have heps : 0 < epsSq (k + 1) n := Real.rpow_pos_of_pos hn' _
    have hsum : lossΔ (θ - θs) ≤ l2sq (θ - θs) / n := by
      exact div_le_div_of_nonneg_right (Finset.sum_le_sum fun _ _ => min_le_right _ _) hn'.le
    have hfar : M * epsSq (k + 1) n < l2sq (θ - θs) / n := by
      rw [← Asym.rate_eq_epsSq]
      exact lt_of_lt_of_le hθ hsum
    let t := M * (n : ℝ) * epsSq (k + 1) n
    have ht : 0 < t := by dsimp [t]; positivity
    have htlt : t < l2sq (θ - θs) := by
      simpa only [t, mul_right_comm M] using (lt_div_iff₀ hn').mp hfar
    obtain ⟨j, hj⟩ := pow_unbounded_of_one_lt (l2sq (θ - θs) / t) (show (1 : ℝ) < 2 by norm_num)
    have hex : ∃ j : ℕ, l2sq (θ - θs) ≤ (2 : ℝ) ^ j * t :=
      ⟨j, (div_lt_iff₀ ht).mp hj |>.le⟩
    have hfind := Nat.find_spec hex
    have hpos : Nat.find hex ≠ 0 := by
      intro hz
      rw [hz, pow_zero, one_mul] at hfind
      exact (not_le_of_gt htlt) hfind
    obtain ⟨j, hj⟩ := Nat.exists_eq_succ_of_ne_zero hpos
    have hlo : (2 : ℝ) ^ j * t < l2sq (θ - θs) :=
      lt_of_not_ge (Nat.find_min hex (by omega : j < Nat.find hex))
    rw [hj, pow_succ] at hfind
    apply Set.mem_iUnion.mpr
    refine ⟨j, hlocal _ hK, ?_, ?_⟩
    · convert hlo using 1
      dsimp [t]
      ring
    · convert hfind using 1
      dsimp [t]
      ring
  · exact Or.inl hK

/-- Divide the expected shell numerator by the lower bound for the evidence. -/
private theorem shell_ratio_bound {k n : ℕ} {c τ L fl fu M CE a : ℝ}
    {μ : Fin n → Measure ℝ} {θs : Fin n → ℝ} {good : Set (Fin n → ℝ)}
    (hn : k + 1 < n) (hτ : 0 < τ ∧ τ < 1) (hlam : 0 < lamSeq c k n)
    (hgood : MeasurableSet good)
    (hE : good ⊆ OmegaE k n τ (lamSeq c k n) θs CE)
    (hZ : good ⊆ OmegaZeta (k + 1) n (Jshell k n fl M) τ θs)
    (ha : 0 < a)
    (hnum :
      ∫⁻ y, Set.indicator (OmegaZeta (k + 1) n (Jshell k n fl M) τ θs)
          (fun y => Nmass (k + 1) τ (lamSeq c k n) y θs (Eshell k n L fl fu a θs)) y
          ∂(Measure.pi μ)
        ≤ Vr (k + 1) * ENNReal.ofReal ((2 * a * n * epsSq (k + 1) n) ^ ((k + 1 : ℝ) / 2)) *
          ENNReal.ofReal (Real.exp (-(fl / 8 * a * n * epsSq (k + 1) n) +
            (1 + Cfine (k + 1) fl / (c ^ 2 * M ^ (2 * (k + 1) - 1))) * n * epsSq (k + 1) n))) :
    ∫⁻ y in good, posterior τ 1 (lamSeq c k n) k n y (Eshell k n L fl fu a θs) ∂(Measure.pi μ)
      ≤ ENNReal.ofReal ((8 * a) ^ (((k + 1 : ℕ) : ℝ) / 2) *
        Real.exp (-(fl / 8 * a * n * epsSq (k + 1) n) +
          (CE + 1 + Cfine (k + 1) fl / (c ^ 2 * M ^ (2 * (k + 1) - 1))) * n * epsSq (k + 1) n)) := by
  let r := k + 1
  let D := denomBound k n CE
  let A := -(fl / 8 * a * n * epsSq r n) +
    (1 + Cfine r fl / (c ^ 2 * M ^ (2 * r - 1))) * n * epsSq r n
  let Z := OmegaZeta r n (Jshell k n fl M) τ θs
  let f := fun y => Nmass r τ (lamSeq c k n) y θs (Eshell k n L fl fu a θs)
  have hn' : 0 < (n : ℝ) := by exact_mod_cast (show 0 < n by omega)
  have heps : 0 < epsSq r n := Real.rpow_pos_of_pos hn' _
  have hV0 : Vr r ≠ 0 := (Metric.measure_ball_pos _ _ one_pos).ne'
  have hVt : Vr r ≠ ∞ := measure_ball_lt_top.ne
  have hp : 0 < (Real.sqrt n * Real.sqrt (epsSq r n) / 2) ^ r := by positivity
  have hD : D ≠ 0 := by
    unfold D denomBound
    exact mul_ne_zero (mul_ne_zero hV0 (ENNReal.ofReal_pos.mpr hp).ne')
      (ENNReal.ofReal_pos.mpr (Real.exp_pos _)).ne'
  calc
    _ = ∫⁻ y, good.indicator
        (fun y => posterior τ 1 (lamSeq c k n) k n y (Eshell k n L fl fu a θs)) y
          ∂(Measure.pi μ) := (lintegral_indicator hgood _).symm
    _ ≤ ∫⁻ y, D⁻¹ * Z.indicator f y ∂(Measure.pi μ) := by
      apply lintegral_mono
      intro y
      change good.indicator _ y ≤ D⁻¹ * Z.indicator f y
      by_cases hy : y ∈ good
      · have hz : y ∈ Z := hZ hy
        rw [Set.indicator_of_mem hy, Set.indicator_of_mem hz]
        rw [(posterior_eq_ratio k n hn τ _ hτ hlam y θs).2.2 _ (measurableSet_Eshell ..)]
        rw [div_eq_mul_inv, mul_comm D⁻¹]
        exact mul_le_mul_right (ENNReal.inv_le_inv.mpr (hE hy)) _
      · rw [Set.indicator_of_notMem hy]
        exact bot_le
    _ ≤ D⁻¹ * (Vr r * ENNReal.ofReal ((2 * a * n * epsSq r n) ^ ((r : ℝ) / 2)) *
        ENNReal.ofReal (Real.exp A)) := by
      rw [lintegral_const_mul' _ _ (ENNReal.inv_ne_top.mpr hD)]
      apply mul_le_mul_right
      simpa only [r, Nat.cast_add, Nat.cast_one, A, Z, f] using hnum
    _ = _ := by
      have hbase : (2 * a * n * epsSq r n) =
          8 * a * (Real.sqrt n * Real.sqrt (epsSq r n) / 2) ^ 2 := by
        rw [div_pow, mul_pow, Real.sq_sqrt hn'.le, Real.sq_sqrt heps.le]
        ring
      have hpow : (2 * a * n * epsSq r n) ^ ((r : ℝ) / 2) =
          (8 * a) ^ ((r : ℝ) / 2) * (Real.sqrt n * Real.sqrt (epsSq r n) / 2) ^ r := by
        have hsq (z : ℝ) (hz : 0 ≤ z) :
            (z ^ 2) ^ ((r : ℝ) / 2) = z ^ r := by
          rw [← Real.rpow_natCast_mul hz 2,
            show (↑(2 : ℕ) : ℝ) * ((r : ℝ) / 2) = r by push_cast; ring, Real.rpow_natCast]
        rw [hbase, Real.mul_rpow (by positivity) (by positivity), hsq _ (by positivity)]
      let B := -(fl / 8 * a * n * epsSq r n) +
        (CE + 1 + Cfine r fl / (c ^ 2 * M ^ (2 * r - 1))) * n * epsSq r n
      have he : A = -(CE * n * epsSq r n) + B := by dsimp [A, B]; ring
      have hDt : D ≠ ∞ := by
        unfold D denomBound
        exact ENNReal.mul_ne_top (ENNReal.mul_ne_top hVt ENNReal.ofReal_ne_top) ENNReal.ofReal_ne_top
      let W := ENNReal.ofReal ((8 * a) ^ ((r : ℝ) / 2) * Real.exp B)
      change _ = W
      calc
        _ = D⁻¹ * (D * W) := by
          congr 1
          unfold D denomBound W
          rw [hpow, he, Real.exp_add]
          simp only [ENNReal.ofReal_mul (Real.exp_nonneg _),
            ENNReal.ofReal_mul (show 0 ≤ (8 * a) ^ ((r : ℝ) / 2) by positivity)]
          ac_rfl
        _ = W := ENNReal.inv_mul_cancel_left hD hDt

/-- The residual shell factors are bounded by a geometric sequence with ratio one half. -/
private theorem dyadic_decay {r : ℕ} (hr : 2 ≤ r) {M X : ℝ} (hM : 0 < M)
    (hX : (r : ℝ) ≤ X) (j : ℕ) :
    (8 * ((2 : ℝ) ^ j * M)) ^ ((r : ℝ) / 2) * Real.exp (-((2 : ℝ) ^ j * X))
      ≤ ((8 * M) ^ ((r : ℝ) / 2) * Real.exp (-X)) * (1 / 2 : ℝ) ^ j := by
  have hr' : (2 : ℝ) ≤ r := by exact_mod_cast hr
  have hj : (j : ℝ) + 1 ≤ (2 : ℝ) ^ j := by
    exact_mod_cast (Nat.lt_two_pow_self (n := j))
  have htwo : (2 : ℝ) ≤ Real.exp 1 := by linarith [Real.add_one_le_exp 1]
  have hpow : ((2 : ℝ) ^ j) ^ ((r : ℝ) / 2) ≤ Real.exp ((j : ℝ) * (r / 2)) := by
    rw [← Real.rpow_natCast_mul (by norm_num) j]
    have h := Real.rpow_le_rpow (by norm_num : (0 : ℝ) ≤ 2) htwo
      (show 0 ≤ (j : ℝ) * (r / 2) by positivity)
    simpa [Real.exp_one_rpow] using h
  have hhalf : Real.exp (-1) ≤ (1 / 2 : ℝ) := by
    rw [Real.exp_neg, one_div]
    exact inv_anti₀ (by norm_num) htwo
  have hexp : Real.exp ((j : ℝ) * (r / 2)) * Real.exp (-((2 : ℝ) ^ j * X))
      ≤ Real.exp (-X) * (1 / 2 : ℝ) ^ j := by
    rw [← Real.exp_add]
    calc
      _ ≤ Real.exp (-X + -(j : ℝ)) := by
        apply Real.exp_le_exp.mpr
        nlinarith [mul_nonneg (show 0 ≤ (2 : ℝ) ^ j - ((j : ℝ) + 1) by linarith)
            (show 0 ≤ X by linarith),
          mul_nonneg (show 0 ≤ (j : ℝ) by positivity) (show 0 ≤ X - r / 2 - 1 by linarith)]
      _ = Real.exp (-X) * Real.exp (-1) ^ j := by
        rw [Real.exp_add, ← Real.exp_nat_mul]
        ring_nf
      _ ≤ _ := by gcongr
  rw [show 8 * ((2 : ℝ) ^ j * M) = (8 * M) * (2 : ℝ) ^ j by ring,
    Real.mul_rpow (by positivity) (by positivity), mul_assoc, mul_assoc]
  exact mul_le_mul_of_nonneg_left
    ((mul_le_mul_of_nonneg_right hpow (Real.exp_nonneg _)).trans hexp) (by positivity)

private theorem score_constant_bound {r n J : ℕ} {s x : ℝ}
    (hr : 0 < r) (hs : 0 < s) (hx : 0 < x) (hxn : x ≤ n) (hJ : s * x ≤ J) :
    4 / (9 * (J + (r : ℝ))) + 1 / (2 * n) + 8 * (r : ℝ) / (3 * J)
      ≤ ((4 / 9 + 8 * (r : ℝ) / 3) / s + 1 / 2) * x⁻¹ := by
  have hJ' : 0 < (J : ℝ) := (mul_pos hs hx).trans_le hJ
  have h₁ : 4 / (9 * (J + (r : ℝ))) ≤ 4 / (9 * (s * x)) := by
    apply div_le_div_of_nonneg_left (by norm_num) (by positivity)
    have : (0 : ℝ) ≤ r := by positivity
    linarith
  have h₂ : (1 : ℝ) / (2 * n) ≤ 1 / (2 * x) :=
    div_le_div_of_nonneg_left (by norm_num) (by positivity) (by linarith)
  have h₃ : 8 * (r : ℝ) / (3 * J) ≤ 8 * (r : ℝ) / (3 * (s * x)) :=
    div_le_div_of_nonneg_left (by positivity) (by positivity) (by linarith)
  calc
    _ ≤ 4 / (9 * (s * x)) + 1 / (2 * x) + 8 * (r : ℝ) / (3 * (s * x)) :=
      add_le_add (add_le_add h₁ h₂) h₃
    _ = _ := by field_simp; ring

set_option maxHeartbeats 600000 in
/-- **Theorem `thm:main`** (σ = 1). -/
theorem main_theorem : MainStatement := by
  intro k hk c L fl fu Vb hc hL hfl
  obtain ⟨CE, n₁, hCE, hn₁, hdenom⟩ := denominator k hk c L fl fu Vb hc hL hfl
  obtain ⟨n₂, _, hloc⟩ := localization k hk c L fl fu Vb hc hL hfl CE
  let r := k + 1
  let A := max 0 (Cfine r fl / c ^ 2)
  -- Since M ≥ 1, replacing M^(2r-1) by 1 gives a sufficient choice of M.
  let M := 1 + 32 / fl * (CE + 1 + A)
  have hA : 0 ≤ A := le_max_left _ _
  have hM1 : 1 ≤ M := by
    dsimp [M]
    have h : 0 ≤ CE + 1 + A := by linarith
    exact le_add_of_nonneg_right (mul_nonneg (by positivity) h)
  have hM : 0 < M := by linarith
  let b := fl / 16 * M
  let s := fl ^ 2 / 256 * M
  let V := (8 * M) ^ ((r : ℝ) / 2)
  have hb : 0 < b := by dsimp [b]; positivity
  have hs : 0 < s := by dsimp [s]; positivity
  have hV : 0 ≤ V := by dsimp [V]; positivity
  have hbudget : CE + 1 + Cfine r fl / (c ^ 2 * M ^ (2 * r - 1)) ≤ fl / 16 * M := by
    have hp : 1 ≤ M ^ (2 * r - 1) := one_le_pow₀ hM1
    have hq : Cfine r fl / (c ^ 2 * M ^ (2 * r - 1)) ≤ A := by
      rw [← div_div]
      apply (div_le_div_of_nonneg_right (le_max_right 0 _) (by positivity)).trans
      exact div_le_self hA hp
    have heq : fl / 32 * M = fl / 32 + (CE + 1 + A) := by
      dsimp [M]
      field_simp
    linarith
  obtain ⟨n₃, _, hshell⟩ := shells k hk c L fl fu Vb hc hL hfl M hM
  obtain ⟨n₄, hxlarge⟩ := Asym.eventually_mul_epsSq_ge r (by dsimp [r]; omega) ((r : ℝ) / b)
  obtain ⟨n₅, hlog⟩ := Asym.eventually_log_ge_one
  let Cscore := (4 / 9 + 8 * (r : ℝ) / 3) / s + 1 / 2
  let Clocal := (Nat.factorial r : ℝ) * ((fl / 16)⁻¹ + (1 / 8 : ℝ)⁻¹)
  let Cshell := V * b⁻¹ * 2
  let Cbad := 5 / 4 + 64 / fl ^ 2 + Cscore
  have hCscore : 0 ≤ Cscore := by dsimp [Cscore]; positivity
  have hClocal : 0 ≤ Clocal := by dsimp [Clocal]; positivity
  have hCshell : 0 ≤ Cshell := by dsimp [Cshell]; positivity
  have hCbad : 0 < Cbad := by dsimp [Cbad]; positivity
  refine ⟨M, Cbad + (Clocal + Cshell), max (max n₁ n₂) (max n₃ (max n₄ n₅)),
    hM, by positivity, ?_⟩
  intro n hn₀ τ hτ₀ hτ₁ μ θs hdata
  have hn₁' : n₁ ≤ n := (le_max_left _ _).trans ((le_max_left _ _).trans hn₀)
  have hn₂' : n₂ ≤ n := (le_max_right _ _).trans ((le_max_left _ _).trans hn₀)
  have hn₃' : n₃ ≤ n := (le_max_left _ _).trans ((le_max_right _ _).trans hn₀)
  have hn₄' : n₄ ≤ n := (le_max_left _ _).trans ((le_max_right _ _).trans
    ((le_max_right _ _).trans hn₀))
  have hn₅' : n₅ ≤ n := (le_max_right _ _).trans ((le_max_right _ _).trans
    ((le_max_right _ _).trans hn₀))
  obtain ⟨hn, hxlarge⟩ := hxlarge n hn₄'
  have hkn : k + 1 < n := hn₁.trans_le hn₁'
  have hn' : 0 < (n : ℝ) := by exact_mod_cast hn
  have hlam : 0 < lamSeq c k n := mul_pos hc (Real.rpow_pos_of_pos hn' _)
  let x := (n : ℝ) * epsSq r n
  have hx : 0 < x := mul_pos hn' (Real.rpow_pos_of_pos hn' _)
  have hxn : x ≤ n := Asym.mul_epsSq_le r n (by omega)
  have hxr : x ≤ (n : ℝ) * rhoSq r n :=
    Asym.mul_epsSq_le_mul_rhoSq r n (by dsimp [r]; omega) (by omega) (hlog n hn₅')
  have hX : (r : ℝ) ≤ b * x := by
    rw [mul_comm]
    exact (div_le_iff₀ hb).mp hxlarge
  let J := Jshell k n fl M
  let P := Measure.pi μ
  let E := OmegaE k n τ (lamSeq c k n) θs CE
  let G := OmegaG k n c τ fl μ θs
  let Z := OmegaZeta r n J τ θs
  let post := posterior τ 1 (lamSeq c k n) k n
  let bad := toMeasurable P ((Eᶜ ∪ Gᶜ) ∪ Zᶜ)
  let good := badᶜ
  have hbad : MeasurableSet bad := measurableSet_toMeasurable _ _
  have hE : good ⊆ E := by
    intro y hy
    by_contra he
    exact hy (subset_toMeasurable P _ (Or.inl (Or.inl he)))
  have hG : good ⊆ G := by
    intro y hy
    by_contra hg
    exact hy (subset_toMeasurable P _ (Or.inl (Or.inr hg)))
  have hZ : good ⊆ Z := by
    intro y hy
    by_contra hz
    exact hy (subset_toMeasurable P _ (Or.inr hz))
  have (i : Fin n) : IsProbabilityMeasure (μ i) := hdata.prob i
  have hposterior (y : Fin n → ℝ) (B : Set (Fin n → ℝ)) : post y B ≤ 1 := by
    have := posterior_isProbability k n (by omega) τ 1 _ ⟨hτ₀, hτ₁⟩ one_pos hlam.le y
    exact prob_le_one
  obtain ⟨hlocal, hprobG, hlocalBound⟩ := hloc n hn₂' τ hτ₀ hτ₁ μ θs hdata
  obtain ⟨hJpos, hJm, hJlower, hnum⟩ := hshell n hn₃'
  have hJlower' : s * x ≤ (J : ℝ) := by simpa [s, x, r, J, mul_assoc] using hJlower
  have hprobZ := score_events k hk n hkn J hJpos hJm τ L fl fu Vb ⟨hτ₀, hτ₁⟩ hL hfl μ θs hdata
  have hprobBad : P bad ≤ ENNReal.ofReal (Cbad * x⁻¹) := by
    have hEbound : P Eᶜ ≤ ENNReal.ofReal (5 / 4 * x⁻¹) := by
      simpa [P, E, x, r, div_eq_mul_inv] using hdenom n hn₁' τ hτ₀ hτ₁ μ θs hdata
    have hGbound : P Gᶜ ≤ ENNReal.ofReal (64 / fl ^ 2 * x⁻¹) := by
      apply hprobG.trans
      apply ENNReal.ofReal_le_ofReal
      rw [← div_eq_mul_inv, div_div]
      apply div_le_div_of_nonneg_left (by norm_num) (by positivity)
      simpa [mul_assoc] using mul_le_mul_of_nonneg_left hxr (sq_nonneg fl)
    have hZbound : P Zᶜ ≤ ENNReal.ofReal (Cscore * x⁻¹) := by
      apply hprobZ.trans
      apply ENNReal.ofReal_le_ofReal
      simpa only [Cscore, r, Nat.cast_add, Nat.cast_one] using
        score_constant_bound (show 0 < r by dsimp [r]; omega) hs hx hxn hJlower'
    calc
      _ = P ((Eᶜ ∪ Gᶜ) ∪ Zᶜ) := measure_toMeasurable _
      _ ≤ (P Eᶜ + P Gᶜ) + P Zᶜ :=
        (measure_union_le _ _).trans (add_le_add_left (measure_union_le _ _) _)
      _ ≤ (ENNReal.ofReal (5 / 4 * x⁻¹) + ENNReal.ofReal (64 / fl ^ 2 * x⁻¹)) +
          ENNReal.ofReal (Cscore * x⁻¹) := add_le_add (add_le_add hEbound hGbound) hZbound
      _ = _ := by
        rw [← ENNReal.ofReal_add (by positivity) (by positivity),
          ← ENNReal.ofReal_add (by positivity) (by positivity)]
        congr 1
        dsimp [Cbad]
        ring
  let Aout : Set (Fin n → ℝ) := {θ | θ - θs ∉ Kn k n c}
  let a := fun j : ℕ => (2 : ℝ) ^ j * M
  let B := fun j => Eshell k n L fl fu (a j) θs
  have hf (j : ℕ) : Measurable (fun y => post y (B j)) :=
    measurable_posterior_apply k n τ 1 _ (measurableSet_Eshell ..)
  have hlocal' (y : Fin n → ℝ) (hy : y ∈ good) :
      post y Aout ≤ ENNReal.ofReal (Clocal * x⁻¹) := by
    apply (hlocalBound y ⟨hG hy, hE hy⟩).trans
    apply ENNReal.ofReal_le_ofReal
    have h₁ : Real.exp (-(fl * n * rhoSq r n / 16)) ≤ (fl / 16)⁻¹ * x⁻¹ := by
      have he : -(fl * n * rhoSq r n / 16) ≤ -((fl / 16) * x) := by
        nlinarith [mul_le_mul_of_nonneg_left hxr hfl.le]
      exact (Real.exp_le_exp.mpr he).trans (Asym.exp_neg_mul_le_inv (by positivity) hx)
    have h₂ : Real.exp (-(n / 8 : ℝ)) ≤ (1 / 8 : ℝ)⁻¹ * x⁻¹ := by
      have he : -(n / 8 : ℝ) ≤ -((1 / 8) * x) := by linarith
      exact (Real.exp_le_exp.mpr he).trans (Asym.exp_neg_mul_le_inv (by norm_num) hx)
    dsimp [Clocal]
    rw [mul_assoc (Nat.factorial r : ℝ), add_mul]
    exact mul_le_mul_of_nonneg_left (add_le_add h₁ h₂) (by positivity)
  have hpeel (j : ℕ) : ∫⁻ y in good, post y (B j) ∂P
      ≤ ENNReal.ofReal (V * b⁻¹ * x⁻¹) * (2⁻¹ : ℝ≥0∞) ^ j := by
    have ha : M ≤ a j := by
      dsimp [a]
      exact le_mul_of_one_le_left hM.le (one_le_pow₀ (by norm_num))
    have ha' : 0 < a j := hM.trans_le ha
    apply (shell_ratio_bound hkn ⟨hτ₀, hτ₁⟩ hlam hbad.compl hE hZ ha'
      (hnum (a j) ha τ hτ₀ hτ₁ μ θs hdata)).trans
    have hbracket : CE + 1 + Cfine r fl / (c ^ 2 * M ^ (2 * r - 1)) ≤ fl / 16 * a j :=
      hbudget.trans (mul_le_mul_of_nonneg_left ha (by positivity))
    have hexp : -(fl / 8 * a j * n * epsSq r n) +
          (CE + 1 + Cfine r fl / (c ^ 2 * M ^ (2 * r - 1))) * n * epsSq r n
          ≤ -((2 : ℝ) ^ j * (b * x)) := by
      have h := mul_le_mul_of_nonneg_right hbracket hx.le
      dsimp [a, b, x] at h ⊢
      nlinarith only [h]
    have hgeom := dyadic_decay (show 2 ≤ r by dsimp [r]; omega) hM hX j
    have hreal : (8 * a j) ^ ((r : ℝ) / 2) *
        Real.exp (-(fl / 8 * a j * n * epsSq r n) +
          (CE + 1 + Cfine r fl / (c ^ 2 * M ^ (2 * r - 1))) * n * epsSq r n)
        ≤ (V * b⁻¹ * x⁻¹) * (1 / 2 : ℝ) ^ j := by
      calc
        _ ≤ (8 * a j) ^ ((r : ℝ) / 2) * Real.exp (-((2 : ℝ) ^ j * (b * x))) :=
          mul_le_mul_of_nonneg_left (Real.exp_le_exp.mpr hexp) (by positivity)
        _ ≤ (V * Real.exp (-(b * x))) * (1 / 2 : ℝ) ^ j := hgeom
        _ ≤ _ := by
          rw [mul_assoc V b⁻¹ x⁻¹]
          exact mul_le_mul_of_nonneg_right
            (mul_le_mul_of_nonneg_left (Asym.exp_neg_mul_le_inv hb hx) hV) (by positivity)
    have hgeomcast : ENNReal.ofReal ((1 / 2 : ℝ) ^ j) = (2⁻¹ : ℝ≥0∞) ^ j := by
      rw [ENNReal.ofReal_pow (by norm_num), one_div, ENNReal.ofReal_inv_of_pos (by norm_num)]
      norm_num
    simpa only [ENNReal.ofReal_mul (show 0 ≤ V * b⁻¹ * x⁻¹ by positivity), hgeomcast] using
      ENNReal.ofReal_le_ofReal hreal
  let F := fun y => post y (farSet k θs M)
  refine ⟨measurable_posterior_apply k n τ 1 _ (measurableSet_farSet k θs M), ?_⟩
  have hgoodInt : ∫⁻ y in good, F y ∂P ≤ ENNReal.ofReal ((Clocal + Cshell) * x⁻¹) := by
    calc
      _ ≤ ∫⁻ y in good, ENNReal.ofReal (Clocal * x⁻¹) + ∑' j, post y (B j) ∂P := by
        apply setLIntegral_mono' hbad.compl
        intro y hy
        exact ((measure_mono (farSet_subset_shells θs hn hM hlocal)).trans
          ((measure_union_le _ _).trans (add_le_add (hlocal' y hy) (measure_iUnion_le _))))
      _ = ENNReal.ofReal (Clocal * x⁻¹) * P good + ∑' j, ∫⁻ y in good, post y (B j) ∂P := by
        rw [lintegral_add_left measurable_const, lintegral_const,
          Measure.restrict_apply_univ, lintegral_tsum (fun j => (hf j).aemeasurable)]
      _ ≤ ENNReal.ofReal (Clocal * x⁻¹) +
          ∑' j : ℕ, ENNReal.ofReal (V * b⁻¹ * x⁻¹) * (2⁻¹ : ℝ≥0∞) ^ j := by
        apply add_le_add _ (ENNReal.tsum_le_tsum hpeel)
        simpa using mul_le_mul_right (prob_le_one (μ := P) (s := good))
          (ENNReal.ofReal (Clocal * x⁻¹))
      _ = _ := by
        rw [ENNReal.tsum_mul_left, ENNReal.tsum_geometric_two, ← ENNReal.ofReal_ofNat (n := 2),
          ← ENNReal.ofReal_mul (by positivity), ← ENNReal.ofReal_add (by positivity) (by positivity)]
        congr 1
        dsimp [Cshell]
        ring
  have hbadInt : ∫⁻ y in bad, F y ∂P ≤ P bad := by
    simpa using (lintegral_mono (μ := P.restrict bad) (fun y => hposterior y (farSet k θs M)))
  rw [Asym.massRate_eq_inv k n hn]
  calc
    _ = (∫⁻ y in bad, F y ∂P) + ∫⁻ y in good, F y ∂P :=
      (lintegral_add_compl F hbad).symm
    _ ≤ ENNReal.ofReal (Cbad * x⁻¹) + ENNReal.ofReal ((Clocal + Cshell) * x⁻¹) :=
      add_le_add (hbadInt.trans hprobBad) hgoodInt
    _ = _ := by rw [← ENNReal.ofReal_add (by positivity) (by positivity), ← add_mul]

end BQTF
