"""Persistent, resumable download -> full local verification -> authorized scoped cleanup."""
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import time

scripts = Path(__file__).resolve().parent
destination = Path('C:/Users/felip/OneDrive - Rice University/NOTS Data/Inner_Quant_Ind')
audit = destination / 'transfer_audit'
remote = '/home/fb31/projects/Quant_Reg/Inner_Individual'
state_path = audit / 'pipeline_status.json'
history = audit / 'pipeline_history.jsonl'
def state(stage, **detail):
    record = dict(utc=datetime.now(timezone.utc).isoformat(), stage=stage, **detail)
    state_path.write_text(json.dumps(record, indent=2))
    with history.open('a', encoding='utf-8') as log:
        log.write(json.dumps(record)+'\n')
    print(json.dumps(record), flush=True)
def run(command, stage):
    state(stage, command=command)
    result = subprocess.run(command)
    if result.returncode:
        raise RuntimeError(f'{stage} failed, exit={result.returncode}')
try:
    # Retry interrupted transfers from the per-file SHA-verified receipts.
    for attempt in range(20):
        state('downloading_raw', attempt=attempt+1, concurrency=16)
        result = subprocess.run([sys.executable, str(scripts / 'download_campaign.py'),
            str(audit / 'raw_transfer_manifest.json'), str(destination), '16'])
        if result.returncode == 0:
            break
        state('raw_transfer_retry_pending', attempt=attempt+1, exit_status=result.returncode)
        time.sleep(60)
    else:
        raise RuntimeError('Raw transfer retries exhausted; remote files preserved')
    run([sys.executable, str(scripts / 'download_verified.py'),
        str(audit / 'project_transfer_manifest.json'), str(destination)], 'downloading_project')
    run([sys.executable, str(scripts / 'verify_downloads.py'), str(destination)], 'verifying_all_local_files')
    receipt = audit / 'local_download_verified.json'
    assert json.loads(receipt.read_text())['all_files_verified'] is True
    run(['scp', str(receipt), 'nots:' + remote + '/deployment/local_download_verified.json'], 'uploading_verified_receipt')
    # This command can delete only the exact inventoried campaign files. Its own
    # guards require matching local verification receipts and unchanged remote files.
    run(['ssh', '-o', 'BatchMode=yes', 'nots', 'python3 ' + remote + '/deployment/cleanup_after_verified.py --execute'], 'cleaning_verified_remote_storage')
    for name in ['cleanup_plan.csv', 'cleanup_completed.csv', 'cleanup_summary.csv']:
        run(['scp', 'nots:' + remote + '/deployment/' + name, str(audit / name)], 'downloading_cleanup_receipt')
    state('complete', destination=str(destination), remote_chains_removed=True)
except BaseException as error:
    state('failed_requires_inspection', error=str(error),
          note='Inspect the last stage and logs; never delete unverified remote files.')
    raise
