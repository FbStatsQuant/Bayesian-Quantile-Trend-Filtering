# E-05 P-MALA fix test: report

*Engineering, 2026-11-23. HQ asked whether the paper's P-MALA can be fixed cheaply for the learned-λ prior b₀ = n⁻². Every change was made on a copy (`Individual_Sampler_PMALA_Augmented_E05copy.R`), whose only edit makes the metric cap configurable; the paper sampler is untouched. NOTS job 2857795, 6 cores, 1 h 47 min, 10.7 core-hours. That is 0.7 over the ≤ 10 cap, because the runs at n = 8k took longer than estimated.*

## Setup
- **Problem:** sin truth, N(0, 0.5²), τ = ½, learned λ and σ, b₀ = n⁻², n ∈ {2k, 8k}, seeds 1–3.
- **Run length:** the paper's 30k sweeps with 10k burn-in, and the paper's settings otherwise (init = "y", 200 warm sweeps, ASIS on).
- **Reference:** the exact banded Gibbs sampler on the same data (E-02 pvg).

**Variants:**
- **a:** metric cap raised from 1e8 to 1e20.
- **b:** λ initialised near its posterior scale, λ₀ = (0.27·n·κ̂^{1/6}/b₀)^{3/4}.
- **c:** both a and b.

## Result: none of the cheap fixes works
Means over the three seeds; the ratios are P-MALA ÷ Gibbs.

| variant | n | λ̄ ratio | Δ² ratio | ESS(log λ) per 20k draws | Gibbs ESS/s gain, Δ² / log λ |
|---|---|---|---|---|---|
| a, b, c | 2k | 0.0036–0.0044 | 6.7 | 2 | ≈ 2000–2700 / ≈ 240–270 |
| a, b, c | 8k | 0.000024 | 27.4 | 2 | ≈ 6400 / ≈ 126 |

- **λ is still collapsed.** It sits 2.5–4.5 orders of magnitude below the posterior (Gibbs λ̄ ≈ 3–4×10⁶ at 2k and ≈ 1×10⁸ at 8k), and the posterior risk is 7–27× worse.
- **At n = 8k all three variants give bitwise-identical output.** So neither the cap nor λ₀ ever enters the chain.

## What is wrong (root cause, from the code)
1. **λ₀ is overwritten at sweep 1.** With `init = "y"`, θ starts at the data. Block 3 then draws λ from λ | θ = Gamma(a₀ + m, b₀ + ‖Dθ‖₁) in the first sweep. With θ ≈ y, that gives λ ≈ m/‖Dy‖₁ ≈ 10³–10⁴, whatever λ₀ was. This explains why variants b and c equal variant a.
2. **The chain then stays in a self-consistent rough-θ, small-λ region.**
   - A small λ keeps the target for θ rough.
   - The P-MALA moves are local: step δ is adapted to about 50% acceptance under a curvature metric at the current small λ.
   - So θ never smooths enough for λ | θ to grow, and λ never grows enough for θ to smooth.
   - The cap is irrelevant because κλ²/2 stays far below 1e8 at these λ.
3. **Why Gibbs does not have the problem.** It draws θ | (z, s, λ) exactly, in one global Gaussian move. A single sweep therefore takes θ to the smoothness that λ implies, and the λ–θ feedback converges in a few sweeps.
   - E-02 §4 shows the same thing at b₀ = n⁻²: P-MALA's λ̄ ratio is 0.51 at n = 500, 0.004 at 2k and 3×10⁻⁵ at 8k.
4. **At the paper's b₀ = 1, λ is small anyway** (λ̄ ≈ 60–10⁴), the trap is the posterior, and P-MALA agrees with Gibbs (E-02 §4). **The paper's reported results are unaffected.**

## What would fix it (not run here; it moves to E-07)
The fix has to change the θ kernel or the initialisation, not the cap.
1. **Start θ at the MAP at λ₀**, the QTF at penalty λ₀σ̂, and keep λ out of Block 3 for the warm sweeps. This removes the trap at the start, but not the slow drift if local moves cannot follow λ.
2. **Make the preconditioner scale with λ:** the Gaussian-twin precision κI + (λ²/2)D′D, factorised banded. Proposals are then posterior-sized whatever λ is. This is E-07 item 3 (HQ brief).
3. **Joint λ–θ move:** ASIS is already on and does not suffice, since ESS(log λ) is about 2. A stronger move rescales θ's rough part together with λ.
4. **Or use the exact banded Gibbs θ draw**, which is the reference here.

These are tested in E-07's pilot within its 40 core-hour cap, not as further E-05 compute.

## Recommendation
- **Do not recommend b₀ ∝ n⁻² with the paper's P-MALA as it stands.**
- **For any shrinking-b₀ default, the θ update must be global or λ-scaled.** That is twin-precision P-MALA with a MAP warm start, or the Gibbs draw. This feeds E-07's λ-prior and preconditioner items.

**Files:**
- `e05_pmala_fix.R` (driver).
- On NOTS: `/projects/ml75/fb31/BQTF/runs/E05-pmala-fix-20261122/` (`e05.rds`, `e05_2857795.out`).
