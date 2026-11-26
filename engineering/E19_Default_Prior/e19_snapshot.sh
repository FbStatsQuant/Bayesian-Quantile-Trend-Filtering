#!/bin/bash
# Usage: bash e19_snapshot.sh EMPTY_SNAPSHOT_DIR VERIFIED_ENGINEERING_COMMIT
set -euo pipefail
(( $# == 2 )) || { echo 'Usage: e19_snapshot.sh EMPTY_SNAPSHOT_DIR VERIFIED_ENGINEERING_COMMIT' >&2; exit 2; }
snapshot=$(realpath -e "$1")
[[ -d "$snapshot" && -z "$(ls -A "$snapshot")" ]]
cd "$(git rev-parse --show-toplevel)"
sampler=63f2a56205b8d2ec311565db8c98874cd96754b2
engineering=$(git rev-parse --verify HEAD)
[[ "$engineering" == "$2" ]]
git merge-base --is-ancestor "$sampler" "$engineering"

sampler_files=(
    method/individual/Individual_Sampler_PMALA_Augmented.R
    method/individual/prox_admm_metric.cpp
    method/joint/prox_box_metric.cpp
)
e14=engineering/E14_Inner_Rerun
e19=engineering/E19_Default_Prior
original=experiments/interior_quantiles/individual_nots_20261003/source
git archive "$sampler" "${sampler_files[@]}" | tar -xf - -C "$snapshot"
git archive "$engineering" "$e14/e14_run.R" "$e14/e14_data.R" \
    "$e19/e19_run.R" "$e19/e19.slurm" "$original/Individual_Sampler_PMALA_Augmented.R" |
    tar -xf - -C "$snapshot"

for file in "${sampler_files[@]}"; do
    actual=$(git hash-object --no-filters "$snapshot/$file")
    [[ "$actual" == "$(git rev-parse "$sampler:$file")" ]]
    printf '%s  %s\n' "$actual" "$file"
done
printf 'Sampler-Commit: %s\nEngineering-Commit: %s\n' "$sampler" "$engineering" \
    > "$snapshot/run_manifest.dcf"
