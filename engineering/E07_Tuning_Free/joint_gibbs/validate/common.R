ROOT <- local({ f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE)); d <- if (length(f)) dirname(normalizePath(f[1])) else getwd(); r <- tryCatch(system2("git", c("-C", shQuote(d), "rev-parse", "--show-toplevel"), stdout = TRUE, stderr = FALSE), error = function(e) character(0)); if (!length(r) || !nzchar(r[1])) stop("E07: cannot find the repo root; run from inside the checkout"); r[1] })   # E-12: repo root (Owls or NOTS), no absolute paths
.libPaths(c(file.path(ROOT, "ops/Rlib"), .libPaths()))
src <- readLines(file.path(ROOT, "method/individual/Individual_Sampler_PMALA_Augmented.R"))
i0 <- grep("^simulate_data <- function", src); i1 <- grep("^# ---- Model pieces", src) - 1
eval(parse(text = src[i0:i1]))
SCR <- file.path(ROOT, "runs/E07-outputs"); dir.create(SCR, recursive = TRUE, showWarnings = FALSE)   # E-12: outputs go to runs/ (git-ignored), never the archive
Sys.setenv(E07_CACHE = file.path(ROOT, "tmp/rcpp_cache"))
source(file.path(ROOT, "engineering/E07_Tuning_Free/joint_gibbs/e07_joint.R"))
e07_load(cache = file.path(ROOT, "tmp/rcpp_cache"))
