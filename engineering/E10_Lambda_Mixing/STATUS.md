# E-10 status: λ mixing with the spline-held interweaving move (stopped 2026-11-25 ~09:10 CT, Felipe's stop order)

NOTS run directory: `/projects/ml75/fb31/BQTF/runs/E10-lambdamix-20261125` (written `$RUN` below).

## Done

### 1. Spline-held ASIS λ move: individual sampler (`method/individual/Individual_Sampler_PMALA_Augmented.R`)

**The move.** Projector `asis_projector`:
- banded cubic B-splines, O(n) per call;
- q = k+1 keeps the original polynomial move;
- q cycled per sweep via `asis_q_grid`;
- default b0 = 1e-5.

**Rule.** `asis_q_default <- "fixed"` ({10, 20, 40}) is a placeholder. No rule has been chosen.

**Tests (run_tests).**

| Test | What it checks | Result |
|---|---|---|
| 6b | enlarged subspace; a wrong Jacobian must fail | correct z ≤ 3.65; wrong z = 124 |
| 6c | projector = dense projection; O(n) cost | error 2e-14; time ratio 3.5 for 10× n |

**Exactness at n = 7 against an importance-sampling reference** (`e10_diag.R exact`):

| Case | Max z |
|---|---|
| Spline q = 4, 5, 6, order 0 and order 1 | 1.3–2.6 (all pass) |
| Wrong Jacobian | 633 and 770 (fail, as required) |
| Polynomial controls | 1.7 and 3.3 (pass) |

**Projector exactness at n = 2000 and 5000, every q:**
- idempotence error ≤ 1e-14;
- symmetry error ≤ 8e-17;
- polynomials reproduced to ≤ 8e-15.

### 2. Joint sampler (`method/joint/`)

- The same move, per level, inside the box constraint (`asis_box_step`).
- T1 (J = 1 reproduces the individual sampler draw for draw), T2, T3, T3b (wrong Jacobian, z = 28) and T4 pass.
- The prox test P3 needs `clarabel`, which is not installed on Owls.
- Joint check, J = 2, VS n500 (job 2887337): run at b0 = 0.01.
  - At b0 = 1e-5 the joint sampler crashes in the banded Cholesky of the metric P.
  - The HEAD code crashes the same way, so it is pre-existing. Filed as E-11 and not started.

### 3. Calibration chains

- n = 500 and n = 2000 are complete; n = 5000 is running (see Queued).
- Design: VS/S/PC × τ ∈ {0.5, 0.75, 0.95}, 2 chains, seed 1.
- Variants: poly (current sampler), fixed, n_prop, n16, geo.

### 4. n = 2000 side-by-side, old vs new (`h2h_n2000/`)

- Table, four cell pages and the chain-difference plot; see its README.
- **Finding:**
  - New move: λ mixes (split R-hat 1.00–1.04).
  - New move: θ does not mix where λ is huge. θ split R-hat median/max is 3.9/14.4 at S τ0.5, and the two chains differ by 1–3 band half-widths (median), up to 11, with smooth, low-frequency gaps.
  - So the narrow bands and low coverage are not reportable.

### 5. Cross-initialisation, S n = 2000 (`$RUN/diag/cross_*.csv`)

**Finding: the high-λ region holds the posterior mass. (B) holds for λ.**
- The log marginal (λ integrated out) is about 8,000 nats higher at λ ≈ 5e5 than where the old sampler sits after 30k sweeps.
- Started there, the old sampler stays there, and its bands are narrow too: width 0.029, coverage 0.29–0.44.
- So the old sampler's ~0.9 coverage is an artefact of λ not converging.

### 6. δ capture (job 2887357, tasks 40–59, `$RUN/out_extra/delta_*.rds`)

These chains reproduce the calibration chains exactly (MSE, coverage and λ mean are identical).

**Final P-MALA step δ:**

| Baseline | τ | Old | New |
|---|---|---|---|
| S | 0.5 / 0.75 | 6.6e-3 to 1.4e-2 | 7e-6 to 1.2e-5 (~1000× smaller) |
| VS | 0.5 / 0.75 | ~1e-2 | 4–8e-4 (~20× smaller) |
| VS | 0.95 | 3.7e-2 | 5–8e-3 |

