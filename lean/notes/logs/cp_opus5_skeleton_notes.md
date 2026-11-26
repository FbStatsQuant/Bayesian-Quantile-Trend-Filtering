# CP-Opus5: Theorem 2 skeleton notes (2026-11-25)

Branch `t3/theorem-two-skeleton`, worktree `/home/fb31/.t3/worktrees/Bayesian-Quantile-Trend-Filtering/t3-66a030ad-eb3cfa2704fd6a94`.
The branch contains statements and stubs only. Every new proof is `sorry` except two pieces of definitional glue, `jointFarSet_eq_iUnion` and `gapConst_pos`. `#print axioms` shows only `propext`, `Classical.choice` and `Quot.sound` for both.
Build: `owls_run -j 3 -- lake build` passes. The only warnings are `declaration uses 'sorry'`.

Existing Theorem 1 definitions and statements are unchanged. The edits are add-only:
- `Spec.lean`: new declarations at the end, and new bullets in the module docstring.
- `BQTF.lean`: 7 new import lines.
- `docs/statements.md`: a new §3 and new rows D6–D9.
  - The old §3 "Differences" is now §4, because the brief asked for the new section to be §3.
  - D5 gained one appended sentence.
  - One "skeleton branch" sentence was added under "Current scope".

## 1. New statements

| Lean name | File | Paper label |
|---|---|---|
| `LevelGrid` (structure) | Spec | `thm:joint` hypotheses on τ_1<⋯<τ_J; D6 |
| `jointFarSet` (def) | Spec | `thm:joint` display, the event `max_j Δ² > M rate`; U in proof "Transfer"; D9 |
| `JointConclusion` (def) | Spec | eq. `joint-fixed` + `thm:joint` display; D8 |
| `JointStatement` (def) | Spec | `thm:joint`, σ_j = 1 |
| `JointStatementScale` (def) | Spec | `thm:joint`, last sentence |
| `prodPosterior` (def) | Joint/Product | §`pf:sec:joint` opening, Π^⊗ |
| `measurableSet_orderSet` | Joint/Product | (support) 𝒞 measurable |
| `measurableSet_jointFarSet` | Joint/Product | (support) U measurable |
| `jointFarSet_eq_iUnion` (proved, glue) | Joint/Product | U = ⋃_j {θ_j ∈ A_j}, proof "Transfer" |
| `prodPosterior_isProbability` | Joint/Product | §`pf:sec:joint` opening ("a probability measure on (ℝⁿ)^J") |
| `prodPosterior_level` | Joint/Product | proof of `pf:lem:cond`, Π^⊗(θ_j ∈ A) = Π_j(A) |
| `jointPosterior_eq_cond` | Joint/Product | §`pf:sec:joint` opening display; D5 |
| `measurable_jointPosterior_apply` | Joint/Product | D8; Theory §5.5 item 3 |
| `prodPosterior_orderSet_pos` | Joint/Conditioning | Lemma `pf:lem:cond`, Π^⊗(𝒞) > 0 |
| `jointPosterior_isProbability` | Joint/Conditioning | Lemma `pf:lem:cond`, Π_𝒞 probability |
| `jointPosterior_level_le` | Joint/Conditioning | Lemma `pf:lem:cond`, displayed inequality |
| `gapConst` (def) | Joint/Gap | g₀ of Lemma `pf:lem:gap` (with gmin) |
| `gapConst_pos` (proved, glue) | Joint/Gap | (support) |
| `fl_le_fu_of_dataHyp` | Joint/Gap | PLAN §5.5 note (a) |
| `quantile_gap` | Joint/Gap | Lemma `pf:lem:gap`, one coordinate |
| `level_gap` | Joint/Gap | Lemma `pf:lem:gap` |
| `supRad` (def) | Joint/SupNorm | s_n of Lemma `pf:lem:sup` |
| `etaSeq` (def) | Joint/SupNorm | η_n of Lemma `pf:lem:sup` |
| `supRad_tendsto` | Joint/SupNorm | Lemma `pf:lem:sup`, s_n → 0 |
| `etaSeq_tendsto` | Joint/SupNorm | Lemma `pf:lem:sup`, η_n → 0 |
| `eventually_supRad_le` | Joint/SupNorm | eventual form (§5.5 item 5) |
| `eventually_etaSeq_le` | Joint/SupNorm | eventual form |
| `supNorm_concentration` | Joint/SupNorm | Lemma `pf:lem:sup` (posterior bound + P(Ωᶜ)) |
| `supNorm_concentration_scale` | Joint/SupNormScale | proof of `thm:joint`, "General scales" |
| `mem_orderSet_of_near` | Joint/Transfer | proof of `thm:joint`, "The constraint" (first display) |
| `prodPosterior_compl_orderSet_le` | Joint/Transfer | "The constraint" (second display) |
| `jointPosterior_jointFarSet_le` | Joint/Transfer | "Transfer" (first display) |
| `eventually_levels` | Joint/Transfer | choice of n₀ (max_l σ_{0l}s′ ≤ g₀/2, Σ_l η′ ≤ 1/2) |
| `joint_assembly` | Joint/Transfer | "Transfer" (last display) + "General scales" constants |
| `joint_theorem` | Joint/Main | `thm:joint` |
| `joint_theorem_scale` | Joint/Main | `thm:joint`, last sentence |

