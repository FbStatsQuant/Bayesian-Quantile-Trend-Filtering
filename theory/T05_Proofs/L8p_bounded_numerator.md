# Lemma L8′: exact-MGF inequality and the bounded-region numerator (Theorem A, Step 2)

**Status:** self-checked (2026-11-22). The proof is complete and elementary. The numerical check `checks/l8p_mgf.py` **passed** on all 14 valid rows (Engineering, NOTS job 2857877); see "Numerical check". Ready for the advisor check. Consistent with v3.1: A4 now requires the strict slack ω ≤ (1−η)ω̄ assumed here.
**Depends on:** L2 (the increment identity and margin), L5 (normalization, finite c-sections), L6 (the evidence bound).
**Used by:** SKELETON Step 2, i.e. Theorem A (σ ≥ σ̄). Theorem A⁺ replaces this lemma by L8-b.

## Setting

Notation as in L2:
- Zᵢ = yᵢ − θ\*ᵢ, with distribution function Fᵢ, and Fᵢ(0) = τ (L2, continuity at the target).
- Xᵢ(δ) = ρ_τ(Zᵢ − δ) − ρ_τ(Zᵢ), and mᵢ(δ) = E Xᵢ(δ).
- (A2) holds on [−L, L] with lower constant f.
- ω̄ := f/(τ(1−τ)), equivalently σ̄ = τ(1−τ)/f.

**No moment assumption is used:** every Xᵢ is bounded by |δ| (L2).

## Statement

**(a) Exact MGF.** For δ > 0,

  E e^{−ωXᵢ(δ)} = h_τ(ωδ) − ω e^{−ω(1−τ)δ} ∫₀^δ e^{ωs}(Fᵢ(s) − τ) ds,

where h_τ(t) := τe^{−(1−τ)t} + (1−τ)e^{τt} is the MGF of a centred two-point variable on {−(1−τ), τ}. For δ = −a < 0, the same formula holds with τ ↔ 1−τ in h, the prefactor e^{−ωτa}, and the integrand τ − Fᵢ(−s).

**(b) Per-coordinate inequality.** For every ω > 0, every Δ ∈ (0, L] and every |δ| ≤ Δ,

  log E e^{−ωXᵢ(δ)} ≤ −B(ω, Δ) · ω · mᵢ(δ),  where  B(ω, Δ) := e^{−ωΔ − ω²Δ²/8} − ω/ω̄ − 0.0321·ω²Δ/f.

In particular, if ω ≤ (1−η)ω̄ and Δ ≤ Δ₀, where Δ₀ is the largest Δ ≤ L with

  ω̄Δ·(1 + ω̄Δ/8 + 0.0321/(τ(1−τ))) ≤ η/2,

then B ≥ η/2.

**(c) Sharpness.** If Fᵢ has density f at 0 and ω > ω̄, then log E e^{−ωXᵢ(δ)} > 0 for all small δ ≠ 0. So the threshold ω̄ cannot be improved on this route. (This is the σ̄ statement of STATEMENT v2.1.)

**(d) Bounded-region numerator.** Let Δ ≤ min(1, L) and E₁ := {θ : ‖δ‖ₙ² > Mε², ‖δ‖∞ ≤ Δ}, with δ = θ − θ\*. (On E₁, Δ²ₙ(δ) = ‖δ‖ₙ², since Δ ≤ 1.) Then

  E₀ N(E₁) ≤ V₃(√n Δ)³ · exp{ −B ω (f/2) M nε² }.

**(e) Step 2 of Theorem A.** Combine (d) with L6, and assume the prior-mass bound −log Π_λ(u_h + B_{ε/2}) ≤ C_pr nε² (L3, L4q, L4q-M). Then

  E₀ Πₙ(E₁ | y) ≤ (2Δ/ε)³ · exp{ −[B f M/2 − (1.44C₁ + 1) − C_pr/ω] ω nε² } + 1.44/(nε²).

This tends to 0 whenever nε² → ∞ faster than log n and M > (2/(Bf))·[1.44C₁ + 2 + C_pr/ω].

## Proof

