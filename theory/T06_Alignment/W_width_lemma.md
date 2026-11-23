# Lemma W: Rademacher width of the TV⁽³⁾ ∩ ℓ₂ body (in-house, via L3's singular values)

*Theory Department, 2026-11-23. Status: **PROVED; advisor-checked (Astra: ACCEPT, `reviews/AUDIT_astra_C1_W.md`)**. Used by route C1 of `../ALIGNMENT_MEMO.md`.*

## Statement

Let ε₁, …, εₙ be independent, mean zero, with |εᵢ| ≤ 1 (for example Rademacher). For ρ > 0 and T₀ > 0 let

  K(ρ, T₀) := {δ ∈ ℝⁿ : ‖δ‖ₙ ≤ ρ, n²‖Dδ‖₁ ≤ T₀},  D = D⁽³⁾, m = n − 3.

Then for every integer 1 ≤ k ≤ m,

  E sup_{δ∈K(ρ,T₀)} ⟨ε, δ⟩ ≤ √n·ρ·(√3 + √k) + 40.8·√(2 log(2m))·T₀·n·k^{−5/2}.

Choosing k = ⌈(T₀√n/ρ)^{1/3}⌉ ∧ m gives

  **E sup_K ⟨ε, δ⟩ ≲ √n·ρ + n^{7/12}·ρ^{5/6}·T₀^{1/6}·√log n.**

**Comparison.** The entropy (Dudley) bound for this class is √n·ρ^{5/6}T₀^{1/6}. Lemma W loses a factor n^{1/12}, because it controls ‖u‖₁ through the crude ℓ₁/ℓ∞ duality, but it needs no external entropy result.

## Proof

1. **Decomposition.** Write δ = Nc + Su with u = Dδ (L5), so that P_Nδ = N·Nᵀδ and P⊥δ = P⊥Su = √n·A·u, with A := n^{−1/2}P⊥S (L3). Then

   ⟨ε, δ⟩ = ⟨P_Nε, δ⟩ + ⟨ε, √n A u⟩.

2. **Null-space part.** |⟨P_Nε, δ⟩| ≤ ‖P_Nε‖₂‖δ‖₂ ≤ ‖P_Nε‖₂·√n ρ. Since E‖P_Nε‖₂ ≤ (E‖P_Nε‖₂²)^{1/2} ≤ √(tr P_N) = √3, this part contributes ≤ √3·√n ρ.

3. **Singular-value split.** Let A = Σ_r σ_r a_r b_rᵀ, with (a_r) orthonormal in ℝⁿ, (b_r) orthonormal in ℝᵐ and σ₁ ≥ σ₂ ≥ … Let P_k project onto span(a₁, …, a_k), and set A_{>k} := Σ_{r>k} σ_r a_r b_rᵀ. Then √nAu = P_k(P⊥δ) + √n·A_{>k}u.

4. **Head.** |⟨ε, P_k P⊥δ⟩| ≤ ‖P_kε‖₂·‖P⊥δ‖₂ ≤ ‖P_kε‖₂·√n ρ, with E‖P_kε‖₂ ≤ √k.

5. **Tail.** |⟨ε, √nA_{>k}u⟩| = √n|⟨A_{>k}ᵀε, u⟩| ≤ √n‖u‖₁·‖A_{>k}ᵀε‖∞ ≤ √n·(T₀/n²)·‖A_{>k}ᵀε‖∞.
   - Each coordinate (A_{>k}ᵀε)_j = Σᵢ (A_{>k})_{ij}εᵢ is sub-Gaussian (Hoeffding) with variance proxy Σᵢ(A_{>k})_{ij}² = Σ_{r>k}σ_r² b_r(j)² ≤ Σ_{r>k}σ_r².
   - By L3, Step 4 (advisor-checked), σ_r ≤ 91.2·n^{5/2}r^{−3}, so Σ_{r>k}σ_r² ≤ 91.2²n⁵·Σ_{r>k}r^{−6} ≤ 91.2²n⁵/(5k⁵).
   - The maximal inequality for m sub-Gaussians gives E‖A_{>k}ᵀε‖∞ ≤ √(2 log(2m))·91.2·n^{5/2}k^{−5/2}/√5.
   - Hence the tail contributes ≤ √(2 log(2m))·(91.2/√5)·T₀·n·k^{−5/2}, and 91.2/√5 ≤ 40.8.

6. **Sum.** Adding steps 2, 4 and 5 gives the bound.

7. **Choice of k.** With k = ⌈(T₀√n/ρ)^{1/3}⌉, the head √n ρ√k and the tail T₀nk^{−5/2} are of the same order, n^{7/12}ρ^{5/6}T₀^{1/6}. Capping k at m only lowers the tail (it vanishes at k = m). ∎

## Use in route C1 (any fixed σ): the empirical-process bound

Let G := sup_{δ∈K}|ℛ(δ) − M(δ)|, with ℛ(δ) = Σᵢ Xᵢ(δᵢ) and M = E₀ℛ (L2).
- Each Xᵢ(t) = ρ_τ(Zᵢ − t) − ρ_τ(Zᵢ) is 1-Lipschitz in t, with Xᵢ(0) = 0.
- Symmetrization, then the Ledoux–Talagrand contraction principle applied conditionally on Z, give

  E G ≤ 2·E sup_K |Σεᵢ Xᵢ(δᵢ)| ≤ 4·E sup_K ⟨ε, δ⟩   (K is symmetric),

  which Lemma W bounds.
- Bousquet's inequality, with envelope ≤ 2 sup_K‖δ‖∞ and wimpy variance ≤ sup_K Σδᵢ² ≤ nρ², gives the deviation.

All of this is **moment-free**: the Xᵢ are bounded by |δᵢ|.

**Remarks after the audit (Astra, finding 6).**
- *Rounding.* Put q := (T₀√n/ρ)^{1/3}. Take k = 1 if q < 1 (then the tail is ≤ √n ρ√q); take q ≤ k ≤ 2q if 1 ≤ q ≤ m; take k = m if q > m (then the tail vanishes and √m ≤ √q). The displayed order bound holds in every case.
- *Entropy comparison.* For the full body, the entropy (Dudley) bound must include the null-space term of order √n ρ, as Lemma W does.
