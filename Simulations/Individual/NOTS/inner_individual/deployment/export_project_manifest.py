"""Freeze a file inventory for download and subsequent scoped cleanup."""
import hashlib
import json
import os
from pathlib import Path

root = Path('/home/fb31/projects/Quant_Reg/Inner_Individual')
assert (root / 'deployment/monitor_stop.csv').exists()
manifest_path = root / 'deployment/project_transfer_manifest.json'
records = []
for directory, dirs, files in os.walk(root, followlinks=False):
    for name in sorted(files):
        path = Path(directory) / name
        if path.is_symlink() or path == manifest_path:
            continue
        h = hashlib.sha256()
        with path.open('rb') as source:
            for chunk in iter(lambda: source.read(4*1024*1024), b''):
                h.update(chunk)
        stat = path.stat()
        records.append(dict(remote=str(path), relative=path.relative_to(root).as_posix(),
            sha256=h.hexdigest(), size=stat.st_size, mtime_ns=stat.st_mtime_ns))
records.sort(key=lambda r: r['remote'])
manifest_path.write_text(json.dumps(dict(run='VS_S_inner_100seeds_15k_3k_b001_20261003T213442Z', records=records), indent=2))
print(json.dumps(dict(files=len(records), bytes=sum(r['size'] for r in records),
    manifest_sha256=hashlib.sha256(manifest_path.read_bytes()).hexdigest()), indent=2))
