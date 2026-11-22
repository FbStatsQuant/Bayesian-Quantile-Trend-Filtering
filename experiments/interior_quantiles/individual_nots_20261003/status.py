"""Run on NOTS: python3 status.py RUN_DIR. Saves observed task/job status without launching jobs."""
import csv
from collections import Counter
from datetime import datetime, timezone
import json
from pathlib import Path
import subprocess
import sys

project_root = Path("/home/fb31/projects/Quant_Reg/Inner_Individual")
run = Path(sys.argv[1]).resolve()
for path in (Path(__file__).resolve(), run):
    if path != project_root and project_root not in path.parents:
        raise SystemExit(f"Campaign scripts and run directories must stay under {project_root}: {path}")
with (run / "metadata/task_manifest.csv").open() as f:
    manifest = list(csv.DictReader(f))
counts = Counter()
task_status = []
for row in manifest:
    task = run / "tasks" / row["baseline"] / row["noise"] / f'tau_{float(row["tau"]):.2f}' / f'seed_{int(row["seed"]):03d}'
    state = "complete" if (task / "SUCCESS").is_file() else (
        "locked_check_scheduler" if (task / "worker.lock").exists() else
        "attempted_without_success" if list(task.glob("attempt_*")) else "not_started")
    counts[state] += 1
    task_status.append(dict(row, state=state))
jobs = []
job_file = run / "metadata/array_jobs.tsv"
if job_file.exists():
    jobs = [line.split("\t")[1] for line in job_file.read_text().splitlines()]
process_job = run / "metadata/process_job_id.txt"
if process_job.exists():
    jobs.append(process_job.read_text().strip())
stamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%S_%fZ")
out = run / "metadata" / "monitor" / stamp
out.mkdir(parents=True)
report = {"utc": stamp, "counts": dict(counts), "jobs": jobs,
          "note": "SUCCESS records completion, not MCMC convergence. Locks require scheduler inspection."}
for name, command in (
    ("squeue", ["squeue", "-j", ",".join(jobs), "-o", "%.25i %.12T %.12M %.40R"]),
    ("sacct", ["sacct", "-j", ",".join(jobs), "--format=JobID,JobName,State,ExitCode,Elapsed,MaxRSS", "--parsable2"])
):
    if not jobs:
        continue
    result = subprocess.run(command, capture_output=True, text=True)
    (out / f"{name}.txt").write_text(result.stdout + result.stderr)
    report[f"{name}_exit_status"] = result.returncode
with (out / "tasks.csv").open("w", newline="") as f:
    writer = csv.DictWriter(f, fieldnames=list(task_status[0]))
    writer.writeheader(); writer.writerows(task_status)
(out / "status.json").write_text(json.dumps(report, indent=2))
print(json.dumps(report, indent=2))
print(f"Saved observations: {out}")
