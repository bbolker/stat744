
# Idea and source code taken from 
#  http://www.magesblog.com/2015/01/extended-kalman-filter-example-in-r.html
#  Modified by Athinthra K S

logistF <- function(r, p, k, t, nu){
  k * p * exp(r*t) / (k + p * (exp(r*t) - 1))+nu
}

k <- 1000
p0 <- 100
r <- 0.2
deltaT <- 0.1
nObs = 250

# sample data:
set.seed(1234)
obsVariance <- 100
ProVariancePop <- 10
nuProPop <- rnorm(nObs, mean=0, sd=sqrt(ProVariancePop))

nuobs <- rnorm(nObs, mean=0, sd=sqrt(obsVariance)) 
pop <- p0
for (i in 2:nObs){
pop[i] <- logistF(r,pop[i-1] , k, deltaT, nuProPop[i])+ nuobs[i]
}

Estimate <- data.frame(Rate=rep(NA, nObs),
                       Population=rep(NA,nObs))

library(numDeriv)
f <- function(x, k, deltaT){
  c(r=x[1],logistF(r=x[1], p=x[2], k,deltaT,0 ))
}
H <- t(c(0, 1))

# Evolution error
Q <- diag(c(ProVariancePop, 0))
# Observation error
R <-  obsVariance
# Initialization
x <- c(r, p0)
P <-  diag(c(144, 25))

for(i in 1:nObs){
  # Observation
  xobs <- c(0, pop[i])
  y <- H %*% xobs
  # Update 
  PTermInv <- solve(H %*% P %*% t(H) + R)
  xf <- x + P %*% t(H) %*%  PTermInv %*% (y - H %*% x)
  P <- P -  P %*% t(H) %*% PTermInv %*% H %*% P
  
  Ft <- jacobian(f, x=x, k=k, deltaT=deltaT)   
  K <- Ft %*% P %*% t(H) %*% solve(H %*% P %*% t(H) + R)
  Estimate[i,] <- x
  
  # Predict
  x <- f(x=xf, k=k, deltaT=deltaT) + K %*% (y - H %*% xf)
  Sigma <- Ft %*% P %*% t(Ft) - K %*% H %*% P %*% t(Ft) +Q
}

# Plot output

time <- c(1:nObs)*deltaT
plot(y=pop, x=time, t='l', main="Population growth", 
     xlab="Time", ylab="Population")
lines(y=Estimate$Population, x=time, col="orange", lwd=2)
