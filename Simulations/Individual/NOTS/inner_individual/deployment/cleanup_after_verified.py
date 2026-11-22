"""On NOTS: remove only fully downloaded campaign storage; retain code and tables."""
import csv
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import sys

root = Path('/home/fb31/projects/Quant_Reg/Inner_Individual').resolve()
name = 'VS_S_inner_100seeds_15k_3k_b001_20261003T213442Z'
raw_root = Path('/scratch/fb31/qr_data/inner_individual') / name
assert root == Path('/home/fb31/projects/Quant_Reg/Inner_Individual')
assert raw_root.resolve() == raw_root
assert (root / 'deployment/monitor_stop.csv').is_file()
manifest_paths = [root / 'deployment/raw_transfer_manifest.json', root / 'deployment/project_transfer_manifest.json']
base_keep = {root / 'SHA256SUMS'}
for line in (root / 'SHA256SUMS').read_text().splitlines():
    base_keep.add(root / line.split('  ', 1)[1])
keep_suffixes = {'.r', '.py', '.sh', '.slurm', '.cpp', '.c', '.h', '.hpp', '.csv', '.xls', '.xlsx', '.md', '.tex'}
records = [r for m in manifest_paths for r in json.loads(m.read_text())['records']]
plan = []
for r in records:
    path = Path(r['remote'])
    resolved = path.resolve()
    assert root in resolved.parents or raw_root in resolved.parents, str(path)
    raw_file = raw_root in resolved.parents
    retained = not raw_file and (path in base_keep or path.suffix.lower() in keep_suffixes or 'code' in path.relative_to(root).parts)
    if not retained:
        plan.append(r)
plan_path = root / 'deployment/cleanup_plan.csv'
with plan_path.open('w', newline='') as f:
    writer = csv.DictWriter(f, fieldnames=['remote', 'relative', 'size', 'sha256', 'mtime_ns'])
    writer.writeheader(); writer.writerows(plan)
print(json.dumps(dict(files_to_remove=len(plan), bytes_to_remove=sum(r['size'] for r in plan),
    scope=[str(root), str(raw_root)]), indent=2), flush=True)
if '--execute' not in sys.argv:
    raise SystemExit(0)
receipt = json.loads((root / 'deployment/local_download_verified.json').read_text())
assert receipt['all_files_verified'] is True
assert receipt['files'] == len(records) and receipt['bytes'] == sum(r['size'] for r in records)
assert receipt['destination'].replace('\\', '/') == 'C:/Users/felip/OneDrive - Rice University/NOTS Data/Inner_Quant_Ind'
for manifest_path in manifest_paths:
    matched = [m for m in receipt['manifests'] if m['name'] == manifest_path.name]
    assert len(matched) == 1 and matched[0]['sha256'] == hashlib.sha256(manifest_path.read_bytes()).hexdigest()
# Check the complete deletion set before deleting anything. Files have been frozen
# since terminal scheduler verification and must still match the inventoried state.
for r in plan:
    path = Path(r['remote'])
    stat = path.stat()
    assert path.is_file() and not path.is_symlink()
    assert stat.st_size == r['size'] and stat.st_mtime_ns == r['mtime_ns'], str(path)
with (root / 'deployment/cleanup_completed.csv').open('w', newline='') as f:
    writer = csv.writer(f); writer.writerow(['remote', 'bytes', 'sha256', 'deleted_utc'])
    for r in plan:
        Path(r['remote']).unlink()
        writer.writerow([r['remote'], r['size'], r['sha256'], datetime.now(timezone.utc).isoformat()])
        f.flush()
# Remove only empty directories within the exact campaign raw-storage subtree.
if raw_root.exists():
    for directory, dirs, files in os.walk(raw_root, topdown=False):
        path = Path(directory)
        assert path == raw_root or raw_root in path.parents
        if not any(path.iterdir()):
            path.rmdir()
link = root / 'runs' / name / 'raw'
if link.is_symlink():
    assert os.readlink(link) == str(raw_root)
    assert not raw_root.exists()
    link.unlink()
remaining_rds = [str(p) for p in root.rglob('*') if p.is_file() and p.suffix.lower() in {'.rds', '.rda', '.rdata'}]
assert not remaining_rds, remaining_rds
assert not raw_root.exists()
with (root / 'deployment/cleanup_summary.csv').open('w', newline='') as f:
    writer = csv.writer(f); writer.writerow(['removed_files', 'removed_bytes', 'remaining_rds', 'raw_directory_exists', 'finished_utc'])
    writer.writerow([len(plan), sum(r['size'] for r in plan), 0, False, datetime.now(timezone.utc).isoformat()])
print('CLEANUP_COMPLETE: no RDS files or raw chain directory remain in this campaign', flush=True)
