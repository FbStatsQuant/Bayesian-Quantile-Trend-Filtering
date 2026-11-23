# Fable ideas for E-07 (INTERNAL)
*Fable, consultant, 2026-11-23. "Measured" = from your tables or my one local check (§5). Everything else is labelled guess.*

## 0. Bottom line
- **Why his λ is stuck (diagnosis).** Given θ, λ | θ ~ Gamma(a₀+m, b₀+‖Dθ‖₁) has relative sd 1/√m (≈ 4.5% at n = 500), and ‖Dθ‖₁ | λ sits at ≈ m/λ. The pair is a near-driftless random walk in log λ with step 1/√m; the data only enter at order df/m. Crossing a posterior of width w in log λ takes ≈ (w√m)² sweeps.
- **Why ASIS and lamjump do not fix it.** ASIS rescales the *whole* non-polynomial part of θ (signal included), so the likelihood pins the rescale to a few %. lamjump takes a prox step with γ = δ/2, far too short to re-shrink roughness to the new λ, so its step adapts back to ≈ 1/√m (your joint smoke: s = 0.06–0.15).
- **The fix that works** is the one your exact Gibbs already contains: move λ with θ integrated out, given the scale-mixture variables. I show below that this block can be bolted onto his P-MALA **without any Gaussian θ draw** (idea 1), and that the same construction repairs the joint design (idea 2).

## Joint design
*Critical-path answer, 2026-11-23, after attempt 1 (collapsed block acceptance 0; pCN r ≈ 0.96–0.995). Supersedes ideas 2 and 4 below.*

**Pick: (iii). Exact reflective HMC for the box-truncated Gaussian θ_j | s_j, z_j, box** (Pakman & Paninski 2014). It replaces both pCN and the collapsed block. Keep the s, z, σ and conjugate-λ draws of the individual Gibbs.

**Update, per level j.** Given w, r, iw as in `e07_sweep`: P = diag(w) + Dᵀdiag(iw)D, μ = P⁻¹(w∘r), box [l, u].
1. x = θ_j − μ. Draw V ~ N(0, P⁻¹) (one banded draw, as now). Time left T = π/2.
2. Free flight: x(t) = x cos t + V sin t, V(t) = −x sin t + V cos t. Coordinate i is A_i cos(t − φ_i), A_i = √(x_i² + V_i²), φ_i = atan2(V_i, x_i). Exit times: upper wall (φ_i − arccos((u_i − μ_i)/A_i)) mod 2π, lower wall (φ_i + arccos((l_i − μ_i)/A_i)) mod 2π (none if the wall is beyond A_i). Take the minimum over i.
3. If it exceeds the time left, fly to the end and stop. Otherwise fly to the wall, reflect V ← V − 2 (V_i / (P⁻¹)_ii) P⁻¹e_i (one banded solve), subtract the time, go to 2.
4. θ_j = μ + x.

**Why it is valid.** The flight is the exact Hamiltonian flow of the Gaussian. The reflection is elastic in the P metric: it preserves energy and volume and is reversible. T is fixed. So the truncated Gaussian is invariant with no accept step and no step size. It is a Gibbs block for θ_j | rest; every other block is the individual conditional, because the order indicator is constant given Θ.

**Measured (one-level proxy; my R prototype, one core; mechanism only).** n = 300, VS/Normal, τ = 0.98, b₀ = 0.01, 400 sweeps, 267 kept. The box is **fixed** at true quantile curves, not at moving neighbours.

| Box | Bounces per trajectory, median (max) | ESS of θ at 5 points, of 267 | ESS(log λ), conjugate only |
|---|---|---|---|
| true 0.97 / 0.99 curves | 14 (23) | 118–167 | 23 |
| true 0.977 / 0.983 (3.4× tighter) | 52 (75) | 247–267 | 25 |

- θ is refreshed almost independently every sweep, in boxes where an unconstrained draw never lands.
- λ then mixes on the conjugate draw alone: ESS ≈ 9% of sweeps, against 2.6–4 in 6000 sweeps for attempt 1.
- 2-d check against rejection sampling passes (means 0.687 / 0.306 against 0.690 / 0.309).
- Caveat: real neighbours are rougher, closer and move. Expect more bounces, and across-level creep that this proxy cannot show.

