---
title: "Monday NIMBLE"
author: "Mike Li, Morgan Kain"
date:  "14:59 30 November 2015"
output: html_document
---


```r
library(knitr)
options(mc.cores = parallel::detectCores())
#opts_chunk$set(cache = TRUE)
```

## NIMBLE: Numerical Inference for statistical Models for Bayesian and Likelihood Estimation

NIMBLE is built in R but compiles your models and algorithms using C++ for speed <br />
NIMBLE is most commonly used for MCMC but can also be used to implement a series of other algorithms (e.g. particle filtering, MCEM) <br />
<br />
1. A system for writing statistical models flexibly, which is an extension of the BUGS language <br />
2. A library of algorithms such as MCMC. <br />
3. A language, called NIMBLE, embedded within and similar in style to R, for writing algorithms that operate on BUGS models. <br />
  
One of the most important concepts behind NIMBLE is to allow a combination of highlevel processing in R and low-level processing in compiled C++. <br />
<br />

##### Why NIMBLE?

1. Options (More customizable MCMC, ability to run JAGS models and STAN models, EM, particle filter) that leads to a more adaptable workflow <br />
2. User-defined functions and distributions – written as nimbleFunctions – can be used in model code.  <br />
3. Multiple parameterizations for distributions, similar to those in R, can be used. <br />
<br />
  e.g. normal distribution with BUGS parameter order: <br />
        x ~ dnorm(a + b * c, tau) <br />
       normal distribution with a named parameter: <br />
        y ~ dnorm(a + b * c, sd = sigma) <br />
<br />
4. Named parameters for distributions and functions, similar to R function calls, can be used. <br />
5. More flexible indexing of vector nodes within larger variables is allowed. For example one can place a multivariate normal vector arbitrarily within a higher-dimensional object, not just in the last index. <br />
6. More general constraints can be declared using dconstraint, which extends the concept of JAGS’ dinterval. <br />
<br />

#### Downloading, installing and loading NIMBLE

On Windows, you should download and install Rtools.exe available from http://cran. r-project.org/bin/windows/Rtools/.  <br />
On OS X, you should install Xcode.  <br />

After these are installed you can install NIMBLE in R using <br />
install.packages("nimble", repos = "http://r-nimble.org", type = "source") <br />

Please post about installation problems to the nimble-users Google group or email nimble.stats@gmail.com.

You will also need to download STAN using the following commands <br />
Sys.setenv(MAKEFLAGS = "-j4") <br />
install.packages("rstan", dependencies = TRUE) <br />
<br />

In total you will need the following pakages:


```r
library("nimble")
library("R2jags")
library("ggplot2")
library("nimble")
library("rstan")
library("igraph")
library("parallel")
library("mcmcplots")
library("lattice")
library("coda")
library("reshape2")
```

<br />
<br />

#### Things to know about working with NIMBLE

<b> Programming in NIMBLE involves a fundamental distinction between: </b> <br />
  1. the steps for an algorithm that need to happen only once, at the beginning, such as inspecting the model <br />
  2. the steps that need to happen each time a function is called, such as MCMC iterations. <br />
  <br />
    When one writes a nimbleFunction, each of these parts can be provided separately. 
<br />

Multiple parameterizations for distributions, similar to those in R, can be used.
NIMBLE calls non-stochastic nodes “deterministic”, whereas BUGS calls them “logical”. 
NIMBLE uses “logical” in the way R does, to refer to boolean (TRUE/FALSE) variables. <br />
Alternative models can be defined from the same model code by using if-then-else statements that are evaluated when the model is defined.

1. NIMBLE extracts all the declarations in the BUGS code to create a model definition. <br />
2. From the model definition, NIMBLE builds a working model in R. This can be used to manipulate variables and operate the model from R. Operating the model includes calculating, simulating, or querying the log probability value of model nodes. <br />
3. From the working model, NIMBLE generates customized C++ code representing the model, compiles the C++, loads it back into R, and provides an R object that interfaces to it. We often call the uncompiled model the “R-model” and the compiled model the “C-model.” <br />  
<br />

### Presentation Outline
The general outline for this presentation follows along with the NIMBLE users manual <br />
http://r-nimble.org/documentation-2 <br />
However, the model(s) used here are written by us <br />

