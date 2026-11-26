import BQTF.Main
import BQTF.Scale.Data

/-!
# Reduction to `σ = 1` (appendix, Section `pf:sec:reduction`)

`θ = σ₀ θ′`: the law of `θ/σ₀` under the `σ₀`-posterior is the `σ = 1` posterior at
data `y/σ₀` with `c` replaced by `σ₀ c`; the rescaled data satisfy A, B with
`(L/σ₀, σ₀ f̲, σ₀ f̄)` and `V* ≤ V̄/σ₀`; `Δ²_n(σ₀ v) ≤ max{σ₀, σ₀²} Δ²_n(v)`.
-/

open MeasureTheory
open scoped ENNReal

namespace BQTF

private theorem lossΔ_smul_le {n : ℕ} {σ : ℝ} (hσ : 0 < σ) (v : Fin n → ℝ) :
    lossΔ (σ • v) ≤ max σ (σ ^ 2) * lossΔ v := by
  unfold lossΔ
  rw [← mul_div_assoc]
  apply div_le_div_of_nonneg_right _ (Nat.cast_nonneg n)
  rw [Finset.mul_sum]
  apply Finset.sum_le_sum
  intro i _
  simp only [Pi.smul_apply, smul_eq_mul, abs_mul, abs_of_pos hσ, mul_pow]
  rw [mul_min_of_nonneg _ _ (hσ.le.trans (le_max_left σ (σ ^ 2)))]
  exact min_le_min
    (mul_le_mul_of_nonneg_right (le_max_left _ _) (abs_nonneg _))
    (mul_le_mul_of_nonneg_right (le_max_right _ _) (sq_nonneg _))

private theorem measurableSet_farSet {n : ℕ} (k : ℕ) (θs : Fin n → ℝ) (M : ℝ) :
    MeasurableSet (farSet k θs M) := by
  have hc : Continuous (fun θ : Fin n → ℝ => lossΔ (θ - θs)) := by
    unfold lossΔ
    fun_prop
  exact measurableSet_lt measurable_const hc.measurable

/-- **Theorem `thm:main`, general scale `σ₀ > 0`.** -/
theorem main_theorem_scale : MainStatementScale := by
  intro k hk σ c L fl fu Vb hσ hc hL hfl
  obtain ⟨M, C, n₀, hM, hC, hmain⟩ :=
    main_theorem k hk (σ * c) (L / σ) (σ * fl) (σ * fu) (Vb / σ)
      (mul_pos hσ hc) (div_pos hL hσ) (mul_pos hσ hfl)
  let a := max σ (σ ^ 2)
  have ha : 0 < a := hσ.trans_le (le_max_left _ _)
  refine ⟨a * M, C, n₀, mul_pos ha hM, hC, ?_⟩
  intro n hn τ hτ₀ hτ₁ μ θs hdata
  let θs' := σ⁻¹ • θs
  let μ' := scaleData σ μ
  have hscaled := hmain n hn τ hτ₀ hτ₁ μ' θs' (hdata.scale hσ)
  have hsub : farSet k θs (a * M) ⊆ (σ⁻¹ • ·) ⁻¹' farSet k θs' M := by
    intro θ hθ
    change (a * M) * rate k n < lossΔ (θ - θs) at hθ
    change M * rate k n < lossΔ (σ⁻¹ • θ - θs')
    apply (mul_lt_mul_iff_right₀ ha).mp
    rw [← mul_assoc]
    refine hθ.trans_le ?_
    have hback : σ • (σ⁻¹ • θ - θs') = θ - θs := by
      dsimp [θs']
      rw [← smul_sub, smul_inv_smul₀ hσ.ne']
    simpa only [hback] using lossΔ_smul_le hσ (σ⁻¹ • θ - θs')
  have hf : Measurable (σ⁻¹ • · : (Fin n → ℝ) → (Fin n → ℝ)) :=
    measurable_const_smul _
  have hpen : σ * lamSeq c k n = lamSeq (σ * c) k n := by
    simp only [lamSeq, mul_assoc]
  refine ⟨measurable_posterior_apply τ σ (lamSeq c k n) k n (measurableSet_farSet _ _ _), ?_⟩
  calc
    (∫⁻ y, posterior τ σ (lamSeq c k n) k n y (farSet k θs (a * M)) ∂(Measure.pi μ))
        ≤ ∫⁻ y, posterior τ 1 (lamSeq (σ * c) k n) k n (σ⁻¹ • y) (farSet k θs' M)
            ∂(Measure.pi μ) := by
          apply lintegral_mono
          intro y
          change posterior τ σ (lamSeq c k n) k n y (farSet k θs (a * M)) ≤
            posterior τ 1 (lamSeq (σ * c) k n) k n (σ⁻¹ • y) (farSet k θs' M)
          rw [← hpen, ← posterior_map_inv_smul τ (lamSeq c k n) hσ k n y,
            Measure.map_apply hf (measurableSet_farSet _ _ _)]
          exact measure_mono hsub
    _ = ∫⁻ y, posterior τ 1 (lamSeq (σ * c) k n) k n y (farSet k θs' M)
          ∂(Measure.pi μ') := by
        rw [← pi_scaleData σ hdata.prob, lintegral_map hscaled.1 hf]
    _ ≤ ENNReal.ofReal (C * massRate k n) := hscaled.2

end BQTF
