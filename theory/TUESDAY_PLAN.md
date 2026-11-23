# Tuesday 24 November: re-aimed attack plan (Theory)

*Theory Department, 2026-11-23. FINAL (written 16:50 CT, ahead of the 21:00 deadline). INTERNAL, for HQ.*

## 0. Aim and the state at the end of Monday

**The method stays Felipe's** (route B is closed): σ ~ IG(0.1, 0.1) learned, λ learned under a Gamma prior, θ drawn by P-MALA. All theorems concern the posterior. No theory claim is built on his sampler's outputs.

**Headline, proved and cross-family audited.** V0T\* (his method plus a λ floor): rate n^{−5/6}(log n)^{1/6}, matched by Theorem LB at the oracle. Also C\*, J and general k. Data gate: the individual test is met; the joint τ = 0.99 cell is unresolved.

**Target for Tuesday: the A-rule without a floor** (λ ~ Gamma(1, 1/(5500(n/500)^{5/2})), no truncation), at τ ∈ [0.05, 0.95] on the paper's three designs.
- Its data gate is posterior-level only: exact sampler, both arms. With his sampler it is UNTESTED.
- **It is not a theorem yet.** The chain to Corollary P's (LT) at Λ₋ = c₋n^{5/2}(log n)^{−1/2} stands as follows.

| Link | λ range / step | Status |
|---|---|---|
| L1 | tiny λ | PROVED, class-wide; **not audited** |
| L2 | bounded λ (DC) | **AUDITED** for all three designs at τ ∈ {0.05, …, 0.95} (`FABLE_B_L2_analysis.md`: DC-G 845116d, DC-W 59752f3) |
| L3 | interpolating fits, extreme scales | PROVED, class-wide; **not audited** |
| L4a | [ℓ₀, n^{3/2}] | **OPEN**: named assumption with data check (`T06_Alignment/L4a_assumption.md`) |
| L4b | [n^{3/2}, n^{21/11}] (min-density) or [n^{3/2}, n^{99/43}] (cells that need β̄) | **OPEN** as a posterior statement. Fixed (σ, λ): AUDITED to n^{9/5}; to n^{26/17} under (ML) + β(L) < 6 or under (XE) (`FABLE_A_L4b.md`, 1af9f8b, 58a0da8) |
| L5 | [n^{21/11}, Λ₋] min-density; [n^{99/43}, Λ₋] averaged β̄ | **AUDITED** (Theorems U, U-σ; averaged β̄: a5453af; extension: 1af9f8b) |
| L6 | L1–L5 ⇒ (LT) | assembly PROVED given its inputs; **not audited** |
| L7 | (LT) ⇒ rate n^{−5/6}(log n)^{1/3} (V0T\* with an n-dependent floor) | **AUDITED** (a43bdcf) |

**One shared missing input.** L4a, the posterior version of L4b below n^{21/11}, and the hypothesis (XE) all reduce to a **posterior sup-norm / forgetting lemma at the bandwidth scale**.
- Fable B's §§10–16 (`FABLE_B_supnorm.md`) give the entry points:
  - the strict Brascamp–Lieb gap;
  - spike removal (B10) and most windows in the bulk (B11);
  - balance in probability on clean windows (B14);
  - the scale-gap stopping point, with the conjecture (SGN).
- Fable A's §9 calls the same input (FG).

## 1. Tuesday pieces: prover, auditor, fallback, account

The rule throughout: Fable and Astra prove, and the other family audits. Opus, Sonnet and Haiku do support work only. Effort is high, never above.

