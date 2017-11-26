---
title: "Particle filtering lab"
date:  "20:31 29 October 2015"
---

To illustrate the practical usage of the basic particle filter described in the previous section and to assess its accuracy, we present here a simple example based on 100 observations simulated from a known Dynamic Linear Model. The data are generated from a local level model with system variance $W=1$, observation variance $V=2$, and initial state distribution $N(10,9)$. We save the observations 
in `y`. Note the use of `dlmForecast` to simulate from a given model.

Generate data:


```r
library("dlm")
## order=1 corresponds to a random walk:
## this just sets up the model
mod <- dlmModPoly(order=1,dV=2,dW=1,m0=10,C0=9)
n <- 100
set.seed(23)
## this simulates from the model
simData <- dlmForecast(mod=mod,nAhead=n,sampleNew=1)
## extract simulated data
y <- simData$newObs[[1]]
```

Basic particle filter parameters/initialization:


```r
N <- 1000
x <- matrix(NA_real_,n+1,N)
wt <- matrix(NA_real_,n,N)
m0 <- 10
c0 <- 9
m <-  m0
c <- c0
w <- 1
v <- 2
## Initial particles from the prior
x[1,] <- rnorm(N,mean=m[1],sd=sqrt(c[1]))
```

Simple bootstrap filter:

```r
for(i in 1:n) {
    ## weights from likelihood function
    wt[i,] <- dnorm(y[i],mean=x[i,],sd=sqrt(v))
    ## normalize weights
    ## (this step is not actually necessary: sample() will
    ##  automatically normalize the 'probs' argument)
    wt[i,] <- wt[i,]/sum(wt[i,])
    ## resample particles according to 
    ##   weights and advance them (using f1)
    ##   to get new particles
    x[i+1,] <- sample(x[i,],N,replace=TRUE,prob=wt[i,])+
        rnorm(N,mean=0,sd=sqrt(w))
}
```

Particle filter using optimal importance density:

```r
N_0 <- N/2
pfOut  <-  matrix(NA_real_, n + 1, N)
wt2 <-  matrix(NA_real_, n + 1, N)
importanceSd  <-  sqrt(drop(W(mod) - W(mod)^2 /
                              (W(mod) + V(mod))))
predSd  <-  sqrt(drop(W(mod) + V(mod)))
## Initialize sampling from the prior
pfOut[1,] <- rnorm(N, mean = m0(mod), sd = sqrt(C0(mod)))
wt2[1,] <- rep(1/N, N)
for (it in 2 : (n + 1)) {
    ## generate particles
    means <- pfOut[it - 1, ] + 
       W(mod)*(y[it - 1] - pfOut[it - 1, ]) /
              (W(mod) + V(mod))
    pfOut[it, ] <- rnorm(N, mean = means, sd = importanceSd)
    ## update the weights
    wt2[it, ] <- dnorm(y[it - 1], mean = pfOut[it-1,],
                       sd = predSd) * wt2[it-1,]
    wt2[it, ] <- wt2[it,]/sum(wt2[it,])
    ## resample, if needed
    N.eff <- 1 / crossprod(wt2[it,])
    if ( N.eff < N_0 ) {
        ## multinomial resampling
        index <- sample(N, N, replace=TRUE, prob=wt2[it, ])
        pfOut[it,] <- pfOut[it, index]
        wt2[it,] <- 1/N
    }
}
```

Compare exact (Kalman) filtering distribution with
naive and optimal particle (bootstrap) filters:



```r
## extract Kalman-filtered values
modFilt <- dlmFilter(y,mod)
KF_mean <- modFilt$m[-1]
KF_sd <- with(modFilt,sqrt(unlist(dlmSvd2var(U.C, D.C))))[-1]
## results from naive filter
x <- x[-1,]
PF_mean <- sapply(1:n,function(i)
    weighted.mean(x[i,], wt[i,]))
PF_sd <- sapply(1:n, function(i)
    sqrt(weighted.mean((x[i,]-PF_mean[i])^2,wt[i,])))
## results from optimal filter
pfOut <- pfOut[-1,]
wt2 <- wt2[-1,]
OPPF_mean <- sapply(1:n,function(i)
    weighted.mean(pfOut[i,], wt2[i,]))
OPPF_sd <- sapply(1:n, function(i)
    sqrt(weighted.mean((pfOut[i,]-OPPF_mean[i])^2,wt2[i,])))
```

