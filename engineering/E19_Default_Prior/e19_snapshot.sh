#!/bin/bash
# Usage: bash e19_snapshot.sh EMPTY_SNAPSHOT_DIR VERIFIED_ENGINEERING_COMMIT
set -euo pipefail
(( $# == 2 )) || { echo 'Usage: e19_snapshot.sh EMPTY_SNAPSHOT_DIR VERIFIED_ENGINEERING_COMMIT' >&2; exit 2; }
snapshot=$(realpath -e "$1")
[[ -d "$snapshot" && -z "$(ls -A "$snapshot")" ]]
if [[ "$(git rev-parse --is-bare-repository)" == false ]]; then
    cd "$(git rev-parse --show-toplevel)"
fi
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
data_revision=01526e1
generator_blob=b2023dc92bb6d3a51136a6013fd63d7b6d6ee7d9
data_files=("$e14/e14_data.R" "$e14/DATA_MATCH.md" "$original/Individual_Sampler_PMALA_Augmented.R")
git archive "$sampler" "${sampler_files[@]}" | tar -xf - -C "$snapshot"
git archive "$data_revision" "${data_files[@]}" | tar -xf - -C "$snapshot"
git archive "$engineering" "$e14/e14_run.R" "$e19/e19_run.R" "$e19/e19.slurm" |
    tar -xf - -C "$snapshot"

for file in "${sampler_files[@]}"; do
    actual=$(git hash-object --no-filters "$snapshot/$file")
    [[ "$actual" == "$(git rev-parse "$sampler:$file")" ]]
    printf '%s  %s\n' "$actual" "$file"
done
[[ "$generator_blob" == "$(git rev-parse "$data_revision:$e14/e14_data.R")" ]]
for file in "${data_files[@]}"; do
    actual=$(git hash-object --no-filters "$snapshot/$file")
    [[ "$actual" == "$(git rev-parse "$data_revision:$file")" ]]
    printf '%s  %s\n' "$actual" "$file"
done
printf 'Sampler-Commit: %s\nEngineering-Commit: %s\nGenerator-Blob: %s\n' \
    "$sampler" "$engineering" "$generator_blob" \
    > "$snapshot/run_manifest.dcf"
