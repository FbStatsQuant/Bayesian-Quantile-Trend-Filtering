from pathlib import Path
import re,json,openpyxl

root=Path('G:/My Drive/Quantile Regression/PMALA version Tex Project')
work=root/'notes/simulation_revision_20260914'
before=work/'before'
source=Path('C:/Users/felip/OneDrive - Rice University/NOTS Data/BQTF/Individual Comparisons/Individual_Comparison_n500_v2.xlsx')
w=openpyxl.load_workbook(source,data_only=True)
data={m:{loss:[list(r) for r in w[f'{m}_{loss}'].iter_rows(min_row=4,max_row=7,min_col=2,max_col=16,values_only=True)] for loss in ['MSE','MAD','MCIW']} for m in ['VS','S']}
(work/'table_source.json').write_text(json.dumps(data,indent=2))
ext={}
for p in ['simulations.tex','appendix_simulations.tex']:
    for tab in re.findall(r'\\begin\{table\}.*?\\end\{table\}',(before/p).read_text(),re.S):
        key=re.search(r'\\label\{([^}]+)\}',tab).group(1)
        if re.match('tab:(vs|s)_ext_',key):
            ext[key]=tab

def table(model,metric):
    name={'VS':'varying-smoothness (VS)','S':'smooth (S)'}[model]
    order={'VS':1,'S':2}[model]
    measure={'MSE':'Mean squared error (MSE)','MAD':'Mean absolute deviation (MAD)','MCIW':'Mean 95\\% pointwise credible-interval width (MCIW)'}[metric]
    caption=f'{measure} for the {name} signal ($k={order}$), $n=500$, at interior quantile levels.'
    if metric!='MCIW':
        caption+=' The three samplers use 100 replications per cell. ADMM uses '+('98--100' if model=='VS' else '55--88')+' valid replications per cell.'
        if model=='S': caption+=' ADMM exclusions may be nonrandom.'
    else:
        caption+=' ADMM supplies point estimates only; n/a denotes an unavailable interval width.'
    lines=[r'\begin{table}[!htbp]',r'\centering',r'\small',r'\caption{'+caption+'}',r'\label{tab:'+model.lower()+'_int_'+metric.lower()+'}',r'\begin{tabular}{lrrrrr}',r'\toprule']
    for idx,noise in enumerate(['Beta','Mixed normal','Gaussian']):
        if idx: lines.append(r'\midrule')
        lines.append(noise+r' & $0.05$ & $0.25$ & $0.50$ & $0.75$ & $0.95$ \\')
        lines.append(r'\midrule')
        for j,method in enumerate(['Onizuka (Laplace)','Onizuka (Horseshoe)','Individual sampler (mean)','ADMM']):
            vals=data[model][metric][j][idx*5:idx*5+5]
            lines.append(method+' & '+' & '.join(f'{v:.6f}' if isinstance(v,(float,int)) else 'n/a' for v in vals)+r' \\')
    lines.extend([r'\bottomrule',r'\end{tabular}',r'\end{table}'])
    return '\n'.join(lines)+'\n'

