# E-02 free check: where do learned lambda and sigma sit?

Production sampler (order 2, a0=1, Normal noise s(u)=(1+u^2)/4, data seed s, MCMC seed s+1000). CAP=(a0+m)/b0, m=n-3. 15000 sweeps (burn 3000) for n<=2000, 12000 (burn 3000) for n=8000. Per-fit table: `free_check_table.csv`; raw traces: `/home/fb31/Bayesian-Quantile-Trend-Filtering/runs/E02/free_check/*.rds`.

## A. Existing records (BQTF sampler, not Onizuka/ADMM)
| source | n | tau | a0, b0 | lambda-bar | lambda/CAP | sigma-bar | L0, sigma/L0 |
|---|---|---|---|---|---|---|---|
| Extreme_Individual (NOTS), VS Normal, 100 seeds | 500 | .90/.93/.96-.99 | 1, .01 | 980/868; 550-650 | .020/.017; .011-.013 | not recorded | n/a |
| same, S Normal | 500 | .90/.93/.96-.99 | 1, .001 | 2155/1775; 850-1120 | .004/.004; .002 | not recorded | n/a |
| Air_sim (NOTS), 100 seeds | 500 | .01/.05/.10 | 500, .01 | 44.8k/47.0k/47.0k | .45/.47/.47 | .0080/.029/.051 | truth not reproducible |
| local pilot (VS Normal, seed 100) | 1000 | .5 | 1, .001 | 510 | .0005 | .1355 | not computed |
| Munich Rent / Growth sampler_diagnostics | real data | .1 etc. | 1, .001/.01 | 1078 / 27.6 | n/a | .42 / .91 | no truth |

Inner_Individual (VS_b0001, S_b0001, S_b00005): raw runs were deleted at archiving (2026-10-14). Only MSE tables survive (`deployment/paper_mse_tables`), with no lambda or sigma. No Gamma(1,1) pilot was found; Part B supplies one.

## B. Fresh learned runs (means over seeds; ns = 2 except n=8000, which is seed 1 only)
CAP is 49700 for VS (n=500, b0=.01). Columns: mean and median lambda, lambda/CAP, sigma-bar, effective penalty lambda-bar*sigma-bar, sigma/L0, sigma/L-hat, mean of lambda*||D3 theta||_1/m, kappa=f(q_tau)/sigma-bar, ESS of log lambda (of about 12000 kept draws), drift = mean log-lambda (2nd half) minus (1st half).

| base | tau | n | b0 | lam mean | lam med | lam/CAP | sig | lam*sig | sig/L0 | sig/Lhat | lam*SD/m | kappa | ESS log lam | drift |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| VS | .5 | 500 | .01 | 1123 | 1107 | .0225 | .135 | 152 | .99 | 1.03 | .98 | 9.3 | 10 | .20 |
| VS | .5 | 2000 | .01 | 2055 | 1997 | .0103 | .133 | 274 | .98 | 1.02 | .99 | 9.4 | 1.7 | .70 |
| VS | .5 | 8000 | .01 | 1027 | 969 | .0013 | .133 | 136 | .98 | 1.02 | 1.00 | 9.4 | 2.0 | .34 |
| VS | .9 | 500 | .01 | 1105 | 1090 | .0222 | .057 | 63 | .95 | 1.03 | .98 | 9.7 | 16 | -.11 |
| VS | .9 | 2000 | .01 | 1737 | 1718 | .0087 | .057 | 99 | .95 | 1.02 | .99 | 9.7 | 2.1 | .54 |
| VS | .9 | 8000 | .01 | 775 | 779 | .0010 | .055 | 43 | .94 | 1.03 | 1.00 | 9.9 | 1.6 | .23 |
| S | .5 | 500 | .01 | 1648 | 1609 | .033 | .135 | 223 | .99 | 1.02 | .97 | 9.3 | 11 | .11 |
| S | .5 | 2000 | .01 | 2398 | 2291 | .012 | .134 | 322 | .99 | 1.02 | .99 | 9.4 | 2.1 | .64 |
| S | .9 | 500 | .01 | 1321 | 1302 | .027 | .057 | 75 | .95 | 1.03 | .98 | 9.7 | 12 | .20 |
| S | .9 | 2000 | .01 | 1659 | 1570 | .0083 | .057 | 94 | .95 | 1.03 | .99 | 9.7 | 1.9 | .59 |
| VS | .5 | 500 | 1e-3 | 2067 | 2018 | .0042 | .136 | 282 | 1.00 | 1.03 | 1.00 | 9.2 | 15 | .04 |
| S | .5 | 500 | 5e-4 | 9087 | 7628 | .0091 | .136 | 1236 | 1.00 | 1.02 | .99 | 9.2 | 1.5 | 1.13 |
| VS | .5 | 500 | 1 (Gamma(1,1)) | 53 | 53 | .107 | .130 | 7 | .95 | 1.08 | .90 | 9.7 | 34 | -.01 |

