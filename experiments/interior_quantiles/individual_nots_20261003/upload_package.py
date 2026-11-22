"""Upload this SHA-sealed package to its fixed NOTS project folder."""
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import subprocess
import tarfile

root = Path(__file__).resolve().parent
remote = "/home/fb31/projects/Quant_Reg/Inner_Individual"
stamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
local = root / "deployment" / ("upload_" + stamp)
local.mkdir(parents=True)
manifest = (root / "SHA256SUMS").read_text().splitlines()
files = ["SHA256SUMS"]
for line in manifest:
    expected, name = line.split("  ", 1)
    assert hashlib.sha256((root / name).read_bytes()).hexdigest() == expected, name
    files.append(name)
archive = local / "package.tar.gz"
with tarfile.open(archive, "w:gz") as bundle:
    for name in files:
        bundle.add(root / name, arcname=name, recursive=False)
digest = hashlib.sha256(archive.read_bytes()).hexdigest()
commands = []
def execute(command, payload=None):
    result = subprocess.run(command, input=payload, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    output = result.stdout.decode("utf-8", errors="replace")
    commands.append(dict(command=command, exit_status=result.returncode, output=output))
    (local / "transfer.json").write_text(json.dumps(dict(utc=stamp, archive_sha256=digest, commands=commands), indent=2))
    print(output, flush=True)
    if result.returncode:
        raise SystemExit(result.returncode)
execute(["ssh", "-o", "BatchMode=yes", "nots", "mkdir -p " + remote + "/deployment"])
remote_archive = remote + "/deployment/package_" + stamp + ".tar.gz"
execute(["scp", str(archive), "nots:" + remote_archive])
payload = f'''set -euo pipefail
cd {remote}
echo '{digest}  {remote_archive}' | sha256sum --check
# Preserve every previous package before any deliberate redeployment.
if [[ -f SHA256SUMS ]]; then
  tar -czf deployment/previous_package_{stamp}.tar.gz --files-from=<(sed 's/^[^ ]*  //' SHA256SUMS) SHA256SUMS
fi
tar -xzf {remote_archive}
sha256sum --check SHA256SUMS
printf '%s\\n' '{digest}' > deployment/package_{stamp}.archive_sha256
date -u --iso-8601=seconds
'''.encode()
(local / "remote_transfer.sh").write_bytes(payload)
execute(["ssh", "-o", "BatchMode=yes", "nots", "bash -s"], payload)
