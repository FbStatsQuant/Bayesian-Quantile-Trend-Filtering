import BQTF.Asym.LocalGeometry
import BQTF.Asym.LocalRates
import BQTF.Asym.LocalMass
import BQTF.Denominator
import BQTF.Width
import BQTF.Interp
import BQTF.Concentration

/-!
# Localization (appendix, Proposition `pf:prop:local`)

Owner: Neon-B. `ρ_n² = n^{−(2r−1)/(2r+1)} log n`, `T_n = 4n^r/λ`, `K_n = K(ρ_n, T_n)`,
`s_0 = min{1, L, 3f̲/(4f̄)}`, `Ω_G = {G_{K_n} ≤ (f̲/4) n ρ_n²}`.
-/

open MeasureTheory ProbabilityTheory
open scoped ENNReal Topology

noncomputable section

namespace BQTF

/-- `K_n = K(ρ_n, T_n)` with `λ = c n^{r−1/2}`. -/
def Kn (k n : ℕ) (c : ℝ) : Set (Fin n → ℝ) :=
  Kset (k + 1) n (Real.sqrt (rhoSq (k + 1) n)) (Tn (k + 1) n (lamSeq c k n))

/-- `s_0 = min{1, L, 3f̲/(4f̄)}`. -/
def s0 (L fl fu : ℝ) : ℝ := min 1 (min L (3 * fl / (4 * fu)))

/-- `Ω_G = {y : G_{K_n}(y) ≤ (f̲/4) n ρ_n²}`. -/
def OmegaG (k n : ℕ) (c τ fl : ℝ) (μ : Fin n → Measure ℝ) (θs : Fin n → ℝ) : Set (Fin n → ℝ) :=
  {y | GK τ μ θs (Kn k n c) y ≤ fl / 4 * n * rhoSq (k + 1) n}

private theorem Kset_zero {r n : ℕ} {ρ T : ℝ} (hρ : 0 ≤ ρ) (hT : 0 ≤ T) :
    (0 : Fin n → ℝ) ∈ Kset r n ρ T := by
  have hd : diffOp r n (0 : Fin n → ℝ) = 0 := by ext i; simp [diffOp]
  exact ⟨by simpa [empNorm, l2sq] using hρ, by simpa [TVr, hd, l1norm] using hT⟩

private theorem Kset_neg {r n : ℕ} {ρ T : ℝ} {δ : Fin n → ℝ} (hδ : δ ∈ Kset r n ρ T) :
    -δ ∈ Kset r n ρ T := by
  rw [← neg_one_smul ℝ δ]
  refine ⟨?_, ?_⟩
  · change empNorm ((-1 : ℝ) • δ) ≤ ρ
    simpa only [empNorm_smul, abs_neg, abs_one, one_mul] using hδ.1
  · change TVr r n ((-1 : ℝ) • δ) ≤ T
    simpa only [TVr_smul, abs_neg, abs_one, one_mul] using hδ.2

private theorem lossHat_abs_le {n : ℕ} (τ : ℝ) (hτ : 0 < τ ∧ τ < 1) (Z δ : Fin n → ℝ) :
    |lossHat τ Z δ| ≤ l1norm δ := by
  unfold lossHat l1norm
  apply (Finset.abs_sum_le_sum_abs ..).trans
  apply Finset.sum_le_sum
  intro i _
  have hp := ell_props τ (Z i) hτ
  change |ell τ (δ i) (Z i)| ≤ |δ i|
  simpa [hp.2.1] using hp.2.2.1 (δ i) 0

private theorem lossExp_abs_le {n : ℕ} (τ : ℝ) (hτ : 0 < τ ∧ τ < 1)
    (μ : Fin n → Measure ℝ) (hμ : ∀ i, IsProbabilityMeasure (μ i))
    (θs δ : Fin n → ℝ) : |lossExp τ μ θs δ| ≤ l1norm δ := by
  have hb : ∀ᵐ y ∂Measure.pi μ, ‖lossHat τ (y - θs) δ‖ ≤ l1norm δ :=
    Filter.Eventually.of_forall fun y => by
      simpa only [Real.norm_eq_abs] using lossHat_abs_le τ hτ (y - θs) δ
  have h := norm_integral_le_of_norm_le_const hb
  simpa [lossExp, Real.norm_eq_abs, measureReal_def] using h

private theorem local_sup_bdd {n : ℕ} (τ : ℝ) (hτ : 0 < τ ∧ τ < 1)
    (μ : Fin n → Measure ℝ) (hμ : ∀ i, IsProbabilityMeasure (μ i))
    (θs : Fin n → ℝ) {K : Set (Fin n → ℝ)} (hK : IsCompact K) :
    ∃ B : ℝ, 0 ≤ B ∧ ∀ y,
      (∀ δ ∈ K, |lossHat τ (y - θs) δ - lossExp τ μ θs δ| ≤ B) := by
  have hcont : Continuous (l1norm (m := n)) := by unfold l1norm; fun_prop
  obtain ⟨B, hB⟩ := (hK.image hcont).bddAbove
  refine ⟨2 * max 0 B, by positivity, fun y δ hδ => ?_⟩
  have hnorm := (hB ⟨δ, hδ, rfl⟩).trans (le_max_right 0 B)
  have h := abs_sub_le (lossHat τ (y - θs) δ) 0 (lossExp τ μ θs δ)
  simp only [sub_zero, zero_sub, abs_neg] at h
  linarith [lossHat_abs_le τ hτ (y - θs) δ, lossExp_abs_le τ hτ μ hμ θs δ]

