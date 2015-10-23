
## stochastic update of the system
SIR_f1 <- function(X,params) {
  res <- with(as.list(c(X,params)), { ## R magic
     infprob <- 1-exp(-beta*I/N*dt)
     recoveryprob <- 1-exp(-gamma*dt)
     newinf <- rbinom(1,prob=infprob,size=S)
     newrecover <- rbinom(1,prob=recoveryprob,size=I)
     c(S=S-newinf,I=I+newinf+newrecover)  
  })
  return(res)
}

params0 <- c(beta=2,gamma=1,dt=1,N=100,report=0.5)
X0 <- c(S=99,I=1)
  
SIR_obslik <- function(Y,X,params)  {
   with(as.list(c(X,params)),
        dbinom(Y,I,prob=report)
   )
}
  
SIR_obslik(0,X0,params0)


