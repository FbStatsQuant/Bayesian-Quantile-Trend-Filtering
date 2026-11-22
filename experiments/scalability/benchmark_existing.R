# Timing audit of existing implementations, not a sampling-validity benchmark.
# Run from the Quantile Regression workspace root. No source files are changed.
suppressPackageStartupMessages(library(glmgen))
suppressPackageStartupMessages(library(MASS))
pm <- new.env(parent=globalenv())
sys.source('Simulations/NOTS_n500/R/individual_core.R', envir=pm)
on <- new.env(parent=globalenv())
suppressPackageStartupMessages(sys.source('Simulations/Onizuka/NOTS_n500/src/BQTF-function.R', envir=on))
outdir <- 'PMALA version Tex Project/notes/complexity_analysis'
n <- 500L; tau <- .5; warm <- 5L; measured <- 30L; repeats <- 3L
set.seed(1)
x <- seq_len(n); y <- sin(2*pi*x/n) + rnorm(n, sd=(1+(x/n)^2)/4)
D <- pm$D_matrix(n, 2L)
# Extract the original outer Gibbs loop and place timing marks around it.
# Setup and first warm iterations are excluded; original updates and storage stay intact.
instrument <- function(fn) {
  b <- as.list(body(fn))
  idx <- which(vapply(b,function(z) is.call(z) && identical(z[[1]],as.name('for')) && identical(z[[2]],as.name('k')),logical(1)))
  stopifnot(length(idx)==1L)
  loop <- b[[idx]]
  original <- loop[[4]]
  loop[[4]] <- substitute({
    if(k == WARM + 1L) .timing_start <- proc.time()[['elapsed']]
    ORIGINAL
    if(k == mc) timing_result <<- (proc.time()[['elapsed']] - .timing_start)/(mc-WARM)
  },list(WARM=warm,ORIGINAL=original))
  b[[idx]] <- loop
  body(fn) <- as.call(b)
  fn
}
on$timing_result <- NA_real_
lap <- instrument(on$BQTF.MCMC.Lap.multi)
hs <- instrument(on$BQTF.MCMC.HS.multi)
pm$prox_g <- function(z,D,gamma,lambda,order=2) {
  .prox_start <- proc.time()[['elapsed']]
  fit <- glmgen::trendfilter(x=seq_along(z),y=z,k=order,lambda=gamma*lambda,
                            control=glmgen::trendfilter.control.list(max_iter=800L))
  pm$prox_elapsed <- pm$prox_elapsed + (proc.time()[['elapsed']] - .prox_start)
  pm$prox_iters <- c(pm$prox_iters,pmin(fit$iter+1L,800L))
  pm$prox_status <- c(pm$prox_status,fit$status)
  as.numeric(fit$beta)
}
results <- list(); prox_details <- list()
# Warm package/JIT paths before measured repetitions.
invisible(pm$pmala_single_sample(y,tau,20,1,.1,D,.02,.01,y,2))
for (rr in seq_len(repeats)) {
  set.seed(1000+rr)
  theta <- y; lambda <- 20; sigma <- 1; acc <- 0L
  pm$prox_iters <- integer(); pm$prox_status <- integer(); pm$prox_elapsed <- 0
  for(ii in seq_len(warm+measured)) {
    if(ii==warm+1L) {
      pm$prox_iters <- integer(); pm$prox_status <- integer(); pm$prox_elapsed <- 0
      t0 <- proc.time()[['elapsed']]
    }
    step <- pm$pmala_single_sample(y,tau,lambda,sigma,.1,D,.02,.01,theta,2)
    theta <- step$theta
    lambda <- rgamma(1,shape=n+nrow(D),rate=1+sum(abs(D %*% theta)))
    sigma <- pm$rinvgamma(1,shape=n+.1,rate=.1+sum(pm$true_check_loss(y-theta,tau)))
    if(ii>warm) acc <- acc+step$accepted
  }
  elapsed <- proc.time()[['elapsed']]-t0
  results[[length(results)+1L]] <- data.frame(method='Draft PMALA (proposal mismatch)',rep=rr,ms_per_iteration=1000*elapsed/measured)
  prox_details[[rr]] <- data.frame(rep=rr,prox_ms_per_gibbs=1000*pm$prox_elapsed/measured,total_ms_per_gibbs=1000*elapsed/measured,calls=length(pm$prox_iters),mean_inner=mean(pm$prox_iters),median_inner=median(pm$prox_iters),max_inner=max(pm$prox_iters),nonzero_status=sum(pm$prox_status!=0),cap_calls=sum(pm$prox_iters>=800L),acceptance=acc/measured)
  cat('PMALA repetition',rr,'finished:',1000*elapsed/measured,'ms/iteration\n'); flush.console()
  for(nm in c('Lap','HS')) {
    set.seed(2000+rr)
    fun <- if(nm=='Lap') lap else hs
    draws <- fun(X=x,Y=y,TForder=2,pp=tau,mc=warm+measured,sparse=FALSE,sig.init=c(1,1))
    stopifnot(all(is.finite(draws)), length(on$timing_result)==1L, is.finite(on$timing_result))
    cat(nm,'repetition',rr,'finished:',1000*on$timing_result,'ms/iteration\n'); flush.console()
    results[[length(results)+1L]] <- data.frame(method=paste('Onizuka',nm,'dense'),rep=rr,ms_per_iteration=1000*on$timing_result)
  }
  write.csv(do.call(rbind,results),file.path(outdir,'timings.csv'),row.names=FALSE)
  write.csv(do.call(rbind,prox_details),file.path(outdir,'prox_iterations.csv'),row.names=FALSE)
  cat('Finished timing repetition',rr,'\n'); flush.console()
}
res <- do.call(rbind,results)
pr <- do.call(rbind,prox_details)
write.csv(res,file.path(outdir,'timings.csv'),row.names=FALSE)
write.csv(pr,file.path(outdir,'prox_iterations.csv'),row.names=FALSE)
writeLines(c('n=500; data seed=1; S signal; Gaussian heteroscedastic noise; tau=.5; k=2',
             '3 repetitions; 5 warm iterations then 30 measured; setup excluded.',
             'PMALA: gamma=.1 delta=.02 eps=.01 a0=500 b0=1 a_sigma=b_sigma=.1 lambda_init=20.',
             'Original proposal/acceptance mismatch retained for faithful runtime audit.',
             'Prox diagnostic recording adds small allocation overhead to PMALA timings.',
             'Onizuka: supplied dense implementation, sig.init=c(1,1), both priors.',
             capture.output(sessionInfo())),file.path(outdir,'timing_environment.txt'))
print(res)
print(pr)
print(aggregate(ms_per_iteration~method,res,median))



