# Alignment memo: does the theorem's σ/λ match Felipe's method?

*Theory Department, 2026-11-23 (final, 18:00 CT; inputs still arriving at 17:05 are folded in). INTERNAL, for HQ.*

**Status labels.** PROVED means proved by Theory, with the proof here or in the cited file; "not yet audited" when no advisor has checked it. SKETCH means the steps are written but unverified. OPEN means no proof. MEASURED means Engineering data, with the source cited.

## EXECUTIVE SUMMARY

**Headline — Theorem V0T\* (PROVED, cross-family audited; individual data gate MET, joint 0.99 unresolved).**
- **Method:** Felipe's method — σ ~ IG(0.1, 0.1) learned, λ ~ Gamma(1, b₀) learned at his constant b₀ — **plus one change: a λ floor λ ≥ 1.6e-5·n^{5/2}**.
- **Result:** θ contracts at the **oracle rate n^{−5/6}(log n)^{1/6}**. No σ̄ condition, no exponential moments.
- **At the paper's n:** the floor never binds at n = 500 (MEASURED), so V0T is his method there.
- **Audit trail:** Fable proved it; Astra audited it (ACCEPT WITH FIXES, editorial).
- **Matching lower bound (Theorem LB, audited; fixes in efc0a09):** the rate n^{−5/6} is exact. The lower bound holds under (A1) + upper (A2), at any σ, learned σ, and V0T's learned λ. The scope is detailed below.
- **Data gate (MEASURED, Engineering b872c87 + follow-up; internal):**
  - **Individual, n = 4000, 7 cells, 2 chains per arm:** median MSE ratio V0T/his = **0.47** (0.38–0.99), so Felipe's bar (median ≤ 1.10, no cell > 1.25) is met.
    - **Caveat:** at n = 4000 his default chain is stuck: λ = 372–1663, R̂ ≈ 2, and running twice as many sweeps does not fix it. The floor (≈ 1.6e4) rescues the chain; it does not reflect the posterior λ, which is ≈ 16–80k. In one cell (S-Mixed τ = 0.95) λ is pinned at the floor, with MSE ratio 0.99.
  - **Joint smoke, n = 2000, VS, levels 0.90–0.99, 1 chain:**
    - At 0.90–0.98 the floor never binds and the two arms match (MSE ratios 0.89–1.14). No crossings.
    - **τ = 0.99 is unresolved:** neither arm converged at 6000 sweeps. It is NOT a floor effect: the floor did not bind.

**Second track: the A-rule without a floor** (data-favoured prior λ ~ Gamma(1, 1/(5500(n/500)^{5/2})), σ learned). This is NOT yet a floor-free theorem. The chain to (LT) of Corollary P, and its status at 17:05:

| Link | λ range / step | Status |
|---|---|---|
| L1 | tiny λ | PROVED, class-wide |
| L2 | bounded λ (design condition DC) | **PROVED and cross-family audited for all three paper designs** at τ ∈ {0.05, 0.25, 0.5, 0.75, 0.95} (Fable B / Astra, `T06_Alignment/FABLE_B_L2_analysis.md` incl. Theorem DC-W). ℓ₀ at τ = ½: Gaussian 1223, Mixed 1194, Beta 49.75; tails: Gaussian 18.9, Mixed 10.08, Beta 0.05: 378, Beta 0.95: 4.1 (short range). Uses (A3). Not "every τ" |
| L3 | interpolating fits, extreme scales | PROVED, class-wide |
| L4a | [ℓ₀, n^{3/2}] | OPEN; named assumption with data check (`T06_Alignment/L4a_assumption.md`) |
| L4b | [n^{3/2}, n^{2.30}] | **PROVED (unaudited) down to n^{9/5}** at fixed (σ, λ), via a new layer-cake remainder bound (Fable A, `T06_Alignment/FABLE_A_L4b.md`, 7335034; Lemma CA verified by Theory; Astra audit running). One hypothesis left on [n^{1.53}, n^{1.80}]; [n^{3/2}, n^{1.53}] SKETCH; uniform version SKETCH below n^{21/11} |
| L5 | [n^{2.30}, c₋n^{5/2}(log n)^{−1/2}] | **PROVED, cross-family audited**: "the A-rule posterior excludes the middle band of λ", averaged β̄ < 6, all paper designs at τ ∈ [0.05, 0.95] |
| L6 | L1–L5 ⇒ (LT) | assembly PROVED given its inputs |
| L7 | (LT) ⇒ rate n^{−5/6}(log n)^{1/3} via V0T\* with an n-dependent floor | **PROVED, cross-family audited** |

**Answers to HQ's questions:**

