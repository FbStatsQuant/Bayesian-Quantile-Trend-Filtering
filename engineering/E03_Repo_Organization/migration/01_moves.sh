#!/usr/bin/env bash
# =============================================================================
# E-03 migration, part 1: folder moves, one commit per area.  PREPARED, NOT APPLIED.
#
#   DRY_RUN=1 (default)  only echoes every command ("DRY: ...").  Nothing is touched.
#   DRY_RUN=0            really runs.  Only in the agreed migration window (see CHECKLIST.md).
#
# Run it from a COPY outside the repo (the script's own folder, Engineering/, is renamed
# in section 6):   cp -r Engineering/E03_Repo_Organization/migration /tmp/e03_kit
#                  DRY_RUN=0 bash /tmp/e03_kit/01_moves.sh
#
# Section order (one commit each):
#   1 paper   2 method   3 sampler-defaults (own labelled commit)   4 experiments
#   5 applications   6 archive   7 departments   8 literature
#   9 newfiles (root README, .gitignore, hook, LICENSE, ...)
#  10 DELETE section (git rm; clearly separated)
#  11 HEAVY: deferred to 01b_heavy_rm.sh (git rm of PC-archived data; refuses without receipts)
# History rewrite (D1) is 05_history_rewrite.sh, run later on a fresh mirror clone.
# =============================================================================
set -euo pipefail

REPO="${REPO:-/home/fb31/Bayesian-Quantile-Trend-Filtering}"
DRY_RUN="${DRY_RUN:-1}"
KIT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"        # where 03_new_files/ lives (this copy)
TRAILER="Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"

run() {                                  # echo in dry run, execute otherwise
  if [ "$DRY_RUN" = "1" ]; then printf 'DRY:'; printf ' %q' "$@"; printf '\n'; else "$@"; fi
}
section() { printf '\n=== %s ===\n' "$*"; }
die() { echo "REFUSED: $*" >&2; exit 1; }

