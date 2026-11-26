# W-08 cross-critique: NEON draft, read against FABLE

Reviewer: FABLE side. Checked on 2026-11-26 against `git ls-files` (1,757 tracked files), `git grep` and `paper/sections/`.
Line numbers `NEON:n` and `FABLE:n` are lines of `drafts/NEON.md` and `drafts/FABLE.md`. Nothing but this file was written.
Not checked: NEON's statements about the LP repo (colours, file names); I did not query GitHub.

## 1. What NEON does better (take into the merged proposal)

1. **Hygiene list (NEON 6C, lines 287-292). All four items verified; FABLE has only the SPod one.**
   - 4 tracked `.pyc` under `experiments/interior_quantiles/individual_nots_20261003/__pycache__/`; no `SHA256SUMS` names them
     (`prepare_package.py:17` excludes `__pycache__`). Safe to untrack.
   - Munich `Others/*.rds` still tracked (24.1 MB, 12.5 MB, ten of about 4.8 MB), although `README.md:66` says they went to the PC.
   - `experiments/joint_upper_levels/runs/.../metadata/monitor/history.jsonl` is tracked, although `.gitignore:40` ignores the
     pattern and `experiments/README.md:30` says it is on the PC.
   - `experiments/scalability/benchmark_existing.R:6-9` sources pre-E-03 paths (`Simulations/NOTS_n500/...`). It cannot run.
     **This is an error in FABLE:** FABLE:124 puts `Rscript benchmark_existing.R` in the "Our work" table. Remove it.
2. **Default-prior mismatch (NEON:187). Verified.** `method/README.md:23` says b0 = 0.01; the code has `b0 <- 1e-5`
   (`method/individual/Individual_Sampler_PMALA_Augmented.R:87`, `method/joint/Joint_Sampler_PMALA_Augmented.R:110`).
   FABLE missed it, and FABLE:323 calls the settings block "the paper's defaults" without checking the prior. Keep NEON's note;
   drop "the paper's defaults" from the quick start until E-19 settles the prior.
3. **Two blockers for moving the department folders that FABLE does not name (NEON:134-135, 279-280). Verified.**
   - `lean/BQTF/Gram.lean:9` cites `theory/T10_gr_positivity/NOTE.md`, and that file is hashed (`lean/SHA256SUMS.txt:17`).
     Moving `theory/` leaves a stale path in an audited source or breaks the checksum.
   - `paper/sections/theory.tex:2` cites `writing/W03_Theorem/theorem.tex` (a comment, but the paper is not to be edited).
   Add both to FABLE's M3 row (FABLE:398).
4. **"Our work" table with real commands (NEON:41-48).** FABLE's table is mostly `[Eng]` placeholders. NEON's verified cells:
   `bash submit.sh RUN_NAME` (`experiments/interior_quantiles/individual_nots_20261003/submit.sh:6`), the two air drivers
   (`experiments/air_simulation/drivers/`), `cd applications/Growth && Rscript Growth_plots_k2.R` (the script uses relative
   paths, `Growth_plots_k2.R:12-18`, so the `cd` is needed). Section numbers §2, §3, §4.1-§4.4 and Tables 1-6, Figures 1-2
   match the order in `paper/sections/` (the two wrong appendix letters are in Section 2 below).
5. **Timings sentence (NEON:28):** 2.0 ms at n = 250, 36.6 ms at n = 4,000, about 25 times and 7,000 times faster than the
   Gibbs code. Verified: `paper/sections/scalability.tex:31`, `:43` (ratios 25 and 7,035), one laptop core (`:18`).
   Two endpoints show the linear growth; FABLE's single n = 1,000 figure (FABLE:88) does not. Use NEON's numbers.
6. **Theory wording (NEON:26):** names the loss (Δ_n²), the two assumptions as "local lower and upper bounds on the
   distribution functions near the quantile" (`theory.tex:33-47`), and "no additional separation assumption" for Theorem 2
   (`theory.tex:109`). All correct and more exact than FABLE:73-77. Merge these phrases into FABLE's shorter paragraph.
7. **Quick start: `sha256sum -c SHA256SUMS.txt` (NEON:248).** It is in `lean/README.md:28`; FABLE's quick start omits it.
8. **`CITATION.cff` (NEON:72):** no `affiliation`, no `preferred-citation`. Verified against the file. Cheap, not in FABLE.
9. **H1 (NEON:14):** "Bayesian Joint Quantile Trend Filtering" matches the paper and `CITATION.cff`, and puts "joint", the hero,
   in the title. Prefer it to FABLE's "Bayesian quantile trend filtering" (FABLE:39).
10. **Line-level privacy citations (NEON:307-311).** I checked all 17 cited lines; each shows what NEON says. FABLE gives counts
    and fewer lines. Use NEON's table as the checklist and FABLE's Section 7 for the procedure.
