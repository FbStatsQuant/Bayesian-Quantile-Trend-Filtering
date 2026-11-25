# E-13a phase 2: the joint script's tests.  The prox tests (P1-P6) need the clarabel package for one reference; they are run and
# reported first but do not block the sampler tests T1-T4 (+T3b), which are the ones HQ requires.
# Usage: Rscript e13b_joint_tests.R   (env E13_ROOT = code tree holding method/)
ROOT <- normalizePath(Sys.getenv("E13_ROOT", "."))
setwd(file.path(ROOT, "method", "joint")); L <- readLines("Joint_Sampler_PMALA_Augmented.R")
eval(parse(text = L[seq_len(grep("^# ---- Main", L)[1] - 1L)]), envir = globalenv()); load_box_cpp()
p <- tryCatch({ run_prox_tests(); "PASS" }, error = function(e) paste("ERROR:", conditionMessage(e)))
cat("\nprox tests (P):", p, "\n\n")
run_tests()
cat("\nsampler tests T1-T4 (+T3b): PASS\n")
