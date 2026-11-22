"""Read every downloaded file and issue the receipt required before remote cleanup."""
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import sys
import time

destination = Path(sys.argv[1]).resolve()
audit = destination / 'transfer_audit'
manifests = [audit / 'raw_transfer_manifest.json', audit / 'project_transfer_manifest.json']
receipt = dict(destination=str(destination), manifests=[], all_files_verified=False)
total = 0; total_bytes = 0; started = time.monotonic(); last_report = started
for manifest_path in manifests:
    content = json.loads(manifest_path.read_text())
    records = content['records']
    for r in records:
        path = destination / r['relative']
        assert destination in path.resolve().parents
        assert path.is_file() and path.stat().st_size == r['size'], str(path)
        h = hashlib.sha256()
        with path.open('rb') as f:
            for chunk in iter(lambda: f.read(4*1024*1024), b''):
                h.update(chunk)
        assert h.hexdigest() == r['sha256'], 'SHA256 mismatch: ' + str(path)
        total += 1; total_bytes += r['size']
        if time.monotonic() - last_report > 30:
            print(json.dumps(dict(verified_files=total, verified_bytes=total_bytes)), flush=True)
            last_report = time.monotonic()
    receipt['manifests'].append(dict(name=manifest_path.name,
        sha256=hashlib.sha256(manifest_path.read_bytes()).hexdigest(), files=len(records)))
receipt.update(all_files_verified=True, files=total, bytes=total_bytes,
               completed_utc=datetime.now(timezone.utc).isoformat())
(audit / 'local_download_verified.json').write_text(json.dumps(receipt, indent=2))
print(json.dumps(receipt, indent=2), flush=True)
