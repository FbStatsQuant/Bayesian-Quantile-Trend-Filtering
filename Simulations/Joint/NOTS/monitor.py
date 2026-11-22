"""Read-only persistent Slurm/log monitor; no simulation or result aggregation."""
import collections
import datetime
import glob
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import time

root = Path(sys.argv[1]).resolve()
array, process, compare = sys.argv[2:5]
monitor_dir = root / "metadata" / "monitor"
monitor_dir.mkdir(exist_ok=True)

def command(args):
    p = subprocess.run(args, text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=30)
    return {"returncode": p.returncode, "stdout": p.stdout, "stderr": p.stderr}

while True:
    now = datetime.datetime.now(datetime.timezone.utc).isoformat()
    queue = command(["squeue", "-r", "-j", ",".join([array, process, compare]), "-h", "-o", "%i|%T|%M|%R"])
    accounting = command(["sacct", "-X", "-j", ",".join([array, process, compare]), "--noheader", "--parsable2", "--format=JobID,State,ExitCode,Elapsed"])
    progress = []
    for name in glob.glob(str(root / "logs" / f"joint_VS_300_{array}_*.out")):
        with open(name, "rb") as stream:
            stream.seek(max(0, os.path.getsize(name) - 4096))
            tail = stream.read().decode(errors="replace")
        rows = re.findall(r"^it\s+(\d+).*?\| ([\d.]+)s$", tail, re.MULTILINE)
        progress.append({"task": int(Path(name).stem.rsplit("_", 1)[1]),
            "sweep": int(rows[-1][0]) if rows else 0,
            "sampler_seconds": float(rows[-1][1]) if rows else None,
            "success_logged": "WORKER_SUCCESS" in tail})
    record = {"utc": now, "pid": os.getpid(), "queue": queue,
        "accounting": accounting, "progress": progress,
        "successful_tasks": len(list((root / "tasks").glob("*/seed_*/SUCCESS"))),
        "stderr_files_nonempty": [str(p) for p in (root / "logs").glob("*.err") if p.stat().st_size]}
    (monitor_dir / "latest.json").write_text(json.dumps(record, indent=2) + "\n")
    with (monitor_dir / "history.jsonl").open("a") as f:
        f.write(json.dumps(record) + "\n")
    print(now, "success", record["successful_tasks"], "of 300", flush=True)
    states = dict(line.split("|")[:2] for line in accounting["stdout"].splitlines() if "|" in line)
    bad = {"FAILED", "CANCELLED", "TIMEOUT", "OUT_OF_MEMORY", "NODE_FAIL"}
    if states.get(compare) == "COMPLETED":
        print("MONITOR_COMPLETE", flush=True)
        break
    if states.get(process, "").split()[0:1] in [[s] for s in bad] or states.get(compare, "").split()[0:1] in [[s] for s in bad]:
        print("MONITOR_REQUIRES_ATTENTION", states, flush=True)
        sys.exit(1)
    time.sleep(60)
