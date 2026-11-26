"""Summarize saved output from accounting.sh. Run locally on Owls."""
import argparse
import math
import re
from pathlib import Path


def cpu_seconds(value):
    days, sep, clock = value.rpartition("-")
    return (86400 * int(days) if sep else 0) + sum(
        float(part) * 60**i for i, part in enumerate(reversed(clock.split(":")))
    )


def rss_mib(value):
    match = re.fullmatch(r"([0-9]+(?:[.][0-9]+)?)([KMGT])?", value)
    if match is None:
        raise ValueError(f"Invalid Slurm MaxRSS: {value!r}")
    factor = {None: 1024**-2, "K": 1024**-1, "M": 1, "G": 1024, "T": 1024**2}
    return float(match[1]) * factor[match[2]]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("mode", choices=("sim", "real"))
    parser.add_argument("accounting", type=Path)
    args = parser.parse_args()
    allocations, batches = {}, {}
    for line in args.accounting.read_text().splitlines():
        fields = line.split("|")
        if len(fields) != 7:
            continue
        job, state, cpu, elapsed, rss, _, exit_code = fields
        match = re.fullmatch(r"(\d+_\d+)([.]batch)?", job)
        if match is None:
            continue
        rows = batches if match[2] else allocations
        if match[1] in rows:
            raise SystemExit(f"Duplicate accounting record for {job}")
        rows[match[1]] = (state, cpu, elapsed, rss, exit_code)

    expected = 6 if args.mode == "sim" else 3
    if len(allocations) != expected or allocations.keys() != batches.keys():
        raise SystemExit("Pilot accounting is incomplete")
    if any(row[0] != "COMPLETED" or row[4] != "0:0" for row in allocations.values()):
        raise SystemExit("At least one pilot task did not complete successfully")

    seconds = [cpu_seconds(row[1]) for row in allocations.values()]
    if any(s <= 0 for s in seconds):
        raise SystemExit("Missing per-task Slurm TotalCPU")
    peak = max(rss_mib(row[3]) for row in batches.values())
    memory = math.ceil(max(1.5 * peak, peak + 256) / 128) * 128
    pilot_hours = sum(seconds) / 3600
    print(f"Pilot CPU: {pilot_hours:.6f} core-hours")
    print(f"Peak MaxRSS: {peak:.1f} MiB; rounded request with headroom: {memory}M")
    if args.mode == "sim":
        per_fit = sum(seconds) / expected
        projection = 1200 * per_fit / 3600 + pilot_hours
        print(f"Mean CPU: {per_fit:.3f} s/fit")
        print(f"Projected 1,200 fits plus pilot: {projection:.3f} core-hours")
        print(f"Remaining under the 80 core-hour cap: {80 - projection:.3f} core-hours (before ADMM)")
    else:
        print(f"Budget left under 40 core-hours: {40 - pilot_hours:.3f} core-hours (before detrendr)")
        print("Extrapolate using each pilot's executed sweeps before sizing the complete production fit.")


if __name__ == "__main__":
    main()
