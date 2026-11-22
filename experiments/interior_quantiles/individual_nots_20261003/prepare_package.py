"""Local static checks and audit packaging only. Does not execute scientific code."""
import argparse
import ast
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import subprocess
import sys

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("--rscript", default="C:/Program Files/R/R-4.4.1/bin/Rscript.exe")
parser.add_argument("--bash", default="C:/Program Files/Git/bin/bash.exe")
args = parser.parse_args()
root = Path(__file__).resolve().parent
workspace = root.parents[3]
excluded = {"runs", "validation", "deployment", "__pycache__"}
files = sorted(p for p in root.rglob("*") if p.is_file() and not excluded.intersection(p.relative_to(root).parts))
checks = []
for p in files:
    rel = p.relative_to(root).as_posix()
    if p.suffix == ".py":
        ast.parse(p.read_text(encoding="utf-8-sig"), filename=rel)
        checks.append({"file": rel, "check": "Python AST parse", "exit_status": 0})
    if p.suffix in {".sh", ".slurm"}:
        assert b"\r" not in p.read_bytes(), f"Unix line endings required: {rel}"
        result = subprocess.run([args.bash, "-n", p.as_posix()], capture_output=True, text=True)
        checks.append({"file": rel, "check": "bash -n", "command": result.args,
                       "exit_status": result.returncode, "output": result.stdout + result.stderr})
        if result.returncode:
            raise RuntimeError(checks[-1])
# parse() does not source/evaluate any file and does not load sampler packages.
expression = r'for (f in list.files(".", pattern="[.]R$", recursive=TRUE, full.names=TRUE)) { parse(f); cat("PARSE_OK", f, "\n") }'
result = subprocess.run([args.rscript, "--vanilla", "-e", expression], cwd=root, capture_output=True, text=True)
checks.append({"check": "R parse only", "command": result.args, "exit_status": result.returncode,
               "output": result.stdout + result.stderr})
if result.returncode:
    raise RuntimeError(checks[-1])
sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
sources = {
    "source/Individual_Sampler_PMALA_Augmented.R": workspace / "Simulations/Individual/Individual_Sampler_PMALA_Augmented.R",
    "source/prox_admm_metric.cpp": workspace / "Simulations/Individual/prox_admm_metric.cpp",
    "paper_reference/simulations.tex": workspace / "PMALA version Tex Project/sections/simulations.tex",
    "paper_reference/appendix_pmala.tex": workspace / "PMALA version Tex Project/sections/appendix_pmala.tex",
}
provenance = []
for destination, original in sources.items():
    assert sha(original) == sha(root / destination), f"Snapshot differs: {destination}"
    provenance.append({"original": str(original), "snapshot": destination, "sha256": sha(original)})
stamp = datetime.now(timezone.utc).isoformat()
(root / "audit").mkdir(exist_ok=True)
(root / "audit/static_checks.json").write_text(json.dumps({
    "utc": stamp, "command": sys.argv, "scope": "Syntax and file identity only; no simulation or numerical validation",
    "checks": checks, "source_identity": provenance}, indent=2), encoding="utf-8")
files = sorted(p for p in root.rglob("*") if p.is_file() and p.name != "SHA256SUMS"
               and not excluded.intersection(p.relative_to(root).parts))
with (root / "SHA256SUMS").open("w", encoding="utf-8", newline="\n") as f:
    for p in files:
        f.write(f"{sha(p)}  ./{p.relative_to(root).as_posix()}\n")
print(f"Static checks passed; {len(files)} files sealed. No remote deployment or computational validation performed.")
