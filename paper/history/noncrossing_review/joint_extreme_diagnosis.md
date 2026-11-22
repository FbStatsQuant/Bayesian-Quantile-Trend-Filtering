# Joint non-crossing sampler at extreme lower quantiles: diagnosis and fixes

Scope: `joint_bayesian` run `ext_bayes_n500_20260909` (VS signal, k = 1, n = 500, 13-level grid 0.003–0.2, targets 0.01–0.04, R = 100), code `Extreme_Quant/Joint_Sampler_Bayesian` = `Sequential_Joint_Quantiles_Scale.R` + `prox_admm_optimized_fixed.cpp`. Prior and sampling scheme taken as fixed; everything below is implementation or tuning.

Method: I re-implemented the sampler line by line (Python driver, C ADMM identical to the C++), reproduced the campaign pathology on seed 1 / Normal, then changed one thing at a time. Single seed, so treat MSE differences of ±20% as noise; the qualitative facts (frozen chains, ties, feasibility) are not noise.

## 1. What the spreadsheet actually says

Normal and Beta: CR ≈ 20% of adjacent checks on the posterior means, AC = 100%, PCP = 100% (every replicate has draw-level crossings), per-index crossing probability 0.70 (Normal) and 0.85 (Beta) — the draws cross at most positions, not at a few. Mixed: CR 2%, but the largest draw-level box violation is 0.28–0.39.

The crossing numbers are the visible symptom. The sampler-health numbers underneath are worse:

- `admm_frac_max_iter = 1` at every level, every seed: ADMM never met tol 1e-4 in 500 iterations.
- Acceptance at 0.01–0.04 (Normal): 0.99 / 0.78 / 0.27 / 0.19 on average, but per replicate it is bimodal: 0.99 or exactly 0. More than half the seeds have acceptance 0 at 0.03 and 0.04 — chains frozen for all 4,000 retained draws.
- MCIW 0.003–0.02 and coverage of the 95% bands 2–4%. A frozen chain has zero-width bands; a crawling chain (acc 0.99, moves of 1e-4) has near-zero width.

So the joint sampler in this run is not a Markov chain exploring anything; the "posterior mean" is one smoothed curve per level. That is why the crossings are small in size (box violation medians 0.005) but everywhere.

## 2. Mechanisms, in order of importance

### 2.1 The proposal is the infeasible ADMM block (fix: return `w`)

`prox_admm_optimized_fixed` returns `theta`, the block that solves the linear system. The box constraint lives on the other block `w` (the clipped copy). They coincide only at convergence, and the ADMM is nowhere near convergence (Section 2.4), so every accepted state violates the box by 1e-3 to 0.3. The MH step evaluates `neg_log_posterior` without the constraint indicator, so infeasible proposals are accepted like any other.

The replica confirms it: returning `w` instead of `theta` gives CR = 0, PCP = 0, max violation = 0 exactly, because the feasible set is convex and the mean of feasible draws is feasible. This is the one change that makes "0 by construction" a true statement in the paper. It is one line in the R wrapper (`theta_proposal <- admm_result$w`) or, equivalently, clipping `theta` into `[lower, upper]` before the MH step.

But returning `w` alone is not enough; it exposes the next three problems (row "retw" in the table: CR 0, and 67% of adjacent checks are exact ties, chains still frozen).

### 2.2 One step size for 13 levels whose σ_k differ by a factor 45

`delta` is a single number (0.005 Normal, 0.007 Beta, 0.01 Mixed) for all levels. The Langevin drift at a point below the curve is δ(1−τ)/σ_k. Posterior σ_k in the run: 0.002 (τ = 0.003), 0.004 (0.006), 0.007 (0.01), 0.013 (0.02), 0.019 (0.03), 0.026 (0.04), … 0.09 (0.2). So the drift at the lowest levels is 0.5–2.5 per below-point (with noise sd only 0.1), the proposal is 0.3 away from the current state, and the exact posterior (whose log-scale is 1/σ_k = 100–500) rejects everything: frozen. At the levels where σ happens to match δ the chain moves; in between it crawls.

The methodology section already says each τ_k has its own δ_k. The code never used that. Per-level δ_k tuned in burn-in (Robbins–Monro on log δ_k toward acceptance ≈ 0.4, frozen after burn-in) gives acceptance 0.35–0.45 at 12 of 13 levels. Keep a floor on δ_k (1e-5 worked); do not use a "×0.2 if acceptance < 0.02" rule — it collapses δ_k to zero at levels that are blocked for a different reason (2.4), and then the proposal is deterministic and the level is frozen for good.

### 2.3 Initialization `theta[, k] = y` for all k, λ_init = 10000

All 13 curves start identical, so every interior box is a single point at iteration 1. The sequential scan then peels levels off the bottom one at a time, each clipped onto its predecessor, and the result is a stack of tied curves. Ties are absorbing under the box scheme: if θ_{k−1,i} = θ_{k,i} = θ_{k+1,i}, level k's box at i is a point, the proposal equals the current value, it is "accepted" at rate 1, and nothing moves until an outer neighbour leaves — which the frozen neighbours never do. That is the 67% tie rate in "retw" and the 0.99 acceptance with 1e-4 moves in the campaign.