| # | Piece | Why | Prover | Auditor | Fallback | Account |
|---|---|---|---|---|---|---|
| T1 | **Audit L1, L3, L6** (`FABLE_A_Arule_lowertail.md` §2, §5) and **Lemma RSB / Prop. LT-EM** | three links are proved but unaudited; cheap | (Fable A, written) | **Astra** | — | Codex |
| T2 | **Posterior sup-norm / forgetting lemma** at the bandwidth scale. Entry, in order (Fable B's proposal): (i) **(SGN)**, square-root run-sums of the posterior signs of Dθ over runs ≈ h; (ii) (B2) wide runs on dense good blocks; (iii) (G2) the energy of exceptional blocks | the one input that unlocks L4a, L4b and (XE) | **Fable B** (CP) | Astra | named assumption (FG), with draws data | CP |
| T3 | **Uniformity of the fixed-pair bound on [n^{9/5}, n^{21/11}]** (LO-low → U-low): Theorem U's grid, interpolation and per-node tails, carried to the new window | turns the audited fixed-pair result into a posterior statement on that range | **Fable A** (CP) | Astra | the posterior band starts at n^{21/11} | CP |
| T4 | **Averaged-β̄ version below n^{99/43}** (L4b / LO-low with weights fᵢ, as in `FABLE_B_averaged_beta.md` §7) | brings Gaussian 0.05/0.95 and Beta 0.95 to n^{21/11} | **Astra** (fresh eyes on Fable B's weighted machinery) | Fable B | those cells keep [n^{3/2}, n^{99/43}] as the assumed range | Codex |
| T5 | **Clean rewrites** of LO, U, L2 (DC-G, DC-W), L4b and L7, with every audit fix written in full; U's §3 re-read against the fixed LO text | HQ: the paper version must contain the fixes | **Fable A** (LO, U, L4b, L7), **Fable B** (L2) | Astra re-reads the diffs | — | CP |
| T6 | **(XE) / the sliver [n^{3/2}, n^{26/17}]**, only if T2 lands | completes L4b | Fable A | Astra | named assumption | CP |

**Order.**
- **Morning:** T1 and T4 on Codex in parallel; T2 and T3 on CP in parallel. T2 is the main risk and gets the strongest slot.
- **Afternoon:** T5, then T6 if T2 lands.

**What "headline proved" means.**
- L1, L3 and L6 audited (T1).
- L4a and L4b closed through T2 + T3 (+ T6).
- Without T2, the paper states the **conditional A-rule theorem**: (L4a) and the remaining L4b range are named assumptions with draws data, next to the unconditional **V0T\*** (fallback F1) and **C\*** (F2).

## 2. Data inputs (Engineering), all to be priced first

| Item | Serves | Status |
|---|---|---|
| **A-rule λ draws** (A_H1 re-run with draws saved; S and VS × three designs × τ ∈ {0.05, 0.5, 0.95} × n ∈ {500, 1000, 2000, 4000}, 3 seeds) | L4a's empirical check, plus three internal diagnostics on the same draws: covariance eigenvalue vs 1/(ωf), windowed sign balance |mean − τ| ≤ 8/K³, (SGN) run-sums | to price; priority **S at τ = 0.95** (watch item) |
| A-rule P-MALA paired test, and a joint version | Felipe's data gate for adopting the A-rule | Engineering |
| V2 pilot, H-V2 screen re-runs | candidate ranking | running |

No compute runs tonight.

## 3. Secondary pieces (only if a slot frees up)

| # | Piece | Prover | Auditor |
|---|---|---|---|
| S1 | LB around the posterior's own centre | Fable | Astra |
| S2 | Necessity half of β ≈ 6 (β > 6 ⇒ λ drifts): would make the extreme-τ limitation a theorem; the data point that way | Astra | Fable |
| S3 | No-floor sufficiency on the paper designs | Astra | Fable |
| S4 | Joint small-gap levels (Theorem J's caveat) | Fable | Astra |
| S5 | Posterior-mean corollary (old P4) | Fable | Astra |

## 4. Old P-items

| Item | Decision |
|---|---|
| P1: log-concave ⇒ (EM) for σ > σ̄ | **RETIRED**: the method lives at 0.13–0.64·σ̄ |
| P2: uniform in σ on compacts | **DONE** (C1/C2) |
| P3: learned λ | **DONE with a floor** (V0T\*); the floor-free version is the target |
| P4: n^{−2/3} rate; posterior-mean corollary | rate SUPERSEDED; the corollary is S5, low tier |
| P5: general k | **DONE** (audited) |
| P6: n^{9/4} self-tuning | **RETIRED** (measured: n^{3/4} under constant b₀) |
| P7: size of n₀(V) | KEPT, low tier |

## 5. Budget split

**Accounts:**
- **Fable proving on CP.** Since 16:00 Felipe's handoff moved the manager threads to CP; the Fable setup is unchanged.
- **Astra on Codex.** Today it ran 11 audits plus one co-proof.
- **No CT or CW use** unless HQ approves. CT was used heavily today until 16:55.

**Today's headroom figures** (from this morning; please confirm current values, since today's heavy use is not reflected): CT ≈ 90% of weekly used; CW ≈ 93%; CP 3 resets from 08:00; Codex 2 resets.

**Tuesday load:**
- two Fable threads on CP (T2, T3, then T5);
- Astra on Codex: T1, T4, and audits as results land, about 4–6 tasks.

**Alerting:** I alert HQ when any account passes 80% of what remains, and before using the second Codex reset.