sim=r'''\section{Simulation}
\label{sec:simulations}

We study two benchmark signals: a varying-smoothness signal (VS), used by \citet{onizuka2024fast}, and a smooth sinusoidal signal (S), used in the first simulation study of \citet{brantley2020baseline}. The former combines gradual variation with a localized feature, whereas the latter represents the smoothly varying baseline that motivates the ADMM approach. Together they assess how the individual sampler of Section~\ref{subsec:individual} compares with Bayesian and optimization-based quantile trend filtering under different patterns of smoothness. The interior-quantile experiment uses $n=500$ observations and the five levels $\tau\in\{0.05,0.25,0.50,0.75,0.95\}$. Tables~\ref{tab:vs_int_mse} and \ref{tab:s_int_mse} report MSE in the main text; MAD and MCIW appear in Appendix~\ref{app:sim:individual}.

\paragraph{Benchmark signals.}
For equally spaced indices $x_i=i$, $i=1,\ldots,n$, let $u_i=i/n$. We generate $y_i=f(u_i)+\varepsilon_i$ independently across indices, with
\begin{align}
 f_{\mathrm{VS}}(u)&=2+\sin(4u-2)+2\exp\{-30(4u-2)^2\},
 \label{eq:sim_vs}\\
 f_{\mathrm{S}}(u)&=\sin(2\pi u).
 \label{eq:sim_s}
\end{align}
We fit VS with $k=1$ and S with $k=2$, using the penalty on $D^{(k+1)}\theta$ defined in Section~\ref{subsec:individual}. Thus the fitted trends are piecewise linear and piecewise quadratic, respectively. The function $f$ is a baseline location curve; it need not equal the conditional mean or any particular conditional quantile when the errors are asymmetric.

\paragraph{Noise distributions.}
Both the ADMM study of \citet{brantley2020baseline} and the Bayesian study of \citet{onizuka2024fast} include Gaussian, Beta, and mixed-normal errors. We use these same three noise families, with the parameterization of \citet{onizuka2024fast}:
\begin{itemize}
 \item Gaussian: $\varepsilon_i\sim\mathcal{N}(0,s(u_i)^2)$, where $s(u)=(1+u^2)/4$.
 \item Beta: $\varepsilon_i\sim\mathrm{Beta}(1,11-10u_i)$.
 \item Mixed normal: $\varepsilon_i\sim u_i\mathcal{N}(-0.2,0.5)+(1-u_i)\mathcal{N}(0.2,0.5)$, where the second argument is the component variance.
\end{itemize}
The Gaussian case is heteroscedastic, the Beta distribution changes shape across the design, and the normal mixture has a design-dependent mixing weight. Brantley et al.\ use the same Gaussian and Beta specifications, but their normal mixture has components $\mathcal{N}(-1,1)$ and $\mathcal{N}(1,1)$; our mixed-normal experiment therefore follows Onizuka et al.\ rather than reproducing that parameterization exactly. All methods in our comparison are evaluated under the same noise specification.

For each level $\tau$, the true conditional quantile is $Q_\tau(u)=f(u)+F_u^{-1}(\tau)$, where $F_u$ is the error distribution at $u$. For Gaussian errors this gives $f(u)+s(u)\Phi^{-1}(\tau)$, and for Beta errors we use the corresponding Beta quantile. For mixed-normal errors we numerically invert
\[
 F_u(t)=u\Phi\!\left(\frac{t+0.2}{\sqrt{0.5}}\right)
       +(1-u)\Phi\!\left(\frac{t-0.2}{\sqrt{0.5}}\right).
\]

\subsection{Individual sampler at interior quantiles}
\label{sec:sim:individual}

\paragraph{Methods and replications.}
We compare the individual sampler with the Laplace and horseshoe MCMC variants of \citet{onizuka2024fast} and the ADMM quantile trend filtering benchmark of \citet{brantley2020baseline}. The Bayesian point estimates are posterior means. The individual sampler uses $6000$ Gibbs iterations, discarding the first $1000$, with fixed, configuration-specific P-MALA step sizes and an $\mathrm{IG}(0.01,0.01)$ prior for the likelihood scale. The Onizuka samplers use $8000$ iterations with $1000$ burn-in iterations. ADMM returns an optimization-based point estimate rather than posterior draws.

There are $100$ intended replications for each signal, noise distribution, and quantile level. All three samplers have $100$ reported replications per cell. The available ADMM run is partial: VS has $98$--$100$ valid replications per cell, and S has $55$--$88$. We retain the reported averages over valid runs. Because the excluded runs need not be random, particularly for S, these ADMM averages may be optimistic and are not a complete paired comparison over all $100$ seeds.

\paragraph{Performance measures.}
For replication $r$, let $\widehat{\theta}_{\tau,i}^{(r)}$ be the point estimate and $[L_{\tau,i}^{(r)},U_{\tau,i}^{(r)}]$ the $95\%$ pointwise posterior interval. We compute
\begin{align*}
 \mathrm{MSE}^{(r)}_\tau&=\frac{1}{n}\sum_{i=1}^n
  \bigl(\widehat{\theta}_{\tau,i}^{(r)}-Q_\tau(u_i)\bigr)^2,\\
 \mathrm{MAD}^{(r)}_\tau&=\frac{1}{n}\sum_{i=1}^n
  \bigl|\widehat{\theta}_{\tau,i}^{(r)}-Q_\tau(u_i)\bigr|,\\
 \mathrm{MCIW}^{(r)}_\tau&=\frac{1}{n}\sum_{i=1}^n
  \bigl(U_{\tau,i}^{(r)}-L_{\tau,i}^{(r)}\bigr),
\end{align*}
and average each measure over the available replications. MCIW is unavailable for the ADMM point estimator. A smaller interval width alone does not establish better uncertainty quantification; calibration must be assessed separately.

\subsubsection{Varying smoothness}
\label{sec:sim:ind:vs}

Table~\ref{tab:vs_int_mse} shows that the individual sampler remains competitive with Onizuka's locally adaptive horseshoe sampler in the Gaussian and mixed-normal settings while using a single global penalty $\lambda$, rather than a vector of random local shrinkage scales. For example, at $\tau=0.50$ its MSE is $0.005616$ versus $0.004449$ for the horseshoe under Gaussian noise, and $0.022183$ versus $0.017310$ under mixed-normal noise. These are modest absolute differences for a substantially simpler shrinkage hierarchy. The individual sampler also improves on the Laplace sampler throughout the mixed-normal design and at four of the five Gaussian levels, and has lower MSE than ADMM in every VS configuration.

The horseshoe nevertheless has the lowest MSE in all $15$ VS configurations. The individual sampler's relative disadvantage is more pronounced under Beta noise, and its Gaussian MSE at $\tau=0.05$ exceeds both Onizuka variants. Competitiveness here therefore means retaining useful estimation accuracy with a simpler hierarchy, rather than matching the horseshoe uniformly. Tables~\ref{tab:vs_int_mad} and \ref{tab:vs_int_mciw} report MAD and MCIW.

'''+table('VS','MSE')+r'''
\subsubsection{Smooth signal}
\label{sec:sim:ind:smooth}

For S, the individual sampler improves on both Onizuka variants in MSE at every Gaussian and mixed-normal level and at four of the five Beta levels (Table~\ref{tab:s_int_mse}). The exception is $\tau=0.05$ under Beta noise. The same ordering among the three samplers holds for MAD, reported in Table~\ref{tab:s_int_mad}.

ADMM is particularly well suited to this smooth-baseline setting: the sinusoidal S signal was used to benchmark the baseline estimator in \citet{brantley2020baseline}. It has the lowest reported MSE and MAD in all S configurations. The individual sampler nevertheless obtains errors of a similar magnitude while performing posterior simulation rather than returning only an optimizer. For example, at the Gaussian median its MSE is $0.003453$, compared with $0.002574$ for ADMM, and its MAD is $0.044661$, compared with $0.038316$. The sampler additionally produces posterior draws and pointwise interval summaries, although their calibration requires separate evaluation. This comparison concerns the strengths of the methods in the smooth setting; ADMM itself is not restricted to smooth signals. Its partial S results also require the replication caveat above.

'''+table('S','MSE')+r'''
\paragraph{Interpretation across the two signals.}
The individual sampler provides a compromise between two useful approaches. ADMM offers efficient point estimation for smooth baselines, while Onizuka's horseshoe Gibbs sampler offers local adaptation through a larger shrinkage hierarchy and incurs substantial matrix-computation costs in the supplied implementation. Our sampler uses one global penalty per quantile and ADMM-based proximal updates to obtain posterior draws with a simpler computational structure. Its S losses are of a similar magnitude to the available ADMM losses, and its Gaussian and mixed-normal VS errors remain competitive with the horseshoe despite the reduction in random shrinkage parameters. These results support the compromise in estimation accuracy; computational efficiency per effective draw must also account for mixing and the number of inner ADMM iterations.

Posterior output is an additional capability, not by itself a guarantee of reliable uncertainty quantification. Appendix Tables~\ref{tab:vs_int_mciw} and \ref{tab:s_int_mciw} report interval widths without treating narrowness as a measure of calibration. In particular, the source run reports zero-width intervals for the individual sampler in $45\%$ of VS and $60\%$ of S replications under Beta noise at $\tau=0.05$; the small MCIW values in those cells require caution.

\clearpage
\subsection{Joint sampler for extreme quantiles}
\label{sec:sim:joint}

The joint sequential sampler of Section~\ref{subsec:joint}, equipped with the sentinel construction of Section~\ref{subsec:sentinel}, is evaluated at $\tau\in\{0.01,0.02,0.98,0.99\}$. These previously reported extreme-quantile experiments use $n=400$ and $100$ replications, and are distinct from the updated $n=500$ interior-quantile comparison. The competitors are the two Onizuka MCMC variants, which fit each quantile independently. Complete VS and S results are retained in Appendix~\ref{app:sim:joint}.

\subsubsection{Varying smoothness}
\label{sec:sim:joint:vs}
For VS, the joint sampler lies between the two Onizuka variants in Gaussian MSE. Under mixed-normal noise it has smaller MSE than the horseshoe at $\tau=0.02,0.98,0.99$, and the two have the same displayed MSE at $\tau=0.01$. Beta-tail results are more mixed. Tables~\ref{tab:vs_ext_mse}, \ref{tab:vs_ext_mad}, and \ref{tab:vs_ext_mciw} give the complete comparison.

\subsubsection{Smooth signal}
\label{sec:sim:joint:smooth}
For S, the horseshoe has lower extreme-quantile MSE than the joint sampler under Gaussian and mixed-normal noise, and both Onizuka variants have lower MSE under Beta noise. The joint sampler improves on the Laplace variant at every mixed-normal level. These results, reported in Tables~\ref{tab:s_ext_mse}, \ref{tab:s_ext_mad}, and \ref{tab:s_ext_mciw}, do not show a uniform advantage from the sentinel construction.

The joint sampler's narrow intervals must be interpreted in the context of its non-crossing constraints. Neighboring quantiles restrict the target's admissible range during sampling, so interval widths alone do not show that its uncertainty statements are better calibrated than those of the independent Onizuka fits. The MCIW results in Appendix~\ref{app:sim:joint} are descriptive summaries of these different posterior constructions.
'''
(root/'sections/simulations.tex').write_text(sim)

