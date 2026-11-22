"""Print a compact view of the saved remote monitor record."""
import collections
import json
from pathlib import Path
import statistics
import sys

root = Path(sys.argv[1])
record = json.loads((root / "metadata" / "monitor" / "latest.json").read_text())
states = collections.Counter()
for row in record["queue"]["stdout"].splitlines():
    cells = row.split("|")
    if len(cells) >= 2:
        states[cells[1]] += 1
sweeps = [p["sweep"] for p in record["progress"]]
print("UTC", record["utc"])
print("Queue (including processing/comparison):", dict(states))
print("Successful tasks:", record["successful_tasks"], "/ 300")
if sweeps:
    print("Started workers:", len(sweeps), "sweeps min/median/max:", min(sweeps), statistics.median(sweeps), max(sweeps), "/ 30000")
print("Nonempty stderr files:", record["stderr_files_nonempty"])
summary = root / "summary" / "comparison_paper_table2.csv"
if summary.exists():
    print(summary.read_text())
