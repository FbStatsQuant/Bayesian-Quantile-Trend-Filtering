"""Record local manuscript provenance and check the scoped edit against its backup."""
from pathlib import Path
from datetime import datetime, timezone
import difflib
import hashlib
import json
import re

audit = Path(__file__).resolve().parent
paper = audit.parent.parent
workspace = paper.parent
live = workspace / 'Simulations/My Samplers/diagnostics_20260930/E_unified'
snapshot = audit / 'source_snapshot'

def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def read(path):
    return path.read_text(encoding='utf-8-sig')

core = ['Unified_Sampler.R', 'bounded_helpers.R', 'prox_bounded.cpp',
        'prox_admm_metric.cpp', 'guarded_reference.R']
comparison = []
for name in core:
    same_text = read(snapshot/name) == read(live/name)
    comparison.append({'file':name, 'snapshot_sha256':digest(snapshot/name),
                       'live_sha256':digest(live/name),
                       'identical_after_newline_normalization':same_text})
    assert same_text, f'Live core source changed: {name}'

diffs = []
for name in ['methodology.tex', 'appendix_pmala.tex']:
    old = audit/'before/sections'/name
    new = paper/'sections'/name
    diffs.extend(difflib.unified_diff(read(old).splitlines(True),read(new).splitlines(True),
                                    fromfile='before/sections/'+name,
                                    tofile='sections/'+name))
(audit/'manuscript.diff').write_text(''.join(diffs),encoding='utf-8')

before = read(audit/'before/sections/methodology.tex')
after = read(paper/'sections/methodology.tex')
joint_marker = r'\subsection{Joint Quantile Sampler}'
assert before.split(joint_marker)[0] == after.split(joint_marker)[0]
before_app = read(audit/'before/sections/appendix_pmala.tex')
after_app = read(paper/'sections/appendix_pmala.tex')
body_marker = r'\subsection{Full conditional distributions}'
new_app_marker = r'\subsection{Computational details of the unified joint sampler}'
assert before_app.split(body_marker,1)[1].rstrip() == after_app.split(body_marker,1)[1].split(new_app_marker)[0].rstrip()
assert digest(paper/'main.tex') == digest(audit/'before/main.tex')

log = read(paper/'main.log')
bad = [line for line in log.splitlines() if re.search(
    r'^!|Overfull|Underfull|undefined|multiply defined|Label\(s\) may have changed', line)]
assert not bad, bad
assert 'Output written on main.pdf (60 pages' in log

map_entries = {
 'Unified_Sampler.R': ['gibbs_unified <-', 'a0 <-', 'offsets <-', 'lower <-',
    'if (it <= warm)', 'for (kk', 'z      <-', 'lambda <- rgamma',
    'as_ <- box_asis_step', 'sigma  <- draw_sigma', 'if (adapt &&'],
 'bounded_helpers.R': ['box_prox <-', 'box_pmala_step <-', 'if(unbounded_box',
    'prop <- p+', 'if(outside)', 'pstar <-', 'log_alpha <- U_cond',
    'asis_scale_domain <-', 'box_asis_step <-', 'eta0 <-', 'a0*eta', 'if(U-L<'],
 'prox_bounded.cpp': ['List bounded_prox', 'eta+=', 'A.B[q][i]*=',
    'rhs[i]=', 't[i]=std::max', 'return List::create'],
 'guarded_reference.R': ['metric_dc <-', 'rinvgauss <-', 'draw_z <-',
    'draw_sigma <-', 'asis_step <-'],
}
rows = ['snapshot_file\tline\tsource_anchor']
for name, patterns in map_entries.items():
    for n,line in enumerate(read(snapshot/name).splitlines(),1):
        if any(pattern in line for pattern in patterns):
            rows.append(f'{name}\t{n}\t{line.strip()}')
(audit/'code_source_map.tsv').write_text('\n'.join(rows)+'\n',encoding='utf-8')

manifest = {
 'checked_at_utc':datetime.now(timezone.utc).isoformat(),
 'audited_source_directory':str(live),
 'immutable_snapshot_directory':str(snapshot),
 'core_live_comparison':comparison,
 'snapshot_sha256':{p.name:digest(p) for p in sorted(snapshot.iterdir()) if p.is_file()},
 'final_manuscript_sha256':{str(p.relative_to(paper)):digest(p) for p in
    [paper/'main.tex',paper/'sections/methodology.tex',paper/'sections/appendix_pmala.tex',paper/'main.pdf']},
 'checks':{'individual_methodology_preserved':True,
           'existing_appendix_body_preserved':True,'main_tex_unchanged':True,
           'final_latex_errors_and_layout_or_reference_warnings':bad,
           'pdf_pages':60,
           'visually_reviewed_pdf_pages':[2,3,8,9,10,11,12,33,38,39,40,41]},
}
(audit/'final_audit.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8')
print('PASS: scoped preservation, live-source consistency, final build checks; saved diff, hashes and source map.')
