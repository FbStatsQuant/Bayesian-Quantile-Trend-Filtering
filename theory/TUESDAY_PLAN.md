# Tuesday 24 November: re-aimed attack plan (Theory)

*Theory Department, 2026-11-23. DRAFT v2 (after the CT Fables and the κ̂ pilot); final by 21:00 CT. INTERNAL, for HQ.*

## Gaps first (HQ steer, 15:xx CT)

Four pieces stand between Theorem LO, which is proved at fixed σ and λ and is unaudited, and the headline. Details are in §2.

| Gap | Piece (§2) | Prover | Auditor | Fallback | Account |
|---|---|---|---|---|---|
| 1. LO audited | H0: **DONE** (Astra: ACCEPT WITH FIXES at fixed (ω, ℓ), 63849f0; Lemma F′/Lev also audited) | — | — | — | — |
| 2. **Min-density loss → averaged β.** This brings Gaussian 0.05/0.95 and Beta 0.95 back in | H3 | Fable | Astra | headline at τ ∈ [0.25, 0.9] on every design, plus the cells whose worst-case β < 6 | CP |
| 3. **Uniformity in σ (compact) and λ (window).** Harder than planned: the audit found a genuine gap. **Route** (audit finding 11): an ℓ-grid at ratio 1 + 1/n interpolates the evidence within a factor e; log-convexity in ω; Hanson–Wright-type score tails on the polynomial grid | H2 | Fable | Astra | the conditional theorem F3 with uniformity as a stated assumption | CP |
| 4. **λ below n^{2.30}**: intermediate range G4 (sign route via κ) and bounded range G5 (certificate) | H4, H5 | Astra (H4), Fable (H5) | Fable (H4), Astra (H5) | named assumption, supported by κ̂ data (F3) | Codex (H4), CP + Engineering (H5) |

**Compute.** Nothing new this evening. The only compute in the plan is H5's interval certificate, on Tuesday, sized by Engineering first.

## 0. Aim

**Headline target: a floor-free theorem for the data-favoured A-rule.** The A-rule is Felipe's method with one hyperparameter changed: λ ~ Gamma(1, b_n), b_n = 1/(5500·(n/500)^{5/2}). It stays in the Gamma family, is a function of n only, and has no truncation. σ ~ IG(0.1, 0.1) is learned and θ is drawn by P-MALA.

- **Target statement.** At τ ∈ [0.05, 0.95], for the paper's three noise designs, θ contracts at **n^{−5/6} up to logs**, with σ and λ both learned.
- **Route.** Theorem H (audited) plus V0T\* (audited) reduce it to one input: **posterior lower-tail control of λ at the learned σ**, Π(λ < Λ₋ | y) → 0 with Λ₋ ≍ n^{5/2}/polylog.
- **Why design-specific.** No class-wide theorem exists for an unfloored adaptive Gamma prior. This is the soft-floor impossibility, with two independent notes (Astra; Fable B).
- **Extreme τ is out of scope.** At τ = 0.01/0.99 the design condition fails for every paper design (β ≈ 13–14 against ≈ 6). At those levels the paper keeps V0T\* and Theorem J.

