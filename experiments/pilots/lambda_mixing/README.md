# lambda-mixing pilot (HQ, 2026-11-25)

Same data as `../default_prior_VS_normal_t075`: VS baseline, Normal noise, tau 0.75, n 500, seed 1, order 2,
lambda ~ Gamma(1, 1e-5), sigma ~ IG(0.1, 0.1), 30k sweeps with 10k burn-in. There are 2 chains per variant (chain seeds 1001, 1002).

**Variant.** Generalised ASIS (`asis_general.R`). The interweaving lambda move holds the projection of theta onto q cubic
B-splines fixed and rescales only the remainder. q = k + 1 with the polynomial basis is the canonical move. The move is exact: it passes
`test_asis_general.R` (grid reference, n = 4), and a deliberately wrong Jacobian fails it (z = 256).

| variant | minutes | lambda ESS | lambda ESS/min | theta ESS median | MSE | coverage |
|---|---|---|---|---|---|---|
| current (q = 3, polynomial) | 5.74 / 4.10 | 8.0 / 6.9 | 1.4 / 1.7 | 85 / 92 | 0.00519 / 0.00524 | 0.962 / 0.926 |
| q = 20 | 6.09 / 4.16 | 105 / 111 | 17.3 / 26.6 | 89 / 89 | 0.00518 / 0.00539 | 0.968 / 0.960 |
| q = 40 | 6.21 / 4.19 | 79 / 66 | 12.7 / 15.8 | 85 / 87 | 0.00493 / 0.00538 | 0.956 / 0.918 |
| q = 80 | 5.65 / 3.88 | 44 / 44 | 7.8 / 11.3 | 88 / 87 | 0.00504 / 0.00510 | 0.958 / 0.940 |

Wall-time differences between the two chains of a variant come from Owls load. Read the efficiency columns within a lane.
Run: `owls_run -j 1 -- ./lane.sh "<name> chain_seed=<s> [asis_q=<q>]" ...` from this folder.

The per-chain draws (`results/<variant>.rds`, 9 MB, not in git) were moved on 2026-11-25 (E-12) to the git-ignored `runs/pilot-lambda_mixing-20261124/` on Owls. A re-run writes them to `results/` again; move them there too.
