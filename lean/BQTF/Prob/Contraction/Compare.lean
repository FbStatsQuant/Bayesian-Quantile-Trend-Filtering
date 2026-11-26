import BQTF.Prob.Contraction.Cube

/-!
# One-sided comparison over the sign cube

For a finite nonempty `S ⊆ ℝⁿ` and 1-Lipschitz `φ_i`,
`∑_{ε ∈ {−1,1}ⁿ} max_{t ∈ S} ∑_i ε_i φ_i(t_i) ≤ ∑_{ε ∈ {−1,1}ⁿ} max_{t ∈ S} ⟨ε, t⟩`
(Ledoux–Talagrand, Thm 4.12, with `F = id`). The contractions are replaced by the identity one
coordinate at a time; each step pairs `ε` with `ε` flipped at that coordinate.
-/

open Finset

noncomputable section

namespace BQTF.Prob

/-- Two-point inequality: if `|f s − f t| ≤ |g s − g t|` on `S`, then
`max(A + f) + max(A − f) ≤ max(A + g) + max(A − g)`. -/
lemma sup'_add_sup'_sub_le {β : Type*} (S : Finset β) (hS : S.Nonempty) (A f g : β → ℝ)
    (h : ∀ s ∈ S, ∀ t ∈ S, |f s - f t| ≤ |g s - g t|) :
    S.sup' hS (fun t => A t + f t) + S.sup' hS (fun t => A t - f t) ≤
      S.sup' hS (fun t => A t + g t) + S.sup' hS (fun t => A t - g t) := by
  obtain ⟨s, hs, hs'⟩ := S.exists_mem_eq_sup' hS (fun t => A t + f t)
  obtain ⟨t, ht, ht'⟩ := S.exists_mem_eq_sup' hS (fun t => A t - f t)
  rw [hs', ht']
  have hfst : f s - f t ≤ |g s - g t| := (le_abs_self _).trans (h s hs t ht)
  have h1 := S.le_sup' (fun t => A t + g t) hs
  have h2 := S.le_sup' (fun t => A t - g t) ht
  have h3 := S.le_sup' (fun t => A t + g t) ht
  have h4 := S.le_sup' (fun t => A t - g t) hs
  rcases le_total (g t) (g s) with hg | hg
  · rw [abs_of_nonneg (by linarith)] at hfst
    linarith
  · rw [abs_of_nonpos (by linarith)] at hfst
    linarith

/-- Flip the sign of coordinate `k`. -/
def flipAt {n : ℕ} (k : Fin n) (ε : Fin n → ℝ) : Fin n → ℝ := Function.update ε k (-ε k)

lemma flipAt_flipAt {n : ℕ} (k : Fin n) (ε : Fin n → ℝ) : flipAt k (flipAt k ε) = ε := by
  simp [flipAt]

lemma flipAt_mem {n : ℕ} (k : Fin n) {ε : Fin n → ℝ} (hε : ε ∈ signCube n) :
    flipAt k ε ∈ signCube n := by
  rw [mem_signCube] at hε ⊢
  intro i
  by_cases hi : i = k
  · subst hi
    rcases hε i with h | h <;> simp [flipAt, h]
  · simpa [flipAt, Function.update_of_ne hi] using hε i

lemma sum_signCube_flipAt {n : ℕ} (k : Fin n) (G : (Fin n → ℝ) → ℝ) :
    ∑ ε ∈ signCube n, G (flipAt k ε) = ∑ ε ∈ signCube n, G ε :=
  Finset.sum_nbij' (flipAt k) (flipAt k) (fun _ h => flipAt_mem k h) (fun _ h => flipAt_mem k h)
    (fun ε _ => flipAt_flipAt k ε) (fun ε _ => flipAt_flipAt k ε) (fun _ _ => rfl)

/-- `Q S ψ = ∑_{ε ∈ cube} max_{t ∈ S} ∑_i ε_i ψ_i(t_i)`. -/
def cubeSup {n : ℕ} (S : Finset (Fin n → ℝ)) (hS : S.Nonempty) (ψ : Fin n → ℝ → ℝ) : ℝ :=
  ∑ ε ∈ signCube n, S.sup' hS fun t => ∑ i, ε i * ψ i (t i)

