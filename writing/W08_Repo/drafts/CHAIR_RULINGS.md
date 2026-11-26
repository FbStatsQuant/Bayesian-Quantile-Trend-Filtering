# W-08 chair rulings for the merge (Writing manager)

Inputs: BRIEF.md (with all owner/HQ rulings), FABLE.md, NEON.md, LEAN_SECTION.md, CRITIQUE_of_NEON.md,
CRITIQUE_of_FABLE.md, INVENTORY.md, figures/README.md (+ figures/out/*.png), lean head questions.
Base text: FABLE.md. Bring in NEON material where named below. Every critique finding below has been
checked by the chair or by the other drafter against the repo; re-verify any number you carry over.

## R1. README order (LP pattern)
Badges -> title + authors (no emails) -> "The main idea behind this project" (3 tight paragraphs, ~250-300
words total: method / theory / computing; FABLE base + NEON's exact theory wording where crisper + NEON's
timing endpoints 2.0 ms to 36.6 ms per sweep, scalability.tex:31,43) -> hero figure + one-line italic
caption -> "Our work" table -> "Formal verification in Lean" (LEAN_SECTION) -> Quick start -> Requirements
-> Shipped outputs -> Repository structure -> Data -> Citation and license.

## R2. Claims discipline (keep FABLE's guardrails)
- Keep FABLE's fixed-vs-random (lambda, sigma) disclaimer (FABLE.md:80-81) and its five caption rules (194-200).
- Joint sampler vs single-level: say only what simulations.tex:94-98 supports (better than OUR individual
  sampler in all but two configurations; ADMM/horseshoe win some cells). No general "lowers MSE".
- Air quality: simulation and SPod are separate studies; do not merge them (data_application.tex vs
  air_simulation.tex). Numbers stay [E-18: ...] placeholders. Point estimates only (MSE, CL, CAA);
  no coverage/interval claim anywhere (E-18 coverage is far below nominal). README goes public only after
  the E-18 paper update lands, so README and paper agree.
- Appendix letters: proofs A, assumptions B, computation C, simulations D, real-data figures E (main.tex:84-88).
- No build time for Lean unless the Lean head supplies one.

## R3. Figures
- Hero = 1 x 2: (a) VS n = 1,000, Normal errors, joint sampler, light-blue band between tau 0.1/0.9 curves,
  dark-blue points on top, true signal dotted, share inside; (b) Growth boys, joint-sampler fit
  (results_joint_k2), labelled "joint-sampler fit; the curves cannot cross", never "the paper's Figure 5".
  Use the actual style spec and numbers from writing/W08_Repo/figures/README.md (colours, 0.8051 boys
  / 0.8025 girls) and say the hero panel waits for E-20.
- SPod: its own full-width figure in the Air-quality row / applications README after E-18 Stage 2'; low
  baseline (0.01-0.10 band, 0.05 line), share below the 0.10 curve. The three SPod levels are SEPARATE
  fits: the band needs an order check (report crossings) and the caption must not say "non-crossing".
- E-20 schema = method, x, y, truth, q10, q90 (+ q10_lo, q10_hi, q90_lo, q90_hi). FABLE's "signal" is wrong.

## R4. Folders
- Public core first: paper/, method/, lean/, experiments/, applications/, NEW examples/ (holds the README
  figure script + reference_outputs: the front page must not be served from writing/). Records listed last,
  in place: engineering/, theory/, writing/, literature/, archive/. No department folder moves (blockers:
  lean/BQTF/Gram.lean:9 cites theory/ inside a hashed source; paper/sections/theory.tex:2 cites writing/;
  engineering/ path is hard-coded in its own scripts and E-18/E-19 run from it).
- Root README repo map must list lean/ (INVENTORY: it is currently missing).

## R5. Moves (all need Engineering sign-off; use INVENTORY for the reference lists)
- M1 now: applications/Munich Rent/ -> archive/munich_rent/code/ (E-03 target, 01_moves.sh:168).
- M2 new: writing/W08_Repo/figures/{make_readme_figures.R,README.md} -> examples/readme_figures/
  (+ reference_outputs/ with the final PNGs), after E-20.
- Optional later: experiments/pilots/ -> archive/pilots/ after E-19 (4 scripts, 7 self-referencing lines);
  paper/history/ -> archive/paper/history/ at paper freeze.
- Non-move hygiene: git rm the 4 tracked __pycache__/*.pyc; the tracked monitor/history.jsonl under an
  ignored path; 01b_heavy_rm.sh never applied (SPod CSVs 134 MB, Munich draws 115 MB tracked) -> after
  E-18 (E-18 reads one SPod CSV), Engineering decides; 10 files exceed the 5 MB hook limit.

## R6. Fixes Engineering must make before the README can point at them (list, do not fix)
- experiments/scalability: benchmark_existing.R hard-codes pre-E03 paths; build_tables.py needs 2 args and
  columns absent from timings.csv; table_cost_scaling_body.tex holds superseded numbers (30-897 ms) vs paper
  2.0-36.6 ms. Until fixed, the "Our work" row points to the paper's table and says "script being updated".
- method/README.md:23 says b0 = 0.01; code default is 1e-5 (individual l.87, joint l.110). Flag to HQ/owner;
  the README states whatever the owner rules, not either value now.
- glmgen is not on CRAN: Engineering supplies the install line. Add ggplot2 to requirements (Growth plots).
- README.md:13 points to an untracked hash_map.tsv; 3 SHA256SUMS entries under
  experiments/interior_quantiles/individual_nots_20261003 already fail although experiments/README says
  seals stay valid.

## R7. Privacy (approved scrub of current files, Eng sign-off; provenance kept)
- Use INVENTORY counts (306 files with patterns + 37 Windows-path-only; classes docs 122 / code 129 /
  frozen 55; 81 sealed by a checksum). Plan: docs -> edit; code -> path variable / repo-relative;
  frozen + sealed -> edit, regenerate the manifest, keep the old manifest as *.orig with a note
  "paths generalized on <date>", one tracked substitution log. lean/SHA256SUMS covers only .lean files:
  scrubbing lean/notes keeps the seal and fixes dead links.
- OPEN for the owner: (a) git history rewrite; (b) literature/Large Prior.pdf public?; (c) third-party
  paper texts paper/history/simulation_revision_20260914/Brantley_2020.txt and Onizuka_2023.txt
  (recommend removing from the tip); (d) SPod raw-data redistribution terms (DATA.md TODO);
  (e) oversized files after E-18; (f) b0 default text (R6).

## R8. Lean section. SUPERSEDED: the Lean head's corrected LEAN_SECTION.md (7b61442) goes in verbatim; the list below is history only.
lean/notes scrub: paths only, header "Paths generalized for publication, <date>; content otherwise verbatim", Lean head confirms first.
- Module map: add Prior/ (Geometry.lean, Window.lean: prior geometry/window); Localization row =
  Proposition pf:prop:local (Localization.lean:11); Asym/ has 8 files.
- Qualified names: BQTF.Prob.symmetrization_finset, BQTF.prekopa_laplace, BQTF.Lin.eckartYoung_tail.
- Mathlib pin: lake-manifest.json inputRev v4.35.0-rc2.
- Rebuild question closed: Polish_2026-11-26.md:102 (build + AxiomCheck + sorry scan on main at f64025a);
  f7aa3c6 changed no .lean file. 11 commits touch lean/ after the audited 5c3d923.
- Pending Lean-head rulings: D10/D12 wording, five-vs-three classical results in lean/README.md:10,
  Prekopa-Leindler qualifier. Leave them marked [Lean head] in the merged text.

## R9. "What we take from the LP repo": NEON's section is the base (it cited LP files); add FABLE's points
that are not in it; adopt / adapt / doesn't fit.
