# W-08 proposal: arrangement of the public repository

Merged from the two drafts, the two critiques, the inventory and the figure worker's README, with the chair's rulings R1 to R9 applied.

This is a proposal. Nothing was moved, renamed, deleted or committed to write it, and no file other than this one was edited. Engineering is the repo steward: every move, removal and scrub below is run by Engineering after its sign-off.

Conventions:

- Square brackets mark a value that is not final: `[E-18: ...]` waits for the air-quality refit, `[E-20: ...]` for the hero fit, `[Eng: ...]` for Engineering, `[owner: ...]` for the owner.
- Every number and path carried over from the drafts was checked again against the tracked files on 2026-11-26 (1,763 tracked files; the Lean section was read again at commit `7b61442`). What did not hold is fixed in the text and listed at the end under "Merge corrections".
- Personal strings are masked as `***`. Two tracked folder names contain the cluster's name and are written here as `individual_***_20261003` and `E09_***_Cleanup`.

---

## 0. Summary for the owner

**What changes**

1. A new front page (`README.md`) in the pattern of the Large Prior repository: badges, title and authors, "The main idea behind this project" in three paragraphs, the hero figure with a one-line caption, the "Our work" table, a full section on the Lean proofs, quick start, requirements, shipped outputs, structure, data, citation and license. The draft text is in Section 1 and Section 8.
2. A hero figure of two panels: the band between the joint sampler's 0.1 and 0.9 quantile curves on a simulated signal (n = 1,000), and the same band on the height of 4,817 Dutch boys. The growth panel can be drawn today; the simulation panel waits for Engineering's fit (E-20). The air-quality figure is separate and comes after E-18.
3. One new public folder, `examples/`, which holds the figure script and the small files the figure is drawn from. The front page is not served from `writing/`.
4. The working rules that are on the front page today (commit rules, task IDs, the size hook, the description of the git-ignored folders) go to a new `engineering/README.md`.
5. A scrub of personal and machine strings in the current files (Section 6).

**What stays**

- The ten tracked top-level folders stay where they are. The public ones (`paper/`, `method/`, `lean/`, `experiments/`, `applications/`, and the new `examples/`) are listed first in the README; the record folders (`engineering/`, `theory/`, `writing/`, `literature/`, `archive/`) are listed last and described as records. No department folder moves.
- The paper is not touched: no file under `paper/main.tex`, `paper/sections/` or `paper/figures/` changes.
- The Lean sources are not touched, so `lean/SHA256SUMS.txt` stays valid.

**How many moves**

| | Count | What |
|---|---:|---|
| Recommended | 2 | M1: the dropped Munich application to `archive/` (125 files, now). M2: the README figure script and its README to `examples/readme_figures/` (2 files, after E-20). |
| Optional, later | 2 | `experiments/pilots/` to `archive/pilots/` after E-19; `paper/history/` to `archive/paper/history/` at paper freeze. |
| Department folders | 0 | |

**Open decisions for the owner** (details in Section 9)

1. Rewrite the git history after the scrub, or leave it?
2. Does `literature/Large Prior.pdf` stay public?
3. Remove the two third-party article texts under `paper/history/` from the tip? (Recommended: yes.)
4. The raw SPod data: who owns it, and may we redistribute it?
5. The oversized tracked files (10 files over 5 MB), after E-18.
6. Which default prior rate b0 the README states: `method/README.md` says 0.01, the code says 1e-5.

**What blocks publication**

The README goes public only after the E-18 paper update lands, so that README and paper give the same air-quality numbers. Until then the air-quality cells are placeholders.

---

## 1. README outline and draft text

### 1.1 Order of sections (R1)

1. Badges
2. Title and authors (no e-mail addresses)
3. The main idea behind this project (three paragraphs: method, theory, computing)
4. Hero figure and one-line italic caption
5. Our work (table: paper item, folder, command, time)
6. Formal verification in Lean (full text in Section 8)
7. Quick start
8. Requirements
9. Shipped outputs
10. Repository structure
11. Data
12. Citation and license

What leaves the front page: the "Status" section, the committing rules, "Departments and task IDs", the row for the git-ignored folders with the cluster path, the sentence that tells the reader to ask an author for a local path, and the pointer to `engineering/E03_Repo_Organization/hash_map.tsv`, a file that is not tracked.

### 1.2 Badges, title and authors

```markdown
# Bayesian Joint Quantile Trend Filtering

[![R >= 4.4](https://img.shields.io/badge/R-%E2%89%A5%204.4-276DC3)](https://www.r-project.org/)
[![Lean 4](https://img.shields.io/badge/Lean-v4.35.0--rc2-0f4c81)](https://lean-lang.org/)
[![Theorems 1-2 verified in Lean](https://img.shields.io/badge/Theorems%201%E2%80%932-verified%20in%20Lean-2e7d32)](#formal-verification-in-lean)
[![License: MIT (code)](https://img.shields.io/badge/license-MIT%20%28code%29-lightgrey)](#citation-and-license)

This repository has the code, the paper and the Lean proofs for
**Bayesian Joint Quantile Trend Filtering via Proximal MCMC with Sequential Gibbs Sampling**,
by Felipe Bedoya, Meng Li (Department of Statistics, Rice University) and
Eric C. Chi (School of Statistics, University of Minnesota).
```

Notes for the editor:

- The H1 matches the paper and `CITATION.cff` and has "joint", the subject of the hero figure, in it. The full title is in the sentence below.
- The Lean badges are static. They are true today (Section 8). If a CI job is added later, replace the third badge with the live one.
- The licence badge says "code" because `LICENSE` excludes the manuscript text.
- No e-mail addresses. Contact is "open an issue".

### 1.3 The main idea behind this project

Three paragraphs, 295 words by `wc -w`.

```markdown
## The main idea behind this project

Quantile trend filtering estimates a conditional quantile by combining the
check loss with an ℓ1 penalty on the differences of order k+1 of the trend. It returns a point
estimate, and the penalty has to be selected. We give it a Bayesian counterpart: an asymmetric
Laplace working likelihood, a Laplace prior on the differences, and priors on the penalty and the
scale. The output is a posterior, with no cross-validation. A joint version fits several quantile levels together, and its draws never cross.

Theorem 1 shows that for a fixed scale and a deterministic penalty of order n^((2k+1)/2), the
posterior contracts around the true quantiles at the rate n^(-(2k+1)/(2k+2)) in the Δ²ₙ loss:
n^(-5/6) for k = 2, with no logarithmic factor. It asks only for local lower and upper
bounds on the distribution functions near the quantile; no moment is assumed. Theorem 2 gives the
same rate at every level of the non-crossing joint posterior at once, with no separation
assumption. Both theorems are machine-checked in Lean 4 ([`lean/`](lean)). The theorems hold the
penalty and the scale fixed; the samplers place priors on both, and that case is not covered.

The normal-exponential representation of that likelihood makes the conditional
of the trend a weighted quadratic plus the ℓ1 difference penalty. We update the trend by a
proximal Metropolis-adjusted Langevin step whose proximal map is a weighted trend filtering
problem on this whole conditional, not on a smoothed check loss; the accept-reject step uses the
exact density. Every linear system is banded, so the cost of a sweep grows linearly with n: 2.0 ms
at n = 250 and 36.6 ms at n = 4,000 on one laptop core. In the joint sampler the proximal map
becomes a box-constrained problem solved with banded interior-point steps.
```

One short paragraph follows the figure, for the air-quality result. It stays a placeholder until E-18 closes:

```markdown
In the peak-detection simulation of Brantley et al. (2020) for air-quality sensors, the sampler
recovers the peak-free baseline with [E-18: MSE PMALA] against [E-18: MSE ADMM] for ADMM quantile
trend filtering at τ = 0.05 and 0.10, and [E-18: MSE PMALA] against [E-18: MSE ADMM] at τ = 0.01,
without selecting a penalty. On one day of fenceline sensor readings (n = 8,640), [E-18: one
sentence on the fitted baselines].
```

Rules these paragraphs follow (R2). They bind any later edit:

1. **Fixed and random (λ, σ).** The sentence "The theorems hold the penalty and the scale fixed; the samplers place priors on both, and that case is not covered" stays on the front page. The paper says the same in its Section 3.4.
2. **Joint against single-level fits.** The README says only that the joint sampler's draws never cross. If a sentence on accuracy is added, it is this and no more: at the extreme upper levels the joint sampler has a smaller MSE than our own individual sampler in every configuration but two, and ADMM and the horseshoe sampler have the smallest MSE in some cells. There is no general "lowers MSE".
3. **Air quality.** The simulation and the SPod application are two studies and are written as two sentences. Numbers are placeholders. Only point estimates are reported (MSE, mean check loss, class-averaged accuracy). No sentence claims coverage or calibrated intervals: in the tracked E-18 table the 95% pointwise coverage of the selected fits is far below 0.95.
4. **Appendix letters.** Proofs A, assumptions B, computation C, simulations D, real-data figures E.
5. **Lean.** The only build time stated is the one the Lean head measured: about 15–20 minutes on 3 cores with the prebuilt Mathlib.
6. The timings are those of the paper's cost table: 2.0 ms at n = 250 and 36.6 ms at n = 4,000, one laptop core. Check them again at paper freeze.

### 1.4 Hero figure and caption

```markdown
![A shaded band between two estimated quantile curves, with the data points on top](examples/readme_figures/reference_outputs/readme_combined.png)

*Bands between jointly sampled 0.1 and 0.9 quantile curves, which cannot cross. Left: a simulated signal, n = 1,000; the band holds [E-20: share] of the points (dotted: the true signal). Right: height of 4,817 Dutch boys, joint-sampler fit; the band holds 80.5% of the children.*
```

The caption rules are in Section 2.3.

### 1.5 "Our work" table

