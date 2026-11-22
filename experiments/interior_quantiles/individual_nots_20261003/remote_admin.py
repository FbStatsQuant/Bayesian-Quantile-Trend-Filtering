"""Execute an auditable shell script on NOTS via stdin, with LF-safe transport."""
from datetime import datetime, timezone
from pathlib import Path
import subprocess
import sys

root = Path(__file__).resolve().parent
script = Path(sys.argv[1]).resolve()
stamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%S_%fZ")
audit = root / "deployment" / (stamp + "_" + script.stem)
audit.mkdir(parents=True)
payload = script.read_text(encoding="utf-8-sig").replace("\r\n", "\n").encode()
(audit / "command.sh").write_bytes(payload)
result = subprocess.run(["ssh", "-o", "BatchMode=yes", "nots", "bash -s"],
    input=payload, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
output = result.stdout.decode("utf-8", errors="replace")
(audit / "output.txt").write_text(output, encoding="utf-8")
(audit / "exit_status.txt").write_text(str(result.returncode), encoding="utf-8")
print(output, flush=True)
raise SystemExit(result.returncode)
