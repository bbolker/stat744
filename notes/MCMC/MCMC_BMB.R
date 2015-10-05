## load all packages first:

library(coda)     ## basic plots and diagnostics
library(lattice)  
library(plotMCMC) ## autocorr plot and other pretty plots
library(MASS)     ## for mvrnorm, kde2d
## mvtnorm::rmvnorm does the same thing, but MASS is a built-in package,
##   so probably better to use MASS::mvrnorm 

## The next line is very common, but *not* recommended.
## Better to leave it up to the user to clean their workspace/
##   start a new session if they prefer
## rm(list=ls())
set.seed(568678876)
reps <- 50000

x <- 0  ## data value
w <- 1  ## candidate distribution width
chain <- c(0,rep(NA,reps))  ## pre-allocate/fill chain with NAs

for(i in 1:reps){
    ## candidate distribution is U(x-w,x+w)
  proposal <- chain[i]+runif(1,min=-w,max=w)
  ## good to use built-in distributions (dcauchy()) when possible
  ratio <- dcauchy(x,proposal)/dcauchy(x,chain[i])
  ## using ratio>1 first is redundant, but efficient
  accept <- (ratio>1 || runif(1)<ratio)
  ## using if rather than ifelse in-line ...
  chain[i+1] <- if (accept) proposal else chain[i]
}

## if x were a vector instead of a single value we should use
## something like this: exp(sum(dcauchy(...,log=TRUE))) is a
## computationally efficient way to take the product of
## the posteriors for each observation in a vector x
##
## a matter of taste whether we use {theta,gamma} or {location,scale}
## as the parameter names
postfun <- function(theta=0,gamma=1,data=x) {
    exp(sum(dcauchy(data,theta,gamma,log=TRUE)))
}

burnin <- 1000
## density plot
dd <- density(chain[-(1:burnin)])
plot(dd,ylim=c(0,0.4))
curve(dcauchy(x),lty=2,add=TRUE,n=201)

## comparison:
plot(dd$x,dcauchy(dd$x)-dd$y,type="l")

plot(dd,xlim=c(-5,5),ylim=c(0,0.4))
curve(dcauchy(x),lty=2,add=TRUE,n=201)

##Convergence Diagnostics
## trace plot
plot(chain,type='l')  ## full chain
plot(chain,type='l',ylim=c(-4,4)) ## constrained chain

## coda and plotMCMC packages
xyplot(as.mcmc(chain))

##autocorrelation check
plotAuto(chain,thin=1)
plotAuto(chain,thin=10)
plotAuto(chain,thin=100)

effectiveSize(chain)

#thinning a chain
tchain <- chain[seq(from=1000,to=50000,by=10)]
plot(density(tchain))
curve(dcauchy(x),lty=2,add=TRUE)
plot(tchain,type="l")
    
##target cauchy density with multiple observations
set.seed(4508921)

## it's best to avoid reusing variables with different meanings
## (e.g. 'chain') -- gets confusing if you ever try to skip around
## within a code file

mchain <- matrix(data=NA,ncol=2,nrow=reps+1)
mchain[1,] <- c(0,0)

x <- c(0,0)
## slight modification
for(i in 1:reps){
    proposal <- mchain[i,]+runif(2,min=-w,max=w)
    ## postfun *implicitly* takes data equal to x
    ## convenient but maybe bad programming practice
    ratio <- postfun(proposal)/postfun(mchain[i])
    accept <- (ratio>1 || runif(1)<ratio)
    mchain[i+1,] <- if (accept) proposal else mchain[i,]
}

par(mfrow=c(1,2))
plot(mchain[,1],type='l')
plot(mchain[,2],type='l')
## or:
xyplot(as.mcmc(mchain))     ## coda
## or:
traceplot(as.mcmc(mchain))  ## coda
## or:
plotTrace(mchain)

## univariate densities:
densityplot(as.mcmc(mchain))
## rug plot (ticks on bottom of plot) aren't useful here... just
##  a solid line

plotDens(as.mcmc(mchain))

kk <- kde2d(mchain[,1],mchain[,2])
with(kk,image(x,y,log(z)))    ## easier to see colours on log scale
lines(mchain[,1],mchain[,2])  ## visualize random walk

## cauchy: chain on gamma (fit a single parameter for both observations)
set.seed(12876553)

x <- c(1,2)
chainG <- c(1,rep(NA,reps))
for(i in 1:reps){
    proposal <- chainG[i]+runif(1,min=-w,max=w)
    if (any(proposal<0)) {
        accept <- FALSE
    } else {
        ratio <- postfun(gamma=proposal)/postfun(gamma=chainG[i])
        accept <- (ratio>1 || runif(1)<ratio)
    }
    chainG[i+1] <- if (accept) proposal else chainG[i]
}

plot(chainG,type='l')
xyplot(as.mcmc(chainG))
plotDens(as.mcmc(chainG),log=TRUE)

## Gibbs Sampling
set.seed(5678909)
reps<-10000
##conditional pdf of x1 given x2
conditional<-function(x.2,mu.1,mu.2,sigma.1,sigma.2,rho){
  out<-rnorm(1,mean=mu.1+(sigma.1/sigma.2)*rho*(x.2-mu.2),sd=sqrt((1-rho^2)*sigma.1^2))
  return(out)
}

chain.1 <- c(0,rep(NA,reps))
chain.2 <- c(0,rep(NA,reps))
rho <- 0.25

for(i in 1:reps){
  chain.1[i+1]<-conditional(chain.2[i],1,-1,0.5,0.35,0.25)
  chain.2[i+1]<-conditional(chain.1[i+1],-1,1,0.35,0.5,0.25)
}

cov<-0.25*0.5*0.35
samples <- mvrnorm(10000,mu=c(-1,1),
                 Sigma=matrix(c(0.5^2,cov,cov,0.35^2),ncol=2))
par(mfrow=c(1,2))
plot(chain.1[1000:10000],chain.2[1000:10000])
plot(samples[,1],samples[,2])
plot(chain.1,type='l')
plot(density(chain.1))
####Gibbs another poisson * gamma
y<-c(5,1,5,14,3,19,1,1,4,22)
t<-c(94,16,63,126,5,31,1,1,2,10)
rbind(y,t)
gibbs <- function(n.sims, beta.start, alpha, gamma, delta, y , t, burnin = 0, thin = 1) {
  beta.draws <- c()
  lambda.draws <- matrix(NA, nrow = n.sims, ncol = length(y))
  beta.cur <- beta.start

lambda.update <- function(alpha, beta, y, t) {
  rgamma(length(y), y + alpha, t + beta)
}
beta.update <- function(alpha, gamma, delta, lambda,y) {
  rgamma(1, length(y) * alpha + gamma, delta + sum(lambda))
}

for (i in 1:n.sims) {
  lambda.cur <- lambda.update(alpha = alpha, beta = beta.cur,y = y, t = t)
  beta.cur <- beta.update(alpha = alpha, gamma = gamma,delta = delta, lambda = lambda.cur, y = y)
if (i > burnin & (i - burnin)%%thin == 0) {
  lambda.draws[(i - burnin)/thin, ] <- lambda.cur
  beta.draws[(i - burnin)/thin] <- beta.cur
    }
  }
  return(list(lambda.draws = lambda.draws, beta.draws = beta.draws))
}
#inference
posterior <- gibbs(n.sims = 10000, beta.start = 1, alpha = 1.8,gamma = 0.01, delta = 1, y = y, t = t)
colMeans(posterior$lambda.draws)
mean(posterior$beta.draws)
apply(posterior$lambda.draws, 2, sd)
sd(posterior$beta.draws)