11. **`--quick` cannot be added to sealed packages (NEON:87):** correct, and a useful limit on what "from the shipped results"
    can mean (FABLE:136).

## 2. Errors in NEON

| # | NEON line | Claim | What the repo says |
|---|---|---|---|
| E1 | 28 | ADMM is worse at τ = 0.01 "where eBIC selects an overly small penalty that bends into emission plumes and crosses higher quantiles", in a sentence about simulation MSE | That is the SPod real-data fit (`paper/sections/data_application.tex:22`), which has no MSE. The simulation is `air_simulation.tex`; its current table has ADMM ahead at 0.01 (0.0302 against 0.0461, `air_simulation.tex:24`, `:27`). Two studies are merged into one sentence. Split them, as FABLE:97-100 does. |
| E2 | 28 | "the joint sampler eliminates crossings and lowers MSE relative to single-level fits" | True against the individual P-MALA sampler only, and "in every configuration but two" (`simulations.tex:98`). Against other single-level methods it is false in places: ADMM has the smallest MSE on the S signal under Beta and Gaussian noise, the horseshoe sampler under Beta noise on VS (`simulations.tex:94-96`). Say "than our own single-level fits in all but two configurations". |
| E3 | 28 | "ADMM shares a single banded factorization across the forward and reverse proximal maps and the proposal draw" | One Cholesky factor of A serves the two maps; the metric M is factorized separately for the proposal noise (`appendix_pmala.tex:27`; `methodology.tex:165`). Drop "and the proposal draw". |
| E4 | 42 | Lean build "~15 min with Mathlib cache" | No build time is recorded in `lean/README.md` or `lean/notes/*.md` (`lean/README.md:18` says only that without the cache Mathlib compiles for hours). The figure seems to come from the LP repo. Placeholder until the Lean head measures it. |
| E5 | 43 | Simulations: "§4.1 & Appendix C" | Appendix C is the sampler's computational details; the simulation appendix is D (`paper/main.tex:84-88`). |
| E6 | 47 | Growth: "§4.4 & Appendix D" | The growth appendix is E (`main.tex:88`, `appendix_data_application_plots.tex:32`). |
| E7 | 44 | `python3 build_tables.py`, "seconds from shipped timings" | The script needs two arguments (`experiments/scalability/build_tables.py:4`, `:10`) and `pandas`, which no requirements list names. As written the command fails. Same error at FABLE:124. Correct form: `python3 build_tables.py . <out_dir>`; Engineering to confirm. |
| E8 | 114 | "one-line italic caption" | The proposed caption is one sentence of about 95 words. It also opens "Non-crossing quantile bands and baselines" over all three panels, but panel (b) is three separate individual-sampler fits (`data_application.tex:16`, "Each level is fitted independently"), for which nothing guarantees order. See D4. |
| E9 | 133, 173, 278 | "E-20" as in-flight work under `engineering/`; "`e13.slurm`-`e18.slurm`" | No `engineering/E20*` is tracked (last is `E19_Default_Prior`, one file). There is no `e16.slurm`; E-16 uses `launch_full.sh` (NEON:278 has it right). |
| E10 | 283 | `.githooks/size_allowlist.txt` and `LICENSE` block moving the public folders | The allowlist has no entries (two comment lines). Not a reference. |
| E11 | 298 | "294 tracked text files" with machine paths | Not reproducible. The six strings NEON lists in line 312 match 271 files, 268 without the three W-08 files (FABLE: 275). NEON's `theory/` count of 19 against my 6 suggests a wider, unstated pattern. The merged text must give the exact regex. |
| E12 | 194 | "tested on R 4.4.1-4.6.0" | Two versions are attested, 4.4.1 (`scalability.tex:18`) and 4.6.0 on the server (`engineering/E14_Inner_Rerun/DATA_MATCH.md:54`). No file states a tested range. Write "R >= 4.4" as `method/README.md:27` does. |
| E13 | 57 | Data section: "SPod provenance and SHA-256 manifest in `DATA.md`" | The manifest is there; the provenance is not: `applications/Air Quality/DATA.md:5` reads "Source: TODO". NEON does not raise the redistribution terms of the 140 MB of raw data (FABLE:447 does). |

Omissions, not errors: NEON has no flag for the third-party article text
`paper/history/simulation_revision_20260914/Brantley_2020.txt` (FABLE:448; the file exists); NEON's theory paragraph does not say
that the theorems fix λ and σ while the samplers put priors on both (FABLE:80-81; the paper says it in Section 3.4).

