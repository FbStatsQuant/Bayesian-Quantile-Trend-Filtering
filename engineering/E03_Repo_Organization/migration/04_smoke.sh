#!/usr/bin/env bash
# E-03 post-migration smoke tests.  PREPARED, NOT RUN.  Run from anywhere:  bash 04_smoke.sh [paper|individual|joint|paths|hook|seals|all]
# Each test prints PASS or FAIL with its pass condition; the script exits non-zero if any FAIL.
# Compute policy: single-threaded (OMP/OPENBLAS/FLEXIBLAS = 1); the whole set is ~5 minutes on Owls; nothing here needs Slurm.
# Nothing is written into the repo: the paper is built in a scratch copy, the hook test in a scratch clone.
set -uo pipefail
REPO="${REPO:-/home/fb31/Bayesian-Quantile-Trend-Filtering}"
WHAT="${1:-all}"
export OMP_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 FLEXIBLAS_NUM_THREADS=1 MKL_NUM_THREADS=1
SCR="$(mktemp -d /tmp/e03_smoke.XXXXXX)"
fail=0
pass() { echo "PASS  $1"; }
bad()  { echo "FAIL  $1"; fail=1; }
want() { [ "$WHAT" = all ] || [ "$WHAT" = "$1" ]; }
cd "$REPO"

if want paper; then
  # Pass: (1) the 3 LaTeX packages exist, (2) latexmk exits 0, (3) main.pdf exists, (4) no "! LaTeX Error", no "Citation ... undefined", no "File ... not found" in main.log.
  # Built in a scratch copy so the tracked paper/main.pdf is not rewritten.  IN_PLACE=1 builds in paper/ (then `git checkout paper/main.pdf`).
  echo "--- paper (cd paper && latexmk -pdf main.tex)"
  miss=""; for f in algpseudocode.sty bbm.sty bbold.sty; do kpsewhich "$f" >/dev/null || miss="$miss $f"; done
  if [ -n "$miss" ]; then bad "paper: missing LaTeX packages:$miss (install in a user texmf)"; else
    if [ "${IN_PLACE:-0}" = 1 ]; then B="$REPO/paper"; else B="$SCR/paper"; mkdir -p "$B"; cp -r paper/main.tex paper/references.bib paper/latexmkrc paper/sections paper/figures "$B"/; fi
    ( cd "$B" && latexmk -pdf -interaction=nonstopmode main.tex > "$SCR/latexmk.out" 2>&1 ); rc=$?
    if [ $rc -eq 0 ] && [ -s "$B/main.pdf" ] && ! grep -qE '^! LaTeX Error|Citation .* undefined|File .* not found' "$B/main.log"; then pass "paper builds (exit 0, main.pdf written, no LaTeX Error / undefined citation / missing file)"
    else bad "paper build (exit $rc); see $SCR/latexmk.out and $B/main.log"; fi
    if command -v pdfinfo >/dev/null; then echo "info  pages: built $(pdfinfo "$B/main.pdf" 2>/dev/null | awk '/^Pages/{print $2}') vs tracked $(pdfinfo paper/main.pdf 2>/dev/null | awk '/^Pages/{print $2}') (informational)"; fi
  fi
fi

if want individual; then
  # Pass: exit 0 and the output contains "all tests passed" (about 100 s; writes nothing).
  echo "--- individual sampler (cd method/individual && Rscript Individual_Sampler_PMALA_Augmented.R test)"
  out="$( cd method/individual && Rscript Individual_Sampler_PMALA_Augmented.R test 2>&1 )"; rc=$?
  if [ $rc -eq 0 ] && grep -q "all tests passed" <<<"$out"; then pass "individual test: all tests passed"; else bad "individual test (exit $rc): $(tail -3 <<<"$out")"; fi
fi

if want joint; then
  # Pass: exit 0 and "all optimisation-kernel tests passed".  Needs R package clarabel (user library); without it FAIL at test P3 is the known cause, not a layout fault.
  echo "--- joint sampler (cd method/joint && Rscript Joint_Sampler_PMALA_Augmented.R test_prox)"
  Rscript -e 'quit(status = !requireNamespace("clarabel", quietly = TRUE))' || echo "warn  R package clarabel is missing: test P3 will fail for that reason (install it in a user library first)"
  out="$( cd method/joint && Rscript Joint_Sampler_PMALA_Augmented.R test_prox 2>&1 )"; rc=$?
  if [ $rc -eq 0 ] && grep -q "all optimisation-kernel tests passed" <<<"$out"; then pass "joint test_prox: all optimisation-kernel tests passed (the ../individual/ include resolves)"; else bad "joint test_prox (exit $rc): $(tail -3 <<<"$out")"; fi
fi

