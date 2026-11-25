#!/bin/bash
# usage: lane.sh "<name> <kv...>" "<name> <kv...>" ...   (runs sequentially, 1 core, from repo root)
cd /home/fb31/Bayesian-Quantile-Trend-Filtering
for spec in "$@"; do set -- $spec; Rscript experiments/pilots/lambda_mixing/run_variant.R "$@" > experiments/pilots/lambda_mixing/results/$1.log 2>&1; done
