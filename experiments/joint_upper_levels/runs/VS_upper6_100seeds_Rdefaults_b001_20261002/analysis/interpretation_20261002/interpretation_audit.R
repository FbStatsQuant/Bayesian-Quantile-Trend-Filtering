options(warn=1)
args <- commandArgs(TRUE)
root <- normalizePath(args[1]); out <- normalizePath(args[2])
capture.output(sessionInfo(), file=file.path(out,"sessionInfo.txt"))
start <- Sys.time()
metrics <- read.csv(file.path(root,"summary","per_seed_all_six_quantiles.csv"))
comp <- read.csv(file.path(root,"summary","comparison_paper_table2.csv"))
growth <- do.call(rbind,lapply(c("Normal","Beta","Mixed"),function(noise) {
  d <- comp[comp$noise==noise,]; lo <- d[d$tau==.96,]; hi <- d[d$tau==.99,]
  data.frame(noise=noise,joint_MSE_growth_pct=100*(hi$mean_MSE/lo$mean_MSE-1),
    individual_MSE_growth_pct=100*(hi$paper_PMALA/lo$paper_PMALA-1),
    joint_advantage_vs_best_at099_pct=100*(1-hi$mean_MSE/hi$paper_best_MSE),
    joint_SE_at099=hi$se_MSE, gap_to_best_at099=hi$paper_best_MSE-hi$mean_MSE)
}))
write.csv(growth,file.path(out,"growth.csv"),row.names=FALSE)
bv <- list(); diagnostics <- list(); raw_screen <- list()
for (noise in c("Normal","Beta","Mixed")) {
  sums <- lapply(1:100,function(seed) readRDS(file.path(root,"tasks",noise,sprintf("seed_%03d",seed),"summary.rds")))
  for (j in 3:6) {
    e <- sapply(sums,function(x) x$est[,j]-x$dat$truth[,j])
    bias <- rowMeans(e)
    variance <- rowMeans((e-bias)^2)
    tau <- sums[[1]]$config$taus[j]
    d <- metrics[metrics$noise==noise & metrics$tau==tau,]
    bv[[length(bv)+1]] <- data.frame(noise=noise,tau=tau,MSE=mean(e^2),
      squared_bias=mean(bias^2),replicate_variance=mean(variance),
      mean_signed_error=mean(e),fraction_negative_errors=mean(e<0),
      mse_median=median(d$MSE),mse_q95=unname(quantile(d$MSE,.95)),
      mse_max=max(d$MSE))
    stopifnot(abs(mean(e^2)-mean(bias^2)-mean(variance))<1e-12)
    diagnostics[[length(diagnostics)+1]] <- data.frame(noise=noise,tau=tau,
      accept_min=min(d$acc_post),accept_mean=mean(d$acc_post),accept_max=max(d$acc_post),
      outside_mean=mean(d$outside_rate),asis_moved_mean=mean(d$asis_moved),
      delta_min=min(d$delta_final),delta_median=median(d$delta_final),
      coverage_mean=mean(d$coverage))
  }
  # Fixed screening sample: seed 1 of each noise, no reruns or tuning.
  x <- readRDS(sums[[1]]$raw_path)
  S <- dim(x$fit$theta)[1]
  ids <- c(1L,125L,250L,375L,500L)
  for (j in 3:6) {
    th <- x$fit$theta[,,j]
    first <- colMeans(th[seq_len(S%/%2),,drop=FALSE])
    last <- colMeans(th[(S%/%2+1):S,,drop=FALSE])
    z <- cbind(th[,ids],spatial_mean=rowMeans(th))
    ess <- coda::effectiveSize(z)
    raw_screen[[length(raw_screen)+1]] <- data.frame(noise=noise,seed=1L,tau=x$config$taus[j],
      kept=S,ESS_min=min(ess),ESS_median=median(ess),
      first_half_MSE=mean((first-x$dat$truth[,j])^2),
      second_half_MSE=mean((last-x$dat$truth[,j])^2),
      half_estimate_RMS_difference=sqrt(mean((first-last)^2)))
  }
  rm(x,sums); gc()
}
bv <- do.call(rbind,bv); diagnostics <- do.call(rbind,diagnostics); raw_screen <- do.call(rbind,raw_screen)
write.csv(bv,file.path(out,"bias_variance.csv"),row.names=FALSE)
write.csv(diagnostics,file.path(out,"diagnostics.csv"),row.names=FALSE)
write.csv(raw_screen,file.path(out,"seed1_chain_screen.csv"),row.names=FALSE)
saveRDS(list(growth=growth,bias_variance=bv,diagnostics=diagnostics,chain_screen=raw_screen,
  start=start,end=Sys.time(),screen_seeds=1L,screen_indices=c(1L,125L,250L,375L,500L)),file.path(out,"audit.rds"))
print(growth); print(bv); print(diagnostics); print(raw_screen)
cat("AUDIT_SUCCESS\n")