Verified and correct in NEON, so nobody rechecks: ten tracked top-level folders; the reference lists of both proposed moves
(9 E-03 files and 12 `paper/history` files for Munich; the 7 lines in 4 pilot scripts); `e18_prepare_spod.R:7`;
`README.md:28`, `:66`; Growth n and G = 220 (`data_application.tex:45-47`); the paper's growth figure is an independent-level
run (`data_application.tex:62`); running the sampler tests from the repo root works (the script searches upward,
`Individual_Sampler_PMALA_Augmented.R:141-146`).

## 3. Disagreements, with a recommendation

**D1. `experiments/pilots/` to `archive/pilots/` (NEON move 2; FABLE keeps it).** NEON's reference list is right, and the risk is
lower than FABLE implies: the pilot scripts load the sampler by a root-relative `method/...` path, so only their own
`experiments/pilots/...` strings change (`run.R:4,13`; `lane.sh:4`; `run_variant.R:3,11,17`; `test_asis_general.R:6`); E-19 does
not reference the folder. The brief itself names `experiments/pilots` among the folders to de-emphasize.
*Recommendation:* accept as optional move, after E-19 closes, with the 7 lines edited in the same commit and
`engineering/E14_Inner_Rerun/DATA_MATCH.md:123` left as history. FABLE's "stays" was too cautious.

**D2. Munich target name.** NEON: `archive/munich_rent/analysis/`. FABLE: `archive/munich_rent/code/`.
*Recommendation:* `code/`. It is the target Engineering already scripted
(`engineering/E03_Repo_Organization/migration/01_moves.sh:168`), so the steward has seen it.

**D3. `paper/history/` (FABLE M2, optional; NEON silent).** NEON treats all of `paper/` as immutable (NEON:86). The brief forbids
changes to paper content; `history/` (263 files) is not content, and it holds most of the Windows paths.
*Recommendation:* keep FABLE's M2 as optional, at paper freeze. Not before.

**D4. SPod panel.** NEON makes the 0.01-0.10 band the default and adds a "fraction below" note. FABLE makes the band conditional
on an order check and falls back to the 0.05 curve. *Recommendation:* FABLE's rule. The fits are separate, so the script must
check the order and stop; the caption says "each fitted separately" and makes no crossing claim. NEON's fraction note is fine
if it is computed per curve by the script.

**D5. Layout.** NEON: three stacked full-width panels. FABLE: (a) full width, (b) and (c) side by side below.
*Recommendation:* FABLE's. The VS panel is the hero and should be the largest; three stacked rows make an image about 10 in
tall and push "Our work" off the first screens. Both drafts agree on shipping order: (a), then (c), then (b). The figure
worker already has demo output in `writing/W08_Repo/figures/out/`; the choice should be made on those images, not on the drafts.

**D6. Where the published figure and script live.** NEON's quick start runs `writing/W08_Repo/figures/make_readme_figures.R`
(NEON:229), a folder NEON's own tree calls internal workspace (NEON:171-174). FABLE proposes `examples/`.
*Recommendation:* one public home (`examples/` with `reference_outputs/`), holding the only copy of the script, the CSVs and
the PNG, moved there at implementation with Engineering's sign-off. Not a second copy next to the one under `writing/`.

**D7. Length of "The main idea".** NEON's three paragraphs run to about 500 words with inline LaTeX; the brief asks for
"3 tight paragraphs" and the LP pattern is shorter. NEON also puts the algorithm in the method paragraph and results in the
computing paragraph. *Recommendation:* FABLE's text as the base (it has the fixed-λ, σ limit and the air result in a separate
paragraph after the figure), with NEON's items 5 and 6 of Section 1 merged in.

**D8. Compiler note.** NEON prints the FMA workaround, with a `/tmp` path, in the README quick start (NEON:218-223).
*Recommendation:* keep it in `method/README.md:30-35`, where it is today; one pointer line on the front page (FABLE:365).

**D9. Badges.** NEON's licence badge reads "MIT (paper: all rights reserved)"; FABLE's reads "MIT (code)" and adds a
"Theorems 1-2 verified in Lean" badge. *Recommendation:* FABLE's two; the Lean badge is the first thing the owner wants sold.

**D10. Sealed packages and the scrub.** NEON says only "do not break them without Engineering's ruling" (NEON:312).
FABLE counts them (about 79 files under 15 manifests) and gives three options (FABLE:443). *Recommendation:* keep FABLE's
options in the merged text; the owner cannot rule on NEON's sentence.

## 4. Errors in FABLE found while checking (for the merge)

- FABLE:124 advertises a script that cannot run, and `build_tables.py` without its arguments (items 1 and E7 above).
- FABLE:218 names the E-20 column `signal`; HQ's ruling fixes `method, x, y, truth, q10, q90` (BRIEF:63).
- FABLE:279 keeps the pilots on a count of references without reading them (D1).
- FABLE:323 "the paper's defaults" (item 2 above).
- FABLE:5 says 1,753 tracked files; today it is 1,757 (E-18 commits since). Recount at merge.
