require("reshape2")
melt.deSolve <- function(data, ..., na.rm=FALSE, value.name= "value") {
    melt(as.data.frame(data),id.var="time",...)
}

## Kalman filter functions for logistic growth model
## KF update calculation
nlkfpred <- function(r,K,procvar,obsvar,M.n.start,
                     Var.n.start,Nobs) {
  nt <- length(Nobs)
  M.nobs <- numeric(nt)
  Var.nobs <- numeric(nt)
  M.n <- M.n.start
  Var.n <- Var.n.start
  M.nobs[1] <- M.n.start
  Var.nobs[1] <- Var.n.start+obsvar
  for (t in 2:nt) {
    M.ni <- M.n+r*M.n*(1-M.n/K)
    b <- 1+r-2*r*M.n/K
    Var.ni <- b^2*Var.n + procvar
    M.nobs[t] <- M.ni
    Var.nobs[t] <- Var.ni + obsvar
    M.n <- M.ni +  Var.ni/Var.nobs[t]*(Nobs[t]-M.nobs[t])
    Var.n <- Var.ni*(1 - Var.ni/Var.nobs[t])
  } 
  list(mean=M.nobs,var=Var.nobs)
}

## KF wrapper function
nlkflik <- function(logr,logK,logprocvar,
                    logobsvar,logM.n.start,logVar.n.start,
                    obs.data) {
  pred <- nlkfpred(r=exp(logr),K=exp(logK),
                   procvar=exp(logprocvar),obsvar=exp(logobsvar),
                   M.n.start=exp(logM.n.start),Var.n.start=exp(logVar.n.start),
                   Nobs=obs.data)
  -sum(dnorm(obs.data,mean=pred$mean,sd=sqrt(pred$var),
             log=TRUE))
}