"""Run independent, resumable file transfers; no numerical computation."""
import concurrent.futures
from datetime import datetime, timezone
import json
from pathlib import Path
import subprocess
import sys
import time

root = Path(__file__).resolve().parent
manifest_path = Path(sys.argv[1]).resolve()
destination = Path(sys.argv[2]).resolve()
manifest = json.loads(manifest_path.read_text())
workers = int(sys.argv[3]) if len(sys.argv) > 3 else 4
audit = destination / 'transfer_audit'
audit.mkdir(parents=True, exist_ok=True)
parts = []
for index in range(workers):
    target = audit / f'raw{workers}_part_{index+1:02d}.json'
    content = json.dumps(dict(run=manifest['run'], records=manifest['records'][index::workers]), indent=2)
    if target.exists() and target.read_text() != content:
        raise RuntimeError('An existing part manifest differs')
    target.write_text(content)
    parts.append(target)
def transfer(part):
    time.sleep(int(part.stem.rsplit('_', 1)[1]) * 0.5)
    with (audit / (part.stem + '.log')).open('a', encoding='utf-8') as log:
        for attempt in range(5):
            result = subprocess.run([sys.executable, str(root / 'download_verified.py'), str(part), str(destination)],
                                   stdout=log, stderr=subprocess.STDOUT)
            if result.returncode == 0:
                return 0
            log.write(f'RETRY {attempt+1}\n'); log.flush()
            time.sleep(15 * (attempt+1))
        return result.returncode
started = time.monotonic()
with concurrent.futures.ThreadPoolExecutor(max_workers=workers) as pool:
    futures = [pool.submit(transfer, part) for part in parts]
    while True:
        done, _ = concurrent.futures.wait(futures, timeout=30)
        progress = []
        for part in parts:
            path = audit / (part.stem + '_progress.json')
            if path.exists():
                try:
                    progress.append(json.loads(path.read_text()))
                except json.JSONDecodeError:
                    pass
        report = dict(utc=datetime.now(timezone.utc).isoformat(),
            files=sum(p['verified_files'] for p in progress), total_files=len(manifest['records']),
            transferred_bytes=sum(p['transferred_bytes'] for p in progress),
            elapsed_seconds=round(time.monotonic()-started), workers_finished=len(done))
        (audit / 'raw_transfer_progress.json').write_text(json.dumps(report, indent=2))
        print(json.dumps(report), flush=True)
        if len(done) == len(futures):
            break
    statuses = [f.result() for f in futures]
if any(statuses):
    raise SystemExit('Transfer errors: ' + str(statuses))
print('ALL_TRANSFERS_VERIFIED', flush=True)