app=r'''\section{Additional Simulation Results}
\label{app:simulation_results}

This appendix reports the MAD and MCIW results accompanying the VS and S interior-quantile MSE tables in Section~\ref{sec:sim:individual}, followed by the complete retained extreme-quantile results. Interior tables use the updated $n=500$ comparison; the extreme-quantile tables retain the earlier $n=400$ experiment.

\subsection{Individual sampler at interior quantiles}
\label{app:sim:individual}

The interior-quantile summaries use posterior means for the three samplers and the ADMM point estimate. The sampler results use $100$ replications per cell; ADMM uses $98$--$100$ for VS and $55$--$88$ for S. The incomplete S run may be affected by nonrandom exclusions. MCIW is the average width of the $95\%$ pointwise posterior intervals and is not available for ADMM.

\subsubsection{Varying smoothness}
Onizuka's horseshoe sampler has the lowest VS MAD in every configuration (Table~\ref{tab:vs_int_mad}). The individual sampler's intervals are narrower than those of both Onizuka variants under Gaussian and Beta noise, but the mixed-normal ranking varies (Table~\ref{tab:vs_int_mciw}). At the lower Beta level $\tau=0.05$, $45\%$ of individual-sampler replications have zero-width intervals, so the small average width does not indicate well-calibrated uncertainty.

'''+table('VS','MAD')+'\n'+table('VS','MCIW')+r'''
\clearpage
\subsubsection{Smooth signal}
\label{app:sim:individual:smooth}
Table~\ref{tab:s_int_mad} shows the individual sampler's lower MAD than both Onizuka variants in all but the lowest Beta quantile. ADMM has the lowest reported MAD, subject to its incomplete replication set. The individual sampler has the narrowest intervals throughout Table~\ref{tab:s_int_mciw}; at $\tau=0.05$ under Beta noise, however, $60\%$ of its replications have zero-width intervals. Narrower intervals must therefore be distinguished from reliable uncertainty quantification.

'''+table('S','MAD')+'\n'+table('S','MCIW')+r'''
\clearpage
\subsection{Joint sampler at extreme quantiles}
\label{app:sim:joint}

These tables retain the previously reported extreme-quantile experiment with $n=400$, $100$ replications, and target levels $0.01$, $0.02$, $0.98$, and $0.99$. They compare the joint sequential sampler with sentinels against independently fitted Onizuka MCMC samplers. The values have not been replaced by the $n=500$ interior-quantile results.

\subsubsection{Varying smoothness}
Tables~\ref{tab:vs_ext_mse}, \ref{tab:vs_ext_mad}, and \ref{tab:vs_ext_mciw} report MSE, MAD, and MCIW for VS with $k=1$. Interval widths are subject to the interpretation in Section~\ref{sec:sim:joint}.

'''
for metric in ['mse','mad','mciw']: app+=ext['tab:vs_ext_'+metric]+'\n\n'
app+=r'''\clearpage
\subsubsection{Smooth signal}
\label{app:sim:joint:smooth}
Tables~\ref{tab:s_ext_mse}, \ref{tab:s_ext_mad}, and \ref{tab:s_ext_mciw} report the corresponding results for S with $k=2$. The horseshoe has lower MSE than the joint sampler under Gaussian and mixed-normal noise, while both Onizuka variants have lower MSE under Beta noise. The narrower joint-sampler intervals do not by themselves establish superior calibration.

'''
for metric in ['mse','mad','mciw']: app+=ext['tab:s_ext_'+metric]+'\n\n'
app+=r'\clearpage'+'\n'
(root/'sections/appendix_simulations.tex').write_text(app)

