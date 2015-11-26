##' Basic chain binomial simulator
##' @param beta prob. of adequate contact per infective
##' @param population size
##' @param effprop initial effective proportion of population
##' @param i0 initial infected
##' @param t0 initial time (unused)
##' @param numobs ending time
##' @param seed random number seed
##' @param reporting observation probability (1 by default)
##' @return a data frame with columns (time, S, I, R) 
simCB <- function(beta = 0.02, N=100, effprop=0.9, i0=1,
                  t0=1, numobs=20, reporting=1, seed=NULL){
  
  ## *all* infecteds recover in the next time step
  
  if (!is.null(seed)) set.seed(seed)
  tvec <- seq(1,numobs)
  n <- length(tvec)
  I <- Iobs <- S <- R <- pSI <- numeric(n)
  
  ##Initial conditions
  N0 <- round(effprop*N)
  I[1] <- i0
  S[1] <- N0 - i0
  R[1] <- N-N0
  pSI[1] <- 1 - (1-beta)^I[1]
  Iobs[1] <- rbinom(1,prob=reporting,size=I[1])## Reed-Frost
  ## e.g. see http://depts.washington.edu/sismid09/software/Module_7/reedfrost.R
  ## or the somewhat lame Wikipedia page
  
  ## Generate the Unobserved process I, and observables:
  
  for (t in 2:n){
    I[t] <- rbinom(1,prob=pSI[t-1],size=S[t-1])
    S[t] <- S[t-1] - I[t]
    R[t] <- R[t-1] + I[t-1]
    pSI[t] <- 1 - (1-beta)^I[t]
    Iobs[t] <- rbinom(1,prob=reporting,size=I[t])
  }
  
  data.frame(time=tvec, S, I, R, Iobs)
  
}
