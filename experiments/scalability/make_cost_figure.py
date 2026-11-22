"""Log-log figure of time per complete Gibbs sweep against n.  usage: python make_cost_figure.py <results_dir> <out_stem>"""
import sys, os
import numpy as np, pandas as pd
import matplotlib as mpl
import matplotlib.pyplot as plt

res_dir, out_stem = sys.argv[1], sys.argv[2]
apply_figure_style(sizes=(8, 7, 6))
t = pd.read_csv(os.path.join(res_dir, "timings.csv"))
g = t.groupby(["method", "n"]).ms_per_sweep.agg(["median", "min", "max", "count"]).reset_index()

series = [  # (method key, label, colour, linestyle, marker, focal?)
    ("individual",             "Individual sampler",                       "#b2182b", "-",  "o", True),
    ("onizuka_Lap_dense",      "Onizuka Laplace, sparse = FALSE",          "#2166ac", "-",  "s", False),
    ("onizuka_HS_dense",       "Onizuka horseshoe, sparse = FALSE",        "#67a9cf", "-",  "D", False),
    ("onizuka_Lap_sparseTRUE", "Onizuka Laplace, sparse = TRUE",           "#2166ac", ":",  "s", False),
    ("onizuka_HS_sparseTRUE",  "Onizuka horseshoe, sparse = TRUE",         "#67a9cf", ":",  "D", False),
]
fig, ax = plt.subplots(figsize=(4.6, 3.2))
ends = []
for key, lab, col, ls, mk, focal in series:
    d = g[g.method == key].sort_values("n")
    if d.empty: continue
    lw = 1.8 if focal else 1.1
    ax.plot(d.n, d["median"], ls, color=col, lw=lw, marker=mk, ms=4 if focal else 3.2, mfc=col if focal else "white", mec=col, zorder=3 if focal else 2)
    multi = d[d["count"] > 1]
    ax.vlines(multi.n, multi["min"], multi["max"], color=col, lw=0.8, alpha=0.7, zorder=1)
    ends.append((d.n.iloc[-1], d["median"].iloc[-1], lab, col))
ax.set_xscale("log"); ax.set_yscale("log")
ax.set_xticks([250, 500, 1000, 2000, 4000]); ax.set_xticklabels(["250", "500", "1000", "2000", "4000"])
ax.xaxis.set_minor_locator(mpl.ticker.NullLocator())
ax.set_yticks([10, 100, 1000, 10000, 100000]); ax.set_yticklabels(["10 ms", "100 ms", "1 s", "10 s", "100 s"]); ax.set_ylim(6, 3e5)
ax.yaxis.set_minor_locator(mpl.ticker.NullLocator())
ax.set_xlabel("Sample size $n$"); ax.set_ylabel("Time per complete Gibbs sweep")
ax.margins(x=0.06, y=0.08)
# legend in the empty upper-left region
from matplotlib.lines import Line2D
handles = [Line2D([], [], color=c, ls=ls, marker=mk, ms=3.5, lw=1.4, mfc=c if f else "white", mec=c, label=l) for _, l, c, ls, mk, f in series if _ in set(g.method)]
ax.legend(handles=handles, loc="upper left", frameon=False, fontsize=6, handlelength=2.4)
fig.tight_layout()
fig.savefig(out_stem + ".pdf"); fig.savefig(out_stem + ".png", dpi=300)
# bbox check
r = fig.canvas.get_renderer()
texts = [(x, x.get_window_extent(r)) for x in fig.findobj(mpl.text.Text) if x.get_text().strip() and x.get_visible()]
ov = [(a.get_text(), b.get_text()) for i, (a, ba) in enumerate(texts) for b, bb in texts[i+1:] if ba.overlaps(bb)]
print("text overlaps:", ov)
