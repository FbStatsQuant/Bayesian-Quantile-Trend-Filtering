// Includes unchanged guarded primitives. Unbounded calls use the original DLL.
#include "prox_admm_metric.cpp"

// Two-block ADMM: split (v,t)=(D theta,theta), g(v,t)=lambda|v|+I_box(t).
// theta update uses increments about x for stability. Return feasible t, not the
// unconstrained theta iterate. Fixed cold starts make this a deterministic map.
List bounded_prox(NumericVector x,NumericVector a,NumericVector r,double lambda,double gamma,
 NumericVector d,double c,int k,double rho,int max_iter,double tol,NumericVector lower,NumericVector upper) {
  int n=x.size(),p=k+1,m=n-p;
  if(m<1||p<1||a.size()!=n||r.size()!=n||d.size()!=n||lower.size()!=n||upper.size()!=n)
    stop("Invalid bounded prox dimensions/order");
  if(!R_finite(lambda)||lambda<0||!R_finite(gamma)||gamma<=0||!R_finite(c)||c<0||!R_finite(rho)||rho<=0||max_iter<1)
    stop("Invalid bounded prox controls");
  double eta=0;
  for(int i=0;i<n;++i) {
    if(!R_finite(x[i])||!R_finite(a[i])||a[i]<0||!R_finite(r[i])||!R_finite(d[i])||d[i]<=0||
       ISNAN(lower[i])||ISNAN(upper[i])||lower[i]>upper[i]||lower[i]==R_PosInf||upper[i]==R_NegInf)
      stop("Invalid bounded prox values/bounds");
    eta+=(a[i]+d[i]/gamma)/n;
  }
  std::vector<double> st=diff_stencil(p),xv(x.begin(),x.end()),Dx(m),v(m),u(m,0),t(n),h(n,0),th(n),
    rhs(n),tmp(m),Dth(m),oldv(m),oldt(n),dt(n),dual(n),station(n),Dtdual(n),Dret(m),w(n),Dw(m);
  apply_D(xv,st,Dx); v=Dx;
  for(int i=0;i<n;++i) t[i]=std::max(lower[i],std::min(upper[i],x[i]));
  Band A=DtD_band(n,st);
  for(int q=0;q<=p;++q) for(int i=0;i<n;++i) A.B[q][i]*=c/gamma+rho;
  for(int i=0;i<n;++i) A.B[0][i]+=a[i]+d[i]/gamma+eta;
  band_chol_ridge(A,"bounded ADMM system");
  double primal=0,dualres=0; int used=0;
  for(int it=0;it<max_iter;++it) {
    oldv=v; oldt=t;
    for(int j=0;j<m;++j) tmp[j]=v[j]-Dx[j]-u[j];
    apply_Dt(tmp,st,rhs);
    for(int i=0;i<n;++i) rhs[i]=a[i]*(r[i]-x[i])+rho*rhs[i]+eta*(t[i]-x[i]-h[i]);
    band_solve(A,rhs);
    for(int i=0;i<n;++i) th[i]=x[i]+rhs[i];
    apply_D(rhs,st,Dw);
    for(int j=0;j<m;++j) Dth[j]=Dx[j]+Dw[j];
    primal=0;
    for(int j=0;j<m;++j) {
      double q=Dth[j]+u[j],cut=lambda/rho;
      v[j]=q>cut?q-cut:(q< -cut?q+cut:0);
      u[j]+=Dth[j]-v[j]; primal+=(Dth[j]-v[j])*(Dth[j]-v[j]);
      tmp[j]=v[j]-oldv[j];
    }
    apply_Dt(tmp,st,dt); dualres=0;
    for(int i=0;i<n;++i) {
      t[i]=std::max(lower[i],std::min(upper[i],th[i]+h[i]));
      h[i]+=th[i]-t[i]; primal+=(th[i]-t[i])*(th[i]-t[i]);
      double q=rho*dt[i]+eta*(t[i]-oldt[i]); dualres+=q*q;
    }
    ++used;
    if(tol>0 && std::sqrt(primal)<=tol && std::sqrt(dualres)<=tol) break;
  }
  // KKT diagnostics at the returned feasible point, not at an intermediate iterate.
  for(int i=0;i<n;++i) w[i]=t[i]-x[i];
  apply_D(w,st,Dw); apply_D(t,st,Dret);
  for(int j=0;j<m;++j) tmp[j]=c/gamma*Dw[j]+rho*u[j];
  apply_Dt(tmp,st,Dtdual);
  double stat=0,subgrad=0,normal=0;
  for(int i=0;i<n;++i) {
    station[i]=a[i]*(t[i]-r[i])+d[i]/gamma*w[i]+Dtdual[i]+eta*h[i];
    stat=std::max(stat,std::abs(station[i]));
    double hn=eta*h[i]; dual[i]=hn;
    if(lower[i]==upper[i]) continue;
    if(t[i]==lower[i]) normal=std::max(normal,std::max(0.0,hn));
    else if(t[i]==upper[i]) normal=std::max(normal,std::max(0.0,-hn));
    else normal=std::max(normal,std::abs(hn));
  }
  // Fenchel complementarity gap handles nearly zero D*t without sign thresholds.
  for(int j=0;j<m;++j) subgrad+=lambda*std::abs(Dret[j])-rho*u[j]*Dret[j];
  return List::create(_["theta"]=wrap(t),_["iterations"]=used,_["primal"]=std::sqrt(primal),
    _["dual"]=std::sqrt(dualres),_["stationarity_inf"]=stat,_["l1_gap"]=subgrad,
    _["box_normal_inf"]=normal,_["l1_dual"]=wrap(u),_["box_dual"]=wrap(dual),_["rho"]=rho,_["eta"]=eta);
}
extern "C" SEXP C_bounded_prox(SEXP x,SEXP a,SEXP r,SEXP lambda,SEXP gamma,SEXP d,SEXP c,SEXP k,
 SEXP rho,SEXP max_iter,SEXP tol,SEXP lower,SEXP upper) {
 BEGIN_RCPP
 return wrap(bounded_prox(as<NumericVector>(x),as<NumericVector>(a),as<NumericVector>(r),as<double>(lambda),
  as<double>(gamma),as<NumericVector>(d),as<double>(c),as<int>(k),as<double>(rho),as<int>(max_iter),
  as<double>(tol),as<NumericVector>(lower),as<NumericVector>(upper)));
 END_RCPP
}
