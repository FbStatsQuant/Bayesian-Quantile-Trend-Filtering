import os
os.chdir("/home/fb31/projects/Quant_Reg/Air_sim_Lap/Driver")

def sub(path, old, new):
    s = open(path).read()
    assert old in s, (path, old)
    open(path, "w").write(s.replace(old, new, 1))

# process_results.R
sub("process_results.R", "# Verifies every task of the run (3 methods x 3 levels x seeds), recomputes the metrics from the stored curves, then\n# writes per-task metrics, (method, tau) averages with standard errors, and paired MSE comparisons against\n# Bayesian-PMALA under RUN_DIR/summary/attempt_*/. Refuses to average an incomplete or invalid run.",
    "# Verifies every task of the run (onizuka_lap x 3 levels x seeds), recomputes the metrics from the stored curves, then\n# writes per-task metrics and (method, tau) averages with standard errors (summary.csv, same columns as the production run)\n# under RUN_DIR/summary/attempt_*/. Refuses to average an incomplete or invalid run.")
sub("process_results.R", 'source(file.path(code_root, "Driver", "common_air.R"))\n',
    'source(file.path(code_root, "Driver", "common_air.R"))\nsource(file.path(code_root, "Driver", "process_lap.R"))\n')
sub("process_results.R", "process_campaign(run_root", "process_campaign_lap(run_root")

# run_task.sh
sub("run_task.sh", "  pmala) worker=Driver/worker_pmala.R ;;\n  admm) worker=ADMM/worker_admm.R ;;\n  onizuka_hs) worker=Onizuka/worker_onizuka.R ;;\n",
    "  onizuka_lap) worker=Onizuka/worker_onizuka_lap.R ;;\n")

# submit.sh
sub("submit.sh", "(at most cfg$concurrency = 400 running; 900 production tasks)", "(at most cfg$concurrency = 400 running; 300 production tasks)")

# make_tables.R
sub("make_tables.R", '  p <- read.csv(file.path(summary_dir, "paired_mse_vs_pmala.csv"), stringsAsFactors = FALSE)\n',
    '  paired_file <- file.path(summary_dir, "paired_mse_vs_pmala.csv")   # absent in the Laplace add-on run (single method)\n  p <- if (file.exists(paired_file)) read.csv(paired_file, stringsAsFactors = FALSE) else NULL\n')
sub("make_tables.R", 'label <- c(pmala = "Bayesian-PMALA", admm = "ADMM", onizuka_hs = "Onizuka (HS)")\n  order_m <- c("pmala", "onizuka_hs", "admm")',
    'label <- c(pmala = "Bayesian-PMALA", admm = "ADMM", onizuka_hs = "Onizuka (HS)", onizuka_lap = "Onizuka (Lap)")\n  order_m <- c("pmala", "onizuka_hs", "onizuka_lap", "admm")')
sub("make_tables.R", "  # Paired comparisons\n  p$competitor", "  # Paired comparisons (only when the run has a paired table)\n  if (!is.null(p)) {\n  p$competitor")
sub("make_tables.R", '    "tab:air_paired"), file.path(out_dir, "air_paired.tex"))\n', '    "tab:air_paired"), file.path(out_dir, "air_paired.tex"))\n  }\n')

# validate.sh
sub("validate.sh", "# Separate snapshot under validation/, tiny settings (n = 500 as in production, seeds 1-2, 60 PMALA sweeps with 20\n# burn-in and 5 warm sweeps, 60 Onizuka draws with 20 burn-in; ADMM unchanged), all 18 tasks run sequentially, then:",
    "# Separate snapshot under validation/, tiny settings (n = 500 as in production, seeds 1-2, 60 Laplace-sampler draws with\n# 20 burn-in), all 6 tasks run sequentially, then:")
sub("validate.sh", "cfg$pmala$gibbs_iter <- 60L\ncfg$pmala$gibbs_burn <- 20L\ncfg$pmala$validation_overrides <- list(warm_sweeps = 5L)\n", "")
sub("validate.sh", 'find "$run/tasks/onizuka_hs"', 'find "$run/tasks/onizuka_lap"')
print("EDITS_OK")
