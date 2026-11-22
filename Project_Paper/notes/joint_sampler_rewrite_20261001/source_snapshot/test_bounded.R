script <- normalizePath(sub('^--file=','',grep('^--file=',commandArgs(FALSE),value=TRUE)[1])); root <- dirname(script)
source(file.path(root,'Unified_Sampler.R')); load_unified_cpp()
expect_error <- function(expr) stopifnot(inherits(tryCatch({force(expr);NULL},error=identity),'error'))
set.seed(601); n <- 7L; x <- rnorm(n); a <- runif(n,.5,2); r <- rnorm(n); d <- runif(n,.8,1.2)
L <- rep(-.35,n); U <- rep(.6,n); gamma <- .7
v <- bounded_prox(x,a,r,0,gamma,d,0,1L,1,2000L,1e-11,L,U)
analytic <- pmax(L,pmin(U,(a*r+d*x/gamma)/(a+d/gamma)))
stopifnot(max(abs(v$theta-analytic))<1e-8,v$stationarity_inf<1e-8,in_box(v$theta,L,U))
cat('PASS bounded diagonal quadratic analytic reference\n')
# Independent epigraph QP, with explicit tiny epigraph ridge required by solve.QP.
# ADMM KKT diagnostics separately certify the unperturbed objective.
n <- 6L; k <- 1L; m <- n-k-1L; D <- diff(diag(n),differences=k+1L)
x <- c(-1,.4,.8,-.2,1,.1); r <- c(.3,-.6,1,.4,-.8,.7)
a <- seq(.7,1.3,length.out=n); d <- seq(.8,1.4,length.out=n); cmet <- 1.7; lam <- .45; gamma <- .8
L <- c(-.3,-.3,-.1,-.2,-.3,-.2); U <- c(.5,.2,.7,.6,.3,.6)
M <- diag(d)+cmet*crossprod(D); H <- diag(a)+M/gamma; b <- a*r+as.vector(M%*%x)/gamma
epiridge <- 1e-9
Hqp <- matrix(0,n+m,n+m); Hqp[1:n,1:n] <- H; Hqp[n+seq_len(m),n+seq_len(m)] <- diag(epiridge,m)
C <- rbind(cbind(-D,diag(m)),cbind(D,diag(m)),cbind(diag(n),matrix(0,n,m)),cbind(-diag(n),matrix(0,n,m)))
qp <- quadprog::solve.QP(Hqp,c(b,rep(-lam,m)),t(C),c(rep(0,2*m),L,-U))$solution[1:n]
obj <- function(th) sum(a*(th-r)^2)/2+lam*sum(abs(D%*%th))+as.numeric(crossprod(th-x,M%*%(th-x)))/(2*gamma)
rho <- .1*(mean(d)+cmet)/gamma
ref <- bounded_prox(x,a,r,lam,gamma,d,cmet,k,rho,50000L,1e-11,L,U)
v200 <- bounded_prox(x,a,r,lam,gamma,d,cmet,k,rho,200L,0,L,U)
stopifnot(max(abs(ref$theta-qp))<1e-6,ref$stationarity_inf<1e-7,abs(ref$l1_gap)<1e-7,
  ref$box_normal_inf<1e-10,ref$primal<1e-7,ref$dual<1e-7,in_box(v200$theta,L,U),v200$iterations==200L)
# Cold-start deterministic output, including diagnostics.
stopifnot(identical(v200,bounded_prox(x,a,r,lam,gamma,d,cmet,k,rho,200L,0,L,U)))
prox_summary <- data.frame(budget=c(200,50000),used=c(v200$iterations,ref$iterations),
  max_error_qp=c(max(abs(v200$theta-qp)),max(abs(ref$theta-qp))),
  objective_gap=c(obj(v200$theta)-obj(qp),obj(ref$theta)-obj(qp)),
  primal=c(v200$primal,ref$primal),dual=c(v200$dual,ref$dual),
  stationarity=c(v200$stationarity_inf,ref$stationarity_inf),l1_gap=c(v200$l1_gap,ref$l1_gap),
  box_normal=c(v200$box_normal_inf,ref$box_normal_inf))
print(prox_summary); write.csv(prox_summary,file.path(root,'prox_checks.csv'),row.names=FALSE)
cat('PASS bounded whole-U metric prox vs independent epigraph QP and KKT; 200-budget reported separately\n')
expect_error(bounded_prox(x,a,r,lam,gamma,d,cmet,k,rho,200L,0,U,L))
expect_error(box_prox(x,a,r,lam,gamma,d,cmet,k,U,L))
for(tt in list(0,1,c(.2,1),c(.5,.5),c(.9,.1),NA_real_,numeric()))
  expect_error(gibbs_unified(rep(0,10),tt,gibbs_iter=3,gibbs_burn=1,warm=0,verbose=FALSE))
