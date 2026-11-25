# E-08: λ ~ Gamma(1, b0) quick look (VS)

The paper's individual P-MALA (`method/individual/Individual_Sampler_PMALA_Augmented.R`), run on one dataset per τ.

- **Design:** VS baseline, Normal noise, n = 500, data seed 1, k = 2, τ ∈ {0.05, 0.25, 0.50, 0.75, 0.95}.
- **Arms:** b0 = 1e-5 ("new") vs b0 = 1e-3 ("paper"), with a0 = 1. Same data and the same sampler seed (1001) for both.
- **Everything else:** the paper VS spec, copied from `experiments/interior_quantiles/individual_nots_20261003/VS_b0001/config.R`: σ ~ IG(0.1, 0.1), ASIS on, 30000 sweeps, 10000 burn-in.
- **Point estimate:** posterior mean.

**Scripts:** `e08_run.R` runs one fit, `e08_analyze.R` builds the table and figure, and `e08_job.slurm` is the NOTS array version (unused).

**Run:** Owls, 2026-11-23, through `owls_run -j 3` (xargs -P 3), about 220 s per fit.
- Fit files, which are heavy and kept out of git, are in `/home/fb31/Bayesian-Quantile-Trend-Filtering/runs/E08-lambdaprior-20261123/out/fits/`.
- Repo HEAD at run time: d44464994599d7803b54f738463679574db1b360.

Sampler SHA256 values:
```
e7b2ddf3df263d16f7eff0583d4e45bca5ae34f0f743e1059e5c6245b2f36e21  method/individual/Individual_Sampler_PMALA_Augmented.R
ed607632e3518d63ac0d8b87671de287970e9a5b3bd9f943fb1ae94e5042f766  method/individual/prox_admm_metric.cpp
```

**Results:** `results/e08_table.md` / `.csv` and `results/e08_fits.png`. MSE is mean_i (posterior mean θ_i − true quantile_i)². The λ and λσ medians and all ESS values are computed over the 20000 post-burn draws.
