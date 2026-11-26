# W-07: rebuild of Appendices C, D and E (inventory, outline and deletion list)

Written by Writing on 2026-11-26 from HEAD 6f38ba9 (main.pdf, 67 pp). **This needs approval from HQ and Felipe before any rewriting.**

## 1. Pages

| Part | Now | Target |
|---|---|---|
| C, Computational details | pp. 42–53, about 12 pp | **≤ 6 pp** |
| D, Additional simulation results | pp. 54–61, 8 pp (4 of them hold a single table each) | **≤ 3 pp** |
| E, Additional real-data figures | pp. 62–64, 3 pp | **≤ 2 pp** |
| C to E | **about 23 pp** (26 counting the references on pp. 65–67) | **≤ 11 pp** (about 14 with the references), so the paper ends near p. 55 |

Appendix A (proofs) is unchanged: Lean-verified, byte-identical, and a diff is supplied at merge. Appendix B gets alignment checks only. It needs no change so far: V* = n²‖D^{(3)}θ*‖₁ is consistent with TV^{(r)} at r = 3.

## 2. Item map: keep, merge or delete

### Appendix C (currently C.1–C.11, with Table 9)
| Now | Action |
|---|---|
| C.1 Full conditional distributions | **Keep**, tightened |
| C.2 Proximal map, individual sampler (ADMM) | **Keep** the algorithm, its cost, and why determinism makes the MH correction exact. **Delete** "the simulations use the original form; in ten replications the MSE does not differ…" (history). Which form each experiment used moves to the new settings table (C.6) |
| C.3 Proximal map, joint sampler | **Keep** stage 1, the stage-2 interior-point method, initialization and stopping, and determinism. **Delete** "ADMM with a box splitting" (a tried-and-rejected narrative). **Condense** "Verification" (two long paragraphs of test numbers) into 3–4 sentences in C.7 |
| C.4 Interweaving step (with the constrained version) | **Keep** |
| C.5 Initialization and warm-up, C.6 Step-size adaptation, C.7 Safeguards | **Merge** into one subsection, "Initialization, adaptation and safeguards". The final sentence of the safeguard text, on what the MH argument covers, stays |
| C.8 Run length | **Replace** with a "Settings of each experiment" table (see §4) and the interior-run diagnostics (acceptance 0.49–0.52, 153 s, ESS) |
| C.9 Updates used for the interior simulations | **Keep the content**, shortened, as "Sampler version used for the interior simulations" (the later version, with every difference stated). E-18 will add the air-quality results here (placeholder) |
| C.10 Choices behind the default settings, **Table 9** (Candidate changes) | **Delete** (development history), except for two sentences that are method, not history: (a) why the noise is added after the proximal map (validity of the MH density); (b) the defaults κ = 3 and a_σ = b_σ = 0.1, which move to the settings table. Deleted: the pilot anecdotes, the κ sweep, the Gamma(1,1) anecdote, the b0 = 1e-4 sensitivity run, the Park–Casella σ-scaled prior anecdote, the "continuous adaptation" history, and all of Table 9 |
| C.11 Exactness checks | **Keep**, condensed: one list for the individual sampler, one for the joint sampler, and a 3–4 sentence summary of the box-solver verification |

### Appendix D (currently D.1, D.2 and Tables 10–17, one table per page)
| Now | Action |
|---|---|
| Tables 10/11 (VS MAD, VS MCIW) | **Merge** into one table: MAD and MCIW side by side for the 3 noise families × 4 methods × 5 levels (ADMM MCIW "–") |
| Tables 12/13 (S MAD, S MCIW) | **Merge** in the same way. The VS and S tables share one page |
| Tables 14–17 (crossings: neighboring and all, VS and S) | **Merge** into one table per signal, with the neighboring and all counts side by side (4 + 4 columns). Both share one page |
| Prose of D.1/D.2 | Shortened. The crossing definition is kept once. Settings stated in §4 are not repeated |
| (new) Air-quality simulation | **Placeholder** for E-18 material (§4.3, Table 2), if any |

### Appendix E (currently E.1, E.2 and Figures 6–9)
| Now | Action |
|---|---|
| E.1 Figure 6 (ADMM SPod fits, 2 stacked panels) | **Keep**, as a compact two-panel figure. Its material is marked as a **placeholder** until the E-18 SPod refit; §4.4.1 is not touched |
| E.2 Figures 7–9 (PMALA girls, LMS boys, LMS girls, one full-width figure each) | **Merge** into one three-panel grid figure on one page |
| The `\iffalse` Nile block (5 figures, never printed; Munich/Nile leftovers) | **Delete** from the source. This has no effect on the PDF |

## 3. Deletion list (for approval)
1. Table 9, "Candidate changes to Bayesian-PMALA", and its paragraph (C.10).
2. All of C.10, "Choices behind the default settings": the pilot anecdotes (identity metric with zero acceptance, the κ sweep 3–10, Gamma(1,1) settling at λ 50–75), the b0 = 1e-4 sensitivity run, the Park–Casella σ-scaled prior anecdote, "smoothing the check loss performed worse", the continuous-adaptation history, and the safeguards history. Two method sentences are kept, as noted in the map.
3. C.3 "ADMM with a box splitting" (the rejected ADMM variant, its error figures, over-relaxation, the active-set scheme).
4. C.2's original-vs-increment form comparison ("ten replications…, geometric mean 1.01").
5. C.3 "Verification" detail, condensed from about 1 page to 3–4 sentences. The 72 and 108 problem results are kept only as their bottom line.
6. The `\iffalse` Nile/Munich block in the E source, which is not printed.
7. **Proposed, needs approval:** drop the all-zero "Joint sampler" row from the crossing tables and say instead in the caption that it is zero in every cell. Every number is unchanged; this is presentation only.