cat('PASS inverted bounds, endpoints, duplicate, unsorted and nonfinite tau rejection\n')
expect_error(gibbs_unified(rep(1e20,10),c(.5,.5+.Machine$double.eps),gibbs_iter=3,gibbs_burn=1,warm=0,verbose=FALSE))
cat('PASS numerically collapsed joint initialization rejection\n')
# Capture reverse map arguments; independently calculate the same Gaussian density.
original_box <- box_prox; calls <- list()
box_prox <- function(...) { args <- list(...); calls[[length(calls)+1L]] <<- args; original_box(...) }
th <- rep(0,6); yy <- seq(-.2,.2,length.out=6); zz <- rep(1,6); cst <- ald_const(.5)
L <- rep(-10,6); U <- rep(10,6); sg <- 1; delta <- .03; lam <- 2
set.seed(77); st <- box_pmala_step(th,yy,zz,lam,sg,delta,cst,1L,'curv',0,NULL,200L,TRUE,3,0,L,U)
stopifnot(length(calls)==2L,identical(calls[[1]][[9]],L),identical(calls[[2]][[9]],L),
  identical(calls[[1]][[10]],U),identical(calls[[2]][[10]],U),
  identical(calls[[1]][[6]],calls[[2]][[6]]),identical(calls[[1]][[7]],calls[[2]][[7]]))
aa <- 1/(cst$t2*sg*zz); rr <- yy-cst$psi*zz; MM <- metric_dc('curv',aa,lam,0,3)
set.seed(77); pf <- original_box(th,aa,rr,lam,delta/2,MM$d,MM$c,1L,L,U)
prop <- pf+sqrt(delta)*minv_sqrt_noise(rnorm(6),MM$d,MM$c,1L)
pr <- original_box(prop,aa,rr,lam,delta/2,MM$d,MM$c,1L,L,U)
logalpha <- U_cond(th,aa,rr,lam,1L)-U_cond(prop,aa,rr,lam,1L)+
  (mnorm2(prop-pf,MM$d,MM$c,1L)-mnorm2(th-pr,MM$d,MM$c,1L))/(2*delta)
accept <- log(runif(1))<logalpha
stopifnot(identical(st$accept,accept),identical(st$theta,if(accept) prop else th),identical(st$log_alpha,min(0,logalpha)))
calls <- list(); set.seed(78)
out <- box_pmala_step(th,yy,zz,lam,sg,1e4,cst,1L,'curv',0,NULL,200L,TRUE,3,0,rep(-1e-9,6),rep(1e-9,6))
stopifnot(out$outside,!out$accept,identical(out$theta,th),out$log_alpha==-Inf,length(calls)==1L)
box_prox <- original_box
cat('PASS fixed-box/metric reverse Gaussian density and genuine outside-support rejection\n')
stopifnot(identical(asis_scale_domain(c(0,0,0),c(1,-2,0),c(.5,-3,-1),c(2,-1,1)),c(.5,1.5)))
stopifnot(identical(asis_scale_domain(0,0,1,2),c(Inf,-Inf)))
theta <- c(-.4,.6,-.2,.7,-.5,.1); Q <- null_basis(6,1L); lambda <- 2
L <- theta-.35; U <- theta+.25; p <- Q%*%crossprod(Q,theta); v <- theta-p
dom <- asis_scale_domain(p,v,L,U); elo <- log(lambda)-log(dom[2]); ehi <- log(lambda)-log(dom[1])
aa <- rep(1.4,6); rr <- seq(-.4,.5,length.out=6)
ld <- function(eta) eta-.001*exp(eta)-sum(aa*(p+lambda/exp(eta)*v-rr)^2)/2
norm <- integrate(Vectorize(function(e) exp(ld(e))),elo,ehi,rel.tol=1e-10)$value
mean_exact <- integrate(Vectorize(function(e) e*exp(ld(e))),elo,ehi,rel.tol=1e-10)$value/norm
set.seed(79); current <- list(theta=theta,lambda=lambda); eta <- numeric(6000)
for(i in seq_along(eta)) {
  current <- box_asis_step(current$theta,current$lambda,aa,rr,1,.001,Q,L,U)
  stopifnot(in_box(current$theta,L,U)); eta[i] <- log(current$lambda)
}
draws <- eta[1001:6000]; batch_se <- sd(colMeans(matrix(draws,100,50)))/sqrt(50)
stopifnot(abs(mean(draws)-mean_exact)<max(6*batch_se,.008),length(unique(draws))>4900)
same <- box_asis_step(theta,lambda,aa,rr,1,.001,Q,theta,theta)
stopifnot(identical(same$theta,theta),identical(same$lambda,lambda))
asis_summary <- data.frame(mean_eta=mean(draws),quadrature_eta=mean_exact,batch_se=batch_se,eta_lower=elo,eta_upper=ehi)
print(asis_summary); write.csv(asis_summary,file.path(root,'asis_checks.csv'),row.names=FALSE)
cat('PASS bounded ASIS feasible domain, fixed box, and eta target vs quadrature\n')
saveRDS(list(prox=prox_summary,asis=asis_summary,session=sessionInfo()),file.path(root,'bounded_checks.rds'))
