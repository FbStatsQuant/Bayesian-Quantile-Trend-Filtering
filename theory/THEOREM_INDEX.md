# Theorem index: the reference for the statement-fidelity check

*Theory Department, 2026-11-23. Each row gives the authoritative file, its audit, and the hypotheses and rate as audited. INTERNAL.*

**Status vocabulary.**
- **AUDITED:** proved and cross-family audited, with the fixes applied or applied by reference.
- **PROVED-UNAUDITED:** proved in one pass, with no cross-family audit yet.
- **SKETCH** and **OPEN** have their usual meaning.

Throughout: noise (A1); (A2) is the local margin with constants (L, f, f̄); (A3) is TV⁽³⁾(θ\*) ≤ V. "Learned σ" means σ ~ IG(a, b) with the penalty free of σ.

## Results in the current paper (updated 2026-11-25)

These are the statements the paper now carries. Under the owner's policy of 2026-11-25, this section is kept in step with every Lean correction packet that changes a statement. Notation is the paper's: r = k+1, Δ²_n, λ_TV = λ/n^k.

### Theorem 1 (`thm:main`): one level, fixed λ and σ
- **Files:** `T07_Bayes_Thm3/T07c_proof.tex`, which is the paper's `appendix_theory.tex` proof. **Audit:** `T07_Bayes_Thm3/AUDIT.md`.
- **Hypotheses:**
  - A and B with constants (L, f̲, f̄), and V* ≤ V̄;
  - k ≥ 1;
  - σ = 1, or any fixed σ₀;
  - λ = c n^{(2k+1)/2}, that is, λ_TV = c n^{1/2}.
- **Conclusion:** E Π(Δ²_n > M n^{−(2k+1)/(2k+2)} | y) ≤ C n^{−1/(2k+2)} for n ≥ n₀.
  - Constants depend only on (c, k, L, f̲, f̄, V̄), plus σ₀.
  - The bound is uniform over the class.
  - It is an upper bound only.
- **Status:** AUDITED. **Formally verified in Lean** (merge 4498143, 2026-11-26): `main_theorem` and `main_theorem_scale` use only the standard axioms. The paper proof was corrected per Lean packets C-01 to C-10; every one was confirmed by Theory, and none changed a statement or a constant.

### Theorem 2 (`thm:joint`): J fixed levels, non-crossing posterior, simultaneous
- **Files:** `T09_Joint_Theorem/STATEMENT.tex`, `PROOF.tex` and `AUDIT.md`. The paper text is Writing's W-05 (5d5eb81), signed off by Theory.
- **Hypotheses:**
  - those of Theorem 1 at every level, with common (L, f̲, f̄) and V̄;
  - λ_j = c_j n^{(2k+1)/2};
  - σ_j = 1, or any fixed σ_{0j};
  - fixed, distinct levels.
- **Conclusion:** E Π_C(max_j Δ²_n(θ_j − θ*_j) > M n^{−(2k+1)/(2k+2)} | y) ≤ C n^{−1/(2k+2)}.
  - Constants depend on (c_1, …, c_J, k, L, f̲, f̄, V̄, J) and the minimum level spacing; the spacing enters n₀ only.
  - No new assumption: B separates the true curves by min{L, spacing/f̄}.
- **Status:** AUDITED (fresh Fable and Astra, three rounds, clean). **Formally verified in Lean** (main d0366d5, 2026-11-26): `joint_theorem` and `joint_theorem_scale` use only the standard axioms. The only paper packet was C-11, measurability of y ↦ Π_C(B|y), in 3cae0ec. No statement or constant changed. The T09 source constant was aligned to 2Σ_l C^{(l)} in f7b8e38.

### Appendix constant g_r > 0 (T-10; Lean correction C-01)
- **Files:** `T10_gr_positivity/NOTE.md`. In the paper since Writing's 906be2b.
- **Statement:** g_r = inf_{w≥r} λ_min(G_w) ∈ (0, 1], depending only on r. It is used in Lemmas `pf:lem:smooth` and `pf:lem:interp`.
- **Status:** PROVED. The Theory head checked it; the Lean target is `BQTF.gr_pos`.

