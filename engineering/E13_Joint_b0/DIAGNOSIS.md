# E-13a Phase 1: why the joint sampler breaks at b0 = 1e-5 (diagnosis only, nothing in method/ changed)

Setting: VS, Normal, n = 500, data seed 1, τ = (0.3, 0.5, 0.7, 0.9) jointly, chain seed 1001, Owls.
Runs: `e13_diag.R` (a copy of `pmala_box_step` that records each call, with the same RNG calls, so the chain is unchanged).
Outputs are in `runs/E13-joint-b0-20261125/diag/` (gitignored).

| Run | What | Sweeps |
|---|---|---|
| D1 | new move ("fixed"), defaults | 1,000 |
| D2 | old move ("poly"), defaults | 1,000 |
| W0 | D1 plus a record of every warm-start optimisation | 260 |
| W1 | D1 with no warm start (diagnostic override) | 800 |
| W2 | W0 plus a reference solve of each warm-start problem by the interior-point solver | 205 |

## 1. The pathology (levels τ = 0.3 / 0.5 / 0.7: acceptance 0, λ ≈ 1e6, σ ≈ 10–20)

**It starts in the warm start (sweeps 1–200), not in the exact sampler and not in the λ move.**

1. **Sweeps 1–3: λ jumps to 1e5–1e7 at the levels that have an upper neighbour.**
   - Warm sweeps replace θ_j by the conditional optimum (`prox_box`, γ = 1e4). They start from the data-free defaults: σ = 1, z = 1, λ = m = 497.
   - At levels 1–3 the upper neighbour is still the shifted raw data, which is wiggly. The fast unbounded solver (ADMM: an iterative optimiser, 300 iterations, step parameter ρ = median(a)) lands outside the box. So the accurate interior-point solver runs, and it returns the true optimum, which is very smooth (‖Dθ‖₁ ≈ 0.005).
   - The conjugate λ draw is then λ ≈ m / ‖Dθ‖₁ ≈ 7e4, rising to 1e6–1e7 within two sweeps.
   - Level 4 has no upper neighbour. There the ADMM point is accepted although it is far from the optimum (objective 380 vs 2.9 at sweep 1). It stays wiggly, so λ stays near 500.
2. **Sweeps 5–50: at λ ≈ 1e6–1e7 the warm-start ADMM stops converging.** ρ = median(a) is about 1e-6 of λ, so the solver is badly scaled.
   - Over the 200 warm sweeps, 88% of warm-start solves have an objective worse than the interior-point reference by more than 0.1% (W2). Gaps reach about 1,000× at levels 1–3.
   - The returned θ can be far off. Example: level 1 at sweep 7 has mean −9.9, while the true optimum has mean 1.5 and the data mean is 2.2.
   - These points have no lower bound to violate, so they are accepted.
3. **The σ runaway.** The σ draw sees the huge residuals: σ goes to 2.5, then 48, then 84.
   - z is drawn on the σ scale, so the working response r = y − ψ z moves by tens (ψ = +1.9 at τ = 0.3 and −1.9 at τ = 0.7).
   - The data weight a = 1/(t2 σ z) falls to 1e-4–1e-5, so the data barely pull θ back.
   - At the end of the warm start, levels 1–3 sit near θ ≈ −30 (the data lie in 0.5–4.8): MSE about 860–1,040, σ ≈ 10–22, λ ≈ 1e6–1e7.
4. **After the warm start, the exact P-MALA step (the θ update) accepts nothing.**
   - λ ≈ 1e6 means κλ²/2 ≈ 1e12. The metric weight is capped at c = 1e8, so its random noise in the difference directions is about √(1e12/1e8) = 100× too large.
   - The ℓ1 penalty term alone makes each proposal 40–1,400 nats worse (median: −348 / −241 / −1,440 at levels 1/2/3). The correction terms recover only 20–150 nats.
   - The step δ adapts down (0.2 → 2e-3 at sweep 500 → 1.7e-5 at sweep 1,000). It cannot fix this before reaching its floor of 1e-8. So the levels freeze where the warm start left them.
5. **The "out" column** is the share of P-MALA proposals, since the end of the warm start, that land outside the box [θ_{j−1}, θ_{j+1}]. Such proposals have target density 0 and are rejected.
   - At levels 1–3 it is 0.04–0.23. Early on, δ ≈ 0.2 and the proposal noise along the smooth (polynomial) directions is huge (variance δ/a with a ≈ 1e-4), so proposals cross a neighbour.
   - Later δ is tiny: proposals stay inside the box but the Metropolis–Hastings test rejects them (point 4).
   - Level 4's lower neighbour is about 30 units below it, so it never crosses (out = 0).

**The old move does the same (D2, poly).** It reaches σ ≈ 10–22, θ ≈ −15 to −42, MSE ≈ 900–1,070 and acceptance ≈ 0.
- λ in the stuck state is about 10× lower (1.3–1.5e5 vs 0.8–1.8e6), because the polynomial move has no extra Jacobian term pulling λ up.
- So **the new move neither causes nor removes the pathology. It raises λ in the stuck state, which shrinks the Cholesky margin (§2).**

