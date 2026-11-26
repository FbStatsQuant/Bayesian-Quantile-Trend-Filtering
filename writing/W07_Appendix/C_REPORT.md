# W-07 Appendix C rebuild: worker report

File: `paper/sections/appendix_pmala.tex`. Pages: was 42–53 (12 pp), now **41–46 (6 pp)**. C ends at the foot of p. 46 with no spare lines, so any change above it in the PDF can push 1–2 lines onto p. 47.

## Outline
| New | Content | Labels |
|---|---|---|
| C.1 | Full conditional distributions | app:pmala:conditionals |
| C.2 | Proximal map, individual sampler (ADMM in increment form, cost, determinism, noise after the map) | app:pmala:admm |
| C.3 | Proximal map, joint sampler (stage 1, Mehrotra IPM, initialization and stopping, determinism) | app:pmala:boxsolver, eq:box_qp |
| C.4 | Interweaving step, with the constrained version | app:pmala:asis, eq:asis_density, eq:joint_asis_interval |
| C.5 | Initialization, adaptation and safeguards (old C.5–C.7) | app:pmala:init, app:pmala:adapt, app:pmala:safeguards |
| C.6 | Settings of each experiment (one table) | app:pmala:settings, tab:pmala_settings |
| C.7 | Sampler version for the interior simulations (old C.9 and the interior diagnostics) | app:pmala:interior |
| C.8 | Exactness checks (condensed) | app:pmala:tests |

Removed labels: app:pmala:runlength, app:pmala:changes, tab:pmala_variants, eq:box_newton, eq:joint_asis_density. `app:pmala:settings` has no reference yet; HQ will point simulations.tex line 19 to it.

## Deletions beyond the approved list
- Opening roadmap paragraph (the brief allowed dropping it).
- C.1: the θ conditional, the block order and the joint-sampler sentence. §2.4 and §2.6 already state them.
- C.2: "the acceptance rate did not change when the iteration budget was increased". This is a sensitivity result that justifies a past choice (rule 2).
- C.3: the displayed residuals, the Δπ/Δυ elimination formulas and the Newton right-hand side, condensed to the system matrix. Also the ‖q‖∞ statistics (median 1e7, max 8e9), which belong to the verification.
- C.4: "‖Dθ‖₁/(m/λ) was between 1.0 and 1.1" and "the conjugate draw moves λ by a few percent per sweep". §2.4 already gives the reason, and the source sampler version was unstated.
- C.5: "start at y so that errors do not depend on a starting estimate"; "the z upper bound is essentially never active"; "starting all levels at y gives zero-width boxes"; "for J = 1 the trend starts at y".
- Old C.8: "Each run uses 30000 sweeps" (false for several runs; the table replaces it). Also "the chain approaches the posterior λ more slowly as n grows; the application uses longer chains" (replaced by the E-18 placeholder).
- C.8: the test of the joint (λ, θ) move. It tests a rejected variant that is not part of the method. Also detail trimmed from the verification: the 90/108 stage use, 27 iterations, the perturbation test, map timings, the a-posteriori bound statistics, the nine-problem ADMM detail, and the midpoint-grid rationale.

## Notation changed to avoid clashes with §2
In C.3 the Hessian Q → A₀ (in §2, Q is the null-space basis); q → β; q_min → ϖ; constraint residuals r_k → R_k (r_i are the pseudo-responses); multipliers π_k → μ_k (π_j is the level-j posterior); W_k → Λ_k (W = diag(w)). In C.4 the scale s → φ. In C.7 the running median s → θ^rm.

## \tbc cells
- Table C.6: the Air simulation row (all six setting cells) and the SPod row (all six): "E-18 refit; settings to be added".
- C.7, first paragraph: "E-18: the air-quality refits of Sections 4.3 and 4.4.1 use this version with b0 ∈ {…}; settings to be added."
- Growth and Timings: no \tbc. Per Felipe, every column without a source is "—". Growth shows only b0 = √G and 6000/1000.

## Judgment calls
- Extreme individual and extreme joint: Version = "Sec. 2" (HQ: "the §2 algorithm without interweaving" for the individual runs; the joint row gives no version, so §2's joint sampler is assumed). Engineering may want to confirm the joint row.

## Main-text inconsistencies (not fixed)
1. simulations.tex l.19, "All other results in the paper use the sampler as described in Section 2": false for the extreme individual runs (target 0.55, no interweaving). HQ will repoint it to C.6.
2. methodology.tex l.104, "Appendices~\ref{app:pmala:init}--\ref{app:pmala:safeguards}": now renders "Appendices C.5–C.5" because the three labels share one subsection. Suggest "Appendix~\ref{app:pmala:init}".
3. methodology.tex §2.4 step 5, Alg. 1 and §2.6 state target 0.5 and interweaving every sweep. The extreme individual runs differ; this is now stated in C.6.
4. data_application.tex §4.4.1 states "proximal parameter γ = 0.1", "smoothing parameter ε = 0.01", IG(0.01, 0.01), "adapted during burn-in", and "the smoothed check-loss gradient". §2 has γ = δ/2, no smoothing, and adaptation throughout. Pending E-18.
5. data_application.tex §4.4.2 refers to "the linear-in-n prior of Section 2.4" (§2.4 states no such prior) and "in our experience the P-MALA step does not move…" (development history).
6. air_simulation.tex uses `\clearpage` and `[H]` (layout rule 8).
