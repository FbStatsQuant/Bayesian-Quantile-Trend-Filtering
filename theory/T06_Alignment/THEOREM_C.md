# Theorem C: contraction of θ with σ LEARNED under the IG prior (σ-aligned with Felipe's method)

*Theory Department, 2026-11-23. INTERNAL until HQ clears it.*

**Status: PROVED (assembly).** Every input is cross-audited:
- C1: Astra audit, findings applied (`C1_any_sigma.md`).
- W: Astra, ACCEPT (`W_width_lemma.md`).
- S: Opus, ACCEPT WITH FIXES, applied (`astra_sigma_concentration.md`).
- L2–L6 and L10-I: advisor-checked (`../T05_Proofs/`).

The assembly below is two lines. It should get a final read by an advisor before it goes to Felipe.

## Statement

**Model.** The paper's single-level posterior with **σ learned** and λ deterministic:

  π(θ, σ | y) ∝ σ^{−n}e^{−Q(θ)/σ} · e^{−λ‖D⁽³⁾θ‖₁} · IG(σ; a, b),  Q(θ) = Σᵢ ρ_τ(yᵢ − θᵢ),

with the flat prior on quadratics, any fixed a, b > 0 (the paper uses 0.1, 0.1), and a roughness penalty that does not involve σ (the paper's default).

**Assumptions** (fixed constants; the supremum is over all laws satisfying them):
- (A1) independence.
- (A2) both halves: a local margin with constants (L, f, f̄).
- (A3) TV⁽³⁾(θ\*) ≤ V.
- Row-average uniform integrability of ρ_τ(Zᵢ). This holds for the paper's Gaussian, Beta and mixture designs.
- σ₀,ₙ := n⁻¹Σᵢ E ρ_τ(Zᵢ) ≥ d > 0. This holds at each fixed design and level: σ₀ ∈ [0.0046, 0.29].
- **λ deterministic, with n^{23/11}(log n)^{12/11} ≪ λ ≪ n³/V.** This includes the oracle λ ≍ n^{5/2}/V.

**No (EM), no σ ≥ σ̄, no exponential or higher moments.**

**Conclusion.** With r_n² := C·n^{1/7}λ^{−2/7}(log n)^{6/7}, i.e. **r_n² ≍ n^{−4/7}(log n)^{6/7} at the oracle**, for every fixed η > 0:

1. sup_P E_P Π( ‖θ − θ\*‖²ₙ > r_n² | y ) → 0;
2. sup_P E_P Π( ‖θ − θ\*‖∞ > η | y ) → 0;
3. sup_P E_P Π( |σ/σ₀,ₙ − 1| > η | y ) → 0.

## Proof (assembly)

- **Compact containment (S §2).** There are fixed 0 < l < H₀ < ∞ with sup_P E Π(σ ∉ [l, H₀] | y) → 0. This needs only λ/log n → ∞ and (A3) (or a bounded truth).
- **Disintegration.** Because the penalty is σ-free, θ | σ = s, y has exactly the fixed-σ posterior Π_s. For any event E,

  Π(E | y) ≤ sup_{s∈[l,H₀]} Π_s(E | y) + Π(σ ∉ [l, H₀] | y).

- **Uniform fixed-σ contraction (C1).** [l, H₀] is a compact subset of (0, ∞). C1 gives sup_P E_P sup_{s∈[l,H₀]} Π_s(‖δ‖ₙ > r_n or TV(δ) > T₀ | y) → 0, with the supremum inside the expectation. On the complement, L10-I gives ‖δ‖∞ ≤ 6r_n + 7.06r_n^{4/5}T₀^{1/5} → 0. Together with the previous two bullets, this proves conclusions 1 and 2.
- **Scale consistency (S §1).** Since |Q(θ) − Q(θ\*)|/n ≤ ‖δ‖ₙ ≤ r_n → 0, hypothesis (H) holds, and S §1 gives conclusion 3. ∎

## What it does and does not cover

- **Covers** the method's σ treatment exactly: the IG prior, learned. It needs no σ̄ condition, and the learned σ provably lands near σ₀,ₙ. The data say σ₀,ₙ = 0.13–0.64 σ̄.
- **Rate:** n^{−4/7}(log n)^{6/7}, against the oracle target n^{−5/6}. This is suboptimal. The exponent is lost in C1's uniform supremum over the whole TV ball and in the crude width (Lemma W); see the Fable rate-gap consult.
- **Does not cover learned λ.** λ is deterministic here. Under Felipe's constant b₀ the learned λ grows like n^{3/4}, outside the window, so the method as run, with both σ and λ learned, has no theorem yet. At n = 500, the learned λ is within 0.03–4× of the oracle.
- The supremum is uniform over the stated class, at fixed design constants. Nothing is uniform as σ₀ → 0 or ∞.
