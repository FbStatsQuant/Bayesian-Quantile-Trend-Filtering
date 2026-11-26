#!/usr/bin/env bash
# Build the new public candidate from one private commit in a new /tmp directory.
set -euo pipefail
umask 077
usage() { printf 'Usage: %s SOURCE_COMMIT ABSOLUTE_NEW_OUTPUT_DIR\n' "$0" >&2; exit 2; }
[[ $# = 2 && "$2" = /* ]] || usage
while IFS= read -r name; do unset "$name"; done < <(git rev-parse --local-env-vars)
export GIT_NO_REPLACE_OBJECTS=1 GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1
export PYTHONDONTWRITEBYTECODE=1
scripts=$(cd -- "$(dirname -- "$0")" && pwd -P)
source=$(git -C "$scripts" rev-parse --show-toplevel)
pin=$(git -C "$source" rev-parse --verify --end-of-options "$1^{commit}")
out=$(realpath -m -- "$2")
[[ "$out" = /tmp/* && ! -e "$out" && "$out" != "$source" && "$out" != "$source"/* ]] || usage
filter="$HOME/.local/bin/git-filter-repo"
[[ -x "$filter" && "$("$filter" --version)" = a40bce548d2c ]] || {
    printf 'Expected the rehearsed git-filter-repo build a40bce548d2c\n' >&2
    exit 2
}
mkdir -m 700 -- "$out" "$out/private"
work=$(mktemp -d "$out/.build.XXXXXXXX")
trap 'rm -rf -- "$work"' EXIT
evidence="$out/private"
export TMPDIR="$work"
export BQTF_BUILD_EVIDENCE="$work"
export PYTHONPATH="$scripts"

# Fetch the explicit commit into an empty repository, without importing source refs.
git init --bare --template= --initial-branch=main "$work/input.git" > "$evidence/input.log"
git -C "$work/input.git" fetch --no-tags --no-write-fetch-head "$source"     "$pin:refs/heads/main" >> "$evidence/input.log" 2>&1
[[ "$(git -C "$work/input.git" rev-parse HEAD)" = "$pin" ]]
{
    printf 'source commit: %s\n' "$pin"
    git version
    "$filter" --version
    (cd -- "$scripts" && sha256sum build.sh public_build.py audit.py replace-text.txt remove-paths.txt \
        message-fingerprints.txt strip-pdfs.txt SPOD_DATA.md export_spod.R)
    du -sb "$work/input.git"
    git -C "$work/input.git" count-objects -v
} > "$evidence/input-summary.txt"
git -C "$work/input.git" show "$pin:engineering/E03_Repo_Organization/migration/strip_blobs.txt"     > "$work/strip.txt"
cat "$scripts/strip-pdfs.txt" >> "$work/strip.txt"

git clone --mirror --no-local "$work/input.git" "$work/rewrite.git"
git -C "$work/rewrite.git" remote remove origin
python3 "$scripts/audit.py" scan "$work/input.git" "$work/initial" > "$evidence/input-audit.txt"
python3 "$scripts/public_build.py" prepare "$work/input.git" "$work/rewrite.git"     "$work" "$work/initial/protected.nul" "$work/strip.txt"
cp -- "$work"/{resealed_digests,historical_unresolved,historical_checksum_differences,archived_manifest_targets}.tsv "$evidence/"
(
    cd -- "$work/rewrite.git"
    [[ "$(git rev-parse --is-bare-repository)" = true && -z "$(git remote)" ]]
    "$filter" --force --sensitive-data-removal --no-fetch         --preserve-commit-hashes --preserve-commit-encoding         --prune-empty never --prune-degenerate never         --message-callback 'import public_build; return public_build.edit_message(message)'         --commit-callback 'import public_build; public_build.callback_commit(commit)'
) > "$evidence/filter-repo.log" 2>&1
map="$work/rewrite.git/filter-repo/commit-map"
awk 'NR == 1 {print "old\tnew"; next} {print $1 "\t" $2}' "$map" > "$work/hash_map.tsv"
cp -- "$work/hash_map.tsv" "$evidence/"

git clone --mirror --no-local "$work/rewrite.git" "$work/verified.git"
git -C "$work/verified.git" remote remove origin
[[ "$(git -C "$work/verified.git" for-each-ref --format='%(refname)')" = refs/heads/main ]]
[[ -z "$(git -C "$work/verified.git" remote)" ]]
git -C "$work/verified.git" fsck --full --no-reflogs > "$evidence/fsck.txt" 2>&1
python3 "$scripts/public_build.py" verify "$work/input.git" "$work/verified.git" "$work"     > "$evidence/commit-verification.txt"
python3 "$scripts/audit.py" checksums "$work/verified.git" > "$evidence/public-checksums.tsv"
python3 "$scripts/audit.py" scan "$work/verified.git" "$evidence/scan" --pdf-text     > "$evidence/public-audit.txt"
python3 "$scripts/public_build.py" gate "$evidence/public-audit.txt" "$evidence/scan"     "$evidence/public-checksums.tsv"
{
    printf 'public commit: %s\n' "$(git -C "$work/verified.git" rev-parse HEAD)"
    du -sb "$work/verified.git"
    git -C "$work/verified.git" count-objects -v
    cat "$evidence/commit-verification.txt" "$evidence/public-audit.txt"
    printf '%s\n' 'Complete the manual verification and handoff checklist before publication.'
} > "$evidence/verification.txt"
mv -- "$work/verified.git" "$out/public.git"
printf 'Public candidate: %s/public.git\nPrivate verification report: %s/verification.txt\n' "$out" "$evidence"