## Earlier program (2026-11-23; NOT in the current paper)

The entries below record the learned-σ and learned-λ program and older drafts. They are kept for reference. The paper does not state them: the owner's scope rules of 11-24 and 11-25 limit the paper to fixed λ and σ, upper bounds only.

### C1: localization at any fixed σ
- **File:** `T06_Alignment/C1_any_sigma.md`. **Audit:** Astra (findings applied).
- **Hypotheses:** (A1), full (A2), (A3); λ deterministic with n^{23/11}(log n)^{12/11} ≪ λ; Vλ = o(n³).
- **Rate:** r² ≍ n^{1/7}λ^{−2/7}(log n)^{6/7}, plus a sup-norm bound via L10-I.
- **Status:** AUDITED.

### Lemma F, W′, C2: realized-numerator shells
- **File:** `FABLE_lemmaF_C2.md`. **Audit:** Opus and Astra.
- **Hypotheses:** fixed σ or σ uniform on a compact interval, **including σ < σ̄**; moment-free.
- **Rate:** n^{−5/6}(log n)^{1/6} at the oracle λ ≍ n^{5/2}/V.
- **Status:** AUDITED.

### Lemma S: scale containment and consistency
- **File:** `astra_sigma_concentration.md`. **Audit:** Opus and Fable.
- **Hypotheses:** row-average uniform integrability; σ₀,ₙ ≥ d; λ/log n → ∞; (A3) or a bounded truth.
- **Conclusion:** σ ∈ [l, H₀] with posterior mass → 1, and σ/σ₀,ₙ → 1.
- **Status:** AUDITED.

### Theorem C: learned σ, deterministic λ
- **File:** `THEOREM_C.md`. **Audit:** its inputs are audited; the assembly had a final Fable read.
- **Hypotheses:** n^{23/11}(log n)^{12/11} ≪ λ ≪ n^{108/41}V^{−42/41}.
- **Rate:** n^{−4/7}(log n)^{6/7} at the oracle.
- **Status:** AUDITED (by its inputs).

### Theorem C\*: learned σ at the oracle λ
- **File:** `THEOREM_C_STAR.md`. **Audit:** Opus and Astra.
- **Hypotheses:** those of C, with λ ≍ n^{5/2}/V; no (EM), no σ ≥ σ̄.
- **Rate:** n^{−5/6}(log n)^{1/6}; σ/σ₀,ₙ → 1.
- **Status:** AUDITED.

### V2T / V0T: λ learned above a floor κ₋n^{5/2}
- **File:** `FABLE_V2T_proof.md`. **Audit:** Astra.
- **Prior:** constant or scaled b₀, with the floor.
- **Rate:** n^{−4/7}(log n)^{6/7}.
- **Status:** AUDITED.

### V0T\*: his method plus the floor
- **File:** `FABLE_A_n56.md` §3. **Audit:** Astra.
- **Rate:** n^{−5/6}(log n)^{1/6}.
- **Data gate (MEASURED):** individual test met; joint τ = 0.99 unresolved.
- **Status:** AUDITED.

### V0T\* with an n-dependent floor (link L7)
- **File:** `FABLE_A_V0Tstar_nfloor.md`. **Audit:** Astra.
- **Hypotheses:** (log n)^{−A} ≤ κ₋,ₙ ≤ κ̄.
- **Rate:** n^{−5/6}(log n)^{1/3} at κ₋,ₙ = c₋(log n)^{−1/2}.
- **Status:** AUDITED.

