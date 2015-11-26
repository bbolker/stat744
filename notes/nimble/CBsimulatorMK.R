##' Basic chain binomial simulator
##' @param beta prob. of adequate contact per infective
##' @param effpropI initial infectives proportion
##' @param effpropS initial susceptibles proportion
##' @param t0 initial time (unused)
##' @param numobs ending time
##' @param seed random number seed
##' @param reporting observation probability (1 by default)
##' @return a data frame with columns (time, S, I, R)
##' @details This is a Reed-Frost model.  N=s0+i0 (not any-more CB? or Mike's CBS)
simCB <- function(beta = beta, pop = pop, effpropS = effpropS, effpropI = effpropI,
                  t0 = t0, numobs = numobs, reporting = reporting, seed = seed){
  
  ## BMB: change name to "chain-binomial" ? e.g., simCB? (done)
  ## *all* infecteds recover in the next time step
  
  ## default params: R0=beta*N=2 (does R0 still have the same meaning now that I switch things around? I think it is still the same.)
  if (!is.null(seed)) set.seed(seed)
  tvec <- seq(1,numobs)
  n <- length(tvec)
  I <- Iobs <- S <- R <- numeric(n)
  
  ##Initial conditions
  S[1] <- round(effpropS*pop)
  I[1] <- round(effpropI*(pop-S[1]))+1 ## at least 1 to work 
  R[1] <- 0
  Psi <- 1 - (1-beta)^I[1]
  Iobs[1] <- rbinom(1,prob=reporting,size=I[1])## Reed-Frost
  ## e.g. see http://depts.washington.edu/sismid09/software/Module_7/reedfrost.R
  ## or the somewhat lame Wikipedia page
  
  ## should we scale force of infection by N or not??
  ## if we don't scale _explicitly_ then R0 = beta*N
  
  ## Generate the Unobserved process I, and observables:

  for (t in 2:n){
    I[t] <- rbinom(1,prob=Psi,size=S[t-1])
    S[t] <- S[t-1] - I[t]
    R[t] <- R[t-1] + I[t-1]
    Psi <- 1 - (1-beta)^I[t]
    Iobs[t] <- rbinom(1,prob=reporting,size=I[t])
  }
  
  data.frame(time=tvec, S, I, R, Iobs)
  
}