intro=r'''\section{Introduction}
\label{sec:introduction}

Time-varying conditional quantiles describe how the lower tail, center, and upper tail of a response evolve across an ordered domain. They are useful when changes in variability or asymmetry matter as much as changes in location, as in environmental monitoring, growth assessment, and economic time series. Quantile trend filtering combines the check loss of \citet{koenker1978regression} with an $\ell_1$ penalty on discrete differences, adapting a piecewise polynomial fit to local changes in the signal \citep{tibshirani2014adaptive,madrid2022risk}.

\citet{brantley2020baseline} developed a quantile trend filtering approach for smoothly varying baseline drift, including joint non-crossing estimation, smoothing-parameter selection, and an alternating direction method of multipliers (ADMM) algorithm. Their formulation provides an effective optimization-based benchmark, especially for the smooth-baseline setting that motivates the method. At a selected regularization level, however, the optimizer supplies point estimates; posterior simulation requires a probabilistic model and an inference procedure beyond that optimization step.

We develop a Bayesian extension that retains this computational connection. Under an asymmetric Laplace working likelihood and a global Laplace prior on trend differences, the conditional posterior mode at unit likelihood scale and fixed regularization parameter coincides with the frequentist quantile trend filtering solution. We instead infer the regularization strength and likelihood scale jointly with the trend. The resulting posterior mean need not equal the optimizer, but both arise from the same check-loss and difference-penalty structure. Section~\ref{subsec:individual} states this connection explicitly.

Bayesian and calibrated loss-based methods provide related approaches to quantile smoothing. \citet{fasiolo2021fast} developed fast calibrated additive quantile regression. For quantile trend filtering, \citet{onizuka2024fast} combined an asymmetric Laplace likelihood with shrinkage priors and developed both Gibbs sampling and calibrated variational approximations. Their horseshoe prior supports coefficient-specific shrinkage, allowing the amount of regularization to vary across the trend. The supplied Gibbs implementation uses latent-variable and local-scale updates together with a changing Gaussian precision matrix; its dense matrix operations motivate an alternative computational route for long signals. This observation concerns that implementation, rather than an unavoidable complexity bound for all Gaussian Gibbs samplers.

Proximal MCMC provides a way to construct such an alternative for nonsmooth models \citep{pereyra2016proximal}. In mean trend filtering, \citet{heng2023bayesian} used proximal Bayesian computation to learn the trend, scale, and regularization parameters. Quantile trend filtering introduces an additional nonsmooth term through the check loss. We use a three-block Gibbs scheme: conjugate updates for a global regularization parameter $\lambda$ and likelihood scale $\sigma$, followed by a proximal Metropolis-adjusted Langevin (P-MALA) update of the trend. ADMM solves the proximal subproblems. Each quantile has only two sampled scalar hyperparameters in addition to its trend, without observation-level likelihood augmentation or separate random scales for every trend difference.

The same construction extends to joint estimation under non-crossing constraints. Quantiles are updated sequentially, with box constraints determined by the current neighboring trends. These constraints enter the proximal ADMM solver through an elementwise projection. Its fixed coefficient matrix permits reuse of a banded factorization; with sparse operations and a fixed inner iteration budget, the work per outer iteration is linear in the sample size. The cost per effective posterior draw also depends on mixing and the accuracy of the proximal solve.

At extreme probability levels, gradient-based quantile sampling can be difficult. We introduce auxiliary sentinel quantiles outside the target range, using the non-crossing constraints to bound the target dynamically during sampling. This is a practical sampling strategy whose performance must be assessed empirically. The retained extreme-quantile results show that its accuracy depends on the signal and noise distribution; narrow constrained intervals alone do not establish calibrated uncertainty.

Our simulation study focuses on two established benchmarks: the varying-smoothness signal used by \citet{onizuka2024fast} and the sinusoidal smooth signal used by \citet{brantley2020baseline}. Both papers considered Gaussian, Beta, and mixed-normal noise; our exact noise parameterization follows Onizuka et al.\ We compare posterior-mean estimates from the individual sampler with the two Onizuka MCMC variants and the ADMM point estimator at quantile levels from $0.05$ to $0.95$. The horseshoe sampler is strongest on the varying-smoothness benchmark, while our sampler improves on both Bayesian competitors in most smooth-signal configurations. ADMM has lower reported smooth-signal errors, but the sampler attains errors of a similar magnitude while producing posterior draws rather than only an optimizer. The partial ADMM run and limitations of the interval summaries are reported with the results.

The proposed sampler is thus a compromise between computationally efficient optimization and a more elaborate locally adaptive Bayesian hierarchy. Relative to ADMM as a standalone estimator, it adds posterior sampling and learning of the regularization and likelihood scales. Relative to the supplied Onizuka Gibbs implementation, it replaces a vector of local shrinkage scales with one global penalty per quantile and uses reusable proximal computations to address the scalability bottleneck. Its competitive Gaussian and mixed-normal VS results and smooth-signal accuracy illustrate this tradeoff. The contribution is an intermediate approach that preserves useful estimation performance while offering both a simpler sampling hierarchy and posterior output, rather than a claim of uniformly smaller losses or automatically calibrated intervals.

Section~\ref{sec:methodology} presents the model, individual and joint samplers, ADMM proximal operator, and sentinel construction. Section~\ref{sec:simulations} reports the simulation study, with additional tables in Appendix~\ref{app:simulation_results}. Section~\ref{sec:applications} presents the data applications, and Section~\ref{sec:discussion} discusses the findings and limitations.
'''
(root/'sections/introduction.tex').write_text(intro)

