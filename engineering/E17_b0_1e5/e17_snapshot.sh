#!/bin/bash
# Usage: bash e17_snapshot.sh EMPTY_SNAPSHOT_DIR
set -euo pipefail
(( $# == 1 )) || { echo "Usage: e17_snapshot.sh EMPTY_SNAPSHOT_DIR" >&2; exit 2; }
snapshot=$(realpath -e "$1")
[[ -d "$snapshot" && -z "$(ls -A "$snapshot")" ]]
repo=$(git rev-parse --show-toplevel)
cd "$repo"
sampler=63f2a56205b8d2ec311565db8c98874cd96754b2
engineering=$(git rev-parse --verify HEAD)
git cat-file -e "$sampler^{commit}"
e17=engineering/E17_b0_1e5
e14=engineering/E14_Inner_Rerun
e15=engineering/E15_Extreme_Individual
git archive "$sampler" method/individual/Individual_Sampler_PMALA_Augmented.R \
    method/individual/prox_admm_metric.cpp method/joint/prox_box_metric.cpp |
  tar -xf - -C "$snapshot"
git archive "$engineering" "$e17/e17_run.R" "$e17/e17.slurm" "$e17/e17_pilot.R" \
    "$e14/e14_run.R" "$e14/e14_data.R" "$e15/e15_run.R" "$e15/e15_data.R" \
    experiments/interior_quantiles/individual_nots_20261003/source/Individual_Sampler_PMALA_Augmented.R \
    experiments/extreme_quantiles/packages/Extreme_Individual/common_extreme.R |
  tar -xf - -C "$snapshot"
printf 'Sampler-Commit: %s\nEngineering-Commit: %s\n' "$sampler" "$engineering" \
  > "$snapshot/run_manifest.dcf"
