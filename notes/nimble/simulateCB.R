##simulate CB data
source('paramsCB.R')
source("CBsimulator.R")

sim <- simCB(beta=beta,N=N,effprop=effprop,i0=i0,reporting=reporting,
             numobs=numobs,seed=seed)

sim

data <- list(obs=sim$Iobs,
             N=N,
             i0=i0,
             numobs=nrow(sim),
             zerohack=zerohack)

##initial values -----
inits <- list(list(I = sim$I,
                   effprop=effprop,
                   beta = beta,
                   N0=N0,
                   reporting = reporting))

params = c('beta',
           'effprop',
           'reporting')



save.image(file="simdata.RData")