- Acceptance stays at about 0.5 everywhere, because δ adapts all run long.

**Lead, not yet acted on.** The curvature metric's D'D weight is capped:
- the code is `metric_dc`: c = min(κ λ²/2, 1e8);
- with κ = 3 the cap binds for λ > ~8.2e3, so it binds in every new-move S/VS cell;
- once the metric saturates, δ shrinks to keep acceptance at 0.5.

The cap, or how the metric scales at huge λ, is a candidate cause of the θ-mixing failure.

## Half-done

### θ block move on the spline subspace: UNTESTED IDEA at n = 2000

**Code** (`block_step` in the individual sampler; `gibbs_pmala_aug(block = , block_mode = )`):
- θ' = θ + Bβ, with B the same basis as the λ move;
- β ~ N((s²/2) ν(θ), s² (B'AB)⁻¹), a preconditioned MALA in β ("mala"), or β ~ N(0, s² (B'AB)⁻¹) ("rw");
- exact Metropolis–Hastings with the full likelihood and the l1 prior;
- scale s per q, adapted during burn-in only, then frozen;
- off by default (`block_theta <- 0L`).

**Exactness, test 6d** (n = 7, k = 1, q = 5, λ = 3; reference = importance sampling, its standard error included in z): **PASS**

| Mode | Ratio | Block acceptance | Max z (mean, sd) |
|---|---|---|---|
| mala | correct | 0.52 | 1.42, 1.56 |
| rw | correct | 0.43 | 1.57, 1.76 |
| rw | wrong (prior dropped) | 0.85 | 4.00, 11.70 → fails, as required |

- The importance-sampling ESS is 546 of 2e6 draws. That is low but adequate here: the wrong ratio is still detected. A stronger reference would raise the test's power.

**Acceptance probe at the same n = 7 target:**

| Proposal | s | Acceptance |
|---|---|---|
| Full Newton step (s = √2, the first version) | 1, 1.41 | 0 |
| mala | 0.1 / 0.2 / 0.4 / 0.7 | 0.87 / 0.54 / 0.09 / 0.007 |
| rw | 0.1 / 0.2 / 0.4 | 0.65 / 0.42 / 0.20 |

A strong prior forces small steps, so it is unknown whether the move helps at λ ≈ 5e5.

**Not run:**
- the full `run_tests()` after the block-move edit (6d ran standalone; the projector change only adds the attributes B and DB);
- the n = 2000 pilot. It was not submitted, per the stop order.

**HQ suggestion, not tried:** precondition with the projected curvature metric G = B'(diag(a) + κ(λ²/2) D'D) B instead of B'AB.

## Queued (already submitted, allowed to finish)

- **Calibration n = 5000** (`bqtf-e10-cal`): results go to `$RUN/out`.
- **Job 2887357, PC MSE across seeds**: PC τ0.5/0.75, old vs new, chain 1001.
  - Data seeds 2–11 at n = 500; seeds 2–6 at n = 2000 and 5000.
  - Results go to `$RUN/out_extra/pcseed_*.rds`.
  - Question: is the new move's +16–19% PC MSE at n = 2000, seed 1 noise or real?
- **Joint check, b0 = 0.01** (job 2887337).

## What I would do next (after Felipe's discussion)

1. **Read the queued jobs.**
   - PC MSE: a paired, per-seed comparison.
   - Calibration n = 5000.
   - Joint non-crossing, and λ mixing in the joint check.
2. **θ at huge λ.** Test the metric cap first (cheap, exact):
   - lift or rescale the 1e8 cap on κλ²/2, keeping the ADMM system factorisable;
   - then the block move with G-preconditioning;
   - pilot: S τ0.5, S τ0.75, VS τ0.75 at n = 2000, 2 chains;
   - success = θ R-hat max ≤ 1.1 and chain-gap ratio max ≤ 1, MSE no worse.
3. **Only then** choose the q rule, write the full NEW-vs-STANDARD report, and port any θ-side fix to the joint sampler.
4. **Writing:** the one sentence in §2.7 waits for the above. Separately, the paper's coverage tables and the b0 = 1e-5 choice need Felipe's decision, given that (B) holds for λ.