The import order follows J0 → {J1→J2, J3, J4→J5} → J6 → J7:
- Product imports Coord and Scale.Posterior.
- Conditioning imports Product.
- Gap imports CheckLoss.
- SupNorm imports Localization, which brings in Denominator and Interp.
- SupNormScale imports SupNorm and Scale.Data.
- Transfer imports Conditioning, Gap and SupNormScale.
- Main imports Transfer, Main and Reduction.

## 2. Encoding choices

1. **Indexing.** Levels are `Fin J`, 0-based. A joint trend is `Θ : Fin J → Fin n → ℝ`, level-major, so `Θ j i = θ_{ij}`. This matches the existing `orderSet`, `jointWeight` and `jointPosterior`. The data `y`, the law `Measure.pi μ` and the per-coordinate laws μ_i are shared by all levels. Each level has its own `θs j`.
2. **𝒞 and the order.** I reused the existing `orderSet J n = {Θ | ∀ i, Monotone (j ↦ Θ j i)}`. It uses weak inequalities, as in eq. `joint_order`.
3. **The level grid (D6).** `LevelGrid J τ gmin` has three fields:
   - `mem`: τ_j ∈ (0,1);
   - `strictMono`: redundant given `spacing` and gmin > 0, kept for readability;
   - `spacing`: `τ ⟨j⟩ + gmin ≤ τ ⟨j+1⟩` for every consecutive pair, written with ℕ-index `j` and `h : j+1 < J`.

   I used the consecutive form, not the pairwise one, to match the paper's `min_{j<J}(τ_{j+1} − τ_j)`. The two are equivalent when gmin > 0.
4. **Quantifier order.** As PLAN §5.2 and §5.5 item 4:
   - `JointStatement`: ∀ k ≥ 1, ∀ J, ∀ c (all > 0), ∀ L f̲ f̄ V̄ (L, f̲ > 0), ∀ gmin > 0, ∃ M C n₀ with `0 < M ∧ 0 < C ∧ 0 < n₀`, then ∀ n ≥ n₀, ∀ τ with `LevelGrid`, ∀ μ θ*, DataHyp at every level, ⇒ `JointConclusion`.
   - `JointStatementScale`: σ₀ is quantified with c, before ∃.

   `0 < n₀` is added, as the brief and PLAN say (`∃ M C n₀ > 0`). `MainStatement` does not have it. It costs nothing, since n₀ can always be enlarged.
