import os, re, random
import pandas as pd, numpy as np

D = os.path.dirname(os.path.abspath(__file__)) + "/.."
I = os.path.join(D, "inputs")
TAUS = [0.96, 0.97, 0.98, 0.99]
TOL = 1e-10
KEY = ["baseline", "noise", "tau"]
results = {}


def rd(p):
    return pd.read_csv(os.path.join(I, p))


def clean(df):
    df = df.copy()
    df["tau"] = df["tau"].round(2)
    return df[df["tau"].isin(TAUS)].reset_index(drop=True)


# summaries
s4 = clean(rd("joint4_summary.csv")); s4["method"] = "joint4"
s6 = clean(rd("joint6_oct7_summary.csv")); s6["method"] = "joint6"
si = clean(rd("individual_oct7_summary.csv"))
print("summary rows (tau filtered): joint4", len(s4), "joint6", len(s6), "indiv", len(si), sorted(si["method"].unique()))
vcols = ["n_seeds", "mean_MSE", "se_MSE", "mean_crossings_neighbor", "se_crossings_neighbor", "mean_crossings_all", "se_crossings_all"]
summ = pd.concat([s4, s6, si], ignore_index=True)[["method"] + KEY + vcols]

# per-task
p4 = clean(rd("joint4_per_task_metrics.csv"))
p6 = clean(rd("joint6_oct7_per_task_metrics.csv"))
print("per-task rows (tau filtered): joint4", len(p4), "joint6", len(p6))
print("per-task methods: joint4 file", list(p4["method"].unique()), "joint6 file", list(p6["method"].unique()))

fut = pd.read_csv(os.path.join(D, "comparison_4lev_6lev_individual.csv"))
fut["tau"] = fut["tau"].round(2)


def agg(p):
    g = p.groupby(KEY)["MSE"]
    out = g.agg(n="count", mean="mean", sd=lambda x: x.std(ddof=1)).reset_index()
    out["se"] = out["sd"] / np.sqrt(out["n"])
    sk = p.groupby(KEY)["seed"].apply(lambda x: sorted(x.tolist()) == list(range(1, 101))).reset_index(name="seeds_ok")
    return out.merge(sk, on=KEY)


# ---------- Check 1
a4, a6 = agg(p4), agg(p6)
ok1 = True
for nm, a in (("joint4", a4), ("joint6", a6)):
    print(f"[C1] {nm}: cells={len(a)}, n per cell min/max={a.n.min()}/{a.n.max()}, all cells seeds exactly 1..100: {bool(a.seeds_ok.all())}")
    ok1 &= bool(a.seeds_ok.all()) and len(a) == 24 and a.n.min() == 100 == a.n.max()
mx1 = 0.0
for nm, a, s in (("joint4", a4, s4), ("joint6", a6, s6)):
    m = a.merge(s, on=KEY, validate="1:1")
    f = fut[fut.method == nm].merge(a, on=KEY, validate="1:1")
    d1 = (m["mean"] - m["mean_MSE"]).abs().max(); d2 = (m["se"] - m["se_MSE"]).abs().max()
    d3 = (f["mean"] - f["mean_MSE"]).abs().max(); d4 = (f["se"] - f["se_MSE"]).abs().max()
    nsum = bool((m["n"] == m["n_seeds"]).all()); nf = bool((f["n"] == f["n_seeds"]).all())
    print(f"[C1] {nm} per-task vs summary file: cells={len(m)} max|d mean|={d1:.3e} max|d se|={d2:.3e} n_seeds match={nsum}")
    print(f"[C1] {nm} per-task vs file under test: cells={len(f)} max|d mean|={d3:.3e} max|d se|={d4:.3e} n_seeds match={nf}")
    mx1 = max(mx1, d1, d2, d3, d4)
    ok1 &= nsum and nf
c1 = ok1 and mx1 < TOL
print("CHECK 1:", "PASS" if c1 else "FAIL", f"max abs discrepancy {mx1:.3e}"); results[1] = c1

