"""Download a NOTS manifest by tar streaming; verify every file before finalizing it."""
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path, PurePosixPath
import subprocess
import sys
import tarfile
import time

manifest_path = Path(sys.argv[1]).resolve()
destination = Path(sys.argv[2]).resolve()
manifest = json.loads(manifest_path.read_text(encoding='utf-8'))
records = manifest['records']
destination.mkdir(parents=True, exist_ok=True)
audit = destination / 'transfer_audit'
audit.mkdir(exist_ok=True)
log_path = audit / (manifest_path.stem + '_verified.jsonl')
previous = {}
for prior_log in audit.glob('*_verified.jsonl'):
    for line in prior_log.read_text().splitlines():
        if line.strip():
            try:
                r = json.loads(line); previous[r['remote']] = r
            except json.JSONDecodeError:
                # Another transfer may be finishing the final receipt line.
                # Missing receipts cause a fresh file hash, never an unchecked skip.
                continue
pending = []
for r in records:
    target = destination / r['relative']
    if destination not in target.resolve().parents:
        raise RuntimeError('Destination escape: ' + str(target))
    old = previous.get(r['remote'])
    if old and old['sha256'] == r['sha256'] and target.is_file() and target.stat().st_size == r['size']:
        continue
    if target.exists():
        # Recover a file finalized just before an interrupted receipt write.
        h = hashlib.sha256()
        with target.open('rb') as existing:
            for chunk in iter(lambda: existing.read(4*1024*1024), b''):
                h.update(chunk)
        if target.stat().st_size != r['size'] or h.hexdigest() != r['sha256']:
            raise RuntimeError('Existing file differs; refusing overwrite: ' + str(target))
        with log_path.open('a', encoding='utf-8') as recovery:
            recovery.write(json.dumps(dict(r, verified_utc=datetime.now(timezone.utc).isoformat())) + '\n')
        continue
    pending.append(r)
if not pending:
    print('ALREADY_VERIFIED', len(records), flush=True)
    raise SystemExit(0)
mapping = {r['remote'].lstrip('/'): r for r in pending}
names = b''.join(r['remote'].lstrip('/').encode() + b'\0' for r in pending)
stderr_path = audit / (manifest_path.stem + '_ssh_stderr.txt')
started = time.monotonic(); downloaded = 0; last_report = started
with stderr_path.open('wb') as errors, log_path.open('a', encoding='utf-8', buffering=1) as log:
    proc = subprocess.Popen(['ssh', '-o', 'BatchMode=yes', '-o', 'Compression=no', 'nots',
        'tar -C / --null -T - -cf -'], stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=errors)
    # A thread feeds the file list while tar streams its output, avoiding pipe deadlock.
    import threading
    def feed():
        try:
            proc.stdin.write(names); proc.stdin.close()
        except BrokenPipeError:
            pass
    feeder = threading.Thread(target=feed); feeder.start()
    count = 0
    try:
        with tarfile.open(fileobj=proc.stdout, mode='r|') as stream:
            for member in stream:
                key = str(PurePosixPath(member.name))
                if key not in mapping or not member.isfile():
                    raise RuntimeError('Unexpected archive member: ' + key)
                r = mapping.pop(key)
                if member.size != r['size']:
                    raise RuntimeError('Remote size changed: ' + key)
                target = destination / r['relative']
                target.parent.mkdir(parents=True, exist_ok=True)
                partial = target.with_name(target.name + '.partial')
                digest = hashlib.sha256()
                source = stream.extractfile(member)
                with partial.open('wb') as out:
                    while True:
                        chunk = source.read(4 * 1024 * 1024)
                        if not chunk:
                            break
                        out.write(chunk); digest.update(chunk); downloaded += len(chunk)
                    out.flush(); os.fsync(out.fileno())
                if digest.hexdigest() != r['sha256']:
                    raise RuntimeError('SHA256 mismatch: ' + key)
                os.replace(partial, target)
                log.write(json.dumps(dict(r, verified_utc=datetime.now(timezone.utc).isoformat())) + '\n')
                count += 1
                now = time.monotonic()
                if now - last_report >= 30 or count == len(pending):
                    report = dict(verified_files=len(records)-len(pending)+count, total_files=len(records),
                        transferred_bytes=downloaded, elapsed_seconds=round(now-started),
                        MB_per_second=round(downloaded / max(now-started, 1) / 1e6, 2),
                        utc=datetime.now(timezone.utc).isoformat())
                    (audit / (manifest_path.stem + '_progress.json')).write_text(json.dumps(report, indent=2))
                    print(json.dumps(report), flush=True); last_report = now
        feeder.join()
        status = proc.wait()
        if status != 0 or mapping:
            raise RuntimeError(f'Transfer incomplete: SSH status={status}; missing={len(mapping)}')
    except BaseException:
        proc.kill(); proc.wait()
        raise
receipt = dict(manifest_sha256=hashlib.sha256(manifest_path.read_bytes()).hexdigest(),
    files=len(records), bytes=sum(r['size'] for r in records), destination=str(destination),
    completed_utc=datetime.now(timezone.utc).isoformat(), status='all_files_sha256_verified')
(audit / (manifest_path.stem + '_COMPLETE.json')).write_text(json.dumps(receipt, indent=2))
print(json.dumps(receipt, indent=2), flush=True)