**Cost.** Per level and sweep: one banded factorisation, one banded solve per bounce, O(n) for the exit times. Guess < 1 ms at n = 500 with ≤ 100 bounces, against ≈ 22 ms per level-sweep for his sampler (0.133 s / 6 in `joint/RESULTS.md`). One C++ export, `banded_rhmc(w, r, iw, theta, lo, up, xi1, xi2, T)`, ≈ 120 lines on the existing QR factor.

**Why not the others.**
- **(i) Hybrid:** it has no λ lever. z and σ were never his bottleneck (σ ratio 1.000). I tested my own T-block in this box: it is wall-limited, mean |Δ log λ| = 0.059, the conjugate step; ESS(log λ) 31 against 23. **Idea 2 fails its own kill signature. Drop it.**
- **(ii) and v2 single-site:** single-site Gibbs is Gauss–Seidel on a sixth-order operator. Relaxation time ≈ 20·iw/w sweeps, 10⁶ or more (order-of-magnitude guess). HQ's worry is right. Windows help only when wider than the correlation length, and then each window needs a truncated-Gaussian sampler, which is this move. Do the whole level at once.

**Traps.**
- After a hit, set x_i exactly on the wall and ignore that wall for the next t < 10⁻⁸.
- Never stop on a bounce cap: it breaks reversibility. If a budget is needed, shorten T in warm-up and freeze it.
- Test J = 2, n = 4 against rejection sampling before any run.

**Kill.**
- Median bounces per trajectory > 2000 at any level in the real joint (cost passes his sweep).
- At equal wall time against his joint: R̂(log λ_j) > 1.05, or the minimum ESS/s over log λ_j and θ_j at 9 points below his, at any level.
- Paired MSE ratio per level > 1.

**If the levels creep together** (R̂ of the level-averaged curve > 1.05): add the stack-shift block (idea 3), then run the same move on the **whole stack at once**, with walls θ_{j+1,i} ≥ θ_{j,i}. Same exit-time formula on the difference; the reflection uses P_{j+1}⁻¹e_i and −P_j⁻¹e_i, with denominator (P_{j+1}⁻¹)_ii + (P_j⁻¹)_ii. Untested.

## 1. Ranked ideas

| # | Idea | Family | Status |
|---|---|---|---|
| 1 | **T-block:** collapsed λ draw + deterministic transport of θ, inside his P-MALA | proximal θ kernel; λ handling only | **mechanism smoke-tested (§5)** |
| 2 | **T-block in the box** as the joint λ move (his joint sampler and the Gibbs joint) | both | **failed in my proxy box (step 0.059 = conjugate); dropped, see "Joint design"** |
| 3 | **Stack-shift Gibbs block** for the joint: all levels move by one common curve | both | untested |
| 4 | **Gap coordinates + truncated-Gaussian kernel** (analytic elliptical slice, or reflective HMC) replacing pCN-with-rejection | non-proximal | superseded by per-level reflective HMC ("Joint design"), which passed a proxy check |
| 5 | **Metric-whitened ASIS** (no augmentation; his own metric P as the non-centring weights) | proximal | untested; fallback to 1 |

### Idea 1: T-block (replaces his Block 3b ASIS)
**Mechanism.** λ is drawn from its conditional with θ integrated out, so its step is the collapsed posterior width, not 1/√m. θ is then *moved*, not redrawn: its standardised fluctuation is kept and re-expressed at the new λ.

**Algorithm** (after his conjugate λ draw; a = 1/(t₂σz), r = y − ψz as in his code):
1. x_j ~ InvGauss(mean 1/(λ|Dθ|_j), shape 1) — `draw_x_exact`; x = 1/t, t = λ²s. Auxiliary, dropped after the block.
2. P(η) = diag(a) + e^{2η} Dᵀdiag(x)D, μ(η) = P(η)⁻¹(a∘r). Slice-sample η′ from
   f(η) = (a₀+m)η − b₀e^η − ½ log det P(η) + ½ (a∘r)ᵀμ(η) — exactly `logf` in `e07_sweep`.