/-- One step: replacing a 1-Lipschitz `ψ_k` by the identity does not decrease `cubeSup`. -/
lemma cubeSup_le_update {n : ℕ} (S : Finset (Fin n → ℝ)) (hS : S.Nonempty)
    (ψ : Fin n → ℝ → ℝ) (k : Fin n) (hk : ∀ u v, |ψ k u - ψ k v| ≤ |u - v|) :
    cubeSup S hS ψ ≤ cubeSup S hS (Function.update ψ k id) := by
  set ψ' := Function.update ψ k id
  -- the part of the sum away from `k`
  let A : (Fin n → ℝ) → (Fin n → ℝ) → ℝ := fun ε t => ∑ i ∈ univ.erase k, ε i * ψ i (t i)
  have hsplit : ∀ (χ : Fin n → ℝ → ℝ), (∀ i ≠ k, χ i = ψ i) → ∀ ε t,
      ∑ i, ε i * χ i (t i) = A ε t + ε k * χ k (t k) ∧
      ∑ i, flipAt k ε i * χ i (t i) = A ε t - ε k * χ k (t k) := by
    intro χ hχ ε t
    have hA : ∀ e : Fin n → ℝ, (∀ i ≠ k, e i = ε i) →
        ∑ i, e i * χ i (t i) = A ε t + e k * χ k (t k) := by
      intro e he
      rw [← Finset.add_sum_erase _ _ (Finset.mem_univ k), add_comm]
      congr 1
      refine Finset.sum_congr rfl fun i hi => ?_
      have hik := Finset.ne_of_mem_erase hi
      rw [he i hik, hχ i hik]
    refine ⟨hA ε fun _ _ => rfl, ?_⟩
    rw [hA (flipAt k ε) fun i hi => by simp [flipAt, Function.update_of_ne hi]]
    simp [flipAt]
    ring
  have hψ := hsplit ψ fun _ _ => rfl
  have hψ' := hsplit ψ' fun i hi => Function.update_of_ne hi _ _
  have key : ∀ ε, (S.sup' hS fun t => ∑ i, ε i * ψ i (t i)) +
      (S.sup' hS fun t => ∑ i, flipAt k ε i * ψ i (t i)) ≤
      (S.sup' hS fun t => ∑ i, ε i * ψ' i (t i)) +
      (S.sup' hS fun t => ∑ i, flipAt k ε i * ψ' i (t i)) := by
    intro ε
    simp_rw [fun t => (hψ ε t).1, fun t => (hψ ε t).2, fun t => (hψ' ε t).1,
      fun t => (hψ' ε t).2]
    refine sup'_add_sup'_sub_le S hS (A ε) _ _ fun s _ t _ => ?_
    simp only [ψ', Function.update_self, id]
    rw [← mul_sub, ← mul_sub, abs_mul, abs_mul]
    exact mul_le_mul_of_nonneg_left (hk _ _) (abs_nonneg _)
  have e1 := sum_signCube_flipAt k fun ε => S.sup' hS fun t => ∑ i, ε i * ψ i (t i)
  have e2 := sum_signCube_flipAt k fun ε => S.sup' hS fun t => ∑ i, ε i * ψ' i (t i)
  have hsum := Finset.sum_le_sum fun ε (_ : ε ∈ signCube n) => key ε
  rw [Finset.sum_add_distrib, Finset.sum_add_distrib] at hsum
  unfold cubeSup
  linarith

/-- One-sided comparison with factor 1 (Ledoux–Talagrand Thm 4.12, `F = id`). -/
theorem cubeSup_comparison {n : ℕ} (S : Finset (Fin n → ℝ)) (hS : S.Nonempty)
    (φ : Fin n → ℝ → ℝ) (hφL : ∀ i u v, |φ i u - φ i v| ≤ |u - v|) :
    (∑ ε ∈ signCube n, S.sup' hS fun t => ∑ i, ε i * φ i (t i)) ≤
      ∑ ε ∈ signCube n, S.sup' hS fun t => dot ε t := by
  classical
  let ψK : Finset (Fin n) → Fin n → ℝ → ℝ := fun K i => if i ∈ K then id else φ i
  have hind : ∀ K : Finset (Fin n), cubeSup S hS φ ≤ cubeSup S hS (ψK K) := by
    intro K
    induction K using Finset.induction_on with
    | empty => exact le_of_eq (congrArg _ (funext fun i => by simp [ψK]))
    | insert a K ha ih =>
      refine ih.trans ((cubeSup_le_update S hS (ψK K) a ?_).trans (le_of_eq ?_))
      · intro u v; simpa [ψK, ha] using hφL a u v
      · congr 1
        funext i
        by_cases hi : i = a
        · subst hi; simp [ψK]
        · simp [ψK, hi]
  have := hind univ
  have hu : ψK univ = fun _ => id := by funext i; simp [ψK]
  rw [hu] at this
  simpa [cubeSup, dot] using this

end BQTF.Prob