**Data gate (Felipe's rule).** The A-rule has passed the exact-Gibbs screen: median MSE ratio 0.95 / 0.90 / 0.53 at n = 500 / 1000 / 2000, max 1.13. It still needs the P-MALA paired test and a joint non-crossing version before the paper can use it. That is Engineering's work, not Theory's; it is listed in §5.

## 1. What is already proved and audited (fallbacks)

| Fallback | Method it covers | Rate | Status |
|---|---|---|---|
| **F1: V0T\*** | his method + λ floor 1.6e-5·n^{5/2} | n^{−5/6}(log n)^{1/6}, exact at the oracle with LB | PROVED, cross-family audited; data gate running |
| **F2: C\*** | σ learned, λ deterministic at the oracle | n^{−5/6}(log n)^{1/6} | PROVED, cross-family audited |
| **F3: conditional A-rule** | A-rule, no floor | n^{−5/6}(log n)^{1/3} | assembly PROVED under the evidence margin (E); (E) stated as an assumption with numerical support (β table, Engineering λ-drift check) |
| Joint | V0T\* and C\* under non-crossing, fixed levels | n^{−5/6} | Theorem J, PROVED, cross-family audited |
| General k | fixed σ/λ | n^{−(2k+1)/(2k+2)} | PROVED, cross-family audited |

If the headline does not close by Tuesday night, **F3 is the paper's A-rule statement and F1 is the unconditional one.**

## 2. Hard pieces of the headline

**State at 15:00 CT.**
- **Fable A, `FABLE_A_three_lemmas.md` (a854245):** Theorem LO, the local Occam bound, is PROVED at fixed (ω, ℓ) for β < 6 and ℓ ≥ n^{99/43}·polylog. It is unaudited. It uses min_i f_i, so as proved it misses Gaussian τ = 0.05/0.95 and Beta 0.95.
- **Fable B, `FABLE_B_Arule_gauss.md` (5fb5e67):** exact identities reduce the λ lower tail to the **sign** of κ(ℓ) = m − ℓ·E_ℓ‖Dθ‖₁ (verified by Theory).
- **κ̂ pilot, Engineering 75ad1a4; reading in `kappa_pilot_reading.md`, 3c4562a:** the sign is positive at τ = 0.05–0.5 and lost at 0.97. This supports the averaged β < 6.

| # | Piece | Prover | Auditor | Fallback if it fails | Budget |
|---|---|---|---|---|---|
| H0 | **Audit Theorem LO** (Lemmas 1, 2a–c, 3). Lemma F′ and Lev are audited first; they are queued from Theorem H | (Fable A, done) | **Astra** | F3 (conditional theorem) | Codex |
| H1 | Audit Lemma RSB + Prop. LT-EM (`FABLE_A_Arule_lowertail.md`) | (Fable A, done) | Astra | none needed | Codex |
| H2 | **Uniformity of LO** in ω on a compact and in ℓ on [n^{99/43}, c₋n^{5/2}]: scalar grid + nested bodies (SKETCH in §5) | Fable (CP) | Astra | the rate keeps an extra K_n factor | CP |
| H3 | **Averaged condition**: Lemma 2b with position-dependent fᵢ, so that β is the design average, not the worst case. This brings in Gaussian τ = 0.05/0.95 and Beta 0.95; the pilot says the sign holds there | Fable (CP) | Astra | the headline covers τ ∈ [0.25, 0.9] on all designs, plus the cells with worst-case β < 6 | CP |
| H4 | **G4: intermediate tuning**, a large constant ≤ ℓ ≤ n^{99/43}. Lemma 1 has no localization there. New angle from Fable B: only κ(ℓ) ≥ 0 is needed there, not a size; try a direct sign argument on κ through (I3) | Astra (fresh eyes) | Fable | state (E-III) on this range as an assumption with the κ̂ data as support (F3) | Codex |
| H5 | **G5: bounded tuning (DC)** for the three paper designs: a proof or a rigorous interval-arithmetic certificate | Fable | Astra | numerical certificate only, stated as such | CP + Engineering |
| H6 | V0T\* with an n-dependent floor κ₋,ₙ = c₋(log n)^{−1/2}, line by line (the A-rule's plug-in) | Astra | Fable | the rate loses a further log | Codex |

**Order.** H0, H1 and H6 first: audits and a routine re-derivation. Then H2 and H3 in parallel. H4 is the main risk and gets the fresh-eyes Astra slot from mid-morning. H5 runs alongside, with Engineering compute for the certificate.

**What "headline proved" would mean.** H0 + H2 + H3 + H6, with H4 and H5 either proved or stated as named assumptions with data. Without H4/H5 the headline is the conditional theorem F3 with a smaller assumption: only the range below n^{2.30}.

## 3. Secondary pieces (each serves the headline or the paper's statement)

| # | Piece | Why it serves | Prover | Auditor |
|---|---|---|---|---|
| S1 | LB "spread around its own random centre" | makes the lower bound about the posterior's own spread, not distance to θ\* | Fable | Astra |
| S2 | Fixed-M Bousquet version of Theorem H | cleaner constant for the plug-in | Astra | Fable |
| S3 | No-floor sufficiency: does σ₀ < 2τ(1−τ)R suffice at bounded tuning for smooth designs? | feeds H5 | Astra | Fable |
| S4 | Joint small-gap item (levels whose true quantiles nearly touch) | Theorem J's caveat | Fable | Astra |
| S5 | Necessity half of β_c (β > 6 ⇒ evidence grows ⇒ λ drifts); Fable A §5 says it needs only Lemma 1's two-sided form plus Jensen | makes the extreme-τ limitation a theorem, not a caveat; the κ̂ data at 0.97 already point that way | Astra | Fable |

## 4. Old P-items: kept or retired

| Item | Decision | Reason |
|---|---|---|
| P1: log-concave ⇒ (EM) for σ > σ̄ | **RETIRED** | concerns σ > σ̄; the method lives at 0.13–0.64·σ̄ |
| P2: uniform in σ on compacts | **DONE** | C1/C2 hold uniformly on [l, H₀], any σ |
| P3: learned λ by hyperprior mass | **DONE with a floor** (V0T\*); its floor-free successor is the headline | — |
| P4: squared loss n^{−2/3} + posterior-mean corollary | rate **SUPERSEDED** (C\*/V0T\* give n^{−5/6} in ‖·‖²ₙ); posterior-mean corollary **KEPT, low tier** (needs posterior uniform integrability) | serves the paper's point estimate |
| P5: general-k exponent | **DONE** (audited) | — |
| P6: n^{9/4} self-tuning premise | **RETIRED** | MEASURED: λ ∝ n^{3/4} under constant b₀; the A-rule replaces it |
| P7: size of n₀(V) | **KEPT, low tier** (support model + Engineering numerics) | honesty about when the bound is in force |

## 5. Engineering inputs Tuesday's theory depends on

- the A-rule λ-drift by β (requested; tests the β_c ≈ 6 prediction);
- the τ = 0.01/0.99 run (running);
- the V0T data test, n = 2000/4000 (running);
- the H-V2 screen re-runs;
- the A-rule P-MALA paired test and joint version (data gate for the headline method).

## 6. Budget split

[TO COMPLETE at 21:00 with current usage.] Today's figures: CT Fable ~90% weekly, CW ~93%, CP 3 resets from 08:00, Codex 2 resets. **Plan: Fable proving on CP; Astra on Codex.** No CT or CW use unless HQ approves. Opus, Sonnet and Haiku do support work only (numerics scripts, consistency checks, reading). Every agent runs at effort high, never above. I alert HQ when any account passes 80% of what remains.
