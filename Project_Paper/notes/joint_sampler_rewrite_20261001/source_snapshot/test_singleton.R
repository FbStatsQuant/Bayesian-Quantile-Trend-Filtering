script <- normalizePath(sub("^--file=","",grep("^--file=",commandArgs(FALSE),value=TRUE)[1]))
root <- dirname(script)
source(file.path(root,"Unified_Sampler.R"))
load_unified_cpp()
dat <- simulate_data(1,50L,.10,"VS","Normal")
settings <- list(y=dat$y,tau=c(.10),order=2L,gibbs_iter=120L,gibbs_burn=60L,
  delta_init=.2,lambda_init=NULL,adapt_target=.5,adapt_gain=1,adapt_kappa=.6,
  delta_bounds=c(1e-8,100),metric="curv",c_fixed=1e4,iters=200L,
  adapt=TRUE,init="y",warm=10L,gamma_warm=1e4,kappa=3,K=1L,asis=TRUE,tol=0,verbose=FALSE)
refsettings <- c(settings,list(a0=1,b0=.001,a_sigma=.1,b_sigma=.1,
  control=.guarded$tf_control,mh=TRUE,prior_scale="none",cmap=FALSE,adapt_all=FALSE,lamjump=FALSE))
# This is an unchanged byte-for-byte snapshot of the verified D file.
reference <- file.path(dirname(root),"D_guarded_frozen200","Individual_Sampler_PMALA_TEMP_Guarded_Frozen200.R")
stopifnot(unname(tools::md5sum(reference))==unname(tools::md5sum(file.path(root,"guarded_reference.R"))))
set.seed(1001); ref <- do.call(.guarded$gibbs_pmala_aug,refsettings); ref_rng <- .Random.seed
set.seed(1001); fit <- do.call(gibbs_unified,settings); unified_rng <- .Random.seed
stopifnot(identical(ref$theta,fit$theta[,,1]))
for(nm in c("lambda","sigma","delta","acc","SD")) stopifnot(identical(ref[[nm]],fit[[nm]][,1]))
stopifnot(identical(ref_rng,unified_rng))
est <- colMeans(ref$theta); est_u <- colMeans(fit$theta[,,1])
summary <- data.frame(method=c("D_guarded","E_unified"),tau=.10,n=50,total=120,burn=60,warm=10,
  mse=c(mean((est-dat$truth)^2),mean((est_u-dat$truth)^2)),
  check_loss=c(mean(rho_tau(dat$y-est,.10)),mean(rho_tau(dat$y-est_u,.10))),
  acceptance=c(ref$acc_post,fit$acc_post),delta_final=c(ref$delta_final,fit$delta_final))
stopifnot(identical(summary$mse[1],summary$mse[2]),identical(summary$check_loss[1],summary$check_loss[2]))
stopifnot(length(unique(fit$delta[60:120,1]))==1L,length(unique(fit$delta[11:60,1]))>1L)
write.csv(summary,file.path(root,"singleton_parity.csv"),row.names=FALSE)
saveRDS(list(settings=settings,reference=ref,unified=fit,ref_rng=ref_rng,unified_rng=unified_rng,summary=summary),file.path(root,"singleton_parity.rds"))
print(summary)
cat("PASS exact tau=.10 theta/lambda/sigma/delta/acceptance/roughness/RNG/MSE/loss parity; burn boundary frozen\n")