##### Part 1
[1.1](#1.1) Build a chain binomial model in JAGS. Conduct parameter estimation <br />
[1.2](#1.2) Translate the model into NIBLE. Conduct parameter estimation <br />
\ \ \ \ \ [1.2.1](#1.2.1) Model exploration/conversion <br />
\ \ \ \ \ [1.2.2](#1.2.2) Create a basic MCMC specification for the chain binomial, compile and run the MCMC <br />
\ \ \ \ \ [1.2.3](#1.2.3) Small MCMC specification adjustments (more on this in Part 3) <br />
[1.3](#1.3) Compare the JAGS and NIMBLE results (parameter estimates, uncertainty, convergence, efficiency) <br />

##### Part 2
[2.1](#2.1) Translate the model using a "hybrid approach" (STAN does not allow for discrete latent variables) <br />
\ \ \ \ \ [2.1.1](#1.4.1) Conduct parameter estimation using JAGS and NIMBLE <br />
\ \ \ \ \ [2.1.2](#1.4.2) Run the hybrid model in STAN and compare the results from JAGS, NIMBLE and STAN <br />
[2.2](#2.2) Compare the NIMBLE Chain Binomial and STAN hybrid model <br />

##### Part 3
[3.1](#3.1) Expolore more fine-tuned adjustments that can be made in NIMBLE <br />
\ \ \ \ \ [3.1.1](#3.1.1)  NIMBLE functions (e.g. allows for the implementation of custom samplers) <br />
      
##### Part 4     
[4.1](#4.1) NIMBLE extras: <br />
\ \ \ \ \ [4.1.1](#4.1.1) Create, compile and run a Monte Carlo Expectation Maximization (MCEM) algorithm, which illustrates some of the flexibility NIMBLE provides to combine R and NIMBLE. <br />
\ \ \ \ \ [4.1.2](#4.1.2) Implement particle filtering for the chain binomial <br />
      
##### Part 5

[5.1](#5.1) Misc NIMBLE notes (truncated distributions, lifted nodes, logProb, multiple instances of the same model)

<br />

### Part 1

##### <a name="1.1"> 1.1 Build a chain binomial model in JAGS </a>
First step is to construct the simulator from which we will obtain our data <br />

Note: It will be important to set your current working directory to "../stat744/notes/NIMBLE" <br />

Set parameters and load the Chain Binomial simulator <br />


```r
beta <- 0.02
pop <- 100
effpropS <- 0.8
effpropI <- 0.2
reporting <- 0.5

s0 <- effpropS*pop
r0 <- 0
zerohack <- 0.001
numobs <- 12
nimtimevec <- c()
source("CBsimulatorMK.R")
```



```r
sim <- simCB(beta = beta, pop = pop, effpropS = effpropS, effpropI = effpropI, 
             t0 = 1, numobs = numobs, reporting = reporting, seed = 5)
sim
```

```
##    time  S  I  R Iobs
## 1     1 80  5  0    2
## 2     2 71  9  5    7
## 3     3 61 10 14    3
## 4     4 48 13 24    7
## 5     5 34 14 37   10
## 6     6 29  5 51    2
## 7     7 26  3 56    1
## 8     8 24  2 59    1
## 9     9 24  0 61    0
## 10   10 24  0 61    0
## 11   11 24  0 61    0
## 12   12 24  0 61    0
```

Take a peek at what this model produces

![plot of chunk unnamed-chunk-3](figure/unnamed-chunk-3-1.png) 

Set up the required arguments to run the JAGS model


```r
data <- list(obs = sim$Iobs,
             pop = pop,
             numobs = nrow(sim),
             r0 = r0)

inits <- list(list(
  I = sim$I*1,
  effpropS = effpropS - 0.1,
  effpropI = effpropI - 0.15,
  beta = beta + .05,
  reporting = reporting),
list(
  I = sim$I*1 + 1,
  effpropS = effpropS - 0.1,
  effpropI = effpropI + 0.2,
  beta = beta + .1,
  reporting = reporting),
list(
  I = sim$I*1 + 2,
  effpropS = effpropS,
  effpropI = effpropI,
  beta = beta - .008,
  reporting = reporting)
)

params = c("beta",
           "effpropS",
           "effpropI",
           "reporting")

#rjags::set.factory("bugs::Conjugate", FALSE, type="sampler")
```

Create the model and examine the MCMC algorithms that JAGS will use to sample <br />


```r
cbjagsmodel <- jags.model(data = data,
               inits = inits,
               file = "CB.bug",
               n.chains = length(inits))
```

```
## Compiling model graph
##    Resolving undeclared variables
##    Allocating nodes
##    Graph Size: 84
## 
## Initializing model
## Deleting model
```

```
## Error in jags.model(data = data, inits = inits, file = "CB.bug", n.chains = length(inits)): LOGIC ERROR:
## Unable to create conjugate sampler
## Please send a bug report to martyn_plummer@users.sourceforge.net
```

```r
list.samplers(cbjagsmodel)
```

```
## Error in inherits(object, "jags"): object 'cbjagsmodel' not found
```

Run some chains (could use coda::coda.samples from cbjagsmodel but here we will just run jags()) <br />


```r
coda.samples(cbjagsmodel, c("beta", "effpropS", "effpropI", "reporting"), 1000)
```

Run through jags <br />


```r
jagstime <- system.time(cbjags <- jags(data = data,
               inits = inits,
               param = params,
               model.file = "CB.bug",
               n.iter = 11000,
               n.burnin = 1000,
               n.thin = 20,
               n.chains = length(inits)))
```

```
## module glm loaded
```

```
## Compiling model graph
##    Resolving undeclared variables
##    Allocating nodes
##    Graph Size: 84
## 
## Initializing model
## Deleting model
```

```
## Error in jags.model(model.file, data = data, inits = init.values, n.chains = n.chains, : LOGIC ERROR:
## Unable to create conjugate sampler
## Please send a bug report to martyn_plummer@users.sourceforge.net
```

```
## Timing stopped at: 0.008 0 0.015
```


```r
cbjags
```

```
## Error in eval(expr, envir, enclos): object 'cbjags' not found
```

```r
xyplot(as.mcmc(cbjags))
```

```
## Error in as.mcmc(cbjags): object 'cbjags' not found
```

<br />
<br />

##### <a name="1.2"> 1.2 Build the NIMLE model </a>


```r
source('nimCBMK.R')
```

Set up the model. Here we need: Constants, Data, Initial Values, NIMBLE model object <br />


```r
nimCBdata <- list(obs = sim$Iobs)

nimCBcon <- list(numobs = numobs, pop = pop, r0 = r0)

nimCBinits <- list(I = sim$I,
                   effpropS = effpropS,
                   effpropI = effpropI,
                   beta = beta,
                   reporting = reporting,
                   s0 = s0)

nimtimevec[1] <- system.time(CBout <- nimbleModel(code = nimcode, 
                         name = 'CBout', 
                         constants = nimCBcon,
                         data = nimCBdata, 
                         inits = nimCBinits))[3]
```

```
## defining model...
## building model...
## setting data and initial values...
## checking model...   (use nimbleModel(..., check = FALSE) to skip model check)
## model building finished
```

<br />
<br />

##### <a name="1.2.1"> 1.2.1 Model exploration/conversion </a>


```r
CBout$getNodeNames()
```

```
##  [1] "reporting"            "effpropS"             "effpropI"            
##  [4] "beta"                 "R[1]"                 "s0"                  
##  [7] "lifted_d100_minus_s0" "S[1]"                 "I[1]"                
## [10] "pSI[1]"               "obs[1]"               "R[2]"                
## [13] "I[2]"                 "S[2]"                 "R[3]"                
## [16] "pSI[2]"               "obs[2]"               "I[3]"                
## [19] "S[3]"                 "R[4]"                 "pSI[3]"              
## [22] "obs[3]"               "I[4]"                 "S[4]"                
## [25] "R[5]"                 "pSI[4]"               "obs[4]"              
## [28] "I[5]"                 "S[5]"                 "R[6]"                
## [31] "pSI[5]"               "obs[5]"               "I[6]"                
## [34] "S[6]"                 "R[7]"                 "pSI[6]"              
## [37] "obs[6]"               "I[7]"                 "S[7]"                
## [40] "R[8]"                 "pSI[7]"               "obs[7]"              
## [43] "I[8]"                 "S[8]"                 "R[9]"                
## [46] "pSI[8]"               "obs[8]"               "I[9]"                
## [49] "S[9]"                 "R[10]"                "pSI[9]"              
## [52] "obs[9]"               "I[10]"                "S[10]"               
## [55] "R[11]"                "pSI[10]"              "obs[10]"             
## [58] "I[11]"                "S[11]"                "R[12]"               
## [61] "pSI[11]"              "obs[11]"              "I[12]"               
## [64] "S[12]"                "pSI[12]"              "obs[12]"
```

You can examine a single specific node using: <br />


```r
CBout[['I[2]']]
```

```
## [1] 9
```


```r
CBout$obs
```

```
##  [1]  2  7  3  7 10  2  1  1  0  0  0  0
```

nimbleModel does its best to initialize a model, but let’s say you want to re-initialize I. <br />


```r
simulate(CBout, 'I') # using the current beta -- if we update beta to a new value this will change
CBout$I
```

```
##  [1]  6 11 14  9  9  6  3  1  3  0  0  0
```

And take a look at the log-prob <br />


```r
calculate(CBout, "I")
```

```
## [1] -19.42777
```

```r
CBout$logProb_I
```

```
##  [1] -2.215493 -2.758072 -2.368823 -2.217028 -2.191347 -2.213444 -1.450521
##  [8] -1.090584 -2.922461  0.000000  0.000000  0.000000
```

```r
I2lp <- CBout$nodes[['I[2]']]$calculate()
I2lp
```

```
## [1] -2.758072
```

or Calculate new log probabilities after updating I <br />


```r
CBout$obs
```

```
##  [1]  2  7  3  7 10  2  1  1  0  0  0  0
```

```r
getLogProb(CBout, 'obs')
```

```
## [1] -13.15753
```

```r
calculate(CBout, CBout$getDependencies(c("obs")))
```

```
## [1] -Inf
```

```r
CBout$logProb_obs
```

```
##  [1] -1.4508329 -1.8255263 -3.8069067 -2.6548057       -Inf -1.4508329
##  [7] -0.9808293 -0.6931472 -2.0794415  0.0000000  0.0000000  0.0000000
```

We can also look at the dependencies to make sense of what is going on <br />


```r
par(mfrow = c(1,1))
plot(CBout$graph)
```

![plot of chunk unnamed-chunk-17](figure/unnamed-chunk-17-1.png) 


```r
CBout$getDependencies(c("beta"))
```

```
##  [1] "beta"    "pSI[1]"  "I[2]"    "pSI[2]"  "I[3]"    "pSI[3]"  "I[4]"   
##  [8] "pSI[4]"  "I[5]"    "pSI[5]"  "I[6]"    "pSI[6]"  "I[7]"    "pSI[7]" 
## [15] "I[8]"    "pSI[8]"  "I[9]"    "pSI[9]"  "I[10]"   "pSI[10]" "I[11]"  
## [22] "pSI[11]" "I[12]"   "pSI[12]"
```


```r
CBout$getDependencies(c("beta"), determOnly = TRUE)
```

```
##  [1] "pSI[1]"  "pSI[2]"  "pSI[3]"  "pSI[4]"  "pSI[5]"  "pSI[6]"  "pSI[7]" 
##  [8] "pSI[8]"  "pSI[9]"  "pSI[10]" "pSI[11]" "pSI[12]"
```

We will return to nimbleFunctions later -- but here is an initial example nimbleFunction that will simulate multiple values for a designated set of nodes and calculate every part of the model that depends on them <br />


```r
simNodesMany <- nimbleFunction( setup = function(model, nodes) {
        mv <- modelValues(model)
        deps <- model$getDependencies(nodes)
        allNodes <- model$getNodeNames()
},
run = function(n = integer()) {
  resize(mv, n) 
  for(i in 1:n) {
            simulate(model, nodes)
            calculate(model, deps)
            copy(from = model, nodes = allNodes,
to = mv, rowTo = i, logProb = TRUE) }
})
```


```r
outI <- simNodesMany(CBout, "I")

outI$run(1)

outI$mv[["logProb_obs"]]
```

```
## [[1]]
##  [1] -1.4508329       -Inf -2.9241386 -2.6548057 -3.3549215 -1.1631508
##  [7] -1.8562980       -Inf -0.6931472  0.0000000  0.0000000  0.0000000
```

<br />
<br />

##### <a name="1.2.2"> 1.2.2 Compile the C++ model, build the MCMC and Run </a>


```r
nimtimevec[2] <- system.time(CBoutC <- compileNimble(CBout))[3]
```

Configure the MCMC with the default options (we will return to customizing this setup later) <br />


```r
nimtimevec[3] <- system.time(CBoutSpec <- configureMCMC(CBout, print = TRUE))[3]
```

```
## [1] RW sampler: reporting,  adaptive: TRUE,  adaptInterval: 200,  scale: 1
## [2] RW sampler: effpropS,  adaptive: TRUE,  adaptInterval: 200,  scale: 1
## [3] RW sampler: effpropI,  adaptive: TRUE,  adaptInterval: 200,  scale: 1
## [4] RW sampler: beta,  adaptive: TRUE,  adaptInterval: 200,  scale: 1
## [5] slice sampler: s0,  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
## [6] slice sampler: I[1],  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
## [7] slice sampler: I[2],  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
## [8] slice sampler: I[3],  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
## [9] slice sampler: I[4],  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
## [10] slice sampler: I[5],  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
## [11] slice sampler: I[6],  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
## [12] slice sampler: I[7],  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
## [13] slice sampler: I[8],  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
## [14] slice sampler: I[9],  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
## [15] slice sampler: I[10],  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
## [16] slice sampler: I[11],  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
## [17] slice sampler: I[12],  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
```

Add chain monitors for the parameters of interest and add thinning <br />


```r
CBoutSpec$addMonitors(c("beta", "effpropS", "effpropI", "reporting"))
```

```
## thin = 1: reporting, effpropS, effpropI, beta
```

```r
CBoutSpec$setThin(20)
```

```
## thin = 20: reporting, effpropS, effpropI, beta
```

Build the MCMC <br />


```r
nimtimevec[4] <- system.time(CBoutMCMC <- buildMCMC(CBoutSpec))[3]

nimtimevec[5] <- system.time(CBoutMCMC <- compileNimble(CBoutMCMC, project = CBout, resetFunctions = TRUE))[3]
```


```r
niter <- 11000

set.seed(0)
nimtimevec[6] <- system.time(CBoutMCMC$run(niter))[3]
```

```
## warning: problem initializing stochastic node, logProb less than -1e12
```

```r
  # mcmc$run(niter, reset = FALSE) can be used to add more iterations
```

Quick peek at time required. Below we will take a look at efficiency using a convenient coda function <br />

Gross time required <br />


```r
jagstime[3]
```

```
## Error in eval(expr, envir, enclos): object 'jagstime' not found
```

```r
sum(nimtimevec[1:6], na.rm = TRUE)
```

```
## [1] 17.861
```

```r
nimtimevec[6]
```

```
## [1] 1.642
```

Efficiency (Net time in a sense) <br />


```r
samples <- as.matrix(CBoutMCMC$mvSamples)

head(samples)
```

```
##            beta  effpropI  effpropS reporting
## [1,] 0.03464681 0.1772207 0.5206537 0.5674668
## [2,] 0.03464681 0.1772207 0.5206537 0.6064857
## [3,] 0.04639885 0.1131511 0.5206537 0.5892586
## [4,] 0.04639885 0.1131511 0.5313764 0.6099658
## [5,] 0.04639885 0.1131511 0.5313764 0.6371056
## [6,] 0.04639885 0.0936791 0.4771068 0.7569950
```

```r
jags_eff <- effectiveSize(as.mcmc.list(as.mcmc(cbjags))) / nimtimevec[1]
```

```
## Error in as.mcmc(cbjags): object 'cbjags' not found
```

```r
nim_eff <- effectiveSize(as.mcmc.list(as.mcmc(samples))) / nimtimevec[6]

jags_eff
```

```
## Error in eval(expr, envir, enclos): object 'jags_eff' not found
```

```r
nim_eff
```

```
##      beta  effpropI  effpropS reporting 
##  39.11720  53.95131  30.00288  52.03887
```


![plot of chunk unnamed-chunk-29](figure/unnamed-chunk-29-1.png) 

Look at the correlation in the chains


```r
  acf(samples[, "beta"])
```

![plot of chunk unnamed-chunk-30](figure/unnamed-chunk-30-1.png) 

```r
  acf(samples[, "reporting"])
```

![plot of chunk unnamed-chunk-30](figure/unnamed-chunk-30-2.png) 

```r
  acf(samples[, "effpropS"])
```

![plot of chunk unnamed-chunk-30](figure/unnamed-chunk-30-3.png) 

```r
  acf(samples[, "effpropI"])
```

![plot of chunk unnamed-chunk-30](figure/unnamed-chunk-30-4.png) 

<br />
<br />

##### <a name="1.2.3"> 1.2.3 Small MCMC specification adjustment </a>

A few undesirable results here... we can add a block sampler to decrease correlation <br />

Take a look at the samplers being used <br />


```r
CBoutSpec$getSamplers()
```

```
## [1]  RW sampler: reporting,  adaptive: TRUE,  adaptInterval: 200,  scale: 1
## [2]  RW sampler: effpropS,  adaptive: TRUE,  adaptInterval: 200,  scale: 1
## [3]  RW sampler: effpropI,  adaptive: TRUE,  adaptInterval: 200,  scale: 1
## [4]  RW sampler: beta,  adaptive: TRUE,  adaptInterval: 200,  scale: 1
## [5]  slice sampler: s0,  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
## [6]  slice sampler: I[1],  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
## [7]  slice sampler: I[2],  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
## [8]  slice sampler: I[3],  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
## [9]  slice sampler: I[4],  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
## [10] slice sampler: I[5],  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
## [11] slice sampler: I[6],  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
## [12] slice sampler: I[7],  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
## [13] slice sampler: I[8],  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
## [14] slice sampler: I[9],  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
## [15] slice sampler: I[10],  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
## [16] slice sampler: I[11],  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
## [17] slice sampler: I[12],  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
```
  

```r
CBoutSpec$addSampler(target = c('effpropS', 'effpropI'), type = 'RW_block',
                      control = list(adaptInterval = 10000))
```

```
## [18] RW_block sampler: effpropS, effpropI,  adaptive: TRUE,  adaptScaleOnly: FALSE,  adaptInterval: 10000,  scale: 1,  propCov: identity
```


```r
CBoutSpec$setThin(20)
```

```
## thin = 20: reporting, effpropS, effpropI, beta
```


```r
CBoutMCMC <- buildMCMC(CBoutSpec)
```


```r
CBoutMCMC <- compileNimble(CBoutMCMC, project  = CBout, resetFunctions = TRUE)
```


```r
nimtimevec[7] <- system.time(CBoutMCMC$run(11000))[3]
samplesNew <- as.matrix(CBoutMCMC$mvSamples)
```

Check for an imporvement


```r
  acf(samplesNew[, "effpropS"])
```

![plot of chunk unnamed-chunk-37](figure/unnamed-chunk-37-1.png) 

```r
  acf(samplesNew[, "effpropI"])
```

![plot of chunk unnamed-chunk-37](figure/unnamed-chunk-37-2.png) 

```r
  plot(samplesNew[ , 'effpropS'], type = 'l', xlab = 'iteration')
```

![plot of chunk unnamed-chunk-37](figure/unnamed-chunk-37-3.png) 

```r
  plot(samplesNew[ , 'effpropI'], type = 'l', xlab = 'iteration')
```

![plot of chunk unnamed-chunk-37](figure/unnamed-chunk-37-4.png) 


```r
nim_eff2 <- effectiveSize(as.mcmc.list(as.mcmc(samplesNew))) / nimtimevec[7]

nim_eff
```

```
##      beta  effpropI  effpropS reporting 
##  39.11720  53.95131  30.00288  52.03887
```

```r
nim_eff2
```

```
##      beta  effpropI  effpropS reporting 
##  84.57268  68.09988  49.99110  81.55782
```

NIMBLE allows for specification of samplers by parameter or node by node (NIMBLE included or user created) <br />

e.g. <br />


```r
CBoutSpec$removeSamplers(c("beta", "effpropS", "effpropI", "reporting"), print = TRUE)
CBoutSpec$addSampler("beta", type = "slice", print = TRUE)
CBoutSpec$addSampler("effpropS", type = "slice", print = TRUE)
CBoutSpec$addSampler("effpropI", type = "slice", print = TRUE)
CBoutSpec$addSampler("reporting", type = "slice", print = TRUE)
```

<br />
<br />

##### <a name="1.3"> 1.3 Compare the JAGS and NIMBLE results </a>

We can also compare the NIMBLE model simultaneously with the JAGS model using MCMCsuite() <br />

Be warned: running this code with "makePlot = TRUE" will produce about 6-8 graphs which will all pop up in separate windows! <br />


```r
source("simulateCB.R")
options(mc.cores = parallel::detectCores())
source('nimCB.R')

nimCBdata <- list(obs=sim$Iobs)
nimCBcon <- list(numobs=numobs,N=N,i0=i0)

nimCBinits <- list(I=sim$I,
                   effprop=effprop,
                   beta=beta,
                   reporting=reporting,
                   N0=N0
)
NimbleCB <- MCMCsuite(code=nimcode,
                   data=nimCBdata,
                   inits=nimCBinits,
                   constants=nimCBcon,
                   MCMCs=c("jags","nimble"),
                   monitors=c("beta","reporting","effprop"),
                   calculateEfficiency=TRUE,
                   niter=iterations,
                   makePlot=FALSE,
                   savePlot=FALSE,
                   setSeed = 5)
```

```
## defining model...
## building model...
## setting data and initial values...
## checking model...   (use nimbleModel(..., check = FALSE) to skip model check)
## model building finished
```

```
## Compiling model graph
##    Resolving undeclared variables
##    Allocating nodes
##    Graph Size: 61
## 
## Initializing model
## Deleting model
```

```
## Error in jags.model(file = modelFileName, data = constantsAndData, inits = inits, : LOGIC ERROR:
## Unable to create conjugate sampler
## Please send a bug report to martyn_plummer@users.sourceforge.net
```

```r
print(NimbleCB$timing)
```

```
## Error in print(NimbleCB$timing): object 'NimbleCB' not found
```

```r
print(NimbleCB$summary)
```

```
## Error in print(NimbleCB$summary): object 'NimbleCB' not found
```

It is kind of scary considering Nimble is suppose to be this awesome super fast magic box. Before we learn Nimble, let's take a few minutes learning JAGS and samplers.



```r
rjags::set.factory("bugs::Conjugate", FALSE, type="sampler")
```

```
## NULL
```

```r
Jagsmod <- jags.model(file="CB2.bug",data=data,inits=inits)
```

```
## Warning in jags.model(file = "CB2.bug", data = data, inits = inits): Unused
## variable "zerohack" in data
```

```
## Compiling model graph
##    Resolving undeclared variables
##    Allocating nodes
##    Graph Size: 61
## 
## Initializing model
## 
##   |                                                          |                                                  |   0%  |                                                          |+                                                 |   2%  |                                                          |++                                                |   4%  |                                                          |+++                                               |   6%  |                                                          |++++                                              |   8%  |                                                          |+++++                                             |  10%  |                                                          |++++++                                            |  12%  |                                                          |+++++++                                           |  14%  |                                                          |++++++++                                          |  16%  |                                                          |+++++++++                                         |  18%  |                                                          |++++++++++                                        |  20%  |                                                          |+++++++++++                                       |  22%  |                                                          |++++++++++++                                      |  24%  |                                                          |+++++++++++++                                     |  26%  |                                                          |++++++++++++++                                    |  28%  |                                                          |+++++++++++++++                                   |  30%  |                                                          |++++++++++++++++                                  |  32%  |                                                          |+++++++++++++++++                                 |  34%  |                                                          |++++++++++++++++++                                |  36%  |                                                          |+++++++++++++++++++                               |  38%  |                                                          |++++++++++++++++++++                              |  40%  |                                                          |+++++++++++++++++++++                             |  42%  |                                                          |++++++++++++++++++++++                            |  44%  |                                                          |+++++++++++++++++++++++                           |  46%  |                                                          |++++++++++++++++++++++++                          |  48%  |                                                          |+++++++++++++++++++++++++                         |  50%  |                                                          |++++++++++++++++++++++++++                        |  52%  |                                                          |+++++++++++++++++++++++++++                       |  54%  |                                                          |++++++++++++++++++++++++++++                      |  56%  |                                                          |+++++++++++++++++++++++++++++                     |  58%  |                                                          |++++++++++++++++++++++++++++++                    |  60%  |                                                          |+++++++++++++++++++++++++++++++                   |  62%  |                                                          |++++++++++++++++++++++++++++++++                  |  64%  |                                                          |+++++++++++++++++++++++++++++++++                 |  66%  |                                                          |++++++++++++++++++++++++++++++++++                |  68%  |                                                          |+++++++++++++++++++++++++++++++++++               |  70%  |                                                          |++++++++++++++++++++++++++++++++++++              |  72%  |                                                          |+++++++++++++++++++++++++++++++++++++             |  74%  |                                                          |++++++++++++++++++++++++++++++++++++++            |  76%  |                                                          |+++++++++++++++++++++++++++++++++++++++           |  78%  |                                                          |++++++++++++++++++++++++++++++++++++++++          |  80%  |                                                          |+++++++++++++++++++++++++++++++++++++++++         |  82%  |                                                          |++++++++++++++++++++++++++++++++++++++++++        |  84%  |                                                          |+++++++++++++++++++++++++++++++++++++++++++       |  86%  |                                                          |++++++++++++++++++++++++++++++++++++++++++++      |  88%  |                                                          |+++++++++++++++++++++++++++++++++++++++++++++     |  90%  |                                                          |++++++++++++++++++++++++++++++++++++++++++++++    |  92%  |                                                          |+++++++++++++++++++++++++++++++++++++++++++++++   |  94%  |                                                          |++++++++++++++++++++++++++++++++++++++++++++++++  |  96%  |                                                          |+++++++++++++++++++++++++++++++++++++++++++++++++ |  98%  |                                                          |++++++++++++++++++++++++++++++++++++++++++++++++++| 100%
```

```r
list.samplers(Jagsmod)
```

```
## $DiscreteSlicer
## [1] "I[10]"
## 
## $DiscreteSlicer
## [1] "I[9]"
## 
## $DiscreteSlicer
## [1] "I[8]"
## 
## $DiscreteSlicer
## [1] "I[7]"
## 
## $DiscreteSlicer
## [1] "I[6]"
## 
## $DiscreteSlicer
## [1] "I[5]"
## 
## $DiscreteSlicer
## [1] "I[4]"
## 
## $DiscreteSlicer
## [1] "I[3]"
## 
## $DiscreteSlicer
## [1] "I[2]"
## 
## $FiniteMethod
## [1] "I[1]"
## 
## $DiscreteSlicer
## [1] "N0"
## 
## $RealSlicer
## [1] "beta"
## 
## $RealSlicer
## [1] "effprop"
## 
## $RealSlicer
## [1] "reporting"
```

```r
slicetime <- system.time(JagsCB <- jags(data=data,
               inits=inits,
               param = params,
               model.file = "CB2.bug",
               n.iter = iterations,
               n.chains = length(inits),
               n.thin = 1,
               n.burnin = 2000
               ))
```

```
## Warning in jags.model(model.file, data = data, inits = init.values,
## n.chains = n.chains, : Unused variable "zerohack" in data
```

```
## Compiling model graph
##    Resolving undeclared variables
##    Allocating nodes
##    Graph Size: 61
## 
## Initializing model
## 
##   |                                                          |                                                  |   0%  |                                                          |++++                                              |   8%  |                                                          |++++++++                                          |  16%  |                                                          |++++++++++++                                      |  24%  |                                                          |++++++++++++++++                                  |  32%  |                                                          |++++++++++++++++++++                              |  40%  |                                                          |++++++++++++++++++++++++                          |  48%  |                                                          |++++++++++++++++++++++++++++                      |  56%  |                                                          |++++++++++++++++++++++++++++++++                  |  64%  |                                                          |++++++++++++++++++++++++++++++++++++              |  72%  |                                                          |++++++++++++++++++++++++++++++++++++++++          |  80%  |                                                          |++++++++++++++++++++++++++++++++++++++++++++      |  88%  |                                                          |++++++++++++++++++++++++++++++++++++++++++++++++  |  96%  |                                                          |++++++++++++++++++++++++++++++++++++++++++++++++++| 100%
##   |                                                          |                                                  |   0%  |                                                          |*                                                 |   3%  |                                                          |***                                               |   5%  |                                                          |****                                              |   8%  |                                                          |*****                                             |  11%  |                                                          |*******                                           |  13%  |                                                          |********                                          |  16%  |                                                          |*********                                         |  19%  |                                                          |***********                                       |  21%  |                                                          |************                                      |  24%  |                                                          |*************                                     |  27%  |                                                          |***************                                   |  29%  |                                                          |****************                                  |  32%  |                                                          |*****************                                 |  35%  |                                                          |*******************                               |  37%  |                                                          |********************                              |  40%  |                                                          |*********************                             |  43%  |                                                          |***********************                           |  45%  |                                                          |************************                          |  48%  |                                                          |*************************                         |  51%  |                                                          |***************************                       |  53%  |                                                          |****************************                      |  56%  |                                                          |*****************************                     |  59%  |                                                          |*******************************                   |  61%  |                                                          |********************************                  |  64%  |                                                          |*********************************                 |  67%  |                                                          |***********************************               |  69%  |                                                          |************************************              |  72%  |                                                          |*************************************             |  75%  |                                                          |***************************************           |  77%  |                                                          |****************************************          |  80%  |                                                          |*****************************************         |  83%  |                                                          |*******************************************       |  85%  |                                                          |********************************************      |  88%  |                                                          |*********************************************     |  91%  |                                                          |***********************************************   |  93%  |                                                          |************************************************  |  96%  |                                                          |************************************************* |  99%  |                                                          |**************************************************| 100%
```

```r
print(JagsCB)
```

```
## Inference for Bugs model at "CB2.bug", fit using jags,
##  1 chains, each with 8000 iterations (first 2000 discarded)
##  n.sims = 6000 iterations saved
##           mu.vect sd.vect   2.5%    25%    50%    75%  97.5%
## beta        0.020   0.001  0.018  0.019  0.020  0.020  0.022
## effprop     0.799   0.013  0.773  0.790  0.799  0.807  0.823
## reporting   0.796   0.014  0.767  0.786  0.796  0.805  0.823
## deviance   19.525   1.522 18.203 18.382 18.979 20.172 23.606
## 
## DIC info (using the rule, pD = var(deviance)/2)
## pD = 1.2 and DIC = 20.7
## DIC is an estimate of expected predictive error (lower deviance is better).
```

```r
slice_eff <- effectiveSize(as.mcmc(JagsCB))/slicetime[3]


rjags::set.factory("bugs::Conjugate", TRUE, type="sampler")
```

```
## NULL
```

```r
Jagsmod2 <- jags.model(file="CB2.bug",data=data,inits=inits)
```

```
## Warning in jags.model(file = "CB2.bug", data = data, inits = inits): Unused
## variable "zerohack" in data
```

```
## Compiling model graph
##    Resolving undeclared variables
##    Allocating nodes
##    Graph Size: 61
## 
## Initializing model
## Deleting model
```

```
## Error in jags.model(file = "CB2.bug", data = data, inits = inits): LOGIC ERROR:
## Unable to create conjugate sampler
## Please send a bug report to martyn_plummer@users.sourceforge.net
```

```r
list.samplers(Jagsmod2)
```

```
## Error in inherits(object, "jags"): object 'Jagsmod2' not found
```

```r
conjutime <- system.time(JagsCB2 <- jags(data=data,
               inits=inits,
               param = params,
               model.file = "CB2.bug",
               n.iter = iterations,
               n.chains = length(inits),
               n.thin = 1,
               n.burnin = 2000
               ))
```

```
## Warning in jags.model(model.file, data = data, inits = init.values,
## n.chains = n.chains, : Unused variable "zerohack" in data
```

```
## Compiling model graph
##    Resolving undeclared variables
##    Allocating nodes
##    Graph Size: 61
## 
## Initializing model
## Deleting model
```

```
## Error in jags.model(model.file, data = data, inits = init.values, n.chains = n.chains, : LOGIC ERROR:
## Unable to create conjugate sampler
## Please send a bug report to martyn_plummer@users.sourceforge.net
```

```
## Timing stopped at: 0 0.004 0.006
```

```r
print(JagsCB)
```

```
## Inference for Bugs model at "CB2.bug", fit using jags,
##  1 chains, each with 8000 iterations (first 2000 discarded)
##  n.sims = 6000 iterations saved
##           mu.vect sd.vect   2.5%    25%    50%    75%  97.5%
## beta        0.020   0.001  0.018  0.019  0.020  0.020  0.022
## effprop     0.799   0.013  0.773  0.790  0.799  0.807  0.823
## reporting   0.796   0.014  0.767  0.786  0.796  0.805  0.823
## deviance   19.525   1.522 18.203 18.382 18.979 20.172 23.606
## 
## DIC info (using the rule, pD = var(deviance)/2)
## pD = 1.2 and DIC = 20.7
## DIC is an estimate of expected predictive error (lower deviance is better).
```

```r
print(JagsCB2)
```

```
## Error in print(JagsCB2): object 'JagsCB2' not found
```

```r
conju_eff <- effectiveSize(as.mcmc(JagsCB2))/conjutime[3]
```

```
## Error in as.mcmc(JagsCB2): object 'JagsCB2' not found
```

```r
slicetime
```

```
##    user  system elapsed 
##   1.360   0.004   1.369
```

```r
conjutime
```

```
## Error in eval(expr, envir, enclos): object 'conjutime' not found
```

```r
slice_eff
```

```
##      beta  deviance   effprop reporting 
## 2784.9328  133.7782 2664.2149 2827.4447
```

```r
conju_eff
```

```
## Error in eval(expr, envir, enclos): object 'conju_eff' not found
```

Wow, that is pretty cool. Let's try to do it in Nimble. 


```r
NimbleCB <- MCMCsuite(code=nimcode,
                   data=nimCBdata,
                   inits=nimCBinits,
                   constants=nimCBcon,
                   MCMCs=c("jags","nimble","nimble_slice"),
                   monitors=c("beta","reporting","effprop"),
                   calculateEfficiency=TRUE,
                   niter=iterations,
                   makePlot=FALSE,
                   savePlot=FALSE,
                   setSeed = 5)
```

```
## defining model...
## building model...
## setting data and initial values...
## checking model...   (use nimbleModel(..., check = FALSE) to skip model check)
## model building finished
```

```
## Compiling model graph
##    Resolving undeclared variables
##    Allocating nodes
##    Graph Size: 61
## 
## Initializing model
## Deleting model
```

```
## Error in jags.model(file = modelFileName, data = constantsAndData, inits = inits, : LOGIC ERROR:
## Unable to create conjugate sampler
## Please send a bug report to martyn_plummer@users.sourceforge.net
```

```r
print(NimbleCB$timing)
```

```
## Error in print(NimbleCB$timing): object 'NimbleCB' not found
```

```r
print(NimbleCB$summary)
```

```
## Error in print(NimbleCB$summary): object 'NimbleCB' not found
```

Why is default Nimble underperforming? (vs Jags) Take my word, nimble-jags is NOT using conjugate samplers. Nimble slice turns all nodes to slice samplers, thus, nimble-jags and nimble slice is using the same sampler. As you can see Nimble slice is more efficient than JAGS.


```r
mod <- nimbleModel(code = nimcode, data=nimCBdata, inits=nimCBinits, constants=nimCBcon, name = "mod")
```

```
## defining model...
## building model...
## setting data and initial values...
## checking model...   (use nimbleModel(..., check = FALSE) to skip model check)
## model building finished
```

```r
temp <- compileNimble(mod) ## need to compile it once before recompiling changes
Cmod <- configureMCMC(mod,print=TRUE,useConjugacy = TRUE)
```

```
## [1] RW sampler: reporting,  adaptive: TRUE,  adaptInterval: 200,  scale: 1
## [2] RW sampler: effprop,  adaptive: TRUE,  adaptInterval: 200,  scale: 1
## [3] RW sampler: beta,  adaptive: TRUE,  adaptInterval: 200,  scale: 1
## [4] slice sampler: I[1],  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
## [5] slice sampler: N0,  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
## [6] slice sampler: I[2],  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
## [7] slice sampler: I[3],  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
## [8] slice sampler: I[4],  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
## [9] slice sampler: I[5],  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
## [10] slice sampler: I[6],  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
## [11] slice sampler: I[7],  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
## [12] slice sampler: I[8],  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
## [13] slice sampler: I[9],  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
## [14] slice sampler: I[10],  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
```

```r
Cmodslice <- configureMCMC(mod,print=TRUE,useConjugacy = TRUE, onlySlice = TRUE)
```

```
## [1] slice sampler: reporting,  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
## [2] slice sampler: effprop,  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
## [3] slice sampler: beta,  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
## [4] slice sampler: I[1],  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
## [5] slice sampler: N0,  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
## [6] slice sampler: I[2],  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
## [7] slice sampler: I[3],  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
## [8] slice sampler: I[4],  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
## [9] slice sampler: I[5],  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
## [10] slice sampler: I[6],  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
## [11] slice sampler: I[7],  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
## [12] slice sampler: I[8],  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
## [13] slice sampler: I[9],  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
## [14] slice sampler: I[10],  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
```

```r
Cmod$removeSamplers(c("reporting","beta","effprop"))
```

```
## [1]  slice sampler: I[1],  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
## [2]  slice sampler: N0,  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
## [3]  slice sampler: I[2],  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
## [4]  slice sampler: I[3],  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
## [5]  slice sampler: I[4],  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
## [6]  slice sampler: I[5],  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
## [7]  slice sampler: I[6],  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
## [8]  slice sampler: I[7],  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
## [9]  slice sampler: I[8],  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
## [10] slice sampler: I[9],  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
## [11] slice sampler: I[10],  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
```

```r
Cmod$addSampler(target = c("reporting","effprop"), type="RW_block")
```

```
## [12] RW_block sampler: reporting, effprop,  adaptive: TRUE,  adaptScaleOnly: FALSE,  adaptInterval: 200,  scale: 1,  propCov: identity
```

```r
Cmod$addSampler("beta",type="slice")
```

```
## [13] slice sampler: beta,  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
```

```r
Cmod$addMonitors(c("reporting","beta","effprop"))
```

```
## thin = 1: reporting, effprop, beta, I
```

```r
newMCMC <- buildMCMC(Cmod)
CnewMCMC <- compileNimble(newMCMC,project = mod, resetFunctions = TRUE)

Cnewtime <- system.time(CnewMCMC$run(iterations))
Cnewsample <- as.matrix(CnewMCMC$mvSamples)
effectiveSize(as.mcmc(Cnewsample[,c('beta','effprop','reporting')]))/Cnewtime[3]
```

```
##      beta   effprop reporting 
##  3220.052  1645.611  1275.205
```


```r
NimbleCB <- MCMCsuite(code=nimcode,
                   data=nimCBdata,
                   inits=nimCBinits,
                   constants=nimCBcon,
                   MCMCs=c("jags","nimble","nimble_slice","newMCMC"),
                   monitors=c("beta","reporting","effprop"),
                   MCMCdefs = list(
                     newMCMC = quote({
                     Cmod <- configureMCMC(mod,print=FALSE,useConjugacy = TRUE)
                     Cmod$removeSamplers(c("reporting","beta","effprop"))
                     Cmod$addSampler(target = c("reporting","effprop"), type="RW_block")
                     Cmod$addSampler("beta",type="slice")
                     Cmod
                   })),
                   calculateEfficiency=TRUE,
                   niter=iterations,
                   makePlot=FALSE,
                   savePlot=FALSE,
                   setSeed = 5)
```

```
## defining model...
## building model...
## setting data and initial values...
## checking model...   (use nimbleModel(..., check = FALSE) to skip model check)
## model building finished
```

```
## Compiling model graph
##    Resolving undeclared variables
##    Allocating nodes
##    Graph Size: 61
## 
## Initializing model
## Deleting model
```

```
## Error in jags.model(file = modelFileName, data = constantsAndData, inits = inits, : LOGIC ERROR:
## Unable to create conjugate sampler
## Please send a bug report to martyn_plummer@users.sourceforge.net
```

```r
print(NimbleCB$timing)
```

```
## Error in print(NimbleCB$timing): object 'NimbleCB' not found
```

```r
print(NimbleCB$summary)
```

```
## Error in print(NimbleCB$summary): object 'NimbleCB' not found
```


```r
source("nimCB2.R")
mod2 <- nimbleModel(code = nimcode, data=nimCBdata, inits=nimCBinits, constants = nimCBcon,
                    name= "mod2")
```

```
## defining model...
## building model...
## setting data and initial values...
## checking model...   (use nimbleModel(..., check = FALSE) to skip model check)
## model building finished
```

```r
Cmod2 <- configureMCMC(mod2,print=TRUE)
```

```
## [1] conjugate_dbeta sampler: reporting,  dependents_dbin: obs[1], obs[2], obs[3], obs[4], obs[5], obs[6], obs[7], obs[8], obs[9], obs[10]
## [2] conjugate_dbeta sampler: effprop,  dependents_dbin: N0
## [3] RW sampler: beta,  adaptive: TRUE,  adaptInterval: 200,  scale: 1
## [4] slice sampler: I[1],  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
## [5] slice sampler: N0,  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
## [6] slice sampler: I[2],  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
## [7] slice sampler: I[3],  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
## [8] slice sampler: I[4],  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
## [9] slice sampler: I[5],  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
## [10] slice sampler: I[6],  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
## [11] slice sampler: I[7],  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
## [12] slice sampler: I[8],  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
## [13] slice sampler: I[9],  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
## [14] slice sampler: I[10],  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
```

```r
NimbleCB2 <- MCMCsuite(code=nimcode,
                   data=nimCBdata,
                   inits=nimCBinits,
                   constants=nimCBcon,
                   MCMCs=c("jags","nimble","nimble_slice"),
                   monitors=c("beta","reporting","effprop"),
                   calculateEfficiency=TRUE,
                   niter=iterations,
                   makePlot=FALSE,
                   savePlot=FALSE,
                   setSeed = 5)
```

```
## defining model...
## building model...
## setting data and initial values...
## checking model...   (use nimbleModel(..., check = FALSE) to skip model check)
## model building finished
```

```
## Compiling model graph
##    Resolving undeclared variables
##    Allocating nodes
##    Graph Size: 61
## 
## Initializing model
## Deleting model
```

```
## Error in jags.model(file = modelFileName, data = constantsAndData, inits = inits, : LOGIC ERROR:
## Unable to create conjugate sampler
## Please send a bug report to martyn_plummer@users.sourceforge.net
```

```r
print(NimbleCB$timing)
```

```
## Error in print(NimbleCB$timing): object 'NimbleCB' not found
```

```r
print(NimbleCB2$timing)
```

```
## Error in print(NimbleCB2$timing): object 'NimbleCB2' not found
```

```r
print(NimbleCB2$summary)
```

```
## Error in print(NimbleCB2$summary): object 'NimbleCB2' not found
```

```r
mat1 <- as.array(NimbleCB$summary)
```

```
## Error in as.array(NimbleCB$summary): object 'NimbleCB' not found
```

```r
mat2 <- as.array(NimbleCB2$summary)
```

```
## Error in as.array(NimbleCB2$summary): object 'NimbleCB2' not found
```

```r
mat1 <- mat1[,"efficiency",]
```

```
## Error in eval(expr, envir, enclos): object 'mat1' not found
```

```r
mat2 <- mat2[,"efficiency",]
```

```
## Error in eval(expr, envir, enclos): object 'mat2' not found
```

```r
a1 <- melt(mat1)
```

```
## Error in melt(mat1): object 'mat1' not found
```

```r
a2 <- melt(mat2)
```

```
## Error in melt(mat2): object 'mat2' not found
```

```r
a1 <- cbind(a1,var3="NoConjugates")
```

```
## Error in cbind(a1, var3 = "NoConjugates"): object 'a1' not found
```

```r
a2 <- cbind(a2,var3="YesConjugates")
```

```
## Error in cbind(a2, var3 = "YesConjugates"): object 'a2' not found
```

```r
dat <- rbind(a1,a2)
```

```
## Error in rbind(a1, a2): object 'a1' not found
```

```r
ggplot(dat,aes(x=var3, y=value,group=interaction(Var1,Var2))) + geom_line(aes(color=interaction(Var1),linetype=Var2)) + geom_point(aes(color=Var1)) + theme_bw() + ylab('Efficiency') + xlab("speed hack")
```

```
## Error in ggplot(dat, aes(x = var3, y = value, group = interaction(Var1, : object 'dat' not found
```

MCMCsuite can also be used to compare models written in STAN which is described below <br />

<br />
<br />

##### <a name="2.1"> 2.1 "hybrid approach" </a> 

We must rewrite the model so that there are no discrete latent variables. We call this the "hybrid model" <br />
An asside -- Discrete Latent Variables: <br />
An additional asside -- Hamiltonian MCMC: <br />

But before we fit the model in STAN lets explore the hybrid model in NIMBLE <br />

NIMBLE allows us to compare the results of multiple models even if they have different parameterizations 
(e.g. Chain Binomial and the Hybrid Model) <br />


```r
data$obs <- data$obs + zerohack # Guarnantee that obs remains above 0 (important for the gamma)
data$zerohack <- zerohack

hybridjags <- jags(data = data,
               inits = inits,
               param = params,
               model.file = "hybrid.bug",
               n.iter = 8000,
               n.chains = length(inits))
```

##### <a name="2.1.1"> 2.1.1 Hybrid in JAGS and NIMBLE </a>


```r
source('nimhybrid.R')
```


```r
nimhydata <- list(obs = sim$Iobs + zerohack)
nimhycon <- list(numobs = numobs, pop = pop, r0 = r0, zerohack = zerohack)

nimhyinits <- list(I = sim$I + zerohack,
                   effpropS = effpropS,
                   effpropI = effpropI,
                   beta = beta,
                   reporting = reporting,
                   s0 = s0)
```


```r
nimcb <- MCMCsuite(code = nimcode,
                   data = nimhydata,
                   inits = nimhyinits,
                   constants = nimhycon,
                   MCMCs = c("jags", "nimble"),
                   monitors = c("beta", "reporting", "effpropS", "effpropI"),
                   niter = 10000,
                   makePlot = FALSE,
                   savePlot = FALSE)
```

##### <a name="2.1.2"> 2.1.2 Hybrid in JAGS, NIMBLE and STAN </a>

Run the STAN model <br />


```r
stantime <- system.time (s1 <- stan(file='hybrid.stan', data = data, init = inits,
           pars=c("beta", "reporting", "effpropS", "effpropI", "I"), iter = 8000,
           seed = 1001, chains = length(inits)))
```

Compare all three methods using the hybrid model <br />


```r
nimhydata <- list(obs = sim$Iobs + zerohack)
nimhycon <- list(numobs = numobs, pop = pop, 
                 r0 = r0, zerohack = zerohack)

nimhyinits <- list(I = sim$I + zerohack,
                   effpropS = effpropS,
                   effpropI = effpropI,
                   beta = beta,
                   reporting = reporting,
                   s0 = s0)
```


```r
allhybrids <- MCMCsuite(code = nimcode,
                   data = nimhydata,
                   inits = nimhyinits,
                   constants = nimhycon,
                   stan_model = "hybrid.stan",
                   MCMCs = c("jags", "nimble", "stan"),
                   monitors = c("beta", "reporting", "effpropS", "effpropI"),
                   niter = 10000,
                   makePlot = FALSE,
                   savePlot = FALSE)
```

##### <a name="2.2"> 2.2 Finally, compare the Chain Binomial NIMBLE and Hybrid STAN </a>


```r
nimCBdata <- list(obs = sim$Iobs)
nimCBcon <- list(numobs = numobs, pop = pop, r0 = r0, zerohack = zerohack)

nimCBinits <- list(I = sim$I,
                   effpropS = effpropS,
                   effpropI = effpropI,
                   beta = beta,
                   reporting = reporting,
                   s0 = s0)
```


```r
nimcb <- MCMCsuite(code = nimcode,
                   data = nimCBdata,
                   inits = nimCBinits,
                   constants = nimCBcon,
                   stan_model = "hybrid.stan",
                   MCMCs = c("jags", "nimble", "stan"),
                   monitors = c("beta", "reporting", "effpropS", "effpropI"),
                   niter = 10000,
                   makePlot = TRUE,
                   savePlot = TRUE)
```

### Part 3

##### <a name="3.1"> 3.1 Expolore more fine-tuned adjustments that can be made in NIMBLE </a>

##### <a name="3.1.1"> 3.1.1 Custom MCMC sampler </a>

The following example is taken directly from pgs 87-89 in the Nimble User Manual <br />

http://r-nimble.org/manuals/ <br />


```r
## the name of this sampler function, for the purposes of ## adding it to MCMC configurations, will be 'my_RW' my_RW <- nimbleFunction(
## sampler functions must contain 'sampler_BASE'
contains = sampler_BASE,

## sampler functions must have exactly these setup arguments: ## model, mvSaved, target, control
setup = function(model, mvSaved, target, control) {
        ## first, extract the control list elements, which will
        ## dictate the behavior of this sampler.
        ## the setup code will be later processed to determine
        ## all named elements extracted from the control list.
        ## these will become the required elements for any
        ## control list argument to this sampler, unless they also
        ## exist in the NIMBLE system option 'MCMCcontrolDefaultList'.
        ## the random walk proposal standard deviation
        scale <- control$scale
        
        ## determine the list of all dependent nodes,
        ## up to the first layer of stochastic nodes, generally
        ## called 'calcNodes'.  The values, inputs, and logProbs
        ## of these nodes will be retrieved and/or altered
        ## by this algorithm.
calcNodes <- model$getDependencies(target) 
},

## the run function must accept no arguments, execute
## the sampling algorithm, leave the modelValues object
## 'mvSaved' as an exact copy of the updated values in model, ## and have no return value. initially, mvSaved contains
## an exact copy of the values and logProbs in the model.
run = function() {
  
    ## extract the initial model logProb
    model_lp_initial <- getLogProb(model, calcNodes) ## generate a proposal value for target node
    proposal <- rnorm(1, model[[target]], scale)
    ## store this proposed value into the target node.
    ## notice the double assignment operator, `<<-`,
    ## necessary because 'model' is a persistent member
    ## data object of this sampler.
    model[[target]] <<- proposal
    
## calculate target_logProb, propagate the
## proposed value through any deterministic dependents, ## and calculate the logProb for any stochastic
## dependnets. The total (sum) logProb is returned. model_lp_proposed <- calculate(model, calcNodes)
## calculate the log Metropolis-Hastings ratio
    log_MH_ratio <- model_lp_proposed - model_lp_initial
    
## Metropolis-Hastings step: determine whether or ## not to accept the newly proposed value
u <- runif(1, 0, 1)
if (u < exp(log_MH_ratio)) jump <- TRUE
    else jump <- FALSE

## if we accepted the proposal, then store the updated ## values and logProbs from 'model' into 'mvSaved'.
## if the proposal was not accepted, restore the values ## and logProbs from 'mvSaved' back into 'model'. if(jump) copy(from = model, to = mvSaved, row = 1,
nodes = calcNodes, logProb = TRUE) else copy(from = mvSaved, to = model, row = 1, nodes = calcNodes, logProb = TRUE)
},

    ## sampler functions must have a member method 'reset',
    ## which takes no arguments and has no return value.
    ## this function is used to reset the sampler to its
    ## initial state.  since this sampler function maintains
    ## no internal member data variables, reset() needn't
    ## do anything.

    methods = list(reset = function () {} )
)

## now, assume the existence of an R model object 'Rmodel',
## which has a scalar-valued stochastic node 'x'
## create an MCMC configuration with no sampler functions
mcmcspec <- configureMCMC(Rmodel, nodes = NULL)

## add our custom-built random walk sampler on node 'x', ## with a fixed proposal standard deviation = 0.1 mcmcspec$addSampler(target = 'x', type = 'my_RW',
control = list(scale = 0.1))
Rmcmc <- buildMCMC(mcmcspec) ## etc...
```

### Part 4

##### <a name="4.1"> NIMBLE extras </a>

##### <a name="4.1.1"> 4.1.1 Mote Carlo Expectation Maximization </a>

Suppose we have a model with missing data (or a layer of latent variables that can be 
treated as missing data) and we would like to maximize the marginal likelihood of the model,
integrating over the missing data. A brute-force method for doing this is MCEM. <br />

Start by building the model <br />


```r
### Construct the NIMBLE model
CBemout <- nimbleModel(code = nimcode, 
                         name = 'CBemout', 
                         constants = nimCBcon,
                         data = nimCBdata, 
                         inits = nimCBinits)


CBmcem <- buildMCEM(model = CBemout, latentNodes = list("I"), 
                      burnIn = 100, 
                      mcmcControl = list(adaptInterval = 20), 
                      boxConstraints = list( list( c("reporting", "effpropS", "effpropI"), 
                                                   limits = c(0, 1) ) ), 
                        buffer = 1e-6)
# burnIn controls the number of discarded MCMC samples for each "E" step

# The MCEM algorithm allows for box constraints on the nodes that will be optimized,
# specified via the boxConstraints argument. This is highly recommended for nodes that
# have zero density on parts of the real line
```


```r
CBmcem(maxit = 20, m1 = 150, m2 = 200)
# maxit controls the total number of iterations
# m1 controls the number of MCMC samples for the first half of the iterations
# m2 controls the number of MCMC samples for the second half of the iterations to reduce MCMC error as the algorithm converges
```

Having trouble with "non-finite finite-difference value", so in the meantime here is the example from the user manual <br />

```r
pumpCode <- nimbleCode({ for (i in 1:N){
      theta[i] ~ dgamma(alpha,beta)
      lambda[i] <- theta[i]*t[i]
      x[i] ~ dpois(lambda[i])
}
alpha ~ dexp(1.0)
beta ~ dgamma(0.1,1.0) 
})

pumpConsts <- list(N = 10,
                   t = c(94.3, 15.7, 62.9, 126, 5.24,
                       31.4, 1.05, 1.05, 2.1, 10.5))

pumpData <- list(x = c(5, 1, 5, 14, 3, 19, 1, 1, 4, 22))

pumpInits <- list(alpha = 1, beta = 1,
                  theta = rep(0.1, pumpConsts$N))

pump <- nimbleModel(code = pumpCode, name = 'pump', constants = pumpConsts,
                    data = pumpData, inits = pumpInits)
```


```r
box <- list( list(c('alpha','beta'), c(0, Inf)))

pumpMCEM <- buildMCEM(model = pump, latentNodes = 'theta[1:10]',
                       boxConstraints = box)

system.time(pumpMLE <- pumpMCEM())

pumpMLE
```

<br />

##### <a name="4.1.2"> 4.1.2 Particle Filter </a>

Set up the Nimble model <br />


```r
CBpfout <- nimbleModel(code = nimcode, 
                         name = 'CBpfout', 
                         constants = nimCBcon,
                         data = nimCBdata,
                         check = FALSE)
```

Build the particle filter <br />


```r
CBpfoutC <- compileNimble(CBpfout)

CBpf <- buildPF(CBpfout, c("I"))
```


```r
CBpfC <- compileNimble(CBpf, project = CBpfout)
```

Set your parameters <br />


```r
CBpfoutC$beta = 0.02
CBpfoutC$effpropS = 0.8
CBpfoutC$effpropI = 0.2
CBpfoutC$reporting = 0.5
```

Obtain log-likelihood


```r
CBpfC$run(m = 5000)
```

Currently relatively useless as is... <br />

Use this framework to construct your own updater <br />

<br />

##### Part 5:  

<a name="5.1"> NIMBLE Notes </a>

**Truncation of distributions** <br />
   • x ∼ N(0, sd = 10) T(0, a)$, or <br />
   • x ∼ T(dnorm(0, sd = 10), 0, a), <br />

   • mu1 ~ dnorm(0, 1) <br />
   • mu2 ~ dnorm(0, 1) <br />
   • constraint_data ~ dconstraint( mu1 + mu2 > 0 ) <br />
   
**Lifted Nodes** <br />
   • The use of link functions causes new nodes to be introduced <br />
   • When distribution parameters are expressions, NIMBLE creates a new deterministic node that contains the expression for a given parameter <br />
   
**logProb** <br />
    • For each variable that contains at least one stochastic node, NIMBLE generates a model variable with the prefix “logProb” <br />
    • Can be retrieved with getLogProb
    
**Choice of Samplers** <br /> 
    1. If the node has no stochastic dependents, a predictive end sampler is assigned. The end sampling algorithm merely calls simulate on the particular node. <br /> 
    2. The node is checked for presence of a conjugate relationship between its prior distribution and the distributions of its stochastic dependents. If it is determined to be in a conjugate relationship, then the corresponding conjugate (Gibbs) sampler is assigned. <br /> 
    3. If the node is discrete-valued, then a slice sampler is assigned [5]. <br /> 
    4. If the node follows a multivariate distribution, then a RW block sampler is assigned for all elements. This is a Metropolis-Hastings adaptive random-walk sampler with a multivariate normal proposal [6]. <br /> 
    5. If none of the above criteria are satisfied, then a RW sampler is assigned. This is a Metropolis-Hastings adaptive random-walk sampler with a univariate normal proposal distribution. <br /> 
    
**Missing Values** <br /> 


```r
CBMiss <- CBout$newModel()
CBMiss$resetData()
CBDataNew <- nimCBdata
CBDataNew$obs[c(1, 3)] <- NA
CBMiss$setData(CBDataNew)
CBMissSpec <- configureMCMC(CBMiss)
CBMissSpec$addMonitors(c("obs", "beta", "effpropS", "effpropI", "reporting"))
CBMissMCMC <- buildMCMC(CBMissSpec)
CBCobj <- compileNimble(CBMiss, CBMissMCMC)
niter <- 1000
set.seed(0)
CBCobj$CBMissMCMC$run(niter)
samples <- as.matrix(CBCobj$CBMissMCMC$mvSamples)
out <- rbind(head(samples), tail(samples))
out
```

**Multiple instances of the same model** <br />
Sometimes it is useful to have more than one copy of the same model. For example, nimbleFunctions are often bound to a particular model as a result of setup code.

```r
simpleCode <- nimbleCode({
for(i in 1:N) x[i] ~ dnorm(0, 1) })
## Return the model definition only, not a built model
simpleModelDefinition <- nimbleModel(simpleCode, constants = list(N = 10),
                                     returnDef = TRUE, check = FALSE)

## Make one instance of the model
simpleModelCopy1 <- simpleModelDefinition$newModel(check = FALSE) ## Make another instance from the same definition
simpleModelCopy2 <- simpleModelDefinition$newModel(check = FALSE) ## Ask simpleModelCopy2 for another copy of itself
simpleModelCopy3 <- simpleModelCopy2$newModel(check = FALSE)
```
