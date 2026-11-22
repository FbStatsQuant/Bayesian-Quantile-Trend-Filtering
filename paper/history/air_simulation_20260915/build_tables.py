from pathlib import Path
import json, re
import openpyxl

project=Path(__file__).resolve().parents[2]
workspace=project.parent
source=workspace/'outputs/air_simulation_summary_20260915/analysis.json'
data=json.loads(source.read_text())
workbook=openpyxl.load_workbook(source.parent/'Air_Simulation_Mean_Metrics.xlsx',data_only=True)
methods={'Individual Sampler':'Individual sampler','Onizuka - Horseshoe':'Onizuka (HS)','ADMM':'ADMM'}
verified=0
for idx,n in enumerate([500,1000,2000,4000]):
    rows=[r for r in data['summary'] if r[1]==n and (r[2]!='Individual Sampler' or r[3]=='Posterior mean')]
    expected=[[r[j] for j in [0,2,6,8,11,12,13,14]] for r in rows]
    actual=[list(r) for r in workbook['Summary'].iter_rows(min_row=7+idx*14,max_row=15+idx*14,max_col=8,values_only=True)]
    assert actual==expected
    lines=[r'\begin{table}[H]',r'\centering',r'\small',r'\setlength{\tabcolsep}{4pt}',
           r'\caption{Simulated air-quality results for $n='+str(n)+r'$. Entries are means across replications. CL denotes check loss; HS denotes the horseshoe sampler. '+
           (r'CL and MSE use $100$ replications; CAA uses $91$ after excluding undefined cases.' if n==500 else r'All metrics use $100$ replications.')+r'}',
           r'\label{tab:air_n'+str(n)+r'}',r'\begin{tabular}{@{}rlrrrrrr@{}}',r'\toprule',
           r' & & & & \multicolumn{4}{c}{CAA at threshold $h$} \\',
           r'\cmidrule(lr){5-8}',r'$\tau$ & Method & CL & MSE & $0.5$ & $0.75$ & $1$ & $1.2$ \\',r'\midrule']
    for j,r in enumerate(rows):
        if j and j%3==0: lines.append(r'\addlinespace[3pt]')
        numbers=[f'{r[6]:.6f}',f'{r[8]:.6f}']+[f'{r[k]:.4f}' for k in [11,12,13,14]]
        lines.append(' & '.join([f'{r[0]:.2f}',methods[r[2]],*numbers])+r' \\')
        verified+=6
    lines.extend([r'\bottomrule',r'\end{tabular}',r'\end{table}'])
    target=project/'sections'/('air_simulation.tex' if n==1000 else 'appendix_air_simulation.tex')
    text=target.read_text()
    begin=f'% AIR-TABLE-{n}-BEGIN'
    end=f'% AIR-TABLE-{n}-END'
    replacement=begin+'\n'+'\n'.join(lines)+'\n'+end
    text,count=re.subn(re.escape(begin)+r'.*?'+re.escape(end),lambda _:replacement,text,flags=re.S)
    assert count==1
    target.write_text(text)

# Keep the main table beside the results discussion, not on a standalone float page.
main_section=project/'sections/air_simulation.tex'
text=main_section.read_text()
pattern=r'% AIR-TABLE-1000-BEGIN.*?% AIR-TABLE-1000-END'
block=re.search(pattern,text,re.S).group(0)
text=re.sub(pattern,'',text,flags=re.S)
text=text.replace('\nThese comparisons require','\n'+block+'\n\nThese comparisons require')
main_section.write_text(text)

selected=[r for r in data['summary'] if r[2]!='Individual Sampler' or r[3]=='Posterior mean']
wins=0
for n in [500,1000,2000,4000]:
    for tau in [.01,.05,.1]:
        by={r[2]:r for r in selected if r[1]==n and r[0]==tau}
        wins+=by['Individual Sampler'][8]<by['ADMM'][8]
        if n==1000:
            assert by['Individual Sampler'][8]<by['ADMM'][8]
            assert by['Onizuka - Horseshoe'][6]<min(by['Individual Sampler'][6],by['ADMM'][6])
            assert all(by['Individual Sampler'][k]>by['ADMM'][k] for k in [11,12,13,14]) if tau==.01 else all(by['Individual Sampler'][k]<by['ADMM'][k] for k in [11,12,13,14])
assert wins==10
(Path(__file__).parent/'table_validation.json').write_text(json.dumps({'source_workbook':str(source.parent/'Air_Simulation_Mean_Metrics.xlsx'),'numeric_metric_entries':verified,'tables':4,'sampler_estimate':'posterior mean','individual_mse_below_admm_cells':wins},indent=2))
print(f'Verified {verified} metric entries against the workbook and generated four LaTeX tables.')