**Without the warm start (W1, diagnostic only)** the opposite failure appears.
- Levels 1–3 stay almost unsmoothed: λ ≈ 1–9, ‖Dθ‖₁ ≈ 55–330, MSE 0.37 / 0.09 / 0.07 vs about 0.007 for the individual sampler.
- λ creeps up only slowly (level 1: 0.75 → 9 over 800 sweeps).
- So the warm start is the trigger here, but simply removing it does not give a healthy chain either. The coupled levels mix slowly in λ from either side.

## 2. The Cholesky crash (pre-existing, E-11)

- **Where:** `band_chol(Mc, "metric P")` at `method/joint/prox_box_metric.cpp:417` (in `pmala_box_move`), and the same call in the unbounded kernel at `method/individual/prox_admm_metric.cpp:194` and `:233`. It factors the metric P = diag(a) + c D'D, with c = min(κλ²/2, 1e8), as a band matrix (half-bandwidth k + 1 = 3). Unlike the ADMM and interior-point systems (`band_chol_ridge`), it gets **no ridge retry**.
- **Why it is not positive definite in floating point:**
  - D'D has a 3-dimensional null space (quadratics). On that null space P equals diag(a) alone, while its largest eigenvalue is about 64c.
  - Once c hits the cap (λ > 8.2e3) and a is small, the condition number passes about 1e16. Cancellation in the last pivots then gives a pivot ≤ 0.
  - Measured with the kernel's own factorisation for a uniform a: with c = 1e8 it fails for a < 1e-6; with c = 1e6, for a < 1e-8; with c = 1e4, for a < 1e-10. So it fails when a/c is below about 1e-14, at both n = 500 and n = 2000.
- **Link to the pathology:** in the stuck state c = 1e8 and a ≈ 1e-5 to 1e-4 (median 7e-4, minimum 7e-5), a margin of only about 100×. A σ spike (σ reached 50–84 in the warm phase), together with z near its upper clamp of 1e4, gives a = 1/(t2 σ z) below 1e-6 at some points, and the factorisation fails. **The crash is the end point of the same runaway**, not a separate defect. It can only happen once a level has collapsed.
- **Reproduced on Owls** (run C1: J = 2, τ = 0.75/0.95, b0 = 1e-5, old move; the E-10 setting, where all three code versions crashed on NOTS before sweep 500). It crashes at **sweep 201, level τ = 0.75: the very first exact step after the warm start.**
  - State at the crash: λ = 6.6e6, so c is at its 1e8 cap; σ = 5.3e4; |y − θ| ≈ 9.2e4 (the curve is about 92,000 units off the data); z at its 1e4 clamp at 423 of 500 points; a ≈ 1.8e-10.
  - `e13_crash_diag.R`: the smallest true eigenvalue of P (≈ 2e-10, on the quadratic null space) is far below the roundoff floor (≈ 1.4e-6, i.e. ε × largest eigenvalue). Both the kernel's band Cholesky and LAPACK fail. It passes only with c 1,000× smaller or a 1,000× larger.
- The J = 4 screen (16 runs, 30k sweeps each) never crashed: at J = 4 the warm runaway stopped earlier (σ ≤ 1.2e3).

## 4. A second, independent defect: the z draw loses precision when a residual is tiny

- `draw_z` (joint and individual, the same code) draws v from the inverse-Gaussian distribution with the textbook formula x = μ + μ²y/(2λ) − (μ/2λ)√(4μλy + μ²y²). Here μ = 1/(τ(1−τ)|e|), with |e| floored at 1e-10.
- When |e| ≲ 1e-8, the subtraction cancels catastrophically. Simulated at τ = 0.7, σ = 0.12:
  - |e| = 1e-8: 1.1% of draws are invalid (v ≤ 0) and z hits the 1e4 clamp;
  - |e| = 1e-10: 42% of draws do;
  - the true z is about 0.05 in both cases.
- **Seen in the screen:** in both b0 = 1e-3 new-move chains, σ at τ = 0.7 jumps from 0.12 to 15.6 (both chains) for one sweep (sweeps 18,648 and 24,629), then decays back over about 5 sweeps. One z at the clamp gives an expected σ ≈ (1e4 + ψ²·1e4/(2 t2))/(1.5 n) ≈ 15.9 ± 0.6. The size of the effect is small (5 sweeps in 20k), but it is a draw from the wrong conditional and an independent way to start a σ spike.
- Fix (not applied): use the stable form x = μ / (1 + w + √(w² + 2w)), w = μy/(2λ), or draw z directly from its generalised inverse-Gaussian conditional.

## 3. Fixes (described, NOT applied)

1. **Warm start (main fix; burn-in only, so the target is unchanged):**
   - make the warm-start optimiser converge: scale the ADMM ρ with λ, or use the interior-point solver whenever ADMM has not met a residual tolerance;
   - start z and σ at their conditionals given the starting θ, instead of z = 1 and σ = 1 (z = 1 shifts the working response by −ψ, e.g. +8.9 at τ = 0.9).
2. **Metric:**
   - factor P in scaled form, P/c = (a/c) I + D'D, with the null space handled exactly, or give "metric P" the same ridge retry as the other systems (still exact, since the same deterministic metric is used forward and backward);
   - then lift or rescale the 1e8 cap, so the proposal noise matches the ℓ1 penalty at large λ. The same lead was found in E-10 for θ mixing.
3. **Guard:** stop or flag a run when σ_j exceeds a data scale such as 10 × the median absolute deviation (MAD) of y. Here σ = 10–20 vs about 0.06 for the healthy level.
