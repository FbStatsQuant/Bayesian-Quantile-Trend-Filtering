#!/usr/bin/env python3
"""Schedule one single-threaded R process per admitted Owls core."""
import argparse
import csv
import fcntl
import os
from pathlib import Path
import signal
import subprocess
import time
from datetime import datetime


HERE = Path(__file__).resolve().parent
GIB_KIB = 1024 ** 2
FREE_RESERVE = 15 * GIB_KIB
CPU_LIMIT_SECONDS = 160 * 3600
RUNTIME_ENV = dict(os.environ, MAKEFLAGS="-j1", R_LIBS_USER=":".join((
    str(Path.home() / "R/x86_64-redhat-linux-gnu-library/4.6"),
    str(Path.home() / "R/library"),
)))


def note(message):
    print(f"[{datetime.now().astimezone().isoformat(timespec='seconds')}] {message}", flush=True)


def mem_available():
    with open("/proc/meminfo") as meminfo:
        for line in meminfo:
            if line.startswith("MemAvailable:"):
                return int(line.split()[1])
    raise RuntimeError("MemAvailable missing in /proc/meminfo")


def tree_rss(pid):
    try:
        stat = Path(f"/proc/{pid}/status").read_text()
        children = Path(f"/proc/{pid}/task/{pid}/children").read_text().split()
    except (FileNotFoundError, ProcessLookupError):
        return 0
    rss = next((int(line.split()[1]) for line in stat.splitlines() if line.startswith("VmRSS:")), 0)
    return rss + sum(tree_rss(child) for child in children)


def cpu_reader():
    relative = Path("/proc/self/cgroup").read_text().strip().removeprefix("0::").lstrip("/")
    cpu_stat = Path("/sys/fs/cgroup") / relative / "cpu.stat"

    def read_cpu():
        return int(cpu_stat.read_text().splitlines()[0].split()[1]) / 1e6

    return read_cpu


def past_cpu(run_dir):
    records = list((run_dir / "pilot").glob("*.time")) + list((run_dir / "full").glob("*.time"))
    total = 0.0
    for path in records:
        for line in path.read_text().splitlines():
            fields = line.split("\t")
            if len(fields) == 5:
                total += float(fields[0]) + float(fields[1])
    return total


def launch(task, run_dir):
    stem = run_dir / "full" / task["id"]
    with stem.with_suffix(".log").open("a") as log:
        return subprocess.Popen(
            ["/usr/bin/time", "-a", "-o", str(stem.with_suffix(".time")),
             "-f", "%U\t%S\t%e\t%M\t%x",
             "Rscript", "--vanilla", str(HERE / "run.R"), "full", task["id"]],
            stdout=log, stderr=subprocess.STDOUT, env=RUNTIME_ENV, start_new_session=True
        )


def planned_tasks(run_dir):
    with (run_dir / "plan.tsv").open() as plan:
        return list(csv.DictReader(plan, delimiter="\t"))


def stop_workers(active):
    for proc in active:
        if proc.poll() is not None:
            continue
        # Leave GNU time alive so it can write the interrupted attempt's resource record.
        children = Path(f"/proc/{proc.pid}/task/{proc.pid}/children")
        try:
            for pid in children.read_text().split():
                os.kill(int(pid), signal.SIGTERM)
        except (FileNotFoundError, ProcessLookupError):
            pass
    for proc in active:
        try:
            proc.wait(timeout=5)
        except subprocess.TimeoutExpired:
            os.killpg(proc.pid, signal.SIGKILL)
            proc.wait()


def schedule(args, run_dir, slots):
    read_cpu = cpu_reader()
    initial_usage = read_cpu()
    already_used = past_cpu(run_dir)
    reserve = {"joint": int(args.joint_gib * GIB_KIB), "ind": int(args.ind_gib * GIB_KIB)}
    pending = planned_tasks(run_dir)
    pending.sort(key=lambda task: task["kind"] != "joint")
    pending = [task for task in pending
               if not any((run_dir / "full" / (task["id"] + suffix)).exists() for suffix in (".rds", ".crash"))]
    active = {}
    failure = None
    wait_for_memory = False
    note(f"Owls allocation {os.environ['OWLS_JOB_ID']}, {slots} slots, {len(pending)} runs pending")
    try:
        while pending or active:
            for proc, task in list(active.items()):
                code = proc.poll()
                if code is None:
                    continue
                del active[proc]
                ident = task["id"]
                if code in (132, 134, 135, 136, 139):
                    marker = run_dir / "full" / f"{ident}.crash"
                    staging = marker.with_suffix(".crash.tmp")
                    staging.write_text(f"Native sampler process terminated with exit status {code}\n")
                    staging.replace(marker)
                    note(f"Native crash in {ident} (exit {code})")
                elif code != 0 or not (run_dir / "full" / f"{ident}.rds").is_file():
                    failure = f"{ident} had a worker failure (exit {code}); see its log in full/"
                    note(failure)
                else:
                    note(f"Finished {ident}")
            used = already_used + read_cpu() - initial_usage
            # Leave a margin for the polling interval, shutdown and final analysis.
            if used >= CPU_LIMIT_SECONDS - 120:
                raise RuntimeError(f"Stopping at the E-16 CPU budget ({used / 3600:.3f} core-hours)")
            if failure and not active:
                raise RuntimeError(failure)

            if pending and not failure:
                available = mem_available() - FREE_RESERVE
                available -= sum(max(0, reserve[task["kind"]] - tree_rss(proc.pid))
                                 for proc, task in active.items())
                while len(active) < slots:
                    index = next((i for i, task in enumerate(pending) if reserve[task["kind"]] <= available), None)
                    if index is None:
                        break
                    task = pending.pop(index)
                    active[launch(task, run_dir)] = task
                    available -= reserve[task["kind"]]
                    note(f"Started {task['id']}")
                if not active and not wait_for_memory:
                    note("Waiting for memory headroom")
                wait_for_memory = not active
            if pending or active:
                time.sleep(5)
    finally:
        stop_workers(active)
        used = already_used + read_cpu() - initial_usage
        note(f"Accounted pilot and full CPU time {used / 3600:.4f} core-hours")


def interrupted(signum, _frame):
    raise SystemExit(128 + signum)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--joint-gib", type=float, required=True)
    parser.add_argument("--ind-gib", type=float, required=True)
    args = parser.parse_args()
    assert os.environ["OWLS_ENV_SOURCED"] == "1"
    slots = int(os.environ["OWLS_JOB_CORES"])
    affinity = os.sched_getaffinity(0)
    assert 1 <= slots <= 8 and len(affinity) == slots and not (set(range(15, 20)) & affinity)
    assert args.joint_gib > 0 and args.ind_gib > 0
    run_dir = Path(os.environ["E16_RUN_DIR"]).resolve(strict=True)
    signal.signal(signal.SIGTERM, interrupted)
    signal.signal(signal.SIGINT, interrupted)
    with (run_dir / "dispatch.lock").open("a") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        schedule(args, run_dir, slots)


if __name__ == "__main__":
    main()
