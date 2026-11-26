#!/bin/bash
# Usage: stage.sh BUNDLE SHA256 BUNDLED_SNAPSHOT_SCRIPT
set -euo pipefail
(( $# == 3 ))
bundle=$1 digest=$2 snapshot=$3
[[ $digest =~ ^[0-9a-f]{64}$ && $snapshot =~ ^engineering/E18_Air_Refit/[A-Za-z0-9_/-]+[.]sh$ ]]
root=$(git -C "$(dirname "$0")" rev-parse --show-toplevel)
printf '%s  %s\n' "$digest" "$bundle" | sha256sum -c
git -C "$root" bundle verify "$bundle"
head=$(git bundle list-heads "$bundle" HEAD | awk '$2=="HEAD"{print $1}')
[[ $head =~ ^[0-9a-f]{40}$ ]]
remote=$(cat <<'REMOTE'
set -euo pipefail
umask 077
head=$1 digest=$2 snapshot=$3
root="$HOME/BQTF/tmp"
dest="$root/e18-code-$head"
mkdir -p "$root"
[[ ! -e "$dest" ]]
scratch=$(mktemp -d "$root/e18-bundle.XXXXXXXX")
trap 'rm -rf -- "$scratch"' EXIT
cat > "$scratch/e18.bundle"
printf '%s  %s\n' "$digest" "$scratch/e18.bundle" | sha256sum -c
repo="$scratch/repo"
git init -q "$repo"
git -C "$repo" bundle verify "$scratch/e18.bundle"
git -C "$repo" fetch -q "$scratch/e18.bundle" HEAD
git -C "$repo" update-ref HEAD FETCH_HEAD
remote_head=$(git -C "$repo" rev-parse HEAD)
printf 'Owls HEAD %s\nNOTS HEAD %s\n' "$head" "$remote_head"
test "$remote_head" = "$head"
mkdir "$scratch/code"
git -C "$repo" show "HEAD:$snapshot" > "$scratch/snapshot.sh"
(cd "$repo" && bash "$scratch/snapshot.sh" "$scratch/code")
(
    cd "$scratch/code"
    slurm=engineering/E18_Air_Refit/e18
    sed 's@/runs/E18-\*)@/tmp/e18-results/E18-*)@' "$slurm.slurm" > "${slurm}_private.slurm"
    grep -Fq '/tmp/e18-results/E18-*)' "${slurm}_private.slurm"
    bash -n "${slurm}_private.slurm"
    find . -type f ! -name SHA256SUMS -print0 | LC_ALL=C sort -z | xargs -0 sha256sum > "$scratch/hashes"
    test -s "$scratch/hashes"
    mv "$scratch/hashes" SHA256SUMS
    sha256sum -c --quiet SHA256SUMS
)
mv -T "$scratch/code" "$dest"
printf 'Staged %s\n' "$dest"
REMOTE
)
printf -v cmd ' %q' bash -c "$remote" e18-stage "$head" "$digest" "$snapshot"
bash "$root/engineering/E17_b0_1e5/ops/nots.sh" bulk "$cmd" < "$bundle"