Per-fit values are in the CSV. MSE of the posterior mean is at most .028 across fits.

Log-log slopes against n (seed-averaged, b0=.01; S has only n=500 and 2000):

| base | tau | slope of lambda-bar | slope of lambda-bar*sigma-bar |
|---|---|---|---|
| VS | .5 | -0.03 | -0.04 |
| VS | .9 | -0.13 | -0.14 |
| S | .5 | +0.27 | +0.27 |
| S | .9 | +0.16 | +0.16 |

## Conclusions
1. lambda is far inside its CAP. At b0=.01, lambda-bar/CAP falls from about 0.02-0.03 at n=500 to about 0.001 at n=8000. The rows with other b0 give .004-.01 (b0=1e-3 and 5e-4) and .11 (Gamma(1,1), which also has lam*SD/m = .90). The mean of lambda*||D3 theta||_1/m is about 1 in every fit, so the data fix the roughness ||D3 theta||_1 and lambda is the (a0+m)/(b0+||D3 theta||_1) conditional, not the prior cap. The Air runs (a0=n=500) sit near .45 of CAP, but there the prior shape a0 is large and truth is not reproducible.
2. sigma tracks the check loss. sigma-bar/L0 is 0.98-1.00 at tau=.5 and 0.94-0.95 at tau=.9. sigma-bar/L-hat is 1.02-1.03, except 1.08 for Gamma(1,1). kappa=f(q_tau)/sigma-bar is 9.2-9.9 and varies little across n and b0 (it is 9.7 at Gamma(1,1)).
3. Scaling with n is flat or slow, not growing like a power law. For VS, lambda-bar and lambda-bar*sigma-bar have slopes of -0.03 (tau=.5) and -0.13 (tau=.9); S gives +0.27 and +0.16 from two sizes only. All slopes rest on 1-2 seeds, 2-3 points and low ESS, so they are consistent with 0 to about 0.3 and cannot separate a rate. Note lambda-bar*sigma-bar is about lambda-bar*0.135 at tau=.5, so the two slopes coincide.
4. Mixing is the main caveat. ESS of log lambda is only 1.5-17 out of 12000 draws (34 at Gamma(1,1)) and about 2 at n>=2000. Drift between halves reaches +0.5 to +0.8 in log lambda at n>=2000 and +1.1 for S with b0=5e-4, so lambda-bar and its median at larger n are not converged and are probably biased toward the initial value. sigma mixes well (ESS 470-6300). Conclusions 1 and 2 survive this (the cap gap is 1-2 orders of magnitude and the sigma ratios are insensitive), but the n-slopes in conclusion 3 do not. The lambda-bar differences between b0 settings at n=500 are also only partly resolved, given the seed-to-seed spread (for example S, b0=5e-4: 11548 vs 6626).
5. The cause of the drift was not investigated (a slow lambda-theta coupling is the obvious candidate). Longer chains or a better lambda-move would be needed before quoting rates.
