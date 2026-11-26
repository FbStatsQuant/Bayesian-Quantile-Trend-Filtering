# W-08 brief: public-repo arrangement PROPOSAL (Writing dept)

Repo: this repository (local checkout) (public on GitHub). Paper: paper/main.tex, paper/sections/*.tex, paper/main.pdf.

## Goal (owner's words)
Propose how to arrange the public repo so that it is "complete, engaging, aesthetic and sells well what we have done".
This is a PROPOSAL ONLY. Do NOT move, rename, delete or edit any repo file other than your own draft file. Do NOT commit. Do NOT push.

## Style reference
`gh repo view FbStatsQuant/Large-Prior-Official-Repo` (and `gh api repos/FbStatsQuant/Large-Prior-Official-Repo/contents` to see its layout).
Pattern: badges; title + authors; "The main idea behind this project" in 3 tight paragraphs (method, theory, computing);
an engaging multi-panel figure of real fits with credible bands + one-line italic caption; then "Our work" table
(paper item -> folder -> command -> time), reference_outputs, requirements, structure, citation/license.
Plain, concrete prose; no hype words.

## Must sell (all true; verify each against the repo before writing it)
- Both contraction theorems are formally verified in Lean 4/Mathlib, only standard axioms, independent final audit CLEAN (lean/, lean/AxiomCheck.lean, lean/README.md).
- Exact proximal-MALA sampler on the whole conditional posterior, banded linear-in-n sweeps (paper Section 2 / methodology.tex, method/).
- Joint sampler: non-crossing quantile curves by construction (method/joint).
- Air quality: competitive with ADMM, better at tau = 0.01 (applications/Air Quality, experiments/air_simulation). Numbers are being refit (E-18): write placeholders like [E-18: MSE] rather than numbers.

## Hero figure: OWNER CLARIFICATION (supersedes the paragraph below)
The VS n = 1,000 hero uses the tau = 0.1 and 0.9 quantile ESTIMATES themselves as a band around the series ("the whole series has its own CI so to speak"):
the area between the two estimated curves is shaded, the points fall inside or outside it, and a note gives the fraction inside (about 0.80).
The JOINT sampler is the hero: its curves never cross, so the band is always valid. Per-curve credible bands are an optional faint variant only.
Engineering produces it as E-20. Consider the same band-from-quantiles idea for the SPod and growth panels.

## Hero figure (owner's idea, original wording)
VS signal at n = 1,000, tau = 0.1 and 0.9 fits with credible bands over the data (Engineering is producing the fits).
Candidate further panels: SPod air-quality baseline (after E-18), growth centiles (paper/figures/growth_pmala_*.pdf).
Style: points light grey, dark line, light band. Write a style spec Engineering can implement (size, dpi, colours as hex, fonts, panel layout, file name/location, script that makes it).

## Deliverable: your draft at writing/W08_Repo/drafts/<YOURNAME>.md with 5 sections
1. README outline, with full draft text for title/authors/badges and "The main idea behind this project" (3 paragraphs).
2. Figure plan: panels, captions, style spec for Engineering.
3. Folder arrangement, public vs internal. Department folders (theory/, engineering/, writing/, archive/, literature/, experiments/pilots ...) are de-emphasized (e.g. moved under one folder or just listed last), NOT deleted. Show the proposed top-level tree.
4. Usage / quick start section (draft text; check the real commands and dependencies in README.md, method/README.md, experiments/README.md).
5. File-move list: a table old path -> new path -> every file that references the old path (find them with grep -rn over the repo, incl. READMEs, run records, lean/SHA256SUMS.txt, paper \includegraphics/\input paths, scripts that source() other scripts). Mark moves that are risky. Prefer fewer moves.

## Constraints
- Engineering is repo steward and must sign off any move: say so, and keep the move list minimal and checkable.
- No change to paper content.
- No secrets or personal data (no emails, no machine paths like /home/..., no cluster account names) in anything proposed for public view. Flag any such item you find already in the public repo.
- ops/, runs/, tmp/ are git-ignored; check `git ls-files` for what is actually public.

## OWNER ADDITIONS (2nd round, HQ relay)
A. Learn from the LP repo AS A WHOLE (it is the owner's own): structure, tone, figures, usage sections, how theory and code are presented
   (browse with `gh api repos/FbStatsQuant/Large-Prior-Official-Repo/contents/<path>`; read folder READMEs and lean/README.md there).
   Add a short section "What we take from the LP repo": adopt / adapt / doesn't fit us.
B. A complete, dedicated Lean section in the README (not a one-liner), facts ONLY from lean/README.md, lean/AxiomCheck.lean, lean/notes/, lean/notes/reviews/FINAL_AUDIT_astra.md:
   - what is formalized: Thm 1 (single quantile; main_theorem, main_theorem_scale), Thm 2 (joint; joint_theorem, joint_theorem_scale), each in plain words;
   - trust story: #print axioms = propext, Classical.choice, Quot.sound only; no sorry; statements frozen/pinned in AxiomCheck.lean; independent final audit CLEAN;
   - classical results built from scratch: one-sided Efron–Stein, Rademacher contraction, symmetrization, Eckart–Young, Prékopa–Leindler;
   - feedback into the paper: 11 corrections C-01..C-11 (lean/notes/PAPER_CORRECTIONS.md);
   - honest differences: lean/README.md D1–D12, only D10 weaker than the paper;
   - build/check: toolchain + Mathlib version, build command, AxiomCheck command, SHA256SUMS;
   - module map.
   The Lean department head fact-checks it before it is final.
C. E-20 hero spec FINAL: VS with Normal errors; band between tau 0.1 and 0.9 curves in light blue; dark-blue points on top; true noiseless signal dotted.

## HQ RULINGS (3rd round)
- Writing makes the README figures (writing/W08_Repo/figures/make_readme_figures.R) from Engineering's saved curves.
- E-20 tidy CSV columns: method, x, y, truth, q10, q90 (+ optional q10_lo, q10_hi, q90_lo, q90_hi).
- SPod has only tau = 0.01, 0.05, 0.10 (no 0.9): show the low baseline under the plumes (0.01–0.10 band or the 0.05 curve), spikes above it.
- Growth: tracked applications/Growth/results_joint_k2 = JOINT-sampler fit (b0 = 0.01, 30,000 sweeps / 10,000 burn-in), NOT the run behind the paper's growth figure. Caption as joint-sampler fit (curves cannot cross); never "the paper's Figure 5".
- Privacy scrub of current files approved in principle (implementation phase, Engineering sign-off): /home/<user> -> repo-relative or $HOME; cluster paths/hosts/allocations -> neutral placeholders; run records get a note "paths generalized", provenance kept.
- OPEN for owner: git history rewrite; whether literature/Large Prior.pdf stays public.
