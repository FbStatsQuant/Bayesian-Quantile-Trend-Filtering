# Paper risk: convergence of the published sampler at its published run lengths
*Engineering, 2026-11-23. Measured facts only; no remedies proposed.*

**Basis.**
- Felipe's sampler code, unmodified, at the paper's settings: individual VS 30k sweeps / 10k burn-in with ASIS; individual S 20k / 5k without ASIS; joint 30k / 10k; the paper's priors; n = 500 unless stated.
- The exact posterior is computed with an independent exact sampler (augmented Gibbs) on the same posterior.
- All comparisons are paired: same data, same seeds.

## 1. Individual sampler, n ≥ 1000: λ not converged
- **n = 1000/2000, Gaussian noise, 8 cells, 2 chains each** (`route_a/variants_results/V2_pilot_cells.csv`):
  - R̂(log λ) is **1.37–2.34**;
  - ESS(log λ) is **3–12** (summed over both chains, each 20k–30k sweeps).
- **His as-run λ against the exact-posterior median at n = 2000, τ = ½ (Gaussian):** S 2,325 vs 47,131 (**0.05×**); VS 9,069 vs 25,077 (**0.36×**).
- **n = 4000** (7 cells, 2 chains each; `v0t/v0t_fits.csv`): R̂(log λ) 1.85–2.25, with λ at 372–1,663 against posterior medians of 16k–38k in the same cells (`route_a/results/ra1_cells.csv`).

## 2. Individual sampler, n = 500, signal S: run length
- **ESS(log λ) per published-length run:** 1.8–19 at n = 500 (per-cell medians over 5 seeds, 18 cells) (`sigma_sprint/sigma_sprint_table.csv`).
- **Running his unchanged sampler longer on S** (9 cells × 5 seeds; `r1/runlength/runlength_cells.csv`):

| Sweeps (× published) | His λ ÷ exact-posterior λ | Median S MSE ratio vs 1× | Cells lower |
|---|---|---|---|
| 1× | 0.46 | 1 | — |
| 2× | 0.69 | 0.85 | 9/9 |
| 4× | 0.91 | 0.80 | 9/9 |

- **VS:** his λ is at 0.99 of the posterior at 1×. Partial 2× controls (21 fits) give a median MSE ratio of 1.02 vs 1×, with 3 of 9 cells lower.

## 3. Joint sampler: λ not converged
- **Grid:** 12 configurations: the paper's tail set (levels 0.90–0.99) and the central t50 set (0.2–0.8) × signals VS, S × 3 noise families. **One seed per configuration.**
- **His λ chains:** ESS(log λ) is **1–58** per 30k-sweep run.
- **His λ medians are 1.0–3.6× the exact posterior's** at almost every level. The posterior values are confirmed by two independent exact samplers (single-site truncated Gibbs, and reflective HMC with R̂ ≤ 1.008).
- **Crossings:** 0 in his output.
- **His output against the exact posterior mean** (MSE vs truth): his output has lower MSE at **55 of 78 levels**. The ten largest margins (posterior-mean MSE ÷ his MSE > 1.25) are:
  - S-Beta central 0.3, 0.5, 0.6, 0.7 (1.26–1.62);
  - VS-Beta central 0.6 (1.26);
  - S-Mixed tail 0.96–0.98 (1.35–1.51);
  - VS-Beta tail 0.90 (1.28);
  - VS-Mixed tail 0.93 (1.26).
  - Table: `joint_gibbs/gate_results/joint_gate_levels.csv`.
- **The exact posterior mean has lower MSE at 23 levels**, notably VS-Beta tail 0.93–0.99 (ratios 0.51–0.82).

## What is not known
- **Joint sampler at 2× or 4× its published length:** UNTESTED. It is not known whether his joint MSE moves toward the exact-posterior values as his λ converges.
- **Joint results rest on one seed per configuration.**
- **Individual results at n ≥ 1000** are Gaussian noise only for the R̂ table (§1). The larger accuracy comparison at n = 1000/2000 (18 + 6 cells × 3 seeds) is in `gibbs_vs/paired_more_seeds.csv`.