# ---------- Check 2
mg = p4[KEY + ["seed", "MSE"]].merge(p6[KEY + ["seed", "MSE"]], on=KEY + ["seed"], suffixes=("4", "6"), validate="1:1")
mg["d"] = mg.MSE4 - mg.MSE6
mg["better"] = (mg.MSE4 < mg.MSE6).astype(float)
print(f"[C2] matched pairs total {len(mg)} (expect 2400); unmatched joint4 rows {len(p4)-len(mg)}, joint6 rows {len(p6)-len(mg)}")
pdf = mg.groupby(KEY).agg(n=("d", "count"), md=("d", "mean"), sd=("d", lambda x: x.std(ddof=1)), sh=("better", "mean")).reset_index()
pdf["sed"] = pdf.sd / np.sqrt(pdf.n)
f = fut[fut.method == "joint4"].merge(pdf, on=KEY, validate="1:1")
dm = (f.md - f.mean_diff_4minus6).abs().max(); ds = (f.sed - f.se_diff_4minus6).abs().max()
dsh = (f.sh - f.share_seeds_4_better).abs().max(); dn = (f.n - f.n_pairs).abs().max()
print(f"[C2] joint4 rows compared={len(f)}  max|d mean_diff|={dm:.3e} max|d se_diff|={ds:.3e} max|d share|={dsh:.3e} max|d n_pairs|={dn}")
oth = fut[fut.method != "joint4"]
na_other = bool(oth[["n_pairs", "mean_diff_4minus6", "se_diff_4minus6", "share_seeds_4_better"]].isna().all().all())
print(f"[C2] paired columns are NA on all {len(oth)} non-joint4 rows: {na_other}")
c2 = len(f) == 24 and len(mg) == 2400 and max(dm, ds, dsh) < TOL and dn == 0
print("CHECK 2:", "PASS" if c2 else "FAIL", f"max abs discrepancy {max(dm, ds, dsh):.3e}"); results[2] = c2

# ---------- Check 3
bad = 0; ncell = 0; ties = 0
for k, g in summ.groupby(KEY):
    ncell += 1
    mn = g.mean_MSE.min()
    winners = g[g.mean_MSE == mn].method.tolist()
    ties += len(winners) > 1
    fg = fut[(fut.baseline == k[0]) & (fut.noise == k[1]) & (fut.tau == k[2])]
    marked = fg[fg.best.astype(str).str.upper() == "TRUE"].method.tolist()
    if len(g) != 6 or sorted(marked) != sorted(winners):
        bad += 1; print("  MISMATCH", k, winners, marked)
print(f"[C3] cells={ncell} methods per cell=6 ties={ties} mismatches={bad}; total TRUE flags in file={int((fut.best.astype(str).str.upper()=='TRUE').sum())}")
c3 = bad == 0 and ncell == 24
print("CHECK 3:", "PASS" if c3 else "FAIL", "mismatching cells", bad); results[3] = c3

# ---------- Check 4
m = fut.merge(summ, on=["method"] + KEY, suffixes=("_f", "_s"), validate="1:1")
mx = 0.0
for c in vcols:
    d = (m[c + "_f"] - m[c + "_s"]).abs().max(); mx = max(mx, d)
    print(f"[C4] {c}: max abs diff {d:.3e}")
print(f"[C4] rows in file={len(fut)} matched to summaries={len(m)}; methods={sorted(fut.method.unique())}; NA in value columns={int(fut[vcols].isna().sum().sum())}")
c4 = len(fut) == 144 and len(m) == 144 and mx < TOL
print("CHECK 4:", "PASS" if c4 else "FAIL", f"max abs discrepancy {mx:.3e}"); results[4] = c4

# ---------- Check 5
md = open(os.path.join(D, "comparison_4lev_6lev_individual.md"), encoding="utf-8").read().splitlines()
labels = fut.drop_duplicates("method").set_index("method")["method_label"].to_dict()
lab2m = {v: k for k, v in labels.items()}
mse_cells = {}
base = noise = None; in_mse = False
for ln in md:
    if ln.startswith("## "):
        mm = re.match(r"## Baseline (\w+): MSE", ln)
        in_mse = bool(mm); base = mm.group(1) if mm else None
    elif ln.startswith("### "):
        noise = ln[4:].strip()
    elif in_mse and ln.startswith("| ") and not ln.startswith("| Method"):
        parts = [x.strip() for x in ln.strip().strip("|").split("|")]
        mse_cells[(base, noise, lab2m[parts[0]])] = parts[1:]
