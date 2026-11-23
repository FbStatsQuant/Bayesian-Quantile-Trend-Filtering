# E-07 joint v3 (reflective HMC per level): local validation (INTERNAL)
Files: `e07_joint_v3.R` (`bqtf_joint3`), `e07_banded_v3.cpp` (`banded_rhmc`; also `banded_omega/eval/transport` from the dropped T-block), `unit_rhmc_v3.R`, `unit_v3.R`, `val_j1_v3.R`, `chain_v3.R`, `calib_v3.R`, `felipe_run_v3.R`, `analyze_h2h_v3.R`, `run_retry_v3.sh`. Owls, owls_run -j 1 per job.
Design: per level s, theta (exact reflective HMC in the box [theta_{j-1}, theta_{j+1}], T = pi/2, no accept step, no cap), sigma|theta (z integrated), z, conjugate lambda. T-block dropped (design change). Stack-shift = optional (`stack = TRUE`).
## Exactness (n = 4 and 6, 3 random P/mu/boxes each, 40k HMC iterations vs rejection sampling from N(mu, P^-1) in the box, P(box) 0.005-0.17)
max |z| of mean difference 0.9-2.3 (6 cases x n coords), max |cov diff| <= 0.0022 (scale 0.08-0.31), all draws in box, min ESS 34k, bounces/trajectory mean 2-8 (max 26).
## Stack-shift dense check (n = 20, J = 2): gradient of log density at Delta=0 equals b (1.8e-9); banded mean vs dense P_S^-1 b 5.6e-15; 40k draws: mean within 2.1 MC-se, cov max diff 0.0028 (scale 0.61).
(T-block transport checks, dropped: iw0=iw1 returns theta to 7e-16; theta(omega, eta) vs dense Cholesky 2e-13. The logdet line of unit_v3.R has a bug in the check, not in the C++.)
## J = 1 vs bqtf_tf exact (VS/Normal tau .5, n=500, a0=1, b0=.01, 2 chains x 4000, burn 1000)
| | v3 | bqtf_tf |
|---|---|---|
| lambda mean (MCse) | 1200 (19.5) | 1189 |
| lambda median | 1182 | 1175 |
| sigma mean | 0.13573 (MCse 9e-5) | 0.13582 |
| MSE of mean curve | 0.004304 | 0.004376 |
| ESS(log lambda) | 145 of 6000 | 1916 (collapsed block) |
Curve RMS diff 0.0023 = 0.03 posterior sd; Rhat 1.007. Without the box the HMC step is an exact draw, so lambda moves by the conjugate step only.
## Head to head: n=500, VS/Normal, taus .90 .93 .96 .97 .98 .99, a0=1, b0=.01, IG(.1,.1), truth per tau
Felipe: lamjump=FALSE copy, config.R settings, 4800 it (burn 1600), 636 s, 1 core, 0.133 s/it. v3: 2 chains x 30000 sweeps (burn 10000), 271 s each, 0.0090 s/sweep. ESS(log lambda)/s uses all core-seconds incl. burn-in.
| tau | MSE F | MSE v3 | lam med F | lam med v3 | ESS/s F | ESS/s v3 | Rhat v3 | dlog lam F / v3 | bounces med (max) |
|---|---|---|---|---|---|---|---|---|---|
| .90 | 0.0655 | 0.0242 | 6015 | 1254 | 0.0020 | 2.13 | 1.002 | 0.052 / 0.051 | 9 (30) |
| .93 | 0.1126 | 0.0331 | 8971 | 1456 | 0.0021 | 2.16 | 1.003 | 0.052 / 0.050 | 19 (280) |
| .96 | 0.1340 | 0.0345 | 11267 | 1551 | 0.0021 | 2.43 | 1.001 | 0.049 / 0.051 | 25 (339) |
| .97 | 0.1495 | 0.0346 | 10552 | 1581 | 0.0021 | 2.77 | 1.001 | 0.052 / 0.051 | 28 (373) |
| .98 | 0.1558 | 0.0347 | 8971 | 1651 | 0.0020 | 2.66 | 1.000 | 0.051 / 0.051 | 22 (567) |
| .99 | 0.2965 | 0.0371 | 1010 | 1638 | 0.0031 | 2.19 | 1.001 | 0.053 / 0.050 | 7 (39) |
Crossings 0 (both), bounce cap hit 0. max Rhat of theta at 9 points 1.001-1.002; Rhat level-averaged curve <= 1.002; min ESS/s of theta (9 pts) 9.2 .. 3.0 (tau .90 .. .99).
Caveats: Felipe's chain at 4800 it is NOT converged (lambda still falling from ~3.7e4, ESS(log lambda) 1.3); his MSE here is burn-in dominated, not his converged value. v3 lambda moves only by the conjugate step (mean |dlog lambda| 0.05 = 1/sqrt(m)), ESS(log lambda) ~3% of draws.
Stack-shift variant (`stack = TRUE`, 2 x 30000, 0.0106 s/sweep): no gain; ESS/s 1.5-2.5, Rhat <= 1.002, MSE same to 3 digits.
