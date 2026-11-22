#!/usr/bin/env bash
# E-03 heavy data removal.  Run ONLY after the signed E-01 receipts for the PC archive exist
# (HQ amendment 3: archived, not deleted; DATA.md with SHA-256 first, git rm after the receipt).
#   DRY_RUN=1 (default) echoes.  Needs: RECEIPT_SPOD=1 RECEIPT_MUNICH=1 RECEIPT_MONITOR=1
set -euo pipefail
REPO="${REPO:-/home/fb31/Bayesian-Quantile-Trend-Filtering}"; DRY_RUN="${DRY_RUN:-1}"
TRAILER="Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
run() { if [ "$DRY_RUN" = "1" ]; then printf 'DRY:'; printf ' %q' "$@"; printf '\n'; else "$@"; fi; }
cd "$REPO"
[ -z "$(git status --porcelain --untracked-files=no)" ] || { echo "REFUSED: tracked changes present" >&2; exit 1; }
[ -f "applications/Air Quality/DATA.md" ] || { echo "REFUSED: DATA.md pointer not committed yet (01_moves.sh section 9)" >&2; exit 1; }
for v in RECEIPT_SPOD RECEIPT_MUNICH RECEIPT_MONITOR; do
  [ "${!v:-0}" = "1" ] || { echo "REFUSED: $v=1 not set (needs the signed E-01 receipt)" >&2; exit 1; }
done
# defence in depth: the SHA-256 in DATA.md must still match the files being removed
( cd "applications/Air Quality" && grep -oE '[0-9a-f]{64}  S08_[0-9-]+\.csv' DATA.md | sha256sum -c - )
run git rm -q -- "applications/Air Quality"/S08_2018-06-1{5,6,7,8,9}.csv "applications/Air Quality"/S08_2018-06-2{0,1}.csv
for d in results results_onizuka results_onizuka_k2 results_pmala results_pmala_k2; do
  run git rm -r -q -- "applications/Munich Rent/Others/$d"
done
if [ "$DRY_RUN" = "1" ]; then echo "DRY: git rm -q -- experiments/joint_upper_levels/runs/*/metadata/monitor/history.jsonl"
else git rm -q -- experiments/joint_upper_levels/runs/*/metadata/monitor/history.jsonl; fi
run git commit -m "E-03: remove PC-archived heavy data (SPod CSVs, Munich Others/results*, joint monitor history.jsonl); pointers in DATA.md" -m "$TRAILER"