3. θ′ = μ(η′) + R(η′)⁻¹ R(η) (θ − μ(η)), where RᵀR = P is the banded triangular factor that `banded_solve_logdet` already builds.

**Exactness.** Given (t, z, σ), the map (θ, η) ↦ (ω = R(η)(θ − μ(η)), η) has Jacobian det R(η), and the target factorises as N(ω; 0, I)·e^{f(η)}. Step 2–3 is a Gibbs update of η | ω. Step 1 is an exact auxiliary draw. No MH step, no tuning constant. Target: his posterior, unchanged.

**Code.** One new C++ export, `banded_transport(w, r, iw0, iw1, theta)` (two QR passes, one banded multiply, one back-substitution; ≈ 40 lines from `banded_solve_logdet`). `pmala_step` untouched.

**Cost.** Guess **+20–25% per sweep**: your whole exact sweep, slice included, ran 1.1 ms against 4.3 ms for his sweep at n = 300 on my machine. To be measured in C++.

**Confirm:** λ quantiles within 10% of exact Gibbs in every cell; ESS(log λ)/s ≥ 10× his; S paired MSE ratio against his at equal wall time ≈ 0.75–0.85; VS 0.97–1.04.
**Kill:** ESS(log λ)/s < 10× his, or S median ratio > 0.90 against his at 1.25× sweeps, or any VS cell > 1.05.
**Pilot:** 18 sprint cells × 5 seeds, his 1.25× sweeps as the equal-time arm. ≈ 1.5 core-h.

**Honest position.** Idea 1 should reproduce the exact-Gibbs MSE (same posterior, λ now mixing) at ≈ 1.2× his cost, where exact Gibbs gets there at 0.15–0.24×. With the scope widened it loses to exact Gibbs on compute for the individual model. Its value: (i) the fallback if Felipe requires P-MALA for θ; (ii) step 3 is what the joint needs (idea 2).

### Idea 2: T-block in the box (joint) — DROPPED
*Proxy check (one level, fixed box at the true 0.97/0.99 curves, n = 300): mean |Δ log λ| = 0.059 against the kill line 2/√m = 0.116. The nearest wall limits the transport. Original text kept for the record.*
Same block per level, with f(η) = −∞ whenever θ(η) leaves [θ_{j−1}, θ_{j+1}] (as `asis_box_step` does; one O(n) transport per slice evaluation). Target N(ω; 0, I)·e^{f(η)}·1{θ(ω, η) ∈ B}; slice on η | ω is exact. **Rejection-free:** the current state is feasible, so the slice always contains a neighbourhood of it.
**Confirm:** ESS(log λ_j)/s ≥ 10× the accept-iff-in-box version at τ ≥ 0.97. **Kill:** mean |Δ log λ_j| per sweep at τ ≥ 0.97 below 2/√m ≈ 0.09, i.e. no better than the conjugate draw. **First measure** the acceptance of your independence block per level: if it is > 20% at 0.99, idea 2 is unnecessary.

### Idea 3: stack-shift Gibbs block (joint)
Add one common curve Δ to **every** level: θ_j ← θ_j + Δ. Ordering is preserved for any Δ, so there is no box. Given all (s_j, z_j, λ_j, σ_j), Δ ~ N(P_Σ⁻¹ Σ_j P_j(μ_j − θ_j), P_Σ⁻¹) with P_Σ = Σ_j P_j, banded: one `banded_gauss_draw` with w = Σ_j w_j, iw = Σ_j iw_j. Exact Gibbs along a translation; cost ≈ 1/J of a sweep.
**Why:** at 0.97–0.99 the levels are stacked, and one-level-at-a-time updates can only creep; the common mode moves at full posterior scale.
**Confirm / kill:** ESS/s of the level-averaged curve at 9 points improves ≥ 2× at equal wall time on a 0.95–0.99 stack; kill below 1.3×.
His joint P-MALA has no s_j, so there it is a Metropolis move: propose Δ ~ N(0, cP̃⁻¹) with P̃ the sum of his level metrics, accept with probability min{1, exp Σ_j [U_j(θ_j) − U_j(θ_j+Δ)]} (symmetric proposal; one step size c).

