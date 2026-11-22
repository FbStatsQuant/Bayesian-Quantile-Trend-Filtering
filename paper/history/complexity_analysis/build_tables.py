"""Build the LaTeX tables and a summary JSON for the computational-cost section from
timings.csv / prox_iterations.csv written by benchmark_cost.R.

usage: python build_tables.py <results_dir> <out_dir>
"""
import sys, json, os
import pandas as pd
import numpy as np

res_dir, out_dir = sys.argv[1], sys.argv[2]
os.makedirs(out_dir, exist_ok=True)
t = pd.read_csv(os.path.join(res_dir, "timings.csv"))
pr = pd.read_csv(os.path.join(res_dir, "prox_iterations.csv"))
sizes = sorted(t.n.unique())

LABEL = {
    "individual":            r"Individual sampler",
    "individual_sparseD":    r"Individual sampler, sparse $D$",
    "onizuka_Lap_dense":     r"Onizuka (Laplace), supplied, \texttt{sparse = FALSE}",
    "onizuka_Lap_sparseTRUE":r"Onizuka (Laplace), supplied, \texttt{sparse = TRUE}",
    "onizuka_HS_dense":      r"Onizuka (horseshoe), supplied, \texttt{sparse = FALSE}",
    "onizuka_HS_sparseTRUE": r"Onizuka (horseshoe), supplied, \texttt{sparse = TRUE}",
    "onizuka_Lap_banded":    r"Onizuka (Laplace), banded $\theta$ draw",
    "onizuka_HS_banded":     r"Onizuka (horseshoe), banded $\theta$ draw",
}
ORDER = ["individual", "onizuka_Lap_dense", "onizuka_Lap_sparseTRUE", "onizuka_HS_dense", "onizuka_HS_sparseTRUE"]

def fmt_cell(med, lo=None, hi=None, single=False):
    """one unit per cell: ms (integer) below 1 s, seconds with 3 significant figures above."""
    if med < 1000:
        f = lambda v: f"{v:.0f}"; unit = ""
    else:
        f = lambda v: f"{v/1000:.3g}"; unit = r"\,s"
    if single: return f"{f(med)}$^{{\\dagger}}$" + unit
    return f"{f(med)} ({f(lo)}--{f(hi)})" + unit

summary = {}
g = t.groupby(["method", "n"]).ms_per_sweep.agg(["median", "min", "max", "count"]).reset_index()
for _, r in g.iterrows():
    summary.setdefault(r.method, {})[int(r.n)] = dict(median=float(r["median"]), lo=float(r["min"]), hi=float(r["max"]), reps=int(r["count"]))

# ---- Table 1: ms per sweep, rows = methods, cols = n
cols = " ".join("r" for _ in sizes)
lines = [r"\begin{tabular}{l" + cols + "}", r"\toprule",
         "Method & " + " & ".join(f"$n = {n}$" for n in sizes) + r" \\", r"\midrule"]
single_rep_cells = []
for m in ORDER:
    if m not in summary: continue
    cells = []
    for n in sizes:
        if n in summary[m]:
            s = summary[m][n]
            if s["reps"] == 1:
                cells.append(fmt_cell(s["median"], single=True)); single_rep_cells.append((m, n))
            else:
                cells.append(fmt_cell(s["median"], s["lo"], s["hi"]))
        else:
            cells.append("---")
    lines.append(LABEL[m] + " & " + " & ".join(cells) + r" \\")
    if m == "individual": lines.append(r"\midrule")
lines += [r"\bottomrule", r"\end{tabular}"]
open(os.path.join(out_dir, "table_cost_scaling_body.tex"), "w", encoding="utf-8").write("\n".join(lines) + "\n")

# ---- Table 2: proximal workload of the individual sampler (dense D variant)
p = pr[pr.method == "individual"].copy()
p["prox_share"] = p.prox_ms_per_sweep / p.ms_per_sweep
agg = p.groupby("n").agg(inner_per_sweep=("inner_per_sweep", "median"), mean_inner=("mean_inner", "median"),
                         max_inner=("max_inner", "max"), cap_calls=("cap_calls", "sum"), nonzero=("nonzero_status", "sum"),
                         prox_share=("prox_share", "median"), acceptance=("acceptance", "median"),
                         acc_lo=("acceptance", "min"), acc_hi=("acceptance", "max"),
                         lambda_mean=("lambda_mean", "median"), delta_final=("delta_final", "median"),
                         calls=("calls", "sum")).reset_index()
lines = [r"\begin{tabular}{rrrrrrrr}", r"\toprule",
         r"$n$ & Inner per sweep & Mean per call & Max per call & Proximal share & Acceptance & $\bar\lambda$ & $\delta$ \\", r"\midrule"]
for _, r in agg.iterrows():
    lines.append(f"{int(r.n)} & {r.inner_per_sweep:.0f} & {r.mean_inner:.0f} & {int(r.max_inner)} & {100*r.prox_share:.0f}\\% & "
                 f"{r.acceptance:.2f} ({r.acc_lo:.2f}--{r.acc_hi:.2f}) & {r.lambda_mean:.0f} & {r.delta_final:.3f} \\\\")
lines += [r"\bottomrule", r"\end{tabular}"]
open(os.path.join(out_dir, "table_prox_workload_body.tex"), "w", encoding="utf-8").write("\n".join(lines) + "\n")
summary["prox"] = {int(r.n): {k: (float(v) if isinstance(v, (float, np.floating)) else int(v)) for k, v in r.items() if k != "n"} for _, r in agg.iterrows()}

# ---- ratios and scaling exponents for the prose
def med(m, n): return summary[m][n]["median"] if m in summary and n in summary[m] else None
ratios = {}
for n in sizes:
    d = {}
    for m in ["onizuka_Lap_dense", "onizuka_HS_dense", "onizuka_Lap_banded", "onizuka_HS_banded", "individual_sparseD"]:
        if med(m, n) and med("individual", n): d[m] = med(m, n) / med("individual", n)
    if med("onizuka_Lap_dense", n) and med("onizuka_Lap_banded", n): d["dense_over_banded_Lap"] = med("onizuka_Lap_dense", n) / med("onizuka_Lap_banded", n)
    if med("onizuka_HS_dense", n) and med("onizuka_HS_banded", n): d["dense_over_banded_HS"] = med("onizuka_HS_dense", n) / med("onizuka_HS_banded", n)
    ratios[int(n)] = d
summary["ratios"] = ratios
slopes = {}
for m in summary:
    if m in ("prox", "ratios"): continue
    ns = sorted(summary[m]); 
    if len(ns) >= 2:
        x = np.log([n for n in ns]); y = np.log([summary[m][n]["median"] for n in ns])
        slopes[m] = float(np.polyfit(x, y, 1)[0])
summary["loglog_slope"] = slopes
summary["single_rep_cells"] = single_rep_cells
summary["protocol"] = {m: {int(n): dict(warm=int(w), measured=int(k), reps=int(c)) for (n, w, k), c in
                           t[t.method == m].groupby(["n", "warm", "measured"]).size().items()} for m in t.method.unique()}
def _keys(o):
    if isinstance(o, dict): return {str(k): _keys(v) for k, v in o.items()}
    if isinstance(o, (list, tuple)): return [_keys(v) for v in o]
    return o
json.dump(_keys(summary), open(os.path.join(out_dir, "summary.json"), "w"), indent=1, default=float)
print(json.dumps({"n": sizes, "ratios": ratios, "slopes": slopes}, indent=1, default=lambda v: round(float(v), 2)))
