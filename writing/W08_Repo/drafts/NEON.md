# W-08 Public-Repository Arrangement Proposal (NEON)

**Scope.** Proposal only for `/home/fb31/Bayesian-Quantile-Trend-Filtering` (public on GitHub). No repository files have been moved, edited, or deleted. All claims, file paths, cross-references, and privacy findings below were verified directly against `git ls-files`, `git grep`, and `FbStatsQuant/Large-Prior-Official-Repo` on 2026-11-26. **Engineering is the repository steward and must sign off every file move, removal, or script edit before execution.** No manuscript content in `paper/` is modified by this proposal.

---

## 1. README Outline and Draft Text

The layout follows [`FbStatsQuant/Large-Prior-Official-Repo`](https://github.com/FbStatsQuant/Large-Prior-Official-Repo): badges, title and authors (no personal emails), **"The main idea behind this project"** in three tight paragraphs (method, theory, computing/results), the multi-panel hero figure with a one-line italic caption, **"Our work"** reproduction table, shipped reference outputs, a dedicated **"Formal verification in Lean 4"** section (authored by FABLE in `drafts/LEAN_SECTION.md`), quick start and requirements, repository structure (public core first, internal record de-emphasized last), data, and citation/license. Plain, concrete prose; no hype words.

### Full Draft Text: Title, Badges, Authors, and "The main idea behind this project"

```markdown
# Bayesian Joint Quantile Trend Filtering

[![R >= 4.4](https://img.shields.io/badge/R-%3E%3D%204.4-276DC3)](https://www.r-project.org/)
[![Lean 4](https://img.shields.io/badge/Lean-v4.35.0--rc2-0f4c81)](https://lean-lang.org/)
[![License: MIT](https://img.shields.io/badge/license-MIT%20%28paper%3A%20all%20rights%20reserved%29-lightgrey)](#citation-and-license)

This repository contains the samplers, simulation and application code, manuscript, and Lean 4 proofs for **Bayesian Joint Quantile Trend Filtering via Proximal MCMC with Sequential Gibbs Sampling**, by Felipe Bedoya (Department of Statistics, Rice University), Meng Li (Department of Statistics, Rice University), and Eric C. Chi (School of Statistics, University of Minnesota).

## The main idea behind this project

Quantile trend filtering estimates a conditional quantile curve along an ordered domain by combining the check loss with an $\ell_1$ penalty on $(k+1)$-th discrete differences, but it returns a point estimate and requires selecting the penalty in advance. We construct a Bayesian counterpart using an asymmetric Laplace working likelihood and a global Laplace prior on the trend differences, placing conjugate priors on both the penalty $\lambda$ and the likelihood scale $\sigma$. Through the normal–exponential mixture representation of the asymmetric Laplace distribution, the conditional negative log-posterior of the trend becomes a weighted quadratic plus the exact $\ell_1$ difference penalty. We therefore update the trend with an exact proximal Metropolis–adjusted Langevin (P-MALA) step built on the entire conditional posterior—a weighted trend filtering problem rather than a smoothed check loss—with an exact Metropolis–Hastings correction and conjugate/interwoven updates for the latent variables, penalty, and scale ([`method/individual/`](method/individual)). To estimate several quantile levels together without crossing, the joint sampler ([`method/joint/`](method/joint)) updates each trend conditional on lying between its neighbouring curves; only the proximal map changes, becoming a box-constrained problem, so no retained draw or posterior-mean curve crosses by construction, and any pair of estimated quantiles defines a valid band around the series everywhere.

On the theory side, Theorem 1 establishes posterior contraction around the true conditional quantile at the rate $n^{-(2k+1)/(2k+2)}$ in the $\Delta_n^2$ loss for any fixed scale $\sigma_0 > 0$ and deterministic penalty $\lambda = c\,n^{(2k+1)/2}$, under local lower and upper bounds on the data distribution functions near the quantile and without assuming the data follow the asymmetric Laplace working likelihood. Theorem 2 extends the same contraction rate simultaneously to all $J$ levels of the non-crossing joint posterior with no additional separation assumption. Both theorems—at unit scale and at general fixed scales, together with every supporting classical inequality—are formally verified in Lean 4 with Mathlib in [`lean/`](lean), with zero `sorry`, only Lean's three standard axioms, and an independent final audit rated CLEAN (see [Formal verification in Lean 4](#formal-verification-in-lean-4)).

On the computing side, every linear system in the sampler is banded with half-bandwidth $k+1$. In the individual sampler, ADMM shares a single banded factorization across the forward and reverse proximal maps and the proposal draw; in the joint sampler, active box constraints are solved by banded primal–dual interior-point steps. The cost per Gibbs sweep therefore grows linearly in $n$: on one laptop core, a sweep of Bayesian-PMALA takes 2.0 ms at $n = 250$ and 36.6 ms at $n = 4{,}000$, roughly 25× faster per sweep than the dense Gibbs implementation of Onizuka et al. (2024) at $n = 250$ and roughly 7,000× faster at $n = 4{,}000$. In simulations and fenceline air-quality monitoring ([`experiments/air_simulation/`](experiments/air_simulation), [`applications/Air Quality/`](applications/Air%20Quality)), Bayesian-PMALA is competitive with ADMM-based quantile trend filtering at $\tau \in \{0.05, 0.10\}$ ([E-18: MSE at tau = 0.05 and 0.10]) and improves on ADMM at $\tau = 0.01$ ([E-18: MSE and baseline comparison at tau = 0.01]), where eBIC selects an overly small penalty that bends into emission plumes and crosses higher quantiles, while outperforming locally adaptive horseshoe and Laplace Gibbs samplers on peak-free baseline recovery ([E-18: MSE and CAA summary]). At extreme upper quantiles ($\tau \in \{0.90, \dots, 0.99\}$), the joint sampler eliminates crossings and lowers MSE relative to single-level fits.
```

### Outline of the Remaining README Sections

1. **Hero figure + one-line italic caption** (placed immediately below the three paragraphs, matching `Large-Prior-Official-Repo`).
   - Rendered by Writing (`writing/W08_Repo/figures/make_readme_figures.R`) from Engineering's saved E-20 / E-18 curves and the shipped joint Growth fit (see Section 3).
2. **`## Our work`**
   - One-sentence intro separating local verification (seconds–minutes) from cluster campaigns whose sealed summaries ship in the repo.
   - Reproduction table:

| In the paper | Folder | How to run | Time |
|---|---|---|---|
| §2: Individual and joint non-crossing samplers | [`method/`](method) | `Rscript method/individual/Individual_Sampler_PMALA_Augmented.R test`; `Rscript method/joint/Joint_Sampler_PMALA_Augmented.R test_prox` | ~100 s (`test`); minutes for a 30k-sweep pilot |
| §3 & Appendix A: Theorems 1 and 2 (Lean 4 / Mathlib proofs) | [`lean/`](lean) | `cd lean && lake exe cache get && lake build && lake env lean AxiomCheck.lean` | ~15 min with Mathlib cache |
| §4.1 & Appendix C: Interior & extreme-quantile simulations (Tables 1–4) | [`experiments/interior_quantiles/`](experiments/interior_quantiles), [`experiments/extreme_quantiles/`](experiments/extreme_quantiles), [`experiments/joint_upper_levels/`](experiments/joint_upper_levels) | Frozen Slurm packages (`bash submit.sh RUN_NAME`); summary tables and builders shipped in each folder | Cluster campaigns (300–3,000 tasks); shipped tables inspectable immediately |
| §4.2: Computational cost scaling (Table 5, Figures 1–2) | [`experiments/scalability/`](experiments/scalability) | Shipped timings and LaTeX body in `timings.csv`, `table_cost_scaling_body.tex`; `python3 build_tables.py` | Seconds from shipped timings (standalone figure generator is an open item) |
| §4.3: Air-quality peak-detection simulation (Table 6, refit under E-18) | [`experiments/air_simulation/`](experiments/air_simulation) | `Rscript drivers/individual_air_sim.R`, `drivers/admm_air_sim.R` (`[E-18: final refit driver and summary path]`) | Hours locally / cluster (`[E-18: core-hours]`) |
| §4.4: SPod fenceline air-quality baseline (`n = 8,640`) | [`applications/Air Quality/`](applications/Air%20Quality) | `[E-18: Stage 2' prepared-data fit and plotting command]` | `[E-18: wall time per level]` |
| §4.4 & Appendix D: Dutch growth centiles (`n = 4,817` boys, `5,190` girls; joint non-crossing fit shipped alongside paper's independent-level figures) | [`applications/Growth/`](applications/Growth) | `cd applications/Growth && Rscript Growth_plots_k2.R` (redraws shipped joint fit) or `Rscript Growth_Joint_PMALA_k2.R sex=boy` | Seconds to redraw; minutes–hours to refit |
| The manuscript itself | [`paper/`](paper) | Read [`paper/main.pdf`](paper/main.pdf), or `cd paper && latexmk -pdf main.tex` | Seconds to compile |

3. **Shipped reference outputs** (short bullet list modeled on `Large-Prior-Official-Repo`):
   - Summarizes what runs/redraws immediately without cluster compute (`method/` unit & exactness checks, `lean/` axiom & SHA-256 verification, Writing's README figure from Engineering's saved curves, `applications/Growth/results_joint_k2/`, sealed summary CSVs/tables in `experiments/`), and candidly flags current open items (missing standalone generators for `scal_*.pdf`, `nile_*`, `growth_lms_*`; E-18 refit pending).
4. **`## Formal verification in Lean 4`** *(dedicated section — drop-in slot for FABLE's `writing/W08_Repo/drafts/LEAN_SECTION.md`)*
   - Placed directly after `## Our work` / reference outputs and before `## Quick start` so visitors see the headline contribution in full before setup instructions.
   - Covers: Theorems 1 & 2 (`main_theorem`, `main_theorem_scale`, `joint_theorem`, `joint_theorem_scale`), trust story (`AxiomCheck.lean`, standard axioms only, zero `sorry`, CLEAN independent audit), classical results proved from scratch, the 11 paper corrections (`C-01`..`C-11`), honest differences `D1`–`D12`, build/check/checksum commands, and module map (fact-checked by the Lean department head).
5. **`## Quick start and requirements`** (full draft text in Section 4).
6. **`## Repository structure`** (public core folders first; internal project record de-emphasized in a brief secondary note—see Section 3).
7. **`## Data`** (Growth dataset from `mice`/Fifth Dutch Growth Study; SPod provenance and SHA-256 manifest in `applications/Air Quality/DATA.md`; external archive note with no personal paths or usernames).
8. **`## Citation and license`** (`CITATION.cff`, MIT for software in `LICENSE`, manuscript under `paper/` all rights reserved until publication, third-party data under providers' terms; "Questions or problems? Please open an issue.").

---

## 2. What We Take from the LP Repo (`Large-Prior-Official-Repo`)

We inspected the entire [`FbStatsQuant/Large-Prior-Official-Repo`](https://github.com/FbStatsQuant/Large-Prior-Official-Repo) tree—including root `README.md`, `CITATION.cff`, `LICENSE`, `sampler/README.md`, `simulations/README.md`, `simulations/benchmarks/README.md`, `simulations/scaling/README.md`, `simulations/common.R`, `simulations/benchmarks/make_figure.R`, `applications/README.md`, `applications/code/make_figure.R`, `paper/README.md`, `lean/README.md`, and `lean/docs/statements.md`.

### Adopt (bring over directly)

- **Root README rhythm and plain voice (`README.md`):** Badges → one-sentence project summary → three tight paragraphs ("The main idea behind this project": method, theory, computing) → multi-panel hero figure with one-line italic caption → `"Our work"` table (`In the paper | Folder | How to run | Time`) → shipped `reference_outputs/` bullet list → Requirements → Data → Citation & license. Zero hype words, concrete numbers, honest caveats.
- **Per-folder README convention (`sampler/README.md`, `simulations/*/README.md`, `applications/README.md`, `lean/README.md`):** Open each folder README with a one-line italic provenance subtitle (e.g., `*Section 2 · Algorithms 1–2*`, `*Section 4.4 · Figure 6*`), a compact settings/files overview, copy-paste runnable commands, and an explicit `> **Scope.**` caveat block in `method/README.md` (mirroring `sampler/README.md`).
- **Separated fitting vs. plotting with `--from=reference_outputs` (`applications/code/make_figure.R`, `simulations/benchmarks/make_figure.R`):** Keep plotting scripts strictly free of MCMC fitting; ship tiny summary CSVs and the rendered PNG/PDF in `reference_outputs/` (never raw chains) so any reader can redraw figures in seconds via `--from=reference_outputs`.
- **Visual grammar and dual Cairo output (`simulations/common.R`, `applications/code/make_figure.R`):** White background, sans-serif typography, clean `#E6E6E6` gridlines, `#4D4D4D` axes, `#222222` labels, deep blue (`#2457A6`) + light steel-blue (`#B0C4DE` / `lightsteelblue`) palette, semi-transparent white in-panel stat badges (`adjustcolor("white", 0.82)`), `grid` viewports for multi-panel layout (no `patchwork`/`cowplot` dependency), and dual 300-dpi PNG + vector Cairo PDF export.
- **Rich `CITATION.cff` (`CITATION.cff`):** Add author `affiliation` fields and a `preferred-citation` block pointing to the manuscript (our current `CITATION.cff` omits both).
- **Lean transparency pair (`lean/README.md`, `lean/docs/statements.md`, `lean/AxiomCheck.lean`, `lean/SHA256SUMS.txt`):** Already adopted in BQTF's `lean/`; keep exact parity and add `SHA256SUMS.txt` discipline wherever reference outputs are shipped.

### Adapt (modify for BQTF's realities)

- **Dedicated Lean section in the root README:** LP summarizes Lean in one bullet and one table row in root `README.md`, leaving details to `lean/README.md` (and notes that classical approximation inputs enter as explicit hypotheses). BQTF's formalization proves *every* classical inequality from scratch with zero extra hypotheses, passed an independent CLEAN final audit, and caught 11 paper corrections (`C-01`..`C-11`)—so we elevate Lean to a dedicated root README section (`drafts/LEAN_SECTION.md`).
- **Hero figure semantics (`applications/code/make_figure.R`):** LP plots posterior means + 95% credible bands around mean functions. In BQTF, the headline visual is **non-crossing quantile bands formed by the estimated quantile curves themselves** (joint sampler, E-20), with dark-blue observations on top, dotted noiseless signal, and an in-panel empirical coverage note (`≈ 0.80`, nominal `0.80`).
- **Reproducibility expectations (`simulations/scaling/README.md`):** LP has two sub-minute local studies (`recovery/`, `benchmarks/`) and one cluster study (`scaling/`). Most of BQTF's simulation tables are 300–3,000-task Slurm campaigns stored as frozen SHA-256 packages; adapt LP's `scaling/` pattern across `experiments/` (highlight shipped summary CSVs/tables + fast local unit tests and pilots rather than implying full tables rerun on a laptop).
- **Data provenance without personal paths (`applications/README.md`):** Keep LP's clear separation of license (MIT code vs. third-party data terms) and SHA-256 input manifests (`applications/Air Quality/DATA.md`), while replacing internal PC/NOTS notes with clean public archival statements.

### Doesn't fit us (do not copy)

- **Deleting internal history/department folders (`LP` has only 5 top-level folders):** LP was assembled as a fresh release tree with older drafts only in git history. BQTF has active NOTS tasks (E-18, E-19), audited `theory/` notes cited inside hashed Lean sources (`lean/BQTF/Gram.lean`), and an explicit constraint to *de-emphasize, not delete* department folders.
- **GPL-3 dual licensing on `sampler/` (`sampler/LICENSE`):** LP's `sampler/` adapts GPL-3 code from `horseshoe` 0.2.0. BQTF's `method/` samplers and C++ kernels are original MIT-licensed code; keep a single MIT code license + "all rights reserved" manuscript notice.
- **Nesting the paper inside `paper/Overleaf/` (`paper/README.md`):** BQTF already has `paper/main.tex`, `paper/sections/`, and `paper/figures/` cleanly at `paper/`, and `paper/` is immutable under W-08.
- **Standalone `--quick` flag across frozen Slurm packages:** Retrofitting `--quick` into frozen `SHA256SUMS`-sealed NOTS packages in `experiments/` would invalidate their checksums. Reserve `--quick` / `--from=reference_outputs` for new/canonical scripts (`method/`, `writing/W08_Repo/figures/`).

---

## 3. Hero Figure Plan: Panels, Visual Grammar, and Captions

**Ownership split (owner ruling).** Engineering supplies the saved curves (E-20 for the VS $n = 1{,}000$ joint fit; E-18 Stage 2′ for SPod). **Writing renders the README figures itself** via `writing/W08_Repo/figures/make_readme_figures.R` (authored by a separate Writing worker). This section therefore specifies the panels, visual encoding, and captions only.

### Core Concept: Non-Crossing Quantile Bands Around the Series

The hero visual showcases the **joint non-crossing sampler** (`method/joint/`) using the **estimated quantile curves themselves** to form a shaded band around the series ("so the whole series has its own CI, so to speak"). Because the joint sampler enforces $\theta_{i,1} \le \cdots \le \theta_{i,J}$ on every retained draw, the quantile curves never cross and the band is valid everywhere by construction. Per-curve 95% credible bands are **not** shown by default (optional faint variant only).

### Layout: 3-Panel Stacked Figure (`3 × 1`)

Matching `Large-Prior-Official-Repo` (`applications/reference_outputs/applications_fig.png`, white background, clean sans-serif typography, `#E6E6E6` gridlines, `#222222` labels, LP-style translucent white in-panel stat badges), we propose a 3-panel vertical stack sharing one cohesive blue-on-white palette:

| Panel | Dataset / Fit | Visual design (panels & encoding) | Provenance & caption guardrails |
|---|---|---|---|
| **(a) Hero panel — VS benchmark, $n = 1{,}000$ (E-20 FINAL SPEC)** | Varying-smoothness signal $f_{\mathrm{VS}}(u)$ (`eq:sim_vs`), $n = 1{,}000$, heteroscedastic Normal errors $\varepsilon_i \sim \mathcal{N}(0, s(u_i)^2)$ with $s(u) = (1+u^2)/4$, $k = 2$; **joint non-crossing sampler** at $\tau \in \{0.10, 0.90\}$ | **Light-blue shaded band** (`#BFD7ED`, `alpha ≈ 0.72`) between the estimated $\hat\theta_{0.10}$ and $\hat\theta_{0.90}$ curves (thin steel-blue boundary lines `#3B6FA8`); **dark-blue observed points $y_i$ on top** (`#163A6B`); **true noiseless signal $f_{\mathrm{VS}}(u)$ dotted** (`#1A1A1A`); in-panel note reporting the empirical fraction of points inside $[\hat\theta_{0.10}, \hat\theta_{0.90}]$ (about `0.80`, nominal `0.80`) and `0 crossings` | Saved curves produced by Engineering under **E-20**; curves cannot cross by construction |
| **(b) SPod fenceline air-quality baseline (`[E-18]`)** | EPA Rubbertown SPod sensor `d`, June 15, 2018 ($n = 8{,}640$ 10-second block means), $k = 2$. **Fits exist only at $\tau \in \{0.01, 0.05, 0.10\}$ (no $\tau = 0.90$).** | Shows the **low baseline beneath the transient emission plumes**—either as the **light-blue $\tau = 0.01$–$0.10$ baseline band** (recommended for visual consistency with Panels a and c, with $\hat\theta_{0.05}$ drawn inside and $\hat\theta_{0.01}$ highlighted) or as the single **$\tau = 0.05$ baseline curve**—with the dark-blue observed PID spikes rising above it and an in-panel note giving the empirical fraction below the baseline (`[E-18: frac_below]`) | Saved curves from **E-18 Stage 2′**; keep `[E-18: ...]` placeholders until Stage 2′ closes |
| **(c) Dutch boys' growth centiles (joint non-crossing fit)** | Fifth Dutch Growth Study, boys ($n = 4{,}817$, $G = 220$ age slots at 0.1-year spacing, $k = 2$); **tracked joint-sampler fit** at $\tau \in \{0.10, 0.30, 0.50, 0.70, 0.90\}$ (`b0 = 0.01`, 30,000 sweeps, 10,000 burn-in) | Nested **quantile-band fan**: **light-blue outer 80% band** $[\hat\theta_{0.10}, \hat\theta_{0.90}]$ (`#D2E3F4`) and slightly deeper **inner 40% band** $[\hat\theta_{0.30}, \hat\theta_{0.70}]$ (`#9EC2E6`) with a crisp median $\hat\theta_{0.50}$ (`#0F2747`), **dark-blue measurements on top** (`#163A6B`, small & semi-transparent), and an in-panel note giving the empirical fraction inside $[\hat\theta_{0.10}, \hat\theta_{0.90}]$ (`~0.80`, nominal `0.80`) and `0 crossings` | **Already shipped:** `applications/Growth/data/fdgs.csv` & `applications/Growth/results_joint_k2/boy/posterior_summary.csv`. **CRITICAL:** this is a *joint-sampler fit whose curves cannot cross*, **NOT** the independent-level run behind the paper's Figure 5 (`growth_pmala_boys.pdf`)—never caption it as "Figure 5 of the paper" |

> **Interim fallback (before E-18 Stage 2′ finishes):** Render a **2-panel (`2 × 1`) figure** with Panel (a) E-20 VS $n = 1{,}000$ and Panel (b) the joint-sampler Dutch boys' growth centiles, then add the SPod panel once E-18 Stage 2′ saves its curves.

### Captions

- **One-line italic README caption (3-panel):**
  > *Non-crossing quantile bands and baselines from Bayesian-PMALA ($k = 2$): (a) joint-sampler fit on the varying-smoothness benchmark ($n = 1{,}000$, Normal errors) with the $[\hat\theta_{0.10}, \hat\theta_{0.90}]$ band in light blue, observations in dark blue, and the true noiseless signal dotted (`[E-20: frac_in]` inside, nominal `0.80`, zero crossings); (b) SPod fenceline air-quality baseline ($\tau \in \{0.01, 0.05, 0.10\}$, $n = 8{,}640$, `[E-18: prior note]`) beneath the emission plumes; and (c) joint-sampler growth centiles for 4,817 Dutch boys (`b0 = 0.01`, 30,000 sweeps) showing the non-crossing outer 80% and inner 40% bands.*
- **In-figure panel titles (left-aligned):**
  - `(a) Varying-smoothness signal (n = 1,000, Normal errors): joint non-crossing 80% quantile band (τ = 0.10 to 0.90)`
  - `(b) SPod fenceline air-quality series (n = 8,640): low-quantile baseline beneath emission plumes (τ = 0.01 to 0.10)`
  - `(c) Dutch boys' height centiles (n = 4,817): joint non-crossing fit (τ = 0.10 to 0.90; zero crossings)`

*(Rendering parameters—dimensions, DPI, Cairo output, hex values above—are passed to Writing's `writing/W08_Repo/figures/make_readme_figures.R`; PNG stays well under the 5 MB pre-commit hook limit.)*

---

## 4. Folder Arrangement: Public vs. Internal

### Design Principle: Clean Public Surface, Zero Risk to Active Campaigns or Checksums

The repository currently has **10 tracked top-level directories** (`applications/`, `archive/`, `engineering/`, `experiments/`, `lean/`, `literature/`, `method/`, `paper/`, `theory/`, `writing/`), plus git-ignored local folders (`ops/`, `runs/`, `tmp/`).

We evaluated consolidating the 5 internal/project-record folders (`theory/`, `engineering/`, `writing/`, `archive/`, `literature/`) under one `internal/` folder versus keeping them at their current paths and de-emphasizing them in `README.md`. **We recommend keeping those 5 folders in place (listed last under a brief "Project record" note in `README.md`) and executing only 2 minimal, low-risk cleanup moves** (`applications/Munich Rent/` → `archive/munich_rent/analysis/` and `experiments/pilots/` → `archive/pilots/`).

**Why not move `engineering/`, `theory/`, `writing/`, `archive/`, or `literature/` now?**
1. **Live Slurm pipelines:** `engineering/` is hardcoded in 90+ scripts including in-flight NOTS work (E-18 Stage 2′, E-19, E-20) and Slurm launchers (`e13.slurm`–`e18.slurm`). Moving it now breaks active runs.
2. **Hashed Lean sources:** `lean/BQTF/Gram.lean:9` cites `theory/T10_gr_positivity/NOTE.md` inside a file covered by `lean/SHA256SUMS.txt`. Editing it invalidates the audited checksums.
3. **Immutable manuscript:** `paper/sections/theory.tex:2` cites `writing/W03_Theorem/theorem.tex`, and `paper/` must not be modified.
4. **Minimal-move mandate:** Listing the 5 internal folders last in `README.md` de-emphasizes them cleanly without breaking a single script, checksum, or TeX build. *(Optional Phase 2, only after E-18/E-19/E-20 close and paper submission: Engineering may revisit consolidating `theory/`, `engineering/`, `writing/` if desired.)*

### Proposed Top-Level Tree

```text
Bayesian-Quantile-Trend-Filtering/
│
├── README.md                  # Public landing page (badges, 3-para idea, hero figure, Our work, Lean, Quick start)
├── CITATION.cff               # GitHub citation metadata (add affiliations + preferred-citation, per LP)
├── LICENSE                    # MIT for code (paper/ all rights reserved)
│
├── method/                    # [PUBLIC CORE] Canonical samplers (run these)
│   ├── individual/            #   Single-quantile exact P-MALA + banded ADMM C++ kernel
│   ├── joint/                 #   Non-crossing joint P-MALA + banded box-IPM C++ kernel
│   └── admm_qtf/              #   ADMM quantile trend filtering baseline
│
├── lean/                      # [PUBLIC CORE] Machine-checked Lean 4 / Mathlib proofs (Theorems 1 & 2)
│   ├── BQTF/                  #   Formalization modules (Spec.lean, Main.lean, Joint/, ...)
│   ├── AxiomCheck.lean        #   Type + standard-axiom verification script
│   ├── docs/statements.md     #   Plain-math correspondence with the paper
│   └── SHA256SUMS.txt         #   Source checksums
│
├── paper/                     # [PUBLIC CORE] Manuscript (main.tex, sections/, figures/, main.pdf; untouched)
│
├── experiments/               # [PUBLIC CORE] Paper simulation studies & benchmarks (pilots/ moved to archive/)
│   ├── interior_quantiles/    #   §4.1 interior-level campaigns (VS & S, n = 500)
│   ├── extreme_quantiles/     #   §4.1 extreme upper quantiles (0.90–0.99)
│   ├── joint_upper_levels/    #   §4.1 six-level joint run
│   ├── air_simulation/        #   §4.3 peak-detection simulation (E-18 refit pending)
│   └── scalability/           #   §4.2 linear-in-n sweep timing benchmark
│
├── applications/              # [PUBLIC CORE] Paper real-data analyses (Munich Rent moved to archive/)
│   ├── Air Quality/           #   §4.4 SPod fenceline sensor data manifest & E-18 baseline analysis
│   └── Growth/                #   §4.4 Dutch children's height centiles (data, joint fit, plots)
│
│   ── Project record & internal workspace (kept for provenance, de-emphasized at bottom of README) ──
├── theory/                    # Proof development memos & audits (T-01 ... T-10)
├── engineering/               # Compute campaigns, diagnostics & repo tooling (E-02 ... E-20)
├── writing/                   # Manuscript & README drafting records (W-01 ... W-08)
├── literature/                # Reading list with DOI/arXiv links (third-party PDFs git-ignored)
└── archive/                   # Superseded analyses (munich_rent/, pilots/, archived_campaigns.md)
```

*(Git-ignored local directories `ops/`, `runs/`, `tmp/` are untracked and omitted from the public README tree.)*

---

## 5. Usage / Quick Start Section (Draft Text for README)

Verified against `README.md`, `method/README.md`, `method/individual/Individual_Sampler_PMALA_Augmented.R`, `method/joint/Joint_Sampler_PMALA_Augmented.R`, `applications/Growth/Growth_Joint_PMALA_k2.R`, `applications/Growth/Growth_plots_k2.R`, `lean/README.md`, and `paper/README.md`.

> **Steward note on defaults:** `method/README.md` currently documents `b0 = 0.01`, whereas `method/individual/Individual_Sampler_PMALA_Augmented.R:87` and `method/joint/Joint_Sampler_PMALA_Augmented.R:110` currently set `a0 = 1, b0 = 1e-5` (E-08), and E-19 may update the default prior. Engineering should sync `method/README.md` once E-19 closes.

```markdown
## Quick start

### Requirements

- **R (>= 4.4)** with a C++17 compiler and the packages `Rcpp`, `RcppArmadillo`, `glmgen`, and `Matrix` (tested on R 4.4.1–4.6.0).
  - Joint box-prox unit tests also require `clarabel`.
  - Redrawing the overview and growth figures requires `ggplot2` (and Cairo graphics support for PDF/PNG).
  - The C++ kernels (`prox_admm_metric.cpp`, `prox_box_metric.cpp`) compile automatically via `Rcpp::sourceCpp` on first run.
- **Lean 4 (optional, to verify the proofs):** install [elan](https://github.com/leanprover/elan), which fetches the pinned toolchain (`leanprover/lean4:v4.35.0-rc2`) and Mathlib revision in `lean/lake-manifest.json`.
- **LaTeX (optional, to recompile the paper):** TeX Live with `algorithmicx` (`algpseudocode`), `bbm`, and `bbold`.

### 1. Run and test the samplers

```sh
# Individual sampler: unit tests (~100 s; prints "all tests passed")
Rscript method/individual/Individual_Sampler_PMALA_Augmented.R test

# Individual sampler: pilot fit on simulated data (edit the Settings block at the top of the file)
# Writes plots and summaries to method/individual/results_pmala_aug/ (git-ignored)
Rscript method/individual/Individual_Sampler_PMALA_Augmented.R

# Joint non-crossing sampler: box-prox optimization kernel tests (requires clarabel)
Rscript method/joint/Joint_Sampler_PMALA_Augmented.R test_prox

# Joint non-crossing sampler: pilot fit (writes to method/joint/results_joint/, git-ignored)
Rscript method/joint/Joint_Sampler_PMALA_Augmented.R
```

*Compiler note for bitwise tests:* Some tests in `method/joint/` assert exact bitwise identity between the unconstrained and free-box kernels. On compilers that contract floating-point expressions into FMA instructions by default (e.g., GCC 14), this can differ by ~`2e-16`. To reproduce the bitwise checks on such toolchains, disable FP contraction via a user `Makevars`:

```sh
printf 'CXXFLAGS=-O2 -ffp-contract=off\nCXX17FLAGS=-O2 -ffp-contract=off\n' > /tmp/Makevars.nofma
R_MAKEVARS_USER=/tmp/Makevars.nofma Rscript method/joint/Joint_Sampler_PMALA_Augmented.R test_prox
```

### 2. Redraw figures from shipped fits (seconds)

```sh
# README overview figure (rendered by Writing from Engineering's saved E-20 / E-18 curves and shipped joint Growth fit)
Rscript writing/W08_Repo/figures/make_readme_figures.R

# Dutch growth centiles: redraws the shipped joint non-crossing fit in applications/Growth/results_joint_k2/
cd applications/Growth && Rscript Growth_plots_k2.R
```

To refit the Dutch growth centiles from scratch (minutes to hours locally):

```sh
cd applications/Growth
Rscript Growth_Joint_PMALA_k2.R sex=boy
Rscript Growth_Joint_PMALA_k2.R sex=girl
Rscript Growth_plots_k2.R
```

### 3. Verify the Lean 4 proofs

```sh
cd lean
sha256sum -c SHA256SUMS.txt    # confirm source files match the audited snapshot
lake exe cache get             # download prebuilt Mathlib (avoids compiling Mathlib from scratch)
lake build                     # builds all modules with zero sorry
lake env lean AxiomCheck.lean  # prints [propext, Classical.choice, Quot.sound] for all four theorems
```

### 4. Recompile the manuscript

```sh
cd paper && latexmk -pdf main.tex
```
```

---

## 6. File-Move List and Public-Repo Privacy Audit

### 6A. Proposed File Moves (Minimal Set — 2 Moves Total; Engineering Sign-Off Required)

Every reference below was found via `git grep` across the entire tracked repository (including READMEs, run records, `lean/SHA256SUMS.txt`, `paper/` `\includegraphics`/`\input` paths, `.gitignore`, `.githooks`, and scripts that `source()` other scripts).

| # | Old path | New path | Every tracked file referencing the old path | Risk & action required |
|---|---|---|---|---|
| **1** | `applications/Munich Rent/` | `archive/munich_rent/analysis/` | **Active docs (update):** `README.md:22`, `applications/README.md:9,18`, `archive/README.md:7`. **Self-contained historical scripts (already broken, pointing to pre-E03 `Data Applications/Munich Rent`):** `applications/Munich Rent/DATA.md:1`, `Munich_PMALA_Individual_k2.R:142,149`, `Munich_PMALA_checks.R:10`, `Munich_plots_k2.R:18`, `Others/*.R` (7 files). **Historical/archive logs (leave untouched):** `engineering/E02_Rate_Sims/free_check/FREE_CHECK.md:12`, `engineering/E03_Repo_Organization/*` (9 files), `experiments/joint_upper_levels/paper_reference/main.txt`, `paper/history/*` (12 files). **Paper TeX / Lean SHA256SUMS:** 0 references. | **LOW.** Dropped from the paper on 2026-10-28; its figures are already in `archive/munich_rent/figures/`. Update the 3 READMEs; leave historical logs untouched. |
| **2** | `experiments/pilots/` | `archive/pilots/` | **Active docs (update):** `experiments/README.md:33`. **Self-contained pilot scripts (update 4 internal relative paths if kept runnable):** `experiments/pilots/default_prior_VS_normal_t075/run.R:4,13`, `experiments/pilots/lambda_mixing/lane.sh:4`, `experiments/pilots/lambda_mixing/run_variant.R:3,11,17`, `experiments/pilots/lambda_mixing/test_asis_general.R:6`. **Historical run notes (leave untouched):** `engineering/E14_Inner_Rerun/DATA_MATCH.md:123`, `engineering/E03_Repo_Organization/*` (4 files). **Paper TeX / Lean SHA256SUMS:** 0 references. | **LOW.** Not used by any paper table or figure. Update `experiments/README.md` and the 4 pilot scripts (or mark them archived). |

### 6B. Moves Considered and Rejected (High Risk — Do NOT Move Now)

| Candidate path | Why NOT moved | Blocking references (verified via `git grep`) | Risk if moved |
|---|---|---|---|
| `engineering/` → `internal/engineering/` | Breaks active NOTS pipelines (E-18 Stage 2′, E-19, E-20) and 90+ scripts | Hardcoded in `engineering/E13_Joint_b0/e13*.slurm`, `E14_Inner_Rerun/e14*.slurm`, `E15_Extreme_Individual/e15.slurm`, `E16_n2000_b0/launch_full.sh`, `E17_b0_1e5/e17.slurm`, `E17_b0_1e5/e17_snapshot.sh`, `E18_Air_Refit/*` (19 files), `E07_Tuning_Free/*` (29 files), `method/individual/Individual_Sampler_PMALA_Augmented.R:419,435`, `method/joint/Joint_Sampler_PMALA_Augmented.R:314,330`, `README.md`, `archive/README.md`, `archive/archived_campaigns.md`. | **HIGH — DO NOT MOVE** |
| `theory/` → `internal/theory/` | Invalidates Lean checksums or leaves stale path in audited Lean source | Cited inside `lean/BQTF/Gram.lean:9` (hashed in `lean/SHA256SUMS.txt`), `lean/PLAN.md:21`, `lean/notes/PAPER_CORRECTIONS.md:37,91`, `lean/notes/reviews/*`, `literature/READING_LIST.md`, `writing/W01–W02`, `README.md`. | **HIGH — DO NOT MOVE** |
| `writing/` → `internal/writing/` | Referenced in immutable `paper/sections/theory.tex` and active W-08 | `paper/sections/theory.tex:2`, `README.md:25`, `theory/ALIGNMENT_MEMO.md`, `theory/T05_Proofs/*`, `engineering/E07_Tuning_Free/*`. | **HIGH — DO NOT MOVE** |
| `applications/Air Quality/` → `applications/air_quality/` | Breaks active E-18 Stage 2′ data-preparation script | `engineering/E18_Air_Refit/e18_prepare_spod.R:7` (`file.path("applications", "Air Quality", "S08_2018-06-15.csv")`), `applications/README.md`, `README.md`. | **HIGH (until E-18 closes) — DO NOT MOVE** |
| `literature/` → `internal/literature/` | Requires `.gitignore` edits (`literature/*.pdf`, `!literature/Large Prior.pdf`) for minimal gain | `.gitignore:43-44`, `README.md:26`, `theory/T03`, `T04`, `T07`, `writing/W04`. | **MEDIUM — SKIP** |
| `method/`, `lean/`, `paper/`, `experiments/`, `applications/` | Already clean public-facing names; cross-referenced across scripts, TeX, hooks, and checksums | `applications/Growth/Growth_Joint_PMALA_k2.R:31`, `paper/main.tex` (`\input`, `\includegraphics`), `lean/SHA256SUMS.txt`, `.githooks/size_allowlist.txt`, `LICENSE`. | **DO NOT MOVE** |

### 6C. Non-Move Tracked-Artifact Hygiene (Flagged for Engineering Sign-Off)

1. **4 tracked `.pyc` binaries:** `experiments/interior_quantiles/individual_nots_20261003/__pycache__/*.cpython-312.pyc`. Verified via `grep`: **not** in any `SHA256SUMS` file (`prepare_package.py:17` excludes `__pycache__`). Safe to `git rm`.
2. **Oversized files still tracked in git (contradicting `DATA.md` pointers & the 5 MB hook policy):**
   - **7 SPod CSVs (~20 MB each, ~140 MB total):** `applications/Air Quality/S08_2018-06-15.csv` … `S08_2018-06-21.csv` (`DATA.md` says they were removed from git after archiving; note `engineering/E18_Air_Refit/e18_prepare_spod.R:7` reads `S08_2018-06-15.csv`, so coordinate removal after E-18 Stage 2′ closes).
   - **Munich Rent heavy `.rds` draws (`24.1 MB`, `12.5 MB`, plus 10+ `~4.8 MB` files):** `applications/Munich Rent/Others/results_onizuka_k2/all_quantile_fits.rds`, `Others/results/all_quantile_fits.rds`, etc. (`Munich Rent/DATA.md` states these were removed from git after archiving).
   - **Joint monitor log (`10.8 MB`):** `experiments/joint_upper_levels/runs/VS_upper6_100seeds_Rdefaults_b001_20261002/metadata/monitor/history.jsonl` (`experiments/README.md:30` states it is on the PC).
3. **Broken legacy scalability script:** `experiments/scalability/benchmark_existing.R` still references pre-E03 paths (`Simulations/NOTS_n500/...`, `PMALA version Tex Project/...`). Do not advertise it as runnable in the public README until Engineering updates or archives it.

---

### 6D. Public-Repo Privacy & Personal-Data Audit

A full scan of `git ls-files` found **zero API keys, tokens, passwords, or private keys**, and **294 tracked text files** containing machine-specific paths, cluster account IDs, Windows usernames, or internal runner paths.

**Owner ruling (approved in principle for implementation, subject to Engineering sign-off):**
1. Replace `/home/<user>/` (and Windows `C:/Users/<user>/`) paths with **repo-relative paths or `$HOME`**.
2. Replace cluster paths, hostnames, and allocation names (`/projects/ml75/...`, `/scratch/fb31`, `nots.rice.edu`, `~/.config/bvs-hq/owls/owls_run`) with **neutral placeholders** (e.g., `<cluster-root>`, `<cluster-scratch>`, `<host>`).
3. **Preserve provenance in run records:** do **not** delete run records; instead add a short header note stating that local/cluster paths were generalized. *(Coordinate with Engineering on any file inside a frozen `SHA256SUMS` package so checksum integrity is preserved or explicitly documented.)*

| Severity / Visibility | Location (verified paths) | What is exposed | Implementation action (Engineering sign-off) |
|---|---|---|---|
| **High — Root README** | `README.md:28,66` | Rice NOTS allocation & username (`/projects/ml75/fb31/BQTF`), local ops details, "Ask Felipe for the PC path" | **Replace** in W-08 README rewrite; keep all machine/cluster/PC paths out of public README |
| **High — Public `applications/` & `method/`** | `applications/Growth/Growth_Joint_checks.R:13`; `applications/Munich Rent/Munich_PMALA_checks.R:9,12`; `applications/README.md:18`; `applications/Munich Rent/Others/results_pmala_k2/RUN_METADATA.txt:3`; `method/*/*.R` (`~/OneDrive/Documents/Quantile Regression`) | Windows username (`C:/Users/felip/OneDrive/...`, `C:/Users/felip/AppData/...`), `/home/fb31/.claude-science-scratch/...`, personal OneDrive folder | Replace with repo-relative paths / `$HOME`; remove `OneDrive` fallback from `method/*/*.R`; move `Munich Rent/` to `archive/` |
| **High — Public `lean/` (linked from `lean/README.md`)** | `lean/PLAN.md:26,43,205`; `lean/notes/reviews/FINAL_AUDIT_astra.md:80,105`; 35 other files in `lean/notes/{logs,reviews}/` | `/home/fb31/Large-Prior-Official-Repo/lean/`, `/home/fb31/.t3/worktrees/...`, `/home/fb31/Bayesian-Quantile-Trend-Filtering/...`, `~/.config/bvs-hq/owls/owls_run` | Replace `/home/fb31/...` and `owls_run` wrappers in `FINAL_AUDIT_astra.md`, `lean/PLAN.md`, and `lean/notes/` with repo-relative paths / neutral commands + provenance note; leave `.lean` sources untouched so `lean/SHA256SUMS.txt` stays valid |
| **Medium — `archive/` & `experiments/README.md`** | `archive/README.md:9`; `archive/archived_campaigns.md:3,8,31`; `experiments/README.md:3` | `/scratch/fb31`, `/home/fb31/projects/Quant_Reg/...`, "Felipe's PC" | Generalize paths to neutral placeholders (`<cluster-scratch>`, `<external-archive>`) with a short provenance note |
| **Medium — Institutional emails** | `paper/main.tex:54,56,58`; `experiments/joint_upper_levels/paper_reference/main.txt:36-38`; `paper/history/*` | `fb31@rice.edu`, `meng@rice.edu`, `echi@umn.edu` | Standard in academic manuscript (`paper/main.tex` untouched); **do not** repeat emails in `README.md` or `CITATION.cff` |
| **Low — Bulk internal & frozen records** | `experiments/` (106 files, mostly frozen `SHA256SUMS` packages), `engineering/` (98 files), `paper/history/` (25 files), `theory/` (19 files), `writing/` (2 files) | `/home/fb31`, `/projects/ml75`, `/scratch/fb31`, `C:/Users/felip`, `~/.config/bvs-hq/owls/owls_run`, `nots.rice.edu` | Apply the generalized-paths scrub + provenance note to non-sealed run records and department notes under Engineering sign-off; **do not break frozen `SHA256SUMS`-sealed packages** without Engineering's explicit ruling |

---

## 7. Open Items for the Owner

1. **Git history rewrite:** Scrubbing current tracked files removes personal/cluster paths from `HEAD`, but prior commits retain them. **Decision needed:** Should Engineering perform a git history rewrite after scrubbing the working tree to remove old paths from history, or leave git history untouched on the public repo?
2. **`literature/Large Prior.pdf`:** This PDF is currently tracked in git (the sole exception in `.gitignore:44`). **Decision needed:** Should `literature/Large Prior.pdf` remain public in this repository, or be git-ignored/removed in favor of a link to `FbStatsQuant/Large-Prior-Official-Repo`?
3. **Oversized tracked files contradicting `DATA.md` (Engineering + owner check):** Confirm post-E-18 removal of the 7 tracked ~20 MB SPod CSVs (`applications/Air Quality/S08_*.csv`), the tracked Munich Rent `Others/*.rds` draws, and the 10.8 MB `history.jsonl` monitor log so the repo matches its `DATA.md` pointers and 5 MB hook policy.