### Theorem LB: lower bound
- **File:** `FABLE_B_lowerbound.md`. **Audit:** Astra; fixes in efc0a09.
- **Hypotheses:** (A1) and the **upper half of (A2) only**; any fixed σ, compact σ-intervals, or learned σ (with Lemma S's hypotheses); deterministic λ with (32Σ)³ ≤ λ ≤ (n/42)³ and β-admissible, which covers every λ → ∞ with λ ≤ a₂n^{5/2}/V; also V0T's learned λ.
- **Conclusion:** E₀Π(Δ²ₙ ≤ c₀λ^{−1/3} | y) → 0; **log-free for V0T**.
- **Status:** AUDITED.
- **Two-sided (exact rate) claim:** needs the upper hypotheses of C\* / V0T\* as well. The loss is Δ²ₙ or ‖·‖²ₙ.

### Theorem J: joint non-crossing, fixed number of levels
- **File:** `FABLE_B_joint.md`. **Audit:** Astra.
- **Conclusion:** V0T\* and C\* transfer to the joint posterior at n^{−5/6}.
- **Status:** AUDITED.

### General k
- **File:** `FABLE_B_general_k.md`. **Audit:** Astra.
- **Rate:** n^{−(2k+1)/(2k+2)} at λ = n^{k+1/2}/V, for k ≥ 1.
- **Status:** AUDITED.

### Theorem H and Corollary P
- **File:** `FABLE_A_theoremH.md`. **Audit:** Astra; fixes applied.
- **Theorem H:** Huber-body localization above any floor Λ₋ ≤ n².
- **Corollary P:** the plug-in identity, given (LT) and (WM).
- **Status:** AUDITED.

### Theorem LO: local Occam bound at fixed (ω, ℓ)
- **File:** `FABLE_A_three_lemmas.md`. **Audit:** Astra.
- **Hypotheses:** β < 6 (min-density); ℓ ≥ C·n^{99/43}polylog.
- **Status:** AUDITED.

### Theorems U and U-σ: uniformity; the middle band
- **File:** `FABLE_A_uniformity.md`. **Audit:** Astra.
- **Conclusion:** the A-rule posterior, with σ learned, puts vanishing mass on λ ∈ [C·n^{99/43}polylog, c₋n^{5/2}(log n)^{−1/2}].
- **Status:** AUDITED.

### LO and U with the averaged β̄ < 6
- **File:** `FABLE_B_averaged_beta.md` §7–8. **Audit:** Astra.
- **Condition:** β̄ = ωtΣf^{−5/6}/Σf^{1/6} < 6, with a smooth profile (REG) and a class-uniform margin.
- **Coverage:** all paper designs at τ ∈ [0.05, 0.95].
- **Status:** AUDITED.

### Lemma RSB and Prop. LT-EM: λ lower tail in the (EM) range only
- **File:** `FABLE_A_Arule_lowertail.md`.
- **Status:** PROVED-UNAUDITED.

### Exact identities: virial, scaling, mean, sign reduction
- **File:** `FABLE_B_Arule_gauss.md`.
- **Status:** PROVED-UNAUDITED; verified by Theory.

## Negative results

- **No-floor obstruction.** File `astra_noFloor.md`, cross-checked by Fable. There is no class-wide theorem without a floor. Status: AUDITED.
- **Soft-floor impossibility within Gamma.** Files `astra_softfloor.md` and `FABLE_B_softfloor.md`. Two independent notes that agree with each other; neither has been audited.

## Open, for the floor-free A-rule

- **L2:** bounded λ. See `FABLE_B_DC.md`.
- **L4a:** [ℓ₀, n^{3/2}]. Stated as a named assumption: `L4a_assumption.md`.
- **L4b:** [n^{3/2}, n^{2.30}]. See `FABLE_A_gap4.md`; a CT Fable is on it.
- **Not to be written anywhere:**
  - "floor-free theorem";
  - an A-rule rate without (LT);
  - any claim at τ = 0.01/0.99.

## Common fidelity traps

1. **"Any σ."** C1, C2 and LB hold at any fixed σ. **Theorem B needs (EM)**, roughly σ ≥ σ̄.
2. **LB's hypotheses** are (A1) plus the *upper* half of (A2) only. **The upper bounds need full (A2).**
3. **The two V0T\* rates.** Fixed floor: (log n)^{1/6}. n-dependent floor: (log n)^{1/3}.
4. **The β-threshold 6** is a *sufficient* comparison. Do not claim failure beyond it as a theorem; it is data only.
5. **Data are INTERNAL.** V0T individual MSE 0.47 is MEASURED; the joint τ = 0.99 result is unresolved.
