#!/bin/bash
# Campaign scripts and code snapshots stay inside the four Extreme_* project folders on NOTS.
readonly EXTREME_BASE=/home/fb31/projects/Quant_Reg
require_extreme_path() {
  local resolved
  resolved=$(realpath -e -- "$1") || return 2
  case "$resolved" in
    "$EXTREME_BASE"/Extreme_Individual|"$EXTREME_BASE"/Extreme_Individual/*) ;;
    "$EXTREME_BASE"/Extreme_admm|"$EXTREME_BASE"/Extreme_admm/*) ;;
    "$EXTREME_BASE"/Extreme_Onizuka|"$EXTREME_BASE"/Extreme_Onizuka/*) ;;
    "$EXTREME_BASE"/Extreme_Joint_Sampler|"$EXTREME_BASE"/Extreme_Joint_Sampler/*) ;;
    *) printf 'Campaign scripts must stay under %s/Extreme_*; rejected %s\n' "$EXTREME_BASE" "$resolved" >&2; return 2 ;;
  esac
}
require_extreme_path "${BASH_SOURCE[0]}"