cd "$REPO"
case "$KIT" in "$REPO"/*) [ "$DRY_RUN" = "1" ] || die "run a COPY of this kit from outside the repo (Engineering/ is renamed in section 7): cp -r $KIT /tmp/e03_kit && DRY_RUN=0 bash /tmp/e03_kit/01_moves.sh";; esac

# ---------------------------------------------------------------- 0. preflight
section "0 preflight"
[ "$(git rev-parse --show-toplevel)" = "$REPO" ] || die "not at the repo root $REPO"
[ "$(git rev-parse --abbrev-ref HEAD)" = "main" ] || die "not on branch main"
# Refuse if ANY tracked file is modified/staged/deleted.  Untracked files are allowed
# (Engineering/ is untracked on purpose; it is added in section 7).
if [ -n "$(git status --porcelain --untracked-files=no)" ]; then
  git status --porcelain --untracked-files=no >&2
  die "tracked files have changes (git status --porcelain). Commit or stash them first."
fi
for t in paper method experiments applications archive theory engineering literature \
         theory_tmp engineering_tmp; do
  [ ! -e "$t" ] || die "target '$t' already exists; migration already (partly) applied?"
done
for s in Project_Paper Simulations "Data Applications" Papers Temp Theory Engineering \
         Simulations/Individual/NOTS/inner_individual Simulations/Joint/NOTS \
         Simulations/Joint/inner_joint Simulations/Extreme "Data Applications/Growth" \
         Temp/NOTS_Exercise Project_Paper/notes/complexity_analysis; do
  [ -e "$s" ] || die "expected source missing: $s"
done
PRE_HASH="$(git rev-parse HEAD)"
echo "pre-migration HEAD = $PRE_HASH   (rollback: git reset --hard $PRE_HASH)"
if [ "$DRY_RUN" != "1" ]; then
  echo "$PRE_HASH" > .git/E03_PRE_HASH
  # baseline of SHA256SUMS verification (frozen packages), compared again by 04_smoke.sh
  : > .git/E03_SHA_BASELINE
  for d in Simulations/Individual/NOTS/inner_individual Simulations/Individual/NOTS/inner_individual/S_b00005 \
           Simulations/Individual/NOTS/inner_individual/S_b0001 Simulations/Individual/NOTS/inner_individual/VS_b0001 \
           Simulations/Joint/NOTS; do
    n=$( (cd "$d" && sha256sum -c SHA256SUMS 2>&1 | grep -c ': FAILED' ) || true )
    echo "$d $n" >> .git/E03_SHA_BASELINE
  done
  cat .git/E03_SHA_BASELINE
fi

# ---------------------------------------------------------------- 1. paper
section "1 paper  (rename only; \\input and figures/ stay relative to the compile dir)"
run git mv Project_Paper paper
# notes/ -> history/ (the 19 session folders + mixture_gibbs.*); complexity_analysis leaves in section 4
run git mv paper/notes paper/history
run git mv paper/noncrossing_review paper/history/noncrossing_review
run git mv paper/Notes.txt paper/history/TODO_2026-03.txt
# (paper/latexmkrc is created in section 9; the 13 unreferenced figures leave in sections 4 and 6)
run git commit -m "E-03: rename Project_Paper/ to paper/; notes, noncrossing_review, Notes.txt into paper/history/" -m "$TRAILER"

# ---------------------------------------------------------------- 2. method
section "2 method  (canonical sampler code)"
run mkdir -p method/individual method/joint method/admm_qtf
run git mv Simulations/Individual/Individual_Sampler_PMALA_Augmented.R method/individual/Individual_Sampler_PMALA_Augmented.R
run git mv Simulations/Individual/prox_admm_metric.cpp                  method/individual/prox_admm_metric.cpp
run git mv Simulations/Individual/pmala_exact_methods_note.md           method/individual/pmala_exact_methods_note.md
run git mv Simulations/Joint/Joint_Sampler_PMALA_Augmented.R            method/joint/Joint_Sampler_PMALA_Augmented.R
run git mv Simulations/Joint/prox_box_metric.cpp                        method/joint/prox_box_metric.cpp
run git mv Simulations/ADMM/ADMM_QTF_Individual.R                       method/admm_qtf/ADMM_QTF_Individual.R
run git commit -m "E-03: move canonical samplers to method/{individual,joint,admm_qtf}/" -m "$TRAILER"

# ---------------------------------------------------------------- 3. sampler-defaults
section "3 sampler-defaults  (OWN LABELLED COMMIT: master Individual settings block := production)"
# Production values = Simulations/Individual/NOTS/inner_individual/source/ snapshot (config.R sampler list):
#   order 2L; b0 0.01; asis TRUE; adapt_target 0.50; gibbs_iter 30000; gibbs_burn 10000; seed 1; tau 0.5.
# tau is already 0.5 in the master.  Seven lines change.  Nothing else in the file is touched.
IND=method/individual/Individual_Sampler_PMALA_Augmented.R
if [ "$DRY_RUN" = "1" ]; then
  echo "DRY: sed -i -E <7 anchored substitutions> $IND   (seed 100->1, order 1L->2L, b0 0.001->0.01, gibbs_iter 20000->30000, gibbs_burn 5000->10000, adapt_target 0.55->0.50, asis_lambda FALSE->TRUE)"
else
  sed -i -E \
    -e 's/^(seed +<- )100\b/\11/' \
    -e 's/^(order +<- )1L\b/\12L/' \
    -e 's/^(a0 <- 1;  b0 <- )0\.001\b/\10.01/' \
    -e 's/^(gibbs_iter +<- )20000\b/\130000/' \
    -e 's/^(gibbs_burn +<- )5000\b/\110000/' \
    -e 's/^(adapt_target <- )0\.55\b/\10.50/' \
    -e 's/^(asis_lambda +<- )FALSE\b/\1TRUE/' \
    "$IND"
  # check: against the frozen snapshot the ONLY remaining difference is the tau line (0.5 vs 0.1)
  SNAP=Simulations/Individual/NOTS/inner_individual/source/Individual_Sampler_PMALA_Augmented.R
  d=$(diff "$IND" "$SNAP" || true)
  nd=$(printf '%s\n' "$d" | grep -c '^[<>]' || true)
  case "$d" in *"tau "*) ;; *) die "unexpected diff vs snapshot: $d";; esac
  [ "$nd" = "2" ] || { printf '%s\n' "$d" >&2; die "settings block differs from the snapshot by more than tau"; }
  git diff --stat -- "$IND"
fi
run git add "$IND"
run git commit -m "E-03: reset master Individual sampler settings block to production defaults (order 2L, b0 0.01, asis TRUE, adapt_target 0.50, gibbs 30000/10000, seed 1, tau 0.5)" -m "Matches Simulations/Individual/NOTS/inner_individual/source/ (and config.R). Sampler body unchanged." -m "$TRAILER"

# ---------------------------------------------------------------- 4. experiments
section "4 experiments  (frozen NOTS packages move as-is; SHA256SUMS stay valid)"
run mkdir -p experiments/interior_quantiles experiments/air_simulation/drivers \
             experiments/extreme_quantiles/packages experiments/pilots
run git mv Simulations/Individual/NOTS/inner_individual experiments/interior_quantiles/individual_nots_20261003
run git mv Simulations/Joint/inner_joint                experiments/interior_quantiles/joint_nots
run git mv Simulations/Individual/individual_air_sim.R  experiments/air_simulation/drivers/individual_air_sim.R
run git mv Simulations/ADMM/admm_air_sim.R              experiments/air_simulation/drivers/admm_air_sim.R
run git mv Simulations/Air/lap_20261023                 experiments/air_simulation/onizuka_laplace_20261023
run git mv Temp/air_lap_20261023/stage                  experiments/air_simulation/onizuka_laplace_20261023/package_stage
run git mv Temp/air_lap_20261023/BUILD_REPORT.md        experiments/air_simulation/onizuka_laplace_20261023/BUILD_REPORT.md
for p in Extreme_admm Extreme_Individual Extreme_Joint_Sampler Extreme_Onizuka; do
  run git mv "Simulations/Extreme/$p" "experiments/extreme_quantiles/packages/$p"
done
for t in tables_20261008 tables_20261023 tables_4lev_20261023; do
  run git mv "Simulations/Extreme/$t" "experiments/extreme_quantiles/$t"
done
run git mv Simulations/Extreme/DEPLOYMENT_NOTES.md      experiments/extreme_quantiles/DEPLOYMENT_NOTES.md
run git mv Temp/extreme_tex_20261023/gen.R              experiments/extreme_quantiles/tables_20261023/gen_tex.R
run git mv Simulations/Joint/NOTS                       experiments/joint_upper_levels
run git mv paper/history/complexity_analysis            experiments/scalability
run mkdir -p experiments/scalability/figures_unused
for f in cost_scaling.pdf cost_scaling.png scal_speedup.pdf scal_pmala_per_obs.pdf; do
  run git mv "paper/figures/$f" "experiments/scalability/figures_unused/$f"
done
run git mv Simulations/Individual/results_pmala_aug     experiments/pilots/individual_results_pmala_aug
run git mv Simulations/Joint/results_joint              experiments/pilots/joint_results_joint
run git commit -m "E-03: move simulation campaigns, tables, air simulation, scalability and pilots into experiments/" -m "$TRAILER"

# ---------------------------------------------------------------- 5. applications
section "5 applications  (Data Applications/ moved AS-IS; inner folder names unchanged)"
run git mv "Data Applications" applications
run git commit -m "E-03: rename Data Applications/ to applications/ (contents unchanged)" -m "$TRAILER"

# ---------------------------------------------------------------- 6. archive
section "6 archive  (small superseded material)"
run mkdir -p archive/munich_rent/figures archive/scratch_2026/air_lap_previews
for f in munich_diagnostic_summary.png munich_individual_sampler.pdf munich_onizuka_q10_q90.pdf \
         munich_onizuka_q30_q50_q70.pdf munich_pmala_q10_q90.pdf munich_pmala_q30_q50_q70.pdf \
         munich_running_mean_stability.png munich_scale_trace_acf_diagnostics.png munich_trace_acf_diagnostics.png; do
  run git mv "paper/figures/$f" "archive/munich_rent/figures/$f"
done
run git mv paper/figures/_superseded_k1_munich archive/munich_rent/figures/_superseded_k1_munich
run git mv Temp/air_lap_20261023/p17-17.png      archive/scratch_2026/air_lap_previews/p17-17.png
run git mv Temp/air_lap_20261023/p17nose-17.png  archive/scratch_2026/air_lap_previews/p17nose-17.png
# OPTIONAL variant (HQ wrote "applications AS-IS", PROPOSAL §3 had Munich in archive/):
if [ "${MUNICH_TO_ARCHIVE:-0}" = "1" ]; then
  run git mv "applications/Munich Rent" archive/munich_rent/code
fi
run git commit -m "E-03: archive Munich figures and Temp previews (Munich app code stays in applications/ unless MUNICH_TO_ARCHIVE=1)" -m "$TRAILER"

# ---------------------------------------------------------------- 7. departments
section "7 departments  (case-only renames in TWO steps so Windows pulls do not collide)"
run git mv Theory theory_tmp
run git mv theory_tmp theory
# Engineering/ is UNTRACKED: plain mv, then add.  (Same two-step rename.)
run mv Engineering engineering_tmp
run mv engineering_tmp engineering
run git add -- engineering ':!**/__pycache__/**' ':!**/*.pyc'
run git commit -m "E-03: Theory/ -> theory/, Engineering/ -> engineering/ (two-step case rename); add engineering/ to git" -m "$TRAILER"

