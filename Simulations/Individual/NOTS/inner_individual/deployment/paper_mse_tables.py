"""On NOTS: reproduce the two paper MSE tables with updated individual rows only."""
import csv
import hashlib
import json
from pathlib import Path

root = Path('/home/fb31/projects/Quant_Reg/Inner_Individual')
run = root / 'runs/VS_S_inner_100seeds_15k_3k_b001_20261003T213442Z'
assert 'exit_status=0' in (run / 'logs/process_1786241_exit.txt').read_text().splitlines()
success = list((run / 'summary').glob('*/SUCCESS'))
assert len(success) == 1
summary = success[0].parent
with (summary / 'average_metrics.csv').open() as f:
    metrics = list(csv.DictReader(f))
assert len(metrics) == 30
updated = {}
for row in metrics:
    assert int(row['n_seeds']) == 100 and float(row['a0']) == 1 and float(row['b0']) == 0.01
    key = (row['baseline'], row['noise'], round(float(row['tau']), 2))
    assert key not in updated
    updated[key] = float(row['mean_MSE'])
taus = [0.05, 0.25, 0.50, 0.75, 0.95]
noise_map = {'Beta': 'Beta', 'Mixed normal': 'Mixed', 'Gaussian': 'Normal'}
methods = ['Onizuka (Laplace)', 'Onizuka (Horseshoe)', 'Bayesian-PMALA', 'ADMM']
output = root / 'deployment/paper_mse_tables'
output.mkdir(exist_ok=True)
records = []; markdown = []; provenance = []
for baseline, filename, label in [('VS', 'simulations.tex', 'tab:vs_int_mse'), ('S', 'appendix_simulations.tex', 'tab:s_int_mse')]:
    source = root / 'deployment/paper_current' / filename
    text = source.read_text()
    table = text.split('\\label{' + label + '}', 1)[1].split('\\end{table}', 1)[0]
    noise = None; rows = []
    for line in table.splitlines():
        parts = [p.strip() for p in line.replace('\\\\', '').split('&')]
        if parts[0] in noise_map:
            noise = parts[0]
        elif parts[0] in methods:
            assert noise is not None and len(parts) == 6
            old = [float(v) for v in parts[1:]]
            values = [updated[(baseline, noise_map[noise], tau)] for tau in taus] if parts[0] == 'Bayesian-PMALA' else old
            rows.append((noise, parts[0], values))
            for tau, value in zip(taus, values):
                records.append(dict(baseline=baseline, noise=noise, method=parts[0], tau=tau,
                    MSE=value, source='new 100-seed campaign' if parts[0] == 'Bayesian-PMALA' else 'current paper'))
    assert len(rows) == 12
    markdown.extend([f'**{baseline} baseline**', '', '| Noise | Method | 0.05 | 0.25 | 0.50 | 0.75 | 0.95 |',
                     '|---|---|---:|---:|---:|---:|---:|'])
    for noise, method, values in rows:
        cells = [f'{v:.6f}' for v in values]
        if method == 'Bayesian-PMALA':
            method = '**Bayesian-PMALA (updated)**'
            cells = [f'**{v}**' for v in cells]
        markdown.append('| ' + ' | '.join([noise, method] + cells) + ' |')
    markdown.append('')
    provenance.append(dict(baseline=baseline, label=label, source=str(source), sha256=hashlib.sha256(source.read_bytes()).hexdigest()))
with (output / 'mse_tables.csv').open('w', newline='') as f:
    writer = csv.DictWriter(f, fieldnames=list(records[0])); writer.writeheader(); writer.writerows(records)
(output / 'mse_tables.md').write_text('\n'.join(markdown))
(output / 'provenance.json').write_text(json.dumps(dict(paper_sources=provenance,
    updated_source=str(summary / 'average_metrics.csv'),
    updated_source_sha256=hashlib.sha256((summary / 'average_metrics.csv').read_bytes()).hexdigest(),
    note='Only individual Bayesian-PMALA rows replaced. Competitors retain the paper values. No paper files edited.'), indent=2))
print('\n'.join(markdown))
