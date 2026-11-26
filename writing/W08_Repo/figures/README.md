# README figures (W-08)

`make_readme_figures.R` draws the README figures from saved fit curves. It fits nothing, takes a few seconds, and needs only R with ggplot2.

## Idea

Each panel shades the area between the estimated τ = 0.1 and τ = 0.9 quantile curves, so the whole series gets its own 80% band. The data points sit on top of the band, and a note gives the share of points inside it (nominal 0.80). The joint sampler's curves cannot cross, so the band is always a valid region.

## Run

From the repo root (on Owls, always through the wrapper):

```
owls_run -j 1 -- Rscript writing/W08_Repo/figures/make_readme_figures.R --demo        # hero from stand-in data
owls_run -j 1 -- Rscript writing/W08_Repo/figures/make_readme_figures.R               # hero from engineering/E20_Showcase/
owls_run -j 1 -- Rscript writing/W08_Repo/figures/make_readme_figures.R --e20 <file>  # hero from a given E-20 file
```

| Flag | Effect |
|---|---|
| `--demo` | The hero uses the repo's own VS generator (`simulate_data()`, parsed from `method/joint/Joint_Sampler_PMALA_Augmented.R`; seed 1, n = 1,000, Normal errors) for `y`, with the true conditional quantiles standing in for the fitted curves. The file names end in `_DEMO` and the image carries a red DEMO label. |
| `--e20 <path>` | Path to the E-20 file (`.csv` or `.rds`). By default the script uses the first such file in `engineering/E20_Showcase/`. If there is none, it skips the hero and the combined image. |
| `--bands` | Adds the per-curve credible bands as a faint variant. Off by default. Output files get the suffix `_bands`. |
| `--no-median` | Drops the thin τ = 0.5 line from the growth panels. |

The script locates its own folder, so it runs from any working directory. All paths are relative.

## Outputs (`out/`)

| File | Content |
|---|---|
| `readme_combined[_DEMO].{png,pdf}` | Multi-panel README image: hero, then growth (boys). PNG 2400 × 810 px; PDF 10.67 × 3.6 in. |
| `readme_hero_vs[_DEMO].{png,pdf}` | Hero alone: VS simulation, n = 1,000. |
| `readme_growth_boys.{png,pdf}`, `readme_growth_girls.{png,pdf}` | Growth panels. |

Each single panel is a 2400 × 1500 px PNG (8 × 5 in at 300 dpi) plus a vector PDF made with cairo_pdf, which embeds the fonts. Every image has an opaque white background, so it reads the same on GitHub's light and dark themes.

## Style

| Element | Hex | Note |
|---|---|---|
| Background | `#FFFFFF` | Opaque |
| Band (τ 0.1 to 0.9) | `#CFE3F6` | Light blue |
| Band edges (the two curves) | `#7EA9D8` | 0.35 pt lines |
| Data points | `#14325C` | Dark blue, drawn on top of the band; contrast 9.7:1 on the band and 12.8:1 on white |
| True signal (simulation only) | `#111111` | Dotted, with a thin white halo so it stays visible over the points |
| Median / baseline line | `#0A1A33` | Thin |
| Per-curve credible bands (`--bands`) | `#8FB3DC` | 45% alpha |
| Title / axis text | `#1F2328` / `#57606A` | |
| Grid | `#EEF1F4` | Major lines only |
| DEMO label | `#B42318` | Demo images only |

The font is Liberation Sans, with the default sans as a fallback.

## Panels

1. **Hero: VS simulation, n = 1,000, Normal errors (E-20).** The script reads a tidy CSV with the columns `method, x, y, truth, q10, q90` and the optional `q10_lo, q10_hi, q90_lo, q90_hi`. It keeps only the rows with `method == "joint"`. These names live in a single block marked `E-20 COLUMN MAPPING` in the script, which is the one place to edit if the schema changes.
2. **Growth (fdgs, joint sampler, k = 2).** Data: `applications/Growth/data/fdgs.csv`, rows with missing height dropped. Curves: `applications/Growth/results_joint_k2/{boy,girl}/posterior_summary.csv`. This is a joint-sampler fit (b0 = 0.01, 30,000 sweeps of which 10,000 are burn-in), labelled "joint-sampler fit; the curves cannot cross". It is not the run behind the paper's growth figure. The share inside is computed per child by linear interpolation of the τ = 0.1 and 0.9 curves at that child's age. The combined image uses boys only: the two sexes look almost the same until about age 12, so a side-by-side pair would halve each panel's width and add clutter without telling the reader anything new. The girls panel is written separately.
3. **SPod air quality: a hook only (after the E-18 refit).** `spod_panel(time, y, lower, upper, middle = NULL, tau_lo = 0.01, tau_hi = 0.10, tau_mid = 0.05)` draws a low baseline band (for example τ = 0.01 to 0.10, with the 0.05 curve as the line) beneath the readings, so the plumes stand clearly above it. Its note gives the share of readings below the upper curve (nominal τ_hi), not a share inside. The script does not call it yet.