```markdown
## Our work

The samplers and the proofs can be checked on a laptop. The simulation campaigns ran on a Slurm
cluster from frozen packages; each experiment folder ships its summaries.

| In the paper | Folder | How to run | Time |
|---|---|---|---|
| Section 2, Algorithms 1–2: the two samplers | [`method/`](method) | from the repository root: `Rscript method/individual/Individual_Sampler_PMALA_Augmented.R test`; `Rscript method/joint/Joint_Sampler_PMALA_Augmented.R test_prox` | about 5 min; under 1 min (see the note on the tests below) |
| Section 3 and Appendix A: Theorems 1 and 2 | [`lean/`](lean) | in `lean/`: `lake exe cache get`, `lake build`, `lake env lean AxiomCheck.lean` | about 15–20 min on 3 cores, with the prebuilt Mathlib |
| Section 4.1 and Appendix D: simulations at interior levels (Tables 1–2) | [`experiments/interior_quantiles/`](experiments/interior_quantiles) | shipped summaries in `paper_reference/`; full run: `bash submit.sh RUN_NAME` in the package folder, on a Slurm cluster | 3,000 cluster tasks |
| Section 4.1 and Appendix D: joint estimation of extreme upper levels (Tables 3–4), crossing tables | [`experiments/extreme_quantiles/`](experiments/extreme_quantiles), [`experiments/joint_upper_levels/`](experiments/joint_upper_levels) | shipped tables; full run: `bash submit.sh RUN_NAME` in each package | 300 cluster tasks for the joint run |
| Section 4.2: cost per sweep (Table 5, Figures 1–2) | [`experiments/scalability/`](experiments/scalability) | see the paper's table; the script is being updated | |
| Section 4.3: air-quality simulation (Table 6) | [`experiments/air_simulation/`](experiments/air_simulation) | [E-18: command] | [E-18] |
| Section 4.4: air-quality sensor data | [`applications/Air Quality/`](applications/Air%20Quality) | [E-18: command] | [E-18] |
| Section 4.4 and Appendix E: growth centiles | [`applications/Growth/`](applications/Growth) | in `applications/Growth/`: `Rscript Growth_plots_k2.R` redraws the shipped joint-sampler fit; `Rscript Growth_Joint_PMALA_k2.R sex=boy` refits it | seconds; [Eng: time] |
| The figure above | [`examples/readme_figures/`](examples/readme_figures) | `Rscript examples/readme_figures/make_readme_figures.R` | seconds |
| The paper | [`paper/`](paper) | read `main.pdf`, or in `paper/`: `latexmk -pdf main.tex` | |

Each folder has its own README with the settings, the commands and the outputs.

The growth fit shipped in `applications/Growth/results_joint_k2/` is a joint-sampler fit of five
levels. The growth figures of the paper come from fits of one level at a time, and the script that
draws them is not in this repository; the same holds for the figures `spod_*` and `scal_*`.
```

Notes for the editor:

- Section, table and figure numbers follow the order of `paper/sections/` (Section 4 inputs simulations, cost, air simulation, data applications, in that order; four tables in the simulations section, one each in the next two). Read them off the compiled `paper/main.pdf` at freeze.
- **The sampler tests do not pass today** (Section 4.2): the individual test stops at its test 7, and the joint test needs `clarabel`. The row and the quick start keep the commands; the comment "ends with all tests passed" goes public only after Engineering's fix (F12).
- The Lean "Time" cell is the Lean head's measured time (Section 8), in the same words.
- The scalability row carries no command (R6): the benchmark script cannot run, the table builder does not match the shipped file, and the shipped table body holds superseded numbers. Section 4.3 has the details.
- The last sentence of the block replaces the LP sentence "Every figure and table of the paper comes from a script in this repository", which is false here. If E-18 delivers the `spod_*` generator, drop `spod_*` from it. The five `nile_*` files under `paper/figures/` are included by no `.tex` file and are not mentioned.
- The Growth row says which run the command redraws, and does not attach a paper figure number to it.

### 1.6 Quick start and Requirements

````markdown
## Quick start

You need R 4.4 or later with the packages `Rcpp`, `RcppArmadillo`, `glmgen` and `Matrix`, and a
C++17 compiler. The C++ kernels compile themselves the first time a sampler runs. All commands are
typed at the repository root unless a `cd` is shown.

**Check the samplers.**

```sh
Rscript method/individual/Individual_Sampler_PMALA_Augmented.R test    # [Eng: ends with "all tests passed" once F12 is fixed]
Rscript method/joint/Joint_Sampler_PMALA_Augmented.R test_prox         # needs the R package clarabel
```

If a bitwise test fails by about 2e-16, see the compiler note in [`method/README.md`](method/README.md).

**Fit one quantile trend.**

```sh
Rscript method/individual/Individual_Sampler_PMALA_Augmented.R
```

This simulates one data set, runs the sampler with the settings block at the top of the file
(order k = 2, 30,000 sweeps with 10,000 burn-in, [owner: prior on the penalty]) and writes a
summary and a plot to `method/individual/results_pmala_aug/`. To change the signal, the noise, the
sample size or the quantile level, edit the settings block. `Rscript
method/joint/Joint_Sampler_PMALA_Augmented.R` does the same for several levels at once.
[Eng: time for the default runs]

**Redraw the figure above.**

```sh
Rscript examples/readme_figures/make_readme_figures.R    # draws from the saved curves; needs ggplot2
```

**Redraw the growth centiles** from the shipped joint-sampler fit:

```sh
cd applications/Growth && Rscript Growth_plots_k2.R
```

