# README figures (W-08)

`make_readme_figures.R` draws the README figures from saved fit curves. It fits nothing, takes a few seconds, and needs only R with ggplot2.

## Idea

The hero and growth panels shade the area between the estimated τ = 0.1 and τ = 0.9 quantile curves. The data points sit on top of the band, and a note gives the share of points inside it (nominal 0.80). Both are joint-sampler fits, whose curves cannot cross, so the lower edge of the band is never above its upper edge. The SPod panel is different: its three levels are separate fits of the individual sampler, so the script checks their order before it draws a band (see Panels, item 3).

## Run

From the repository root:

```
Rscript examples/readme_figures/make_readme_figures.R --demo        # hero from stand-in data
Rscript examples/readme_figures/make_readme_figures.R               # hero from engineering/E20_Showcase/curves.csv; without it, growth panels (a)(b) only
Rscript examples/readme_figures/make_readme_figures.R --e20 <file>  # hero from a given E-20 file
```

| Flag | Effect |
|---|---|
| `--demo` | The hero uses the repo's own VS generator (`simulate_data()`, parsed from `method/joint/Joint_Sampler_PMALA_Augmented.R`; seed 1, n = 1,000, Normal errors) for `y`, with the true conditional quantiles standing in for the fitted curves. The file names end in `_DEMO` and the image carries a red DEMO label. |
| `--e20 <path>` | Path to the E-20 file (`.csv` or `.rds`). By default the script uses the first such file in `engineering/E20_Showcase/`. If there is none, it skips the hero and the combined image. |
| `--bands` | Adds the per-curve credible bands as a faint variant. Off by default. Output files get the suffix `_bands`. |
| `--no-median` | Drops the thin τ = 0.5 line from the growth panels. |
| `--spod <path>` | Also draws the SPod panel from a curve file (`.csv` with the columns `time, y, q01, q05, q10`; the names live in the block marked `SPOD COLUMN MAPPING`). Off by default. Writes `readme_spod.{png,pdf}`. |

The script locates its own folder, so it runs from any working directory. All paths are relative.

## Outputs (`reference_outputs/`; `--demo` writes to `out/`, never published)

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
3. **SPod air quality (after the E-18 refit; drawn only with `--spod <path>`).** `spod_panel(time, y, lower, upper, middle, tau_lo = 0.01, tau_hi = 0.10, tau_mid = 0.05)` draws the low baseline beneath the readings, so the plumes stand clearly above it. The three levels are separate fits of the individual sampler, so nothing guarantees their order. The function checks all three curves at every time point and counts the crossings (points where the τ = 0.01 curve is above the 0.05 curve, or the 0.05 curve above the 0.10 curve). With no crossing it draws the band between the 0.01 and 0.10 curves and the 0.05 curve as the line. With one crossing or more it draws the 0.05 curve alone and no band. The count is printed in the panel note and on the console either way. The note also gives the share of readings below the 0.10 curve (nominal 0.10), not a share inside. The subtitle says "Each level fitted separately (individual sampler)"; the panel never says "joint" or "cannot cross". Tested on synthetic data on 2026-11-26: 0 crossings gives the band; 187 planted crossings in 8,640 points are counted as 187 and give the line alone.
