#!/bin/bash
# Usage: bash e18_snapshot.sh EMPTY_SNAPSHOT_DIR
set -euo pipefail
(( $# == 1 )) || { echo 'Usage: e18_snapshot.sh EMPTY_SNAPSHOT_DIR' >&2; exit 2; }
snapshot=$(realpath -e "$1")
[[ -d "$snapshot" && -z "$(ls -A "$snapshot")" ]]
cd "$(git rev-parse --show-toplevel)"
sampler=63f2a56205b8d2ec311565db8c98874cd96754b2
engineering=$(git rev-parse --verify HEAD)
e18=engineering/E18_Air_Refit
air=experiments/air_simulation
git archive "$sampler" method/individual/Individual_Sampler_PMALA_Augmented.R \
  method/individual/prox_admm_metric.cpp method/joint/prox_box_metric.cpp |
  tar -xf - -C "$snapshot"
git archive "$engineering" "$e18" engineering/E14_Inner_Rerun/e14_run.R \
  "$air/drivers" "$air/onizuka_laplace_20261023/attempt_20261023T171713_511660/results.rds" \
  experiments/extreme_quantiles/packages/Extreme_Onizuka/source/BQTF-function.R |
  tar -xf - -C "$snapshot"
printf 'Sampler-Commit: %s\nEngineering-Commit: %s\n' "$sampler" "$engineering" \
  > "$snapshot/run_manifest.dcf"