### Idea 4: gap coordinates
Parametrise (θ₁, g_j = θ_{j+1} − θ_j ≥ 0). Each g_j | rest is Gaussian (precision Σ_{l>j} P_l) truncated to the positive orthant: one-sided constraints, at the gap's own scale. Sample with elliptical slice sampling using closed-form feasible angles (rejection-free, no step size), in segments of 25–50 points so one bad coordinate does not shrink the whole move; fallback: exact reflective HMC (Pakman–Paninski), O(n) per wall hit.
**Kill:** ESS/s of θ at 0.99 no better than pCN-with-rejection at its best r.

### Idea 5: metric-whitened ASIS (no t)
θ(η) = c_η + L_η⁻ᵀ L_{η₀}ᵀ(θ − c_{η₀}), P_η = diag(a) + κe^{2η}/2·DᵀD = L_ηL_ηᵀ, c_η = P_η⁻¹(a∘r); slice on
f(η) = (a₀+m)η − b₀e^η − ½Σa(θ(η)−r)² − e^η‖Dθ(η)‖₁ − ½ log det P_η.
His ASIS is the special case a → 0. Exact; decoupling only approximate (guess: weaker than idea 1). Try only if idea 1 is ruled out for using the scale mixture.

## 2. Critique of the exact augmented Gibbs (leading candidate)
**Individual sampler: correct.** I re-derived the collapsed density in `e07_sweep` step 5; it matches. σ | θ with z integrated out is right.

**Is the joint design exact?** Yes, under conditions.
- *pCN + reject outside the box:* exact (pCN is reversible for the unconstrained Gaussian conditional; MH against the truncated target accepts iff inside).
- *Collapsed block, accept iff θ′ ∈ box:* exact, because the proposal (slice kernel on η, then fresh θ′) is reversible for the **unconstrained** conditional, so the MH ratio against the truncated target is just the indicator. Four things must hold:
  1. On rejection **both λ and θ revert**. Keeping λ′ with the old θ samples λ from p_coll(η) and drops the factor Pr(θ ∈ B | η). This is the likely bug.
  2. The slice kernel must be reversible: fixed width and step limits, nothing adapted from the current state.
  3. t drawn from its conditional immediately before, and held fixed.
  4. No importance ratio. It is not an independence sampler; adding a ratio would break it.

**Where it fails (0.97–0.99).**
- The collapsed block's acceptance is Pr(N(μ, P⁻¹) ∈ box), exponentially small in n. Your own smoke (`joint/RESULTS.md`) shows his P-MALA proposals, at a small local step (√δ ≈ 0.3–0.4 in his metric), already leave the box 23% of the time at 0.97 and 30% at 0.99. A full-scale draw will essentially never land inside (guess: < 10⁻³). λ_j then falls back to the conjugate draw, and his slow-λ problem returns exactly at the levels the paper cares about.
- pCN contracts towards the **unconstrained** mean μ_j, which at tight levels can lie outside the box. His prox is box-constrained and centres proposals inside; pCN does not. Expect r → 1, θ mixing no better than his, and stalls at the walls. r also becomes a per-level tuning constant.
- Level-at-a-time updates of a tight stack mix slowly whatever the within-level kernel.
- **Fixes:** per-level reflective HMC ("Joint design"), then idea 3. Idea 2 did not survive my proxy check.

**The right equal-compute comparison.**
- Total core-seconds on one node type, single-threaded, all chains and all warm-up counted, compile time excluded.
- **Curves, not points:** paired MSE at budgets T/8, T/4, T/2, T, 2T (T = his paper run). Claim dominance at every budget. This is what protects against the P3 outcome ("the gain was compute").
- Give his sampler his best protocol at each budget (his 2× arm is the bar on S, not his 1×).
- Report **two errors**: MSE to the truth, and distance to a long-run reference posterior mean. Only the second measures the sampler; the first can move either way with convergence (see VS).
- Mixing: min over monitored scalars of ESS/s and R̂ over ≥ 4 chains, same rule for both.
- Joint: equal total core-seconds over all levels.

