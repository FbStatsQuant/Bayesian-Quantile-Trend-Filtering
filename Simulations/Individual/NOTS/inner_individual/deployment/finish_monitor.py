"""Verify terminal scheduler results, then stop only this campaign's monitor."""
import csv
import os
from pathlib import Path
import signal
import socket
import subprocess
import time

root = Path('/home/fb31/projects/Quant_Reg/Inner_Individual')
run = root / 'runs/VS_S_inner_100seeds_15k_3k_b001_20261003T213442Z'
assert socket.gethostname().split('.')[0] == 'loginx3'
assert 'exit_status=0' in (run / 'logs/process_1786241_exit.txt').read_text().splitlines()
result = subprocess.run(['sacct', '-X', '-n', '-P', '-j', '1786240,1786241',
    '--format=JobID,State,ExitCode,Elapsed'], check=True, capture_output=True, text=True)
rows = [line.split('|')[:4] for line in result.stdout.splitlines() if line.strip()]
fits = [r for r in rows if r[0].startswith('1786240_')]
processing = [r for r in rows if r[0] == '1786241']
assert len(fits) == 3000 and len(processing) == 1
assert all(r[1] == 'COMPLETED' and r[2] == '0:0' for r in fits + processing)
pid = int((run / 'metadata/monitor/launch_pid.txt').read_text())
cmdline = Path(f'/proc/{pid}/cmdline')
if cmdline.exists():
    command = cmdline.read_bytes().split(b'\0')
    assert str(run / 'code/monitor.py').encode() in command and str(run).encode() in command
    os.kill(pid, signal.SIGTERM)
    time.sleep(1)
with (root / 'deployment/final_accounting.csv').open('w', newline='') as f:
    writer = csv.writer(f); writer.writerow(['JobID', 'State', 'ExitCode', 'Elapsed']); writer.writerows(rows)
with (root / 'deployment/monitor_stop.csv').open('w', newline='') as f:
    writer = csv.writer(f); writer.writerow(['host', 'pid', 'reason']); writer.writerow([socket.gethostname(), pid, 'all 3000 fits and processing completed successfully'])
print('ALL_3000_FITS_AND_PROCESSING_COMPLETED_EXIT_0; MONITOR_STOPPED', flush=True)
