# Theorem C\*: σ LEARNED under the IG prior, at the oracle rate n^{−5/6}

*Theory Department, 2026-11-23. INTERNAL until HQ clears it.*

**Status: PROVED (assembly of cross-audited parts).** The assembly is the same two lines as Theorem C, with C2 supplying the rate. A short final read by a second model is recommended. Fable A, who is writing the same assembly independently in `FABLE_A_n56.md`, serves as that read.

Inputs, all cross-audited:
- **Lemma F, W′ and C1 with W′:** Fable #2 (`FABLE_lemmaF_C2.md`), verified by Theory, Opus: ACCEPT (`reviews/AUDIT_opus_F_C2.md`).
- **C2, the realized-numerator shell lemma:** Fable #2, Opus: shells ACCEPT WITH FIXES (editorial), everything else ACCEPT. It holds at fixed or compact-uniform σ, **including σ < σ̄**, moment-free, with the supremum over σ inside the expectation.
- **C1, the localization:** Astra-audited (`C1_any_sigma.md`).
- **Lemma S §2, compact containment of σ:** Opus-audited (`astra_sigma_concentration.md`).
- **L2–L6, L10-I:** advisor-checked (`../T05_Proofs/`).

## Statement

Model and assumptions are those of Theorem C (`THEOREM_C.md`): σ ~ IG(a, b) learned, a σ-free penalty, (A1), full (A2), (A3), row-average uniform integrability, σ₀,ₙ ≥ d > 0, and **λ deterministic at the oracle, λ ≍ n^{5/2}/V**.

**No (EM), no σ ≥ σ̄, no exponential moments.**

Then there is M such that

  sup_P E_P Π( ‖θ − θ\*‖²ₙ > M·(log n)^{1/6}V^{1/3}n^{−5/6} | y ) → 0,

and moreover ‖θ − θ\*‖∞ → 0 and σ/σ₀,ₙ → 1 in posterior probability.

## Proof (assembly)

1. **σ-containment (S §2).** There are fixed 0 < l < H₀ with sup_P E Π(σ ∉ [l, H₀] | y) → 0.
2. **Disintegration.** The penalty is σ-free, so θ | σ = s, y is the fixed-σ posterior Π_s, and Π(E | y) ≤ sup_{s∈[l,H₀]} Π_s(E | y) + Π(σ ∉ [l, H₀] | y).
3. **Fixed σ, uniform on [l, H₀].** C1 (localization: ‖δ‖ₙ ≤ r and ‖δ‖∞ ≤ s_K → 0) combined with C2 (dyadic shells from Mε² up to r², k_max = ⌈log₂(r²/(Mε²))⌉) gives sup_P E sup_{s∈[l,H₀]} Π_s(‖δ‖²ₙ > Mε² | y) → 0, with ε² ≍ (log n)^{1/6}V^{1/3}n^{−5/6}.
   - The good event is one ω-free set: Ω_ψ ∩ Ω₆ ∩ Ω_G ∩ (the Markov events for the remainder factor at the two endpoints ω₁ = 1/H₀ and ω₂ = 1/l, one per shell).
   - The threshold is ω₁(f/8 − η)M > ω₂(1.44C₁ + 1) + C_pr + C_fine·ω₂²/M⁵, with 0 < η < f/8.
4. Steps 1–3 give the rate. The sup-norm bound is C1's. Scale consistency is S §1 with (H), since |Q − Q\*|/n ≤ ‖δ‖ₙ → 0. ∎

## Response to the C2 audit (Opus, `reviews/AUDIT_opus_F_C2.md`)

Every finding was verified by Theory.

| # | Finding | Ruling | Change |
|---|---|---|---|
| 1 | k_max must reach r² | HOLDS | k_max = ⌈log₂(r²/(Mε²))⌉ (Step 3 above) |
| 2 | State 0 < η < f/8 | HOLDS | Stated |
| 3 | Name one ω-free good event (so the supremum is inside the expectation) | HOLDS | Stated in Step 3 |
| 4 | (PLAUSIBLE) C2 on [l, H₀] plus S §2 gives the learned-σ rate without σ₀-concentration | **HOLDS.** Steps 1–3 need only containment; σ → σ₀ is an extra conclusion. | This assembly |
| 5 | Mark FABLE_rate_gap.md superseded; flag Lemma F's unused remark | HOLDS | Noted (planning note superseded by FABLE_lemmaF_C2.md) |

## Scope

- **Covers** σ exactly as Felipe's method learns it, at the oracle rate.
- **λ is deterministic here.** For both learned (Felipe's method plus the λ floor), see Theorem V0T\* (Fable A, in progress). It needs C2 uniform over ℓ ≥ Λ₋ against the mixed denominator.

## Cross-family audit (Astra, `reviews/AUDIT_astra_F_C2.md`, 2026-11-23)

Verdicts:
- **Theorem C\*: ACCEPT.**
- Lemma F and W′: ACCEPT.
- C1 with W′: ACCEPT WITH FIXES.
- C2: ACCEPT WITH FIXES.

All seven findings were verified by Theory and **HOLD**:
1. **F interior and ends.** Confirmed.
2. **C1 with W′.** Carry forward Vλ = o(n³) and the denominator condition at the improved radius. Both hold at the oracle: n^{−5/6} = o(n^{−5/7}).
3. **Shells.** Define E_a = {aD_n < ‖δ‖₂² ≤ 2aD_n, ‖δ‖∞ ≤ s₀} explicitly, with D_n = nε² and s₀ = min(L, 3f/(4ω₂f̄)), before the Tonelli step. Note added; C1 gives s_K → 0 deterministically.
4. **Coarse event.** Var(Q) ≤ (J+3)/4, and Chebyshev gives failure probability ≤ 4(J+3)/(9(J−1)²) → 0. Confirmed.
5. **Fine factor.** Hoeffding failure ≤ (2m)^{−3}, and 2ω₂b_J/λ = O(n^{−5/12}(log n)^{1/12}). Confirmed.
6. **Shell coverage.** The upper edge of shell k is 2^{k+1}Mε², so any terminal index K ≥ log₂(r²/(Mε²)) − 1 suffices. Floor and ceiling both work.
   - **Disagreement with Opus (#1), minor:** Opus required the ceiling; Astra shows the floor also works. Theory sides with Astra on the mathematics. Since the ceiling used in Step 3 is valid either way, nothing changes. Flagged to HQ.
7. **Learned-σ transfer.** Under Lemma S's hypotheses, confirmed.

**Status: Theorem C\* is cross-audited by both families** (Opus, Astra) on all of its Fable-written parts.
