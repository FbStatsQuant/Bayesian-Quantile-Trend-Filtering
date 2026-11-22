"""Read-only NOTS instructions/environment inspection; no files or jobs created remotely."""
from pathlib import Path
import subprocess

root = Path(__file__).resolve().parent
command = r'''
set -eu
printf 'READ_ONLY_PROBE_UTC='; date -u --iso-8601=seconds
hostname -f
for d in / /home /home/fb31 /home/fb31/projects /home/fb31/projects/Quant_Reg /home/fb31/projects/Quant_Reg/Inner_Individual; do
  if [ -f "$d/AGENTS.md" ]; then printf '\nINSTRUCTIONS %s/AGENTS.md\n' "$d"; cat "$d/AGENTS.md"; else printf 'NO_AGENTS %s\n' "$d"; fi
done
ls -la /home/fb31/projects/Quant_Reg/Inner_Individual
scontrol show config | grep -E 'ClusterName|MaxArraySize|MaxJobCount'
module load GCC/14.3.0
module avail R/4.5.2 2>&1
sinfo -N -h -o '%N %P' | head -8
'''
result = subprocess.run(["ssh", "-o", "BatchMode=yes", "nots", "bash -s"],
    input=command.encode(), stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
text = result.stdout.decode("utf-8", errors="replace")
(root / "audit").mkdir(exist_ok=True)
(root / "audit" / "nots_readonly_probe.txt").write_text(
    text + f"\nSSH_EXIT_STATUS={result.returncode}\n", encoding="utf-8")
print(text)
raise SystemExit(result.returncode)
