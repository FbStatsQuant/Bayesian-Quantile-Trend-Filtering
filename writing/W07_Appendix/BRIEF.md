# W-07 worker brief (approved by HQ and Felipe on 2026-11-26)

The approved plan is `writing/W07_Appendix/OUTLINE.md`. Read it first. This brief adds the rules and the rulings. The paper is `paper/main.tex`, with sections in `paper/sections/`.

## Goal
Rebuild the non-proof appendices from scratch, in perfect alignment with the main text, and **at least halve their length**. Felipe: "extremely disorganized … trim it as much as possible, it's too long."
- **C, Computational details** (`appendix_pmala.tex`): now pp. 42–53, target **≤ 6 pages**.
- **D, Additional simulation results** (`appendix_simulations.tex`): now 8 pp, target **≤ 3 pages**.
- **E, Additional real-data figures** (`appendix_data_application_plots.tex`): now 3 pp, target **≤ 2 pages**.

## Hard rules
1. **Do not touch** `appendix_theory.tex` (Appendix A, Lean-verified) or `appendix_assumptions.tex` (B), or any main-text file (`abstract, introduction, methodology, theory, numerical, simulations, scalability, air_simulation, data_application, discussion`, `main.tex`, `references.bib`). If you think a main-text change is needed, list it in your report; do not make it.
2. **Development history goes.** Describe the method as it is and the results as they are, not how we got there: no pilots, no tried-and-rejected variants, no "previous default", no sensitivity runs that justify a past choice. The approved deletion list is OUTLINE.md §3, items 1–7.
3. **Numbers never change.** Every MSE/MAD/MCIW/crossing value stays the same value. Only the rounding changes, and rounding is presentation. Keep every table and every competing-method fit figure, merged and denser.
4. **Faithfulness.** The appendix must say exactly what was run. Every statement of a run setting needs a source: an engineering/ or experiments/ README, or an Engineering answer. **No inference.** Where the source is still pending, write the cell or sentence with the visible marker `\tbc{...}` (see Macros).
5. **Labels.** Keep every label that is referenced from outside your file, attached to the corresponding new home (OUTLINE.md §6). Where sections merge, put the old labels on the merged section (several `\label`s are fine). Remove labels nothing references.
6. **Notation and defaults must match §2–§4 exactly** (methodology.tex, simulations.tex, data_application.tex). Use the same symbols: `\by`, `\norm`, $a_0,b_0,a_\sigma,b_\sigma$, $\kappa$, $\delta$, $\gamma$, $H$, $T(\cdot)$, $T_B$, $M$, $W$, $D$, $m=n-k-1$, etc. Do not restate setup that §4 already gives; cross-reference it instead.
7. **Paper style (Felipe's rules).** No section named "Theory". Citations only via natbib (`\citet`/`\citep`). A paragraph right after a displayed equation, table or algorithm must not open by repeating its label. Abbreviations are defined once, not in every caption. Captions stay short.
8. **Layout.**
   - No `\clearpage`, `\newpage` or `[H]`. Use `[tbp]` or `[htbp]` floats and let them pack.
   - No page holding one small table. Merge sibling tables (shared headers, column groups, stacked panels). Figures go in multi-panel grids.
   - Check every page of the compiled PDF visually (`pdftoppm -r 50 -f P -l Q main.pdf /tmp/...` and look at the PNGs) before you report.
9. **Precision (Felipe, 2026-11-26): keep every number's format exactly as it is.** No rounding anywhere: 6 decimals stay 6, 2 stay 2. If a merged table is too wide, use \small or \footnotesize, a tighter \tabcolsep, or stacked panels. Copy values verbatim, by script, and check that each table's multiset of numbers is unchanged. (This replaces the earlier 4/1-decimal ruling.)
10. **Commits.** Commit in small logical steps with explicit paths: `git add -- <paths> && git commit -m "..." -- <paths>`. Never use `-a` or a pre-staged index. End every message with `Co-Authored-By: <your model> <noreply@...>`. **Do not commit `paper/main.pdf`.** Do not push. Quote a hash only after git prints it.
11. **Compute.** Compile only through the Owls wrapper, at most 1 core:
    `cd paper && for i in $(seq 1 20); do ~/.config/bvs-hq/owls/owls_run -j 1 -- latexmk -pdf -interaction=nonstopmode main.tex > /tmp/w07_latex.out 2>&1; rc=$?; [ $rc -ne 75 ] && break; sleep 30; done; grep -i "undefined\|^! \|Overfull" main.log; pdfinfo main.pdf | grep Pages`
    If the wrapper prints REFUSED, wait and retry; never bypass it. The build must end with no undefined references and no overfull boxes.
12. Never put the owner's email or personal details anywhere.

## Macros
At the top of your file add
`\providecommand{\tbc}[1]{\textcolor{red}{[TBC: #1]}}`
and use `\tbc{...}` for every pending fact (E-18 air-quality material, Engineering answers). The markers must be easy to grep and visible in the PDF.

## Known provenance (use exactly these; anything else is \tbc)
- **Interior simulations** (§4.1 Tables 1/2, Appendix D.1): later sampler version (E-14, commit 63f2a56). Its features are a running-median data start, λ held at λ⁽⁰⁾ = m during the H = 200 warm-up sweeps, spline-held interweaving with q cycling 10/20/40, and the two safeguard changes, as stated in the current C.9. b0 = 1e-3 (VS) and 5e-4 (S); 30000 sweeps with 10000 burn-in; IG(0.1, 0.1); acceptance target 0.5; all 100 seeds. Diagnostics in the current C.6/C.7/C.8: acceptance 0.49–0.52, none stopped, median wall time 153 s, median log λ ESS 102 (VS) and 132 (S) from every 30th retained draw. Source: `engineering/E14_Inner_Rerun/README.md` and the current appendix text. ADMM form: \tbc.
- **Extreme individual runs** (§4.2 Tables 3/4, crossings): legacy Oct-7/21 sampler snapshot; b0 = 0.01 (VS) and 0.001 (S); 10000 sweeps with 3000 burn-in; interweaving off; acceptance target 0.55; starts at y and updates λ during the 200 warm sweeps. Source: `engineering/E15_Extreme_Individual/PROVENANCE.md`, table "Settings relative to the interior runs". ADMM form: \tbc.
- **Extreme joint sampler** (§4.2): Oct-2 run, `experiments/joint_upper_levels/README.md` and `config.R`: b0 = 0.01, a_σ = b_σ = 0.1, 30000 sweeps with 10000 burn-in, 200 warm sweeps, κ = 3, interweaving on, adapt_target 0.50, adaptation throughout. Mark it "\tbc{Engineering to confirm}" until confirmed. ADMM form: \tbc.
- **Air-quality simulation** (§4.3) and **SPod application** (§4.4.1, App E.1): being refit in E-18. Every setting is \tbc. Leave a clearly marked placeholder for the appendix material and for the "application uses the increment form / longer chains" sentences.
- **Growth** (§4.4.2, App E.2): §4.4.2 states Gamma(1, √G), 6000 sweeps with 1000 burn-in, one independent run per level. Sampler version, interweaving, acceptance target and ADMM form are all \tbc.
- **Scalability** (§4.2 timings): sampler version \tbc.
- **Defaults** of the §2 algorithm: κ = 3, a_σ = b_σ = 0.1, δ⁽⁰⁾ = 0.2, λ⁽⁰⁾ = m, σ⁽⁰⁾ = 1, H = 200, γ_w = 10⁴, 150 ADMM iterations, adaptation gain t^{-0.6} toward 0.5, δ ∈ [1e-8, 1e2]. These are as in the current appendix.
