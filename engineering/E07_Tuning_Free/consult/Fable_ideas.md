# Fable ideas for E-07 (INTERNAL)
*Fable, consultant, 2026-11-23. "Measured" = from your tables or my one local check (§5). Everything else is labelled guess.*

## 0. Bottom line
- **Why his λ is stuck (diagnosis).** Given θ, λ | θ ~ Gamma(a₀+m, b₀+‖Dθ‖₁) has relative sd 1/√m (≈ 4.5% at n = 500), and ‖Dθ‖₁ | λ sits at ≈ m/λ. The pair is a near-driftless random walk in log λ with step 1/√m; the data only enter at order df/m. Crossing a posterior of width w in log λ takes ≈ (w√m)² sweeps.
- **Why ASIS and lamjump do not fix it.** ASIS rescales the *whole* non-polynomial part of θ (signal included), so the likelihood pins the rescale to a few %. lamjump takes a prox step with γ = δ/2, far too short to re-shrink roughness to the new λ, so its step adapts back to ≈ 1/√m (your joint smoke: s = 0.06–0.15).
- **The fix that works** is the one your exact Gibbs already contains: move λ with θ integrated out, given the scale-mixture variables. I show below that this block can be bolted onto his P-MALA **without any Gaussian θ draw** (idea 1), and that the same construction repairs the joint design (idea 2).

## 1. Ranked ideas

| # | Idea | Family | Status |
|---|---|---|---|
| 1 | **T-block:** collapsed λ draw + deterministic transport of θ, inside his P-MALA | proximal θ kernel; λ handling only | **mechanism smoke-tested (§5)** |
| 2 | **T-block in the box** as the joint λ move (his joint sampler and the Gibbs joint) | both | untested |
| 3 | **Stack-shift Gibbs block** for the joint: all levels move by one common curve | both | untested |
| 4 | **Gap coordinates + truncated-Gaussian kernel** (analytic elliptical slice, or reflective HMC) replacing pCN-with-rejection | non-proximal | untested |
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

### Idea 2: T-block in the box (joint)
Same block per level, with f(η) = −∞ whenever θ(η) leaves [θ_{j−1}, θ_{j+1}] (as `asis_box_step` does; one O(n) transport per slice evaluation). Target N(ω; 0, I)·e^{f(η)}·1{θ(ω, η) ∈ B}; slice on η | ω is exact. **Rejection-free:** the current state is feasible, so the slice always contains a neighbourhood of it.
**Confirm:** ESS(log λ_j)/s ≥ 10× the accept-iff-in-box version at τ ≥ 0.97. **Kill:** mean |Δ log λ_j| per sweep at τ ≥ 0.97 below 2/√m ≈ 0.09, i.e. no better than the conjugate draw. **First measure** the acceptance of your independence block per level: if it is > 20% at 0.99, idea 2 is unnecessary.

### Idea 3: stack-shift Gibbs block (joint)
Add one common curve Δ to **every** level: θ_j ← θ_j + Δ. Ordering is preserved for any Δ, so there is no box. Given all (s_j, z_j, λ_j, σ_j), Δ ~ N(P_Σ⁻¹ Σ_j P_j(μ_j − θ_j), P_Σ⁻¹) with P_Σ = Σ_j P_j, banded: one `banded_gauss_draw` with w = Σ_j w_j, iw = Σ_j iw_j. Exact Gibbs along a translation; cost ≈ 1/J of a sweep.
**Why:** at 0.97–0.99 the levels are stacked, and one-level-at-a-time updates can only creep; the common mode moves at full posterior scale.
**Confirm / kill:** ESS/s of the level-averaged curve at 9 points improves ≥ 2× at equal wall time on a 0.95–0.99 stack; kill below 1.3×.
The same block is valid in his joint P-MALA with the P_j replaced by a draw-free MH version (propose Δ ~ N(0, cP_Σ⁻¹), ratio Π_j π_j(θ_j+Δ)/π_j(θ_j)).

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
- **Fixes:** ideas 2, 3, 4, in that order.

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
1. Measure, per level, the acceptance of the collapsed block and the pCN outside-rate on one VS fit at 0.90–0.99 (minutes).
2. Implement `banded_transport`; run idea 2 and idea 3 in the Gibbs joint.
3. Idea 1 individual pilot only if a proximal θ kernel is still required.

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
- **Compute disclosure:** my first two runs used multithreaded BLAS by mistake (one was killed at 300 s; together roughly 4 core-hours on this PC, not NOTS). The reported run was pinned to one core, 30 s.
