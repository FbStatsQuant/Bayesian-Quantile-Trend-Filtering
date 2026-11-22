# Pure postprocessing: no native load or sampling on source().
unified_data_options <- function(model=2L, noise="normal") {
  # Verified against Individual_Sampler_Scale.R and Individual_Sampler_MYULA.R.
  # The approved PMALA generator uses PC/VS/S instead of numeric model codes.
  baselines <- c("PC","VS","S")
  if(is.numeric(model)&&length(model)==1L&&is.finite(model)&&model %in% 1:3) {
    baseline_id <- baselines[model]
  } else if(is.character(model)&&length(model)==1L&&!is.na(model)&&toupper(model) %in% baselines) {
    baseline_id <- toupper(model)
  } else stop("model must be 1 (PC), 2 (VS), 3 (S), or a baseline code PC/VS/S")
  noises <- c(normal="Normal",beta="Beta",mixed="Mixed")
  if(!is.character(noise)||length(noise)!=1L||is.na(noise)||!tolower(noise) %in% names(noises))
    stop("noise must be normal, beta or mixed (case insensitive)")
  list(model=match(baseline_id,baselines),baseline_id=baseline_id,noise_id=unname(noises[tolower(noise)]))
}

unified_simulation_truth <- function(seed, n, tau, baseline_id="VS", noise_id="Normal") {
  if(!is.numeric(tau)||!length(tau)||any(!is.finite(tau))||any(tau<=0|tau>=1)||anyDuplicated(tau))
    stop("Truth tau values must be distinct and strictly between 0 and 1")
  if(length(n)!=1L||!is.finite(n)||n<1||n!=floor(n)) stop("n must be a positive integer")
  # Reuse the authoritative generator for ALL baseline/noise combinations.
  # It resets RNGkind/seed internally; restore both even if it raises an error.
  old_kind <- RNGkind(); had_seed <- exists(".Random.seed",envir=.GlobalEnv,inherits=FALSE)
  if(had_seed) old_seed <- get(".Random.seed",envir=.GlobalEnv)
  on.exit({
    do.call(RNGkind,as.list(old_kind))
    if(had_seed) assign(".Random.seed",old_seed,envir=.GlobalEnv)
    else if(exists(".Random.seed",envir=.GlobalEnv,inherits=FALSE)) rm(".Random.seed",envir=.GlobalEnv)
  },add=TRUE)
  truth <- vapply(tau,function(tt) simulate_data(seed,n,tt,baseline_id,noise_id)$truth,numeric(n))
  truth <- matrix(truth,nrow=n,ncol=length(tau))
  colnames(truth) <- as.character(tau)
  truth
}

