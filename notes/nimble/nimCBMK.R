library(nimble)

nimcode <- nimbleCode({
  ## inits
  reporting ~ dunif(0,1)
  effpropS ~ dunif(0,1)
  effpropI ~ dunif(0,1)
  beta ~ dunif(0,0.2)
  s0 ~ dbin(effpropS,pop)
  I[1] ~ dbin(effpropI,pop-s0)
  S[1] <- s0
  R[1] <- r0
  pSI[1] <- 1 - (1-beta)^I[1]
  obs[1] ~ dbin(reporting , I[1])
  
  for(t in 2:numobs){
    I[t] ~ dbin(pSI[t-1],S[t-1])
    S[t] <- S[t-1] - I[t]
    R[t] <- R[t-1] + I[t-1]
    pSI[t] <- 1 - (1-beta)^I[t]
    obs[t] ~ dbin(reporting,I[t])
  }})