**Why VS can be 3–4% worse with the same posterior.**
1. *Most likely (guess):* his VS runs are not at the posterior either. With ESS(log λ) of 2–30, each run sits in a narrow λ window: a plug-in-like estimate. The exact posterior averages over the full λ spread (10–90% range ≈ 2.5× in my check), and at its upper end the VS bump is over-smoothed. Bias is convex in λ, so the mixture costs a little.
   - *Test:* in the two cells, compare sd(log λ) within run, his against exact; average the exact sampler's conditional means μ over draws inside his λ window and see if his MSE is reproduced; run his sampler at 8× sweeps and check the ratio goes to 1.00.
   - *Prediction:* the two cells are among those where Gibbs/P-MALA λ > 1 (`crosscheck_sigma_gibbs_vs_pmala.csv`: VS-Mixed-0.05 at 1.07, VS-Beta-0.95 at 1.06).
2. *MSE to the truth is a property of the posterior, not the sampler* (ALD is a working likelihood). A better-converged chain is not guaranteed a lower MSE. If test 1 confirms, no sampler can remove the 3–4%; only the prior can.
3. *Multiplicity:* 18 cells, 5 seeds, t₄ intervals. Rerun the two cells with 20 seeds before reading anything into them.
4. *Unlikely:* his clamps (z ∈ [1e-8, 1e4]); Monte Carlo error (exact keeps thousands of near-independent draws).

**Free gain for both samplers:** report the average of μ(λ, t, z, σ) instead of the average of θ draws. Same estimand (Rao–Blackwell), lower Monte Carlo variance, zero extra cost in the T-block or the collapsed block. Guess: < 1% at current run lengths, more at short budgets.

## 3. What I would NOT try
- **More ASIS or lamjump variants**, K_theta > 1, longer ADMM: none changes the 1/√m step. θ is not the bottleneck.
- **Tempering or more chains for λ:** the problem is step geometry, not multimodality; it only multiplies compute.
- **Unadjusted proximal samplers (MYULA) or empirical-Bayes λ (SAPG):** change the target; your fixed-λ and fixed-σ arms already failed.
- **λ-collapsed P-MALA** (θ target ∝ (b₀+‖Dθ‖₁)^{−(a₀+m)}): removes the Gibbs lag but ‖Dθ‖₁ still diffuses at √δ/√m per move. At best 2×.
- **Selling a b₀ change as a sampler gain.** b₀λ ≈ 5 on S in my check: the prior caps λ. That is a model change and needs its own paired test.
- **pCN-with-rejection and the independence collapsed block at 0.97–0.99** without first measuring their acceptance.

## 4. Suggested order
*Updated after attempt 1.*
1. Implement `banded_rhmc` (see "Joint design"); pass the J = 2, n = 4 exactness test; run the real joint at 0.90–0.99 and read bounces, R̂ and ESS/s per level.
2. Add the stack-shift block (idea 3) if the level-averaged curve is slow; whole-stack reflective HMC after that.
3. Idea 1 individual pilot only if a proximal θ kernel is still required. Idea 2 is dropped.

## 5. My local check (one dataset; mechanism only, not evidence on MSE)
S / Normal, τ = 0.5, n = 300, seed 1, his priors (b₀ = 5e-4), 1200 sweeps, 400 burn-in, one chain. Prototype in R with dense Cholesky, so its time is not a timing.

| Arm | ESS(log λ) of 800 | λ median (10%–90%) | mean \|Δ log λ\| of the block | MSE (1 seed) |
|---|---|---|---|---|
| His, ASIS off | ≈ 10 | 492 (416–544) | – | 0.0090 |
| His, ASIS on | ≈ 3 | 1170 (713–1670) | 0.020 | 0.0042 |
| **His P-MALA + T-block** | **≈ 500** | **10400 (6510–16000)** | **0.33** | 0.0023 |
| Exact Gibbs (yours) | ≈ 350 | 10200 (6260–15700) | – | 0.0024 |

- The T-block chain reaches the exact-Gibbs λ distribution; his chain is still 9–20× below it after 1200 sweeps.
- Conjugate step for reference: 1/√m = 0.058.
- **Compute disclosure:** my first two runs used multithreaded BLAS by mistake (one was killed at 300 s; together up to ≈ 4 core-hours on this PC, not NOTS). The reported run was pinned to one core, 30 s.