abstract=(before/'abstract.tex').read_text().replace('piecewise constant, varying smoothness, and smooth signals','varying-smoothness and smooth signals')
abstract=abstract.replace('The results show competitive estimation relative to the Bayesian approach of \\citet{onizuka2024fast}.','The individual sampler improves on both Bayesian competitors in most smooth-signal configurations, while the horseshoe benchmark is more accurate on the varying-smoothness signal. Its smooth-signal errors are of a similar magnitude to the available ADMM results, with posterior draws as an additional output; incomplete ADMM replications and interval calibration limit the comparison.')
(root/'sections/abstract.tex').write_text(abstract)

disc=(before/'discussion.tex').read_text()
disc=re.sub(r'(\\paragraph\{Summary of findings\.\}\n).*?(?=\\paragraph\{Scalability\.\})',lambda m:m.group(1)+r'''The updated interior-quantile experiment shows a clear dependence on signal structure. Onizuka's horseshoe sampler has the lowest reported MSE and MAD throughout the VS benchmark. For S, the individual sampler improves on both Onizuka variants at every Gaussian and mixed-normal level and at all but the lowest Beta level. ADMM is well suited to the smooth-baseline setting that motivated \citet{brantley2020baseline}, and has the lowest reported S losses. The individual sampler nevertheless produces errors of a similar magnitude through posterior simulation, together with posterior draws and interval summaries. Its VS losses are lower than those of ADMM. The ADMM S averages use only 55--88 valid replications per cell and may benefit from nonrandom exclusions, so they do not establish an unconditional ranking over the full intended experiment.

''',disc,flags=re.S)
disc=re.sub(r'(\\paragraph\{Limitations\.\}\n).*?(?=\\paragraph\{The sentinel strategy)',lambda m:m.group(1)+r'''A single global penalty is a deliberate simplification relative to coefficient-specific shrinkage. The VS results favor the horseshoe, whereas the individual sampler is more competitive on the globally smooth S signal. These two experiments do not establish a universally preferred prior or difference order. The uncertainty summaries also require further validation: narrow MCIW values do not imply calibrated intervals, and the individual sampler produces zero-width intervals in a substantial fraction of the lowest-Beta-quantile replications. Fixed step sizes and finite chains make mixing diagnostics and sensitivity analysis essential before treating the intervals as reliable uncertainty statements.

''',disc,flags=re.S)
disc=disc.replace(r'The weakly informative prior $\sigma \sim \mathrm{IG}(0.1, 0.1)$ is sufficient to regularize this in all settings considered, but sensitivity of the posterior to this prior choice warrants attention in applications where the noise distribution is far from symmetric or unimodal.',r'The likelihood-scale prior can regularize this interaction, but sensitivity to its parameters remains an empirical question. The updated interior-quantile experiment uses $\sigma\sim\mathrm{IG}(0.01,0.01)$, as stated in Section~\ref{sec:sim:individual}.')
(root/'sections/discussion.tex').write_text(disc)