if want paths; then
  echo "--- path coupling"
  # Pass: no source file outside frozen packages / history still names the old layout.
  hits="$(grep -rnIE 'Simulations/|Project_Paper|Data Applications|PMALA version Tex' \
        --include=*.R --include=*.py --include=*.cpp --include=*.tex --include=*.sh --include=*.slurm . \
        --exclude-dir=.git --exclude-dir=history --exclude-dir=individual_nots_20261003 --exclude-dir=joint_nots \
        --exclude-dir=joint_upper_levels --exclude-dir=packages --exclude-dir=package_stage --exclude-dir=E03_Repo_Organization \
        --exclude-dir=theory 2>/dev/null | grep -v '^./experiments/extreme_quantiles/tables_4lev_20261023/verify' || true)"
  if [ -z "$hits" ]; then pass "no old-layout path left in maintained code"; else bad "old-layout paths remain:"; echo "$hits" | head -20; fi
  # Pass: growth kernel root resolves to method/{joint,individual}
  Rscript -e 'sd <- normalizePath("applications/Growth"); kr <- file.path(dirname(dirname(sd)), "method");
    stopifnot(file.exists(file.path(kr,"joint","prox_box_metric.cpp"), file.path(kr,"individual","prox_admm_metric.cpp"), file.path(kr,"joint","Joint_Sampler_PMALA_Augmented.R")))' \
    && pass "growth kernel root resolves (../../method/{joint,individual})" || bad "growth kernel root"
  # Pass: every edited R file parses
  ok=1; for f in method/individual/*.R method/joint/*.R method/admm_qtf/*.R experiments/air_simulation/drivers/*.R \
        applications/Growth/*.R experiments/air_simulation/onizuka_laplace_20261023/rows.R \
        experiments/extreme_quantiles/tables_20261023/gen_tex.R experiments/extreme_quantiles/tables_4lev_20261023/*.R; do
    Rscript -e 'invisible(parse(commandArgs(TRUE)[1]))' "$f" >/dev/null 2>&1 || { echo "  parse error: $f"; ok=0; }
  done; [ $ok = 1 ] && pass "edited R files parse" || bad "R parse errors"
  # Pass: stale bib is gone and the 3 merged keys are present once
  [ ! -e paper/sections/references.bib ] && [ "$(grep -c -E '\{(cobb1978nile|rue2005gaussian|faulkner2018locally),' paper/references.bib)" = 3 ] \
    && pass "bib merged (3 keys), stale sections/references.bib removed" || bad "bib merge state"
  # Pass: case renames landed as lower case in the index (Windows-collision check)
  git ls-files | grep -qE '^(Theory|Engineering)/' && bad "capitalised Theory/ or Engineering/ still tracked" || pass "theory/ and engineering/ are lower case in the index"
fi

if want hook; then
  # Pass: a 6 MB staged file is refused (exit 1); after listing it in the allowlist the hook exits 0.
  echo "--- size hook (scratch clone)"
  git clone -q --no-hardlinks "$REPO" "$SCR/hooktest" && ( cd "$SCR/hooktest"
    head -c 6000000 /dev/urandom > big.bin; git add big.bin
    if bash .githooks/pre-commit 2>/dev/null; then echo "FAIL  hook accepted a 6 MB file"; exit 1; else echo "PASS  hook refuses a 6 MB file"; fi
    echo big.bin >> .githooks/size_allowlist.txt
    if bash .githooks/pre-commit 2>/dev/null; then echo "PASS  hook accepts it when allow-listed"; else echo "FAIL  allow-list ignored"; exit 1; fi
  ) || fail=1
fi

if want seals; then
  # Pass: the number of failing lines in each frozen package's SHA256SUMS equals the pre-migration baseline recorded by 01_moves.sh (.git/E03_SHA_BASELINE).
  echo "--- frozen package seals (sha256sum -c) vs baseline"
  [ -f .git/E03_SHA_BASELINE ] || echo "warn  no baseline file (01_moves.sh records it when DRY_RUN=0)"
  map() { case "$1" in
     Simulations/Individual/NOTS/inner_individual*) echo "experiments/interior_quantiles/individual_nots_20261003${1#Simulations/Individual/NOTS/inner_individual}";;
     Simulations/Joint/NOTS) echo "experiments/joint_upper_levels";; esac; }
  while read -r old n; do
    new="$(map "$old")"; now=$( (cd "$new" && sha256sum -c SHA256SUMS 2>&1 | grep -c ': FAILED') || true )
    [ "$now" = "$n" ] && pass "seal $new: $now failing lines (baseline $n)" || bad "seal $new: $now failing lines, baseline $n"
  done < <(cat .git/E03_SHA_BASELINE 2>/dev/null)
fi

rm -rf "$SCR"
[ $fail = 0 ] && echo "ALL SMOKE TESTS PASSED" || echo "SOME SMOKE TESTS FAILED"
exit $fail
