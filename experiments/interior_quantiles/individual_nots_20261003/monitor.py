"""Persistently inspect this NOTS campaign every ten minutes; never submit jobs."""
from datetime import datetime, timezone
from pathlib import Path
import json
import os
import subprocess
import sys
import time

root = Path("/home/fb31/projects/Quant_Reg/Inner_Individual")
run = Path(sys.argv[1]).resolve()
if root not in run.parents or root not in Path(__file__).resolve().parents:
    raise SystemExit("Monitor must stay within Inner_Individual")
meta = run / "metadata" / "monitor"
meta.mkdir(exist_ok=True)
(meta / "monitor_pid.txt").write_text(str(os.getpid()) + "\n")
jobs = [line.split("\t")[1] for line in (run / "metadata/array_jobs.tsv").read_text().splitlines()]
jobs.append((run / "metadata/process_job_id.txt").read_text().strip())
terminal = {"COMPLETED", "FAILED", "CANCELLED", "TIMEOUT", "OUT_OF_MEMORY", "NODE_FAIL", "PREEMPTED", "BOOT_FAIL", "DEADLINE", "REVOKED"}
while True:
    started = time.monotonic()
    stamp = datetime.now(timezone.utc).isoformat()
    result = subprocess.run([sys.executable, str(run / "code/status.py"), str(run)],
                            stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
    print(stamp, "STATUS_EXIT", result.returncode, result.stdout, flush=True)
    accounting = subprocess.run(["sacct", "-X", "-n", "-P", "-j", ",".join(jobs),
        "--format=JobIDRaw,State,ExitCode"], capture_output=True, text=True)
    queue = subprocess.run(["squeue", "-h", "-j", ",".join(jobs), "-o", "%i|%T"],
                            capture_output=True, text=True)
    states = {}
    for line in accounting.stdout.splitlines():
        fields = line.split("|")
        if len(fields) >= 3:
            states[fields[0]] = {"state": fields[1].split()[0].rstrip("+"), "exit_code": fields[2]}
    payload = dict(utc=stamp, pid=os.getpid(), status_exit=result.returncode,
                   sacct_exit=accounting.returncode, squeue_exit=queue.returncode,
                   queue=queue.stdout, states=states, interval_seconds=600)
    (meta / "latest.json.tmp").write_text(json.dumps(payload, indent=2))
    os.replace(str(meta / "latest.json.tmp"), str(meta / "latest.json"))
    process_id = jobs[-1]
    if (result.returncode == 0 and accounting.returncode == 0 and queue.returncode == 0
            and not queue.stdout.strip() and process_id in states
            and states[process_id]["state"] in terminal):
        (meta / "monitor_finished.json").write_text(json.dumps(payload, indent=2))
        print("MONITOR_FINISHED", stamp, flush=True)
        break
    time.sleep(max(1, 600 - (time.monotonic() - started)))
