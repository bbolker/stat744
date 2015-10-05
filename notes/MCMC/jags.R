library(mcmcplots)
library(coda)
library(lattice)
library(R2jags)

## general-purpose function for simulating time series
## with (discrete-time) logistic dynamics
simlogistdata <- function(seed=1001,
                          r=1,K=10,n0=1,t0=1,tot.t=10,dt=0.5,
                          sd.proc=1,sd.obs=1) {
  if (!is.null(seed)) set.seed(seed)
  tvec <- seq(1,tot.t,by=dt)
  n <- length(tvec)
  y <- numeric(n)
  y[1] <- n0
  e.proc <- rnorm(n,mean=0,sd=sd.proc)
  e.obs <- rnorm(n,mean=0,sd=sd.obs)
  for (i in 2:n) {
      y[i] <- max(0.001,y[i-1]+(r*y[i-1]*(1-y[i-1]/K))*dt+e.proc[i])
  }
  y.procobs <- y+e.obs
  cbind(tvec,y.procobs)
}

set.seed(102)
s1 <- simlogistdata(tot.t=10,dt=0.2)
plot(y.procobs~tvec,data=s1)

parameters <- c("r","K","tau.obs","tau.proc","n0")
library("R2jags")

## set up intial values for chains
inits <- list(list(n0=1,r=0.2,K=10,tau.obs=1,tau.proc=1),
              list(n0=1,r=0.1,K=10,tau.obs=1,tau.proc=1),
              list(n0=1,r=0.4,K=10,tau.obs=1,tau.proc=1),
              list(n0=1,r=0.2,K=10,tau.obs=3,tau.proc=1),
              list(n0=1,r=0.2,K=10,tau.obs=1,tau.proc=3))

jagsdata <- list(o=s1[,2],dt=0.2,N=nrow(s1),n0rate=1, maxr=5)

j1 <- jags(data=jagsdata,inits, param=parameters,
           model="logist.bug",   ## in your working directory 
           n.chains=length(inits), ##how many chains you want(in the list)
           n.iter=15000,
           n.burnin=5000,
           n.thin=37)
### The general idea will work with any flavor of BUGS (WinBUGS,
##  OpenBUGS, JAGS ...) you can add another two components, debug=TRUE/FALSE ...


print(j1)
s2 <- as.mcmc(j1$BUGS)
##plot

mcmcplot(j1,dir=getwd())
## 
xyplot(as.mcmc(j1))
## Geweke diagnostic: whether your markov chain is good
## the difference between the first 10% sample and the last 50% sample (should be non-significatn!)
geweke.diag(j1)
##heidel diagnol: two test: 1.Stationarity test:if reject h_0, it is not stationary
## 2. Halfwidth test: whether the estimate (s.t:mean with low variance) is acurate,sufficiently low noise.
heidel.diag(as.mcmc(j1))
## Raftery diagnol: 95% look at the tail, how large n is good enough?
raftery.diag(as.mcmc(j1))
## Gelman-Rubin statistic (potential scale reduction factor);
##  should be <1.2
gelman.diag(as.mcmc(j1))
##
## handy in this case, but be careful with attach() and
## similar!
attach.jags(j1)
plot(r,type='l')
plot(density(r))
abline(v=1,lty=1)
quantile(r,probs=c(0.025,0.975))
##
plot(density(sqrt(1/tau.obs)))
plot(density(1/tau.obs))
abline(v=1,lty=1)
quantile(r,probs=c(0.025,0.975))
detach.jags()


