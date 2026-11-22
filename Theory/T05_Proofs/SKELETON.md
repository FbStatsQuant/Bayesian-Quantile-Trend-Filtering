# Proof skeleton: Theorem A at the oracle tuning (Stage A)

*Status: skeleton (2026-11-22). It shows how the lemmas combine. Statement: `../T03_Feasibility/STATEMENT_DRAFT.md`, v2.1.*

## Target statements

**Theorem A (milestone, σ ≥ σ̄ = τ(1−τ)/f).** Fix V and the constants of (A2). Set λₙ := n^{5/2}/V (primary version) or λₙ := (n³/V)^{3/4} (fallback version), and

- εₙ² := (log n)^c · κ^{−5/6} · V^{1/3} n^{−5/6}  (primary),
- εₙ² := (log n)^c · κ^{−7/8} · V^{1/4} n^{−3/4}  (fallback).

Then, for a large constant M,

  sup_{P ∈ 𝒫ₙ} E_P Πₙ( Δ²ₙ(θ − θ\*) > M εₙ² | y ) → 0.

**Theorem A⁺ (target).** The same statement for every fixed σ > 0. Its plan is in STATEMENT v2.1.

## Decomposition of the bad event

Fix Δ ∈ (0, L] and M large. With δ = θ − θ\*:

  {Δ²ₙ(δ) > Mε²} ⊂ E₁ ∪ E₂,
  E₁ := {Δ²ₙ(δ) > Mε², ‖δ‖∞ ≤ Δ},  E₂ := {‖δ‖∞ > Δ}.

Then

  E₀ Πₙ(E₁ ∪ E₂ | y) ≤ E₀[ N(E₁)/N(ℝⁿ) ] + E₀ Πₙ(E₂ | y).

## Step 1: denominator (L6, done in draft)

With probability ≥ 1 − 1.44/(nε²), N(ℝⁿ) ≥ ν(G) e^{−ω(1.44C₁ + 1)nε²}. The prior mass satisfies

  −log ν(G) ≤ φ(ε/2) + [c_K λ²‖u_h‖₂² (L4q) or λ‖u\*‖₁ (L4)] + O(log n) ≤ C_prior · nε²,

at the stated tuning. This uses L3 for φ(ε/2) ≲ (n^{5/2}/(λε))^{2/5} ≲ nε², and L4q-M for the mollified shift.

## Step 2: numerator on the bounded region (L8′, milestone route; to be written)

For θ ∈ E₁, every coordinate satisfies |δᵢ| ≤ Δ ≤ L. Fubini and independence give

  E₀ N(E₁) = ∫_{E₁} ∏ᵢ E e^{−ωXᵢ(δᵢ)} ν(dθ).

The exact MGF of the bounded increment (STATEMENT v2.1, σ̄ paragraph) gives, for ω ≤ (1−η)ω̄ and |δᵢ| ≤ Δ,

  log E e^{−ωXᵢ} ≤ −η′ ω mᵢ(δᵢ)

for some η′ = η′(η, Δ, f, f̄) > 0. *This per-coordinate inequality is the content of L8′. It must be proved on |δ| ≤ Δ, not only to second order.*

Hence E₀ N(E₁) ≤ ∫_{E₁} e^{−η′ω M(θ)} dν ≤ e^{−η′ω c₀ M nε²} · ν(E₁ ∩ bounded part). The ν-mass of E₁ is finite, since c is confined by the sup-norm constraint, and its log is polynomial in n.

Combining with Step 1: E₀[N(E₁)/N(ℝⁿ)] ≤ exp{−(η′ω c₀ M − C − ω(1.44C₁ + 1)) nε² + O(log n)} + 1.44/(nε²) → 0 for M large.

## Step 3: the sup-norm tail (L9′ / L10, the crux; open)

We need E₀ Πₙ(‖θ − θ\*‖∞ > Δ | y) → 0. Plan (STATEMENT v2.1, L9-a and L10):
- **(a)** {Δ²ₙ > K}: by convexity of ℛ and log-concavity of Πₙ (L9-a). This is moment-free.
- **(b)** On {Δ²ₙ ≤ K}, use the interpolation ‖P_R δ‖∞ ≲ ‖δ‖ₙ^{4/5}·TV⁽³⁾(δ)^{1/5} together with posterior control of TV⁽³⁾(δ). The latter comes from the two-level sieve (L7, ADH Prop. 2.15) plus a numerator bound outside the sieve (L9-c). This is where λ ≥ n^{a₀} enters.

## Step 4 (Theorem A⁺, any σ)

Replace Step 2 by the realized-numerator argument of STATEMENT v2.1: Knight score term, coarse net, fine-part integration, chained remainder (L8-b). Steps 1 and 3 are unchanged.

## Lemma status board

| Lemma | Role | Status |
|---|---|---|
| L1 basis | coordinates | trivial (verified numerically, T-03) |
| L2 excess risk | margins, C₁ | **advisor-checked** (Astra: accept with fixes; fixes applied) |
| L3 small ball | φ(ε) bound | **draft, second read done** (awaiting the numerical check): proved up to a (log n)^{6/5} factor via the Gaussian scale mixture + Anderson + singular values of C³ (no Laplace small-deviation theory needed) |
| L4 ℓ₁ shift | fallback prior mass | **advisor-checked** (Astra: accept) |
| L4q quadratic shift | primary prior mass | **self-checked** (Fable adversarial check: correct with fixable gaps, all fixed); awaiting advisor check |
| L4q-M mollification | bias term | **self-checked** (signed order-3 kernel; proof in L4q file) |
| L5 normalization | propriety, flat c | **advisor-checked** (Astra: accept) |
| L6 evidence | denominator | **draft**, self-checked given L3/L4/L4q |
| L8′ bounded numerator | Theorem A | **draft** (`L8p_bounded_numerator.md`): exact-MGF identity, log E e^{−ωX} ≤ −Bω·m(δ) on \|δ\| ≤ Δ with B ≥ η/2 for ω ≤ (1−η)ω̄; Step 2 closed given L6; numerical check queued |
| L8-b realized numerator | Theorem A⁺ | plan only |
| L9-a far region | both | to attempt |
| L9-c, L10 sup-norm | both | open (crux) |