**(a)** Take δ > 0. By L2, Xᵢ = (1−τ)δ − W with W := clip(Zᵢ, 0, δ) ∈ [0, δ]. For a variable in [0, δ], e^{ωW} = 1 + ∫₀^δ ωe^{ωs}1{W > s} ds. For s < δ, {W > s} = {Zᵢ > s}. Hence

  E e^{ωW} = 1 + ω∫₀^δ e^{ωs}(1 − Fᵢ(s)) ds.

Write 1 − Fᵢ(s) = (1−τ) − Gᵢ(s), with Gᵢ(s) := Fᵢ(s) − τ ≥ 0. Then 1 + ω(1−τ)∫₀^δ e^{ωs} ds = τ + (1−τ)e^{ωδ}. Multiplying by e^{−ω(1−τ)δ} gives the formula.

For δ = −a < 0: by L2, Xᵢ = τa − clip(−Zᵢ, 0, a), and P(clip(−Zᵢ, 0, a) > s) = Fᵢ(−s−). Left limits do not matter inside the integral, and the same computation applies with τ ↔ 1−τ.

**(b)** Take δ > 0; the case δ < 0 is identical after τ ↔ 1−τ, because both the two-point law and the bounds below are symmetric under that swap. Write t := ωδ ∈ (0, ωΔ].

1. *The integral term.* Since e^{ωs} ≥ 1 and Gᵢ ≥ 0, ω∫₀^δ e^{ωs}Gᵢ(s) ds ≥ ω mᵢ(δ). This uses mᵢ(δ) = ∫₀^δ Gᵢ (L2).
2. *Logarithm.* Write E e^{−ωX} = h − a, with h := h_τ(t) ≥ 1 (Jensen; the two-point variable has mean 0) and a ≥ ω e^{−ω(1−τ)δ} mᵢ(δ). Since log(1 − x) ≤ −x,

  log E e^{−ωX} ≤ log h − a/h ≤ ψ(t) − ω mᵢ(δ) e^{−ωΔ} e^{−ω²Δ²/8},

  where ψ := log h_τ. Here we used e^{−ω(1−τ)δ} ≥ e^{−ωΔ}, and h ≤ e^{t²/8} (Hoeffding: the two-point variable has range 1).
3. *Cumulant bound.* ψ is the cumulant generating function of a two-point variable with gap 1, so ψ(0) = ψ′(0) = 0 and ψ″(0) = τ(1−τ). Moreover ψ‴(t) = q(1−q)(1−2q) for the tilted probability q = q(t) ∈ (0, 1). Its maximum over q is attained where q(1−q) = 1/6, which gives |ψ‴| ≤ 1/(6√3). By Taylor's theorem,

  ψ(t) ≤ τ(1−τ)t²/2 + |t|³/(36√3) ≤ ω²δ²[τ(1−τ)/2 + 0.01604·ωΔ].

4. *Margin.* For |δ| ≤ Δ ≤ L, L2 gives mᵢ(δ) ≥ fδ²/2, i.e. δ² ≤ 2mᵢ(δ)/f. Therefore

  ψ(t) ≤ ω mᵢ(δ)·[ωτ(1−τ)/f + 0.0321·ω²Δ/f] = ω mᵢ(δ)·[ω/ω̄ + 0.0321·ω²Δ/f].

Combining 2 and 4 gives (b).

*For the "in particular":* with ω ≤ (1−η)ω̄ ≤ ω̄ and e^{−x} ≥ 1 − x,

  B ≥ 1 − ω̄Δ − ω̄²Δ²/8 − (1−η) − 0.0321·ω̄²Δ/f = η − ω̄Δ(1 + ω̄Δ/8 + 0.0321/(τ(1−τ))) ≥ η/2,

using ω̄/f = 1/(τ(1−τ)).

**(c)** Suppose Fᵢ(s) − τ = fs + o(s). By (a), as δ → 0,

  log E e^{−ωX} = ψ(ωδ) − ω fδ²/2 + o(δ²) = (δ²/2)·ω·(ωτ(1−τ) − f) + o(δ²).

This is positive when ω > f/(τ(1−τ)) = ω̄.

