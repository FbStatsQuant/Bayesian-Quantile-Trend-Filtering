#!/bin/bash
# All campaign scripts and code snapshots on NOTS stay under this package folder.
readonly PACKAGE_ROOT=/home/fb31/projects/Quant_Reg/Inner_Individual/S_b00005
require_package_path() {
  local resolved
  resolved=$(realpath -e -- "$1") || return 2
  case "$resolved" in
    "$PACKAGE_ROOT"|"$PACKAGE_ROOT"/*) ;;
    *) printf 'Campaign scripts must stay under %s; rejected %s\n' "$PACKAGE_ROOT" "$resolved" >&2; return 2 ;;
  esac
}
require_package_path "${BASH_SOURCE[0]}"
