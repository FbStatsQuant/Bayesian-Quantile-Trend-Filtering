# E-18 warm-up solver observations

The published warm-up runs for 200 sweeps with λ held fixed. Each
sweep attempts ADMM at relative tolerance `1e-6` and uses IPM when
ADMM misses that tolerance.

For τ = .05, seed 1, at warm sweeps 1, 50 and 200, the ADMM
shrinkage threshold λ/ρ was 9.3–11.9. The split variable stayed at
zero throughout the 300 iterations, and the relative primal residual
remained near 1. IPM stalled after 26, 24 and 24 iterations, with
the dual residual and gap above target. The condition numbers of the
diagonal weights a were 822, 3,460 and 1,426. There were no finite
box bounds.

All 1,200 E-18 fits and all three E-14 Owls replays recorded 200
IPM fallbacks and 200 nonconvergences. The warm-up did not certify
the conditional mode. The sampling phase inherited the approximate
warm iterates from the data-based initialization. The warm-up is
part of the published algorithm and the sampler has not been patched.
