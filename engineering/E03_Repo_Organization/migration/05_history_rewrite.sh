#!/usr/bin/env bash
# =============================================================================
# E-03 D1: one-time history rewrite with git filter-repo.  PREPARED, NOT APPLIED.
# Felipe's decision (2026-11-22): YES.  Runs AFTER the migration commits (01_moves.sh, path fixes, smoke tests green),
# on a FRESH MIRROR CLONE.  The working repo is never modified.  HQ force-pushes the result.
#
#   DRY_RUN=1 (default) only echoes.   DRY_RUN=0 does it.
#
# Removes from ALL history (old and new paths):
#   * SPod CSVs            Data Applications/Air Quality/S08_*.csv  (and applications/Air Quality/...)
#   * Munich Others        .../Munich Rent/Others/results*/   (every file, i.e. all .rds)
#   * old-paper snapshots  Project_Paper/notes/*/before/main.pdf, any */build/main.pdf (and paper/history/...)
#   * monitor log          Simulations/Joint/NOTS/runs/*/metadata/monitor/history.jsonl (and experiments/joint_upper_levels/...)
#   * third-party PDFs     every .pdf under Papers/ or literature/ EXCEPT "Large Prior.pdf"
# Writes the old->new commit map to engineering/E03_Repo_Organization/hash_map.tsv (committed on top of the rewritten main,
# in a work clone, ready to push) and prints before/after .git sizes.
# =============================================================================
set -euo pipefail
REPO="${REPO:-/home/fb31/Bayesian-Quantile-Trend-Filtering}"
DRY_RUN="${DRY_RUN:-1}"
WORK="${WORK:-/tmp/bqtf_rewrite}"                      # scratch; must not exist
PDF_BACKUP="${PDF_BACKUP:-$HOME/BQTF_literature_pdfs}" # local copy of the third-party PDFs
TRAILER="Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
run() { if [ "$DRY_RUN" = "1" ]; then printf 'DRY:'; printf ' %q' "$@"; printf '\n'; else "$@"; fi; }
die() { echo "REFUSED: $*" >&2; exit 1; }

command -v git-filter-repo >/dev/null || die "git-filter-repo not installed"
# The rewrite deletes the heavy data from EVERY commit, so the archive must be safe first (HQ amendment 3):
for v in RECEIPT_SPOD RECEIPT_MUNICH RECEIPT_MONITOR; do
  [ "${!v:-0}" = "1" ] || die "$v=1 not set: needs the signed E-01 receipt (SPod CSVs, Munich Others/results*, monitor log)"
done
[ "${PDFS_BACKED_UP:-0}" = "1" ] || die "set PDFS_BACKED_UP=1 after checking the local copies of literature/*.pdf (they leave the repo history)"
[ ! -e "$WORK" ] || die "$WORK exists; remove it or set WORK=..."
cd "$REPO"
[ -z "$(git status --porcelain --untracked-files=no)" ] || die "tracked changes in $REPO"
[ -d paper ] && [ -d method ] && [ -d engineering ] || die "migration commits not present (paper/, method/, engineering/ missing)"
ORIGIN_URL="$(git remote get-url origin)"
BEFORE_GIT="$(du -sh .git | cut -f1)"
echo "before: .git = $BEFORE_GIT"; git count-objects -vH | sed 's/^/  /'

# 0. keep a local copy of the third-party PDFs (the rewrite removes them from history, hence from a fresh clone)
run mkdir -p "$PDF_BACKUP"
if [ "$DRY_RUN" = "1" ]; then echo "DRY: cp literature/*.pdf $PDF_BACKUP/   (17 third-party + Large Prior.pdf)"; else cp -n literature/*.pdf "$PDF_BACKUP"/ 2>/dev/null || true; fi

# 1. paths file (regexes, Python syntax; filter-repo --invert-paths removes matches)
PATHS="$WORK.paths.txt"
if [ "$DRY_RUN" = "1" ]; then echo "DRY: write $PATHS:"; PATHS=/dev/stdout; fi
cat > "$PATHS" <<'PATHS_EOF'
regex:^(Data Applications|applications)/Air Quality/S08_.*\.csv$
regex:^(Data Applications|applications|archive/munich_rent/code)/(Munich Rent/)?Others/results[^/]*/
regex:^(Project_Paper/notes|paper/history)/[^/]+/(before|build)/main\.pdf$
regex:^(Simulations/Joint/NOTS|experiments/joint_upper_levels)/runs/[^/]+/metadata/monitor/history\.jsonl$
regex:^(Papers|literature)/(?!Large Prior\.pdf$)[^/]*\.pdf$
PATHS_EOF