5. **σ = 1 and λ.** σ is `fun _ => 1` and λ is `fun j => lamSeq (c j) k n`. These are plugged into the existing `jointPosterior`.
6. **U_M (D9).** U_M is `jointFarSet k θs M = {Θ | ∃ j, M * rate k n < lossΔ (Θ j - θs j)}`. It is equivalent to the paper's max form for J ≥ 1, and empty for J = 0. `jointFarSet_eq_iUnion` (proved) rewrites it as `⋃ j, {Θ | Θ j ∈ farSet k (θs j) M}`.
7. **ENNReal vs Real.** As in Theorem 1:
   - posterior masses are `ℝ≥0∞`, and no `toReal` is taken;
   - the bounds are `ENNReal.ofReal (real expression)`;
   - the ratio in `jointPosterior_eq_cond` and `jointPosterior_level_le` is ENNReal division. When Π^⊗(𝒞) = 0 both sides are 0, so the equality holds unconditionally. Lemma `cond` then rules that case out.

   Where a sum of `ofReal`s appears, I added nonnegativity hypotheses (`hCl`, `hp`, `hη0` in `joint_assembly`) so that Σ ofReal = ofReal Σ. For `hη0`, nonnegativity permits the real sum bound to be transferred to the sum of the positive parts. The example η = (1, −1) has Σ η ≤ 1/2 but Σ ofReal η = 1, so it disproves only that arithmetic step, not the assembly theorem. *(Corrected after the Astra audit, F1: the earlier claim here, that the statement is false without `hη0`, was wrong. Astra shows that a negative η_l forces Ω_l = ∅, hence 1 ≤ p_l·massRate, so the assertion holds even without `hη0`. `hη0` is kept for the short proof.)*
8. **Measurability (D8).**
   - The conclusion includes `Measurable (fun y => jointPosterior … y (jointFarSet …))`.
   - `measurable_jointPosterior_apply` has no level hypotheses, because the definition is a ratio of two Tonelli-measurable ℝ≥0∞ functions. That makes it stronger than Theory's "positive for n > r" wording.
   - The good events Ω in J4, J5 and J6 are existential and **not** asserted measurable. The paper never uses measurability of Ω_E ∩ Ω_G, and the assembly can use `toMeasurable` of Ωᶜ, as `Main` does.
   - If the Astra audit prefers explicit `Ω = OmegaE ∩ OmegaG`, that would strengthen J4. It would also bring a `CE` existential and would need Ω_G measurability only if it is asserted.
9. **Sup norm.** `‖θ − θ*‖_∞ > s` is written coordinatewise, as `∃ i, s < |θ i − θs i|`, in the style of `interp` and `localization`. It is equivalent to the Mathlib sup norm for n ≥ 1, and all uses have n ≥ n₂ > k + 1.
10. **s_n and η_n.**
    - `supRad CI k c n = CI * (√(rhoSq r n) + (√(rhoSq r n)^(2k) * Tn r n (lamSeq c k n))^(1/(2k+1)))` with r = k + 1. Here 2r − 2 = 2k is a ℕ power, and 2r − 1 = 2k + 1 is in the real exponent.
    - The paper writes `(ρ^{2r−2}T)^{1/(2r−1)}`. `interp` writes `ρ^{(2r−2)/(2r−1)} T^{1/(2r−1)}`. The two agree for T ≥ 0, which provers will need (`Real.mul_rpow`).
    - `etaSeq` is the exact bound of `localization`(b).
    - `n` is the last argument, so the sequences are `fun n => …`.
11. **C_I placement.** In `supNorm_concentration` and `supNorm_concentration_scale`, `∃ CI > 0` comes right after k, before c, L and the others. This makes s_n depend only on (c, r) (or (σ₀c, r)), as the lemma says. `supRad_tendsto` holds for every CI.
12. **Eventual conditions (§5.5 item 5).** `eventually_supRad_le`, `eventually_etaSeq_le` and `eventually_levels` are stated with `∀ᶠ n in atTop`. No single-n check or monotonicity in n is assumed.
13. **Gap (§5.5 note a).**
    - `0 < fu` is not a hypothesis anywhere. `fl_le_fu_of_dataHyp` (n ≥ 1, L > 0) supplies it.
    - `quantile_gap` (one coordinate) has no sign condition on fu at all. I checked that it is true for fu ≤ 0: B then makes F flat near q₁, so either q₂ − q₁ > L, or the case fu = 0 gives min = 0 < q₂ − q₁.
    - `level_gap` uses `gapConst L gmin fu = min L (gmin/fu)`, which needs fu > 0 internally. That holds because `i : Fin n` gives n ≥ 1.
14. **Conditions on n.**
    - The Lemma `cond` statements use `1 ≤ n`, not the paper's n > r. This is weaker, so the statements are more general. They are true because properness holds for n ≥ 1 (D4, `posterior_isProbability`) and every postWeight is positive.
    - J4 and J5 give `k + 1 < n₂`.