# ---------------------------------------------------------------- 8. literature
section "8 literature"
run git mv Papers literature
run git commit -m "E-03: rename Papers/ to literature/" -m "$TRAILER"

# ---------------------------------------------------------------- 9. new files
section "9 newfiles  (from 03_new_files; the copy of the kit is the one you started from)"
NF="$KIT/03_new_files"
[ -d "$NF" ] || die "03_new_files not found next to this script ($NF)"
run cp "$NF/README.md"        README.md
run cp "$NF/.gitignore"       .gitignore
run cp "$NF/.gitattributes"   .gitattributes
run cp "$NF/LICENSE"          LICENSE
run cp "$NF/CITATION.cff"     CITATION.cff
run mkdir -p .githooks
run cp "$NF/.githooks/pre-commit"          .githooks/pre-commit
run cp "$NF/.githooks/size_allowlist.txt"  .githooks/size_allowlist.txt
run chmod +x .githooks/pre-commit
run cp "$NF/paper/README.md"        paper/README.md
run cp "$NF/paper/latexmkrc"        paper/latexmkrc
run cp "$NF/method/README.md"       method/README.md
run cp "$NF/experiments/README.md"  experiments/README.md
run cp "$NF/applications/README.md" applications/README.md
run cp "$NF/applications/Air_Quality_DATA.md"  "applications/Air Quality/DATA.md"
run cp "$NF/applications/Munich_Rent_DATA.md"  "applications/Munich Rent/DATA.md"
run cp "$NF/archive/README.md"                 archive/README.md
run cp "$NF/archive/archived_campaigns.md"     archive/archived_campaigns.md
run cp "$NF/literature/README.md"              literature/README.md
run cp "$NF/literature/READING_LIST.md"        literature/READING_LIST.md      # replaces the tracked file (links added)
run cp "$NF/experiments/joint_upper_levels_DATA.md" experiments/joint_upper_levels/MONITOR_LOG_POINTER.md
run cp "$NF/engineering/NOTS_EXERCISE_PATTERN.md"  engineering/E03_Repo_Organization/NOTS_EXERCISE_PATTERN.md
run git config core.hooksPath .githooks
run git add README.md .gitignore .gitattributes LICENSE CITATION.cff .githooks paper/README.md paper/latexmkrc \
            method/README.md experiments/README.md applications/README.md \
            "applications/Air Quality/DATA.md" "applications/Munich Rent/DATA.md" \
            archive/README.md archive/archived_campaigns.md literature/README.md literature/READING_LIST.md \
            experiments/joint_upper_levels/MONITOR_LOG_POINTER.md engineering/E03_Repo_Organization/NOTS_EXERCISE_PATTERN.md