**(d)** By L5, N(E₁) = ∫_{E₁} e^{−ωℛ(θ)} ν(dθ), with ℛ = Σᵢ Xᵢ(δᵢ) and ν = dc ⊗ Π_λ.
- *Independence.* By Tonelli and independence (A1), E₀N(E₁) = ∫_{E₁} ∏ᵢ E e^{−ωXᵢ(δᵢ)} ν(dθ).
- *Apply (b).* On E₁ every |δᵢ| ≤ Δ, so (b) and L2 give

  ∏ᵢ E e^{−ωXᵢ(δᵢ)} ≤ exp{−Bω Σᵢ mᵢ(δᵢ)} ≤ exp{−Bω(f/2) n‖δ‖ₙ²} ≤ exp{−Bω(f/2) M nε²}.

- *Mass of E₁.* For fixed u, the c-section of {‖δ‖∞ ≤ Δ} is contained in {c : ‖c − c₀(u)‖₂ ≤ √n Δ}. To see this, note that ‖δ‖₂ ≤ √n Δ, that projection onto span(N) is an ℓ₂-contraction, and that N is orthonormal (as in the Astra remark on L5). So ν(E₁) ≤ V₃(√n Δ)³·Π_λ(ℝᵐ) = V₃(√n Δ)³.

**(e)** Let Ω₀ be the event of L6. It has probability ≥ 1 − 1.44/(nε²), and on it N(ℝⁿ) ≥ ν(G)e^{−ω(1.44C₁+1)nε²}, with ν(G) = V₃(ε√n/2)³·Π_λ(u_h + B_{ε/2}). Then

  E₀Πₙ(E₁ | y) ≤ E₀[N(E₁)]/(ν(G)e^{−ω(1.44C₁+1)nε²}) + P₀(Ω₀ᶜ).

Insert (d), the volume ratio (√nΔ)³/(ε√n/2)³ = (2Δ/ε)³, and the prior-mass bound. Finally, 3 log(2Δ/ε) = O(log n) = o(nε²). ∎

## Remarks

- **No union bound, no entropy.** The expectation is taken before the ratio, and the denominator is controlled on a single event. This is why the old L8 counterexample (sup over an unstructured ε-ball) does not apply.
- **Role of Δ.** Δ is a fixed constant ≤ Δ₀(η, ω̄, τ). It need not shrink with n. So L10 only needs sup-norm localization at a fixed level Δ.
- **Why the bounded region is needed (no moments).** For |δ| ≫ 1 the identity (a) gives E e^{−ωX} ≥ e^{−ω(1−τ)δ}(1 + ω∫₀^δ e^{ωs}(1 − Fᵢ(s)) ds), which exceeds 1 under heavy right tails (e.g. Cauchy). So the Fubini route cannot handle E₂ = {‖δ‖∞ > Δ}. That is L10's job.
- **Constant.** f/2 in (d) is the local margin. The Huber margin c₀ of L2 is not needed here, because on E₁ every coordinate lies in the quadratic regime.

## Numerical check (passed)

`checks/l8p_mgf.py`:
1. sup|ψ‴| = 1/(6√3) over τ;
2. the exact MGF (a) against Monte Carlo;
3. inequality (b) on a grid of δ ∈ [−Δ, Δ], η ∈ {0.1, 0.3}, Δ ∈ {0.02, …, 0.5}, τ ∈ {0.05, 0.5, 0.9}, for Normal, Cauchy, Laplace, t₂ and lognormal noise. Here f is the minimum density on [−0.5, 0.5] around the quantile.

**Result (NOTS job 2857877).**
- sup|ψ‴| = 0.09623 = 1/(6√3).
- Inequality (b) holds on every grid point for Normal, Cauchy, Laplace, t₂ and lognormal noise at τ ∈ {0.05, 0.5, 0.9}.
- The exact MGF matches Monte Carlo to within 1–2 MC standard errors (se ≈ 2×10⁻⁴ at N = 4×10⁵).
- **Excluded row:** lognormal at τ = 0.05. The window [q ± 0.5] around q ≈ 0.085 extends below the support, so f = 0 and (A2) fails with L = 0.5. B is NaN there, and the script's comparison was vacuous. That row is outside the lemma's hypotheses and is **not** counted as a pass. The script now guards against f = 0.
- *Print quirk (cosmetic):* the printed "m" column is the exact m at δ = 0.5, while the MC value is at δ = 0.3. Both were checked by hand (normal, τ = ½: m(0.3) ≈ 0.0179, m(0.5) ≈ 0.0487).