Compare entire ensembles:

```r
par(las=1,bty="l")
matplot(x[-1,],type="p",pch=16,
         col=adjustcolor("black",alpha=0.1))
matpoints(pfOut[-1,],pch=16,
         col=adjustcolor("red",alpha=0.1))
lines(y[-1],col="cyan",lwd=2)
lines(KF_mean[-1],col="blue",lwd=2)
```

![plot of chunk env](figure/env-1.png) 

Hard to see the distribution: let's check it just for
$t=40$:


```r
plot(density(pfOut[40,]),main="",xlab="",col=2,xlim=c(5,20))
lines(density(x[40,]))
abline(v=y[40])
abline(v=KF_mean[40])
```

![plot of chunk plotdens](figure/plotdens-1.png) 

Plot summary statistics:

```r
par(mfrow=c(1,1),las=1)
lvec <- c("solid","dotted", "longdash")
cvec <- c("black","red","blue")
labs <- c("Kalman", "Naive Particle","Optimal Particle")
plot.ts(cbind(KF_mean, PF_mean, OPPF_mean),
        plot.type = "s",lty = lvec, col=cvec,
        ylab = expression(m[t]))
legend("topleft", labs,
       lty = lvec, col=cvec, bty = "n")
```

![plot of chunk qplot](figure/qplot-1.png) 

```r
plot.ts(cbind(KF_sd, PF_sd,OPPF_sd), plot.type = "s",
        lty = lvec,
        col=cvec, xlab = "", ylab = expression(sqrt(C[t])))
legend("right", labs,
       lty=lvec, col=cvec, bty = "n")
```

![plot of chunk qplot](figure/qplot-2.png) 

In our implementation of the optimal particle filter we set the number
of particles to 1000, and we use the optimal importance kernel as
importance transition density. For a Dynamic Linear Model this density
is easy to use both in terms of generating from it and for updating
the particle weights. To keep things simple, instead of the more
efficient residual resampling, we use plain multinomial resampling,
setting the threshold for a resampling step to 500, that is, whenever
the effective sample size drops below one half of the number of
particles, we resample.

For a completely specified dynamic linear model the Kalman filter can
be used to derive exact filtering means and variance. In the figures
above, we compare the exact filtering means and standard deviations,
obtained using the Kalman filter, with Monte Carlo approximation of
the same quantities obtained using the particle filter alorithm. In
terms of the filtering mean, the particle filters can give accurate
approximations at any time. The approximations to the filtering
standard deviations are less precise, although reasonably close to the
true values. The precision can be increased by increasing the number
of particles in the simulation.

## SIR model

As a less-trivial dynamical system, consider the following dynamical system
that models an epidemic outbreak in discrete time.

The state of the system is $\{S,I\}$, where $S$ is the current number of
susceptible individuals and $I$ is the number of infectious individuals.
The *hazard* (probability per unit time) that a susceptible will be infected
is $\beta I$, so the *per capita* probability of infection within a time step $\Delta t$
is $p_I(I) = 1-\exp(-\beta I/N \Delta t)$.  The hazard that an infected individual will
recover is $\gamma$ (so $p_R=1-\exp(-\gamma \Delta t)$).  Infected individuals
are observed with probability $p_C$.

$$
\begin{split}
\textrm{inf(t)} & \sim \textrm{Binom}(p_I, S(t)) \\
\textrm{rec(t)} & \sim \textrm{Binom}(p_R, I(t)) \\
S(t+1) & = S(t)-\textrm{inf}(t) \\
I(t+1) & = I(t)+\textrm{inf}(t)-\textrm{rec}(t) \\
I_{\textrm{obs}}(t) & \sim \textrm{Binom}(p_C, I(t))
\end{split}
$$

