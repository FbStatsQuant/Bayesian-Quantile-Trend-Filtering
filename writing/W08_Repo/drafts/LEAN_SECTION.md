<!--
W-08, owner addition B (FABLE). Draft of the Lean section of the top-level README.
Status: DRAFT for the Lean department head to fact-check. Not final until the head signs.

Sources allowed by the brief, and the only ones used:
  lean/README.md, lean/AxiomCheck.lean, lean/notes/ (PAPER_CORRECTIONS.md, reviews/, logs/),
  lean/notes/reviews/FINAL_AUDIT_astra.md.
Every claim below is followed by an HTML comment "src:" with file:line. Line numbers are those of the
working tree on 2026-11-26 (lean/ last touched by commit f7aa3c6).
The module map also uses the list of file names under lean/BQTF (git ls-files); file names only.
Paths in links are relative to the repository root, since this text goes into the top-level README.

Items the head must decide are collected at the end ("For the Lean head"). They are in comments and
do not print.
-->

## Formal verification in Lean

Both contraction theorems of the paper are proved in [Lean 4](https://lean-lang.org/) with Mathlib, in [`lean/`](lean). A proof assistant checks every step of a proof down to the axioms, so the theorems do not rest on a referee having read the appendix line by line.
<!-- src: lean/README.md:5 ("machine-checked proofs, in Lean 4 with Mathlib, of the paper's two posterior-contraction theorems") -->

### What is proved

| Paper | In plain words | Lean statement | Proved by |
|---|---|---|---|
| Theorem 1, σ = 1 | For independent data whose distribution functions grow at least and at most linearly near the τ-quantile (Assumptions A and B), a trend of bounded variation and a penalty λ = c·n^((2k+1)/2), the expected posterior mass of the trends whose loss Δ²ₙ exceeds M·n^(−(2k+1)/(2k+2)) is at most C·n^(−1/(2k+2)). There is no logarithmic factor. | `MainStatement` | `main_theorem` |
| Theorem 1, any fixed scale σ₀ > 0 | The same bound, with constants that may also depend on σ₀. | `MainStatementScale` | `main_theorem_scale` |
| Theorem 2, unit scales | For J quantile levels fitted jointly under the non-crossing constraint, the same bound holds for the largest of the J losses, so all levels contract at the same rate at once. | `JointStatement` | `joint_theorem` |
| Theorem 2, any fixed scales σ₀ⱼ > 0 | The same, with a separate scale at each level. | `JointStatementScale` | `joint_theorem_scale` |
<!-- src (names, files): lean/README.md:32-37; lean/AxiomCheck.lean:9-10,17-18 -->
<!-- src (Thm 1 in words): FINAL_AUDIT_astra.md:25-32 (k≥1, level in (0,1), independent laws, margins A and B, TV bound, λ=c n^((2k+1)/2), event Δ²ₙ>M n^(-(2k+1)/(2k+2)), bound C n^(-1/(2k+2)), "without a logarithm") -->
<!-- src (Thm 1 scale): FINAL_AUDIT_astra.md:36-38 ("adds σ₀>0 before the constants"; "M,C,n₀ may additionally depend on σ₀") -->
<!-- src (Thm 2 in words): FINAL_AUDIT_astra.md:44-48 (finite J, same single-level premises at each level, posterior restricted to trends weakly increasing in j, "strict maximum-loss event", "both exponents of Theorem 1") -->
<!-- src (Thm 2 scales): FINAL_AUDIT_astra.md:52-54 ("arbitrary positive σ₀ⱼ"; "Each level divides its own check loss by its own scale") -->

The observations need not be identically distributed and no moment is assumed. The asymmetric Laplace density is a working likelihood only.
<!-- src: FINAL_AUDIT_astra.md:26 ("Distinct marginal laws and infinite data moments are allowed") -->
<!-- NOTE for the head: "working likelihood only" is the paper's wording (theory.tex), not in the allowed sources. FINAL_AUDIT:26,29 support "product of arbitrary marginal laws" and "working check loss". Keep or cut. -->

In Theorem 2 the true quantile curves are not assumed to be separated, and nothing is assumed about independence across levels: every level uses the same observations.
<!-- src: FINAL_AUDIT_astra.md:45 ("No additional separation of the truth or independence across levels is assumed"; "All levels use one vector of independent observations") -->

The four statements are collected in [`lean/BQTF/Spec.lean`](lean/BQTF/Spec.lean). [`lean/docs/statements.md`](lean/docs/statements.md) explains each one in plain mathematics, so you can compare it with the paper without reading Lean.
<!-- src: lean/README.md:39 -->

### Why you can trust it

- **No `sorry`.** Nothing is left unproved.
  <!-- src: lean/README.md:10; source scan FINAL_AUDIT_astra.md:105-109 (pattern sorry|admit|native_decide|axiom |unsafe|implemented_by|set_option; sole match is a heartbeat limit, Main.lean:233) -->
- **Standard axioms only.** `#print axioms` on each of the four theorems lists `propext`, `Classical.choice` and `Quot.sound`, the three axioms of ordinary mathematics in Lean, and nothing else.
  <!-- src: lean/README.md:10; lean/AxiomCheck.lean:12-13,20-21; printed output FINAL_AUDIT_astra.md:84-87; again after the polish pass, PolishDocstrings_Astra_2026-11-26.md:3 -->
- **The statements are pinned.** [`lean/AxiomCheck.lean`](lean/AxiomCheck.lean) contains lines such as `example : MainStatement := main_theorem`. They compile only if each theorem has exactly the type written in `Spec.lean`, so a proof of something weaker cannot pass under the same name.
  <!-- src: lean/README.md:25; lean/AxiomCheck.lean:4-5,9-10,17-18 -->
- **Independent final audit: CLEAN.** A reviewer who wrote none of the proofs compared the four compiled statements with the paper, hypothesis by hypothesis, and reran the axiom check and the source scan. The verdict: all four Lean statements imply their paper counterparts, with no gap in any of them.
  <!-- src: FINAL_AUDIT_astra.md:1 (title "Independent final audit at 5c3d923"); :3 ("CLEAN. All four compiled propositions imply their paper counterparts."); :32,38,48,54 ("Top-level gaps: none." x4); :73 ("No blocker, major or minor fidelity gap in the four top-level statements"); :77-109 (commands and output) -->
  <!-- NOTE for the head: "who wrote none of the proofs" is my reading of "independent"; the audit file does not say it in words. Reword to "An independent reviewer" if you prefer. -->
- **Every module was reviewed.** Each module has a dated code review in [`lean/notes/reviews/`](lean/notes/reviews), and the head ruled on every finding.
  <!-- src: lean/README.md:67 ("per-module code reviews"); PAPER_CORRECTIONS.md:12 ("a fresh Sol review has passed, and the head has ruled on every finding"); 29 dated review files in lean/notes/reviews/ besides the final audit -->

### Classical results proved from scratch

No classical result enters as a hypothesis. Where Mathlib did not have a result the proofs need, it is proved in this repository:
<!-- src: lean/README.md:10 ("No classical result enters as a hypothesis.") -->

| Result | Lean declaration | File |
|---|---|---|
| Efron–Stein inequality, one-sided form | `BQTF.Prob.efronStein_oneSided` | `lean/BQTF/Prob/EfronStein.lean` |
| Rademacher contraction principle (Ledoux–Talagrand, Theorem 4.12) | `BQTF.Prob.contraction_abs` | `lean/BQTF/Prob/Contraction.lean` |
| Symmetrization | `symmetrization_finset` | `lean/BQTF/Prob/Symmetrization.lean` |
| Eckart–Young tail bound for singular values | `eckartYoung_tail` (namespace `BQTF.Lin`) | `lean/BQTF/Lin/EckartYoung.lean` |
| Prékopa–Leindler inequality, in the form the proof uses (log-concavity of the product-Laplace slice mass) | `prekopa_laplace` | `lean/BQTF/Shift/PrekopaLaplace.lean` |
<!-- src Efron–Stein: lean/README.md:10; PAPER_CORRECTIONS.md:85 (name and file) -->
<!-- src contraction: lean/notes/logs/cp_opus2_progress.md:1 ("Ledoux–Talagrand contraction (BQTF.Prob.contraction_abs)"); reviews/Contraction_2026-11-25.md:1,60 ("The paper cites Ledoux–Talagrand Thm 4.12"); logs/neonB_questions.md:50,61 (not in Mathlib) -->
<!-- src symmetrization: reviews/Concentration_2026-11-25.md:31 (file), :79 ("concentration and symmetrization_finset use the standard 3 axioms only"); PolishDocstrings_Astra_2026-11-26.md:20 (the three modules supply symmetrization_finset, contraction_abs, efronStein_oneSided) -->
<!-- src Eckart–Young: lean/README.md:10 ("the Eckart–Young tail bound"); reviews/EckartYoung_2026-11-25.md:1,10; PolishDocstrings_Astra_2026-11-26.md:11 -->
<!-- src Prékopa–Leindler: lean/README.md:10; PolishDocstrings_Astra_2026-11-26.md:17 ("prekopa_laplace in Shift/PrekopaLaplace proves joint log-concavity of the product-Laplace slice mass"); reviews/QuadShift_2026-11-26.md:57 ("the proved Prékopa–Leindler slice result") -->
<!-- NOTE for the head (1): lean/README.md:10 names three results (Efron–Stein, Eckart–Young, Prékopa–Leindler). The brief asks for five. Contraction and symmetrization are supported by the notes cited above but not by lean/README.md. Confirm that both are proved here without a hypothesis, and consider adding them to lean/README.md:10 so the two READMEs agree. -->
<!-- NOTE for the head (2): PolishDocstrings:17 calls the Prékopa result a "product-Laplace slice specialization" (row label "Scope"). I therefore do not write "the Prékopa–Leindler inequality" without the qualifier. lean/README.md:10 does. Decide which wording is right and use it in both places. -->
<!-- NOTE for the head (3): the fully qualified names of symmetrization_finset and prekopa_laplace are not given in the notes; I wrote them unqualified. -->

### What the formalization changed in the paper

Formalizing the proofs found eleven places where the paper's argument needed a fix, numbered C-01 to C-11 in [`lean/notes/PAPER_CORRECTIONS.md`](lean/notes/PAPER_CORRECTIONS.md): missing cases, side conditions that were not stated, and intermediate claims that were wrong as written. None changes the statement of a theorem or a rate. All eleven are now in the paper, and each was checked against the Lean declaration that settles it.
<!-- src count and summary: lean/README.md:57 ("eleven places ... missing cases, unstated side conditions, or a wrong intermediate claim. None changes a theorem statement or a rate.") -->
<!-- src C-01..C-11 headings: PAPER_CORRECTIONS.md:31,42,52,61,70,79,95,104,113,122,138 (eleven "## C-xx" headings, none skipped) -->
<!-- src "in the paper" and "checked": status lines PAPER_CORRECTIONS.md:40 (C-01 verified; fix already in the paper at 906be2b, :35-37), :50 (C-02), :59 (C-03), :68 (C-04), :77 (C-05), :86 (C-06), :102 (C-07), :111 (C-08), :120 (C-09), :136 (C-10), :145 (C-11); each reads "in paper (<hash>)" and "verified" -->
<!-- NOTE for the head: please confirm line 145 (C-11) ends with "verified" as the others do; I read "in paper (3cae0ec); verified (2026-11-26, Lean head)". -->

Three examples:

- **C-06.** The variance bound for a supremum used a two-sided change bound that holds only one-sided. The fix uses the one-sided Efron–Stein inequality; the bound is unchanged.
  <!-- src: PAPER_CORRECTIONS.md:79 (heading), :83 (fix; "The stated bound is unchanged"), :84 ("a wrong proof step") -->
- **C-07.** A second-moment bound was proved only for positive shifts, and the printed formula was false for negative ones. The fix adds the negative case with the same constant.
  <!-- src: PAPER_CORRECTIONS.md:95 (heading), :98-100 ("For t < 0 the displayed representation is false"; "The constants are unchanged") -->
- **C-02 and C-11.** The theorems take the expectation of the posterior probability of a set, but the paper never said that this probability is a measurable function of the data. Lean proves it as part of each conclusion.
  <!-- src: PAPER_CORRECTIONS.md:42-48 (C-02), :138-144 (C-11); lean/README.md:46 (D3, D8) -->

### Where Lean differs from the paper

Both theorems have the paper's hypotheses and conclusions. [`lean/docs/statements.md`](lean/docs/statements.md) lists every difference, D1 to D12, with its direction:
<!-- src: lean/README.md:43 -->

- **Equivalent reformulations** (D1, D2, D4, D5, D9), for example the assumptions stated coordinate by coordinate and the posterior written with its normalizer.
  <!-- src: lean/README.md:45; FINAL_AUDIT_astra.md:60,61,63,64,68 ("Equivalent" for D1, D2, D4, D5, D9) -->
- **Stronger conclusions** (D3, D8): measurability of the posterior mass is proved as part of the theorem.
  <!-- src: lean/README.md:46; FINAL_AUDIT_astra.md:62,67 ("Stronger conclusion") -->
- **Safe generalizations** (D6, D7, D11): the level spacing enters through a lower bound, the number of levels is any natural number, and the gap lemma needs Assumption B only.
  <!-- src: lean/README.md:47,50; FINAL_AUDIT_astra.md:65,66,70 ("Safe" for D6, D7, D11) -->
- **Lemma sup** (D12) is proved on the paper's named event, as `supNorm_concentration_events`, so it matches the paper.
  <!-- src: lean/README.md:51,55 ("Since then, the named-event version supNorm_concentration_events has been added, so Lemma sup now matches the paper"); PolishDocstrings_Astra_2026-11-26.md:28 -->
- **One difference is weaker than the paper** (D10). Three constants that the paper gives explicitly in appendix lemmas are existential in Lean: C_E in Lemma evid, C_pr in Proposition prior, and the quad-shift coefficient. So the Lean versions of those standalone lemmas say less than the paper's. The two theorems are not affected: their constants are existential in the paper too, and the final audit traced that the weaker lemmas suffice.
  <!-- src: lean/README.md:49,53,55; FINAL_AUDIT_astra.md:69 ("D10 | Weaker explicit appendix coefficients, sufficient for both theorems"), :13-15 (trace), :73 ("D10 and D12 limit standalone appendix claims") -->
<!-- COUNT CHECK for the head: D1..D12 = 12 entries: 5 equivalent (D1, D2, D4, D5, D9) + 2 stronger (D3, D8) + 3 safe (D6, D7, D11) + D12 + D10 = 12. -->
<!-- NOTE for the head, "only D10 weaker": the final audit (at 5c3d923) marks TWO entries weaker, D10 (:69) and D12 (:71). D12 was closed afterwards by supNorm_concentration_events (commits 323b228 and f7aa3c6 per the lean/ log; lean/README.md:55), and that addition was audited separately (PolishDocstrings_Astra_2026-11-26.md:3,28, at 7ea4cfc). So "only D10 is weaker" is true of the current tree, and "the final audit found only D10 weaker" would be false. The text above is worded for the current tree. -->

### Build and check

You need [elan](https://github.com/leanprover/elan). It installs the toolchain pinned in `lean/lean-toolchain` (`leanprover/lean4:v4.35.0-rc2`); Mathlib is pinned in `lean/lake-manifest.json`.
<!-- src: lean/README.md:14 -->
<!-- NOTE for the head: the Mathlib revision itself is not in the allowed sources (lean/README.md:14 says only "pinned in lake-manifest.json, at the same revision as the Large Prior formalization"). If you want the commit or tag printed here, supply it: [Lean head: Mathlib revision]. -->

```sh
cd lean
lake exe cache get              # prebuilt Mathlib; without it Mathlib compiles for hours
lake build                      # ends with "Build completed successfully"
lake env lean AxiomCheck.lean   # prints the axioms each main theorem uses
sha256sum -c SHA256SUMS.txt     # the Lean sources are the ones we checked
```
<!-- src: lean/README.md:16-21 (first three commands, verbatim), :28 (SHA256SUMS) -->
<!-- NOTE for the head: build time is not stated in the allowed sources. The LP repo's README says "~15 min". Supply a measured time or leave it out: [Lean head: build time with the Mathlib cache]. -->

The third command should print four lines, each ending in `[propext, Classical.choice, Quot.sound]`.
<!-- src: lean/README.md:26; lean/AxiomCheck.lean:12-13,20-21 (four #print axioms); FINAL_AUDIT_astra.md:84-87 -->

### Module map

```
lean/
├── BQTF/                  the development
├── BQTF.lean              imports every module
├── AxiomCheck.lean        type and axiom checks for the four theorems
├── docs/statements.md     the statements in plain mathematics, and the differences from the paper
├── notes/                 statement audits, per-module reviews, paper corrections, work logs
├── PLAN.md                the module plan the formalization followed
├── lakefile.toml, lake-manifest.json, lean-toolchain
└── SHA256SUMS.txt
```
<!-- src: lean/README.md:61-71 -->

A rough map of `lean/BQTF/`:

| Files | Content |
|---|---|
| `Spec.lean` | The four statements and the definitions they use |
| `Basic.lean`, `Coord.lean` | Norms, the prior in difference coordinates; the posterior as a ratio and its properness (Lemma coord) |
| `CheckLoss.lean` | The check loss and its moments (Lemma check) |
| `Gram.lean`, `Falling.lean`, `Smooth.lean`, `Interp.lean`, `SplineApprox.lean` | Polynomial Gram matrices (g_r > 0), local smoothing, interpolation, spline approximation |
| `Width.lean`, `Concentration.lean`, `Score.lean` | The width bound, concentration of the empirical process, the score events |
| `SmallBall.lean`, `QuadShift.lean`, `PriorMass.lean`, `Denominator.lean` | Small-ball probability, the quadratic-shift lemma, prior mass, the lower bound on the denominator |
| `Localization.lean`, `Shells.lean` | Localization and the bound on shells |
| `Main.lean` | Theorem 1 at σ = 1 |
| `Reduction.lean`, `Scale/` | Theorem 1 at a general scale, by rescaling the data |
| `Joint/` | Theorem 2: the product posterior and its conditioning on the non-crossing set, the gap between levels, sup-norm concentration, transfer, and the two joint theorems (`Joint/Main.lean`) |
| `Prob/` | Efron–Stein, the contraction principle, symmetrization |
| `Lin/` | Eckart–Young, the Gaussian small-ball bound, the Laplace scale mixture |
| `Shift/` | Prékopa–Leindler for the Laplace measure, Rademacher maxima, slice bounds |
| `Asym/` | Rates and elementary integrals used throughout |
<!-- src Spec: lean/README.md:39,63; PolishDocstrings:26 -->
<!-- src Basic, Coord: FINAL_AUDIT_astra.md:29 (Basic.lean: norms, product Laplace prior in difference coordinates), :63 (Coord.lean:747 properness); PAPER_CORRECTIONS.md:58 (posterior_eq_ratio, Coord.lean, Lemma coord) -->
<!-- src CheckLoss: PAPER_CORRECTIONS.md:97,101 (Lemma check(e), remK_moments) -->
<!-- src Gram: PAPER_CORRECTIONS.md:39 (gr_pos); Interp: :67; Smooth: :33 (Lemma pf:lem:smooth) with reviews/SmoothInterp_2026-11-25.md; SplineApprox: reviews/SplineApprox_2026-11-25.md:5 (Lemma pf:lem:F); Falling: reviews/Falling_2026-11-25.md:37 (iterated differences of monomials) -->
<!-- src Width: reviews/Width_2026-11-25.md:14 (Lemma pf:lem:width); Concentration: PAPER_CORRECTIONS.md:81,85 (Lemma conc); Score: FINAL_AUDIT_astra.md:7 (score_events), reviews/Score_2026-11-25.md:23 (pf:lem:score) -->
<!-- src SmallBall: PAPER_CORRECTIONS.md:115,119 (Lemma sb); QuadShift: :124,135; PriorMass and Denominator: FINAL_AUDIT_astra.md:11-15, lean/README.md:49,55 -->
<!-- src Shells: PAPER_CORRECTIONS.md:106,110 (Lemma shells). Localization: file name and reviews/Localization_2026-11-25.md:1 only; the one-word description is INFERRED from the name. Head to confirm. -->
<!-- src Main, Reduction, Scale: lean/README.md:34-35; PAPER_CORRECTIONS.md:76 (Reduction.lean, Scale/Data.lean) -->
<!-- src Joint: lean/README.md:36-37,63; FINAL_AUDIT_astra.md:19 (SupNorm, SupNormScale, Main), :48 (Product.lean:217, Conditioning.lean:27), :70 (Gap.lean, Transfer.lean) -->
<!-- src Prob: see "Classical results" above. Lin: PolishDocstrings:19 (LaplaceMixture: Gaussian scale mixture representation; EckartYoung; GaussianSmallBall). Shift: PolishDocstrings:17,18 (PrekopaLaplace, SliceBounds, Rademacher: integral_rademacherMax_le) -->
<!-- src Asym: PAPER_CORRECTIONS.md:110 (Asym/Laplace.lean used for the Laplace mgf); reviews/Main_2026-11-25.md:109 (Asym/Rates.lean). The description "rates and elementary integrals" is INFERRED from the file names (Rates, ShellRates, LocalRates, CheckIntegrals, Laplace). Head to confirm. -->

The work logs and reviews in [`lean/notes/`](lean/notes) record how the development was built and checked.
<!-- src: lean/README.md:67 -->

<!--
==========================================================================================
FOR THE LEAN HEAD: things to confirm or decide (none of this prints)

1. COUNTS. C-01..C-11: eleven headings, PAPER_CORRECTIONS.md:31-138. D1..D12: twelve entries,
   lean/README.md:43-51 and FINAL_AUDIT_astra.md:60-71. Classification used above: 5 equivalent,
   2 stronger, 3 safe, D12 now matching the paper, D10 weaker.

2. "ONLY D10 WEAKER". True for the current tree, not for the tree the final audit read. The final
   audit is at 5c3d923 and lists D10 AND D12 as weaker (:69, :71). D12 was closed later (323b228),
   audited in PolishDocstrings_Astra_2026-11-26.md (:28) at 7ea4cfc. The section says "final audit:
   CLEAN" and "D12 matches the paper" in different bullets on purpose, so that neither sentence claims
   that the final audit covered the later commit. If you want one sentence that covers both, it should
   name both reviews.

3. THE AUDITED COMMIT IS NOT THE CURRENT HEAD OF lean/. After 5c3d923 came the polish pass
   (9663f6b, f5936b3, 323b228, 7ea4cfc, f64025a, f7aa3c6). Polish_2026-11-26.md:5-9 records that all
   117 shared public and 128 shared private declaration headers are unchanged and that Spec.lean and
   AxiomCheck.lean are unchanged apart from a doc comment; PolishDocstrings:3 records the four axiom
   lines again at 7ea4cfc. f64025a changed comments after 7ea4cfc. Is there an axiom check and a
   source scan on the commit the README will describe? If not, one run of
   `lake build && lake env lean AxiomCheck.lean` at that commit closes it, and SHA256SUMS.txt should
   be from the same commit (f7aa3c6 says it was refreshed for the 58 Lean sources).

4. FIVE CLASSICAL RESULTS. lean/README.md:10 names three; the brief names five. See NOTE (1) under
   "Classical results". Also NOTE (2): is "Prékopa–Leindler inequality" without a qualifier accurate,
   given PolishDocstrings:17?

5. PINS. Toolchain leanprover/lean4:v4.35.0-rc2 (lean/README.md:14). Mathlib revision: not in the
   allowed sources; placeholder left. Build time: placeholder left.

6. SOURCE SCAN. FINAL_AUDIT:109 reports one `set_option maxHeartbeats 600000` in Main.lean:233, which
   "preserves kernel checking". I did not mention it in the public text. Say so if you want it shown.

7. PUBLIC VIEW OF lean/notes/. The reviews contain absolute home-directory paths in their Markdown
   links (for example reviews/CheckLoss_2026-11-25.md:44, Polish_2026-11-26.md:8), commands with a
   local wrapper path (FINAL_AUDIT_astra.md:80,105), and internal names of provers and reviewers.
   The README section above links to lean/notes/reviews/ and to PAPER_CORRECTIONS.md, so readers
   will open them. The links with home paths are dead on GitHub. This is item 4 of Section 7 of
   FABLE.md; cleaning them changes no Lean source and no checksum (SHA256SUMS.txt covers Lean
   sources only).

8. TWO INFERRED ROWS in the module map: Localization and Asym. Marked above.

9. I did not rebuild. Every statement about what compiles is taken from the notes.
==========================================================================================
-->
