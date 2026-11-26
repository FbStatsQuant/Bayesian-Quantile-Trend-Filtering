import BQTF.Joint.SupNorm
import BQTF.Scale.Data

/-!
# Supremum-norm concentration at a general scale (proof of `thm:joint`, "General scales")

Owner: TBD (assigned at the Theorem 2 trigger).

Lemma `pf:lem:sup` at scale `σ₀ > 0`, via the reduction of Appendix `pf:sec:reduction`
(`posterior_map_inv_smul`, `DataHyp.scale`): the law of `θ/σ₀` under `Π(· ∣ y)` is the `σ = 1`
posterior based on `y/σ₀` with `c` replaced by `σ₀c`, and the rescaled data satisfy `DataHyp`
with `(L/σ₀, σ₀f̲, σ₀f̄, V̄/σ₀)`. Theory's answers (PLAN §5.5 item 2):
* `s′_n = supRad C_I k (σ₀c) n` depends on `(σ₀c, r)`; in original units the radius is `σ₀ s′_n`;
* `η′_n = etaSeq k (σ₀f̲) n` depends on `(σ₀f̲, r)`;
* `n₂′` depends on `(σ₀c, r, L/σ₀, σ₀f̲, σ₀f̄, V̄/σ₀)`;
* `P(Ωᶜ) ≤ {5/4 + 64/(σ₀f̲)²} n^{−1/(2r)}`.

`C_I` is the same constant as in `supNorm_concentration` (it comes from `interp` and depends on
`k` only); it is quantified before `σ₀` here.

Nonvacuity: as in `Joint/SupNorm`, with any `σ₀ > 0` (the hypotheses on the data do not involve
`σ₀`).
-/

open MeasureTheory ProbabilityTheory
open scoped ENNReal

noncomputable section

namespace BQTF

/-- Lemma `pf:lem:sup` at scale `σ₀` ("General scales" paragraph of the proof of `thm:joint`).
There is `C_I > 0` depending only on `k` such that for all `σ₀, c, L, f̲ > 0`, `f̄`, `V̄` there is
`n₂ > k + 1` with: for every `n ≥ n₂`, `τ ∈ (0,1)` and law/target with `DataHyp` (original
units), some event `Ω` satisfies
* `Π_{σ₀,λ}(θ : ‖θ − θ*‖_∞ > σ₀ s′_n ∣ y) ≤ η′_n` on `Ω`, with `s′_n = supRad C_I k (σ₀c) n`,
  `η′_n = etaSeq k (σ₀f̲) n`, and
* `P(Ωᶜ) ≤ {5/4 + 64/(σ₀f̲)²} n^{−1/(2r)}`. -/
theorem supNorm_concentration_scale (k : ℕ) (hk : 1 ≤ k) :
    ∃ CI : ℝ, 0 < CI ∧ ∀ (σ₀ c L fl fu Vb : ℝ), 0 < σ₀ → 0 < c → 0 < L → 0 < fl →
      ∃ n₂ : ℕ, k + 1 < n₂ ∧ ∀ n, n₂ ≤ n → ∀ τ : ℝ, 0 < τ → τ < 1 →
        ∀ (μ : Fin n → Measure ℝ) (θs : Fin n → ℝ), DataHyp k n τ μ θs L fl fu Vb →
          ∃ Ω : Set (Fin n → ℝ),
            (∀ y ∈ Ω, posterior τ σ₀ (lamSeq c k n) k n y
                {θ | ∃ i, σ₀ * supRad CI k (σ₀ * c) n < |θ i - θs i|}
                  ≤ ENNReal.ofReal (etaSeq k (σ₀ * fl) n)) ∧
            Measure.pi μ Ωᶜ
              ≤ ENNReal.ofReal ((5 / 4 + 64 / (σ₀ * fl) ^ 2) * massRate k n) := by
  obtain ⟨CI, hCI, hunit⟩ := supNorm_concentration k hk
  refine ⟨CI, hCI, ?_⟩
  intro σ₀ c L fl fu Vb hσ hc hL hfl
  obtain ⟨n₂, hn₂, hconc⟩ :=
    hunit (σ₀ * c) (L / σ₀) (σ₀ * fl) (σ₀ * fu) (Vb / σ₀)
      (mul_pos hσ hc) (div_pos hL hσ) (mul_pos hσ hfl)
  refine ⟨n₂, hn₂, ?_⟩
  intro n hn τ hτ₀ hτ₁ μ θs hdata
  let e : (Fin n → ℝ) ≃ᵐ (Fin n → ℝ) :=
    (Homeomorph.smul (isUnit_iff_ne_zero.mpr (inv_ne_zero hσ.ne')).unit).toMeasurableEquiv
  obtain ⟨Ω', hpost, hprob⟩ :=
    hconc n hn τ hτ₀ hτ₁ (scaleData σ₀ μ) (σ₀⁻¹ • θs) (hdata.scale hσ)
  let s := supRad CI k (σ₀ * c) n
  have htail :
      e ⁻¹' {θ | ∃ i, s < |θ i - (σ₀⁻¹ • θs) i|} =
        {θ | ∃ i, σ₀ * s < |θ i - θs i|} := by
    ext θ
    simp only [Set.mem_preimage, Set.mem_ofPred_eq]
    apply exists_congr
    intro i
    change s < |σ₀⁻¹ * θ i - σ₀⁻¹ * θs i| ↔ σ₀ * s < |θ i - θs i|
    rw [← mul_sub, abs_mul, abs_of_pos (inv_pos.mpr hσ), ← div_eq_inv_mul,
      lt_div_iff₀ hσ, mul_comm s σ₀]
  refine ⟨e ⁻¹' Ω', ?_, ?_⟩
  · intro y hy
    have hpen : σ₀ * lamSeq c k n = lamSeq (σ₀ * c) k n := by
      simp only [lamSeq, mul_assoc]
    have hmap : (posterior τ σ₀ (lamSeq c k n) k n y).map e =
        posterior τ 1 (lamSeq (σ₀ * c) k n) k n (σ₀⁻¹ • y) := by
      rw [← hpen]
      exact posterior_map_inv_smul τ (lamSeq c k n) hσ k n y
    change posterior τ σ₀ (lamSeq c k n) k n y {θ | ∃ i, σ₀ * s < |θ i - θs i|} ≤ _
    rw [← htail, ← e.map_apply, hmap]
    exact hpost (e y) hy
  · have hmap : (Measure.pi μ).map e = Measure.pi (scaleData σ₀ μ) :=
      pi_scaleData σ₀ hdata.prob
    change Measure.pi μ (e ⁻¹' Ω'ᶜ) ≤ _
    rw [← e.map_apply, hmap]
    exact hprob

end BQTF