# 2. fresh mirror clone (filter-repo wants a fresh clone; --no-local avoids hardlinks to the original)
run git clone --mirror --no-local "$REPO" "$WORK/mirror.git"
# 3. rewrite
if [ "$DRY_RUN" = "1" ]; then
  echo "DRY: (cd $WORK/mirror.git && git filter-repo --invert-paths --paths-from-file $WORK.paths.txt)"
else
  ( cd "$WORK/mirror.git" && git filter-repo --invert-paths --paths-from-file "$WORK.paths.txt" )
  ( cd "$WORK/mirror.git" && git reflog expire --expire=now --all && git gc --prune=now --aggressive -q )
fi
# 4. checks on the rewritten mirror
if [ "$DRY_RUN" != "1" ]; then
  cd "$WORK/mirror.git"
  n_old=$(git rev-list --all | wc -l); echo "commits after rewrite: $n_old (before: $(git -C "$REPO" rev-list --all | wc -l); emptied commits are pruned)"
  for pat in 'S08_.*\.csv' 'Others/results' 'before/main\.pdf' 'history\.jsonl'; do
    c=$(git log --all --name-only --format= | grep -cE "$pat" || true); [ "$c" = 0 ] || die "pattern $pat still in history ($c)"
  done
  git log --all --name-only --format= | grep -E '^(Papers|literature)/.*\.pdf$' | sort -u | grep -v 'Large Prior.pdf' && die "third-party PDF left" || true
  echo "largest blobs after rewrite:"; git rev-list --objects --all | git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' | awk '$1=="blob"' | sort -k3 -n -r | head -5
  echo "after: mirror size"; git count-objects -vH | sed 's/^/  /'
fi
# 5. work clone: hash map committed on top
if [ "$DRY_RUN" = "1" ]; then
  echo "DRY: git clone $WORK/mirror.git $WORK/work ; copy $WORK/mirror.git/filter-repo/commit-map -> engineering/E03_Repo_Organization/hash_map.tsv (header old<TAB>new); commit"
else
  git clone -q "$WORK/mirror.git" "$WORK/work"
  mkdir -p "$WORK/work/engineering/E03_Repo_Organization"
  awk 'NR==1{print "old\tnew"; next}{print $1 "\t" $2}' "$WORK/mirror.git/filter-repo/commit-map" > "$WORK/work/engineering/E03_Repo_Organization/hash_map.tsv"
  ( cd "$WORK/work" && git add engineering/E03_Repo_Organization/hash_map.tsv \
      && git commit -q -m "E-03: record old->new commit hash map after history rewrite (git filter-repo)" -m "$TRAILER" )
  git -C "$WORK/work" remote set-url origin "$ORIGIN_URL"
  echo "after: .git of the work clone = $(du -sh "$WORK/work/.git" | cut -f1)   (before: $BEFORE_GIT)"
fi
cat <<MSG

Handoff (HQ force-pushes; nobody else pushes meanwhile):
  cd $WORK/work && git push --force origin main
Then every other clone is stale:
  NOTS : re-clone at /projects/ml75/fb31/BQTF/repo (keep the ~/Bayesian-Quantile-Trend-Filtering symlink pointing there)
  Owls : mv ~/Bayesian-Quantile-Trend-Filtering ~/Bayesian-Quantile-Trend-Filtering.pre-rewrite && git clone $ORIGIN_URL ~/Bayesian-Quantile-Trend-Filtering
  PC   : see the one-line instruction in CHECKLIST.md
MSG