**No MSE, MAD, MCIW or crossing table and no competing-fit figure is deleted.** They are only merged or resized.

## 4. Faithfulness: which sampler and which settings produced each result
This becomes a single table in new C.6. Facts are from the experiments/ and engineering/ READMEs. Items marked **?** go to Engineering via HQ.

| Result | Sampler version | b0 (λ rate) | Sweeps / burn-in | Interweaving | Acceptance target | ADMM form |
|---|---|---|---|---|---|---|
| Interior, §4.1 Tables 1/2 + D (E-14, 63f2a56) | **later version** (data-based start, λ held in warm-up, spline-held interweaving q = 10/20/40, safeguards) | 1e-3 VS, 5e-4 S | 30000 / 10000 | spline-held | 0.5 | **?** |
| Extreme, individual (§4.2 Tables 3/4, crossings) | Oct-7/21 legacy snapshot (E-15 PROVENANCE) | **0.01 VS, 0.001 S** | **10000 / 3000** | **off** | **0.55** | **?** (original, presumably) |
| Extreme, joint sampler (Oct-2 run) | legacy joint sampler | **0.01** (its README warns that "the paper states a 0.001 rate") | 30000 / 10000, 200 warm | on | 0.5 | **?** |
| Air simulation, §4.3 Table 2 | **pending E-18** (placeholder) | | | | | |
| SPod, §4.4.1 / E.1 | **pending E-18** (placeholder; §4.4.1 currently says γ = 0.1 and "smoothing parameter ε = 0.01") | | 6000 / 1000 | | | increment |
| Growth, §4.4.2 / E.2 | **?** (individual sampler; generator missing per experiments/README) | Gamma(1, √G) | 6000 / 1000 | **?** | **?** | **?** |
| Scalability, §4.2 timings | **?** | | | | | |

**Gaps in the current appendix that the rebuild fixes:**
- C.8 says "each run uses 30000 sweeps": this is false for the extreme individual runs (10000/3000) and for SPod and growth (6000/1000).
- §2 says the step size adapts toward 0.5 and that interweaving follows the λ draw, but the extreme individual runs used 0.55 and no interweaving.
- C.10 calls b0 = 1e-2 the default, but the extreme S individual runs used 1e-3.

**These will all be stated plainly in the settings table.**

## 5. Decisions needed
1. **Base algorithm (recommended: A).**
   - **A.** C describes the algorithm of §2 (θ⁰ = y, null-space interweaving), and a short subsection states the later version used for the interior runs (and for air quality, after E-18). **No §2 change.**
   - **B.** C describes the later version as "the" algorithm. This would need §2 edits (Algorithm 1 line "Initialize θ⁽⁰⁾ = y", the interweaving sentence in §2), which go beyond pointer fixes.
2. **Precision.** The main-text tables are not consistent: interior MSE uses 6 decimals, extreme MSE 4.
   - Proposal for the appendix: **4 decimals** for MAD and MCIW (matching extreme MSE and the numbers quoted in the text), **1 decimal** for crossing counts (now 2), stated once in a note.
   - Whether to also round main Tables 1/2 is Felipe's call. At 4 decimals the small Beta MSEs (0.000512) become 0.0005, so a ×10³ scaling would be the alternative.
3. Deletion item 7 (the joint-sampler zero rows).

## 6. Inbound references (all preserved)
Each label is kept on its new home, so the main text needs **no edits** apart from any listed at merge.
- From methodology.tex: app:pmala:{conditionals, admm, boxsolver, asis, init, adapt, safeguards}.
- From simulations.tex: app:simulation_results, app:sim:individual:{vs,smooth}, app:sim:joint_extreme, app:pmala, app:pmala:interior.
- From data_application.tex: app:spod_admm, fig:spod_detrended_admm, app:growth, fig:growth_girls, fig:growth_lms_girls.
- From introduction.tex: app:pmala, app:assumptions.
- From numerical.tex: app:simulation_results, app:data_plots.
- Appendix A has no references into C–E.

Where sections merge, the old labels stay as aliases on the merged section: app:pmala:init, app:pmala:adapt and app:pmala:safeguards on the new section, and the table and figure labels on the merged floats. Labels left without a reference (app:pmala:runlength, app:pmala:changes, tab:pmala_variants, the Nile figure labels) are removed.

## 7. Process
- Worktree `w07-appendix`, separate from the shared tree. Lean and Theory packets still go to main first, and the branch is rebased onto them.
- Opus (Claude Personal) rebuilds C. Neon rebuilds D and E. Sol (codex 6.2, fresh session) does the alignment and layout audit. Haiku/Sonnet does the label and reference sweeps.
- Gates before merge:
  - notation and defaults match §2–§4;
  - every number in the main text matches the appendix;
  - no undefined, dangling or orphan labels;
  - the build is clean, with no overfull boxes;
  - a page-by-page visual pass, with no stranded floats or `\clearpage`;
  - Appendix A is byte-identical.
- At merge: report the page counts per appendix (old and new), the old→new outline, the deletion list and the hash.
