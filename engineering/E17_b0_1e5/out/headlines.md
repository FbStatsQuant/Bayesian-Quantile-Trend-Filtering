# E-17 results for HQ

## MSE versus both baselines

The comparisons use the printed published mean and unrounded rerun means. A dash means no noise family meets the strict comparison.

| Design | Signal | τ | Lower than both | Higher than both |
| --- | --- | ---: | --- | --- |
| interior | VS | 0.05 | Gaussian, Beta | — |
| interior | VS | 0.25 | Beta | Gaussian, mixed normal |
| interior | VS | 0.50 | Beta | Gaussian, mixed normal |
| interior | VS | 0.75 | Beta | Gaussian, mixed normal |
| interior | VS | 0.95 | Gaussian, Beta, mixed normal | — |
| interior | S | 0.05 | Gaussian, Beta, mixed normal | — |
| interior | S | 0.25 | Gaussian, Beta, mixed normal | — |
| interior | S | 0.50 | Gaussian, Beta, mixed normal | — |
| interior | S | 0.75 | Gaussian, Beta, mixed normal | — |
| interior | S | 0.95 | Gaussian, Beta, mixed normal | — |
| extreme | VS | 0.90 | Gaussian, Beta | — |
| extreme | VS | 0.93 | Gaussian, Beta, mixed normal | — |
| extreme | VS | 0.96 | Gaussian, Beta, mixed normal | — |
| extreme | VS | 0.97 | Gaussian, Beta, mixed normal | — |
| extreme | VS | 0.98 | Gaussian, Beta, mixed normal | — |
| extreme | VS | **0.99** | — | — |
| extreme | S | 0.90 | Gaussian, Beta, mixed normal | — |
| extreme | S | 0.93 | Gaussian, Beta, mixed normal | — |
| extreme | S | 0.96 | Gaussian, Beta, mixed normal | — |
| extreme | S | 0.97 | Gaussian, Beta, mixed normal | — |
| extreme | S | 0.98 | Gaussian, Beta, mixed normal | — |
| extreme | S | **0.99** | — | — |

## Extreme λ ESS

| Signal | τ | Median at 1e-3 | Median at 1e-5 | Change |
| --- | --- | ---: | ---: | ---: |
| VS | All | 66.36 | 62.45 | -5.9% |
| VS | **0.99** | 37.99 | 37.76 | -0.6% |
| S | All | 71.39 | 59.22 | -17.1% |
| S | **0.99** | 36.34 | 32.22 | -11.3% |

## Crossing totals

Counts sum pointwise inversions over 300 noise/seed groups per signal, counting each level pair once. The interior uses all five reported levels. The extreme uses 0.96–0.99.

| Design | Signal | Neighbor at 1e-3 | Neighbor at 1e-5 | All pairs at 1e-3 | All pairs at 1e-5 |
| --- | --- | ---: | ---: | ---: | ---: |
| interior | VS | 159 | 281 | 161 | 285 |
| interior | S | 102 | 525 | 103 | 535 |
| extreme | VS | 107872 | 104908 | 175762 | 172187 |
| extreme | S | 109178 | 127480 | 200846 | 251162 |

## Health flags

- interior `S_Mixed_t05_s090`, post-burn-in acceptance 0.38845, λ ESS 10.46.
- extreme `S_Beta_t96_s026`, post-burn-in acceptance 0.39705, λ ESS 14.67.
- extreme `S_Mixed_t96_s016`, post-burn-in acceptance 0.39800, λ ESS 6.21.
