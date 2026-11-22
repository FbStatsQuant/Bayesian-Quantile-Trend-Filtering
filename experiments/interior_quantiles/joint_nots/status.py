"""Read-only progress view of a run: queue states, completed tasks per cell, sweep progress."""
import collections
import glob
import os
from pathlib import Path
import re
import statistics
import subprocess
import sys

root = Path(sys.argv[1]).resolve()
jobs = [line.split("\t")[1] for line in (root / "metadata" / "array_jobs.tsv").read_text().splitlines() if line]
q = subprocess.run(["squeue", "-r", "-h", "-j", ",".join(jobs), "-o", "%T"], text=True, capture_output=True)
print("Queue:", dict(collections.Counter(q.stdout.split())))
done = collections.Counter()
for f in glob.glob(str(root / "tasks" / "*" / "*" / "*" / "seed_*" / "SUCCESS")):
    parts = Path(f).parts
    done[parts[-5:-2]] += 1
n_tasks = sum(1 for line in (root / "metadata" / "task_index.tsv").read_text().splitlines() if line)
print("Completed:", sum(done.values()), "/", n_tasks)
for key in sorted(done):
    print("  ", "/".join(key), done[key], "/ 100")
sweeps = []
for name in glob.glob(str(root / "logs" / "slurm" / "joint_interior_*.out")):
    with open(name, "rb") as stream:
        stream.seek(max(0, os.path.getsize(name) - 2048))
        tail = stream.read().decode(errors="replace")
    if "WORKER_SUCCESS" in tail:
        continue
    hits = re.findall(r"^it\s+(\d+)", tail, re.M)
    if hits:
        sweeps.append(int(hits[-1]))
if sweeps:
    print("Running workers:", len(sweeps), "sweeps min/median/max:", min(sweeps), statistics.median(sweeps), max(sweeps), "/ 30000")
errs = [f for f in glob.glob(str(root / "logs" / "slurm" / "*.err")) if os.path.getsize(f) > 0]
print("Nonempty stderr files:", len(errs))