Fix: start from ordered, separated curves — a smoothed fit of y plus the empirical residual quantile at each τ_k, forced strictly increasing (the same idea your `Sequential_Joint_Quantiles_Scale_Corrected.R` uses). Start λ at its prior mean (≈ 110 here), not 10,000: with λ = 10,000 the first proposals are so over-smoothed that the tie stack forms in the first sweep. With ordered init + per-level δ_k the tie rate drops from 67% to 5–8% (Normal) and posterior means have no ties at all.

### 2.4 The proximal step is far too strong, and the ADMM never computes it

With a = 2000, b = √500 the λ posterior is prior-dominated: λ ≈ 110 at every level, every seed. The prox penalty is then λγ = 44 on Σ|D²θ|. On the true VS curve, the exact prox with λγ = 44 moves the curve by 0.30 in sup-norm (it flattens the bump). The posterior at σ_k ≈ 0.005–0.02 cannot accept a 0.03 move at a below-point, let alone 0.3. If the ADMM had converged, every level would be frozen.

The chain moved at all only because 500 cold-started iterations (θ_init = z, both duals reset to zero every call, ρ = 50) do not solve the prox: the ℓ1 dual has to climb to λ/ρ = 2.2 in increments of |D²θ| ≈ 1e-4 per iteration, so after 500 iterations the ℓ1 term is ~2% active and what the solver returns is an ℓ2-type smoother of z whose strength is set by (ρ, iteration count), not by λγ. Measured on a smooth curve: this surrogate still shifts the current state by 0.11 (γ = 0.4) each time it is applied, and re-applying it shifts again by 0.06 — it is not idempotent, so even at δ → 0 the proposal differs from the current state by 0.03–0.1. That, not δ, is what freezes the 0.01–0.04 levels.

Offline measurements (true VS curve, λ = 110, Langevin noise δ = 0.005):

| γ | λγ | exact prox: shift of a smooth curve (sup) | noise passed through (rms) | ρ = 500, 500 iters vs exact |
|---|---|---|---|---|
| 0.4 | 44 | 0.30 | 0.010 | not converged at ρ = 50 |
| 0.1 | 11 | 0.13 | 0.013 | identical |
| 0.05 | 5.5 | 0.087 | 0.016 | identical |
| 0.02 | 2.2 | 0.051 | 0.020 | identical |
| 0.01 | 1.1 | 0.034 | 0.021 | identical |

Two consequences. First, γ has to come down by a factor 20–40 (λγ ≈ 1–2) so that the prox removes the Langevin noise (its second differences are ≈ 0.1–0.25, still above the threshold) without deforming smooth curves beyond what σ_k tolerates. With λ fixed by the prior, γ is the only knob that sets this ratio; γ = 0.4 was tuned for the interior-quantile regime where σ ≈ 0.1–0.4 tolerates the deformation. Second, ρ = 500 (roughly 5λ) makes 500 ADMM iterations agree with the exact prox at all γ ≤ 0.1; ρ = 50 does not. The absolute tolerance 1e-4 is unreachable at any ρ (it needs 1e4–1e5 iterations) and is irrelevant: at ρ = 500 the returned `w` is within ~1e-3 of the exact prox after 500 iterations. Report ‖θ − w‖∞ rather than `frac_max_iter` as the ADMM diagnostic. The w-only warm start in the current code changes the output by 5e-4 — it neither helps nor hurts; keep or drop it.

### 2.5 Sentinels below the data resolution

At n = 500, τ = 0.003 has 1.5 expected observations below the curve, τ = 0.006 has 3. Those levels are not located by the data; their posterior is "just under the lowest points" plus prior, their MSE in every variant is 0.1–0.16, and they sit 0.01–0.03 under the 0.01 level (truth gaps 0.06–0.07 for Normal). They still act as a wall, but it is a wall glued to the 0.01 level, and it contributed to the tie stack in 2.3. If the scaffold below 0.01 is kept, one level at 0.005 (2.5 points) is defensible; 0.003 is not doing what the paper's sentinel section claims.

### 2.6 What parameters cannot fix (flagging, not proposing)

`joint_bayesian_core.R` accepts with `log_post_prop − log_post_curr` only. `individual_core.R` — the sampler that works — adds the proposal-density terms (Moreau-envelope drift, `grad_f_plus_g`). The joint code therefore differs from both the individual code and the methodology text (which states the q-ratio). With the prox-then-accept construction and no proposal correction, the posterior draws are the current curve plus ~0.01–0.02 of smoothed noise, and the 95% bands cover 20–45% even after all fixes below. That is the coverage number a referee will compute from your stored draws. Restoring the q-terms in the joint code costs one extra constrained ADMM solve per level per iteration; whether it repairs coverage in this regime I did not test. Your call, since you ruled the process fixed.

