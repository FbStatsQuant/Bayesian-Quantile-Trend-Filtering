# Interior-quantile claims with b0 = 1e-5

E-17 individual fits at b0 = 1e-5. Prepared for HQ review.

The archived baseline predates E-14. The current-paper column uses the tables supplied to this build. Ratios use the displayed six-decimal MSEs. Signed percentages compare PMALA with the smaller Onizuka MSE in each cell.

| Claim | Pre-E-14 published | Current paper | Recomputed with E-17 |
| --- | --- | --- | --- |
| VS MSE, largest ratio among the Bayesian samplers | 1.218389 | 1.218697 | 1.365737 |
| VS Beta MSE, horseshoe smallest | 5/5 | 5/5 | 5/5 |
| VS MSE, ADMM largest | 14/15 (exceptions: mixed normal at τ = 0.95) | 14/15 (exceptions: mixed normal at τ = 0.95) | 14/15 (exceptions: mixed normal at τ = 0.95) |
| S MSE, ADMM smallest | 15/15 | 15/15 | 15/15 |
| S MSE, PMALA divided by ADMM | 1.3716 to 3.1207 (Beta at τ = 0.05 to mixed normal at τ = 0.95) | 1.2842 to 2.0264 (Beta at τ = 0.05 to Beta at τ = 0.95) | 1.1777 to 1.6380 (Gaussian at τ = 0.25 to Beta at τ = 0.95) |
| S MSE versus Onizuka at τ = 0.25, 0.50, 0.75 | 9/9 below both, 0 above both, 0 between or tied (relative difference -23.30% to -15.16%) | 9/9 below both, 0 above both, 0 between or tied (relative difference -43.49% to -25.44%) | 9/9 below both, 0 above both, 0 between or tied (relative difference -49.46% to -33.75%) |
| S MSE versus Onizuka at τ = 0.05 and 0.95 | 1/6 below both, 5 above both, 0 between or tied (relative difference -14.92% to +18.07%) | 6/6 below both, 0 above both, 0 between or tied (relative difference -33.05% to -4.44%) | 6/6 below both, 0 above both, 0 between or tied (relative difference -49.83% to -20.34%) |
| VS MAD, Beta winner and ADMM ranking | 5/5 horseshoe wins under Beta. 13/15 (exceptions: mixed normal at τ = 0.05, mixed normal at τ = 0.95) ADMM largest overall. | 5/5 horseshoe wins under Beta. 14/15 (exceptions: mixed normal at τ = 0.95) ADMM largest overall. | 5/5 horseshoe wins under Beta. 14/15 (exceptions: mixed normal at τ = 0.95) ADMM largest overall. |
| VS MCIW versus Onizuka | 15/15 below both, 0 above both, 0 between or tied | 15/15 below both, 0 above both, 0 between or tied | 15/15 below both, 0 above both, 0 between or tied |
| S MAD versus Onizuka | 10/15 below both, 5 above both, 0 between or tied | 15/15 below both, 0 above both, 0 between or tied | 15/15 below both, 0 above both, 0 between or tied |
| S MCIW versus Onizuka | 10/15 below both, 0 above both, 5 between or tied | 15/15 below both, 0 above both, 0 between or tied | 15/15 below both, 0 above both, 0 between or tied |