```r
SIR_f1 <- function(xstart,times,params,...) {
    ## in pomp, xstart, params are provided as _matrices_.
    ## if we want to use with() magic we need to transpose
    ## them and then turn them into data frames ...
    ff <- function(x) as.data.frame(t(x))
    nrep <- ncol(xstart)
    nvars <- nrow(xstart)
    res <- with(c(ff(xstart),ff(params)), { ## R magic
                    infprob      <- 1-exp(-beta*I/N*dt)
                    recoveryprob <- 1-exp(-gamma/N*dt)
                    newinf     <- rbinom(nrep,prob=infprob,size=S)
                    newrecover <- rbinom(nrep,prob=recoveryprob,size=I)
                    ## combine in same orientation as xstart ...
                    rbind(S=S-newinf,I=I+newinf-newrecover)
                })
    ## results need to be returned as a 3-dimensional array
    ## here we have assumed that only a single time step will be requested:
    ## this will cause problems if we try to use abc or synthetic likelihood
    ##  in pomp ...
    res2 <- array(c(xstart,res),dim=c(nvars,nrep,2),
                  dimnames=list(rownames(xstart),NULL,NULL))
  return(res2)
}

params1 <- c(beta=2,gamma=1,dt=1,N=50,pC=0.5,I.0=0.02)
X0 <- c(S=49,I=1)
 
SIR_obslik <- function(y,x,t,params,log=FALSE,...)  {
    d <- with(as.list(c(x,params)),
              dbinom(y,I,prob=pC,log=log)
              )
    ## if (any(is.na(d))) browser()
    return(d)
}
SIR_obslik(0,X0,t=0,params1)
```

```
## [1] 0.5
```

Run a simulation:

```r
set.seed(101)
nt <- 100
obsvals <- numeric(nt)
## assume we actually observe the first case
obsvals[1] <- X0["I"]
Xmat <- matrix(NA,ncol=2,nrow=nt,
               dimnames=list(NULL,names(X0)))
Xmat[1,] <- X0
for (i in 2:nt) {
    ## have to jump through a couple of extra hoops to get data in/out
    ## of pomp format ...
    Xmat[i,] <- SIR_f1(cbind(Xmat[i-1,]),i,cbind(params1))[,,2]
    obsvals[i] <- rbinom(1,prob=params1["pC"],size=Xmat[i,"I"])
}
```


```r
par(las=1,bty="l")
matplot(cbind(Xmat,obsvals),type="b",col=c(1,2,4),lty=1,
        pch=1:3,
        xlab="time",ylab="",
        xlim=c(0,20))
legend("topright",col=c(1,2,4),pch=1:3,c("S","I","I(obs)"))
```

![plot of chunk plotsim1](figure/plotsim1-1.png) 



## iterated filtering etc.

To use `pomp` for iterated filtering we need just a little bit more
machinery (most of the hard part was done in setting up the
simulation function in the weird way we did, which was to enable
`pomp`-compatibility ...)


```r
library("pomp")
transfun <- function(params,...) {
    params[c("beta","gamma")] <- log(params[c("beta","gamma")])
    params[c("pC","I.0")] <- qlogis(params[c("report","I.0")])
    return(params)
}
transfun_inv <- function(params,...) {
    params[c("beta","gamma")] <- exp(params[c("beta","gamma")])
    params[c("pC","I.0")] <- plogis(params[c("report","I.0")])
    return(params)
}
initfun <- function(params,t0,...) {
    with(as.list(params),
     {
         I0 <- ceiling(I.0*N)
         c(S=N-I0,I=I0)
     })}
```


```r
P1 <- pomp(data=obsvals,times=1:length(obsvals),
           t0=0,rprocess=SIR_f1,dmeasure=SIR_obslik,
           toEstimationScale=transfun,
           fromEstimationScale=transfun_inv,
           initializer=initfun
)
```


```r
system.time(m1 <- mif2(P1, Nmif = 10, start=params1, transform=TRUE,
     Np=1000, rw.sd(beta=0.1,gamma=0.1,pC=0.1),
     cooling.fraction.50=0.1))
```

```
## Error: in 'mif2': particle-filter error:Error : 'mif2.pfilter' error: 'dmeasure' returns non-finite value
```

```
## Timing stopped at: 0.056 0 0.06
```

```r
p1 <- pfilter(m1)  ## final filtering step
```

```
## Error in pfilter(m1): error in evaluating the argument 'object' in selecting a method for function 'pfilter': Error: object 'm1' not found
```

I picked the tuning parameters `rw.sd` and `cooling.fractions` more
or less arbitrarily ...  now can (begin to) use `plot(m1)` to look at
convergence diagnostics ...


```r
coef(p1)
```

```
## Error in coef(p1): error in evaluating the argument 'object' in selecting a method for function 'coef': Error: object 'p1' not found
```