## 3. Evidence: seed 1, VS, 6,000 iterations / 2,000 burn-in

Normal noise unless stated. "Campaign" = mean over 100 seeds from the spreadsheet.

| run | change | CR % | PCP % | ties ACT0 % | acc at 0.01/0.02/0.03/0.04 | MSE 0.01/0.02/0.03/0.04 | MCIW | coverage |
|---|---|---|---|---|---|---|---|---|
| campaign | — | 19.8 | 100 | 0 | .99/.78/.27/.19 | .038/.027/.027/.025 | .021/.016/.008/.008 | .03/.04/.02/.02 |
| base replica | — | 20.6 | 100 | 0 | .99/.99/0/0 | .047/.029/.032/.028 | .023/.023/0/0 | .04/.04/0/0 |
| retw | return w | 0 | 0 | 67 | 1/1/0/0 | .064/.039/.032/.028 | 0/0/0/.02 | 0/0/0/.12 |
| v2 | + δ_k adaptive, ordered init, λ_init 110 | 0 | 0 | 5.5 | .35/.36/.40/.37 | .092/.080/.065/.048 | .08/.09/.09/.09 | .14/.27/.39/.43 |
| v5 | v2 + γ 0.01, ρ 500 | 0 | 0 | 7.9 | 0/.38/.34/.41 | .056/.036/.023/.019 | 0/.04/.10/.09 | 0/.13/.33/.33 |
| v6 | v2 + γ 0.02, ρ 500 | 0 | 0 | 7.0 | 0/.37/.36/.36 | .058/.043/.025/.018 | 0/.06/.11/.11 | 0/.20/.33/.37 |
| v7 | v2 + γ 0.005, ρ 500 | 0 | 0 | 6.1 | .67/.39/.41/.45 | .065/.038/.025/.019 | .06/.09/.10/.09 | .18/.22/.32/.30 |
| v5 Beta | as v5, Beta noise | 0 | 0 | 31 | .43/.45/.39/.52 | .0005/.0003/.0003/.0003 | .016/.012/.010/.010 | .49/.41/.41/.43 |

Campaign Beta MSE was 0.0058 at every target; v5 is 10–20× lower. Scaffold levels 0.05–0.2 (Normal) go from MSE 0.03 to 0.015. The 0.01 level is the fragile one: at γ = 0.01–0.02 it froze at the δ floor (the prox deformation 0.03–0.05 exceeds what σ ≈ 0.007 tolerates, and its box is narrow); at γ = 0.005 it moves (acc 0.67) at the price of a slightly worse point estimate on this seed. Somewhere in γ ∈ [0.005, 0.01] with δ_k adapted is where the lower-tail levels all move; that sweep is worth doing on the cluster with 10–20 seeds before the 300-task run. Ties in Beta (31%) are real: adjacent Beta lower quantiles differ by 0.001–0.01, so the box binds legitimately; the posterior means still have zero ties.

## 4. Recommended configuration for the next campaign

In `joint_bayesian_core.R` / `config.R`, in this order of leverage:

1. Proposal = `admm_result$w` (or clip `theta` to the box). Non-negotiable; makes CR/PCP identically 0 and lets the paper say so.
2. `rho_admm` = 500 (≈ 5λ); keep `max_iter_admm` = 500; keep `tol_admm` as is or switch to a relative criterion — either way log ‖θ − w‖∞ per call.
3. `gamma` ≈ 0.005–0.01 (λγ ≈ 0.5–1), same for all noises; the current 0.4 is an interior-quantile value.
4. `delta` → vector `delta_vec` adapted per level during burn-in toward acceptance 0.3–0.5, with a floor, no cliff rule, fixed after burn-in. Starting values ∝ σ_k are fine; the adaptation removes the guesswork.
5. Initialize ordered and separated; `lambda_init` ≈ prior mean (110).
6. Drop 0.003 from the grid, or accept that it is a decorative level; report its `n·τ`.
7. Store per level: acceptance, δ_k after burn-in, ‖θ − w‖∞, tie fraction, ESS of a few θ_i. The current diagnostics (`admm_frac_max_iter`, `grad_norm_mean`) do not detect any of the failures above.

Expected outcome from the seed-1 evidence: CR = PCP = 0 by construction, acceptance 0.3–0.5 at all target levels, ties on draws ≈ 5–10% (Normal) with none on posterior means, MSE at 0.03–0.04 roughly 25% below the campaign and at Beta an order of magnitude below, coverage 0.2–0.5 (structural, see 2.6).

## 5. Things I did not do

Single seed per configuration; Mixed noise not replicated (same mechanism, largest box violations in the campaign, so expect the same fixes to apply). RNG streams differ from R, so numbers match the campaign in kind, not digit by digit. The adaptation rule is mine; use your Corrected script's version if you prefer, minus the cliff. No change to the prior, the likelihood smoothing, the scan order, or the MH rule.
