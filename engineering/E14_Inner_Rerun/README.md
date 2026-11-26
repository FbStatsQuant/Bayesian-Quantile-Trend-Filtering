# E-14 interior quantile rerun

E-14 reruns Bayesian-PMALA for the VS and S interior simulations using
all 100 data seeds per signal, noise, and quantile cell. The table builder
updates the Bayesian-PMALA rows of the six paper tables and copies the
published competitor entries. [Replication rule and evidence](DATA_MATCH.md#pmala-replication-rule)

| Setting | Published VS | Published S | E-14, both signals |
| --- | --- | --- | --- |
| Sampler initialization and warm-up | October snapshot, θ starts at y and λ updates during warm-up | Same as VS | E-13a sampler at `63f2a56`, data-based start and λ held for the 200 warm sweeps |
| λ interweaving after warm-up | Original ASIS on | ASIS off | Spline-held ASIS with `asis_q = "fixed"`, cycling through dimensions 10, 20, and 40 |
| Total sweeps / burn-in | 30,000 / 10,000 | 20,000 / 5,000 | 30,000 / 10,000 |
| Gamma λ prior rate `b0` | 0.001 | 0.0005 | 0.001 for VS and 0.0005 for S |
| σ prior, sample size, and order | IG(0.1, 0.1), 500, 2 | IG(0.1, 0.1), 500, 2 | IG(0.1, 0.1), 500, 2 |
| Data seed | Replication seed 1–100 | Replication seed 1–100 | Same replication seeds and generator |
| MCMC seed | Replication seed + 1000 | Replication seed + 1000 | 10001 + zero-based task index, distinct across all 3,000 chains |

The data match across old and new fits. The MCMC streams differ.
[VS configuration](../../experiments/interior_quantiles/individual_nots_20261003/VS_b0001/config.R#L8) ·
[S configuration](../../experiments/interior_quantiles/individual_nots_20261003/S_b00005/config.R#L8) ·
[Old chain seeding](../../experiments/interior_quantiles/individual_nots_20261003/VS_b0001/worker.R#L37) ·
[E-14 worker](e14_run.R#L45)

## Fit reproducibility

Bitwise replay of fitted chains is limited to the same CPU or node
family with the same software and settings. Across node families,
individual fits can differ by Monte Carlo-sized amounts. In NOTS
replay job `2921171` under R 4.5.2, VS Mixed at τ = 0.25, seed 1
(index 1100), was identical. S Beta at τ = 0.50, seed 1 (index 2200),
changed in MSE from 0.000318 to 0.000385. S Gaussian at τ = 0.75,
seed 1 (index 1800), changed from 0.00222 to 0.00204.

From the repository root, build the six LaTeX fragments, comparison CSV,
and health report in `engineering/E14_Inner_Rerun/out/`. The MSE comparison
for the owner is written to `engineering/E14_Inner_Rerun/old_vs_new_mse.md`.

```bash
Rscript --vanilla engineering/E14_Inner_Rerun/e14_tables.R runs/E14-inner-rerun-20261125/
```

All 3,000 results must pass validation before the builder writes the LaTeX
fragments. The run issue report lists missing and failed fits.
[Execution and diagnostics](RUN.md)

For the Markdown health lines, place verified scheduler counts in
`e14_attempts.csv` in the run directory. Use one row each for VS and S
with columns `signal,n_failed_attempts,n_rerun`. The final RDS files
provide λ ESS and current fit status. Scheduler accounting supplies
the retry history.

## E-14b common-rate rebuild

After GO, combine the original E-14 VS results at b0 = 1e-3 with the
E-14b S results at b0 = 1e-3.

```bash
Rscript --vanilla engineering/E14_Inner_Rerun/e14b_tables.R \
  runs/E14-inner-rerun-20261125/ runs/E14b-inner-S-b1e3-20261125/
```

The rebuilt fragments, MSE Markdown, detailed comparison, health reports
and recomputed claims are written to `out/b1e3/`. The original E-14
outputs remain in their current locations. The updated MSE report uses
the pre-E-14 published values as its baseline. The claims report also
shows the values from the current manuscript for comparison. Each run
may supply its own `e14_attempts.csv` with the scheduler counts for its
selected signal.
