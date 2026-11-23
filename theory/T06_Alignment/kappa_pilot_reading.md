# κ̂(ℓ) pilot: Theory's reading (INTERNAL, input to Tuesday's plan; not for Felipe)

*Theory, 2026-11-23. Data: Engineering 75ad1a4, `engineering/E07_Tuning_Free/route_a/kappa_results/kappa_pilot.csv`.*

**Setup.** 160 fixed-λ exact-Gibbs chains with σ learned, on the Gaussian heteroscedastic design, seed 1:
- truths S and VS;
- n ∈ {500, 2000};
- τ ∈ {0.5, 0.25, 0.05, 0.97};
- 10 values of ℓ from 4 to 2/b_n.

MCSE is 0.5–1.6. The quantity is κ̂ = m − ℓ·mean‖Dθ‖₁ = ℓ·∂_ℓ log E(ℓ), which is exact by (I2) of `FABLE_B_Arule_gauss.md`.

**What was predicted** (Fable B §8 and Fable A, UNTESTED before this run):
- κ > 0, with slope −1/3, at τ = 0.5 and 0.25;
- a smaller κ at 0.05;
- κ flat or negative at 0.97.

**What the data show:**

| τ | Sign of κ̂ below the bias region | log-log slope (first six significant points) | Reading |
|---|---|---|---|
| 0.5 | positive in every cell | −0.34 to −0.35 | matches −1/3 |
| 0.25 | positive in every cell | −0.33 to −0.35; κ̂(0.25)/κ̂(0.5) = 0.93–0.98 (predicted 0.93) | matches |
| 0.05 | positive in every cell (S stays > 0 up to ℓ = 2/b_n) | −0.42 to −0.44 | sign as predicted; the ratio to τ = 0.5 is ≈ 0.4–0.5 in mid-range (predicted ≈ ⅓); the slope is steeper |
| 0.97 | **n = 2000: κ̂ ≈ −1.2 ± 1.3 at ℓ = 2.2e3**, then +10, then significantly negative (−10.5, −13.3) on S | −0.50 to −0.51 | **as predicted: the sign is lost.** On S at n = 2000, λ has no growing push beyond about ℓ ≈ 2e3 ≪ n^{5/2} |

**The bias region.** On VS, κ̂ turns negative at the largest ℓ in every τ, beyond about 2e3 at n = 500 and 1e5 at n = 2000. On S it does not, apart from τ = 0.97. This is the bias term of (I3): it caps λ near the truth's oracle, VS being the rougher truth. It is expected, and it is not a failure of the sign.

**Consequences for Tuesday:**
1. **The design condition (LO, β < ~6) is supported by data on this design:** the sign holds at 0.05–0.5 and fails at 0.97. The proxy crossing τ ≈ 0.965 is consistent with this.
2. **τ = 0.05 is positive although the worst-case β = 6.7.** So the *averaged* condition is the right one, which is what Fable A's Theorem LO (min-density) does not yet give.
3. **Caveats:** one seed and one design; a fixed-λ posterior, not the A-rule chain. The identity diagnostic on the A-rule chains was not possible because draws were not saved.
