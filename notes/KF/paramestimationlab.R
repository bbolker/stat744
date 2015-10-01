## Parameter Estimation using th Kalman Filter
## Code written by Athinthra K S,
##                School of Computational Science and Engineering
##                McMaster University.

## Stats744 Class Excercise

## Change the parameters and observe the error plot
## y=a*x^2

func <- function(a,x){
  (a^2)*x^2+x+1
}

#initial guess
a0 <- 1
#variance of state
StaVariance <- 10

#Generate Data
ParamTrue <- 4
set.seed(1234)
datVariance <- 10
nObs <- 500
deltaX <- 0.01
nu <- rnorm(nObs, mean=0, sd=sqrt(datVariance)) 
y <- c( func(ParamTrue, (1:(nObs))*deltaX)) + nu

#Xdata
xdata <- (1:nObs)*deltaX
ParamEstimate <- rep(NA, nObs)

#Linearization
G <- function(a,x){2*a*x^2}

# Evolution error
Q <- StaVariance
# Observation error
R <-  0
# Prior
ak <- a0
Sigma <-  datVariance

for(i in 1:nObs){
  # Observation step
  xk <- (i)*deltaX
  yk <- func(ak,xk)
  
  # Prediction step
  ak <- ak+0  ## R??
  ek <- y[i]-yk
  Sigma <- Sigma+Q
  
  SigTermInv <- (G(ak, xk) %*% Sigma %*% G(ak, xk) + R)^(-1)
  K <- G(ak,xk) %*% Sigma %*% SigTermInv

  # Updating step
  ak <- ak+K*ek
  Sigma <- (1-K*G(ak, xk))*Sigma
  ParamEstimate[i] <- ak
}

# calculate error and plot
LogError <- log(abs(ParamEstimate-ParamTrue))
plot(LogError)
plot(ParamEstimate,ylim=c(-10,10),type="l")
abline(h=4,col="red")
