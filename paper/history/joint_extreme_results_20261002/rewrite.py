"""One-time manuscript edit using the inspected, saved NOTS averages."""
from pathlib import Path
import csv

here = Path(__file__).resolve().parent
project = here.parent.parent
rows = list(csv.DictReader((here / "average_metrics_tau096_099.csv").open()))
assert len(rows) == 12 and all(row["n_seeds"] == "100" for row in rows)

def values(noise, metric):
    block = sorted((r for r in rows if r["noise"] == noise), key=lambda r: float(r["tau"]))
    assert [float(r["tau"]) for r in block] == [.96, .97, .98, .99]
    return " & ".join(f"{float(r[metric]):.6f}" for r in block)

path = project / "sections" / "simulations.tex"
old = path.read_text(encoding="utf-8")
intro, previous = old.split(r"\subsection{Extreme upper quantiles}", 1)
intro = intro.replace(
    r"The extreme-quantile experiment of Section~\ref{sec:sim:extreme} keeps $n=500$, the order $k=2$ and the three noise families, and is run on the varying-smoothness signal at the four upper levels $\tau\in\{0.96,0.97,0.98,0.99\}$; Table~\ref{tab:vs_ext_upper_mse} reports it in the main text.",
    r"Section~\ref{sec:sim:extreme} evaluates joint estimation of upper quantiles on the VS signal, reporting MSE at $\tau\in\{0.96,0.97,0.98,0.99\}$ in Table~\ref{tab:vs_ext_upper_mse} and joint MAD and MCIW in Appendix~\ref{app:sim:joint_extreme}.")
prose = r"""\subsection{Joint estimation of extreme upper quantiles}
\label{sec:sim:extreme}

We use the joint sampler of Section~\ref{subsec:joint} to assess accuracy at extreme upper quantiles and to exploit its non-crossing constraint when quantile levels are close together. For the VS signal with $n=500$, $k=2$ and the three noise distributions above, we jointly fit $\tau\in\{0.90,0.93,0.96,0.97,0.98,0.99\}$ and evaluate the four levels $0.96$--$0.99$. The comparison includes the individually fitted Bayesian-PMALA sampler, the Laplace and horseshoe samplers of \citet{onizuka2024fast}, and the ADMM estimator of \citet{brantley2020baseline}.

The joint results average $100$ replications per noise distribution, using posterior means from $30000$ sweeps with $10000$ discarded as burn-in. We retain the joint implementation's default settings, including $\lambda_j\sim\mathrm{Gamma}(1,10^{-2})$ and $\sigma_j\sim\mathrm{IG}(0.1,0.1)$; the individual Bayesian-PMALA results retain the $\mathrm{Gamma}(1,10^{-3})$ prior of the interior comparison. Table~\ref{tab:vs_ext_upper_mse} reports MSE, while Tables~\ref{tab:vs_ext_upper_mad_joint} and \ref{tab:vs_ext_upper_mciw_joint} in Appendix~\ref{app:sim:joint_extreme} report joint MAD and MCIW.

The joint sampler has the lowest MSE in $9$ of the $12$ configurations: all Gaussian and mixed-normal cases and the Beta case at $\tau=0.99$; the horseshoe sampler leads in the remaining three. It improves on individual Bayesian-PMALA at every reported level, with reductions at $\tau=0.99$ of approximately $40\%$, $48\%$ and $51\%$ under Beta, Gaussian and mixed-normal noise, respectively. These gains accompany non-crossing fits, although the different penalty priors mean that the comparison does not isolate the effect of the ordering constraint.

"""
table = r"\begin{table}" + previous.split(r"\begin{table}", 1)[1]
caption_start = table.index(r"\caption{")
caption_end = table.index("\n", caption_start)
table = table[:caption_start] + r"\caption{Mean squared error at extreme upper quantiles for the VS signal, $n=500$ and $k=2$. The joint sampler fits six levels together and its entries average $100$ replications per noise distribution.}" + table[caption_end:]
for noise in ["Beta", "Mixed", "Normal"]:
    table = table.replace(r"Joint sampler (non-crossing) & \multicolumn{4}{c}{pending} \\",
                          "Joint sampler (non-crossing) & " + values(noise, "mean_MSE") + r" \\", 1)
assert "pending" not in table
path.write_text(intro + prose + table, encoding="utf-8")

path = project / "sections" / "appendix_simulations.tex"
appendix = path.read_text(encoding="utf-8")
appendix = appendix.replace(
    r"This appendix reports the MAD and MCIW results accompanying the VS and S interior-quantile MSE tables in Section~\ref{sec:sim:individual}. All tables use the $n=500$ comparison.",
    r"This appendix supplements the interior-quantile comparisons of Section~\ref{sec:sim:individual} and the joint extreme-quantile experiment of Section~\ref{sec:sim:extreme}. All tables use $n=500$ and order $k=2$.")
appendix += r"""
\clearpage
\subsection{Joint estimation of extreme upper quantiles}
\label{app:sim:joint_extreme}

Tables~\ref{tab:vs_ext_upper_mad_joint} and \ref{tab:vs_ext_upper_mciw_joint} supplement the MSE comparison in Section~\ref{sec:sim:extreme}. Entries are averages over the same $100$ replications per noise distribution, with all six quantile levels fitted jointly. MAD uses the posterior mean, and MCIW is the average width of the equal-tail $95\%$ pointwise posterior intervals.

"""
for metric, name, caption in [
    ("mean_MAD", "mad", "Mean absolute deviation (MAD) of the joint sampler at extreme upper quantiles for the VS signal, $n=500$ and $k=2$."),
    ("mean_MCIW", "mciw", r"Mean $95\%$ pointwise credible-interval width (MCIW) of the joint sampler at extreme upper quantiles for the VS signal, $n=500$ and $k=2$.")]:
    appendix += "\n".join([
        r"\begin{table}[!htbp]", r"\centering", r"\small", "\\caption{" + caption + "}",
        r"\label{tab:vs_ext_upper_" + name + "_joint}", r"\begin{tabular}{lrrrr}", r"\toprule",
        r"Noise & $0.96$ & $0.97$ & $0.98$ & $0.99$ \\", r"\midrule",
        *[label + " & " + values(noise, metric) + r" \\" for label, noise in
          [("Beta", "Beta"), ("Mixed normal", "Mixed"), ("Gaussian", "Normal")]],
        r"\bottomrule", r"\end{tabular}", r"\end{table}", "", ""])
path.write_text(appendix, encoding="utf-8")
print("Replaced extreme-quantile prose; inserted 12 MSE, 12 MAD, and 12 MCIW entries from saved results.")
