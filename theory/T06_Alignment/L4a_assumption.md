# Link L4a: the named assumption on the λ range below n^{3/2}, and its empirical status

*Theory, 2026-11-23. INTERNAL. Responds to HQ's steer, Felipe's rule that "every assumption must be shown to hold on our simulation designs".*

## 1. Statement, in posterior terms

**Assumption (L4a).** For the A-rule, λ ~ Gamma(1, b_n) with b_n = 1/(5500(n/500)^{5/2}), and σ ~ IG(0.1, 0.1) learned, at fixed design, level τ ∈ [0.05, 0.95] and truth class constant V:

  sup_P E_P Π( ℓ₀ ≤ λ ≤ n^{3/2}(log n)^{c} | y ) → 0,

where ℓ₀ is the fixed constant of `FABLE_A_Arule_lowertail.md` §2.

**Its role.** Together with what is already proved, it gives (LT) of Corollary P at Λ₋ = c₋n^{5/2}(log n)^{−1/2}:
- (I) and (III-a/b): proved, class-wide;
- (II), bounded λ: L2, separate;
- [n^{3/2}, n^{2.30}]: L4b;
- [n^{2.30}, Λ₋]: Theorem U-σ, proved and audited, averaged β̄ < 6.

**A finite-n proxy that is checkable.** The content of (L4a) together with U-σ is that the posterior of λ does not drift below the oracle scale λ\* := n^{5/2}/V as n grows. The checkable form is: posterior λ / λ\* stays bounded below, uniformly in n.

(L4a) is an asymptotic statement with fixed V. For the VS truth, λ\* < n^{3/2} whenever n < V ≈ 7276. So **at the paper's n, the VS posterior legitimately sits inside the L4a range**, because the oracle itself is there. A "zero mass below n^{3/2}" check is therefore the wrong test at paper n. The right test is the λ/λ\* trend.

## 2. Data check from existing outputs (no new compute)

**Source.** `engineering/E07_Tuning_Free/hyper/results/screen_cells.csv`, spec `A_H1` (= the A-rule), exact Gibbs.
- Per cell it holds **posterior medians of λ** (median over seeds), not draws. So posterior *mass* below a threshold cannot be computed from saved outputs.
- λ\* = n^{5/2}/V, with V = 156 (S) and 7276 (VS), the memo's values, constant 1.

| Truth | Noise | τ | n = 500 (5 seeds) | n = 1000 (1 seed) | n = 2000 (1 seed) |
|---|---|---|---|---|---|
| S | Normal | 0.5 | λ/λ\* = 0.85 | 0.97 | 1.05 |
| S | Normal | 0.05 | 0.47 | 0.65 | — |
| S | Normal | 0.95 | 0.59 | **0.08** | — |
| S | Beta | 0.05 / 0.5 / 0.95 | 1.55 / 1.10 / 0.31 | — | — |
| S | Mixed | 0.05 / 0.5 / 0.95 | 0.61 / 0.67 / **0.13** | — | — |
| VS | Normal | 0.5 | 3.16 | 3.30 | 2.78 |
| VS | Normal | 0.05 | 1.76 | 1.38 | — |
| VS | Normal | 0.95 | 2.36 | 1.52 | — |
| VS | Beta | 0.05 / 0.5 / 0.95 | 3.26 / 2.93 / 1.58 | — | — |
| VS | Mixed | 0.05 / 0.5 / 0.95 | 3.55 / 5.83 / 2.58 | — | — |

**Reading (MEASURED, medians only):**
- **τ = 0.5, both truths, n = 500 → 2000:** λ/λ\* is stable (S: 0.85 → 0.97 → 1.05; VS: 3.16 → 3.30 → 2.78). The A-rule's λ tracks the oracle scale n^{5/2}/V, with no downward drift. This is the content of (L4a) + U-σ.
- **The absolute threshold.** At paper n, the median sits below n^{3/2} in **every VS cell** (λ/n^{3/2} = 0.11–0.76) and in two S cells: Mixed 0.95 (0.40) and Normal 0.95 at n = 1000 (0.52). For VS this is the expected n < V effect, not evidence against (L4a).
- **Watch item: S at τ = 0.95.** λ/λ\* = 0.31 (Beta), 0.13 (Mixed), and Normal falls from 0.59 to **0.08** between n = 500 and 1000. That last value is a single seed. It is the one pattern in the data that *could* indicate downward drift at an outer level. It needs draws and seeds before anything is concluded.
- **So: zero mass below n^{3/2} on every cell is NOT shown, and cannot be with medians only.** No such claim goes in the memo.

## 3. Check that needs compute (Tuesday; cost to be priced by Engineering)

**Design.**
- Re-run spec `A_H1` with **λ draws saved**, on the cells of the screen grid:
  - S and VS;
  - Normal, Beta and Mixed;
  - τ ∈ {0.05, 0.5, 0.95};
  - n ∈ {500, 1000, 2000, 4000}, 3 seeds.
- **Report per cell:**
  - posterior quantiles (5%, 50%) of λ/λ\*;
  - the posterior mass of {λ < n^{3/2}};
  - the same at {λ < c·λ\*} for c = 0.1.
- **Priority:** the S τ = 0.95 cells, the watch item above.

**Rough size.** The screen's A_H1 arm at n ≤ 2000 plus one n = 4000 tier. Engineering to price. Theory's expectation is a few core-h; nothing runs tonight.

## 4. Referee lens: why this is not "assuming the conclusion"

1. **The conclusion is about θ; the assumption is about λ, on a sub-range.**
   - The theorem's conclusion is the contraction rate of θ.
   - (L4a) is a statement about the hyperparameter posterior, on the range [ℓ₀, n^{3/2}] only.
   - The remaining ranges are **proved**: tiny λ, interpolating fits, extreme scales, and the whole band [n^{2.30}, Λ₋] (Theorem U-σ, audited).
   - So (L4a) covers a strict, explicitly delimited part of one input, (LT), and none of the θ argument.
2. **It is a standard kind of high-level condition.**
   - Contraction results for hierarchical and empirical-Bayes posteriors routinely assume, or separately prove, that the hyperparameter posterior stays away from degenerate values. Our assumption is of that type, and narrower.
   - It is stated in checkable posterior terms, and Section 2 checks its finite-n proxy.
3. **It is falsifiable, and has been tested where it should fail.**
   - Its companion condition, β̄ < 6, predicted that λ collapses where β̄ > 6.
   - Engineering's extreme-τ run confirmed the collapse (λ ≈ 0.005× the prior mean).
   - The κ̂ pilot confirmed the sign pattern.
4. **An unconditional alternative exists.** V0T\* (his method plus the floor) needs no such assumption, is proved and cross-family audited, and meets the individual data gate. The paper can state the A-rule result conditionally next to an unconditional floored result.

**What a referee could still object to.** The assumption is not proved, and below n^{3/2} even the heuristic (the Gaussian proxy) is unjustified (`FABLE_A_gap4.md` §4). The honest framing is: "assumed; supported by the posterior-λ trend in simulations; proved above n^{2.30}".
