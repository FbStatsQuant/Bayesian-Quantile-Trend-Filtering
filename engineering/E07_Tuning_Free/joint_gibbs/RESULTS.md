# E-07 joint non-crossing Gibbs sampler: local validation (INTERNAL)

Code: `e07_joint.R` (`bqtf_joint`, sources `../sampler/e07_sampler.R`); scripts in `validate/` (val_a.R, val_b.R, val_b_smooth.R).
Owls via owls_run -j 1 (two jobs at a time). Two details of the code to know:
- Degenerate init: with J = 1 Felipe's rule gives theta = y, so sigma_0 = 0; guarded (sigma_0 = mean rho(y - median y)) when sigma_0 <= 0.
- The pCN radius r_j is adapted in burn-in on the logit scale toward acceptance 0.3 (acceptance above target lowers r), clamped to [0, 0.999], frozen after burn-in.
- Option `init = "smooth"` (not the default): theta_j = smooth.spline(y) + sd(residual) qnorm(tau_j); ordered by construction.

## (a) J = 1 vs bqtf_tf(move = "exact", standardize = FALSE), simulate_data(1, 500, 0.5, "VS", "Normal"), a0 = 1, b0 = 0.01, a_s = b_s = 0.1; 2 chains x 4000 sweeps, 1000 burn
| | joint (J=1) | bqtf_tf |
|---|---|---|
| lambda mean | 1193 (MCse 4.1) | 1191 |
| lambda median | 1174 | 1178 |
| sigma mean | 0.13579 (MCse 8.5e-5) | 0.13569 |
| MSE of mean curve vs truth | 0.004426 | 0.004469 |
| ESS(log lambda) | 2908 | 1969 |
Posterior-mean curve difference: RMS 0.0026, max 0.0060 (RMS = 0.033 x average posterior sd). Rhat(log lambda) 1.000. Agreement within MC error. pCN / collapsed acceptance 1 (no box); crossings 0. Time 26 s vs 13 s.

## (b) joint smoke: n = 500, VS, Normal, taus = .90 .93 .96 .97 .98 .99, a0 = 1, b0 = 0.01, a_s = b_s = 0.1, 2 chains x 3000 sweeps, 1000 burn, K_try = 5
Crossings: 0 in all sweeps and chains in both runs. Seconds per sweep (6 levels, per chain): 0.017 (Felipe init), 0.0155 (smooth init).

Felipe init (spec):
| tau | pCN acc | coll acc | r_pcn | lambda med | sigma med | MSE vs truth | Rhat log lambda | ESS |
|---|---|---|---|---|---|---|---|---|
| .90 | 0.0015 | 0 | 0.999 | 0.81 | 0.456 | 1.007 | 1.014 | 261 |
| .93 | 0.0026 | 0 | 0.999 | 0.84 | 0.239 | 0.695 | 1.088 | 15 |
| .96 | 0.015 | 0 | 0.999 | 0.84 | 0.032 | 0.506 | 1.028 | 55 |
| .97 | 0.267 | 0 | 0.998 | 0.85 | 0.002 | 0.463 | 1.026 | 64 |
| .98 | 0.213 | 0 | 0.999 | 0.94 | 0.005 | 0.352 | 1.346 | 4.6 |
| .99 | 0.308 | 0 | 0.998 | 1.29 | 0.005 | 0.190 | 2.422 | 2.4 |

Smooth init (`init = "smooth"`):
| tau | pCN acc | coll acc | r_pcn | lambda med | sigma med | MSE vs truth | Rhat log lambda | ESS |
|---|---|---|---|---|---|---|---|---|
| .90 | 0.212 | 0 | 0.961 | 1243 | 0.0586 | 0.0258 | 1.47 | 4.0 |
| .93 | 0.224 | 0 | 0.993 | 1622 | 0.0427 | 0.0339 | 1.72 | 3.1 |
| .96 | 0.205 | 0 | 0.995 | 1845 | 0.0262 | 0.0344 | 2.01 | 2.7 |
| .97 | 0.194 | 0 | 0.995 | 1839 | 0.0200 | 0.0336 | 1.65 | 3.2 |
| .98 | 0.231 | 0 | 0.994 | 1850 | 0.0137 | 0.0342 | 2.14 | 2.6 |
| .99 | 0.251 | 0 | 0.965 | 1605 | 0.0075 | 0.0370 | 1.57 | 3.5 |

