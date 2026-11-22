# Static equivalence checks, run by validate.sh from a validation snapshot's code directory.
# 1. simulate_extreme() reproduces simulate_data() of both PMALA sources exactly (n = 500, every
#    baseline/noise, seeds 1-3): same response and same truth at every level.
# 2. The PMALA Main-section call is found and the overrides bind names that it reads.
# 3. Reports the saved PMALA settings that the campaign will use, and the solver versions.
options(warn = 1)
source("Extreme_Individual/config.R"); source("Extreme_Individual/common_extreme.R")
load_defs <- function(dir, file) {
  old <- setwd(dir); on.exit(setwd(old))
  lines <- readLines(file, warn = FALSE); main <- grep("^# ---- Main", lines); stopifnot(length(main) == 1L)
  env <- new.env(parent = globalenv()); eval(parse(text = lines[seq_len(main - 1L)]), envir = env)
  list(env = env, main = parse(text = lines[main:length(lines)]))
}
ind <- load_defs("Extreme_Individual/source", "Individual_Sampler_PMALA_Augmented.R")
joint_dir <- file.path(Sys.getenv("EXTREME_BASE_DIR", "/home/fb31/projects/Quant_Reg"), "Extreme_Joint_Sampler", "source", "Joint")
for (b in c("VS", "S")) for (nz in c("Normal", "Beta", "Mixed")) for (s in 1:3) {
  mine <- simulate_extreme(s, 500L, b, nz, c(0.90, 0.93, cfg$taus))
  for (t in cfg$taus) {
    ref <- ind$env$simulate_data(s, 500L, t, b, nz)
    stopifnot(identical(mine$y, ref$y), identical(unname(mine$truth[, tau_label(t)]), ref$truth))
  }
}
cat("CHECK_OK simulate_extreme == Individual simulate_data (y and truth), 2 x 3 x 3 x 4 cases\n")
if (dir.exists(joint_dir)) {
  jnt <- load_defs(joint_dir, "Joint_Sampler_PMALA_Augmented.R")
  for (b in c("VS", "S")) for (nz in c("Normal", "Beta", "Mixed")) for (s in 1:3) {
    taus6 <- c(0.90, 0.93, 0.96, 0.97, 0.98, 0.99)
    mine <- simulate_extreme(s, 500L, b, nz, taus6); ref <- jnt$env$simulate_data(s, 500L, taus6, b, nz)
    stopifnot(identical(mine$y, ref$y), identical(unname(mine$truth), unname(ref$truth)))
  }
  cat("CHECK_OK simulate_extreme == Joint simulate_data (y and six-level truth)\n")
} else cat("NOTE joint package not found at", joint_dir, "- joint generator check skipped here\n")
is_fit <- vapply(ind$main, function(e) is.call(e) && identical(e[[1]], as.name("<-")) && identical(e[[2]], as.name("fit")), logical(1))
stopifnot(sum(is_fit) == 1L)
call <- ind$main[[which(is_fit)]][[3]]
stopifnot(identical(call[[1]], as.name("gibbs_pmala_aug")),
          all(c("tau", "order", "b0", "gibbs_iter", "gibbs_burn") %in% all.vars(call)))
cat("CHECK_OK PMALA Main call found; overridden names are read by it:\n"); print(call)
saved <- mget(setdiff(all.vars(call), c("dat", "y")), envir = ind$env)
cat("SAVED PMALA SETTINGS (before campaign overrides of order, b0, gibbs_iter, gibbs_burn; tau per task):\n")
str(saved[setdiff(names(saved), "tf_control")])
cat("VERSIONS piqp", as.character(packageVersion("piqp")), "| glmgen", as.character(packageVersion("glmgen")),
    "| Rcpp", as.character(packageVersion("Rcpp")), "| GIGrvg", as.character(packageVersion("GIGrvg")),
    "| invgamma", as.character(packageVersion("invgamma")), "| MCMCpack", as.character(packageVersion("MCMCpack")), "\n")
cat("VALIDATE_CHECKS_SUCCESS\n")
