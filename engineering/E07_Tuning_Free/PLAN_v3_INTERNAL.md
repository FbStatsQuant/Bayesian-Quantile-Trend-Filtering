# E-07 re-plan v3: INTERNAL (Engineering and HQ only)

*2026-11-23, after Felipe's reset.*
- Felipe's sampler is the default: learned σ ~ IG(0.1, 0.1), λ ~ Gamma(1, b₀), P-MALA.
- The task is a **proximal** algorithm that is consistently more accurate: lower paired MSE across the full grid, median ratio clearly below 1, no cell above 1.25, mixing no worse, and a joint version that has been run and wins.
- **Frozen, no further compute:** the non-proximal track (augmented Gibbs, pCN box moves, S1–S6 as planned).

## Where the data say there is room (internal measurements, his sampler, paper settings)
| Observation | Data | Implication |
|---|---|---|
| **S signal: λ under-converged in his runs** | G0 smoke, 6 paired fits. His λ̄ is 1.4–2.7× below a converged 4-chain run; his MSE is 13–60% higher in all 6; ESS(log λ) is 1.4–7 per run. The paper's S runs use ASIS **off**, 20k sweeps | A proximal fix that converges λ on S should lower MSE there |
| **VS: his runs are at their posterior** | G0: VS (ASIS **on**) agrees with the converged run within noise (MSE −16% to +9%, no sign) | **No accuracy to gain on VS by mixing.** Gains on VS can only come from a different posterior (prior), which can go either way |
| **The S prior caps λ** | One seed (Fable): b₀ = 5×10⁻⁴ holds λ about 10× below its data value (b₀λ ≈ 8); a non-capping prior halved MSE at S, τ = 0.95. **UNTESTED in his sampler** | A non-capping λ rate may help S tails, but only if λ converges (E-05: P-MALA collapses at very small b₀) |
| **σ fixed fails his bar** | σ sprint: VS loses (8/18 cells > 1.25) | σ stays learned, as in his default |

**Honest expectation:**
- "Median clearly < 1 across the full grid" is plausible only if S gains are large and VS stays exactly neutral.
- VS has no mixing headroom.
- If the candidates below only tie on VS and win on S, the median may land near 0.9–1.0. That might not meet "clearly < 1". We will report it as measured.

## Proximal candidates (all inside his P-MALA sampler; settings or handling only; ALL UNTESTED)
| # | Candidate | Why the data suggest it | Joint version | Pilot (paired against his L fits already run: sprint seeds 1–5, so **no new baseline compute**) | Core-h |
|---|---|---|---|---|---|
| P1 | **ASIS on for every signal** (his own `asis_lambda` flag; S currently runs it off) | VS has ASIS on and its λ agrees with the converged run; S has it off and is under-converged | His joint code already has constrained ASIS (`asis_box_step`) | S × 3 noises × τ ∈ {0.05, 0.5, 0.95} × 5 seeds = 45 fits at his 20k sweeps | **1.4** |
| P2 | **Proximal warm start:** θ₀ = his ADMM QTF fit at an eBIC λ (his own `admm_qtf`), λ₀ matched to it (λ₀σ₀ = Λ_eBIC), instead of θ₀ = y, λ₀ = m | E-05 mechanism: λ \| θ = y collapses λ at sweep 1, and it then drifts up slowly. A smooth proximal start removes the drift | Per level, with ordered starts (sort the level fits pointwise) | Same 45 fits, plus VS × 3 noises × 3 τ × 5 seeds = 45 (VS must stay neutral) | **3.4** |
| P3 | **His joint (λ, θ) proximal jump** (`lamjump_step`, already in his code, off in the paper) | Targets λ–θ coupling directly; methods note: lost ESS/h at the paper's priors, **never measured on S accuracy** | **Not in his joint code**; it would need porting with a box-constrained prox. Risk: no joint version | Same 45 S fits | **1.6** |
| P4 | **Non-capping λ rate, b₀ = s_y·n^{−5/2}·c, with P1 + P2** (only if P1/P2 make λ converge) | S prior cap (one seed). Tests whether a theory-scaled, scale-free rate beats the per-signal b₀ | Per level (the joint code needs per-level b₀, a small vectorisation) | 18 sprint cells × 5 seeds = 90 fits | **3.4** |

## Stages and gates
| Stage | Content | Core-h | Gate |
|---|---|---|---|
| R1 | P1, P2, P3 pilots (paired against the existing L; MSE, coverage, ESS(log λ), R̂ over 2 chains on 1 seed per cell) | **6.4** | Keep a candidate only if S median ratio ≤ 0.90, no S cell > 1.10, and VS cells all ≤ 1.05 |
| R2 | P4 on the best of R1 | 3.4 | Same bar on all 18 cells |
| R3 | Full grid for the survivor: VS, S (+ PC) × 3 noises × τ ∈ {0.05, 0.25, 0.5, 0.75, 0.95, 0.99} × 10 seeds, his sampler against the survivor, with fit plots | ≈ 2 × 36 × 10 × 130 s ≈ **26** (13 if his baseline arm reuses the sprint seeds where they overlap) | Felipe's bar: median clearly < 1, no cell > 1.25, ESS/s no worse |
| R4 | Joint: his joint sampler against the survivor in his joint code, VS × 3 noises × levels 0.90–0.99 × 3 seeds | ≈ 6–10 (his joint cost to be measured on 1 fit first) | Paired MSE per level ≤ his; non-crossing by construction |

- **Hours:**
  - Spent on E-07: G0 1.3, σ sprint 8.0, λ-prior arms (2867404) ≈ 6, so ≈ 15.3.
  - **Left under the 70 cap: ≈ 54.7.**
  - R1–R4 ≈ 40–46.
- **If R1 finds nothing that beats him on S without hurting VS, E-07 stops there.** Reported internally only.
