"""On NOTS: inventory the completed raw chains using their saved audit hashes."""
import hashlib
import json
from pathlib import Path

project = Path('/home/fb31/projects/Quant_Reg/Inner_Individual')
name = 'VS_S_inner_100seeds_15k_3k_b001_20261003T213442Z'
run = project / 'runs' / name
raw = Path('/scratch/fb31/qr_data/inner_individual') / name
assert 'exit_status=0' in (run / 'logs/process_1786241_exit.txt').read_text().splitlines()
records = []
for marker in sorted((run / 'tasks').rglob('SUCCESS')):
    attempt = Path(marker.read_text().strip())
    matches = []
    for line in (attempt / 'OUTPUT_SHA256SUMS').read_text().splitlines():
        digest, path = line.split('  ', 1)
        path = Path(path).resolve()
        if raw in path.parents:
            matches.append(dict(remote=str(path), relative=(Path('runs') / name / 'raw' / path.relative_to(raw)).as_posix(),
                                sha256=digest, size=path.stat().st_size, mtime_ns=path.stat().st_mtime_ns))
    assert len(matches) == 1, marker
    records.extend(matches)
assert len(records) == 3000 and len({r['remote'] for r in records}) == 3000
target = project / 'deployment/raw_transfer_manifest.json'
target.write_text(json.dumps(dict(run=name, records=records), indent=2))
print(json.dumps(dict(files=len(records), bytes=sum(r['size'] for r in records),
    manifest=str(target), manifest_sha256=hashlib.sha256(target.read_bytes()).hexdigest()), indent=2))
