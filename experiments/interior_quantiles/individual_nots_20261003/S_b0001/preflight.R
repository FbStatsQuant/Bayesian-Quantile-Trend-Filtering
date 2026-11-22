# Configuration/source audit only; does not generate data or run chains.
source("config.R"); source("common.R")
validate_config(cfg, production=TRUE)
for (p in c("glmgen", "Rcpp", "coda")) stopifnot(requireNamespace(p, quietly=TRUE))
load_sampler(normalizePath("."), compile=FALSE)
check_sampler_defaults(cfg)
saveRDS(cfg, "../metadata/config.rds"); dput(cfg, file="../metadata/config.txt")
write.csv(task_grid(cfg), "../metadata/task_manifest.csv", row.names=FALSE)
writeLines(as.character(pilot_ids(cfg)), "../metadata/pilot_task_ids.txt")
capture.output(sessionInfo(), file="../metadata/sessionInfo.txt")
cat(sprintf("PREFLIGHT_OK: %d fits (S); %d sweeps, %d burn-in; lambda Gamma(%g, rate %g); ASIS %s; order %d\n",
  nrow(task_grid(cfg)), cfg$sampler$gibbs_iter, cfg$sampler$gibbs_burn, cfg$sampler$a0, cfg$sampler$b0,
  cfg$sampler$asis, cfg$sampler$order))