method=(before/'methodology.tex').read_text()
method=re.sub(r'For \$k = 0\$, the estimator.*?\n\n','',method,flags=re.S)
method=method.replace('This order exhibits a degree of robustness that lower orders do not share: misspecification of $c$ produces gradual degradation in mean squared error rather than the catastrophic structural collapse observed for $k = 0$.','Sensitivity to this scaling should be assessed for the specific signal and sample size.')
method=method.replace('among the three orders','between the two fitted orders')
method=method.replace('their full simulation suite, which spans two signal structures---piecewise constant (PC) and varying smoothness (VS)---under three noise distributions: Gaussian, Beta, and mixed normal.','their simulation study, which includes the varying-smoothness benchmark under Gaussian, Beta, and mixed-normal noise.')
method=method.replace(r'In our implementation we set $a_\sigma = b_\sigma = 0.1$, a weakly informative choice that lets the data dominate the posterior for $\sigma$.',r'The scale-prior parameters are specified for each experiment; the updated interior-quantile comparison uses $a_\sigma=b_\sigma=0.01$.')
(root/'sections/methodology.tex').write_text(method)

bib=(before/'references.bib').read_text()
bib=bib.replace('author={Koenker, Roger and Bassett Jr, Gilbert}','author={Koenker, Roger and Bassett, Jr., Gilbert}')
bib=bib.replace('journal={Econometrica: journal of the Econometric Society},','journal={Econometrica},\n  volume={46},\n  number={1},')
bib=bib.replace('Proximal markov chain monte carlo algorithms','Proximal {Markov} chain {Monte Carlo} algorithms')
bib+=r'''
@article{heng2023bayesian,
  title={Bayesian trend filtering via proximal {Markov} chain {Monte Carlo}},
  author={Heng, Qiang and Zhou, Hua and Chi, Eric C.},
  journal={Journal of Computational and Graphical Statistics},
  volume={32},
  number={3},
  pages={938--949},
  year={2023},
  doi={10.1080/10618600.2023.2170089}
}
'''
for key,doi in {'onizuka2024fast':'10.1007/s11222-023-10327-y','brantley2020baseline':'10.1214/19-AOAS1318','pereyra2016proximal':'10.1007/s11222-015-9567-4','fasiolo2021fast':'10.1080/01621459.2020.1725521','yang2017joint':'10.1080/01621459.2016.1192545'}.items():
    bib=bib.replace('@article{'+key+',','@article{'+key+',\n  doi={'+doi+'},')
(root/'references.bib').write_text(bib)
print('Rewrote simulation and introduction; generated six interior tables directly from source; retained six VS/S extreme tables in appendix. Removed PC experiment and updated affected manuscript claims.')