report_unified <- function(fit, y, target_tau, truth=NULL, x=seq_along(y),
                           out_dir=file.path(.unified_dir,"report_output"), prefix="unified") {
  dims <- dim(fit$theta); taus <- fit$tau
  if(length(dims)!=3L||any(dims<1L)||!is.numeric(taus)||length(taus)!=dims[3L]||
     any(!is.finite(taus))||any(taus<=0|taus>=1)||anyDuplicated(taus)||
     !is.numeric(fit$theta)||any(!is.finite(fit$theta))) stop("Invalid unified fit")
  n <- dims[2L]; nq <- dims[3L]; kept <- dims[1L]
  if(!is.numeric(y)||length(y)!=n||any(!is.finite(y))||
     !is.numeric(x)||length(x)!=n||any(!is.finite(x))) stop("x and y must be finite numeric vectors matching the fit")
  if(!is.numeric(target_tau)||length(target_tau)!=1L||!is.finite(target_tau)||!target_tau %in% taus)
    stop("target_tau must be one of the fitted tau values")
  j <- match(target_tau,taus)
  if(length(prefix)!=1L||is.na(prefix)||!grepl("^[A-Za-z0-9_-]+$",prefix)) stop("prefix must contain only letters, digits, underscores or hyphens")
  total <- nrow(fit$lambda)
  if(is.null(total)||total<kept) stop("Invalid fit trace lengths")
  for(nm in c("lambda","sigma","delta","acc"))
    if(!is.matrix(fit[[nm]])||!identical(dim(fit[[nm]]),c(total,nq))) stop("Invalid trace dimensions: ",nm)
  post <- seq.int(total-kept+1L,total)
  est <- vapply(seq_len(nq),function(h) colMeans(matrix(fit$theta[,,h],nrow=kept,ncol=n)),numeric(n))
  est <- matrix(est,nrow=n,ncol=nq); colnames(est) <- as.character(taus)
  known <- rep(FALSE,nq)
  if(is.null(truth)) truth <- matrix(NA_real_,n,nq) else {
    if(is.numeric(truth)&&is.null(dim(truth))&&nq==1L&&length(truth)==n) truth <- matrix(truth,n,1L)
    if(!is.numeric(truth)||!is.matrix(truth)||!identical(dim(truth),c(n,nq)))
      stop("truth must be an n-by-length(fit$tau) numeric matrix; a vector is allowed only for a singleton")
    if(!is.null(colnames(truth))) {
      labels <- suppressWarnings(as.numeric(colnames(truth)))
      if(anyNA(labels)||anyDuplicated(labels)||!setequal(labels,taus)) stop("Named truth columns must match the fitted taus")
      truth <- truth[,match(taus,labels),drop=FALSE]
    }
    for(h in seq_len(nq)) {
      if(all(is.na(truth[,h]))) next
      if(any(!is.finite(truth[,h]))) stop("Each truth column must be wholly finite or wholly NA (unavailable)")
      known[h] <- TRUE
    }
  }
  mse <- vapply(seq_len(nq),function(h) if(known[h]) mean((est[,h]-truth[,h])^2) else NA_real_,numeric(1))
  ess <- vapply(seq_len(nq),function(h) {
    if(kept<3L||!requireNamespace("coda",quietly=TRUE)) return(NA_real_)
    curve_level <- rowMeans(matrix(fit$theta[,,h],nrow=kept,ncol=n))
    if(sd(curve_level)==0) return(NA_real_)
    tryCatch(as.numeric(coda::effectiveSize(curve_level)),error=function(e) NA_real_)
  },numeric(1))
  diagnostics <- data.frame(tau=taus,MSE=mse,truth_available=known,
    mean_check_loss=vapply(seq_len(nq),function(h) mean(rho_tau(y-est[,h],taus[h])),numeric(1)),
    acceptance_post=colMeans(fit$acc[post,,drop=FALSE]),
    lambda_mean_post=colMeans(fit$lambda[post,,drop=FALSE]),
    sigma_mean_post=colMeans(fit$sigma[post,,drop=FALSE]),delta_final=fit$delta[total,],
    delta_frozen_post=vapply(seq_len(nq),function(h) length(unique(fit$delta[post,h]))==1L,logical(1)),
    ESS_curve_level=ess,retained_draws=kept)
  crossings <- if(nq==1L) 0 else sum(vapply(seq_len(nq-1L),function(h)
    sum(fit$theta[,,h]>fit$theta[,,h+1L]),numeric(1)))
  if(!dir.exists(out_dir)&&!dir.create(out_dir,recursive=TRUE,showWarnings=FALSE)) stop("Cannot create output directory")
  label <- format(target_tau,trim=TRUE,scientific=FALSE,digits=15)
  plot_file <- file.path(out_dir,paste0(prefix,"_target_",gsub("\\.","p",label),".png"))
  table_file <- file.path(out_dir,paste0(prefix,"_diagnostics.csv"))
  target_data <- data.frame(x=x,observed=y,truth=truth[,j],estimate=est[,j])
  curve_file <- file.path(out_dir,paste0(prefix,"_target_",gsub("\\.","p",label),"_curves.csv"))
  write.csv(diagnostics,table_file,row.names=FALSE,na="NA")
  write.csv(target_data,curve_file,row.names=FALSE,na="NA")
  png(plot_file,width=1400,height=850,res=140)
  device <- dev.cur(); on.exit(if(device %in% dev.list()) dev.off(device),add=TRUE)
  par(mar=c(4.5,4.7,4.6,1.2))
  subtitle <- if(known[j]) sprintf("Posterior mean estimate  |  Target MSE = %.6g",mse[j]) else
    "Posterior mean estimate  |  Truth unavailable; target MSE unavailable"
  plot(x,y,pch=16,cex=.65,col=adjustcolor("grey40",.55),
    ylim=range(c(y,est[,j],if(known[j]) truth[,j])),xlab="Index / x",ylab="Response / quantile",
    main=paste0("Target quantile: tau = ",label))
  mtext(subtitle,side=3,line=.5,cex=.82,col="grey30")
  idx <- order(x)
  if(known[j]) lines(x[idx],truth[idx,j],col="#222222",lwd=2.4)
  lines(x[idx],est[idx,j],col="#B23A48",lwd=2.4,lty=2)
  legend("topleft",bty="n",bg="white",cex=.82,
    legend=c("Observed data",if(known[j]) "True target curve","Estimated target curve (posterior mean)"),
    col=c("grey55",if(known[j]) "#222222","#B23A48"),
    pch=c(16,if(known[j]) NA,NA),lty=c(NA,if(known[j]) 1,2),lwd=c(NA,if(known[j]) 2.4,2.4))
  dev.off(device)
  cat(sprintf("\nUnified sampler report: target tau=%s; fitted taus=%s\n",label,paste(taus,collapse=", ")))
  for(h in seq_len(nq)) cat(sprintf("MSE [tau=%s]: %s\n",as.character(taus[h]),
    if(known[h]) format(mse[h],digits=10) else "unavailable (truth not supplied)"))
  cat("Post-burn diagnostics (estimator: posterior mean):\n"); print(diagnostics,row.names=FALSE)
  cat(sprintf("Retained adjacent-curve crossing violations: %d\n",crossings))
  if(!is.null(fit$seconds)) cat(sprintf("Sampler elapsed seconds: %.3f\n",fit$seconds))
  cat("ESS is descriptive for this chain; accepted movement alone does not establish convergence.\n")
  cat("Saved plot:",normalizePath(plot_file,winslash="/"),"\n")
  invisible(list(diagnostics=diagnostics,estimate=est,target_tau=target_tau,target_data=target_data,
    crossing_violations=crossings,plot_file=plot_file,diagnostics_file=table_file,curve_file=curve_file))
}
