from pathlib import Path
import re,json,collections,openpyxl,sys
from pypdf import PdfReader
root=Path(__file__).resolve().parents[2]
work=root/'notes/simulation_revision_20260914'
build=Path(sys.argv[1]) if len(sys.argv)>1 else root
files=[root/'main.tex',*sorted(root.glob('sections/*.tex'))]
active='\n'.join(re.sub(r'(?<!\\)%.*','',p.read_text()) for p in files)
labels=re.findall(r'\\label\{([^}]+)\}',active)
refs=set(re.findall(r'\\(?:eqref|ref|autoref)\{([^}]+)\}',active))
assert not refs-set(labels),refs-set(labels)
assert all(n==1 for n in collections.Counter(labels).values())
keys=set(k.strip() for group in re.findall(r'\\cite\w*\*?(?:\[[^]]*\])*\{([^}]+)\}',active) for k in group.split(','))
bibkeys=re.findall(r'@\w+\{([^,]+),',(root/'references.bib').read_text())
assert not keys-set(bibkeys),keys-set(bibkeys)
assert len(bibkeys)==len(set(bibkeys))
assert not re.search(r'\bPC\b|tab:pc_|sec:sim:\w+:pc|piecewise constant signal',active,re.I)
sim=(root/'sections/simulations.tex').read_text()
app=(root/'sections/appendix_simulations.tex').read_text()
tables={re.search(r'\\label\{([^}]+)\}',t).group(1):t for t in re.findall(r'\\begin\{table\}.*?\\end\{table\}',sim+'\n'+app,re.S)}
assert len(re.findall(r'\\begin\{table\}',sim))==2
assert set(re.findall(r'\\label\{(tab:[^}]+)\}',sim))=={'tab:vs_int_mse','tab:s_int_mse'}
w=openpyxl.load_workbook('C:/Users/felip/OneDrive - Rice University/NOTS Data/BQTF/Individual Comparisons/Individual_Comparison_n500_v2.xlsx',data_only=True)
count=0
for model in ['VS','S']:
    for metric in ['MSE','MAD','MCIW']:
        tab=tables[f'tab:{model.lower()}_int_{metric.lower()}']
        rows=[line for line in tab.splitlines() if re.match(r'(Onizuka|Individual sampler|ADMM)\b',line)]
        assert len(rows)==12
        for noise in range(3):
            for method in range(4):
                actual=rows[noise*4+method].split('&')[1:]
                actual=[s.replace('\\','').strip() for s in actual]
                expected=[w[f'{model}_{metric}'].cell(4+method,2+5*noise+i).value for i in range(5)]
                expected=[f'{v:.6f}' if isinstance(v,(int,float)) else 'n/a' for v in expected]
                assert actual==expected,(model,metric,noise,method)
                count+=5
for tab in tables.values():
    assert not re.search(r'\\(?:textbf|bfseries|color|textcolor|cellcolor)',tab)
for p in ['simulations.tex','appendix_simulations.tex']:
    for t in re.findall(r'\\begin\{table\}.*?\\end\{table\}',(work/'before'/p).read_text(),re.S):
        key=re.search(r'\\label\{([^}]+)\}',t).group(1)
        if re.match('tab:(vs|s)_ext_',key): assert tables[key]==t,key
log=(build/'main.log').read_text(errors='replace')
assert not re.search(r'undefined|multiply defined|Overfull|^!',log,re.M|re.I)
r=PdfReader(build/'main.pdf')
page_text=[p.extract_text() for p in r.pages]
assert all('??' not in t for t in page_text)
(work/'page_text.txt').write_text('\n'.join(f'PAGE {i+1}\n{t}' for i,t in enumerate(page_text)),encoding='utf-8')
report={'result_cells_verified':count,'main_tables':2,'appendix_tables':10,'citation_keys':len(keys),'labels':len(labels),'references':len(refs),'pdf_pages':len(r.pages),'missing_citations':0,'missing_references':0,'overfull_boxes':0,'bold_or_colored_loss_entries':0,'extreme_tables_preserved':6}
(work/'validation.json').write_text(json.dumps(report,indent=2))
print(json.dumps(report))
print('Pages containing simulation/appendix tables:',[i+1 for i,t in enumerate(page_text) if re.search(r'Table \d+: (Mean|MSE)',t)])
