import BQTF.Basic

/-!
# Rademacher integrals as finite averages over the sign cube

`rademacher n` is the uniform law on `{−1, 1}ⁿ`, so `∫ g ∂(rademacher n)` is the average of `g`
over the cube, for every `g` (no measurability needed: the law is a finite sum of Diracs).
-/

open MeasureTheory ProbabilityTheory Finset
open scoped ENNReal

noncomputable section

namespace BQTF.Prob

/-- The sign cube `{−1, 1}ⁿ ⊆ ℝⁿ`. -/
def signCube (n : ℕ) : Finset (Fin n → ℝ) := Fintype.piFinset fun _ => ({-1, 1} : Finset ℝ)

lemma mem_signCube {n : ℕ} {ε : Fin n → ℝ} : ε ∈ signCube n ↔ ∀ i, ε i = -1 ∨ ε i = 1 := by
  simp [signCube]

lemma rademacher_eq_sum_dirac (n : ℕ) :
    rademacher n = ∑ ε ∈ signCube n, ((2 : ℝ≥0∞) ^ n)⁻¹ • Measure.dirac ε := by
  have h1 : rademacher1 = ∑ x ∈ ({-1, 1} : Finset ℝ), (2 : ℝ≥0∞)⁻¹ • Measure.dirac x := by
    rw [Finset.sum_pair (by norm_num), ← smul_add, rademacher1, one_div]
  have : IsFiniteMeasure rademacher1 := ⟨by simp [rademacher1]⟩
  unfold rademacher
  refine Measure.pi_eq fun s _ => ?_
  simp only [Measure.coe_finsetSum, Finset.sum_apply, Measure.smul_apply, smul_eq_mul,
    Measure.dirac_apply, h1]
  have hprod : ∀ ε : Fin n → ℝ, (Set.univ.pi s).indicator (1 : (Fin n → ℝ) → ℝ≥0∞) ε =
      ∏ i, (s i).indicator (1 : ℝ → ℝ≥0∞) (ε i) := by
    intro ε
    simp only [Set.indicator, Set.mem_univ_pi, Pi.one_apply]
    split_ifs with h
    · exact (Finset.prod_eq_one fun i _ => by simp [h i]).symm
    · simp only [Set.mem_univ_pi, not_forall] at h
      obtain ⟨i, hi⟩ := h
      exact (Finset.prod_eq_zero (Finset.mem_univ i) (by simp [hi])).symm
  simp_rw [hprod, ← Finset.mul_sum, Finset.prod_mul_distrib, Finset.prod_const,
    Finset.card_univ, Fintype.card_fin, ENNReal.inv_pow]
  congr 1
  rw [signCube, Finset.prod_univ_sum]

/-- `∫ g ∂(rademacher n) = 2^{−n} ∑_{ε ∈ {−1,1}ⁿ} g ε`, for every `g`. -/
lemma integral_rademacher (n : ℕ) (g : (Fin n → ℝ) → ℝ) :
    ∫ ξ, g ξ ∂(rademacher n) = ((2 : ℝ) ^ n)⁻¹ * ∑ ε ∈ signCube n, g ε := by
  rw [rademacher_eq_sum_dirac, integral_finsetSum_measure]
  · simp only [integral_smul_measure, integral_dirac, smul_eq_mul, Finset.mul_sum]
    congr 1; ext ε
    simp [ENNReal.toReal_inv, ENNReal.toReal_pow]
  · intro ε _
    exact (integrable_dirac (by simp)).smul_measure (by simp)

end BQTF.Prob