print(f"[C5] parsed MSE md rows: {len(mse_cells)} (expect 36)")


def fmt(r):
    return f"{r.mean_MSE:.5f} ({r.se_MSE:.5f})"


random.seed(20261023)
allk = list(mse_cells.keys())
picks = [(random.choice(allk), random.choice(TAUS)) for _ in range(6)]
ok5 = True
for (b, n, me), t in picks:
    r = fut[(fut.baseline == b) & (fut.noise == n) & (fut.method == me) & (fut.tau == t)].iloc[0]
    cell = mse_cells[(b, n, me)][TAUS.index(t)]
    isb = cell.startswith("**") and cell.endswith("**")
    txt = cell.strip("*")
    exp = fmt(r)
    col_bold = [mm for (bb, nn, mm), v in mse_cells.items() if bb == b and nn == n and v[TAUS.index(t)].startswith("**")]
    okc = (txt == exp) and (isb == (str(r.best).upper() == "TRUE")) and (col_bold == [me] if isb else (me not in col_bold and len(col_bold) == 1))
    ok5 &= okc
    print(f"[C5] {b}/{n}/tau={t}/{me}: md='{cell}' csv='{exp}' bold_md={isb} best_csv={r.best} bold_in_column={col_bold} -> {'OK' if okc else 'BAD'}")

pm = {}
for ln in md:
    if re.match(r"\| (VS|S) \| (Normal|Beta|Mixed) \|", ln) and "share" in ln:
        parts = [x.strip() for x in ln.strip().strip("|").split("|")]
        pm[(parts[0], parts[1])] = parts[2:]
print(f"[C5] parsed paired-diff md rows: {len(pm)} (expect 6)")


def pexp(r):
    return f"{r.mean_diff_4minus6:.5f} ({r.se_diff_4minus6:.5f}), share {r.share_seeds_4_better:.2f}"


random.seed(7)
pk = [(random.choice(list(pm)), random.choice(TAUS)) for _ in range(3)]
for (b, n), t in pk:
    r = fut[(fut.baseline == b) & (fut.noise == n) & (fut.method == "joint4") & (fut.tau == t)].iloc[0]
    cell = pm[(b, n)][TAUS.index(t)]
    okc = cell == pexp(r); ok5 &= okc
    print(f"[C5] paired {b}/{n}/tau={t}: md='{cell}' csv='{pexp(r)}' -> {'OK' if okc else 'BAD'}")

# extra: exhaustive sweep
fb = 0; fn = 0
for (b, n, me), v in mse_cells.items():
    for t, cell in zip(TAUS, v):
        r = fut[(fut.baseline == b) & (fut.noise == n) & (fut.method == me) & (fut.tau == t)].iloc[0]
        fn += 1
        if cell.strip("*") != fmt(r) or cell.startswith("**") != (str(r.best).upper() == "TRUE"):
            fb += 1; print("  full-sweep mismatch", b, n, me, t, cell, fmt(r))
print(f"[C5-extra] exhaustive sweep of MSE md cells: {fn} cells, mismatches={fb}")
pb = 0; pn = 0
for (b, n), v in pm.items():
    for t, cell in zip(TAUS, v):
        r = fut[(fut.baseline == b) & (fut.noise == n) & (fut.method == "joint4") & (fut.tau == t)].iloc[0]
        pn += 1
        if cell != pexp(r):
            pb += 1; print("  paired mismatch", b, n, t, cell, pexp(r))
print(f"[C5-extra] exhaustive sweep of paired md cells: {pn} cells, mismatches={pb}")
c5 = ok5 and fb == 0 and pb == 0 and len(mse_cells) == 36 and len(pm) == 6
print("CHECK 5:", "PASS" if c5 else "FAIL"); results[5] = c5
print("SUMMARY:", {k: ("PASS" if v else "FAIL") for k, v in results.items()})
