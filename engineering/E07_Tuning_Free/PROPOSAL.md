# E-07 Efficient, tuning-free individual sampler: revised plan (v2)

*Engineering, 2026-11-23. This revises v1 (`PROPOSAL_v1.md`) after Felipe's ruling (HQ, 11-23) and Astra's HQ review (`hq_reviews/ASTRA_E07.md`).*
- **Status:** a plan for HQ approval. Nothing beyond smoke tests runs until HQ approves the staged budget (§6).
- **Paper sampler:** untouched. All work is on copies.

## 0. What Felipe asked for, and how this plan answers it
1. **The goal is an efficient sampler that scales in n and in the joint-quantile setting, not P-MALA as such** (introduction, methodology §joint, scalability, appendix_pmala). Every change below is judged by:
   - accuracy and mixing against the **exact code used in the paper**;
   - cost per sweep and per effective sample as n grows;
   - whether it extends to the ordered, box-constrained joint sampler (§3).
2. **σ fixed is accepted if the user never chooses it.**
   - **F-auto** (an automatic data-driven σ) is the default candidate.
   - **F-oracle** (1.1σ̄) is used for simulation validation only.
   - **P** (a σ prior) is a comparison arm.
3. **Evidence bar:** a change is adopted only with a lot of clear evidence that it beats the original. Each change is ablated alone (§2). **Anything that does not clearly win is dropped.**
4. **Diagnostics come first** (Astra's findings, §1). No comparison is decided on the prototype's stopping rule.

## 1. Stage S0: validated diagnostics (before any comparison)
**Prototype defects (Astra) and their fixes:**

| Defect | Fix |
|---|---|
| Sums single-chain ESS | Use multichain bulk and tail ESS on rank-normalised draws (Vehtari, Gelman, Simpson, Carpenter & Bürkner 2021), from the `posterior` package. It is not installed on NOTS or Owls, so it goes into the BQTF R library on `/projects`. If installation fails, port its reference implementation and test it against the published examples |
| No folded R̂ | R̂ = max(bulk rank-normalised split-R̂, folded split-R̂) |
| Undefined R̂ mapped to 1 | Report NA, and treat it as not converged |
| Mixed retention strides when the history is re-thinned | Keep iteration indices. Thin once, at a fixed stride chosen up front, and estimate bands from equally strided post-warm-up draws only |
| Only λ starts varied | Vary θ starts as well: y, a MAP, and a jittered MAP |
| Cap hits | Flag fits that reach the sweep cap; never report them as converged |

**Validation:**
- AR(1) chains with known ESS, as a unit test.
- **Long independent reference runs** of every sampler on 6 benchmark cells (200k sweeps for the original, 50k for the new). Check that the stopped estimates and the 2.5%/97.5% band endpoints lie within the combined MCSE.

**Cost:** about 2 core-h.

## 2. The changes, each ablated alone
Arms on the same data and seeds:

| Arm | θ move | λ move | λ prior | σ | Isolates |
|---|---|---|---|---|---|
| **O** | paper P-MALA (curvature metric, ADMM prox) | conjugate + ASIS (VS) / none (S), as in the paper | paper's b₀ per signal | IG(0.1, 0.1) | the published sampler |
| **C** | paper P-MALA | conjugate + **collapsed (λ, θ) block** | paper's | paper's | the collapsed λ block alone |
| **X** | **exact preconditioned-Langevin draw** (h = 2) | conjugate + ASIS / none, as in the paper | paper's | paper's | the θ move alone |
| **N** | exact draw | collapsed block | paper's | paper's | both sampler changes (the same target as O) |
| **N-λ** | exact | collapsed | **Gamma(2, s_y·n^{−5/2})** | paper's | the λ prior alone |
| **N-F** | exact | collapsed | Gamma(2, s_y·n^{−5/2}) | **F-auto** (and F-oracle in simulation) | the σ rule |
| **N-P** | exact | collapsed | Gamma(2, s_y·n^{−5/2}) | IG(0.1, 0.1·s_y), or the VP prior when it arrives | the σ-prior arm |

- **Same-target arms** (O, C, X, N) must agree within MCSE. Only speed and mixing may differ.
- **Prior and σ arms** change the posterior. They are judged on accuracy, coverage and width.

**Smoke evidence already in hand** (G0, cancelled at 9.5 min on HQ's instruction; 3 seeds; **prototype diagnostics, so not decisive**):
- **On the paper's own data and priors, O's ESS(log λ) is 1.4–17 in 20–30k sweeps.** The C arm with 4 chains (R̂ ≤ 1.01) gives 600–2500.
- **VS (ASIS on in the paper):** O and C agree within O's Monte Carlo noise. λ̄ ratios are 0.67–1.14, and MSE differs by −16% to +9% with no consistent sign.
- **S (ASIS off in the paper):** O's λ̄ is consistently below C's, by 1.4–2.7× in all 6 paired fits. O's MSE is higher in all 6, by 13–60% (τ = ½: 0.0028/0.0048/0.0039 against 0.0018/0.0041/0.0029).
- This looks like the E-05 mechanism: λ starts low and drifts up slowly.
- **If S1 confirms it with validated diagnostics, the paper's S results are under-converged in λ. That is a finding HQ and Felipe need, whatever is adopted.**

## 3. Joint non-crossing extension of each change (Felipe's requirement; ALL UNTESTED)
- **Requirement:** a change qualifies for the paper only if a working joint, non-crossing extension exists and holds up head to head against Felipe's original joint sampler (`method/joint/Joint_Sampler_PMALA_Augmented.R`).
- **Joint design to test on:** VS, n = 500 × 3 noises × τ ∈ {0.90, 0.93, 0.96, 0.97, 0.98, 0.99}, 30k sweeps.
- **Scheduled after S1, not today.**
- **What the original does:** level j's θⱼ is drawn from its conditional restricted to the box Bⱼ = [θⱼ₋₁, θⱼ₊₁], held fixed during level j's update. It uses P-MALA with a box-constrained prox (interior point), rejecting proposals outside Bⱼ, plus a constrained ASIS.
- **The exact fact every design below uses:** let q be a proposal that is reversible with respect to the *unconstrained* conditional π. Then for the target π·1_B, MH acceptance is exactly 1_B(θ′), and the truncation constant cancels.

| Change | Joint design (concrete) | What could make it fail | Pilot that tests it (cost, UNTESTED) |
|---|---|---|---|
| **θ move** (augmented Gibbs) | Per level, given (zⱼ, sⱼ, λⱼ, σⱼ), the conditional is N(μⱼ, Pⱼ⁻¹) truncated to Bⱼ. Use the implicit-Langevin (pCN) proposal θ′ = μⱼ + r(θⱼ − μⱼ) + √(1−r²)Pⱼ^{−1/2}ξ and accept iff θ′ ∈ Bⱼ. Adapt r in burn-in toward an acceptance rate of ≈ 0.3; r = 0 (the exact draw) when the box is slack. The cost is one banded QR per proposal, O(n) | At tight levels (0.97–0.99, gaps ≈ 0.02–0.05 σ-units) the acceptance of a full n-vector inside the box may collapse; then r → 1 and the move is slow. **Fallback:** a block-wise version that moves windows of ≈ 50 coordinates with the conditional Gaussian of the window (banded), each accepted iff inside the box | Acceptance and ESS/s per level on the joint design, 3 noises × 2 seeds, against the original joint sampler. ≈ 3 core-h (the original joint cost is not yet measured; estimate 6 levels × ≈ 5–8 ms/sweep × 30k ≈ 15–25 min per fit, so 6 fits ≈ 2 h; the new move ≈ 1 h) |
| **Collapsed (λⱼ, θⱼ) block** | Draw (λⱼ′, θⱼ′) from the unconstrained collapsed block (slice on log λ with θ integrated out, then the exact θ draw). Use it as an independence proposal for the box-restricted target, accepted iff θⱼ′ ∈ Bⱼ (exact). When it is rejected, keep the current (λⱼ, θⱼ) and still do the ordinary conjugate λ \| θ draw | The independence proposal ignores the box, so its acceptance equals P(θ ∈ Bⱼ) under the unconstrained conditional, which may be ≈ 0 at tight levels. Then λ mixing falls back to the conjugate draw alone (the E-05 problem). **Fallback:** the paper's constrained ASIS (existing), or a collapsed proposal with θ moved by the pCN step above at the new λ and accepted with the joint MH ratio | Acceptance rate per level and ESS(log λⱼ) on the same pilot (shared runs, +0.5 core-h) |
| **λ prior** (Gamma(2, s_y·n^{−5/2}) or an automatic centre) | Per level, unchanged: each λⱼ has its own prior and conjugate draw | None structural. The per-level centres must not reorder curves, but ordering is enforced by the box anyway | Comes with the pilots above |
| **σ rule** (fixed 1.1σ̄ or plug-in) | Per level: σⱼ fixed (no σ \| θ block) | The plug-in at 0.99 (sparse tail): use the VP's extrapolation from the nearest estimable level | Comes with the pilots above |
| **Banded O(n) cost** | Same banded QR per level and proposal | — | Cost per sweep against J ∈ {2, 4, 6} levels, both samplers: ≈ 1 core-h |

- **Joint gate (after S1):** ≈ 5 core-h in total.
- **Pass:** the new joint arm (i) never crosses (by construction), (ii) has MSE per level no worse than the original's (paired), and (iii) has ESS/s ≥ the original's at every level.
- **A change that wins individually but fails this gate is reported as a remark, not as a method.**

## 4. Benchmarks and measures (the paper's own)
**Benchmarks:**
- **Interior/extreme grid:** VS and S (plus PC, the third baseline in `simulate_data`, reported separately) × Gaussian, Beta and mixed normal × τ ∈ {0.05, 0.25, 0.5, 0.75, 0.95, 0.99}, at n = 500.
- **Peak detection** (`air_simulation.tex`): n = 500, τ ∈ {0.01, 0.05, 0.10}.
- **Data applications:**
  - SPod (n = 8640, τ ∈ {0.01, 0.05, 0.1}). The paper reports 44–53 min per level and a median ESS(θ) of 3.5 at τ = 0.01, so this is the showcase for mixing and runtime.
  - Dutch boys (G = 220 grouped slots). The paper had to switch the λ prior because "the P-MALA step [was] unable to move". This needs grouped-data support in the copy.

**Measures:**
- **Accuracy:** MSE and MAD against Q_τ, with replicate 95% CIs and paired differences against O.
- **Bands:** coverage and width. Non-crossing counts for the individual fits (as in the paper's appendix).
- **Mixing:**
  - ESS per second and per sweep: θ (min and median over coordinates), λ, σ; bulk and tail.
  - R̂ (bulk and folded).
  - Trace and ACF plots for λ and for representative θ coordinates (bump, edge, centre).
- **Scalability:** cost per sweep and per effective sample (min θ ESS, and λ) for n ∈ {500, 1k, 2k, 4k, 8k, 16k}, extending the paper's experiment. Joint-J scaling only once a joint variant exists (S6).
- **σ auto (F-auto):** landing in the theory interval, undershoot (σ̂ < σ̄), overshoot and abstention, reported separately (Beta at 0.05 and all 0.99 cells singled out); failures stay in the denominator.
- **Figures:** ggplot2 throughout.
  - Per cell: truth vs original vs new, each with its MSE.
  - Mixing panels: traces and ACFs.
  - Scaling panels: ms per sweep and seconds per effective sample against n.

## 5. Measured rates used for costing
| Sampler | Rate |
|---|---|
| O (paper code) | 5.4 ms/sweep at n = 500 (G0 on NOTS: VS 30k sweeps in 165 s, S 20k in 107 s). ≈ 0.45–0.5 s/sweep at n = 8640 (paper) |
| C (P-MALA plus collapsed block) | 6.6 ms/sweep at n = 500 (G0: 79.8 s for 4 × 3000) |
| N (exact plus collapsed) | ≈ 1.6–2 ms/sweep at n = 500 (Owls); 4 chains stop after ≈ 1–3k sweeps |
| Scaling | O(n) in all arms |

## 6. Staged plan (cheapest decisive evidence first)
| Stage | Content | Decides | Core-h |
|---|---|---|---|
| **S0** | Diagnostics (`posterior`), AR(1) unit tests, long reference runs on 6 cells | Whether the diagnostics can be trusted | **2** |
| **S1** | **Same-target head-to-head:** O, C, X, N. VS and S × 3 noises × τ ∈ {0.05, 0.5, 0.95} × 5 seeds. All arms run 4 chains (O at the paper's run length per chain). Report the agreement of summaries, ESS/s and ESS/sweep (θ min/median, λ, σ), R̂, traces and ACFs. Also checks the S-signal λ finding | Which sampler change pays; whether the paper's S runs converged | **≈ 16** (O ≈ 12) |
| **S2a** | **Accuracy grid with cheap replication:** 36 cells × 10 seeds. Arms: O (1 chain, as published), N, N-λ, N-F-oracle, N-F-auto, N-P. Paired differences against O | Whether the prior and σ rules win, and where they lose | **≈ 15** (O ≈ 11) |
| S2b | Extend S2a to 20 seeds only in the cells where S2a is undecided (CI straddles 0) | Resolves the close cells | ≤ 8 |
| S2c | F-auto landing study: 36 cells × 200 datasets, pilot fits only | Whether F-auto is usable as the default | **2** |
| **S3** | Peak detection: 30 replications × 3 levels; O vs the adopted arm(s) | Whether the paper's application-style benchmark holds | **5** |
| **S4** | SPod (n = 8640, 3 levels; O at the paper's settings with 2 chains, the new sampler with 4) and Dutch boys (5 levels) | Mixing and runtime on real data | **7** |
| **S5** | Scalability: n = 500…16k, 3 replications; ms/sweep and s/ESS for O vs the adopted sampler | n-scaling claim | **4** |
| **S6** | **Joint gate (§3), after S1:** prototype the box-restricted moves; pilot against the original joint sampler on the joint design; J-scaling | Whether the individual gains have a working joint extension | **≈ 5** |
| **Total S0–S6** | | | **≈ 56** (64 with S2b; cap 60. Already spent: G0 1.3, σ sprint 8.0) |

- **Already spent on E-07:** 1.3 core-h (G0, cancelled).
- **Gates:**
  - **S1 → S2:** the same-target arms agree within MCSE, and N (or C) beats O on ESS/s for both λ and min-θ in at least 80% of cells. Otherwise the sampler change is dropped and S2 runs with O only for the prior and σ arms.
  - **S2a → S3/S4:** HQ reviews the losing cells.
- **Trim options, if 51 is too much:**
  - S1 at 3 seeds (−6);
  - S3 at 20 replications (−2);
  - S4 without Dutch boys (−1);
  - drop the PC truth (−4).
- **Priority:** Theory's pre-attack simulations keep NOTS priority tonight. S0 needs no NOTS and runs first.

## 7. Advisor and reviewer findings: rulings
- The v1 rulings on Fable's and Astra's memos stand (`PROPOSAL_v1.md` §7), with these changes from Astra's HQ review:

| # | Finding (ASTRA_E07) | My check | Ruling |
|---|---|---|---|
| H1 | The prototype sums single-chain ESS, has no folded R̂, maps an undefined R̂ to 1, and mixes thinning strides | Confirmed by reading `e07_sampler.R`: `rhat_ess` sums `effectiveSize` per chain and returns `rhat = 1` when not finite; THs is re-thinned by 2 | **Accept**; fixed in S0 before any comparison |
| H2 | The collapsed block must retain the ordinary λ \| θ draw, refresh t at the new λ, take one slice step and redraw θ | Matches the implementation (steps 4–5) | **Accept** (already so). Add a small-n quadrature reference for λ and a large-λ determinant stress test (S0) |
| H3 | Call the h = 2 move an "implicit preconditioned Langevin update on the augmented Gaussian conditional" | Agrees with F-R1b and A-3 | **Accept** the name; Felipe's ruling makes the label secondary to efficiency |
| H4 | λ prior: s_y-scaled Gamma(2, s_y·n^{−5/2}); same-data s_y is empirical Bayes | Correct. Theory would need uniformity in the rate multiplier | **Accept**; flag it as empirical Bayes in the write-up |
| H5 | F-auto: Hall–Sheather h, quadratic design, include the endpoints, reject crossings, abstain at sparse tails; report landing, undershoot, overshoot and abstention separately; convexity gives no one-sided guarantee for the fitted quadratic at a boundary | Correct. My v1 text overstated the bias argument for the fitted boundary | **Accept**: S2c implements and reports exactly this |
| H6 | A coherent P is IG(1, L) restricted to [L, 2L], with L from the F rule | It is valid, but it is effectively F with a little jitter | **Test as an extra P arm in S2a** only if the VP memo does not supersede it |
| H7 | Validate stopped estimates and band endpoints against long independent runs with combined MCSE | — | **Accept** (S0) |

### 7b. VP review (`hq_reviews/VP_E07.md`): rulings
| # | VP finding | My check | Ruling |
|---|---|---|---|
| V1 | The collapsed block is correct; test the log-det at n = 8k (λ² ≈ 10¹⁶–10²²) | The banded QR works on the stacked matrix, whose condition number is √cond(P), the same path that stays stable to λ ≈ 1e9 in E-02. Not tested in the collapsed slice at 8k | **Accept**: one n = 8k cell is added to S0 (log-det against a high-precision reference, and λ̄ against E-02 Gibbs) |
| V2 | The exact θ move, and the hybrid, are an augmented Gibbs sampler, not P-MALA | Agree. The hybrid's P-MALA move sits on top of an exact draw | **Accept**: it is named "augmented Gibbs" in all E-07 outputs; the hybrid stays as the C arm for the ablation only |
| V3 | The λ prior is effectively flat at n = 500 (rate ≈ 5e-8 against ‖Dθ‖₁ ≥ 6e-4). Its content is that it does not cap λ | Agree. This is consistent with the smoke finding that the paper's b₀ caps λ on S (b₀λ ≈ 8) | **Accept**; the write-up will say so |
| V4 | The nats claim is worded too strongly: an n-strength prior IG(κn, κn·σ_ref) does move σ, but needs σ̄ | Agree | **Accept** the rewording; the conclusion is unchanged |
| V5a | Stopping: start two chains from the quadratic fit | Cheap, and it targets the θ-trap | **Accept**: starts are y, the LS quadratic ×2, and the smoothing-spline fit |
| V5b | G3 "within 0.1 sd" fails by chance; use a pass rate | 0.1 sd ≈ 2 MCSE at ESS 400, so about 5% of estimates fail by chance | **Accept**: pass if ≥ 90% of estimates lie within 0.1 sd and none lies beyond 0.25 sd |
| V5c | Stored θ covers the wrong window beyond 8k sweeps | Was real in the prototype (re-thinning) | **Already fixed** in S0 (4733a4d): one fixed stride with iteration indices |
| V6a | Plug-in without abstention: σ̄(τ) ≤ (τ/p)σ̄(p) above the median (mirror below) | Re-derived: (1−t)·s(t) = 1/hazard(F⁻¹(t)), and log-concave ⇒ increasing hazard ⇒ σ̄(t)/t non-increasing for t ≥ ½ | **Accept**; implemented in S2c and reported against the abstention variant |
| V6b | Cap: σ̄ ≤ √3·max(τ, 1−τ)·sd | Follows from V6a at p = ½ and Bobkov's f(med)²·Var ≥ 1/12 for log-concave laws (quoted; Theory is confirming) | **Accept** as an upper clip; reported (landing, over- and undershoot) in S2c |
| V7 | Coherent P is IG(0.1, 0.1·s_y) truncated to [σ̂_F, cap]; τ-only hyperparameters cannot work (R depends on the law) | Agree | **Accept**: P-trunc gets one cell to show it equals F; the smooth-prior P arm stays as the "learned σ" comparison |
| V8 | Key risk: F costs point accuracy (larger λσ, more smoothing) | — | **Measured first**: the σ sprint (paper sampler, L vs F, paired, 5 seeds) is running now; S2a repeats it with the new sampler at 10 seeds by τ, reporting MSE, coverage, width and λσ per arm. Also tests the VP's (σ_F/σ₀)^{5/6} prediction |
| V9 | Re-run the paper's tables under the new λ default | — | **Felipe's decision after S1/S2** (HQ); no action |
| V10 | Theory: the learned-λ theorem needs the supremum over σ ∈ I and over c inside the expectation | — | Relayed to HQ; for Theory |