run git commit -m "E-03: add README, .gitignore, .gitattributes, LICENSE, CITATION.cff, size hook, folder READMEs, DATA.md pointers" -m "$TRAILER"

# ---------------------------------------------------------------- 10. DELETE section
section "10 DELETE  (git rm; separate from the moves)"
echo "--- 10a  merge the 3 unique bib keys, THEN remove the stale sections/references.bib"
for k in cobb1978nile rue2005gaussian faulkner2018locally; do
  if [ "$DRY_RUN" != "1" ]; then
    grep -q "{$k," paper/sections/references.bib || die "key $k missing in stale bib"
    ! grep -q "{$k," paper/references.bib || die "key $k already in paper/references.bib"
  fi
done
if [ "$DRY_RUN" = "1" ]; then echo "DRY: (printf '\n'; cat $NF/paper/bib_merge_3keys.bib) >> paper/references.bib"
else (printf '\n'; cat "$NF/paper/bib_merge_3keys.bib") >> paper/references.bib; fi
run git add paper/references.bib
run git commit -m "E-03: merge 3 unique keys (cobb1978nile, rue2005gaussian, faulkner2018locally) from stale sections/references.bib into paper/references.bib" -m "$TRAILER"
run git rm -q paper/sections/references.bib
run git commit -m "E-03: remove stale paper/sections/references.bib (its 3 unique keys were merged in the previous commit)" -m "$TRAILER"

