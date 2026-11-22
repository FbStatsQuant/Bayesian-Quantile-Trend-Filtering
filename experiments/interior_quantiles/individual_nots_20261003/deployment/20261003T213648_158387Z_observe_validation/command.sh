#!/bin/bash
set -euo pipefail
cd /home/fb31/projects/Quant_Reg/Inner_Individual
date -u --iso-8601=seconds
squeue -j 1785936 -o '%.24i %.12T %.12M %.35R'
sacct -j 1785936 --format=JobID,State,ExitCode,Elapsed,MaxRSS --parsable2
v=validation/check_20261003T213509Z_1785936
printf 'SUCCESS_COUNT='; find "$v/tasks" -name SUCCESS -type f | wc -l
tail -8 validate_1785936.err
if [[ -f "$v/metadata/validation_exit.txt" ]]; then cat "$v/metadata/validation_exit.txt"; fi
if [[ -f "$v/logs/raw_validation.out" ]]; then tail -5 "$v/logs/raw_validation.out"; fi
find "$v/tasks" -name failure.rds.txt -exec cat {} \;
if [[ -f validation/APPROVED_PACKAGE_SHA256 ]]; then cat validation/APPROVED_PACKAGE_SHA256; fi
