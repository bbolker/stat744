##
rm(list=ls())
set.seed(568678876)
reps=50000
##target density: the cauchy distribution
cauchy<-function(theta,x=0,gamma=1){
  out <- 1/(pi*gamma*(1+((theta-x)/gamma)^2))
  return(out)
}

chain<-rep(0,50000)
for(i in 1:reps){
  proposal<-chain[i]+runif(1,min=-1,max=1)
  accept<-runif(1)<cauchy(proposal)/cauchy(chain[i])
  chain[i+1]<-ifelse(accept==T,proposal,chain[i])
}

plot(density(chain[1000:50000]),ylim=c(0,0.4))
den<-cauchy(seq(from=-10,to=10,by=0.1),x=0,gamma=1)
lines(den~seq(from=-10,to=10,by=0.1),lty=2)

plot(density(chain[1000:50000]),xlim=c(-5,5),ylim=c(0,0.4))
den<-cauchy(seq(from=-5,to=5,by=0.1),x=0,gamma=1)
lines(den~seq(from=-5,to=5,by=0.1),lty=2)
##don't run these two lines, this is an alternative way to do the simulation from Prof.Bolker
L<-sum(dcauchy(x,x0,r,log=TRUE))
exp(L)*prior_distribution
##
##Convergence Diagnostics
##plot over time
plot(chain,type='l',ylim=c(-4,4))
##autocorrelation check
library(plotMCMC)
plotAuto(chain,thin=1)
plotAuto(chain,thin=10)
plotAuto(chain,thin=100)
#thinning a chain
plot(density(chain[seq(from=1000,to=50000,by=10)]),xlim=c(-5,51),ylim=c(0,0.4))
den<-cauchy(seq(from=-5,to=5,by=0.1),x=0,gamma=1)
lines(den~seq(from=-5,to=5,by=0.1),lty=2)
##target multiple cauchy density
rm(list=ls())
set.seed(4508921)
reps=50000

mvcauchy<-function(theta,x=c(0,0),gamma=1){
  out<-(1/(2*pi))*(gamma/((theta[1]-x[1])^2+(theta[2]-x[2])^2+gamma^2)^1.5)
  return(out)
}

chain<-matrix(data=NA,ncol=2,nrow=reps+1)
chain[1,]<-c(0,0)

for (i in 1:reps){
  proposal<- chain[i,]+runif(2,min=-1,max=1)
  accept<-runif(1)<mvcauchy(proposal)/mvcauchy(chain[i,])
  if(accept == T){chain[i+1,]<-proposal}
  else{chain[i+1,]<-chain[i,]}
}

par(mfrow=c(1,2))
plot(chain[,1],type='l')
plot(chain[,2],type='l')

par(mfrow=c(1,2))
plot(chain[,1]~chain[,2],type='l')

plot(density(chain[,1][1000:50000]),xlim=c(-5,5),ylim=c(0,0.4))
##cauchy simulate gamma
rm(list=ls())
set.seed(12876553)
reps=50000

cauchy<-function(gamma,x = 2,theta=1){
  out <- 1/(pi*gamma*(1+((x-theta)/gamma)^2))
  return(out)
}
chain<-c(0.5)
for(i in 1:reps){
  proposal<-chain[i]+runif(1,min=-1,max=1)
  accept<-runif(1)<cauchy(proposal)/cauchy(chain[i])
  chain[i+1]<-ifelse(accept==T,proposal,chain[i])
}
plot(chain,type='l')
plot(density(chain[1000:50000]),ylim=c(0,0.05))
##M-H another sample
rm(list=ls())
set.seed(12130910)
mh.gamma <- function(n.sims, start, burnin, cand.sd, shape, rate) {
  theta.cur <- start
  chain <- c()
  
theta.update <- function(theta.cur, shape, rate) {
  theta.can <- rnorm(1, mean = theta.cur, sd = cand.sd)
  accept.prob <- dgamma(theta.can, shape = shape, rate = rate)/dgamma(theta.cur,shape = shape, rate = rate)
  if (runif(1) <= accept.prob) theta.can
  else theta.cur
}
for (i in 1:n.sims) {
    chain[i] <- theta.cur <- theta.update(theta.cur, shape = shape,rate = rate)
}
return(chain[(burnin + 1):n.sims])
}
##test
mh.chains <- mh.gamma(10000, start = 1, burnin = 1000, cand.sd = 2,shape = 1.7, rate = 4.4)
plot(mh.chains,type='l')
##Gibbs Sampling
rm(list=ls())
set.seed(5678909)
reps<-10000
##conditional pdf of x1 given x2
conditional<-function(x.2,mu.1,mu.2,sigma.1,sigma.2,rho){
  out<-rnorm(1,mean=mu.1+(sigma.1/sigma.2)*rho*(x.2-mu.2),sd=sqrt((1-rho^2)*sigma.1^2))
  return(out)
}

chain.1<-c(0)
chain.2<-c(0)
rho<-0.25

for(i in 1:reps){
  chain.1[i+1]<-conditional(chain.2[i],1,-1,0.5,0.35,0.25)
  chain.2[i+1]<-conditional(chain.1[i+1],-1,1,0.35,0.5,0.25)
}

library(mvtnorm)
cov<-0.25*0.5*0.35
samples<-rmvnorm(10000,mean=c(-1,1),sigma=matrix(data=c(0.5^2,cov,cov,0.35^2),ncol=2,nrow=2))
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