echo "--- 10b  throwaway material"
run git rm -r -q Temp/NOTS_Exercise                                   # throwaway exercise (pattern kept in engineering/E03_Repo_Organization/NOTS_EXERCISE_PATTERN.md)
for f in p-10.png p-11.png p-12.png q-13.png q-14.png; do
  run git rm -q "Temp/extreme_tex_20261023/$f"                        # page previews
done
# old-paper PDF snapshots (8 files; they stay in git history until the D1 rewrite)
if [ "$DRY_RUN" = "1" ]; then
  echo "DRY: git rm -q -- paper/history/*/before/main.pdf   (8 files today, under Project_Paper/notes/*/before/)"
else
  git rm -q -- paper/history/*/before/main.pdf
fi
run git commit -m "E-03: remove Temp/NOTS_Exercise, Temp extreme_tex previews, and notes/*/before/main.pdf snapshots" -m "$TRAILER"

echo "--- 10c  untrack (files stay on disk, now ignored): LaTeX build artifacts and third-party PDFs"
for e in aux bbl blg fdb_latexmk fls log out toc; do
  run git rm --cached -q "paper/main.$e"
done
# D3: literature/*.pdf is git-ignored except Large Prior.pdf.  Local copies stay on disk.
if [ "$DRY_RUN" = "1" ]; then
  echo "DRY: for each literature/*.pdf except 'Large Prior.pdf': git rm --cached -q  (17 files)"
else
  git ls-files -z -- 'literature/*.pdf' | while IFS= read -r -d '' f; do
    [ "$f" = "literature/Large Prior.pdf" ] || git rm --cached -q -- "$f"
  done
fi
# OPTIONAL (not in PROPOSAL; ambiguous): 4 tracked __pycache__/*.pyc in the frozen individual package, not covered by SHA256SUMS
if [ "${RM_PYC:-0}" = "1" ]; then
  run git rm -r --cached -q experiments/interior_quantiles/individual_nots_20261003/__pycache__
fi
run git commit -m "E-03: untrack LaTeX build artifacts and third-party PDFs (kept locally; .gitignore'd). paper/main.pdf stays tracked" -m "$TRAILER"

# ---------------------------------------------------------------- 11. HEAVY (separate script)
section "11 HEAVY  (git rm of the PC-archived data): NOT done here"
echo "Deferred to 01b_heavy_rm.sh, which refuses to run without the signed E-01 receipts"
echo "(SPod CSVs, Munich Others/results*, joint monitor history.jsonl).  DATA.md pointers are already committed (section 9)."

# ---------------------------------------------------------------- cleanup
section "cleanup of now-empty old folders"
run find Simulations Temp "Data Applications" Papers Project_Paper -depth -type d -empty -delete 2>/dev/null || true
for d in Simulations Temp "Data Applications" Papers Project_Paper; do
  if [ -d "$d" ] && [ "$DRY_RUN" != "1" ]; then echo "WARNING: $d still has files (untracked leftovers?):"; find "$d" -type f | head; fi
done
echo
echo "Done (DRY_RUN=$DRY_RUN). Next: 04_smoke.sh, then CHECKLIST.md handoff.  Rollback: git reset --hard $PRE_HASH"
