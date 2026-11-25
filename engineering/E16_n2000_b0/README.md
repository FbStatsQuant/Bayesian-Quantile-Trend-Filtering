# E-16 λ-prior decision at n = 2000

## Design

The E-13a phase-2 generator supplies one Gaussian response per baseline (VS, S, PC)
and data seed (1–5), shared across both b0 values, both chains, and all quantiles.
The joint sampler fits τ = 0.3, 0.5, 0.7, 0.9 together with MCMC seeds 1001 and 1002.
The individual references fit each τ separately with MCMC seed 1001.
There are 60 joint runs and up to 120 individual references.

Both samplers use n = 2000, k = 2, λ ~ Gamma(a0 = 1, rate = b0),
σ ~ IG(0.1, 0.1), and the E-13a phase-2 spline-held ASIS move (the literal
`asis_q = "fixed"`). The block move is off. Full runs use 30,000 sweeps,
10,000 burn-in sweeps and 200 warm sweeps. The worker uses the sampler
source from commit `63f2a56`.

## Pre-registered decision rule

Pick **b0 = 1e-5** if **every** joint run at b0 = 1e-5 passes **all**
four gates below. Otherwise pick **b0 = 1e-3**.

1. The σ guard count is zero at every level.
2. Post-burn-in P-MALA acceptance is in the inclusive interval [0.4, 0.6]
   at every level.
3. λ split R-hat is ≤ 1.05 at every level, computed from the two chains
   in the same baseline × data seed × b0 cell. Post-burn-in λ ESS is ≥ 100
   separately for every chain and level. Use the E-13a classic split R-hat
   on raw λ and the per-chain `coda::effectiveSize()` estimator.
   An unavailable or non-finite diagnostic fails its gate.
4. The run completes without a sampler crash.

Report the same gates for b0 = 1e-3 for information. Report the joint to
matched individual MSE ratio by chain and level and flag ratios > 1.2.
Report quantile crossings. MSE and crossings are checks only and do not
affect the choice. The decision is evaluated after all 60 joint runs have
a result or a recorded sampler crash.

## Pilot and outputs

The pilot uses VS, seed 1, b0 = 1e-5 and MCMC seed 1001 for the joint
fit and separate individual fits at τ = 0.5 and 0.9. Short pilot results
and resource measurements are kept in their own directory. The full run
uses the same sampler settings with the registered sweep counts.

The output directory is `runs/E16-n2000-b0-decision-20261125/`. Results are
written atomically as one RDS per run. The RDS includes pointwise posterior
means and 95% bands, MSE, acceptance, λ and σ traces, warm IPM fallback
and burn-in σ guard counts, joint crossing totals, time, and sampler
commit. The θ draw arrays are held only in worker memory.
