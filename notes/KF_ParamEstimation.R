#Parameter Estimation using Kalman Filter
#Code written by Athinthra K S,
#                School of Compuational Science and Engineering
#                McMaster University.

# Stats744 Class Excercise

# Change the parameters and observe the error plot
#y=a*x^2

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
nObs = 500
deltaX <- 0.01
nu <- rnorm(nObs, mean=0, sd=sqrt(datVariance)) 
y <- c( func(ParamTrue, (1:(nObs))*deltaX)) + nu

#Xdata
xdata <-c((1:nObs)*deltaX)
ParamEstimate <- (rep(NA, nObs))

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
  # Observation
  xk <- (i)*deltaX
  yk <- func(ak,xk)
  
  #Predict
  ak <- ak+0
  ek <- y[i]-yk
  Sigma <- Sigma+Q
  
  SigTermInv <- (G(ak, xk) %*% Sigma %*% G(ak, xk) + R)^(-1)
  K <- G(ak,xk) %*% Sigma %*% SigTermInv

  # Update
  ak <- ak+K*ek
  Sigma <- (1-K*G(ak, xk))*Sigma
  ParamEstimate[i] <- ak}

# calculate eror and plot
LogError <- log(abs(ParamEstimate-ParamTrue))
plot(LogError)