| | Answer | Status |
|---|---|---|
| (a) | σ > σ̄ is used ONLY in Theorem B's expected-numerator step (EM). It is a limit of that proof technique: not needed for contraction, and not used for coverage. | PROVED |
| (b) | Contraction holds for fixed σ < σ̄ at the SAME rate n^{−5/6}: C1 (localization) + Lemma F + C2 (realized-numerator shells), uniformly on compact σ-intervals, moment-free. | PROVED, audited by both families |
| (c) | Learned σ: **Theorem C\*** gives n^{−5/6} with σ ~ IG learned, at deterministic oracle λ (Lemma S: σ is contained in [l, H₀] and concentrates on σ₀,ₙ). MEASURED: σ/σ₀,ₙ = 0.95–1.02, with width ∝ n^{−1/2}. | PROVED; every part audited by both families (Lemma S: Opus + Fable) |
| (d) | Constant b₀ alone (no floor) is **not** covered: λ ∝ n^{3/4} (MEASURED), outside every window. With the floor (V0T) it is covered at n^{−5/6} for constant OR scaled b₀. Under (EM), constant b₀ gives n^{−1/4} without a floor. | PROVED (floor). **No floor: no class-wide theorem exists** (Astra's counterexample, cross-family audited by Fable). There is a law in the class where the exact no-floor posterior is inconsistent, for constant b₀ and also for unfloored scaled b₀. The floor is **one sufficient repair** (not shown to be necessary). The necessary condition σ₀ ≤ 2τ(1−τ)R **holds for all paper designs with margin** (MEASURED: ratio 0.18–0.47, commit 51b7163, `T06_Alignment/noFloor_necessary.out`). Whether it is sufficient is OPEN. |
| (e) | Route B with Theorem B as it stood is impossible on data: every σ ≥ σ̄ arm fails Felipe's MSE bar. Route A succeeded; see the headline. | MEASURED + PROVED |

**Variants:**
- **V0T** (his method + floor): identical at n = 500; theorem at n^{−5/6}; data test running.
- **V2** (b₀ ∝ n^{−5/2}): pilot running.
- **V1** (λ fixed): **FAILED on data** (MEASURED, Engineering: S cells 1.37–1.92× worse; the posterior λ differs about 10× between S and VS). λ must stay data-driven.
- **Soft floor via Gamma hyperparameters** (temporary Astra assistant, `T06_Alignment/astra_softfloor.md`; Fable cross-check in progress; NOT yet audited):
  - **(i)** Shape a_n = Kn/log n with mean κn^{5/2} gives the V0T\* rate n^{−5/6} with no truncation. But it **pins λ** at its prior mean, which is V1's failure mode on data.
  - **Impossibility:** no deterministic Gamma schedule gives class-wide contraction AND tracks oracle windows 46× apart.
  - **(ii)** V2 (constant shape, scaled rate) **fails class-wide**, even on a bounded design satisfying the strict margin. So the margin condition is NOT sufficient.
  - **(iii)** Felipe's Gamma(n, 1) gives no RMS contraction at any radius o(n^{−1/3}).
  - **Consequence:** for an adaptive λ prior (data-passing), any theorem must be **design-specific** (the paper's smooth noise families). That is OPEN, and it is Tuesday's target.
  - **Independent cross-check (Fable B, `FABLE_B_softfloor.md`, unaudited): it agrees with Astra.**
    - Class-wide guarantees and adaptivity are incompatible within the Gamma family.
    - The sharp soft-floor shape is ∝ n/log n.
    - Gamma(n, 1) cannot reach n^{−5/6}.
    - A pinned soft floor (a_n = An, mean κn^{5/2}) gives all V0T\* conclusions with no truncation (PROVED by assembly), but it kills adaptivity.
    - **Warning for the design-specific A-rule theorem:** a weak prior is not expected to suffice at extreme τ, where the proxy sign is 6 − σ̄/σ₀ and σ̄/σ₀ ≈ 6.6–6.7 at τ = 0.05/0.95. So it may hold only at moderate τ (CONJECTURE).
  - **β per paper design and level** (computed; `T06_Alignment/beta_table.out`). β = τ(1−τ)/(f·σ₀); proxy condition β < ~6, which is CONJECTURAL. Columns are β with the worst-case density, then β with the design-averaged density.

    | τ | Gaussian | Beta | Mixed |
    |---|---|---|---|
    | 0.01 | 20.9 / 13.3 ✗ | 5.6 / 0.9 ✓ | 14.1 / 13.9 ✗ |
    | 0.05 | 6.7 / 4.3 (avg ✓) | 5.5 / 1.0 ✓ | 4.5 / 4.5 ✓ |
    | 0.25 | 2.8 / 1.8 ✓ | 5.1 / 1.1 ✓ | 1.9 / 1.9 ✓ |
    | 0.5 | 2.4 / 1.5 ✓ | 4.5 / 1.3 ✓ | 1.6 / 1.6 ✓ |
    | 0.75 | 2.8 / 1.8 ✓ | 4.0 / 2.0 ✓ | 1.9 / 1.9 ✓ |
    | 0.9 | 4.4 / 2.8 ✓ | 4.9 / 3.3 ✓ | 3.0 / 2.9 ✓ |
    | 0.95 | 6.7 / 4.3 (avg ✓) | 6.6 / 5.0 (borderline) | 4.5 / 4.5 ✓ |
    | 0.99 | 20.9 / 13.3 ✗ | 17.1 / 12.7 ✗ | 14.1 / 13.9 ✗ |

    - **Reading:** on the design-averaged β, every paper level from 0.05 to 0.95 is inside the proxy region, with Beta 0.95 borderline. τ = 0.01/0.99 is outside for all designs.
    - **MEASURED (Engineering, existing exact Gibbs):** the A-rule's λ ratio drops at the tails in the predicted direction, most at Beta 0.95 (β = 6.0). The dominant effect, though, is the signal: the λ ratio is ≈ 3–10 on S and ≈ 0.2–0.8 on VS.
    - **So the A-rule is a natural Tuesday target for τ ∈ [0.05, 0.95]**, and the extreme levels 0.01/0.99 are likely out of reach of this route.
  - **A-rule lower tail (Fable A, `FABLE_A_Arule_lowertail.md`, unaudited):**
    - **PROVED:** an A-rule lower-tail result with no floor, but only at fixed σ in the (EM) range, NOT at the learned σ. The posterior mass of {λ < c₋n^{5/2}(log n)^{−1/2}} → 0, via a new reverse small-ball lemma.
    - **At the learned σ:** conditional on one explicit evidence inequality ("under-smoothed pairs cost code length").
    - **Proxy design condition:** β = τ(1−τ)/(f₀σ₀) < β_c ≈ 6 (CONJECTURE). It **predicts that the A-rule's λ drifts below its prior mean at Gaussian τ = 0.01/0.99 and Beta τ = 0.99**; a cheap data check has been requested from Engineering.
    - ~~Three lemmas would close the gap for 1 < β < 6 on C1's window (SKETCH).~~ Superseded by the next bullet. The earlier "β < 5.2" is withdrawn.
  - **Theorem LO, the local Occam bound** (Fable A, `T06_Alignment/FABLE_A_three_lemmas.md`; **PROVED at fixed σ and λ, cross-family audited** (Astra: ACCEPT WITH FIXES, 63849f0). **Uniformity in (σ, λ) is OPEN: the audit found a genuine gap in the sketch.** So there is no A-rule posterior statement yet). At the learned σ, the evidence of under-smoothed fits decays whenever **β < 6**, which is the conjectured constant itself. It holds for λ ≥ n^{2.30}, below the oracle n^{5/2}.
    - **Open:** uniformity in (σ, λ), a genuine gap with a repair route; the range of λ below n^{2.30}, which has no route; bounded λ, for which a numerical certificate is needed.
    - As proved it uses the worst-case density, so **Gaussian τ = 0.05/0.95 and Beta 0.95 are not covered yet**. The averaged-β version is a Tuesday piece.
  - **Theorem U / U-σ: uniformity, closing the gap the LO audit found** (Fable A, `T06_Alignment/FABLE_A_uniformity.md`; **PROVED and cross-family audited**, Astra: ACCEPT WITH FIXES, f5f05de).
    - **Result: the A-rule posterior excludes the middle band of λ.** Under the joint posterior with σ learned, it puts vanishing mass on λ ∈ [C·n^{2.30}polylog, c₋n^{5/2}(log n)^{−1/2}], for worst-case β < 6.
    - **This is NOT yet a floor-free theorem.** That needs gap 4 (λ below n^{2.30}) and hence (LT) of Theorem H's Corollary P.
    - The nine audit fixes are applied by reference tonight; the paper version (Tuesday rewrite) will contain them in full.
    - **Still open:** λ below n^{2.30}. Astra's attempt today proved obstructions (`astra_gap4_sign.md`); Fable is working on it.
  - **Averaged β** (Fable B, `T06_Alignment/FABLE_B_averaged_beta.md`). **LO and U / U-σ hold with β̄ < 6: PROVED and cross-family audited** (Astra: ACCEPT WITH FIXES, a5453af).
    - **The condition:** β̄ = ωt·Σfᵢ^{−5/6}/Σfᵢ^{1/6}, the averaged condition in place of the worst-case density. It needs a smooth density profile, plus a class-uniform margin.
    - **Values, reproduced independently by Astra:** Gaussian 0.05/0.95: 4.43; Beta 0.95: 5.12; Mixed 0.05/0.95: 4.46.
    - **Consequence: the A-rule's middle-band exclusion covers the whole paper grid τ ∈ [0.05, 0.95] on all three designs.**
    - The sufficient comparison crosses 6 at τ ≈ 0.96–0.97. Beyond that the theorem says nothing either way; data: the κ̂ pilot and the extreme-τ run.
  - **Gap 4, λ below n^{2.30}: OPEN.**
    - Astra (`astra_gap4_sign.md`) and Fable A (`FABLE_A_gap4.md`) have proved obstructions and partial routes.
    - Below λ ≈ n^{3/2} even the β < 6 heuristic has no justification.
    - Until this closes, there is no floor-free theorem.
    - **If it is assumed (L4a; `T06_Alignment/L4a_assumption.md`):**
      - **Statement:** Π(ℓ₀ ≤ λ ≤ n^{3/2}polylog | y) → 0.
      - **Empirical status (MEASURED, A-rule screen medians, `engineering/E07_Tuning_Free/hyper/results/screen_cells.csv`):** the posterior λ tracks the oracle n^{5/2}/V stably from n = 500 to 2000 at τ = 0.5.
      - **Zero mass below n^{3/2} is NOT shown,** and with medians only it cannot be. At paper n, VS sits there legitimately, because its oracle is below n^{3/2} while n < V.
      - **Watch item:** S at τ = 0.95 (one seed).
      - **Draws check:** proposed for Tuesday.
  - **L7, V0T\* with an n-dependent floor** (Fable A, `T06_Alignment/FABLE_A_V0Tstar_nfloor.md`): **PROVED and cross-family audited** (Astra: ACCEPT WITH FIXES). It gives the rate n^{−5/6}(log n)^{1/3} once (LT) holds.
  - **Sign reduction** (Fable B, `T06_Alignment/FABLE_B_Arule_gauss.md`, 5fb5e67; identities verified by Theory). The λ lower tail reduces to the sign of a posterior mean, κ(ℓ) = m − ℓ·E_ℓ‖Dθ‖₁. At τ = ½ no diverging floor is proved; this is a negative result.
  - **MEASURED, internal (κ̂ pilot):** Engineering 75ad1a4, 0.29 core-h; Theory's reading is `T06_Alignment/kappa_pilot_reading.md`, 3c4562a.
    - On the Gaussian design, one seed, κ̂ > 0 at τ = 0.05, 0.25 and 0.5.
    - The slope is −1/3 at 0.25/0.5, as predicted.
    - At τ = 0.97, n = 2000, the sign is lost, as predicted.
    - This supports the averaged β < 6 design condition.
  - **Lower bound, Theorem LB (referee point #1), Fable B** (`T06_Alignment/FABLE_B_lowerbound.md`). **PROVED and cross-family audited** (Astra: ACCEPT WITH FIXES). **All eleven confirmed fixes, plus the plausible one, are applied in commit efc0a09.**
    - **Statement:** E₀Π(Δ²ₙ(θ − θ\*) ≤ c₀λ^{−1/3} | y) → 0, with an explicit finite-n bound: 1.44/D + 8D^{3/2}e^{5−(Σ+1)D}, D = nλ^{−1/3}.
    - **Exact scope of the lower bound:**
      - **Noise:** (A1) and the **upper half of (A2) only**. No lower margin, no (EM), no moments, no σ ≥ σ̄.
      - **σ:** any fixed σ > 0, with c₀ depending on σ. It holds uniformly on compact σ-intervals. It also holds for **σ learned under IG**, given Lemma S's hypotheses: row-average UI, σ₀,ₙ ≥ d, and (A3) or a bounded truth.
      - **λ:** deterministic, with λ → ∞ and λ = o(n³), so D → ∞; precisely, (32Σ)³ ≤ λ ≤ (n/42)³. Σ depends on the truth through the shift budget β.
        - Under (A3), TV⁽³⁾ ≤ V with fixed V > 0, this covers **every λ → ∞ with λ ≤ a₂n^{5/2}/V**, with β bounded.
        - For quadratic truths it covers every λ = o(n³).
        - **Above the oracle**, both tuning restrictions must be re-checked at the growing β, and they can fail; for example, λ = n^{59/20} is not certified.
      - **λ learned:** his method plus the floor (V0T: constant b₀, fixed V and κ₋) gives Π(Δ²ₙ ≤ c·Λ₋^{−1/3} | y) → 0 with a constant c, **log-free** (this was closed by the audit). Not covered: unfloored scaled hyperpriors (A-rule, V2), because no upper containment of λ is available.
      - **Centre:** a ball around the truth θ\*, not around a posterior-dependent centre. The "own spread" version needs a new lemma.
    - **Matching (two-sided) statement at the oracle λ ≍ n^{5/2}/V:** c₀(V/a₂)^{1/3}n^{−5/6} ≤ Δ²ₙ ≤ M(log n)^{1/6}V^{1/3}n^{−5/6}, with posterior mass → 1. It holds in Δ²ₙ and in ‖·‖²ₙ.
      - **The upper half needs more than LB:** full (A2), (A3), row-average UI and σ₀,ₙ ≥ d.
        - learned σ, deterministic oracle λ: from C\*;
        - his method + floor: from V0T\*;
        - a fixed σ: from C\*-3/4;
        - a fixed σ in the (EM) range: from Theorem B.
      - **So under (A1) + upper (A2) alone, only the lower half is established.** The remaining gap is the factor (log n)^{1/6} on the upper side.
    - **Headline (approved by HQ once the fixes were in):** "upper and matching lower bound": **n^{−5/6} is the exact posterior contraction rate** at the oracle, for his method + floor (V0T\*) and for learned σ at the oracle λ (C\*). This is up to (log n)^{1/6} on the upper side.
- **Theorem H** (Fable A, `T06_Alignment/FABLE_A_theoremH.md`): Huber-body localization above any λ floor Λ₋ (n^{−3/14} at Λ₋ ≍ n^{3/4}), plus the plug-in identity Π(B | y) ≤ Π(B | y, λ ≥ Λ₋) + Π(λ < Λ₋ | y). **Status: PROVED and cross-family audited** (Astra: ACCEPT WITH FIXES; V2T Step 2 confirmed at a general floor; a fixed-M version is possible). Fixes applied in the commit that adds this note (see git log: 'Theorem H fixes applied'). It is the building block for a floor-free A-rule theorem; the missing input is lower-tail control of λ (Fable A, in progress).
- **Exact-Gibbs hyperparameter screen (MEASURED, Engineering; prior effect only, both arms exact Gibbs):**
  - **PASSES:** **A-rule λ ~ Gamma(1, b_n), b_n = 1/(5500·(n/500)^{5/2})**. It is n-only, one rule for both signals, and V2-shaped. Median MSE ratio against his current prior: 0.95 / 0.90 / 0.53 at n = 500 / 1000 / 2000; max 1.13.
  - **FAILS:** Gamma(n, 1): median ×1.85, up to ×6.1, as predicted.
  - Theory's H-V2 specs are being re-run (after a submission bug).
  - **Candidate ranking for the λ prior (pending the full screen):**
    1. **A-rule** (data-favoured): it is the natural target for Tuesday's design-specific, floor-free theorem;
    2. H-V2 variants (pending);
    3. V0T (his prior + floor): has the audited theorem now, but uses a truncation, which is outside the families.
  - **No theorem covers the A-rule yet.** Class-wide it falls under the V2 impossibility, so the theorem must be design-specific.
- **New freedom (Felipe):** Gamma/IG hyperparameters may be deterministic functions of n (τ for σ), but no truncation. Candidates for the exact-Gibbs screen: H-V2 (Gamma(1, b₀(500/n)^{5/2})), H-V2-common, H-V2-shape2. The theorem for these without the floor needs the 'no-interpolation' evidence lemma (Fable B and Astra, in progress).

**Joint non-crossing (Theorem J, Fable B; PROVED and cross-family audited, Astra: ACCEPT WITH FIXES).** For a fixed number of levels, V0T\* and C\* transfer to the paper's joint non-crossing posterior at n^{−5/6}, with no extra separation condition: upper (A2) forces separated true quantiles, and the sup-norm conclusion makes the constraint asymptotically inactive. Caveat: at the paper's n the ordering is likely still active, so the theorem says the constraint does no harm asymptotically, not that it helps.

**General k:** rate n^{−(2k+1)/(2k+2)} at λ = n^{k+1/2}/V, for every k ≥ 1. **PROVED and cross-family audited** (Fable B; Astra: ACCEPT WITH FIXES). The Christoffel constant (k+1)² is proved for every degree. k = 1 has a thin but sufficient margin. At k = 0 only Theorem B survives.

**Extreme-τ limitation (stated honestly):** the planned floor-free A-rule theorem targets τ ∈ [0.05, 0.95], which covers every level of the paper's single-level grid. At τ = 0.01/0.99 the design condition fails for all three designs (β ≈ 13–14 against ≈ 6), so this route is expected NOT to cover those levels. **MEASURED (Engineering, internal; partial, n = 2000 only, ≤ 3 seeds, 2.5 core-h).** The prediction holds:
- In the three cells with β > 6, the A-rule's posterior λ collapses to ≈ 0.005× its prior mean.
- In the β ≈ 1.1 cell (Beta τ = 0.01), it sits at 12.6×.
- Caveat: the collapsed cells are mostly not converged.
- Caveat: coverage is ≈ 0.3 there under his priors too, with MSE ratio ≈ 1. So the extreme levels are hard for both priors, not only for the A-rule. V0T\* (with the floor) and Theorem J are not subject to this limitation.

**Caveat for the paper:** all theorems concern the POSTERIOR. His P-MALA λ is not converged at n ≥ 1000 (Engineering aca7214).

**Still arriving:** Fable A and an independent Astra co-prover (the no-floor method), the Astra audit of general k, the VP's reply, the V1/V2/V0T data.

---

**The method (Felipe's default).** σ ~ IG(0.1, 0.1), learned. λ ~ Gamma(1, b₀), learned, with b₀ = 1e-3 (VS) or 5e-4 (S). θ drawn by P-MALA. The posterior is π(θ, λ, σ | y) ∝ σ^{−n}e^{−Σρ_τ(yᵢ−θᵢ)/σ}·λ^m e^{−λ‖Dθ‖₁}·Gamma(λ)·IG(σ).

**Where the method lands** (MEASURED: σ sprint, `engineering/E07_Tuning_Free/sigma_sprint/sigma_sprint_table.md`, n = 500, 18 cells × 5 seeds):
- The learned σ is **0.13–0.64 × σ̄** in all 18 cells (0.13–0.23 at τ = 0.05 and 0.95).
- The learned λ is 9e2–2.6e4.
- Every arm with σ ≥ σ̄ fails Felipe's MSE bar:
  - with λ free, 1.1–24× worse;
  - with λσ matched, 1.3–14× worse (Engineering, 2026-11-23).

---

## (a) Where Theorem B uses σ > σ̄, and what for

**Answer.** σ > σ̄ enters Theorem B **only** through (EM), and (EM) is used **only** in Step 1, the expected numerator E₀N(E) = ∫_E ∏ᵢ E e^{−ωXᵢ(δᵢ)} dν. It is a requirement of the **proof technique** (integrating the likelihood ratio in expectation). It is not a requirement of contraction, and it is not used for coverage. Theorem B claims nothing about coverage.

**Status: PROVED** (by inspection of the advisor-checked chain, `T05_Proofs/THEOREM_B_COMPLETE.md`):
- **L6 (denominator): any ω.** Its event {T ≤ 1.44C₁nε² + nε²}, with T = ∫ℛ dν_G, does not involve σ at all.
- **Prior side (L3, L4, L4q, L4q-M, L5): σ-free.**
- **Step 2 (flat part) and Step 4:** σ enters only through constants (C₃(bω), C_pr/ω).
- **Step 1 is the only place (EM) is used.**

**Why the route needs it (PROVED at route level, modulo the routine shell prior-mass bound ν(S_M) ≥ e^{−Cnε²}, obtained as in L6 from L3/L4q).** Suppose ω > fᵢ(0)/(τ(1−τ)) for all i, for example i.i.d. noise with a density.
1. By L8′(c) (advisor-checked) there are δ₀ > 0 and κ₀ > 0 with E e^{−ωXᵢ(δ)} ≥ e^{κ₀ωδ²} for |δ| ≤ δ₀.
2. Hence, on the shell S_M := {Mε² < ‖δ‖²ₙ ≤ 2Mε², ‖δ‖∞ ≤ δ₀}, E₀N(S_M) ≥ e^{κ₀ωMnε²}·ν(S_M).
3. The Fubini bound therefore **grows** with M instead of decaying, so Step 1 cannot be completed by any choice of M.

This is a failure of the route, not a counterexample to contraction (see (b)).

**What σ̄ does mean: calibration, not rate.**
- σ̄ is exactly where the posterior spread (∝ σ/f) equals the sandwich variance of the posterior centre (τ(1−τ)/f²).
- Below σ̄ the posterior is narrower than the centre's sampling error, so credible bands under-cover. Coverage is never claimed.
- MEASURED, consistent with this:
  - the learned-σ coverage is 0.64–0.75 at τ = 0.05 and 0.95, where σ/σ̄ ≈ 0.14 (σ sprint);
  - with σ = 1.1σ̄ coverage is 0.88–1.00;
  - in E-06 the replicate variance divided by the posterior spread is ≈ π/2 in the null space but only 1.08 in the penalised rough directions at σ₀, so the miscalibration is mild where the penalty acts.

---

## (b) Contraction for fixed σ < σ̄

**Answer.**
- **Expected: yes, at the same n-rate, with σ-dependent constants. Status: OPEN as a theorem.**
- **No counterexample is known, and none is expected.** At fixed σ > 0 the posterior is log-concave, its mode is the PQTF estimator with penalty λσ, and its spread is ≍ (σ/f)^{5/6}λ^{−1/3}. Below σ̄ the binding term is the centre's sampling error, τ(1−τ)f^{−2}κ^{1/6}λ^{−1/3}, which has the **same order** λ^{−1/3}.
- **What breaks is only Step 1 of the proof** (see (a)).

**Evidence (MEASURED).**
- E-06: the σ₀ arm (σ₀ < σ̄, Gaussian) has the same contraction slopes as the 1.1σ̄ arm, with median slope difference −0.008 (`engineering/E06_Rate_Validation/tables/e06_slopes_all.csv`, 0796f00).
- E-02: the spread law λ^{−1/3} holds at σ₀.
- R-A2 (requested): fixed σ ≈ σ₀ and fixed λ, n = 500 and 2000.

**Proof routes for σ < σ̄** (they need **realized** rather than expected likelihood control):

| Route | Covers | Rate | Status |
|---|---|---|---|
| **C1. Gauge decomposition + uniform empirical process + integration against ν** (`T05_Proofs/parked/L10_stage1_NOTES.md`, main thread) | **every fixed σ > 0**, moment-free, **uniformly on compact σ-intervals** | With the in-house width (Lemma W): ‖δ‖²ₙ ≲ n^{1/7}λ^{−2/7}(log n)^{6/7} for λ ≫ n^{23/11}, i.e. **≈ n^{−4/7} at λ = n^{5/2}/V**. With an entropy width (if citable): λ^{−2/7}, for λ ≫ n^{21/11}, i.e. n^{−5/7}. **Byproduct: ‖δ‖∞ → 0 for every σ** (L10-I on the localized body) | SKETCH. **Every ingredient is in hand:** the width lemma is PROVED in-house (`T06_Alignment/W_width_lemma.md`, from L3's advisor-checked singular values); then symmetrization, Ledoux–Talagrand, Bousquet; L6 for the denominator (any σ); L10-I for the sup-norm; convexity along rays; the Gamma(m) tail of λ‖u‖₁. The cone integration remains to be written out and audited. |
| **C2. Hölder–Knight realized numerator (VP)** | every fixed σ > 0, uniformly on compact σ-intervals | optimal λ^{−1/3} | SKETCH, exponent level only (FINAL_fable_v3 §3b). Its remainder step needs localization, which C1 could supply. |
| C3. Tempering from B at σ′ > σ̄ | — | — | Dead end: it needs a uniform realized lower bound on ℛ over the bad set, which is exactly C1's content. |

**Why C1 is the natural aligned headline.**
- It works for **any** σ, so it covers σ₀ and the learned σ's range, with no (EM) and no moments.
- Its bounds are uniform over compact σ-intervals: e^{−ωx} is monotone in ω, and the events (L6's and the empirical-process event) are σ-free.
- It also yields sup-norm localization for every σ. That is exactly the input C2 needs, and also L10 for Theorem A.
- Its rate is suboptimal: n^{−4/7} with the in-house width, n^{−5/7} with an entropy width, against the optimal n^{−5/6}. C2, built on C1's localization, would restore the optimal rate.

---

## HEADLINE (updated 14:20 CT)

- **Theorem C\*, σ learned under the IG prior, at the oracle rate n^{−5/6}(log n)^{1/6}** (`T06_Alignment/THEOREM_C_STAR.md`).
  - No σ̄ condition, no exponential moments.
  - λ is deterministic at the oracle.
  - PROVED by assembling cross-audited parts: C1 (Astra), Lemma F, W′ and C2 (Opus), Lemma S (Opus).
- **Theorem V0T, Felipe's method plus a λ floor, σ AND λ learned, at n^{−4/7}(log n)^{6/7}** (`FABLE_V2T_proof.md`; Astra: ACCEPT WITH FIXES).
  - The floor never binds at n = 500 (measured).
  - **Theorem V0T\*: the same at the ORACLE RATE n^{−5/6}(log n)^{1/6}** (`FABLE_A_n56.md`). Fable proved it; Astra audited it: ACCEPT WITH FIXES, eight editorial findings, all held. **This is the headline for Felipe's method + floor.**
  - The V0T data test is built and awaits HQ's OK.

**Presentation caveat (Engineering, aca7214, V2_lambda_traces.png).** Every theorem here concerns the POSTERIOR. At n = 1000–2000 and the paper's run lengths, Felipe's P-MALA has not converged in λ (R̂ 1.3–2.3; on S at n = 2000, τ = ½, its λ sits about 20× below the exact posterior). Statements about his method at larger n should therefore say "the posterior it targets", and the paper should note that reaching it requires adequate run length or mixing. This is a sampler matter, not a theory gap.

## (c) Learned σ

**Decomposition (PROVED, one line).** For any interval I and any event E,

  Π(E | y) = ∫ Π_σ(E | y) Π(dσ | y) ≤ sup_{σ∈I} Π_σ(E | y) + Π(σ ∉ I | y).

Here Π_σ is the θ-posterior at fixed σ (λ fixed, or learned and mixed over). The σ^{−n} factor affects only the σ-marginal. Taking E₀ gives the route. **This is Astra's option (e)** (`writing/W01_Statements/reviews/REVIEW_astra.md`); it fits, and it needs:

1. **Uniform contraction over σ ∈ I, with I around σ₀ and therefore below σ̄ — OPEN**, the same as (b), uniformly.
   - *Inside the (EM) range, uniformity is PROVED here (not yet audited).* Let ω ∈ [ω₁, ω₂] with (EM) at ω₂ and common b; (EM) is monotone in σ by Jensen, so it then holds on the whole interval.
   - Since e^{−ωx} ≤ e^{−ω₁x} + e^{−ω₂x}, we get sup_ω N_ω(E) ≤ N_{ω₁}(E) + N_{ω₂}(E).
   - L6's event is σ-free, and L_ω ≥ ν(G)e^{−ω₂(1.44C₁+1)nε²}.
   - Hence E₀ sup_{ω∈[ω₁,ω₂]} Π_ω(E | y) → 0 for M > (2/b)(ω₂/ω₁)(1.44C₁ + 1 + C_pr/ω₂). This is **P2, proved**.
   - It covers learned σ only with a prior supported in the (EM) range, and Engineering's data rule that out on MSE.
   - **Below σ̄ the same trick applies to C1** (its bound is uniform in ω on compacts by the same monotonicity) — SKETCH.
2. **σ-posterior concentration and compact containment: Lemma S** (temporary Astra assistant, `T06_Alignment/astra_sigma_concentration.md`). **Verified step by step by Theory; cross-check by a second model pending.**
   - **§1, PROVED:** (H) ⇔ σ/s_n → 1, with s_n = σ₀,ₙ. This uses the IG(n + a, b + Q) conditional (Gamma pivot plus Chebyshev), a law of large numbers under row-average uniform integrability of the check loss (which covers the paper's Gaussian, Beta and mixture designs), and |Q − Q\*| ≤ n‖δ‖ₙ.
   - **§2, PROVED: compact containment** Π(σ ∉ [l, H₀] | y) → 0, with **no trend localization needed** (only (A3) and λ/log n → ∞):
     - a coarse evidence bound e^{−Cn}, taken at σ ∈ [1, 2];
     - the upper tail, via the flat integral ≤ C_k s³;
     - the lower tail, via data roughness: Q(θ) < qn forces ‖Dθ‖₁ ≥ nd/4, whose prior cost 2^m e^{−λnd/8} beats the O(n log n) IG moment.

     This breaks the circularity Astra flagged in the W-01 review.
   - **§3, PROVED: transfer.** If Hypothesis U holds (uniform fixed-σ localization on the whole of [l, H₀], with the supremum inside the expectation), then (H) and hence Lemma S follow.
   - **Hypothesis U is exactly what C1 states** (`T06_Alignment/C1_any_sigma.md`: E sup_{ω∈[ω₁,ω₂]} Π_ω(‖δ‖ₙ > r | y) → 0, which gives |Q − Q\*|/n ≤ ‖δ‖ₙ ≤ r → 0).
**MEASURED (Engineering R-A1/R-A2; exact Gibbs on Felipe's default posterior; 1bf027f; `engineering/E07_Tuning_Free/route_a/results/`).** 18 cells × n ∈ {500, 1000, 2000, 4000}, 5 seeds.
- **σ concentrates on σ₀,ₙ, as Lemma S predicts.**
  - The posterior median of σ/σ₀,ₙ is 0.95–1.02 for n ≥ 1000 in every cell (0.94–0.97 at τ = 0.05/0.95). The 90% interval width shrinks like n^{−0.50…−0.59}; at n = 4000 it is ≈ [0.93, 1.03].
  - σ/σ̄ is flat in n, at 0.14–0.63: it never approaches σ̄.
  - Cross-check at n = 500 against Felipe's P-MALA: σ agrees to 1.000 (range 0.94–1.07).
- **Fixed (σ, λ) at the posterior medians reproduces the learned method (R-A2):** MSE ratio 0.94–1.02, rough-radius ratio 0.83–1.02. This is empirical support for the disintegration route of Theorem C.
- **Caveat:** on S, Felipe's as-run P-MALA λ is under-converged (Gibbs/P-MALA λ 1.4–5.7×; ASIS is off at the paper's run length). λ statements on S therefore refer to the posterior, not to his chains.

3. **Combined (C1 + Lemma S): learned σ under Felipe's IG(0.1, 0.1) prior, deterministic λ ≍ n^{5/2}/V (more generally n^{23/11}(log n)^{12/11} ≪ λ ≪ n^{108/41}V^{−42/41}; corrected per Fable's final read):**
   - Π(‖θ − θ\*‖²ₙ > r² | y) → 0 with r² ≍ n^{1/7}λ^{−2/7}(log n)^{6/7}, i.e. n^{−4/7} at the oracle;
   - ‖θ − θ\*‖∞ → 0;
   - σ/σ₀,ₙ → 1 in posterior probability;
   - moment-free apart from uniform integrability, and with **no condition σ > σ̄**.

   **Status: ALL THREE PIECES ADVISOR-CHECKED.**
   - **W:** Astra, ACCEPT.
   - **C1:** Astra, REJECT as first written; all six findings verified and applied (the TV restriction Vλ = o(n³), the uniform L6 hypotheses); the oracle conclusion is confirmed.
   - **S:** verified by Theory; Opus, ACCEPT WITH FIXES (wording only; nine findings, all held and applied).

   **The combined theorem (C1 + S, learned σ, deterministic oracle λ) is therefore PROVED and cross-audited**, modulo the final assembly statement written up below. Opus #8 also confirms that it has to go through C1: Theorem B's route cannot give Hypothesis U. If these hold, this is a **σ-aligned theorem**: it covers the method's actual σ treatment, at a suboptimal rate.

---

## (d) λ: Gamma(1, b₀) with constant b₀

**Answer: NOT covered by the n^{−5/6} results, and not covered by "uniform over c in a compact set".**
- The conditional is λ | θ ~ Gamma(a₀ + m, b₀ + ‖Dθ‖₁).
- The fixed point is λ ≈ (0.27·n·κ^{1/6}/b₀)^{3/4} (T-03; confirmed in E-02 for b₀ ∝ n^{−2}, slope 2.257).
- With **constant** b₀ this gives **λ ∝ n^{3/4}**, so spread ∝ λ^{−1/3} ∝ **n^{−1/4}**.
- Writing b₀ = c·n^{−5/2}, the default corresponds at n = 500 to c ≈ 5.6e3 (VS) or 2.8e3 (S). As n grows at fixed b₀, c = b₀n^{5/2} → ∞, so it leaves every compact set.

**Status.**
- The mismatch is PROVED in this sense: a constant b₀ is not of the form c·n^{−5/2} with c bounded.
- The n^{3/4} growth and the n^{−1/4} rate are heuristic. They match the sprint λ̄ within a factor of 2–4 at n = 500, and R-A1-post will measure λ against n.
- A theorem for constant b₀ is P3(ii) ("(b₀/n)^{1/4}-type"): **OPEN**.

**MEASURED (R-A1): λ under constant b₀.** Median slope over n = 500–4000:
- **S: 0.76–0.94, consistent with n^{3/4}** (τ = ½: 0.78–0.81).
- VS: 1.09–1.69, plausibly pre-asymptotic, because of the bump.

The default method contracts more slowly than the oracle schedules. Rough q95 slopes are S −0.18 to −0.49 and VS −0.50 to −0.63, consistent with λ^{−1/3} ∝ n^{−1/4} plus bias on S.

**At the paper's n the learned λ is near the oracle (MEASURED against computed).** The oracle is n^{5/2}/V, with V from the statements note (Table simV): ≈ 3.6e4 (S, V ≈ 156) and ≈ 768 (VS, V ≈ 7276) at n = 500. The learned λ̄ in the σ sprint is 9e2–2.6e4 (S) and 1.1e3–3.1e3 (VS), i.e. 0.03–0.7× the oracle on S and 1.5–4× on VS. So the mismatch is asymptotic, not at the paper's n. The n^{3/4} growth with constant b₀ is MEASURED in E-02 (slope 0.745; statements note, line 485), and R-A1-post re-measures it under the default priors.

**New results on learned λ** (temporary Astra assistant, `T06_Alignment/astra_learned_lambda.md`; key steps re-derived by Theory; **advisor-checked by Opus**: ACCEPT / ACCEPT WITH FIXES, no gap; fixes logged in the file):
- **Under (EM), i.e. σ in Theorem B's range, learned λ is covered for both schedules (P3 essentially resolved):**
  - b₀ = c·n^{−5/2}: Δ²ₙ ≲ n^{−5/6}(log n)^{1/6}, and squared loss n^{−2/3}(log n)^{1/3};
  - **constant b₀ (Felipe's schedule): Δ²ₙ ≲ n^{−1/4}(log n)^{1/8}**, with posterior λ ≲ n^{3/4}(log n)^{1/8}. The matching lower bound on λ is open.
  - The proof mixes over λ inside Fubini. Constant b₀ is therefore covered as run, but only at the slow rate, and only where (EM) holds, i.e. not at the learned σ.
- **Counterexample (PROVED, verified by Theory).** With learned λ (either schedule) and a fixed σ that is very small, the posterior is inconsistent: λ stays bounded and the fit interpolates the data. The example uses uniform noise with σ ≲ 6·10⁻⁵, against σ₀ = 0.25.
  - So "learned λ, any fixed σ" is **false**, and a learned-λ result below σ̄ must use where the joint posterior puts σ.
  - Felipe's learned σ is ≈ σ₀, about 4000× larger than the counterexample's σ. **It is not a flagrant conflict with the method**, but it means the both-learned case needs a genuinely joint argument.
- **Both learned (σ and λ): OPEN.**
  - The exact decomposition is PROVED (d3): sup over σ ∈ I, λ ∈ J of Π_{σ,λ}(bad), plus the joint tails of λ and σ.
  - Missing: joint containment of λ in a window where C1 works (λ ≫ n^{23/11}). Under constant b₀ the posterior λ ≲ n^{3/4}, so C1 cannot apply.
  - **For Felipe's exact method (constant b₀, σ learned) there is currently no contraction theorem at any rate.**

**What would align λ.**
- **(i)** State the default as **b₀ = c·n^{−5/2} with c fixed** at its n = 500 value. This is identical at the paper's n and differs elsewhere. It needs P3 plus Engineering's paired check at other n, under Felipe's rules. Proposal: UNTESTED.
- **(ii)** A theorem for constant b₀ at the slower rate (P3 ii, OPEN).
- C1's window (λ ≫ n^{15/11}) does **not** contain λ ∝ n^{3/4}. So the λ alignment is a separate open problem from the σ alignment.

---

## (e) Route B: what a new method must satisfy for the theorem AS IT STANDS

Theorem B, with uniformity in σ as in (c)(1), needs:
1. **σ:** fixed, or with prior support, inside the (EM) range. For the paper's families this means at least σ > σ̄ (point density) at the worst design point, plus a two-sided exponential tail envelope (Proposition 1) or a ψ₁ bound with a σ threshold (Proposition 2).
2. **λ:** deterministic, of order n^{5/2}/V (or (n³/V)^{3/4}). Learned λ is pending P3.
3. **Noise:** light-tailed.

**Verdict (MEASURED).** Condition 1 is incompatible with Felipe's MSE bar: every σ ≥ σ̄ arm failed, including with λσ matched. With σ = 1.1σ̄ and λ learned under a prior centred to match λσ (c39b1c6, `sigma_sprint/arms/`), the median MSE ratio is 1.34–1.53 and 10–13 of 18 cells exceed 1.25. The mode matches, but at the 2–7× higher temperature the posterior mean is rougher (‖D³θ̂‖₁ 1.3–4.5×). **No Route-B method can align with Theorem B as it stands.** Engineering has been told not to spend compute on it. Route B becomes viable only if the theorem moves below σ̄ (C1 or C2). Then the condition would be: σ in a compact interval around σ₀, and λ in C1's window.

---

## Variants the theorems cover (Felipe's clarification, 2026-11-23)

**Rule.** A theorem may cover a variant of Felipe's method only if the variant:
1. matches his sampler on paired MSE (median ratio ≤ 1.10, no cell > 1.25);
2. satisfies the theorem's assumptions as run;
3. has a working joint non-crossing version.

Neither σ nor λ may be user-set, and they may not both be fixed. Every variant below is **UNTESTED** until Engineering's paired runs pass.

| Variant | Change to his method | Theorem that covers it exactly | Rate | Status | Test needed (Engineering) |
|---|---|---|---|---|---|
| **V0** = his method | none | — | — | **no theorem at any rate** (λ ∝ n^{3/4} is outside every window) | — |
| **V1** | σ ~ IG learned (unchanged); **λ fixed by a deterministic rule** λₙ = κ·n^{5/2} | **Theorem C** (PROVED, cross-audited inputs) | n^{−4/7}(log n)^{6/7} | Theorem done | **Expected to fail on data.** The oracle λ differs ~46× between S and VS (V ≈ 156 vs 7276), so one κ cannot suit both, while the learned λ adapts. Cheap to confirm: one paired run at n = 500 with κ set at the geometric middle. Pilot cost ≈ 1 core-h. |
| **V2 (recommended)** | σ ~ IG learned (unchanged); **λ ~ Gamma(1, b₀,ₙ) with b₀,ₙ = b₀·(500/n)^{5/2}**, b₀ = 1e-3 (VS) or 5e-4 (S). **Identical to his method at n = 500.** | Needs Theorem C extended to learned λ: the joint decomposition (d3, PROVED); C1 uniform over a λ-window J above n^{23/11} (SKETCH: use T₀ = Tn³/inf J); and **joint posterior containment of λ in J — OPEN, the Tuesday crux** | n^{−4/7}(log n)^{6/7} now; n^{−5/6} with Fable's F → C2 route (CONJECTURE) | Within reach Tuesday (Fable follow-up running) | At n = 500 it is identical, so it passes trivially. Paired runs at **n = 1000 and 2000** on the paper grid against his constant-b₀ sampler (MSE bar, coverage, ESS of log λ), plus **the joint version** (per-level b₀,ₙ) at levels 0.90–0.99. Check P-MALA convergence: at n = 2000, b₀,ₙ ≈ 3e-5 (E-05 saw non-convergence only at much smaller b₀ ∝ n^{−2}). |
| **V2T** | V2 plus a lower truncation of the λ-prior at κ₋·n^{5/2}, with κ₋ chosen so the truncation never binds at n = 500 (κ₋ = 1.6e-5, ten times below 923/500^{5/2}, the smallest learned λ in the sprint, which leaves margin for the n^{21/8} versus n^{5/2} growth). Under V2's schedule the posterior λ ∝ n^{21/8} grows faster than n^{5/2}, so it should not bind at larger n either. | Mixed over λ at fixed σ with **one fixed C1 body at the lower endpoint**: λ‖u‖₁ ~ Gamma(m) for every λ ≥ Λ₋ makes the TV cone uniform. Astra's mixed denominator; Lemma S uniform in λ (monotone in λ, evaluated at Λ₋); no upper containment needed (Fable, `FABLE_joint_V2.md`) | n^{−4/7}(log n)^{6/7}; n^{−5/6} via F → C2 | **SKETCH; closable with existing lemmas (Tuesday)**. Untruncated V2 needs a lower-λ evidence bound that Fable conjectures requires σ₀ > σ̄/6 (fails for Gaussian at τ = 0.05: 0.149) | As V2, plus: report the posterior mass below κ₋·n^{5/2}. **MEASURED at n = 500 (R-A1 posterior, 90 fits):** the smallest 5% quantile of λ is 267, three times the floor of 89, so **V2T = his method at n = 500.** Under CONSTANT b₀ the floor would bind by n = 4000 (ratio 0.45), so the floor is only coherent together with V2's schedule. Under V2: pending (V2 pilot, n = 1000/2000). |
| **V0T (smallest change)** | **His exact method (constant b₀) + λ floor λ ≥ κ₋n^{5/2}** (κ₋ = 1.6e-5). Identical at n = 500 (MEASURED: min q05 λ = 267 > floor 89). Under constant b₀ the floor binds from n ≈ 4000, where it pins λ near κ₋n^{5/2} instead of the n^{3/4} growth. | **Fable's V2T proof covers it** (`FABLE_V2T_proof.md`): the floor does the work. The truncated exponential is memoryless, so the hyperprior mass of [Λ₋, 2Λ₋] is ≥ a constant for any b₀. | n^{−4/7}(log n)^{6/7} | **PROVED and cross-audited** (Astra: ACCEPT WITH FIXES; ten editorial findings, all held; `reviews/AUDIT_astra_V2T.md`). Rate n^{−4/7}(log n)^{6/7}; n^{−5/6} via Lemma F + C2 (Opus audit running). | Paired test of his method against his method + floor at **n = 2000 and 4000**, where it may bind: MSE bar, coverage; plus the joint version. To be specified once the audit passes. |
| V3 | σ learned; λ from an automatic empirical-Bayes plug-in (marginal-likelihood maximiser) | Needs C1 uniform in λ plus plug-in concentration | as C | SKETCH | Only if V2 fails on data. |

**Why V2 is the smallest change.**
- It keeps the Gamma learning of λ and his priors, and it is his exact default at n = 500.
- Only the n-scaling of b₀ changes, from constant to ∝ n^{−5/2}. Under the T-03 fixed point this moves the posterior λ from ∝ n^{3/4} (outside every window) to ∝ n^{21/8}. That is inside C1's window n^{23/11} ≪ λ ≪ n³/V.
- Under (EM) the same schedule is already PROVED at n^{−5/6} (Astra, Opus-audited). The missing piece is the below-σ̄ version.

---

## Pending inputs

- Self-check of C1 (`T06_Alignment/C1_any_sigma.md`), then a cross-model audit of C1, W and S (Fable on CP from 15:15 CT).

- VP consultation on C1, C2 and (c)(2): due 16:30 CT.
- Engineering R-A1-post + R-A2 (≈ 5.5 core-h; awaiting HQ's compute OK): σ and λ concentration against n, and fixed σ ≈ σ₀.
- Audit of the P2 uniformity proof in (c)(1): to be requested from HQ (low priority: it only covers the (EM) range).
