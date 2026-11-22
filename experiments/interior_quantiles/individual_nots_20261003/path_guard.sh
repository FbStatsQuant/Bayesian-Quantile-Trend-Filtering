#!/bin/bash
# All campaign scripts and code snapshots on NOTS stay under this project folder.
readonly INNER_INDIVIDUAL_ROOT=/home/fb31/projects/Quant_Reg/Inner_Individual
require_inner_individual_path() {
  local resolved
  resolved=$(realpath -e -- "$1") || return 2
  case "$resolved" in
    "$INNER_INDIVIDUAL_ROOT"|"$INNER_INDIVIDUAL_ROOT"/*) ;;
    *) printf 'Campaign scripts must stay under %s; rejected %s\n' "$INNER_INDIVIDUAL_ROOT" "$resolved" >&2; return 2 ;;
  esac
}
require_inner_individual_path "${BASH_SOURCE[0]}"
