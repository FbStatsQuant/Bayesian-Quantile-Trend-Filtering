validate_unified <- function(y,tau,order,total,burn,warm,iters,K,init,delta,lambda,db) {
  if(!is.numeric(tau)||!length(tau)||any(!is.finite(tau))||any(tau<=0|tau>=1)||anyDuplicated(tau)||is.unsorted(tau,strictly=TRUE))
    stop("tau must be distinct, strictly increasing, finite values strictly between 0 and 1")
  int <- function(x) length(x)==1L && is.finite(x) && x==floor(x)
  if(!is.numeric(y)||any(!is.finite(y))||!int(order)||order<0||length(y)<=order+1L) stop("Invalid y or difference order")
  if(!all(vapply(list(total,burn,warm,iters,K),int,logical(1)))||burn<0||warm<0||warm>burn||total<=burn||iters<1||K<1) stop("Invalid iteration settings")
  if(init!="y") stop("This candidate supports approved init='y' only")
  pos <- function(x) length(x)==1 && is.finite(x) && x>0
  if(!pos(delta)||(!is.null(lambda)&&!pos(lambda))) stop("delta/lambda initialization must be positive finite scalars")
  if(length(db)!=2||any(!is.finite(db))||db[1]<=0||db[1]>db[2]) stop("Invalid delta bounds")
}
check_box <- function(lower,upper,n) {
  if(length(lower)!=n||length(upper)!=n||anyNA(lower)||anyNA(upper)||any(lower>upper)||any(lower==Inf)||any(upper==-Inf))
    stop("Invalid bounds: require length n and lower <= upper")
}
in_box <- function(theta,lower,upper) all(is.finite(theta)&theta>=lower&theta<=upper)
unbounded_box <- function(lower,upper) all(lower==-Inf & upper==Inf)
# C++ optimizer loader and .Call wrapper. No random draws occur here.
# bounded_prox() is implemented in prox_bounded.cpp; box_prox() below dispatches
# infinite boxes to the unchanged individual optimizer for singleton parity.
load_bounded_cpp <- function() {
  src <- file.path(.unified_dir,"prox_bounded.cpp")
  dll <- file.path(tempdir(),"prox_unified_bounded.dll")
  cmd <- sprintf('"C:/mingw64/bin/g++.exe" -std=gnu++17 -O2 -w -shared -static-libgcc -static-libstdc++ -I"%s/include" -I"%s" -o "%s" "%s" -L"%s/bin/x64" -lR',
     R.home(),system.file("include",package="Rcpp"),dll,src,R.home())
  if(system(cmd)!=0) stop("Could not compile bounded kernel")
  info <- dyn.load(dll)
  address <- getNativeSymbolInfo("C_bounded_prox",info)$address
  assign("bounded_prox",function(x,a,r,lambda,gamma,d,c,k,rho,max_iter,tol,lower,upper)
    .Call(address,as.numeric(x),as.numeric(a),as.numeric(r),as.numeric(lambda),as.numeric(gamma),
      as.numeric(d),as.numeric(c),as.integer(k),as.numeric(rho),as.integer(max_iter),as.numeric(tol),as.numeric(lower),as.numeric(upper)),
    envir=environment(load_bounded_cpp))
}
# Whole conditional U + metric quadratic + box indicator, approximated by ADMM.
box_prox <- function(x,a,r,lambda,gamma,d,c,order,lower,upper,rho=NULL,iters=200L,tol=0) {
  check_box(lower,upper,length(x))
  if(unbounded_box(lower,upper)) return(.guarded$prox_T(x,a,r,lambda,gamma,d,c,order,rho,iters,tol))
  if(is.null(rho)) rho <- .1*(mean(d)+c)/gamma
  bounded_prox(x,a,r,lambda,gamma,d,c,order,rho,iters,tol,lower,upper)$theta
}
box_pmala_step <- function(theta,y,z,lambda,sigma,delta,cst,order,metric,c_fixed,rho,iters,mh,kappa,tol,lower,upper) {
  check_box(lower,upper,length(theta))
  if(!in_box(theta,lower,upper)) stop("Current theta outside support")
  if(unbounded_box(lower,upper)) return(.guarded$pmala_step(theta,y,z,lambda,sigma,delta,cst,order,metric,c_fixed,rho,iters,mh,kappa,tol))
  gamma <- delta/2; a <- 1/(cst$t2*sigma*z); r <- y-cst$psi*z
  M <- metric_dc(metric,a,lambda,c_fixed,kappa)
  p <- box_prox(theta,a,r,lambda,gamma,M$d,M$c,order,lower,upper,rho,iters,tol)
  prop <- p+sqrt(delta)*minv_sqrt_noise(rnorm(length(theta)),M$d,M$c,order)
  outside <- !in_box(prop,lower,upper)
  if(outside) log_alpha <- -Inf else {
    pstar <- box_prox(prop,a,r,lambda,gamma,M$d,M$c,order,lower,upper,rho,iters,tol)
    log_alpha <- U_cond(theta,a,r,lambda,order)-U_cond(prop,a,r,lambda,order)+
      (mnorm2(prop-p,M$d,M$c,order)-mnorm2(theta-pstar,M$d,M$c,order))/(2*delta)
    if(!is.finite(log_alpha)) log_alpha <- -Inf
  }
  accept <- log(runif(1))<log_alpha
  list(theta=if(accept) prop else theta,accept=accept,log_alpha=min(0,log_alpha),outside=outside)
}
asis_scale_domain <- function(p,v,lower,upper) {
  check_box(lower,upper,length(p)); lo <- 0; hi <- Inf
  for(i in seq_along(p)) {
    if(v[i]==0) { if(p[i]<lower[i]||p[i]>upper[i]) return(c(Inf,-Inf)) } else {
      ends <- sort(c((lower[i]-p[i])/v[i],(upper[i]-p[i])/v[i]))
      lo <- max(lo,ends[1]); hi <- min(hi,ends[2])
    }
  }
  c(lo,hi)
}
box_asis_step <- function(theta,lambda,a,r,a0,b0,Q,lower,upper,w=1,max_steps=30L) {
  check_box(lower,upper,length(theta))
  if(!in_box(theta,lower,upper)) stop("ASIS current theta outside support")
  if(unbounded_box(lower,upper)) return(.guarded$asis_step(theta,lambda,a,r,a0,b0,Q,w,max_steps))
  p <- Q%*%crossprod(Q,theta); v <- theta-p
  dom <- asis_scale_domain(p,v,lower,upper); unchanged <- list(lambda=lambda,theta=theta)
  if(dom[1]>=dom[2]||dom[2]<=0||!in_box(as.numeric(p+v),lower,upper)) return(unchanged)
  eta0 <- log(lambda); eta_lo <- eta0-log(dom[2]); eta_hi <- eta0-log(dom[1])
  logf <- function(eta) {
    if(!is.finite(eta)||eta<eta_lo||eta>eta_hi) return(-Inf)
    lam <- exp(eta); th <- as.numeric(p+(lambda/lam)*v)
    if(!is.finite(lam)||lam<=0||!in_box(th,lower,upper)) return(-Inf)
    a0*eta-b0*lam-sum(a*(th-r)^2)/2
  }
  y0 <- logf(eta0)-rexp(1)
  if(!is.finite(y0)) return(unchanged)
  L <- eta0-runif(1)*w; U <- L+w; j <- floor(runif(1)*max_steps); kk <- max_steps-1-j
  while(j>0&&logf(L)>y0) { L <- L-w; j <- j-1 }
  while(kk>0&&logf(U)>y0) { U <- U+w; kk <- kk-1 }
  repeat {
    eta1 <- L+runif(1)*(U-L)
    if(logf(eta1)>y0) break
    if(eta1<eta0) L <- eta1 else U <- eta1
    if(U-L<1e-10) return(unchanged)
  }
  list(lambda=exp(eta1),theta=as.numeric(p+(lambda/exp(eta1))*v))
}
