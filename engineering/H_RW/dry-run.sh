#!/usr/bin/env bash
# Creates two new, remote-free mirrors outside the source checkout.
set -euo pipefail
umask 077
usage() { printf 'Usage: %s SOURCE_REPO ABSOLUTE_NEW_SCRATCH_DIR [STRIP_BLOB_IDS]\n' "$0" >&2; exit 2; }
[[ $# -ge 2 && $# -le 3 && "$2" = /* ]] || usage
# Prevent inherited Git context from redirecting operations to another checkout.
while IFS= read -r name; do unset "$name"; done < <(git rev-parse --local-env-vars)
scripts=$(cd -- "$(dirname -- "$0")" && pwd -P)
source=$(realpath -- "$1")
work=$(realpath -m -- "$2")
[[ "$work" = /tmp/* && ! -e "$work" && "$work" != "$source"/* ]] || usage
filter="$HOME/.local/bin/git-filter-repo"
[[ -x "$filter" ]] || { printf 'git-filter-repo missing\n' >&2; exit 2; }
strip=()
compare_strip=()
if [[ $# = 3 ]]; then
    ids=$(realpath -- "$3")
    strip=(--strip-blobs-with-ids "$ids")
    compare_strip=(--strip "$ids")
fi
mkdir -m 700 -- "$work"
git clone --mirror --no-local "$source" "$work/input.git"
git -C "$work/input.git" remote remove origin
# Restore tracking-ref tips as scratch refs if the source has any. Removing origin
# also removes refs/remotes/origin/* in a local mirror.
git -C "$work/input.git" fetch --no-tags "$source" 'refs/remotes/*:refs/h-rw/input-remote-tips/*'
git -C "$work/input.git" version > "$work/versions.log"
"$filter" --version >> "$work/versions.log"
du -sb "$work/input.git" > "$work/before-size.log"
git -C "$work/input.git" count-objects -v >> "$work/before-size.log"
python3 "$scripts/audit.py" scan "$work/input.git" "$work/before" --pdf-text > "$work/before.log"
python3 "$scripts/audit.py" checksums "$work/input.git" > "$work/before-checksums.tsv"
git clone --mirror --no-local "$work/input.git" "$work/rewrite.git"
git -C "$work/rewrite.git" remote remove origin
(
    cd -- "$work/rewrite.git"
    [[ "$(git rev-parse --is-bare-repository)" = true && -z "$(git remote)" ]]
    export BQTF_PROTECTED_PATHS="$work/before/protected.nul"
    # --force is confined to this new mirror, which has no remote.
    "$filter" --force --sensitive-data-removal --no-fetch         --preserve-commit-hashes --preserve-commit-encoding         --prune-empty never --prune-degenerate never         --invert-paths --paths-from-file "$scripts/remove-paths.txt"         "${strip[@]}" --replace-text "$scripts/replace-text.txt"         --file-info-callback "$scripts/file-info.py"
) > "$work/rewrite.log" 2>&1
git clone --mirror --no-local "$work/rewrite.git" "$work/verified.git"
git -C "$work/verified.git" remote remove origin
git -C "$work/verified.git" fsck --full --no-reflogs > "$work/fsck.log" 2>&1
du -sb "$work/verified.git" > "$work/after-size.log"
git -C "$work/verified.git" count-objects -v >> "$work/after-size.log"
map="$work/rewrite.git/filter-repo/commit-map"
awk 'NR == 1 {print "old\tnew"; next} {print $1 "\t" $2}' "$map" > "$work/hash_map.tsv"
python3 "$scripts/audit.py" checksums "$work/verified.git" > "$work/after-checksums.tsv"
python3 "$scripts/audit.py" compare "$work/input.git" "$work/verified.git" "$map"     "$work/before/protected.nul" "${compare_strip[@]}" > "$work/compare.log"
python3 "$scripts/audit.py" scan "$work/verified.git" "$work/after" --pdf-text > "$work/after.log"
printf 'Dry-run reports are in %s\n' "$work"
