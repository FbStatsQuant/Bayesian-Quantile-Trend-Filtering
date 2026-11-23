#!/bin/bash
# retry owls_run (never bypass) until accepted. usage: run_retry_v3.sh N -- cmd...
N=$1; shift; shift
while true; do ~/.config/bvs-hq/owls/owls_run -j $N -- "$@"; rc=$?; [ $rc -ne 75 ] && exit $rc; sleep 20; done
