# Extreme upper quantiles — individual sampler MSE

Published fits used the old sampler at 10k sweeps / 3k burn-in with b0 = 0.01 for VS and 0.001 for S. The rerun uses the updated sampler at 30k / 10k with b0 = 0.001 for both signals. On VS, the MSE ratio combines changes to b0, the sampler, and chain length. On S, the sampler and chain length change at the same b0.

## VS

| Noise | τ | Published individual MSE | New individual MSE | New / old |
| --- | ---: | ---: | ---: | ---: |
| Gaussian | 0.90 | 0.013400 | 0.011562 | 0.862847 |
| Gaussian | 0.93 | 0.016700 | 0.014501 | 0.868301 |
| Gaussian | 0.96 | 0.027100 | 0.023223 | 0.856951 |
| Gaussian | 0.97 | 0.032800 | 0.029972 | 0.913781 |
| Gaussian | 0.98 | 0.041000 | 0.038788 | 0.946052 |
| Gaussian | 0.99 | 0.050200 | 0.060606 | 1.207287 |
| Beta | 0.90 | 0.005500 | 0.004924 | 0.895320 |
| Beta | 0.93 | 0.006800 | 0.006074 | 0.893221 |
| Beta | 0.96 | 0.010600 | 0.010015 | 0.944821 |
| Beta | 0.97 | 0.012400 | 0.012080 | 0.974175 |
| Beta | 0.98 | 0.015400 | 0.015444 | 1.002829 |
| Beta | 0.99 | 0.013200 | 0.023045 | 1.745804 |
| Mixed normal | 0.90 | 0.054100 | 0.042634 | 0.788068 |
| Mixed normal | 0.93 | 0.071600 | 0.053540 | 0.747768 |
| Mixed normal | 0.96 | 0.120300 | 0.089763 | 0.746161 |
| Mixed normal | 0.97 | 0.146800 | 0.123775 | 0.843157 |
| Mixed normal | 0.98 | 0.184000 | 0.165665 | 0.900351 |
| Mixed normal | 0.99 | 0.245800 | 0.259570 | 1.056023 |

Failed attempts: 0 · Rerun fits: 0 · Median λ ESS: 66.358699

## S

| Noise | τ | Published individual MSE | New individual MSE | New / old |
| --- | ---: | ---: | ---: | ---: |
| Gaussian | 0.90 | 0.011000 | 0.007556 | 0.686903 |
| Gaussian | 0.93 | 0.014300 | 0.009604 | 0.671574 |
| Gaussian | 0.96 | 0.023800 | 0.016574 | 0.696382 |
| Gaussian | 0.97 | 0.029300 | 0.024994 | 0.853030 |
| Gaussian | 0.98 | 0.037800 | 0.034758 | 0.919522 |
| Gaussian | 0.99 | 0.046000 | 0.055362 | 1.203532 |
| Beta | 0.90 | 0.004200 | 0.003207 | 0.763476 |
| Beta | 0.93 | 0.005400 | 0.004049 | 0.749781 |
| Beta | 0.96 | 0.008800 | 0.007347 | 0.834875 |
| Beta | 0.97 | 0.010700 | 0.010265 | 0.959315 |
| Beta | 0.98 | 0.013400 | 0.013474 | 1.005517 |
| Beta | 0.99 | 0.012100 | 0.020002 | 1.653048 |
| Mixed normal | 0.90 | 0.048500 | 0.028229 | 0.582039 |
| Mixed normal | 0.93 | 0.062900 | 0.035742 | 0.568231 |
| Mixed normal | 0.96 | 0.111900 | 0.069845 | 0.624169 |
| Mixed normal | 0.97 | 0.142000 | 0.105747 | 0.744700 |
| Mixed normal | 0.98 | 0.176500 | 0.157109 | 0.890137 |
| Mixed normal | 0.99 | 0.232400 | 0.244591 | 1.052459 |

Failed attempts: 0 · Rerun fits: 0 · Median λ ESS: 71.392995