**Check the proofs.** Install [elan](https://github.com/leanprover/elan), then

```sh
cd lean
lake exe cache get              # prebuilt Mathlib; without it Mathlib compiles for hours
lake build                      # about 15-20 min on 3 cores; ends with "Build completed successfully"
lake env lean AxiomCheck.lean   # four lines, each ending in [propext, Classical.choice, Quot.sound]
sha256sum -c SHA256SUMS.txt     # the Lean sources are the ones we checked
```

**Build the paper.** `cd paper && latexmk -pdf main.tex`

## Requirements

- **R** 4.4 or later, with a C++17 compiler: `Rcpp`, `RcppArmadillo`, `glmgen`, `Matrix`. The
  joint sampler's tests also need `clarabel`, and the figure scripts need `ggplot2`.
- `glmgen` is not on CRAN. Install it with [Eng: install line].
- **Lean**: [elan](https://github.com/leanprover/elan) installs the pinned toolchain
  (`leanprover/lean4:v4.35.0-rc2`); `lake` fetches the Mathlib revision pinned in
  `lean/lake-manifest.json`.
- **LaTeX**: only to recompile the paper. TeX Live with `algorithmicx`, `bbm` and `bbold`.
- The simulation campaigns ran on a Slurm cluster from frozen packages. Each experiment folder
  ships its summaries, so the paper's tables can be compared without rerunning them.

## Shipped outputs

- [`examples/readme_figures/reference_outputs/`](examples/readme_figures/reference_outputs): the
  saved curves behind the figure above (small CSV files, no posterior draws) and the image.
- [`applications/Growth/results_joint_k2/`](applications/Growth/results_joint_k2): the joint
  growth fit: curve summaries, sampler diagnostics and the crossing counts (all zero).
- [`experiments/`](experiments): for each campaign, the frozen package, the summaries and the
  tables. [`experiments/README.md`](experiments/README.md) maps every table of the paper to its
  folder.
- [`lean/`](lean): the checked sources with their SHA-256 list, and the reviews in `lean/notes/`.
````

### 1.7 Repository structure

````markdown
## Repository structure

```
paper/           the manuscript: main.pdf, main.tex, sections/, figures/
method/          the samplers: individual/, joint/, and the ADMM baseline admm_qtf/
lean/            Lean 4 proofs of Theorems 1 and 2
experiments/     the simulations of the paper: frozen packages, summaries, tables
applications/    real data: Growth/, Air Quality/
examples/        the figure on this page, with the curves it is drawn from
```

The folders `engineering/`, `theory/` and `writing/` hold the project's working records (task
notes, pilot runs, reviews), `literature/` the reading list, and `archive/` superseded material.
They are not needed to use the method or to reproduce the paper.
````

### 1.8 Data, citation and license

```markdown
## Data

- **Growth.** `applications/Growth/data/fdgs.csv` is the Fifth Dutch Growth Study sample
  (Schönbeck et al., 2013) as distributed with the R package `mice` (van Buuren and
  Groothuis-Oudshoorn, 2011), exported from version 3.19.0. [Eng: licence of the package data]
- **Air quality.** One day of SPod fenceline sensor readings from the EPA Rubbertown data set that
  accompanies Brantley et al. (2020). [owner: source, terms, and whether the raw files are shipped]

## Citation and license

`CITATION.cff` has the reference; GitHub shows it under "Cite this repository".

The code is MIT-licensed (see [`LICENSE`](LICENSE)). The manuscript text under [`paper/`](paper)
is not covered by that licence: all rights reserved until publication. Third-party data stay
under their providers' terms.

Questions or problems? Please open an issue.
```

Two small changes go with this block: add `affiliation` fields and a `preferred-citation` entry to `CITATION.cff`, as the LP repository has (ours has neither); and the heading is spelled "license" in the README to match the badge anchor, while `LICENSE` keeps its own text.

---

## 2. Figure plan

Who does what (HQ ruling): Engineering fits and saves the curves; Writing draws the figures from the saved curves with `make_readme_figures.R`. The script fits nothing, runs in a few seconds, and needs only R with `ggplot2`.

### 2.1 The idea

The hero is a band made of two quantile curves: the joint sampler's estimates at τ = 0.1 and τ = 0.9, with the area between them shaded and the data points on top. A note in the panel gives the share of points inside (nominal 0.80). The joint sampler's curves cannot cross, so the lower edge of the band is never above its upper edge. Per-curve credible bands are not drawn; they are an optional variant (`--bands`), off by default and not for the front page.

### 2.2 Panels (R3)

The hero is one row of two panels, `readme_combined.png`. The demo image `figures/out/readme_combined_DEMO.png` shows the layout; I looked at it, and both panels are legible at README width.

| Panel | Content | Source | Status |
|---|---|---|---|
| (a) Simulation | VS signal, n = 1,000, Normal errors, joint sampler at τ = (0.1, 0.9). Light-blue band between the two estimated curves, dark-blue points on top, the true noiseless signal dotted, share of points inside. | Engineering's saved curves from E-20 | **Waits for E-20.** Today the panel can be drawn only with `--demo`, which uses the true quantiles in place of fitted curves and prints a red DEMO label. The demo image is never published. |
| (b) Growth, boys | Height against age for 4,817 Dutch boys. Band between the fitted 0.1 and 0.9 curves, the median as a thin line, share of children inside. Subtitle in the image: "Joint-sampler fit; the curves cannot cross." | Tracked: `applications/Growth/data/fdgs.csv` and `applications/Growth/results_joint_k2/boy/posterior_summary.csv` | **Ready.** Share inside: 0.8051 for boys (0.8025 for girls; the girls panel is written as a separate file and is not in the combined image). I recomputed both from the tracked files. |

Two facts about panel (b) that every caption and sentence must respect:

- The run is a joint-sampler fit (b0 = 0.01, 30,000 sweeps with 10,000 burn-in; `crossings.csv` in the same folder has zero in every row).
- It is not the run behind the paper's growth figure, which fits each level independently with other settings. The panel is never called "Figure 5 of the paper" or "as in the paper".

### 2.3 Captions

The README caption is in Section 1.4. Alt text: "A shaded band between two estimated quantile curves, with the data points on top".

Five rules keep the captions true (R2):

1. **The share.** The caption prints the share the script computes, at the precision of the note inside the panel (one decimal of a percentage, for example 80.5%), next to the nominal value where there is room. It never rounds a computed share to "about 80%". It is typed from the script's output, not by hand from memory.
2. **What the band is.** It is an in-sample share on the data the curves were fitted to. It is not called coverage, a confidence interval or a credible interval. The words are "the band between two quantile curves".
3. **"Cannot cross"** is said only of joint-sampler fits, that is, panels (a) and (b). The SPod figure is three separate fits and makes no such claim.
4. **The growth panel is not the paper's figure.**
5. **Evidence for "cannot cross" in panel (a).** Next to the saved curves, Engineering saves the number of retained draws and the number with any crossing (expected 0), as `applications/Growth/results_joint_k2/boy/crossings.csv` does for the growth fit.

### 2.4 Style spec (from `figures/README.md`)

| Element | Hex | Note |
|---|---|---|
| Background | `#FFFFFF` | Opaque, so the image reads the same on GitHub's light and dark themes |
| Band (τ 0.1 to 0.9) | `#CFE3F6` | Light blue |
| Band edges (the two curves) | `#7EA9D8` | 0.35 pt lines |
| Data points | `#14325C` | Dark blue, drawn on top of the band; contrast 9.7:1 on the band and 12.8:1 on white |
| True signal (simulation only) | `#111111` | Dotted, with a thin white halo so that it stays visible over the points |
| Median or baseline line | `#0A1A33` | Thin |
| Per-curve credible bands (`--bands`) | `#8FB3DC` | 45% alpha; optional variant |
| Title / axis text | `#1F2328` / `#57606A` | |
| Grid | `#EEF1F4` | Major lines only |
| DEMO label | `#B42318` | Demo images only |

Font: Liberation Sans, with the default sans as a fallback.

| Output | Size |
|---|---|
| `readme_combined.{png,pdf}` | PNG 2400 × 810 px; PDF 10.67 × 3.6 in |
| `readme_hero_vs.{png,pdf}`, `readme_growth_boys.{png,pdf}`, `readme_growth_girls.{png,pdf}` | each PNG 2400 × 1500 px (8 × 5 in at 300 dpi), plus a vector PDF made with `cairo_pdf`, which embeds the fonts |

The demo PNGs are about 0.2 MB each, far under the 5 MB limit of the pre-commit hook.

### 2.5 E-20 schema (R3)

Engineering saves one tidy CSV with these columns:

| Column | Content |
|---|---|
| `method` | the sampler that made the fit; the hero keeps the rows with `method == "joint"` |
| `x` | index of the observation |
| `y` | the observation |
| `truth` | the true noiseless signal |
| `q10`, `q90` | the estimated τ = 0.1 and τ = 0.9 curves |
| `q10_lo`, `q10_hi`, `q90_lo`, `q90_hi` | optional: per-curve credible limits, used only with `--bands` |

The column is `truth`, not `signal`. The names live in one block of the script marked `E-20 COLUMN MAPPING`, which is the one place to edit if the schema changes. Engineering also saves a short summary next to the CSV: n, seed, sampler settings, retained draws, and draws with any crossing (rule 5 above).

### 2.6 SPod plan (R3)

The air-quality figure is not part of the hero. It is its own full-width figure, placed in the air-quality row of the README or in the README of `applications/`, after E-18 Stage 2′.

- Fits exist at τ = 0.01, 0.05 and 0.10 only. There is no upper level, so this is not an "80% band".
- The figure shows the low baseline under the plumes: the band between the 0.01 and 0.10 curves, the 0.05 curve as a line, the readings on top with the spikes above the band. The note gives the share of readings below the 0.10 curve (nominal 0.10), not a share inside.
- The three levels are separate fits of the individual sampler, so nothing guarantees their order. Before the band is drawn, the script checks that the three curves are ordered at every time point and reports the number of crossings. If any are found, the figure falls back to the 0.05 curve alone.
- The caption says "each level fitted separately" and does not say "non-crossing".
- Input: E-18's README says the real-data report writes `spod_curves.csv` under `engineering/E18_Air_Refit/results_a0_n/` (8,640 time labels, the readings in sensor counts, and the pointwise medians at the three levels). The file is not tracked yet. The script already has the function `spod_panel()` for this figure and does not call it yet.

---

## 3. Folder arrangement

### 3.1 Proposed top level (R4)

```
Bayesian-Quantile-Trend-Filtering/
├── README.md                 front page (Section 1)
├── LICENSE, CITATION.cff
│
│   public
├── paper/                    main.pdf, main.tex, sections/, figures/, references.bib
├── method/                   individual/, joint/, admm_qtf/
├── lean/                     Lean 4 proofs of Theorems 1 and 2
├── experiments/              simulations of the paper: frozen packages, summaries, tables
├── applications/             Growth/, Air Quality/
├── examples/                 NEW: readme_figures/ (script, README, reference_outputs/)
│
│   records (kept in place, listed last in the README)
├── engineering/              task folders E-02 to E-19, and a new README.md with the working rules
├── theory/                   task folders T-01 to T-10
├── writing/                  task folders W-01 to W-08
├── literature/               reading list
└── archive/                  superseded material: munich_rent/, scratch_2026/, archived_campaigns.md
```

Six public folders and five record folders. Nothing is deleted. GitHub lists folders alphabetically, so the records sit among the public folders in the file list; the README's structure section sets the reading order.

### 3.2 Public and records

| Folder | Role | In the README |
|---|---|---|
| `paper/`, `method/`, `lean/`, `experiments/`, `applications/`, `examples/` | What a reader uses. Each has, or gets, a README with settings, commands and outputs. | "Our work" table and the structure section |
| `engineering/`, `theory/`, `writing/` | Records of how the work was done: task notes, pilots, audits, run ledgers. Public, not advertised. | One paragraph at the end of the structure section |
| `literature/`, `archive/` | Reading list; superseded material | The same paragraph |
| `lean/notes/` | Audits, reviews and logs of the formalization. Stays: `lean/README.md` links into it, and the final audit and the corrections list are selling points. | Through the Lean section |
| The three git-ignored working folders | Not public | Not on the front page; described in `engineering/README.md` without machine paths |

The root README must list `lean/`. Today it does not: the current README has no mention of `lean/` or of Lean at all.

### 3.3 Why no department folder moves (R4)

Three blockers, each checked:

1. `lean/BQTF/Gram.lean:9` cites `theory/T10_gr_positivity/NOTE.md` in a comment, and that file is one of the 58 sources hashed in `lean/SHA256SUMS.txt`. Moving `theory/` leaves a stale path in an audited source or forces a change to the checksum list.
2. `paper/sections/theory.tex:2` cites `writing/W03_Theorem/theorem.tex` in a comment, and the paper is not to be edited.
3. `engineering/` is hard-coded in its own scripts (14 scripts build paths with `"engineering"`, and 117 tracked files contain `engineering/`), and E-18 and E-19 run from it today.

### 3.4 New files (no move)

| New file | Content | Who |
|---|---|---|
| `examples/README.md` | What the folder is; one line per subfolder | Writing drafts, Engineering checks |
| `examples/readme_figures/reference_outputs/*` | The E-20 curve file and its summary, the published PNGs | Curves: Engineering. Images: Writing. |
| `engineering/README.md` | The working rules now on the front page: commit with explicit paths, the size hook, task IDs, what the git-ignored folders are. No cluster path, no account name. | Engineering |
| `theory/README.md`, `writing/README.md` | Three lines each: what the folder is, that it is a working record, where the final statements live (`paper/`, `lean/`) | Theory, Writing |

Any department brief or note that says "see README for the commit rules" must point to `engineering/README.md` afterwards.

Each public folder README gets, under its title, an italic line naming the paper items it serves, as `lean/README.md` already has (*Theorem 1 · Theorem 2*).

---

## 4. Usage and quick start: reasoning and status of the commands

### 4.1 Reasoning behind the text of Section 1.6

- The tests come before the fit. A reader who wants to know whether the code works on their machine gets an answer in about five minutes.
- Commands are typed at the repository root. Both sampler scripts locate their own folder, so both start from the root; I ran both from there (Section 4.2).
- The compiler note is one pointer line. The full note, with the flags, stays in `method/README.md`.
- The fit paragraph does not say "the paper's defaults". `method/README.md` says the settings block has b0 = 0.01; the code has b0 = 1e-5 in both samplers. The README states whatever the owner rules (Section 9).
- The quick start does not show a call on the user's own data. The sampler file ends with a main block that always runs the pilot fit (from line 767 of the individual sampler), so `source()`-ing it to call the sampler on new data also runs the pilot. A user-data example needs either a guard in the sampler or a small loader; both are Engineering's to decide. A callable entry point is the single change that would most improve the repository for a user.
- `sha256sum -c` is in the Lean block because `lean/README.md` documents it.
- Times are measured wall times on one named class of machine ("a laptop", "one core"), never a host name.

### 4.2 Commands verified

Run during this merge, on a Linux workstation, each through the lab's single-core job wrapper:

| Command | Result |
|---|---|
| `Rscript method/individual/Individual_Sampler_PMALA_Augmented.R test` (from the root, and again from `method/individual/`) | **Fails**, the same way both times, after about 4.5 minutes. Tests 1 to 6d pass. Test 7 (the joint (λ, θ) jump move against a grid reference) stops with `max(abs(m1 - m_ex)/se1) < 4 is not TRUE`: largest mean z-score 68.86, chain mean of λ 0.842 against 3.287 exact. "all tests passed" is not printed. The jump move is off in the default settings (`lamjump <- FALSE`), so the default fit does not use the code that fails. `method/README.md:14` says "all tests passed, about 100 s". |
| `Rscript method/joint/Joint_Sampler_PMALA_Augmented.R test_prox` (from the root) | **Stops at P3** after 24 seconds: the R package `clarabel` is not installed on the machine I used. P1 and P2 pass (P1 bitwise 0.0e+00; P2 within 8.5e-12 of the closed form). Not a code failure; the requirement is documented. |
| `cd lean && sha256sum -c SHA256SUMS.txt` | 58 of 58 OK |

Recorded as passing in the repository, not rerun here:

| Command | Record |
|---|---|
| `lake build`, `lake env lean AxiomCheck.lean`, and the `sorry` scan | Run on `main` at `f64025a` (`lean/notes/reviews/Polish_2026-11-26.md:102`); no Lean source, lakefile, manifest or toolchain file has changed since. The Lean head also rebuilt the BQTF modules from scratch on 2026-11-26 and repeated the axiom check (Section 8). |
| `Rscript make_readme_figures.R --demo` | The demo images in `figures/out/` are dated today; I inspected the combined one. The script was not rerun, so as not to rewrite files. |
| `cd applications/Growth && Rscript Growth_plots_k2.R` | The script reads relative paths (`data/fdgs.csv`, `results_joint_k2/...`), so the `cd` is required. Not rerun: it rewrites tracked figures. Engineering confirms. |
| `cd paper && latexmk -pdf main.tex` | Documented in `paper/README.md`; not rerun |

### 4.3 Commands that wait on Engineering (R6)

These are listed for Engineering to fix. Nothing here was fixed.

| # | Item | What is wrong | Until fixed |
|---|---|---|---|
| F1 | `experiments/scalability/benchmark_existing.R` | Lines 6 to 9 source files by pre-E-03 paths that no longer exist. It cannot run. | Not in the README |
| F2 | `experiments/scalability/build_tables.py` | Needs two arguments (`<results_dir> <out_dir>`) and `pandas`; it reads columns `n` and `ms_per_sweep`, but the shipped `timings.csv` has `method, rep, ms_per_iteration`. | Not in the README |
| F3 | `experiments/scalability/table_cost_scaling_body.tex` | Holds superseded numbers (PMALA 71 ms at n = 500 up to 897 ms at n = 4,000); the paper has 2.0 to 36.6 ms. | The "Our work" row points to the paper's table and says "the script is being updated" |
| F4 | `method/README.md:23` | Says b0 = 0.01; the code default is 1e-5 (`Individual_Sampler_PMALA_Augmented.R:87`, `Joint_Sampler_PMALA_Augmented.R:110`). | Flagged to the owner; the README states neither value |
| F5 | `glmgen` | Not on CRAN. Engineering supplies the install line it uses. | Placeholder in Requirements |
| F6 | `ggplot2` | Needed by `Growth_plots_k2.R` and by the figure script; missing from the current requirements. | Added in the draft |
| F7 | `README.md:13` | Points to `engineering/E03_Repo_Organization/hash_map.tsv`, which is not tracked. | The new README drops the sentence; Engineering adds the file or not |
| F8 | `experiments/interior_quantiles/individual_***_20261003/SHA256SUMS` | 3 of 30 entries fail today (`audit/***_readonly_probe.txt`, `audit/static_checks.json`, `paper_reference/simulations.tex`), although `experiments/README.md` says the seals stay valid. | The README does not say that every package verifies |
| F9 | User-data entry point | `source()`-ing a sampler runs its pilot fit (Section 4.1). | No user-data example in the README |
| F10 | Growth times, default-fit times | Not measured | `[Eng: time]` |
| F12 | `Individual_Sampler_PMALA_Augmented.R test` | Test 7 fails reproducibly (Section 4.2). Either the jump move or its reference is wrong, or the test is stale. | The README does not promise "all tests passed"; Engineering fixes the move, fixes the test, or removes the optional move from the test list |
| F11 | `paper/README.md` | Says "11 section files"; `paper/sections/` has 15. Says `figures/` holds only figures that `main.tex` includes; five `nile_*` files are included by nothing. | Engineering or Writing corrects the README of `paper/`; the paper itself is not touched |

---

## 5. File moves and hygiene

All moves need Engineering's sign-off and are run by Engineering. Reference lists are from INVENTORY and were rechecked with `git grep -nI -F '<old path>'` on 2026-11-26. Engineering reruns the same command just before moving, since E-18 and E-19 are adding files.

"Historical" files record the repository at an earlier date (the E-03 migration scripts, dated paper-history folders). They are not edited after a move; they are listed so that nobody takes them for live references.

### 5.1 Move table (R5)

| # | Old path | New path | Files that reference the old path | Risk | Sign-off |
|---|---|---|---|---|---|
| **M1** (now) | `applications/Munich Rent/` (125 files; the application was dropped from the paper on 2026-10-28) | `archive/munich_rent/code/` (the target E-03 scripted, `engineering/E03_Repo_Organization/migration/01_moves.sh:168`) | **To edit:** `README.md:22` (rewritten anyway); `applications/README.md:9`, `:18`, `:19`; `archive/README.md:7`. **Inside the folder (move with it; already not runnable, they use the pre-E-03 layout):** 4 files at its top level and 7 under `Others/`. **Historical, leave:** `engineering/E02_Rate_Sims/free_check/` (1 file), `engineering/E03_Repo_Organization/` (9 files, among them `01_moves.sh:168,206,216` and `01b_heavy_rm.sh:19`), `experiments/joint_upper_levels/paper_reference/main.txt`, `paper/history/` (12 files). **Not referenced by:** any script outside the folder, any `\input` or `\includegraphics`, `lean/SHA256SUMS.txt`. | Low. One point to settle first: `Others/` holds 115 MB of tracked draws that `01b_heavy_rm.sh` was written to remove (Section 5.3, H3). Decide H3 before M1, so the draws are not moved and then removed. The folder also carries its own `SHA256SUMS.inputs` and `.outputs`, with paths relative to the folder, so they move with it. | Engineering |
| **M2** (after E-20) | `writing/W08_Repo/figures/make_readme_figures.R`, `writing/W08_Repo/figures/README.md` | `examples/readme_figures/`, plus `examples/readme_figures/reference_outputs/` with the E-20 curve file and the final PNGs | **To edit, inside the two files:** `make_readme_figures.R:29` finds the repository root three levels above the script; at the new place it is two. `:32` writes to `out/`; the public copy writes to `reference_outputs/`. `:172` looks for the E-20 file in `engineering/E20_Showcase/`; the public copy reads the curve file in `reference_outputs/`, so the front page does not depend on `engineering/`. Usage comments at `:13`, `:14`, `:20` and `README.md:14-16` name the old path and the lab's job wrapper; the public README gives plain `Rscript` lines. **Leave:** the W-08 drafts and the brief mention the old path as history. **Not referenced by:** any tracked file outside `writing/W08_Repo/`. | Low. The script also parses `method/joint/Joint_Sampler_PMALA_Augmented.R` for `--demo` and reads `applications/Growth/`; both paths are unchanged. After the move, run it once without `--demo` and compare the growth shares with 0.8051 and 0.8025. `figures/out/` is untracked today, so nothing else moves. | Engineering (location), Writing (script) |
| **O1** (optional, after E-19) | `experiments/pilots/` (63 files) | `archive/pilots/` | **To edit:** `experiments/README.md:33`; 7 self-referencing lines in 4 scripts: `default_prior_VS_normal_t075/run.R:4,13`; `lambda_mixing/lane.sh:4`; `lambda_mixing/run_variant.R:3,11,17`; `lambda_mixing/test_asis_general.R:6`. **Historical, leave:** `engineering/E14_Inner_Rerun/DATA_MATCH.md:123`; `engineering/E03_Repo_Organization/` (`PROPOSAL.md:87`, `migration/01_moves.sh:124,146,147`, `migration/02_path_fixes.md:196`). | Low. The pilot scripts load the samplers by the root-relative `method/...` path, which does not change. Three of them name the lab's job wrapper in a usage comment; scrub that in the same commit. | Engineering |
| **O2** (optional, at paper freeze) | `paper/history/` (263 files) | `archive/paper/history/` (this name keeps the `.gitignore` rule `**/history/**/build/` valid) | **To edit:** `README.md:19` (rewritten anyway); `paper/README.md:23`; `experiments/README.md:16`, `:17`, `:19`, `:32`; `engineering/E14_Inner_Rerun/DATA_MATCH.md:169`, `:197`, `:258` (relative links `../../paper/history/...`). **Leave:** `paper/sections/scalability.tex:13`, a comment that already uses a still older name; the paper is not edited. **Historical, leave:** `engineering/E03_Repo_Organization/` (`PROPOSAL.md:64,65`, `migration/01_moves.sh`, `02_path_fixes.md:192`, `05_history_rewrite.sh:12,51`, and the copy of `experiments/README.md` under `03_new_files/`). **Not referenced by:** `paper/main.tex`, any `\input` or `\includegraphics`. | Medium: many files. No file inside the folder uses a `../..` path (0 matches), so the extra level breaks nothing inside. Do it only after the owner rules on the two third-party texts in it (Section 9), and with no edit session open. | Engineering |

### 5.2 Paths that do not move

| Path | Why |
|---|---|
| `engineering/`, `theory/`, `writing/` | Section 3.3 |
| `literature/`, `archive/` | Docs only reference them, but `.gitignore:43-44` names `literature/`, and the gain is nil |
| `paper/main.tex`, `paper/sections/`, `paper/figures/` | 14 `\input` lines and 10 `\includegraphics` lines, relative to `paper/`; no change to the paper |
| `method/` | At least 37 live scripts load it by path; the joint kernel includes the individual one |
| `experiments/*/` frozen packages | Sealed by `SHA256SUMS` with paths relative to the package; 12 live scripts in `engineering/` read `experiments/` |
| `lean/` | Nothing outside references it, so it could move, but it is already where a reader looks |
| `applications/Air Quality/` | Read by `engineering/E18_Air_Refit/e18_prepare_spod.R:7`; renaming it waits for E-18 at the least |

### 5.3 Non-move hygiene (R5)

| # | Item | Facts | Action |
|---|---|---|---|
| H1 | 4 tracked `.pyc` files | `experiments/interior_quantiles/individual_***_20261003/__pycache__/*.cpython-312.pyc`. `.gitignore` already excludes the pattern. No checksum file lists them. | `git rm --cached` |
| H2 | Tracked monitor log under an ignored path | `experiments/joint_upper_levels/runs/VS_upper6_100seeds_Rdefaults_b001_20261002/metadata/monitor/history.jsonl`, 10.3 MB. `.gitignore:40` ignores the pattern and `experiments/README.md:30` says the file is kept elsewhere. | Untrack, or correct the README; Engineering decides |
| H3 | `01b_heavy_rm.sh` was never applied | The seven SPod CSVs (134 MB) and the Munich draws under `Others/` (115 MB) are still tracked, while `applications/Air Quality/DATA.md` and the current README say they were removed. E-18 reads one of the SPod files (`S08_2018-06-15.csv`). | After E-18, Engineering decides. The data question in Section 9 comes first. |
| H4 | 10 files exceed the 5 MB hook limit | The seven SPod CSVs, two Munich `all_quantile_fits.rds` (23.0 and 11.9 MB) and the monitor log of H2. The hook's allowlist is empty. | Follows H2 and H3 |
| H5 | Paths cited as code spans | Nothing in the current root README is a link. | The new README uses links |

---

## 6. Privacy scrub plan (R7)

Approved in principle by the owner: a scrub of the current files, run by Engineering, with provenance kept. Home paths become repo-relative paths or `$HOME`; cluster paths, host names and allocation names become neutral placeholders; run records are not deleted, and each scrubbed record says that paths were generalized.

### 6.1 Counts (INVENTORY, tracked files, `writing/W08_Repo/` excluded)

| | Files |
|---|---:|
| With at least one pattern (home paths, login id, group id, cluster project paths, cluster host, lab host, allocation name, IPv4) | 306 |
| With a Windows user path only (`C:/Users/***`) | 37 |
| **Total** | **343** |

Lines per pattern: home paths 1,281 (in 202 files); login id 1,381; cluster project paths 168; lab host 273; cluster host 17; group id 21; allocation name 7; IPv4 2 (one file). Windows user paths: 1,904 lines in 44 files, 1,867 of them in 29 build logs under `paper/history/`.

Where the 306 files are: `engineering/` 132, `experiments/` 102, `lean/` 39, `theory/` 23, and 10 elsewhere (root 2, `applications/` 2, `archive/` 2, `writing/` 2, `method/` 1, `paper/history/` 1).

No secrets: a search for keys, tokens, passwords and private-key files over the tracked text found none.

### 6.2 Classes and handling

| Class | Files | Handling |
|---|---:|---|
| (a) Docs: READMEs, notes, reviews | 122 | Edit the text: repo-relative paths, "the cluster", "a Linux workstation" |
| (b) Code defaults: R, shell, Slurm, Python | 129 | Replace by a path variable or a repo-relative path; then run the script's test or a dry run |
| (c) Frozen records: deployment and audit logs, run metadata, `paper/history/` | 55 | Edit, with the manifest procedure below where a checksum covers the file |

81 of the 306 files have their current hash listed in a checksum file: 75 in the archive manifest under `engineering/E09_***_Cleanup/` (47 of them only there), and 34 in the `SHA256SUMS` of packages under `experiments/` and of one Munich result folder.

### 6.3 Procedure

1. **One scripted pass, one commit, by Engineering.** The script writes every substitution (`file, line, old class, new`) to one tracked substitution log, so the change can be reviewed and repeated. The log itself holds no personal value: it names the class of the old string, not the string.
2. **Sealed files.** Edit the file, regenerate the manifest, and keep the old manifest next to it as `*.orig` with the note "paths generalized on <date>". The regenerated manifest gives a working check; the `*.orig` file records what ran. The sentence in `experiments/README.md` that says these files must not be edited changes in the same commit.
3. **Lean.** `lean/SHA256SUMS.txt` lists only the 58 `.lean` sources, and none of them carries a pattern. The 39 files with patterns under `lean/` are `PLAN.md` and files in `notes/`. Scrubbing them keeps the seal. In `lean/notes/reviews/` the home paths sit inside Markdown links to a local checkout, so those links are dead on GitHub today; the scrub turns them into repo-relative links, which also makes the reviews usable by a reader. The reviews were committed verbatim, so this pass changes paths only: each edited review gets the header "Paths generalized for publication, <date>; content otherwise verbatim", and nobody touches `lean/notes/` before the Lean head confirms.
4. **Code is run after it is scrubbed.** Two scripts in `engineering/E02_Rate_Sims/` hard-code an absolute path to the kernel; `applications/Growth/Growth_Joint_checks.R:13` has a Windows fallback path.
5. **The paper is not touched.** The authors' addresses on the title page of `paper/main.tex` are normal for a manuscript and stay.
6. **The W-08 files are in scope.** INVENTORY excluded `writing/W08_Repo/` because the drafts quote the patterns. Six tracked files there carry them (the brief, three drafts, and the figure script and its README, which name the lab's job wrapper). They are public and need the same scrub, and the public copies of M2 are written without the wrapper lines.

The scrub cleans the current files only. Every string stays reachable in older commits unless the history is rewritten; that is an open decision (Section 9).

---

## 7. What we take from the LP repo (R9)

Base: the section of the NEON draft, which cites the LP files it read. Added: the points of the FABLE draft that were not in it. I read the LP front page and spot-checked the cited facts (Merge corrections, item 20).

### Adopt

| From the LP repo | Here |
|---|---|
| Front-page order and voice: badges, one sentence with title and authors, "The main idea behind this project" in three paragraphs, figure with a one-line italic caption, "Our work" table, requirements, data, citation and license. Numbers in place of adjectives, "we" for the authors. | Section 1 |
| "Our work" table: paper item, folder, command, time | Section 1.5 |
| Folder READMEs that open with an italic line naming the paper items they serve, then settings, files and commands; a "Scope" block where the code has limits (`sampler/README.md`) | Add the italic line to the READMEs of `method/`, `experiments/*/`, `applications/*/`, `examples/`; add a Scope block to `method/README.md` |
| Drawing kept apart from fitting: plot scripts that fit nothing, and `reference_outputs/` with small CSV files and the figure, no posterior draws | `examples/readme_figures/` |
| Visual grammar: white background, sans-serif text, light grid, a dark and a light blue, a note inside the panel, PNG at 300 dpi plus a vector PDF | Section 2.4, with our own hex values |
| `CITATION.cff` with `affiliation` fields and a `preferred-citation` entry | Section 1.8 |
| Lean transparency: `AxiomCheck.lean`, `docs/statements.md`, `SHA256SUMS.txt`, and a Lean README that says what is proved, how to check it, and where it differs from the paper | Already in `lean/` |
| Limits stated where the claim is made | The fixed (λ, σ) sentence in the theory paragraph; D10 in the Lean section; the caption rules |
| "Questions or problems? Please open an issue." and no e-mail addresses | Section 1.8 |
| A Data section that names each source, its terms, and whether the raw files are shipped | Section 1.8; the SPod line waits for the owner |

### Adapt

| From the LP repo | Why it changes here |
|---|---|
| Lean in one bullet and one table row | Here it is a full section. LP takes the classical approximation inputs as explicit hypotheses; our two theorems take no classical result as a hypothesis, passed an independent audit, and produced eleven corrections to the paper. |
| Hero: posterior means with 95% bands, a figure of the paper | Ours is the band between two jointly sampled quantile curves, made for the README. Its caption cites no paper figure number and does not use the words coverage or interval. |
| "Every figure and table of the paper comes from a script in this repository" | Not true here. Replaced by a sentence that says which figures have no script. |
| Studies that rerun on a laptop in seconds or minutes, with one cluster study | Most of our tables are cluster campaigns of 300 to 3,000 tasks in frozen packages. The table points to shipped summaries and gives the cluster command for the full run. |
| The sampler is a function you `source()` and call, with a usage block | Our samplers are scripts with a settings block, and sourcing one runs its pilot fit. The quick start shows the script run. A callable entry point needs Engineering (F9). |
| Data notes with sources, licences and input checksums | Keep the structure; write archive statements without machine paths; the SPod source is still "TODO" in its `DATA.md` |
| Licence: MIT with a GPL-3 exception for adapted code | MIT for code, manuscript text excluded. Engineering confirms that `method/admm_qtf/` and the Onizuka add-on under `experiments/air_simulation/` contain no adapted third-party code that needs its own notice. |

### Doesn't fit us

| From the LP repo | Why not |
|---|---|
| A repository that holds only the public product (five top-level folders) | This repository is also the working record, and the owner wants the department folders kept. They are listed last. A separate clean release repository would be the closest match to LP; it is a larger decision than this proposal and is only named here. |
| `paper/Overleaf/` and a PDF named after the paper | The paper builds from `paper/main.tex`, and its paths must not change. |
| Top-level names `sampler/` and `simulations/` | Ours are `method/` and `experiments/`, loaded by path from dozens of scripts. |
| A `--quick` flag on every fitting script | Adding it to a sealed package changes its checksums. It is for new scripts only. |
| Byte-for-byte reproduction claims | We have bitwise tests for the kernels only, and they depend on compiler flags. |
| "about 15 min with the Mathlib cache" for the Lean build | That is LP's measured time. Ours is the Lean head's: about 15–20 minutes on 3 cores. |

---

## 8. Formal verification in Lean

The text below is `drafts/LEAN_SECTION.md` as fact-checked and corrected by the Lean head (commit `7b61442`, verdict CORRECTED), copied verbatim with its source comments. It replaces chair ruling R8: neither R8 nor any correction of the merge writer is applied on top of it. The comments do not print on GitHub; they are dropped or kept at the owner's choice when the section is lifted into `README.md`.

`````markdown
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
| Theorem 1, σ = 1 | For independent data whose distribution functions grow at least and at most linearly near the τ-quantile (Assumptions A and B), a true trend whose total variation of order r = k + 1 (the paper's TV^(r)) is at most V̄, and a penalty λ = c·n^((2k+1)/2), the expected posterior mass of the trends whose loss Δ²ₙ exceeds M·n^(−(2k+1)/(2k+2)) is at most C·n^(−1/(2k+2)). There is no logarithmic factor. | `MainStatement` | `main_theorem` |
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
<!-- Lean head: KEEP. It is accurate. In Lean, the posterior is built from the check loss (asymmetric Laplace kernel), and the data law is an arbitrary product of marginals, unrelated to that kernel (BQTF/Spec.lean; FINAL_AUDIT_astra.md:26,29). -->

In Theorem 2 the true quantile curves are not assumed to be separated, and nothing is assumed about independence across levels: every level uses the same observations.
<!-- src: FINAL_AUDIT_astra.md:45 ("No additional separation of the truth or independence across levels is assumed"; "All levels use one vector of independent observations") -->

The four statements are collected in [`lean/BQTF/Spec.lean`](lean/BQTF/Spec.lean). [`lean/docs/statements.md`](lean/docs/statements.md) explains each one in plain mathematics, so you can compare it with the paper without reading Lean.
<!-- src: lean/README.md:39 -->

### Why you can trust it

- **No `sorry`.** Nothing is left unproved.
  <!-- src: lean/README.md:10; source scan FINAL_AUDIT_astra.md:105-109 (pattern sorry|admit|native_decide|axiom |unsafe|implemented_by|set_option; sole match is a heartbeat limit, Main.lean:233) -->
- **Standard axioms only.** `#print axioms` on each of the four theorems lists `propext`, `Classical.choice` and `Quot.sound`, the three axioms of ordinary mathematics in Lean, and nothing else. This was last checked, with a full build and the source scan, at commit f64025a. No Lean source, lakefile, manifest or toolchain file has changed since.
  <!-- Lean head (2026-11-26): confirmed. Full build, AxiomCheck and the source scan on main at f64025a (Polish_2026-11-26.md, rulings). Later lean/ commit f7aa3c6 touched docs and SHA256SUMS only. A from-scratch rebuild of BQTF at 19be187, whose lean/ tree equals f7aa3c6's, repeated AxiomCheck. -->
  <!-- Lean head: the audit at 5c3d923 and the later polish are kept separate on purpose. The CLEAN verdict is the audit's, at 5c3d923. The D12 change and the docstrings came after it and were reviewed separately (PolishDocstrings_Astra_2026-11-26.md, at 7ea4cfc). 11 commits touch lean/ after 5c3d923. -->
  <!-- src: lean/README.md:10; lean/AxiomCheck.lean:12-13,20-21; printed output FINAL_AUDIT_astra.md:84-87; again after the polish pass, PolishDocstrings_Astra_2026-11-26.md:3 -->
- **The statements are pinned.** [`lean/AxiomCheck.lean`](lean/AxiomCheck.lean) contains lines such as `example : MainStatement := main_theorem`. They compile only if each theorem has exactly the type written in `Spec.lean`, so a proof of something weaker cannot pass under the same name.
  <!-- src: lean/README.md:25; lean/AxiomCheck.lean:4-5,9-10,17-18 -->
- **Independent final audit: CLEAN.** A reviewer who wrote none of the proofs compared the four compiled statements with the paper, hypothesis by hypothesis, and reran the axiom check and the source scan. The verdict: all four Lean statements imply their paper counterparts, with no gap in any of them.
  <!-- src: FINAL_AUDIT_astra.md:1 (title "Independent final audit at 5c3d923"); :3 ("CLEAN. All four compiled propositions imply their paper counterparts."); :32,38,48,54 ("Top-level gaps: none." x4); :73 ("No blocker, major or minor fidelity gap in the four top-level statements"); :77-109 (commands and output) -->
  <!-- Lean head: CONFIRMED. The final auditor was a fresh agent launched for the audit, with no part in writing or reviewing the proofs (audit brief, 2026-11-26). -->
- **Every module was reviewed.** Every source file is covered by a dated code review in [`lean/notes/reviews/`](lean/notes/reviews), written by a reviewer who did not write that file. The statements were audited separately, in [`lean/notes/audits/`](lean/notes/audits). Every finding was ruled on.
  <!-- src: lean/README.md:67 ("per-module code reviews"); PAPER_CORRECTIONS.md:12 ("a fresh Sol review has passed, and the head has ruled on every finding"); 29 dated review files in lean/notes/reviews/ besides the final audit -->
  <!-- Lean head: checked file by file. Each of the 56 files under lean/BQTF is named in at least one review. Some reviews cover a group of files: for example, the Denominator review covers Asym/*, and the SmallBall review covers Lin/GaussianSmallBall and LaplaceMixture. So "every source file is covered", not "each module has its own review". -->

### Classical results proved from scratch

No classical result enters as a hypothesis. Where Mathlib did not have a result the proofs need, it is proved in this repository:
<!-- src: lean/README.md:10 ("No classical result enters as a hypothesis.") -->

| Result | Lean declaration | File |
|---|---|---|
| Efron–Stein inequality, one-sided form | `BQTF.Prob.efronStein_oneSided` | `lean/BQTF/Prob/EfronStein.lean` |
| Rademacher contraction principle (Ledoux–Talagrand, Theorem 4.12) | `BQTF.Prob.contraction_abs` | `lean/BQTF/Prob/Contraction.lean` |
| Symmetrization for finite empirical processes (van der Vaart and Wellner, Lemma 2.3.6) | `BQTF.Prob.symmetrization_finset` | `lean/BQTF/Prob/Symmetrization.lean` |
| Eckart–Young tail bound for singular values (Frobenius form) | `BQTF.Lin.eckartYoung_tail` | `lean/BQTF/Lin/EckartYoung.lean` |
| Prékopa–Leindler inequality: the functional form on ℝ, tensorized to the product Laplace law on ℝᵈ. The proof uses it as joint log-concavity of the Laplace slice mass. | `BQTF.PL.pl_one`, `BQTF.PL.plProp_Qlam`; applied in `BQTF.prekopa_laplace` | `lean/BQTF/Shift/PrekopaLaplace/OneDim.lean`, `…/Tensor.lean`, `lean/BQTF/Shift/PrekopaLaplace.lean` |
<!-- src Efron–Stein: lean/README.md:10; PAPER_CORRECTIONS.md:85 (name and file) -->
<!-- src contraction: lean/notes/logs/cp_opus2_progress.md:1 ("Ledoux–Talagrand contraction (BQTF.Prob.contraction_abs)"); reviews/Contraction_2026-11-25.md:1,60 ("The paper cites Ledoux–Talagrand Thm 4.12"); logs/neonB_questions.md:50,61 (not in Mathlib) -->
<!-- src symmetrization: reviews/Concentration_2026-11-25.md:31 (file), :79 ("concentration and symmetrization_finset use the standard 3 axioms only"); PolishDocstrings_Astra_2026-11-26.md:20 (the three modules supply symmetrization_finset, contraction_abs, efronStein_oneSided) -->
<!-- src Eckart–Young: lean/README.md:10 ("the Eckart–Young tail bound"); reviews/EckartYoung_2026-11-25.md:1,10; PolishDocstrings_Astra_2026-11-26.md:11 -->
<!-- src Prékopa–Leindler: lean/README.md:10; PolishDocstrings_Astra_2026-11-26.md:17 ("prekopa_laplace in Shift/PrekopaLaplace proves joint log-concavity of the product-Laplace slice mass"); reviews/QuadShift_2026-11-26.md:57 ("the proved Prékopa–Leindler slice result") -->
<!-- NOTE for the head (1): lean/README.md:10 names three results (Efron–Stein, Eckart–Young, Prékopa–Leindler). The brief asks for five. Contraction and symmetrization are supported by the notes cited above but not by lean/README.md. Confirm that both are proved here without a hypothesis, and consider adding them to lean/README.md:10 so the two READMEs agree. -->
<!-- NOTE for the head (2): PolishDocstrings:17 calls the Prékopa result a "product-Laplace slice specialization" (row label "Scope"). I therefore do not write "the Prékopa–Leindler inequality" without the qualifier. lean/README.md:10 does. Decide which wording is right and use it in both places. -->
<!-- NOTE for the head (3): the fully qualified names of symmetrization_finset and prekopa_laplace are not given in the notes; I wrote them unqualified. -->
<!-- Lean head, ON (1)-(3), 2026-11-26:
  - All five results are proved in-tree with no hypothesis standing in for the classical result. `#print axioms` gives [propext, Classical.choice, Quot.sound] for each of: BQTF.Prob.efronStein_oneSided, BQTF.Prob.contraction_abs, BQTF.Prob.symmetrization_finset, BQTF.Lin.eckartYoung_tail, BQTF.PL.pl_one, BQTF.PL.plProp_Qlam and BQTF.prekopa_laplace.
  - Prékopa–Leindler: the full functional inequality is proved, not only the slice specialization. pl_one is Prékopa–Leindler for Lebesgue measure on ℝ (via a one-dimensional weighted Brunn–Minkowski). Tensor.lean shows it is stable under products, measure-preserving linear equivalences and log-concave densities, which gives plProp_Qlam for the product Laplace law on ℝᵈ. prekopa_laplace (PolishDocstrings:17) is the specialization the proof uses. Both READMEs now say "functional form on ℝ, tensorized to the product Laplace law".
  - lean/README.md:10 now lists all five.
  - Fully qualified names: BQTF.Prob.symmetrization_finset, BQTF.prekopa_laplace, BQTF.Lin.eckartYoung_tail, BQTF.Prob.contraction_abs, BQTF.Prob.efronStein_oneSided. eckartYoung_tail is outside the inner EckartYoung namespace, which ends at EckartYoung.lean:112. -->


### What the formalization changed in the paper

Formalizing the proofs found eleven places where the paper's argument needed a fix, numbered C-01 to C-11 in [`lean/notes/PAPER_CORRECTIONS.md`](lean/notes/PAPER_CORRECTIONS.md): missing cases, side conditions that were not stated, and intermediate claims that were wrong as written. None changes the statement of a theorem or a rate. All eleven are now in the paper, and each was checked against the Lean declaration that settles it.
<!-- src count and summary: lean/README.md:57 ("eleven places ... missing cases, unstated side conditions, or a wrong intermediate claim. None changes a theorem statement or a rate.") -->
<!-- src C-01..C-11 headings: PAPER_CORRECTIONS.md:31,42,52,61,70,79,95,104,113,122,138 (eleven "## C-xx" headings, none skipped) -->
<!-- src "in the paper" and "checked": status lines PAPER_CORRECTIONS.md:40 (C-01 verified; fix already in the paper at 906be2b, :35-37), :50 (C-02), :59 (C-03), :68 (C-04), :77 (C-05), :86 (C-06), :102 (C-07), :111 (C-08), :120 (C-09), :136 (C-10), :145 (C-11); each reads "in paper (<hash>)" and "verified" -->
<!-- NOTE for the head: please confirm line 145 (C-11) ends with "verified" as the others do; I read "in paper (3cae0ec); verified (2026-11-26, Lean head)". -->
<!-- Lean head: CONFIRMED. All eleven status lines (40, 50, 59, 68, 77, 86, 102, 111, 120, 136, 145) read "verified", and C-02 to C-11 each carry an "in paper (<hash>)". Theory confirmed every one. -->
<!-- Lean head: the C-06, C-07 and C-02/C-11 examples were checked against PAPER_CORRECTIONS. All three are accurate. -->

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
- **Safe generalizations** (D6, D7, D11): the level spacing enters through a lower bound, both in Theorem 2 and in the gap lemma, and the number of levels is any natural number.
  <!-- Lean head: CORRECTED. The old text "the gap lemma needs Assumption B only" implied the paper's lemma needs more, but the paper's Lemma gap (appendix_theory.tex, \label{pf:lem:gap}) also assumes B only. The generalization in D11 is that `level_gap_of_assB` accepts any lower bound gmin on the adjacent spacings; the minimum spacing gives the paper's g₀ exactly (PolishDocstrings_Astra_2026-11-26.md, D11). -->
  <!-- src: lean/README.md:47,50; FINAL_AUDIT_astra.md:65,66,70 ("Safe" for D6, D7, D11) -->
- **Lemma sup** (D12) is proved on the paper's named event, as `supNorm_concentration_events`, so it matches the paper.
  <!-- src: lean/README.md:51,55 ("Since then, the named-event version supNorm_concentration_events has been added, so Lemma sup now matches the paper"); PolishDocstrings_Astra_2026-11-26.md:28 -->
- **One difference is weaker than the paper** (D10). Two constants that the paper gives explicitly in appendix lemmas are existential in Lean: C_E in Lemma evid and C_pr in Proposition prior. A third, the quad-shift coefficient, is a different explicit constant, in place of the paper's eventual bound of 2. So the Lean versions of those standalone lemmas say less than the paper's. The two theorems are not affected: their constants are existential in the paper too, and the final audit traced that the weaker lemmas suffice.
  <!-- Lean head: CORRECTED. The quad-shift coefficient is not existential: it is H = (1 + K_max/2)/(1 − e^{−2}), in place of the paper's eventual c_K ≤ 2 (docs/statements.md D10; FINAL_AUDIT_astra.md:13). lean/README.md:49 had the same slip and is fixed in the same commit. -->
  <!-- Lean head, ON POINT 1: the wording keeps the two reviews cleanly separate. "Final audit: CLEAN" (Why you can trust it) describes 5c3d923, where the audit marked D10 and D12 weaker. The D12 bullet here describes the current tree, where D12 was closed by supNorm_concentration_events (323b228) and reviewed in PolishDocstrings_Astra_2026-11-26.md at 7ea4cfc. Neither sentence claims the audit covered the later commit. Approved as written. -->
  <!-- src: lean/README.md:49,53,55; FINAL_AUDIT_astra.md:69 ("D10 | Weaker explicit appendix coefficients, sufficient for both theorems"), :13-15 (trace), :73 ("D10 and D12 limit standalone appendix claims") -->
<!-- COUNT CHECK for the head: D1..D12 = 12 entries: 5 equivalent (D1, D2, D4, D5, D9) + 2 stronger (D3, D8) + 3 safe (D6, D7, D11) + D12 + D10 = 12. -->
<!-- NOTE for the head, "only D10 weaker": the final audit (at 5c3d923) marks TWO entries weaker, D10 (:69) and D12 (:71). D12 was closed afterwards by supNorm_concentration_events (commits 323b228 and f7aa3c6 per the lean/ log; lean/README.md:55), and that addition was audited separately (PolishDocstrings_Astra_2026-11-26.md:3,28, at 7ea4cfc). So "only D10 is weaker" is true of the current tree, and "the final audit found only D10 weaker" would be false. The text above is worded for the current tree. -->

### Build and check

You need [elan](https://github.com/leanprover/elan). It installs the toolchain pinned in `lean/lean-toolchain` (`leanprover/lean4:v4.35.0-rc2`). Mathlib is pinned in `lean/lake-manifest.json`, at revision `065356127b1dc0016f66b7283ce0ce2c4055aa55` (input revision `v4.35.0-rc2`).
<!-- Lean head: the Mathlib rev and inputRev are from lean/lake-manifest.json, and the toolchain from lean/lean-toolchain. Both have been unchanged since 5c3d923. -->
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

With the prebuilt Mathlib, `lake build` takes about 15–20 minutes on 3 cores.
<!-- Lean head: measured 2026-11-26. A from-scratch build of the BQTF modules at 19be187 (lean/ tree = f7aa3c6), Mathlib from the cache, -j 3 on a shared server, took 1046 s ("Build completed successfully (8988 jobs)"). AxiomCheck then printed the standard three axioms for all four theorems. -->

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
| `Gram.lean`, `Falling.lean`, `Smooth.lean`, `Interp.lean`, `SplineApprox.lean` | The polynomial Gram constant (g_r > 0), falling factorials, the smoothed truth (Lemma smooth), the interpolation inequality, spline approximation (Lemma F) |
| `Width.lean`, `Concentration.lean`, `Score.lean` | The width bound, concentration of the empirical process, the score events |
| `SmallBall.lean`, `QuadShift.lean`, `PriorMass.lean`, `Prior/`, `Denominator.lean` | Small-ball probability, the quadratic-shift lemma, prior mass (Proposition prior), the lower bound on the denominator (Lemma evid; `Prior/` holds the prior matrix and smoothing window at which it applies Proposition prior) |
| `Localization.lean`, `Shells.lean` | Localization of the posterior to the set K(ρₙ, Tₙ) (Proposition local), and the bound on the shells outside it (Proposition shell) |
| `Main.lean` | Theorem 1 at σ = 1 |
| `Reduction.lean`, `Scale/` | Theorem 1 at a general scale, by rescaling the data |
| `Joint/` | Theorem 2: the product posterior and its conditioning on the non-crossing set, the gap between levels, sup-norm concentration, transfer, and the two joint theorems (`Joint/Main.lean`) |
| `Prob/` | Efron–Stein, the contraction principle, symmetrization |
| `Lin/` | Eckart–Young, the Gaussian small-ball bound, the Laplace scale mixture |
| `Shift/` | Prékopa–Leindler for the Laplace measure, Rademacher maxima, slice bounds |
| `Asym/` | Helpers for Localization, Shells, Denominator, Theorem 1 and the sup-norm lemma. The 8 files cover asymptotic rate bounds (`Rates`, `LocalRates`, `ShellRates`), the Laplace moment generating function and product integrals (`Laplace`), measurability and exponential integrals of the check-loss increments (`CheckIntegrals`), the local prior mass in polynomial coordinates (`LocalMass`), and continuity, closedness and norm identities (`LocalGeometry`, `Vector`). |
<!-- Lean head: the Localization row is CONFIRMED and made precise. Localization.lean:3 is Proposition pf:prop:local, with K_n = K(ρ_n, T_n) and Ω_G at Localization.lean:5-6. The Asym row is CORRECTED: the old "rates and elementary integrals used throughout" missed LocalMass, LocalGeometry and Vector, and these files feed Localization, Shells, Denominator, Main and Joint/SupNorm, not everything (grep of imports). The Prior/ row was missing: Prior/Geometry (priorMatrix, deltaA_priorMatrix) and Prior/Window (smoothingPower, priorBudget) are imported only by Denominator.lean, which applies prior_mass at that matrix and window. Both files are covered by the PriorMass and Denominator reviews. The Smooth/Falling wording follows the module headers (Smooth.lean:3 "The smoothed truth"; Falling.lean:3 "Falling factorials"). -->
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

<!--
==========================================================================================
LEAN HEAD RESOLUTIONS (2026-11-26). Verdict: CORRECTED (list in the reply to HQ). Signed off once
the build-time line is filled in.

1. COUNTS: confirmed. There are 11 corrections and 12 differences. The classification is 5 equivalent,
   2 stronger, 3 safe (D11 safe because of the gmin lower bound, not because of "B only"), D12
   matching the paper, and D10 weaker.
2. "ONLY D10 WEAKER": approved as worded. The audit at 5c3d923 and the polish review at 7ea4cfc are
   kept separate; see the note under D10.
3. AUDITED COMMIT vs CURRENT TREE: closed. The full build, AxiomCheck and source scan ran on main
   at f64025a, which the README cites. No .lean, lakefile, manifest or toolchain file changed after
   it; f7aa3c6 touched docs and SHA256SUMS only. A from-scratch BQTF build at 19be187, whose lean/
   tree equals f7aa3c6's, repeated AxiomCheck. SHA256SUMS.txt is from f7aa3c6, over the same 58
   sources, and `sha256sum -c` gives all OK. Note that 11 commits touch lean/ after 5c3d923, not 6.
4. FIVE CLASSICAL RESULTS: confirmed, each with the standard 3 axioms. lean/README.md:10 now lists
   all five. The Prékopa–Leindler wording is now "functional form on ℝ, tensorized to the product
   Laplace law" in both READMEs, which is accurate.
5. PINS: filled in. The toolchain is leanprover/lean4:v4.35.0-rc2. Mathlib is
   065356127b1dc0016f66b7283ce0ce2c4055aa55, input revision v4.35.0-rc2. Build time: see the
   Build section.
6. maxHeartbeats: no need to mention it publicly. It raises an elaboration resource limit for one
   declaration, and the kernel still checks the proof (FINAL_AUDIT_astra.md:109).
7. HOME PATHS IN lean/notes/: valid. This is referred to HQ as a separate decision: a doc-only pass
   rewriting absolute paths to repo-relative ones in lean/notes would also edit review reports that
   were committed verbatim. It changes no Lean source and no checksum.
8. INFERRED ROWS: Localization was confirmed and made precise. Asym was corrected. The missing
   Prior/ row was added.
9. REBUILD: done by the Lean head (see 3).
==========================================================================================
-->
`````

---

## 9. Open items

### 9.1 For the owner

| # | Decision | What is known | Recommendation |
|---|---|---|---|
| a | **Rewrite the git history?** | The scrub cleans the current files; old commits keep every path, host name and address. A rewrite changes every commit hash (the hashes quoted in `lean/notes/`, in `PAPER_CORRECTIONS.md` and in run ledgers would need a map), forces every clone to be made again, and does not reach forks or caches made before it. The strings are low-sensitivity identifiers, not credentials. | Not for the paths alone. Worth it only if it is also the way to remove the raw sensor data or the third-party texts, should (c) or (d) require that. |
| b | **Does `literature/Large Prior.pdf` stay public?** | The only PDF tracked under `literature/` (1.3 MB), kept by an explicit exception in `.gitignore`. It is the manuscript of another paper, which has its own public repository with its own PDF. | Replace it by a link to that repository in the reading list. |
| c | **Third-party article texts.** | `paper/history/simulation_revision_20260914/Brantley_2020.txt` (54 KB) and `Onizuka_2023.txt` (95 KB) are extracted texts of published articles; the first carries its authors' addresses. The repository's own rule keeps third-party PDFs out of git. | Remove both from the tip. Whether from history too is decision (a). |
| d | **SPod raw data.** | Seven files, 134 MB, tracked. `applications/Air Quality/DATA.md` has "Source: TODO" and says the files were removed from git; they were not. The README's Data section cannot be written until the source and its redistribution terms are known. | The owner supplies source and terms. If redistribution is not clearly allowed, ship a download note and checksums instead of the files, after E-18. |
| e | **Oversized files after E-18.** | 10 tracked files exceed the 5 MB hook limit (Section 5.3, H2 to H4). | Engineering proposes; the owner approves any that stay. |
| f | **Default b0 in the text.** | `method/README.md:23` says 0.01; both samplers have 1e-5; E-19 may change the default. | Rule once E-19 reports; README and `method/README.md` then say the same. |

Smaller choices, with a default taken in this proposal that the owner can overturn: the H1 is "Bayesian Joint Quantile Trend Filtering" (the alternative is the full paper title); the authors' addresses stay on the paper's title page; the working records stay public and are listed last.

### 9.2 For Engineering

1. Sign off or amend the moves M1 and M2, and say whether O1 and O2 are wanted (Section 5.1).
2. E-20: save the curve file in the schema of Section 2.5, with the crossing summary.
3. E-18: the final commands, times and numbers for the two air-quality rows and the air paragraph; `spod_curves.csv` for the SPod figure; a generator for the `spod_*` figures of the paper if one exists.
4. The fixes F1 to F12 of Section 4.3. F1 to F3 decide whether the scalability row gets a command; F12 decides whether the quick start can say that the tests pass.
5. The hygiene items H1 to H4 (Section 5.3).
6. The scrub (Section 6): the script, the substitution log, the regenerated manifests with their `*.orig` copies, the note.
7. `engineering/README.md` with the working rules that leave the front page.
8. Confirm that `method/admm_qtf/` and the Onizuka add-on hold no adapted third-party code that needs a licence notice, and the licence line for the growth data.
9. Measured times for every `[Eng: time]` cell.

### 9.3 For the Lean head

The Lean section is fact-checked (Section 8); its closing note says it is signed off once the build-time line is filled in, and that line is now filled in. One item is left: confirm the paths-only pass over `lean/notes/` before Engineering runs it (Section 6.3, item 3).

### 9.4 Order of work

1. Now: M1 (after H3 is decided for the Munich draws), H1, `engineering/README.md`, the scrub of docs and of `lean/notes/`.
2. When E-20 delivers: the hero figure, M2, `examples/`.
3. When E-18 and its paper update land: the air-quality cells, the SPod figure, the data decision, then the README goes public. F12 before that, or the test comment stays out.
4. After E-19: the b0 text, O1 if wanted.
5. At paper freeze: table and figure numbers read off the PDF, the timings rechecked, O2 if wanted.

---

## Merge corrections

Numbers and paths that did not hold when rechecked, or that the rulings overturned, and what the merged text uses.

1. **Tracked files.** FABLE has 1,753, the FABLE-side critique 1,757, INVENTORY 1,759. Today: 1,763 at `7550fd1`. INVENTORY's per-folder counts still hold except `writing/` (26 then, 30 now).
2. **Scalability commands.** Both drafts put `benchmark_existing.R` or `build_tables.py` in the "Our work" table. Neither runs as written (F1, F2), and the shipped table body is superseded (F3). The row now has no command (R6).
3. **E-20 column.** FABLE's `signal` is wrong; the column is `truth`, and `method` is required (R3).
4. **Figure layout.** FABLE proposed one wide panel over two; NEON three stacked. The merged hero is one row of two panels, and SPod is a separate figure (R3).
5. **Colours and sizes.** Both drafts carried their own hex values. The merged spec is the one in `figures/README.md`, which is what the script uses.
6. **Growth share.** NEON wrote "~0.80" and FABLE left a placeholder. Recomputed from the tracked files: 0.8051 for boys (4,817 children, 220 grid ages) and 0.8025 for girls (5,190 children, 221 grid ages).
7. **Caption precision.** FABLE's rule 1 asks for two decimals. The script prints one decimal of a percentage in the panel (80.5%), and the caption now matches the panel, so that image and caption never disagree. The intent of the rule is kept: the computed value, never "about 80%".
8. **Lean build time.** NEON's "~15 min" is the LP repository's time (I read it on the LP front page). Replaced by the Lean head's measured time, about 15–20 minutes on 3 cores with the prebuilt Mathlib, in the "Our work" row and the quick start.
9. **Appendix letters.** NEON's "Appendix C" for simulations and "Appendix D" for growth are wrong. Simulations are Appendix D and the real-data figures Appendix E (`paper/main.tex:84-88`).
10. **Air quality.** NEON merged the simulation and the SPod application in one sentence and explained ADMM's behaviour at τ = 0.01 with a fact from the application. Split into two sentences with placeholders (R2). In the current paper table ADMM is ahead at τ = 0.01 (0.0302 against 0.0461), so "better at τ = 0.01" exists only in the refit.
11. **Joint against single-level.** NEON's "lowers MSE relative to single-level fits" is not supported. `simulations.tex:98` supports only: smaller MSE than our individual sampler in every configuration but two (R2).
12. **Shared factorization.** NEON's "and the proposal draw" is dropped. The merged computing paragraph makes no claim about shared factorizations.
13. **"Credible bands" on the front page.** FABLE's method paragraph said every fit "comes with credible bands" and that the band between two curves is "always a valid band for the data". Both phrases are removed (R2: no interval claim anywhere). The paragraph now says only that the joint draws never cross.
14. **Lean numbers in FABLE.** "About 16,200 lines" is 16,960 lines in the 56 files under `lean/BQTF/`. "Six later commits" after the audited commit is 11. LEAN_SECTION's own list of polish commits omitted one.
15. **Lean section.** Section 8 is the Lean head's corrected text (commit `7b61442`), verbatim. It replaces R8, and none of my own corrections is applied to it. Against the earlier draft it changes: the verified build cited at `f64025a`; Theorem 1 with total variation of order r = k + 1 at most V̄; D10 (only C_E and C_pr are existential, the quad-shift coefficient is an explicit constant); D11 reworded; five classical results with qualified names; a `Prior/` entry in the module map; the Mathlib revision and the build time; the wording on review coverage. `lean/README.md:10` now lists all five results. The rest of this proposal was checked against these points.
16. **Sealed manifests.** FABLE's "5 manifests under `experiments/interior_quantiles/`" is 4 `SHA256SUMS` files (the fifth file is the hash of a tarball). FABLE's "275 files / about 79 sealed" and NEON's "294 files" are replaced by INVENTORY's 306 + 37 and 81 (R7).
17. **Privacy counts, my own recheck.** Home paths in 202 files: reproduced exactly. For the totals, a single case-insensitive regex of my own over the same file set gives 314 files where INVENTORY has 306, and 43 Windows-only files where INVENTORY has 37 (50 files with a Windows user path against 44, counting both slash styles). INVENTORY excludes title-page addresses and matches inside hash strings and does not print its exact expressions, so I could not reproduce its totals to the file. The merged text carries INVENTORY's counts as ruled; the scrub script's own log will give the final number, and the difference is at most 14 files.
18. **Sizes.** NEON's "~140 MB" for the SPod files and "10.8 MB" for the monitor log are decimal megabytes; INVENTORY and the rulings use binary ones (134 MB, 10.3 MB; Munich draws 115 MB). The merged text uses the binary values throughout. Note that `experiments/README.md:30` itself says "10.8 MB".
19. **Move lists.** M1: `applications/README.md` references Munich at lines 9, 18 and 19 (the drafts gave 9 and 18). O1: the E-03 folder has 3 files that name `experiments/pilots`, not 4. O2: the reference is at `paper/README.md:23`. M2: the script finds the repository root three levels up (`make_readme_figures.R:29`), which must become two at `examples/readme_figures/`, and its default E-20 folder `engineering/E20_Showcase/` does not exist; neither draft had these.
20. **LP repository claims.** NEON's citations of LP files were not checked by the critique. I checked the front page, `simulations/common.R` (the grid, axis, label and blue hex values NEON quotes are there), `CITATION.cff` (affiliations and `preferred-citation` are there) and the licence paragraph. I did not check NEON's `lightsteelblue` and `adjustcolor` details, and the merged text does not carry them.
21. **NEON's "E-20 under `engineering/`" and "`e13.slurm` to `e18.slurm`".** No `engineering/E20*` folder is tracked, and E-16 has no Slurm file. Not carried.
22. **"R 4.4.1 to 4.6.0 tested".** No file states a tested range. The merged text says "R 4.4 or later", as `method/README.md` does.
23. **`Growth_Joint_checks.R`.** FABLE called it code "that the paper's growth fit uses". It is a test harness for the joint growth script, and that script is not the paper's fit. The scrub plan now describes it as a script with a Windows fallback path.
24. **Second third-party text.** FABLE flagged `Brantley_2020.txt` only; `Onizuka_2023.txt` is in the same folder (R7).
25. **Found at the merge, in neither draft.** (i) `paper/README.md` says 11 section files; there are 15 (F11). (ii) Six tracked files under `writing/W08_Repo/` carry personal or machine strings and were outside INVENTORY's scan (Section 6.3, item 6). (iii) The Munich folder has its own two checksum files, which move with it, and its 115 MB of draws should be decided before M1 (Section 5.1). (iv) `spod_curves.csv`, which the E-18 README announces, is not tracked yet.
26. **Sampler tests.** Both drafts wrote that the individual test "ends with all tests passed", taken from `method/README.md:14`. I ran it twice (from the root and from `method/individual/`): it fails at test 7 both times, with identical numbers. The joint `test_prox` could not finish because `clarabel` is not installed here. Details in Section 4.2; item F12 for Engineering. One slip of mine to record: the one-line check that `clarabel` is missing was run with plain `Rscript -e`, not through the job wrapper.
