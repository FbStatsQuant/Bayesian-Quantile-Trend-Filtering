# VS baseline, inner quantiles, individual P-MALA with lambda rate 0.001

Requested 2026-10-12. Paper VS specification with one change: lambda prior Gamma(1, **rate 0.001**) instead of
rate 0.01. Everything else follows the source Settings block: ASIS on, 30,000 sweeps / 10,000 burn-in,
sampler snapshot `source/` (byte-identical to the 10-03 snapshot), k = 2, n = 500, sigma ~ IG(0.1, 0.1),
curvature metric kappa = 3, adapt target 0.50 throughout, 150 ADMM iterations, theta = y start, 200 warm sweeps,
data seed s, MCMC seed s + 1000 (same responses as every earlier inner run).
Override relative to the source Settings block (declared in `config.R`, enforced by `check_sampler_defaults`):
b0 0.01 -> 0.001.
Grid: VS x {Normal, Beta, Mixed} x tau {0.05, 0.25, 0.50, 0.75, 0.95} x seeds 1-100 = 1,500 fits.
Scripts are those of `../S_b0001` with the baseline, prior, run-length and path constants changed.

NOTS location: `/home/fb31/projects/Quant_Reg/Inner_Individual/VS_b0001` (scripts refuse other paths).
Raw draws: `/scratch/fb31/qr_data/inner_individual_VS_b0001/RUN_NAME`, linked as `runs/RUN_NAME/raw`.

## Steps

```bash
cd /home/fb31/projects/Quant_Reg/Inner_Individual/VS_b0001
bash submit.sh RUN_NAME            # snapshot code, preflight, submit the pilot: seed 1, all 15 cells
bash status.sh runs/RUN_NAME
Rscript --vanilla runs/RUN_NAME/code/process_results.R runs/RUN_NAME --pilot   # pilot table + crossings
bash release.sh runs/RUN_NAME      # remaining 1,485 fits (%400) + processing job (afterany)
```

The pilot tasks are part of the run, so the final averages use all 100 seeds without refitting seed 1.
See `../S_b0001/README.md` for outputs, retries and the overwrite rules (unchanged).
