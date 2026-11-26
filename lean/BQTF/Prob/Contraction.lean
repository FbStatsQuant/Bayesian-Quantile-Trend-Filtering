import BQTF.Basic
import BQTF.Prob.Contraction.Compare

/-!
# Ledoux–Talagrand contraction principle (absolute-value form)

For a finite symmetric nonempty `T ⊆ ℝⁿ` and 1-Lipschitz `φ_i` with `φ_i(0) = 0`,
`E max_{δ ∈ T} |∑ ξ_i φ_i(δ_i)| ≤ 2 E max_{δ ∈ T} ⟨ξ, δ⟩` for Rademacher `ξ`
(Ledoux–Talagrand, *Probability in Banach Spaces*, Thm 4.12; Boucheron–Lugosi–Massart Thm 11.6).

Route: the integrals are averages over `{−1,1}ⁿ` (`integral_rademacher`); with `T₀ = T ∪ {0}`,
`max_T |X| ≤ max_{T₀} X + max_{T₀} (−X)`; the two terms have the same average by `ξ ↦ −ξ`;
the one-sided comparison `cubeSup_comparison` removes the `φ_i`; and `max_{T₀} ⟨ξ,·⟩ = max_T ⟨ξ,·⟩`
because `T` is symmetric.
-/

open MeasureTheory ProbabilityTheory

namespace BQTF.Prob

theorem contraction_abs {n : ℕ} (T : Finset (Fin n → ℝ)) (hT : T.Nonempty)
    (hsymm : ∀ δ ∈ T, -δ ∈ T) (φ : Fin n → ℝ → ℝ) (hφ0 : ∀ i, φ i 0 = 0)
    (hφL : ∀ i u v, |φ i u - φ i v| ≤ |u - v|) :
    ∫ ξ, T.sup' hT (fun δ => |∑ i, ξ i * φ i (δ i)|) ∂(rademacher n) ≤
      2 * ∫ ξ, T.sup' hT (fun δ => dot ξ δ) ∂(rademacher n) := by
  classical
  rw [integral_rademacher, integral_rademacher]
  set f : (Fin n → ℝ) → (Fin n → ℝ) → ℝ := fun ε δ => ∑ i, ε i * φ i (δ i) with hf
  set T₀ := insert (0 : Fin n → ℝ) T
  have h0 : T₀.Nonempty := Finset.insert_nonempty _ _
  have hf0 : ∀ ε, f ε 0 = 0 := fun ε => by simp [hf, hφ0]
  -- (a) `max_T |X| ≤ max_{T₀} X + max_{T₀} (−X)`
  have ha : ∀ ε, T.sup' hT (fun δ => |f ε δ|) ≤
      T₀.sup' h0 (f ε) + T₀.sup' h0 (fun δ => -f ε δ) := by
    intro ε
    refine Finset.sup'_le _ _ fun δ hδ => ?_
    have hδ0 : δ ∈ T₀ := Finset.mem_insert_of_mem hδ
    have hz : (0 : Fin n → ℝ) ∈ T₀ := Finset.mem_insert_self _ _
    have h1 := T₀.le_sup' (f ε) hδ0
    have h2 := T₀.le_sup' (fun δ => -f ε δ) hδ0
    have h3 := T₀.le_sup' (f ε) hz
    have h4 := T₀.le_sup' (fun δ => -f ε δ) hz
    simp only [hf0, neg_zero] at h1 h2 h3 h4
    rw [abs_le]
    constructor <;> linarith
  -- (b) symmetry `ξ ↦ −ξ` of the cube
  have hb : ∑ ε ∈ signCube n, T₀.sup' h0 (fun δ => -f ε δ) =
      ∑ ε ∈ signCube n, T₀.sup' h0 (f ε) := by
    refine Finset.sum_nbij' (fun ε => -ε) (fun ε => -ε) (fun ε hε => ?_) (fun ε hε => ?_)
      (fun ε _ => neg_neg ε) (fun ε _ => neg_neg ε) (fun ε _ => ?_)
    · rw [mem_signCube] at hε ⊢
      intro i; rcases hε i with h | h <;> simp [h]
    · rw [mem_signCube] at hε ⊢
      intro i; rcases hε i with h | h <;> simp [h]
    · congr 1; funext δ
      simp [hf, Finset.sum_neg_distrib]
  -- (c) one-sided comparison
  have hc := cubeSup_comparison T₀ h0 φ hφL
  -- (d) `max_{T₀} ⟨ξ,·⟩ = max_T ⟨ξ,·⟩`
  have hd : ∀ ε, T₀.sup' h0 (fun δ => dot ε δ) = T.sup' hT (fun δ => dot ε δ) := by
    intro ε
    rw [Finset.sup'_insert (H := hT)]
    obtain ⟨δ, hδ⟩ := id hT
    have h1 := T.le_sup' (fun δ => dot ε δ) hδ
    have h2 := T.le_sup' (fun δ => dot ε δ) (hsymm δ hδ)
    have hneg : dot ε (-δ) = -dot ε δ := by simp [dot, Finset.sum_neg_distrib]
    simp only [hneg] at h2
    have hz : dot ε 0 = 0 := by simp [dot]
    rw [hz]
    exact max_eq_right (by linarith)
  have hsum : ∑ ε ∈ signCube n, T.sup' hT (fun δ => |f ε δ|) ≤
      2 * ∑ ε ∈ signCube n, T.sup' hT (fun δ => dot ε δ) := by
    calc ∑ ε ∈ signCube n, T.sup' hT (fun δ => |f ε δ|)
        ≤ ∑ ε ∈ signCube n, (T₀.sup' h0 (f ε) + T₀.sup' h0 (fun δ => -f ε δ)) :=
          Finset.sum_le_sum fun ε _ => ha ε
      _ = 2 * ∑ ε ∈ signCube n, T₀.sup' h0 (f ε) := by
          rw [Finset.sum_add_distrib, hb]; ring
      _ ≤ 2 * ∑ ε ∈ signCube n, T₀.sup' h0 (fun δ => dot ε δ) := by
          gcongr
      _ = 2 * ∑ ε ∈ signCube n, T.sup' hT (fun δ => dot ε δ) := by
          simp_rw [hd]
  have hc2 : (0 : ℝ) ≤ ((2 : ℝ) ^ n)⁻¹ := by positivity
  calc ((2 : ℝ) ^ n)⁻¹ * ∑ ε ∈ signCube n, T.sup' hT (fun δ => |f ε δ|)
      ≤ ((2 : ℝ) ^ n)⁻¹ * (2 * ∑ ε ∈ signCube n, T.sup' hT (fun δ => dot ε δ)) :=
        mul_le_mul_of_nonneg_left hsum hc2
    _ = _ := by ring

end BQTF.Prob
