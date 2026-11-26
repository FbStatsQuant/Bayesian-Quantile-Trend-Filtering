#!/bin/bash
# Run only after NOTS GO. Hold both shim lanes so this uses one connection.
set -euo pipefail
lane=${1:?Usage: nots.sh control|bulk SSH_ARGS...}
shift
case "$lane" in
    control) other=bulk; limit=240 ;;
    bulk) other=control; limit=600 ;;
    *) exit 2 ;;
esac
root=$(git -C "$(dirname "$0")" rev-parse --show-toplevel)
shim="$root/ops/bin/sshlock"
export PATH="$shim:$PATH" NOTS_SSH_LANE="$other" NOTS_SSH_LOCK_WAIT_S=15
source "$shim/lock_lib.sh"

state="$root/tmp/E17/ssh-backoff"
mkdir -p "$(dirname "$state")"
check_window() {
    local now ct cutoff
    now=$(date +%s)
    if [[ -r "$state" ]] && (( now < $(cat "$state") )); then
        echo 'NOTS backoff is still active' >&2
        return 1
    fi
    ct=$(TZ=CST6CDT date +%H%M%S)
    if (( 10#$ct >= 185500 && 10#$ct < 194500 )); then
        echo 'NOTS SSH blackout is active' >&2
        return 1
    fi
    if (( 10#$ct < 185500 )); then
        if [[ $lane == bulk ]]; then
            cutoff=$(TZ=CST6CDT date -d 'today 18:50:00' +%s)
        else
            cutoff=$(TZ=CST6CDT date -d 'today 18:55:00' +%s)
        fi
        available=$((cutoff - now - NOTS_SSH_LOCK_WAIT_S - 15))
        if (( available <= 0 )); then
            echo 'Insufficient time before the NOTS cutoff' >&2
            return 1
        fi
        if (( available < limit )); then limit=$available; fi
    fi
}
record_backoff() {
    date -d '15 minutes' +%s > "$state"
    echo 'NOTS connection failed. Back off for 15 minutes and verify state before retrying.' >&2
}
check_window
nots_lock_acquire || { record_backoff; exit 255; }
trap nots_lock_release EXIT
check_window
export NOTS_SSH_LANE="$lane" NOTS_CONTROL_WALL_S="$limit"
status=0
if [[ $lane == bulk ]]; then
    timeout --foreground -k 10 "$limit" ssh nots "$@" || status=$?
else
    ssh nots "$@" || status=$?
fi
if [[ $status == 124 || $status == 137 || $status == 255 ]]; then record_backoff; fi
exit "$status"
