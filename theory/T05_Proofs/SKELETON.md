# Proof skeleton: Theorem A at the oracle tuning (Stage A)

*Status: skeleton (2026-11-22). It shows how the lemmas combine. Statement: `../T03_Feasibility/STATEMENT_DRAFT.md`, v3.1.*

## Target statements

**Theorem A (milestone, strict slack ω ≤ (1−η)ω̄, ω̄ = f/(τ(1−τ)), i.e. σ ≥ σ̄/(1−η)).** Fix V and the constants of (A2). Set λₙ := n^{5/2}/V (primary version) or λₙ := (n³/V)^{3/4} (fallback version), and

- εₙ² := (log n)^c · κ^{−5/6} · V^{1/3} n^{−5/6}  (primary),
- εₙ² := (log n)^c · κ^{−7/8} · V^{1/4} n^{−3/4}  (fallback).

Then, for a large constant M,

  sup_{P ∈ 𝒫ₙ} E_P Πₙ( Δ²ₙ(θ − θ\*) > M εₙ² | y ) → 0.

**Theorem A⁺ (target).** The same statement for every fixed σ > 0. Its plan is in STATEMENT v3.1 (Hölder–Knight route first).

## Decomposition of the bad event

Fix Δ ∈ (0, L] and M large. With δ = θ − θ\*:

  {Δ²ₙ(δ) > Mε²} ⊂ E₁ ∪ E₂,
  E₁ := {Δ²ₙ(δ) > Mε², ‖δ‖∞ ≤ Δ},  E₂ := {‖δ‖∞ > Δ}.

Then

  E₀ Πₙ(E₁ ∪ E₂ | y) ≤ E₀[ N(E₁)/N(ℝⁿ) ] + E₀ Πₙ(E₂ | y).

## Step 1: denominator (L6; advisor-checked)

With probability ≥ 1 − 1.44/(nε²), N(ℝⁿ) ≥ ν(G) e^{−ω(1.44C₁ + 1)nε²}. The prior mass satisfies

  −log ν(G) ≤ φ(ε/2) + [c_{K′} λ²‖u_h‖₂² (half-radius L4q, K′ = K(λε/2)) or λ‖u\*‖₁ (L4)] + O(log n) ≤ C_prior · nε²,

at the stated tuning. This uses L3 for φ(ε/2) ≲ (n^{5/2}/(λε))^{2/5} ≲ nε², and L4q-M for the mollified shift.

## Step 2: numerator on the bounded region (L8′; advisor-checked)

For θ ∈ E₁, every coordinate satisfies |δᵢ| ≤ Δ ≤ L. Fubini and independence give

  E₀ N(E₁) = ∫_{E₁} ∏ᵢ E e^{−ωXᵢ(δᵢ)} ν(dθ).

The exact MGF of the bounded increment (L8′(a)–(b)) gives, for ω ≤ (1−η)ω̄ and |δᵢ| ≤ Δ ≤ Δ₀,

  log E e^{−ωXᵢ} ≤ −η′ ω mᵢ(δᵢ)

with η′ = B(ω, Δ) ≥ η/2 (L8′(b); free of f̄). This is proved on |δ| ≤ Δ, not only to second order.

Hence E₀ N(E₁) ≤ ∫_{E₁} e^{−η′ω M(θ)} dν ≤ e^{−η′ω c₀ M nε²} · ν(E₁ ∩ bounded part). The ν-mass of E₁ is finite, since c is confined by the sup-norm constraint, and its log is polynomial in n.

Combining with Step 1: E₀[N(E₁)/N(ℝⁿ)] ≤ exp{−(η′ω c₀ M − C − ω(1.44C₁ + 1)) nε² + O(log n)} + 1.44/(nε²) → 0 for M large.

## Step 3: the sup-norm tail (L9′ / L10, the crux; open)

We need E₀ Πₙ(‖θ − θ\*‖∞ > Δ | y) → 0. Plan (STATEMENT v3.1; now the VP's two-stage route, with Stage 2 = L10-I):
- **(a)** {Δ²ₙ > K}: by convexity of ℛ and log-concavity of Πₙ (L9-a). This is moment-free.
- **(b)** On {Δ²ₙ ≤ K}, use the interpolation ‖P_R δ‖∞ ≲ ‖δ‖ₙ^{4/5}·TV⁽³⁾(δ)^{1/5} together with posterior control of TV⁽³⁾(δ). The latter comes from the two-level sieve (L7, ADH Prop. 2.15) plus a numerator bound outside the sieve (L9-c). This is where λ ≥ n^{a₀} enters.

## Step 4 (Theorem A⁺, any σ)

Replace Step 2 by the realized-numerator argument of STATEMENT v3.1: Knight score term, coarse net, fine-part integration, chained remainder (L8-b). Steps 1 and 3 are unchanged.

## Theorem B (light-tail fallback; HQ: prove first)

`B_light_tail.md`. Under the global MGF condition (EM), Step 2 is done on **all of ℝⁿ** by Fubini, and the flat part is bounded by C₃(bω), free of n. So Steps 3–4 (L7, L9, L10) are not needed. Step 1 (L6) is unchanged. The result is in Δ²ₙ only.

## Lemma status board

| Lemma | Role | Status |
|---|---|---|
| L1 basis | coordinates | trivial (verified numerically, T-03) |
| L2 excess risk | margins, C₁ | **advisor-checked** (Astra: accept with fixes; fixes applied) |
| L3 small ball | φ(ε) bound | **advisor-checked** (Fable: ACCEPT): φ(ε) ≤ 30x^{2/5}(log m)^{1/5} + 6 via the Gaussian scale mixture + Anderson + singular values of C³ |
| L4 ℓ₁ shift | fallback prior mass | **advisor-checked** (Astra: accept) |
| L4q quadratic shift | primary prior mass | **advisor-checked** (Astra: ACCEPT; half-radius form stated first) |
| L4q-M mollification | bias term | **advisor-checked** (Astra: ACCEPT WITH FIXES, applied: explicit kernel, ‖u_h‖∞, c_{K′}^{5/6} kept with a fresh half-radius threshold check) |
| L5 normalization | propriety, flat c | **advisor-checked** (Astra: accept) |
| L6 evidence | denominator | **advisor-checked** (Astra: ACCEPT WITH FIXES, applied: small-ball log in the rate consequence) |
| L8′ bounded numerator | Theorem A | **advisor-checked** (Fable: ACCEPT WITH FIXES, applied; 15/15 numerical rows): exact MGF identity, log E e^{−ωX} ≤ −Bω·m(δ) on \|δ\| ≤ Δ with B ≥ η/2 for ω ≤ (1−η)ω̄ |
| L8-b realized numerator | Theorem A⁺ | plan only |
| L9-a far region | both | to attempt |
| L10-I interpolation | L10 (deterministic part; Stage 2) | **advisor-checked** (Astra; C = 9 exactly): ‖δ‖∞ ≤ 6‖δ‖ₙ + 7.06‖δ‖ₙ^{4/5}TV⁽³⁾^{1/5}; Stage 2 closes given Stage 1 for λ/n^{21/11} → ∞ |
| L10 Stage 1 (posterior TV ball + Δ²ₙ ≲ λ^{−2/7}, in-probability) | both | **open: the remaining crux** (main thread and the Fable child) |
| B: Props 1–2 + assembly | Theorem B (light tails) | **PROOF COMPLETE, advisor-checked** (Astra on B and L6; Fable on L3; all inputs L2–L6, L4q/L4q-M advisor-checked) |
