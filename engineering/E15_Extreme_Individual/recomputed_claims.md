# Extreme-upper-quantile manuscript claims

HQ review only. The prior-rate decision remains open.

Rankings and ties use the four displayed MSE decimals. The advantage is measured relative to the smallest competing MSE in the same cell. Crossing summaries use the displayed two decimals.

| Claim | Published | Recomputed |
| --- | --- | --- |
| VS Gaussian/mixed normal from τ = 0.93, joint MSE strictly smallest | 10/10 | 9/10 |
| VS Gaussian/mixed normal from τ = 0.93, nearest competitor MSE divided by joint MSE as τ increases | Normal 1.01× to 1.36× (strictly increasing). Mixed 1.03× to 1.71× (strictly increasing) | Normal 1.01× to 1.36× (strictly increasing). Mixed 0.98× to 1.71× (strictly increasing) |
| VS mixed normal at τ = 0.99, joint advantage and reference MSEs | Joint 0.1240, individual 0.2458, horseshoe 0.2123, ADMM 0.2980 | Joint 0.1240, individual 0.2596, horseshoe 0.2123, ADMM 0.2980 |
| VS Gaussian/mixed normal at τ = 0.90, MSE winners | Mixed laplace. Normal laplace and horseshoe | Mixed individual. Normal individual and laplace and horseshoe |
| VS Beta at τ = 0.90 through 0.98, horseshoe MSE strictly smallest | 5/5 | 5/5 |
| VS Beta at τ = 0.99, MSE winners | joint and individual smallest (joint 0.0132, individual 0.0132) | joint smallest (joint 0.0132, individual 0.0230) |
| S Beta/Gaussian, ADMM MSE strictly smallest | 12/12 | 12/12 |
| S Beta/Gaussian, ADMM smallest and joint second | 12/12 | 12/12 |
| S mixed normal, MSE endpoints at τ = 0.90 and 0.99 | ADMM 0.0158 to 0.2911, joint 0.0280 to 0.0940, individual 0.0485 to 0.2324 | ADMM 0.0158 to 0.2911, joint 0.0280 to 0.0940, individual 0.0282 to 0.2446 |
| S mixed normal, levels where joint MSE is strictly smallest | 0.97, 0.98, 0.99 | 0.97, 0.98, 0.99 |
| Both signals, joint MSE strictly below individual MSE | 34/36 (exceptions: VS Normal 0.90, VS Beta 0.99) | 32/36 (exceptions: VS Beta 0.90, VS Mixed 0.90, VS Normal 0.90, VS Mixed 0.93) |
| VS Gaussian at τ = 0.90, joint and individual MSE | Joint 0.0135, individual 0.0134 | Joint 0.0135, individual 0.0116 |
| VS Beta at τ = 0.99, joint and individual MSE | Joint 0.0132, individual 0.0132 | Joint 0.0132, individual 0.0230 |
| Crossings among adjacent reported levels, individual versus joint | Positive in 6/6 individual, 6/6 Laplace, 6/6 horseshoe, and 6/6 ADMM signal/noise groups. Joint has zero in 24/24 neighboring cells | Positive in 6/6 individual, 6/6 Laplace, 6/6 horseshoe, and 6/6 ADMM signal/noise groups. Joint has zero in 24/24 neighboring cells |
| Appendix VS neighboring individual counts | 12/12 positive (mean counts 23.82–248.75) | 12/12 positive (mean counts 107.54–261.42) |
| Appendix VS total individual counts | 12/12 positive (mean counts 42.99–285.81) | 12/12 positive (mean counts 226.78–362.63) |
| Appendix S neighboring individual counts | 12/12 positive (mean counts 28.04–225.52) | 12/12 positive (mean counts 99.12–260.20) |
| Appendix S total individual counts | 12/12 positive (mean counts 49.51–274.88) | 12/12 positive (mean counts 263.22–389.56) |

The comparison covers the prose around the extreme MSE and crossing tables. The design still fits six levels separately for the individual sampler and counts crossings only among 0.96–0.99. The appendix counts index-level inversions, adds the specified pair counts, and averages over paired data seeds. All 48 joint crossing entries remain zero.

Appendix C.9 scope considerations are recorded in the [draft notes](WRITING_NOTES.md).

[Extreme MSE prose](../../paper/sections/simulations.tex#L92) · [Crossing definition](../../paper/sections/appendix_simulations.tex#L144)
