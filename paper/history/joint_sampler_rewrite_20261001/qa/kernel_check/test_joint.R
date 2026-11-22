script <- normalizePath(sub('^--file=','',grep('^--file=',commandArgs(FALSE),value=TRUE)[1])); root <- dirname(script)
source(file.path(root,'Unified_Sampler.R')); load_unified_cpp()
cases <- list(central=c(.1,.5,.9),tail=c(.96,.97,.98,.99))
all_summary <- list()
for(case in names(cases)) {
  taus <- cases[[case]]; n <- 60L; total <- 1000L; burn <- 500L; warm <- 50L
  dat <- simulate_data(1,n,taus[1],'VS','Normal')
  checks <- c(initial=0L,theta_move=0L,theta=0L,interweaving=0L)
  min_gap <- Inf; post_theta_moves <- post_asis_moves <- integer(length(taus)); prev <- NULL
  audit <- function(stage,it,j,states) {
    mat <- do.call(cbind,lapply(states,`[[`,'theta')); gap <- min(mat[,-1,drop=FALSE]-mat[,-ncol(mat),drop=FALSE])
    stopifnot(gap>=0,all(is.finite(mat))); min_gap <<- min(min_gap,gap); checks[stage] <<- checks[stage]+1L
    if(!is.null(prev) && it>burn && stage=='theta_move' && any(mat[,j]!=prev[,j])) post_theta_moves[j] <<- post_theta_moves[j]+1L
    if(!is.null(prev) && it>burn && stage=='interweaving' && any(mat[,j]!=prev[,j])) post_asis_moves[j] <<- post_asis_moves[j]+1L
    prev <<- mat
  }
  # Record posterior-only out-of-box rates without changing kernel calls/RNG.
  native_step <- box_pmala_step; calls <- outside <- accepted <- integer(length(taus)); sweep_j <- 0L
  box_pmala_step <- function(...) {
    st <- native_step(...); sweep_j <<- sweep_j+1L
    sweep <- warm+(sweep_j-1L)%/%length(taus)+1L; j <- (sweep_j-1L)%%length(taus)+1L
    if(sweep>burn) { calls[j] <<- calls[j]+1L; outside[j] <<- outside[j]+as.integer(isTRUE(st$outside)); accepted[j] <<- accepted[j]+as.integer(st$accept) }
    st
  }
  set.seed(1001); fit <- gibbs_unified(dat$y,taus,gibbs_iter=total,gibbs_burn=burn,warm=warm,verbose=FALSE,audit=audit)
  box_pmala_step <- native_step
  stopifnot(all(vapply(seq_along(taus),function(j) length(unique(fit$delta[burn:total,j]))==1L,logical(1))))
  for(j in seq_len(length(taus)-1L)) stopifnot(all(fit$theta[,,j]<=fit$theta[,,j+1L]))
  movement <- vapply(seq_along(taus),function(j) max(apply(fit$theta[,,j],2,sd)),numeric(1))
  summary <- data.frame(case=case,tau=taus,n=n,total=total,burn=burn,warm=warm,
    outside_rate=outside/calls,accepted_rate=accepted/calls,accepted_theta_moves=post_theta_moves,
    asis_moves=post_asis_moves,max_coordinate_sd=movement,delta_final=fit$delta_final,
    min_gap=min_gap,seconds=fit$seconds)
  print(summary); print(checks)
  saveRDS(list(fit=fit,data=dat,summary=summary,audit_counts=checks),file.path(root,paste0('joint_',case,'.rds')))
  all_summary[[case]] <- summary
}
summary <- do.call(rbind,all_summary); write.csv(summary,file.path(root,'joint_checks.csv'),row.names=FALSE)
cat('PASS no crossing after every theta and interweaving update and throughout retained chains; rates above quantify movement\n')
if(any(summary$accepted_theta_moves==0)) cat('LIMITATION: some conditional theta chains accepted zero retained proposals; support correctness is not evidence of mixing\n')