## Reading
- The sampler is valid and non-crossing by construction (0 crossings). J = 1 reproduces the individual sampler.
- Mixing is BAD at J = 6. The collapsed (lambda, theta) block is accepted 0 times: a full exact 500-dim draw essentially never lands inside the pointwise box when the gaps between adjacent levels are small. pCN acceptance is ~0.2 only at r ~ 0.96-0.995 (tiny steps), so lambda moves by slow local drift: ESS(log lambda) 2.6-4 and Rhat 1.5-2.1 at 3000 sweeps (smooth init); not converged.
- With Felipe's init (theta_j = y + const, rough copies of y) the chain is stuck: the box is tight around rough neighbours, so smooth proposals are rejected (pCN 0.0015-0.015 at the three lower levels), lambda stays at ~1 and the posterior means are rough copies of y (MSE 0.19-1.0). Whether it ever leaves this region was not tested.
- Not tested: longer runs, different K_try, other targets for r_j, a cross-level joint move.

# v2 (e07_joint2.R, ss_tgibbs.cpp): exact single-site truncated Gibbs + one pCN-in-box + Gamma lambda + Felipe's asis_box_step; no collapsed block; smooth init
Tests: truncated-normal sampler vs exact moments on 12 intervals (incl. [8,Inf), [-12,-10], [30,31], [-1e-3,1e-3]): all agree to MC error. ss_tgibbs vs an exact rejection sampler on a 12-point box (accept 3.2%, 80k kept vs 400k sweeps): max |z| of the mean 1.09, sd ratio 0.994-1.002 (`validate/t_tn.R`, `t_ss.R`).

## (a) J = 1 vs bqtf_tf exact (same data/priors as above; 2 x 4000 sweeps, 1000 burn)
lambda mean 1172 (MCse 20.5) vs 1193; median 1149 vs 1177; sigma mean 0.13571 vs 0.13575; curve RMS diff 0.0038 (0.048 x posterior sd), max 0.018; MSE vs truth 0.004438 vs 0.004425. Agreement within MC error, but ESS(log lambda) is 110 vs 1900 (Rhat 1.03): without the collapsed block lambda mixes slowly even at J = 1.

## (b) head to head, joint smoke design (n=500, VS, Normal, a0=1, b0=0.01, IG(0.1,0.1))
Felipe = worker copy with lamjump = FALSE, 1 chain x 5000 iters (2500 burn, warm 200), 663 s. v2 = 2 chains x 2800 sweeps (1400 burn), 591 s CPU total (295/296 s each). ESS/s = ESS(log lambda) / total CPU s. Crossings: 0 and 0.
| tau | MSE v2 | MSE F | lambda med v2 | lambda med F | Rhat v2 | ESS v2 | ESS F | ESS/s v2 | ESS/s F | pCN acc v2 | F acc |
|---|---|---|---|---|---|---|---|---|---|---|---|
| .90 | 0.0128 | 0.0458 | 1269 | 4332 | 1.40 | 4.3 | 1.3 | 0.0073 | 0.0020 | 0.24 | 0.53 |
| .93 | 0.0121 | 0.0858 | 1660 | 7872 | 1.07 | 22.2 | 1.4 | 0.0376 | 0.0021 | 0.25 | 0.54 |
| .96 | 0.0130 | 0.1119 | 1769 | 8817 | 1.53 | 3.7 | 1.3 | 0.0062 | 0.0020 | 0.25 | 0.58 |
| .97 | 0.0155 | 0.1340 | 2020 | 9425 | 1.70 | 3.1 | 1.3 | 0.0053 | 0.0020 | 0.24 | 0.54 |
| .98 | 0.0227 | 0.1357 | 2119 | 7978 | 1.45 | 4.0 | 1.4 | 0.0067 | 0.0021 | 0.25 | 0.52 |
| .99 | 0.0326 | 0.2140 | 1715 | 1051 | 1.07 | 17.1 | 4.3 | 0.0289 | 0.0065 | 0.29 | 0.48 |
Median ESS/s ratio v2/F = 3.4. ASIS moved in 100% of sweeps for both; Felipe's outside-box rejections 0.32-0.40. Neither sampler has converged in lambda at this budget (v2 Rhat 1.07-1.70, ESS 3-22; Felipe ESS 1.3-4.3 in a single chain, so no Rhat). Felipe's lambda sits at 4e3-9e3 with oversmoothed means (MSE 0.05-0.21); v2's lambda 1.3e3-2.1e3.
Caveat: MSE differences partly reflect where each unconverged chain currently is (different starts: Felipe's rough y + const, v2's smooth init), not only the stationary posterior.
Scripts: validate/{felipe_run,v2_chain,analyze_b2,val_a2}.R.
