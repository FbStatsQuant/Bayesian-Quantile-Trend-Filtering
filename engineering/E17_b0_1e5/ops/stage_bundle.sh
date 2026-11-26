#!/bin/bash
# Usage: stage_bundle.sh BUNDLE SHA256
set -euo pipefail
(( $# == 2 ))
bundle=$1 digest=$2
[[ $digest =~ ^[0-9a-f]{64}$ ]]
printf '%s  %s\n' "$digest" "$bundle" | sha256sum -c
ops=$(cd "$(dirname "$0")" && pwd)
root=$(git -C "$ops" rev-parse --show-toplevel)
git -C "$root" bundle verify "$bundle"
head=$(git bundle list-heads "$bundle" HEAD | awk '$2=="HEAD"{print $1}')
[[ $head =~ ^[0-9a-f]{40}$ ]]

remote=$(cat <<'REMOTE'
set -euo pipefail
umask 077
expected=$1 digest=$2
mkdir -p "$HOME/BQTF/tmp"
dest="$HOME/BQTF/tmp/e17-code-$expected"
[[ ! -e "$dest" ]]
incoming=$(mktemp -d "$HOME/BQTF/tmp/e17-bundle.XXXXXXXX")
trap 'rm -rf -- "$incoming"' EXIT
cat > "$incoming/e17.bundle"
printf '%s  %s\n' "$digest" "$incoming/e17.bundle" | sha256sum -c
repo="$incoming/repo"
git init -q "$repo"
git -C "$repo" bundle verify "$incoming/e17.bundle"
git -C "$repo" fetch -q "$incoming/e17.bundle" HEAD
git -C "$repo" update-ref HEAD FETCH_HEAD
head=$(git -C "$repo" rev-parse HEAD)
printf 'Owls HEAD %s\nNOTS HEAD %s\n' "$expected" "$head"
test "$head" = "$expected"
mkdir "$incoming/code"
e17=engineering/E17_b0_1e5
git -C "$repo" show "HEAD:$e17/e17_snapshot.sh" > "$incoming/snapshot.sh"
(cd "$repo" && bash "$incoming/snapshot.sh" "$incoming/code")
git -C "$repo" archive "$head" "$e17/ops/validate_outputs.R" |
    tar -xf - -C "$incoming/code"
(
    cd "$incoming/code"
    sed 's@/runs/E17-\*)@/tmp/e17-results/E17-*)@; s@under ~/BQTF/runs@under ~/BQTF/tmp/e17-results@' \
        "$e17/e17.slurm" > "$e17/e17_private.slurm"
    grep -Fq '/tmp/e17-results/E17-*)' "$e17/e17_private.slurm"
    bash -n "$e17/e17_private.slurm"
    test "$(awk '/^Engineering-Commit:/{print $2}' run_manifest.dcf)" = "$head"
    find . -type f -print0 | LC_ALL=C sort -z | xargs -0 sha256sum > "$incoming/hashes"
    mv "$incoming/hashes" SHA256SUMS
    sha256sum -c --quiet SHA256SUMS
)
mv -T -- "$incoming/code" "$dest"
printf 'Staged %s\n' "$dest"
REMOTE
)
printf -v cmd ' %q' bash -c "$remote" e17-stage "$head" "$digest"
bash "$ops/nots.sh" bulk "$cmd" < "$bundle"