private theorem local_event_probability {k n J : ℕ} {c L fl fu Vb τ : ℝ}
    (hk : 1 ≤ k) (hn : k + 1 < n) (hfl : 0 < fl)
    {μ : Fin n → Measure ℝ} {θs : Fin n → ℝ}
    (hτ : 0 < τ ∧ τ < 1) (hdata : DataHyp k n τ μ θs L fl fu Vb)
    (hρ : 0 < Real.sqrt (rhoSq (k + 1) n)) (hT : 0 < Tn (k + 1) n (lamSeq c k n))
    (hJ : 1 ≤ J) (hJm : J ≤ n - (k + 1))
    (hw : Real.sqrt n * (Real.sqrt (rhoSq (k + 1) n) * Real.sqrt (J + ((k + 1 : ℕ) : ℝ)) +
        2 ^ (k + 1) * cF (k + 1) * Real.sqrt (Real.log (2 * n)) * Tn (k + 1) n (lamSeq c k n) *
          (J : ℝ) ^ (-(((k + 1 : ℕ) : ℝ) - 1 / 2))) ≤ fl / 32 * n * rhoSq (k + 1) n) :
    Measure.pi μ (OmegaG k n c τ fl μ θs)ᶜ ≤
      ENNReal.ofReal (64 / (fl ^ 2 * n * rhoSq (k + 1) n)) := by
  let r := k + 1
  let K := Kn k n c
  let G := GK τ μ θs K
  let P := Measure.pi μ
  let x := (n : ℝ) * rhoSq r n
  have hμ (i : Fin n) : IsProbabilityMeasure (μ i) := hdata.prob i
  have hn' : 0 < n := by omega
  have hρSq : 0 < rhoSq r n := Real.sqrt_pos.mp hρ
  have hx : 0 < x := mul_pos (by exact_mod_cast hn') hρSq
  have hK : IsCompact K := isCompact_Kset r n hn' _ _ hρ.le
  obtain ⟨hG, hmean, hvar⟩ := concentration τ hτ μ hdata.prob θs K hK
    (fun _ hδ => Kset_neg hδ) ⟨0, Kset_zero hρ.le hT.le⟩
  have hwidth := (width r n (by dsimp [r]; omega) hn _ _ hρ hT J hJ hJm).trans hw
  have hmean' : (∫ y, G y ∂P) ≤ fl / 8 * x := by
    have hW : (∫ ξ, sSup ((fun δ => dot ξ δ) '' K) ∂rademacher n) ≤ fl / 32 * n * rhoSq r n :=
      hwidth
    apply hmean.trans
    calc
      _ ≤ 4 * (fl / 32 * n * rhoSq r n) := mul_le_mul_of_nonneg_left hW (by norm_num)
      _ = _ := by dsimp [x]; ring
  have hvar' : variance G P ≤ x := by
    apply hvar.trans
    apply Real.sSup_le _ hx.le
    rintro v ⟨δ, hδ, rfl⟩
    exact (l2sq_le_of_empNorm_le hn' hδ.1).trans_eq
      (by dsimp [x]; rw [Real.sq_sqrt hρSq.le])
  obtain ⟨B, hB, hbound⟩ := local_sup_bdd τ hτ μ hdata.prob θs hK
  have hG₂ : MemLp G 2 P := by
    apply memLp_of_bounded (a := 0) (b := B) _ hG.aestronglyMeasurable 2
    apply Filter.Eventually.of_forall
    intro y
    have hnonneg : 0 ≤ G y := Real.sSup_nonneg fun _ ⟨_, _, h⟩ => h ▸ abs_nonneg _
    exact ⟨hnonneg, Real.sSup_le (fun _ ⟨δ, hδ, h⟩ => h ▸ hbound y δ hδ) hB⟩
  have hpos : 0 < fl / 8 * x := by positivity
  calc
    _ ≤ P {y | fl / 8 * x ≤ |G y - ∫ z, G z ∂P|} := by
      apply measure_mono
      intro y hy
      change ¬G y ≤ fl / 4 * n * rhoSq r n at hy
      have hy' := lt_of_not_ge hy
      have h := le_abs_self (G y - ∫ z, G z ∂P)
      change fl / 8 * x ≤ _
      dsimp [x] at hmean' ⊢
      linarith
    _ ≤ ENNReal.ofReal (variance G P / (fl / 8 * x) ^ 2) :=
      meas_ge_le_variance_div_sq hG₂ hpos
    _ ≤ _ := by
      apply ENNReal.ofReal_le_ofReal
      apply (div_le_div_of_nonneg_right hvar' (sq_nonneg _)).trans_eq
      rw [mul_assoc (fl ^ 2) (n : ℝ)]
      change x / (fl / 8 * x) ^ 2 = 64 / (fl ^ 2 * x)
      field_simp
      norm_num

private theorem local_ray_bound {k n : ℕ} {c L fl fu Vb τ : ℝ}
    (hn : 0 < n) (hL : 0 < L) (hfl : 0 < fl)
    {μ : Fin n → Measure ℝ} {θs : Fin n → ℝ}
    (hτ : 0 < τ ∧ τ < 1) (hdata : DataHyp k n τ μ θs L fl fu Vb)
    (hρ : 0 < Real.sqrt (rhoSq (k + 1) n)) (hT : 0 < Tn (k + 1) n (lamSeq c k n))
    (hlocal : ∀ δ ∈ Kn k n c, ∀ i, |δ i| ≤ s0 L fl fu)
    {y : Fin n → ℝ} (hy : y ∈ OmegaG k n c τ fl μ θs) (δ : Fin n → ℝ)
    (hδ : δ ∉ Kn k n c) :
    let ρ := Real.sqrt (rhoSq (k + 1) n)
    let T := Tn (k + 1) n (lamSeq c k n)
    let α := fl / 4 * n * rhoSq (k + 1) n
    let t := max (empNorm δ / ρ) (TVr (k + 1) n δ / T)
    1 < t ∧ -α * t ≤ lossHat τ (y - θs) δ ∧
      (TVr (k + 1) n δ / T ≤ empNorm δ / ρ →
        α * (empNorm δ / ρ) ≤ lossHat τ (y - θs) δ) := by
  let r := k + 1
  let ρ := Real.sqrt (rhoSq r n)
  let T := Tn r n (lamSeq c k n)
  let α := fl / 4 * n * rhoSq r n
  let t := max (empNorm δ / ρ) (TVr r n δ / T)
  let v := t⁻¹ • δ
  change 1 < t ∧ -α * t ≤ lossHat τ (y - θs) δ ∧
    (TVr r n δ / T ≤ empNorm δ / ρ → α * (empNorm δ / ρ) ≤ lossHat τ (y - θs) δ)
  have ht : 1 < t := by
    contrapose! hδ
    exact ⟨(div_le_one hρ).mp ((le_max_left _ _).trans hδ),
      (div_le_one hT).mp ((le_max_right _ _).trans hδ)⟩
  have ht₀ : 0 < t := zero_lt_one.trans ht
  have hE : empNorm v = empNorm δ / t := by
    simp [v, empNorm_smul, abs_of_pos (inv_pos.2 ht₀), div_eq_mul_inv, mul_comm]
  have hV : TVr r n v = TVr r n δ / t := by
    simp [v, TVr_smul, abs_of_pos (inv_pos.2 ht₀), div_eq_mul_inv, mul_comm]
  have hv : v ∈ Kn k n c := by
    refine ⟨?_, ?_⟩
    · rw [hE, div_le_iff₀ ht₀, mul_comm]
      exact (div_le_iff₀ hρ).mp (le_max_left _ _)
    · rw [hV, div_le_iff₀ ht₀, mul_comm]
      exact (div_le_iff₀ hT).mp (le_max_right _ _)
  have hK : IsCompact (Kn k n c) := isCompact_Kset r n hn _ _ hρ.le
  obtain ⟨B, hB, hbound⟩ := local_sup_bdd τ hτ μ hdata.prob θs hK
  have hdev : |lossHat τ (y - θs) v - lossExp τ μ θs v| ≤ α := by
    have hbd : BddAbove ((fun δ => |lossHat τ (y - θs) δ - lossExp τ μ θs δ|) '' Kn k n c) :=
      ⟨B, fun _ ⟨δ, hδ, h⟩ => h ▸ hbound y δ hδ⟩
    exact (le_csSup hbd ⟨v, hv, rfl⟩).trans hy
  have hbase : lossExp τ μ θs v - α ≤ lossHat τ (y - θs) v := by linarith [(abs_le.mp hdev).1]
  have hray := lossHat_ray τ hτ (y - θs) δ ht.le
  refine ⟨ht, ?_, ?_⟩
  · apply le_trans _ hray
    have hn := lossExp_nonneg hdata hτ hL hfl v
    nlinarith only [mul_le_mul_of_nonneg_left hbase ht₀.le, mul_nonneg ht₀.le hn]
  · intro hd
    have he : t = empNorm δ / ρ := max_eq_left hd
    have hEq : empNorm v = ρ := by
      rw [hE, div_eq_iff ht₀.ne', he]
      rw [mul_comm ρ, div_mul_cancel₀ _ hρ.ne']
    have hSq := sq_empNorm v
    rw [hEq, Real.sq_sqrt (Real.sqrt_pos.mp hρ).le] at hSq
    have hμv := lossExp_quadratic_lower hdata hτ hL hfl v (fun i =>
      (hlocal v hv i).trans ((min_le_right _ _).trans (min_le_left _ _)))
    have hmass : fl / 2 * n * rhoSq r n ≤ lossExp τ μ θs v := by
      rw [eq_div_iff (by exact_mod_cast hn.ne' : (n : ℝ) ≠ 0)] at hSq
      nlinarith [mul_le_mul_of_nonneg_left hSq.le (show 0 ≤ fl / 2 by positivity)]
    rw [← he]
    apply le_trans _ hray
    have hv' : α ≤ lossHat τ (y - θs) v := by
      have hL' : 2 * α ≤ lossExp τ μ θs v := by dsimp [α]; linarith only [hmass]
      linarith only [hbase, hL']
    simpa only [mul_comm α t] using mul_le_mul_of_nonneg_left hv' ht₀.le

private theorem local_gamma_tail (n r : ℕ) (hn : 0 < n) {lam α : ℝ} (hlam : 0 < lam)
    (hα : α + 1 ≤ n / 32) :
    (∫⁻ u, Set.indicator {u : Fin (n-r) → ℝ | 2 * n < lam * l1norm u}
      (fun u => ENNReal.ofReal (Real.exp ((α + 1) * (lam * l1norm u / (4 * n) + 1 / 2)))) u
      ∂Qlam (n-r) lam) ≤ ENNReal.ofReal (Real.exp (-(n / 4 : ℝ))) := by
  have hn' : 0 < (n : ℝ) := by exact_mod_cast hn
  let b := (α + 1) / (4 * n) + 1 / 2
  let A := (α + 1) / 2 - n
  have hb : b ≤ 51 / 100 := by
    have hb' : (α + 1) / (4 * n) ≤ 1 / 128 := by
      apply (div_le_iff₀ (by positivity)).mpr
      linarith
    dsimp [b]
    linarith
  have hb' : b < 1 := by linarith
  have hbase : (1 - b)⁻¹ ≤ Real.exp (23 / 32) := by
    have h := Real.sum_le_exp_of_nonneg (x := (23 / 32 : ℝ)) (by norm_num) 5
    calc
      _ ≤ (49 / 100 : ℝ)⁻¹ :=
        inv_anti₀ (by norm_num) (by linarith)
      _ ≤ _ := by
        apply le_trans _ h
        norm_num [Finset.sum_range_succ, Nat.factorial]
  have hnm : n - r ≤ n := Nat.sub_le _ _
  have hmoment : (1 - b)⁻¹ ^ (n - r) ≤ Real.exp ((n : ℝ) * (23 / 32)) := by
    calc
      _ ≤ Real.exp (23 / 32) ^ (n - r) := pow_le_pow_left₀ (by positivity) hbase _
      _ = Real.exp (((n - r : ℕ) : ℝ) * (23 / 32)) := (Real.exp_nat_mul _ _).symm
      _ ≤ _ := Real.exp_le_exp.mpr (mul_le_mul_of_nonneg_right (by exact_mod_cast hnm) (by norm_num))
  have hm : Measurable (fun u : Fin (n-r) → ℝ =>
      ENNReal.ofReal (Real.exp (b * (lam * l1norm u)))) := by
    unfold l1norm
    fun_prop
  calc
    _ ≤ ∫⁻ u, ENNReal.ofReal (Real.exp A) *
        ENNReal.ofReal (Real.exp (b * (lam * l1norm u))) ∂Qlam (n-r) lam := by
      apply lintegral_mono
      intro u
      by_cases hu : 2 * (n : ℝ) < lam * l1norm u
      · have hu' : u ∈ {u : Fin (n-r) → ℝ | 2 * n < lam * l1norm u} := hu
        dsimp only
        rw [Set.indicator_of_mem hu', ← ENNReal.ofReal_mul (Real.exp_nonneg _), ← Real.exp_add]
        apply ENNReal.ofReal_le_ofReal
        apply Real.exp_le_exp.mpr
        dsimp [A, b]
        have he : (α + 1) * (lam * l1norm u / (4 * n) + 1 / 2) +
          (lam * l1norm u / 2 - n) = (α + 1) / 2 - n +
            ((α + 1) / (4 * n) + 1 / 2) * (lam * l1norm u) := by ring
        rw [← he]
        linarith
      · have hu' : u ∉ {u : Fin (n-r) → ℝ | 2 * n < lam * l1norm u} := hu
        dsimp only
        rw [Set.indicator_of_notMem hu']
        exact bot_le
    _ = ENNReal.ofReal (Real.exp A) * ENNReal.ofReal ((1 - b)⁻¹ ^ (n-r)) := by
      rw [lintegral_const_mul _ hm, Qlam_lintegral_exp_l1 _ hlam hb']
    _ ≤ ENNReal.ofReal (Real.exp A) * ENNReal.ofReal (Real.exp ((n : ℝ) * (23 / 32))) :=
      mul_le_mul_right (ENNReal.ofReal_le_ofReal hmoment) _
    _ ≤ _ := by
      rw [← ENNReal.ofReal_mul (Real.exp_nonneg _), ← Real.exp_add]
      apply ENNReal.ofReal_le_ofReal
      apply Real.exp_le_exp.mpr
      dsimp [A]
      linarith

private theorem norm_NT_le_empNorm {r n : ℕ} (hr : 1 ≤ r) (hn : r < n)
    (θ θs : Fin n → ℝ) : l2norm (NT r n (θ - θs)) ≤ Real.sqrt n * empNorm (θ - θs) := by
  obtain ⟨⟨v,u⟩, rfl⟩ := (coordMap_bijective r n hr hn).1.2 θ
  let δ := coordMap r n (v,u) - θs
  have hn' : 0 < (n : ℝ) := by exact_mod_cast (show 0 < n by omega)
  have hh := pythagoras r n hr hn θs v u
  have h₀ := l2sq_nonneg (Pperp r n (Smul r n (u - ustar r n θs)))
  rw [← sub_cbar_eq r n hr hn]
  change l2norm (v - cbar r n θs u) ≤ Real.sqrt n * empNorm δ
  apply (sq_le_sq₀ (Real.sqrt_nonneg _) (mul_nonneg (Real.sqrt_nonneg _) (empNorm_nonneg _))).mp
  rw [mul_pow, Real.sq_sqrt (l2sq_nonneg _), Real.sq_sqrt hn'.le, sq_empNorm]
  rw [mul_div_cancel₀ _ hn'.ne']
  linarith

private theorem local_mass_emp {k n : ℕ} {τ lam ρ α : ℝ} (hn : k + 1 < n)
    (hlam : 0 < lam) (hρ : 0 < ρ) (hα : 0 < α) (y θs : Fin n → ℝ)
    {B : Set (Fin n → ℝ)} (hBm : MeasurableSet B)
    (hB : ∀ θ ∈ B, ρ ≤ empNorm (θ - θs) ∧
      α * (empNorm (θ - θs) / ρ) ≤ lossHat τ (y - θs) (θ - θs)) :
    Nmass (k + 1) τ lam y θs B ≤
      Vr (k + 1) * ENNReal.ofReal (((k + 1).factorial : ℝ) *
        (2 * Real.sqrt n * ρ / α) ^ (k + 1) * Real.exp (-α / 2)) := by
  let r := k + 1
  let R := Real.sqrt n * ρ
  let κ := α / (2 * R)
  have hn' : 0 < (n : ℝ) := by exact_mod_cast (show 0 < n by omega)
  have hκ : 0 < κ := by dsimp [κ,R]; positivity
  unfold Nmass
  rw [← lintegral_indicator hBm]
  calc
    _ ≤ ∫⁻ θ, ENNReal.ofReal (Real.exp (-α / 2)) *
        ENNReal.ofReal (Real.exp (-(κ * l2norm (NT r n (θ - θs))))) ∂nu r n lam := by
      apply lintegral_mono
      intro θ
      by_cases hθ : θ ∈ B
      · dsimp only
        rw [Set.indicator_of_mem hθ, ← ENNReal.ofReal_mul (Real.exp_nonneg _), ← Real.exp_add]
        apply ENNReal.ofReal_le_ofReal
        apply Real.exp_le_exp.mpr
        obtain ⟨ha, hb⟩ := hB θ hθ
        have hnt := norm_NT_le_empNorm (r:=r) (by dsimp [r]; omega) hn θ θs
        have hh : κ * l2norm (NT r n (θ - θs)) ≤ α / 2 * (empNorm (θ - θs) / ρ) := by
          apply (mul_le_mul_of_nonneg_left hnt hκ.le).trans_eq
          dsimp [κ, R]
          have hsr : 0 < Real.sqrt n := by positivity
          field_simp
        have hp : 1 ≤ empNorm (θ - θs) / ρ := (one_le_div hρ).mpr ha
        linarith only [hh, hb, mul_le_mul_of_nonneg_left hp (show 0 ≤ α / 2 by positivity)]
      · dsimp only
        rw [Set.indicator_of_notMem hθ]
        exact bot_le
    _ = _ := by
      rw [lintegral_const_mul' _ _ ENNReal.ofReal_ne_top,
        nu_lintegral_exp_NT r n (by dsimp [r]; omega) hn lam κ hlam hκ]
      have hk : κ⁻¹ = 2 * Real.sqrt n * ρ / α := by dsimp [κ, R]; rw [inv_div]; congr 1; ring
      rw [hk, ENNReal.ofReal_mul (show 0 ≤ (r.factorial : ℝ) *
        (2 * Real.sqrt n * ρ / α) ^ r by positivity)]
      ac_rfl

private theorem local_mass_tv {k n : ℕ} {τ lam ρ α : ℝ} (hn : k + 1 < n)
    (hlam : 0 < lam) (hρ : 0 < ρ) (_hα : 0 ≤ α) (hαn : α + 1 ≤ n / 32)
    (y θs : Fin n → ℝ) {B : Set (Fin n → ℝ)} (hBm : MeasurableSet B)
    (hB : ∀ θ ∈ B,
      let q := lam * l1norm (diffOp (k + 1) n θ) / (4 * n) + 1 / 2
      2 * n < lam * l1norm (diffOp (k + 1) n θ) ∧
      empNorm (θ - θs) ≤ ρ * q ∧ -α * q ≤ lossHat τ (y - θs) (θ - θs)) :
    Nmass (k + 1) τ lam y θs B ≤
      Vr (k + 1) * ENNReal.ofReal (((k + 1).factorial : ℝ) *
        (Real.sqrt n * ρ) ^ (k + 1) * Real.exp (-(n / 4 : ℝ))) := by
  let r := k + 1
  let q (u : Fin (n-r) → ℝ) := lam * l1norm u / (4 * n) + 1 / 2
  let R := Real.sqrt n * ρ
  let T := {u : Fin (n-r) → ℝ | 2 * n < lam * l1norm u}
  let U := {θ | l2norm (NT r n (θ - θs)) ≤ R * q (diffOp r n θ)}
  let H := T.indicator (fun u => ENNReal.ofReal (Real.exp (α * q u)))
  have hn₀ : 0 < n := by omega
  have hn' : 0 < (n : ℝ) := by exact_mod_cast hn₀
  have hq : ∀ u, 0 ≤ q u := by
    intro u
    have hl : 0 ≤ l1norm u := Finset.sum_nonneg fun _ _ => abs_nonneg _
    dsimp [q]
    positivity
  have hqc : Continuous q := by dsimp [q]; unfold l1norm; fun_prop
  have hTm : MeasurableSet T := by dsimp [T]; unfold l1norm; exact measurableSet_lt measurable_const (by fun_prop)
  have hHm : Measurable H := (Real.measurable_exp.comp (measurable_const.mul hqc.measurable)).ennreal_ofReal.indicator hTm
  unfold Nmass
  rw [← lintegral_indicator hBm]
  calc
    _ ≤ ∫⁻ θ, U.indicator (fun θ => H (diffOp r n θ)) θ ∂nu r n lam := by
      apply lintegral_mono
      intro θ
      by_cases hθ : θ ∈ B
      · obtain ⟨hθT, hθR, hθL⟩ := hB θ hθ
        have hθU : θ ∈ U := by
          apply (norm_NT_le_empNorm (r := r) (by dsimp [r]; omega) hn θ θs).trans
          change _ ≤ R * q (diffOp r n θ)
          dsimp [R]
          rw [mul_assoc]
          exact mul_le_mul_of_nonneg_left hθR (Real.sqrt_nonneg _)
        dsimp only
        rw [Set.indicator_of_mem hθ, Set.indicator_of_mem hθU]
        unfold H
        rw [Set.indicator_of_mem (show diffOp r n θ ∈ T from hθT)]
        exact ENNReal.ofReal_le_ofReal (Real.exp_le_exp.mpr
          (by simpa only [q, neg_mul, neg_neg] using neg_le_neg hθL))
      · dsimp only
        rw [Set.indicator_of_notMem hθ]
        exact bot_le
    _ = Vr r * (∫⁻ u, ENNReal.ofReal ((R * q u) ^ r) * H u ∂Qlam (n-r) lam) :=
      vol_formula r n (by dsimp [r]; omega) hn lam hlam θs H hHm
        (fun u => R * q u) (measurable_const.mul hqc.measurable)
        (fun u => mul_nonneg (by dsimp [R]; positivity) (hq u))
    _ ≤ Vr r * (ENNReal.ofReal ((r.factorial : ℝ) * R ^ r) *
        ENNReal.ofReal (Real.exp (-(n / 4 : ℝ)))) := by
      apply mul_le_mul_right
      let f := T.indicator (fun u => ENNReal.ofReal (Real.exp ((α + 1) * q u)))
      calc
        _ ≤ ∫⁻ u, ENNReal.ofReal ((r.factorial : ℝ) * R ^ r) * f u ∂Qlam (n-r) lam := by
          apply lintegral_mono
          intro u
          by_cases hu : u ∈ T
          · dsimp only [H, f]
            rw [Set.indicator_of_mem hu, Set.indicator_of_mem hu,
              ← ENNReal.ofReal_mul' (Real.exp_nonneg _), ← ENNReal.ofReal_mul' (Real.exp_nonneg _)]
            apply ENNReal.ofReal_le_ofReal
            have h := (div_le_iff₀ (by positivity : 0 < (r.factorial : ℝ))).mp
              (Real.pow_div_factorial_le_exp (x := q u) (hq u) r)
            rw [mul_pow, show (α + 1) * q u = q u + α * q u by ring, Real.exp_add]
            calc
              _ ≤ (R ^ r * (Real.exp (q u) * (r.factorial : ℝ))) * Real.exp (α * q u) :=
                mul_le_mul_of_nonneg_right (mul_le_mul_of_nonneg_left h (by dsimp [R]; positivity))
                  (Real.exp_nonneg _)
              _ = _ := by ring
          · dsimp only [H, f]
            rw [Set.indicator_of_notMem hu, Set.indicator_of_notMem hu, mul_zero, mul_zero]
        _ ≤ _ := by
          rw [lintegral_const_mul' _ _ ENNReal.ofReal_ne_top]
          exact mul_le_mul_right (local_gamma_tail n r hn₀ hlam hαn) _
    _ = _ := by rw [← ENNReal.ofReal_mul (by dsimp [R]; positivity)]

private theorem local_posterior_bound {k n : ℕ} {c L fl fu Vb τ CE : ℝ}
    (hn : k + 1 < n) (hc : 0 < c) (hL : 0 < L) (hfl : 0 < fl)
    {μ : Fin n → Measure ℝ} {θs : Fin n → ℝ}
    (hτ : 0 < τ ∧ τ < 1) (hdata : DataHyp k n τ μ θs L fl fu Vb)
    (hlocal : ∀ δ ∈ Kn k n c, ∀ i, |δ i| ≤ s0 L fl fu)
    (hρ : 0 < Real.sqrt (rhoSq (k + 1) n))
    (hε : 0 < Real.sqrt (epsSq (k + 1) n))
    (hV : c * Vb / (4 * Real.sqrt n) ≤ 1 / 2)
    (hαn : fl / 4 * n * rhoSq (k + 1) n + 1 ≤ n / 32)
    (hR₁ : 2 * Real.sqrt n * Real.sqrt (rhoSq (k + 1) n) /
        (fl / 4 * n * rhoSq (k + 1) n) ≤ Real.sqrt n * Real.sqrt (epsSq (k + 1) n) / 2)
    (hCE : CE * (n * epsSq (k + 1) n) ≤ (fl / 4 * n * rhoSq (k + 1) n) / 4)
    (hR₂ : (Real.sqrt n * Real.sqrt (rhoSq (k + 1) n)) ^ (k + 1) *
        Real.exp (CE * (n * epsSq (k + 1) n)) ≤
      (Real.sqrt n * Real.sqrt (epsSq (k + 1) n) / 2) ^ (k + 1) * Real.exp (n / 8))
    (y : Fin n → ℝ)
    (hy : y ∈ OmegaG k n c τ fl μ θs ∩ OmegaE k n τ (lamSeq c k n) θs CE) :
    posterior τ 1 (lamSeq c k n) k n y {θ | θ - θs ∉ Kn k n c} ≤
      ENNReal.ofReal (Nat.factorial (k + 1) *
        (Real.exp (-(fl * n * rhoSq (k + 1) n / 16)) + Real.exp (-(n / 8 : ℝ)))) := by
  let r := k + 1
  let ρ := Real.sqrt (rhoSq r n)
  let ε := Real.sqrt (epsSq r n)
  let α := fl / 4 * n * rhoSq r n
  let x := (n : ℝ) * epsSq r n
  let lam := lamSeq c k n
  let T := Tn r n lam
  let A := {θ | θ - θs ∉ Kn k n c}
  let A₁ := A ∩ {θ | TVr r n (θ - θs) / T ≤ empNorm (θ - θs) / ρ}
  let A₂ := A ∩ {θ | empNorm (θ - θs) / ρ < TVr r n (θ - θs) / T}
  let vr := Vr r
  let R₀ := Real.sqrt n * ε / 2
  let D := denomBound k n CE
  let u := diffOp r n
  have hn₀ : 0 < n := by omega
  have hn' : 0 < (n : ℝ) := by exact_mod_cast hn₀
  have hlam : 0 < lam := mul_pos hc (Real.rpow_pos_of_pos hn' _)
  have hT : 0 < T := by dsimp [T, Tn]; positivity
  have hα : 0 < α := by
    have h := Real.sqrt_pos.mp hρ
    dsimp [α]
    positivity
  have hA : MeasurableSet A :=
    ((isClosed_Kset r n ρ T).measurableSet.preimage (measurable_id.sub_const _)).compl
  have hA₁ : MeasurableSet A₁ := hA.inter (measurableSet_le
    (((continuous_TVr r n).measurable.comp (measurable_id.sub_const _)).div_const T)
    (((continuous_empNorm n).measurable.comp (measurable_id.sub_const _)).div_const ρ))
  have hA₂ : MeasurableSet A₂ := hA.inter (measurableSet_lt
    (((continuous_empNorm n).measurable.comp (measurable_id.sub_const _)).div_const ρ)
    (((continuous_TVr r n).measurable.comp (measurable_id.sub_const _)).div_const T))
  have hUnion : A = A₁ ∪ A₂ := by
    ext θ
    change θ ∈ A ↔ (θ ∈ A ∧ _) ∨ (θ ∈ A ∧ _)
    constructor
    · intro h
      exact (le_or_gt (TVr r n (θ - θs) / T) (empNorm (θ - θs) / ρ)).elim
        (fun h' => Or.inl ⟨h,h'⟩) (fun h' => Or.inr ⟨h,h'⟩)
    · rintro (⟨h,_⟩ | ⟨h,_⟩) <;> exact h
  have hRay (θ : Fin n → ℝ) (hθ : θ ∈ A) :=
    local_ray_bound hn₀ hL hfl hτ hdata hρ hT hlocal hy.1 (θ - θs) hθ
  have h₁ : Nmass r τ lam y θs A₁ ≤ vr * ENNReal.ofReal
      ((r.factorial : ℝ) * (2 * Real.sqrt n * ρ / α) ^ r * Real.exp (-α / 2)) := by
    apply local_mass_emp hn hlam hρ hα y θs hA₁
    intro θ hθ
    obtain ⟨htt, _, hLoss⟩ := hRay θ hθ.1
    have he : max (empNorm (θ - θs) / ρ) (TVr r n (θ - θs) / T) = empNorm (θ - θs) / ρ :=
      max_eq_left hθ.2
    rw [he] at htt
    exact ⟨(one_le_div hρ).mp htt.le, hLoss hθ.2⟩
  have h₂ : Nmass r τ lam y θs A₂ ≤ vr * ENNReal.ofReal
      ((r.factorial : ℝ) * (Real.sqrt n * ρ) ^ r * Real.exp (-(n / 4 : ℝ))) := by
    apply local_mass_tv hn hlam hρ hα.le hαn y θs hA₂
    intro θ hθ
    let δ := θ - θs
    let t := TVr r n δ / T
    let q := lam * l1norm (u θ) / (4 * n) + 1 / 2
    have he : max (empNorm δ / ρ) (TVr r n δ / T) = t :=
      max_eq_right hθ.2.le
    obtain ⟨htt, hLoss, _⟩ := hRay θ hθ.1
    rw [he] at htt hLoss
    have hTruth : TVr r n θs / T ≤ 1 / 2 := by
      apply (div_le_div_of_nonneg_right (show TVr r n θs ≤ Vb by
        dsimp [r]; rw [TVr_eq_TV]; exact hdata.signal) hT.le).trans
      dsimp [T, lam, r]
      rw [Asym.Tn_eq k n hn₀ c hc]
      have hp : 0 < Real.sqrt n := by positivity
      have heq : Vb / (4 / c * Real.sqrt n) = c * Vb / (4 * Real.sqrt n) := by
        field_simp
      rwa [heq]
    have hTri : TVr r n δ ≤ TVr r n θ + TVr r n θs := by
      unfold TVr
      rw [← mul_add]
      apply mul_le_mul_of_nonneg_left _ (by positivity)
      dsimp [δ]
      rw [diffOp_sub]
      unfold l1norm
      rw [← Finset.sum_add_distrib]
      exact Finset.sum_le_sum fun i _ => by
        simpa only [Pi.sub_apply, sub_zero, zero_sub, abs_neg] using
          abs_sub_le (u θ i) 0 (u θs i)
    have htheta : TVr r n θ / T = lam * l1norm (u θ) / (4 * n) := by
      dsimp [T, Tn, TVr, r, u]
      rw [pow_succ]
      field_simp
    have htq : t ≤ q := by
      have hh := div_le_div_of_nonneg_right hTri hT.le
      rw [add_div, htheta] at hh
      exact hh.trans (add_le_add_right hTruth _)
    have hgate : 2 * (n : ℝ) < lam * l1norm (u θ) := by
      have hq : 1 < q := htt.trans_le htq
      dsimp [q] at hq
      have h : (1 / 2 : ℝ) < lam * l1norm (u θ) / (4 * n) := by linarith
      have hh := (lt_div_iff₀ (by positivity : 0 < 4 * (n : ℝ))).mp h
      linarith
    have hρq : empNorm δ ≤ ρ * q := by
      rw [mul_comm]
      exact (div_le_iff₀ hρ).mp (hθ.2.le.trans htq)
    exact ⟨hgate, hρq, (mul_le_mul_of_nonpos_left htq (neg_nonpos.2 hα.le)).trans hLoss⟩
  have hDo : denomBound k n CE ≤ Nmass r τ lam y θs Set.univ := hy.2
  have hD : D = vr * ENNReal.ofReal (R₀ ^ r * Real.exp (-(CE * x))) := by
    change vr * ENNReal.ofReal (R₀ ^ r) * ENNReal.ofReal
      (Real.exp (-(CE * n * epsSq r n))) = _
    rw [ENNReal.ofReal_mul (show 0 ≤ R₀ ^ r by positivity), ← mul_assoc]
    rw [show -(CE * n * epsSq r n) = -(CE * x) by dsimp [x]; ring]
  let E₁ := Real.exp (-α / 4)
  let E₂ := Real.exp (-(n / 8 : ℝ))
  let Q := ENNReal.ofReal ((r.factorial : ℝ) * (E₁ + E₂))
  have hRad₁ : (2 * Real.sqrt n * ρ / α) ^ r * Real.exp (-α / 2) ≤
      (R₀ ^ r * Real.exp (-(CE * x))) * E₁ := by
    rw [mul_assoc (R₀ ^ r), ← Real.exp_add]
    exact mul_le_mul (pow_le_pow_left₀ (by positivity) hR₁ _)
      (Real.exp_le_exp.mpr (by
        have hh : CE * x ≤ α / 4 := hCE
        linarith only [hh])) (Real.exp_nonneg _) (by positivity)
  have hRad₂ : (Real.sqrt n * ρ) ^ r * Real.exp (-(n / 4 : ℝ)) ≤
      (R₀ ^ r * Real.exp (-(CE * x))) * E₂ := by
    have h := mul_le_mul_of_nonneg_right hR₂ (Real.exp_nonneg (-(n / 4) - CE * x))
    have hleft : (Real.sqrt n * ρ) ^ r * Real.exp (-(n / 4 : ℝ)) =
        ((Real.sqrt n * ρ) ^ r * Real.exp (CE * x)) * Real.exp (-(n / 4) - CE * x) := by
      rw [mul_assoc, ← Real.exp_add]
      congr 2
      ring
    have hright : (R₀ ^ r * Real.exp (-(CE * x))) * E₂ =
        (R₀ ^ r * Real.exp (n / 8)) * Real.exp (-(n / 4) - CE * x) := by
      dsimp [E₂]
      rw [mul_assoc, mul_assoc, ← Real.exp_add, ← Real.exp_add]
      congr 2
      ring
    rw [hleft, hright]
    exact h
  have hMass : Nmass r τ lam y θs A ≤ D * Q := by
    have hs : Nmass r τ lam y θs A ≤ Nmass r τ lam y θs A₁ + Nmass r τ lam y θs A₂ := by
      rw [hUnion]
      exact lintegral_union_le _ _ _
    apply hs.trans ((add_le_add h₁ h₂).trans _)
    rw [← mul_add, ← ENNReal.ofReal_add (by positivity) (by positivity)]
    rw [hD, mul_assoc vr]
    apply mul_le_mul_right
    rw [← ENNReal.ofReal_mul (by positivity : 0 ≤ R₀ ^ r * Real.exp (-(CE * x)))]
    apply ENNReal.ofReal_le_ofReal
    let F := R₀ ^ r * Real.exp (-(CE * x))
    calc
      _ = (r.factorial : ℝ) *
          ((2 * Real.sqrt n * ρ / α) ^ r * Real.exp (-α / 2) +
            (Real.sqrt n * ρ) ^ r * Real.exp (-(n / 4 : ℝ))) := by ring
      _ ≤ (r.factorial : ℝ) * (F * E₁ + F * E₂) :=
        mul_le_mul_of_nonneg_left (add_le_add hRad₁ hRad₂) (by positivity)
      _ = _ := by dsimp [F, Q]; ring
  have hD₀ : D ≠ 0 := by
    rw [hD]
    exact mul_ne_zero (Metric.measure_ball_pos _ _ one_pos).ne'
      (ENNReal.ofReal_pos.mpr (by dsimp [R₀]; positivity)).ne'
  have hDTop : D ≠ ∞ := by
    rw [hD]
    exact ENNReal.mul_ne_top measure_ball_ne_top ENNReal.ofReal_ne_top
  have hPost : posterior τ 1 lam k n y A ≤ Q := by
    rw [(posterior_eq_ratio k n hn τ lam hτ hlam y θs).2.2 _ hA, div_eq_mul_inv]
    calc
      _ ≤ (D * Q) * D⁻¹ := mul_le_mul' hMass (ENNReal.inv_le_inv.mpr hDo)
      _ = _ := by rw [mul_comm _ D⁻¹, ENNReal.inv_mul_cancel_left hD₀ hDTop]
  have he : -α / 4 = -(fl * n * rhoSq r n / 16) := by dsimp [α]; ring
  simpa only [Q, E₁, E₂, he] using hPost

/-- Proposition `pf:prop:local`. For every `C_E` (in use, the constant of `denominator`) there is
`n₂` such that for `n ≥ n₂` and every law and target satisfying the hypotheses:
(a) `sup_{δ ∈ K_n} ‖δ‖_∞ ≤ s_0`;
(b) `P(Ω_Gᶜ) ≤ 64/(f̲² n ρ_n²)`, and on `Ω_G ∩ Ω_E`,
`Π_λ(θ − θ* ∉ K_n ∣ y) ≤ r! {e^{−f̲ n ρ_n²/16} + e^{−n/8}}`.
(The paper's `n₂` depends on `(c, r, L, f̲, f̄, V̄)`; here also on `C_E`, which depends on those.) -/
theorem localization (k : ℕ) (hk : 1 ≤ k) (c L fl fu Vb : ℝ) (hc : 0 < c) (hL : 0 < L)
    (hfl : 0 < fl) (CE : ℝ) :
    ∃ n₂ : ℕ, k + 1 < n₂ ∧ ∀ n, n₂ ≤ n → ∀ τ : ℝ, 0 < τ → τ < 1 →
      ∀ (μ : Fin n → Measure ℝ) (θs : Fin n → ℝ), DataHyp k n τ μ θs L fl fu Vb →
        (∀ δ ∈ Kn k n c, ∀ i, |δ i| ≤ s0 L fl fu) ∧
        Measure.pi μ (OmegaG k n c τ fl μ θs)ᶜ
          ≤ ENNReal.ofReal (64 / (fl ^ 2 * n * rhoSq (k + 1) n)) ∧
        ∀ y ∈ OmegaG k n c τ fl μ θs ∩ OmegaE k n τ (lamSeq c k n) θs CE,
          posterior τ 1 (lamSeq c k n) k n y {θ | θ - θs ∉ Kn k n c}
            ≤ ENNReal.ofReal (Nat.factorial (k + 1) *
                (Real.exp (-(fl * n * rhoSq (k + 1) n / 16)) + Real.exp (-(n / 8 : ℝ)))) := by
  let r := k + 1
  have hr : 2 ≤ r := by dsimp [r]; omega
  obtain ⟨CI, hCI, hInterp⟩ := interp r hr
  let S := s0 L fl (max fl fu)
  have hS : 0 < S := by dsimp [S, s0]; positivity
  have hsmall : ∀ᶠ n : ℕ in Filter.atTop,
      CI * (Real.sqrt (rhoSq r n) +
        Real.sqrt (rhoSq r n) ^ ((2 * r - 2 : ℝ) / (2 * r - 1)) *
          Tn r n (lamSeq c k n) ^ ((1 : ℝ) / (2 * r - 1))) ≤ S := by
    have ht := (Asym.interpolation_factor_tendsto_zero k hk c hc).const_mul CI
    simp only [mul_zero] at ht
    exact ht.eventually (eventually_le_nhds hS)
  have hw := Asym.eventually_width_bound k hk c fl hc hfl
  have hrad := Asym.eventually_radial_bounds k hk c fl Vb CE hc hfl
  obtain ⟨N, hN⟩ := Filter.eventually_atTop.mp (hsmall.and (hw.and hrad))
  refine ⟨max N (r+1), (Nat.lt_succ_self r).trans_le (le_max_right _ _), ?_⟩
  intro n hn τ hτ₀ hτ₁ μ θs hdata
  obtain ⟨hsmall, ⟨hnr, hρ, hT, J, hJpos, hJm, hw⟩, hrad⟩ := hN n ((le_max_left _ _).trans hn)
  obtain ⟨_, hε, hV, hαn, hR₁, hCE, hR₂⟩ := hrad
  have hfu : fl ≤ fu := by
    let i : Fin n := ⟨0, by omega⟩
    have ha := hdata.assA i L (by simp [abs_of_pos hL])
    have hb := hdata.assB i L (by simp [abs_of_pos hL])
    have h := ha.trans hb
    rw [abs_of_pos hL] at h
    exact (mul_le_mul_iff_of_pos_right hL).mp h
  have hlocal (δ : Fin n → ℝ) (hδ : δ ∈ Kn k n c) (i : Fin n) : |δ i| ≤ s0 L fl fu := by
    apply (hInterp n hnr δ i).trans
    have hSeq : S = s0 L fl fu := by dsimp [S]; rw [max_eq_right hfu]
    rw [← hSeq]
    apply le_trans _ hsmall
    have hδ' : empNorm δ ≤ Real.sqrt (rhoSq r n) ∧ TVr r n δ ≤ Tn r n (lamSeq c k n) := hδ
    have hr' : (2 : ℝ) ≤ r := by exact_mod_cast hr
    have hpos : (0 : ℝ) < 2 * r - 1 := by linarith
    have hnonneg : (0 : ℝ) ≤ 2 * r - 2 := by linarith
    apply mul_le_mul_of_nonneg_left _ hCI.le
    apply add_le_add hδ'.1
    exact mul_le_mul
      (Real.rpow_le_rpow (empNorm_nonneg _) hδ'.1 (div_nonneg hnonneg hpos.le))
      (Real.rpow_le_rpow (TVr_nonneg _) hδ'.2 (by positivity))
      (Real.rpow_nonneg (TVr_nonneg _) _) (Real.rpow_nonneg hρ.le _)
  refine ⟨hlocal, local_event_probability hk hnr hfl ⟨hτ₀,hτ₁⟩ hdata hρ hT hJpos hJm hw, ?_⟩
  exact local_posterior_bound hnr hc hL hfl ⟨hτ₀,hτ₁⟩ hdata hlocal hρ hε hV hαn hR₁ hCE hR₂

end BQTF