15. **Scale step (J5).**
    - The radius is `σ₀ * supRad CI k (σ₀ * c) n`.
    - The mass is `etaSeq k (σ₀ * fl) n`.
    - The probability bound is `(5/4 + 64/(σ₀ fl)^2) * massRate k n`.

    These follow Theory §5.5 item 2. The posterior is `posterior τ σ₀ (lamSeq c k n)`, in original units.
16. **`joint_assembly` interface.**
    - It takes `MainConclusion` at a **common** M for each level. J7 has to derive this from `main_theorem_scale`'s per-level M^{(l)} ≤ M, using `farSet` monotonicity in M plus `measurable_posterior_apply`.
    - It also takes per-level (s_l, η_l, Ω_l, p_l), and returns C = 2 Σ C_j + Σ p_l.
    - The σ = 1 case is σ = `fun _ => 1`.
17. **`joint_theorem`** is also the specialization σ₀ = 1 of `joint_theorem_scale`. Both are `sorry`, as instructed.

## 3. Points in the paper that look wrong or ambiguous (not fixed)

1. **J ≥ 2 is not stated.** `thm:joint` never says J ≥ 2. For J = 1, `min_{j<J}(τ_{j+1} − τ_j)` is an empty minimum, which is undefined, or +∞ by convention (g₀ = L). The Lean statement covers all J (D7), so nothing depends on this. *(Astra audit disposition: the subsection sets J ≥ 2 before the theorem, theory.tex:87, so this is exposition only.)*
2. **Lemma `pf:lem:gap` assumes `0 < f̄ < ∞` explicitly.** The theorem inherits f̄ only through Assumption B, which does not assert f̄ > 0. It is implied by A + B with L > 0 and n ≥ 1, but the paper does not say so. Lean derives it (`fl_le_fu_of_dataHyp`).
3. **Lemma `pf:lem:cond` assumes n > r, but n ≥ 1 suffices.** Properness holds for every n ≥ 1, as Theory's D4 discussion and `posterior_isProbability` show. The n > r comes from citing Lemma `pf:lem:coord`(b). This is harmless, since the theorem has n ≥ n₀ > r. The text after eq. `joint-fixed` ("For n > k+1 the denominator is positive") is correct but not sharp.
4. **Measurability is not stated.** E_{θ*} Π_𝒞(U | y) is used without stating that y ↦ Π_𝒞(U | y) is measurable. This is the same gap as C-02, and Theory proposes folding it into the C-02 text (D8).
5. **"Assumptions A and B at each of the levels" leaves θ*_j implicit.** The theorem does not say that θ*_j means the τ_j-quantile curve and appears in A/B at level j. It also says "V*_j ≤ V̄ for all j and n" without defining V*_j = TV(θ*_j) in the theorem. Both are clear from context.
6. **The proof's choice of n₀ needs an eventual reading.** The proof says "n₀ … such that max_l s_{n,l} ≤ g₀/2 and Jη_n ≤ 1/2 for all n ≥ n₀". This is correct as an eventual condition. Because s_n is not monotone (Theory §5.5 item 5), it has to be read as "eventually", not checked at a single n. The text is fine as written.
7. **I checked the exponent claims, and both are correct.**
   - Lemma `sup` proof: ρ_n^{2r−2}T_n = (4/c) n^{−(4r²−8r+1)/(2(2r+1))}(log n)^{r−1}, which tends to 0 for r ≥ 2.
   - Scope remark: s_n ≍ n^{−13/70} up to logs for k = 2.
8. **"η_n is the same at all levels"** (proof of `thm:joint`) holds only at σ = 1. At general scales, η′_{n,l} depends on σ_{0l}f̲. The "General scales" paragraph handles this correctly with Σ_l η′_{n,l}.

## 4. Process note

At the start I ran `python3 --version`, a bare interpreter version check, once by mistake, while checking the end of the Spec file. No script was run. It broke the "never run bare python" rule, and I am reporting it here. Every build went through `owls_run` (`-j 3` for `lake build`, `-j 1` for one `lake env lean` axiom check on a temporary file, which I then deleted).
