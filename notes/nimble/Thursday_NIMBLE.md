---
title: "Thursday NIMBLE"
author: "Mike Li, Morgan Kain"
date:  "15:43 26 November 2015"
output: html_document
---


```r
library(knitr)
## opts_knit$set(root.dir = "/Users/Morgan/Documents/School Work/McMaster/NIMBLE_Presentation/")
options(mc.cores = parallel::detectCores())
#opts_chunk$set(cache = TRUE)
```

## NIMBLE: Numerical Inference for statistical Models for Bayesian and Likelihood Estimation

- NIMBLE is built in R but compiles your models and algorithms using C++ for speed
- NIMBLE is most commonly used for MCMC but can also be used to implement a series of other algorithms (e.g. particle filtering, MCEM) 

1. A system for writing statistical models flexibly, which is an extension of the BUGS language
2. A library of algorithms such as MCMC.
3. A language, called NIMBLE, embedded within and similar in style to R, for writing algorithms that operate on BUGS models.
  
One of the most important concepts behind NIMBLE is to allow a combination of high-level processing in R and low-level processing in compiled C++.

##### Why NIMBLE?

1. Options (More customizable MCMC, ability to run JAGS models and STAN models, EM, particle filter) that leads to a more adaptable workflow 
2. User-defined functions and distributions – written as nimbleFunctions – can be used in model code.
3. Multiple parameterizations for distributions, similar to those in R, can be used. <br />
<br />
  e.g. normal distribution with BUGS parameter order:
  ```
x ~ dnorm(a + b * c, tau)
```
Normal distribution with a named parameter:
```
y ~ dnorm(a + b * c, sd = sigma)
```
4. Named parameters for distributions and functions, similar to R function calls, can be used. <br />
5. More flexible indexing of vector nodes within larger variables is allowed. For example one can place a multivariate normal vector arbitrarily within a higher-dimensional object, not just in the last index. <br />
6. More general constraints can be declared using dconstraint, which extends the concept of JAGS’ dinterval. <br />
<br />

#### Downloading, installing and loading NIMBLE

On Windows, you should download and install `Rtools.exe` available from http://cran.r-project.org/bin/windows/Rtools/ .
On OS X, you should install Xcode. 

After these are installed you can install NIMBLE in R using

```
install.packages("nimble", repos = "http://r-nimble.org", type = "source")
```

Please post about installation problems to the `nimble-users` Google group or email `nimble.stats@gmail.com`.

You will also need to download STAN using the following commands

```r
Sys.setenv(MAKEFLAGS = "-j4")
install.packages("rstan", dependencies = TRUE)
```

In total you will need the following pakages:


```r
library("nimble")
library("R2jags")
library("ggplot2")
library("rstan")
library("igraph")
library("parallel")
library("mcmcplots")
library("lattice")
library("coda")
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
             t0 = 1, numobs = numobs, reporting = reporting, seed = 3)
sim
```

```
##    time  S  I  R Iobs
## 1     1 80  5  0    1
## 2     2 70 10  5    5
## 3     3 59 11 15    6
## 4     4 47 12 26    4
## 5     5 38  9 38    5
## 6     6 31  7 47    4
## 7     7 27  4 54    2
## 8     8 25  2 58    2
## 9     9 23  2 60    0
## 10   10 22  1 62    1
## 11   11 22  0 63    0
## 12   12 22  0 63    0
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
## 
##   |                                                          |                                                  |   0%  |                                                          |+                                                 |   2%  |                                                          |++                                                |   4%  |                                                          |+++                                               |   6%  |                                                          |++++                                              |   8%  |                                                          |+++++                                             |  10%  |                                                          |++++++                                            |  12%  |                                                          |+++++++                                           |  14%  |                                                          |++++++++                                          |  16%  |                                                          |+++++++++                                         |  18%  |                                                          |++++++++++                                        |  20%  |                                                          |+++++++++++                                       |  22%  |                                                          |++++++++++++                                      |  24%  |                                                          |+++++++++++++                                     |  26%  |                                                          |++++++++++++++                                    |  28%  |                                                          |+++++++++++++++                                   |  30%  |                                                          |++++++++++++++++                                  |  32%  |                                                          |+++++++++++++++++                                 |  34%  |                                                          |++++++++++++++++++                                |  36%  |                                                          |+++++++++++++++++++                               |  38%  |                                                          |++++++++++++++++++++                              |  40%  |                                                          |+++++++++++++++++++++                             |  42%  |                                                          |++++++++++++++++++++++                            |  44%  |                                                          |+++++++++++++++++++++++                           |  46%  |                                                          |++++++++++++++++++++++++                          |  48%  |                                                          |+++++++++++++++++++++++++                         |  50%  |                                                          |++++++++++++++++++++++++++                        |  52%  |                                                          |+++++++++++++++++++++++++++                       |  54%  |                                                          |++++++++++++++++++++++++++++                      |  56%  |                                                          |+++++++++++++++++++++++++++++                     |  58%  |                                                          |++++++++++++++++++++++++++++++                    |  60%  |                                                          |+++++++++++++++++++++++++++++++                   |  62%  |                                                          |++++++++++++++++++++++++++++++++                  |  64%  |                                                          |+++++++++++++++++++++++++++++++++                 |  66%  |                                                          |++++++++++++++++++++++++++++++++++                |  68%  |                                                          |+++++++++++++++++++++++++++++++++++               |  70%  |                                                          |++++++++++++++++++++++++++++++++++++              |  72%  |                                                          |+++++++++++++++++++++++++++++++++++++             |  74%  |                                                          |++++++++++++++++++++++++++++++++++++++            |  76%  |                                                          |+++++++++++++++++++++++++++++++++++++++           |  78%  |                                                          |++++++++++++++++++++++++++++++++++++++++          |  80%  |                                                          |+++++++++++++++++++++++++++++++++++++++++         |  82%  |                                                          |++++++++++++++++++++++++++++++++++++++++++        |  84%  |                                                          |+++++++++++++++++++++++++++++++++++++++++++       |  86%  |                                                          |++++++++++++++++++++++++++++++++++++++++++++      |  88%  |                                                          |+++++++++++++++++++++++++++++++++++++++++++++     |  90%  |                                                          |++++++++++++++++++++++++++++++++++++++++++++++    |  92%  |                                                          |+++++++++++++++++++++++++++++++++++++++++++++++   |  94%  |                                                          |++++++++++++++++++++++++++++++++++++++++++++++++  |  96%  |                                                          |+++++++++++++++++++++++++++++++++++++++++++++++++ |  98%  |                                                          |++++++++++++++++++++++++++++++++++++++++++++++++++| 100%
```

```r
list.samplers(cbjagsmodel)
```

```
## $ShiftedCount
## [1] "I[12]"
## 
## $DiscreteSlicer
## [1] "I[11]"
## 
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
## $DiscreteSlicer
## [1] "I[1]"
## 
## $DiscreteSlicer
## [1] "S[1]"
## 
## $RealSlicer
## [1] "beta"
## 
## $ConjugateBeta
## [1] "effpropI"
## 
## $ConjugateBeta
## [1] "effpropS"
## 
## $ConjugateBeta
## [1] "reporting"
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
## 
##   |                                                          |                                                  |   0%  |                                                          |+++++++++++                                       |  22%  |                                                          |++++++++++++++++++++++                            |  44%  |                                                          |+++++++++++++++++++++++++++++++++                 |  66%  |                                                          |++++++++++++++++++++++++++++++++++++++++++++      |  88%  |                                                          |++++++++++++++++++++++++++++++++++++++++++++++++++| 100%
##   |                                                          |                                                  |   0%  |                                                          |*                                                 |   2%  |                                                          |**                                                |   4%  |                                                          |***                                               |   7%  |                                                          |****                                              |   9%  |                                                          |******                                            |  11%  |                                                          |*******                                           |  13%  |                                                          |********                                          |  15%  |                                                          |*********                                         |  18%  |                                                          |**********                                        |  20%  |                                                          |***********                                       |  22%  |                                                          |************                                      |  24%  |                                                          |*************                                     |  26%  |                                                          |**************                                    |  29%  |                                                          |***************                                   |  31%  |                                                          |****************                                  |  33%  |                                                          |******************                                |  35%  |                                                          |*******************                               |  37%  |                                                          |********************                              |  40%  |                                                          |*********************                             |  42%  |                                                          |**********************                            |  44%  |                                                          |***********************                           |  46%  |                                                          |************************                          |  48%  |                                                          |*************************                         |  51%  |                                                          |**************************                        |  53%  |                                                          |****************************                      |  55%  |                                                          |*****************************                     |  57%  |                                                          |******************************                    |  59%  |                                                          |*******************************                   |  62%  |                                                          |********************************                  |  64%  |                                                          |*********************************                 |  66%  |                                                          |**********************************                |  68%  |                                                          |***********************************               |  70%  |                                                          |************************************              |  73%  |                                                          |*************************************             |  75%  |                                                          |**************************************            |  77%  |                                                          |****************************************          |  79%  |                                                          |*****************************************         |  81%  |                                                          |******************************************        |  84%  |                                                          |*******************************************       |  86%  |                                                          |********************************************      |  88%  |                                                          |*********************************************     |  90%  |                                                          |**********************************************    |  92%  |                                                          |***********************************************   |  95%  |                                                          |************************************************  |  97%  |                                                          |**************************************************|  99%  |                                                          |**************************************************| 100%
```


```r
cbjags
```

```
## Inference for Bugs model at "CB.bug", fit using jags,
##  3 chains, each with 11000 iterations (first 1000 discarded), n.thin = 20
##  n.sims = 1500 iterations saved
##           mu.vect sd.vect   2.5%    25%    50%    75%  97.5%  Rhat n.eff
## beta        0.022   0.007  0.012  0.017  0.020  0.025  0.039 1.002  1200
## effpropI    0.391   0.270  0.035  0.155  0.331  0.589  0.943 1.003   730
## effpropS    0.820   0.128  0.506  0.753  0.855  0.918  0.974 1.006   430
## reporting   0.481   0.119  0.298  0.391  0.464  0.553  0.762 1.005   370
## deviance   29.965   3.350 23.533 27.913 29.820 32.034 37.025 1.008   290
## 
## For each parameter, n.eff is a crude measure of effective sample size,
## and Rhat is the potential scale reduction factor (at convergence, Rhat=1).
## 
## DIC info (using the rule, pD = var(deviance)/2)
## pD = 5.6 and DIC = 35.5
## DIC is an estimate of expected predictive error (lower deviance is better).
```

```r
xyplot(as.mcmc(cbjags))
```

![plot of chunk unnamed-chunk-8](figure/unnamed-chunk-8-1.png) 

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
## [1] 10
```


```r
CBout$obs
```

```
##  [1] 1 5 6 4 5 4 2 2 0 1 0 0
```

nimbleModel does its best to initialize a model, but let’s say you want to re-initialize I. <br />


```r
simulate(CBout, 'I') # using the current beta -- if we update beta to a new value this will change
CBout$I
```

```
##  [1]  7 10 14  9 11  7  1  2  2  0  1  0
```

And take a look at the log-prob <br />


```r
calculate(CBout, "I")
```

```
## [1] -21.70036
```

```r
CBout$logProb_I
```

```
##  [1] -2.9086403 -2.3671034 -2.1998297 -2.3751669 -2.0406554 -1.8454856
##  [7] -2.8344862 -1.2710398 -1.6833944 -0.9293245 -1.2452374  0.0000000
```

```r
I2lp <- CBout$nodes[['I[2]']]$calculate()
I2lp
```

```
## [1] -2.367103
```

or Calculate new log probabilities after updating I <br />


```r
CBout$obs
```

```
##  [1] 1 5 6 4 5 4 2 2 0 1 0 0
```

```r
getLogProb(CBout, 'obs')
```

```
## [1] -14.00589
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
##  [1] -2.9061201 -1.4020427 -1.6966935 -1.4020427 -1.4890541 -1.2966822
##  [7]       -Inf -1.3862944 -1.3862944       -Inf -0.6931472  0.0000000
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

We will return to nimbleFunctions later -- but here is an initial example nimbleFunction that will simulate multiple values for a designated set of nodes and calculate every part of the model that depends on them


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
##  [1] -1.3862944 -3.4657359 -1.4890541 -2.1132084 -1.6432048 -1.2966822
##  [7] -1.8075078 -0.9808293  0.0000000 -0.6931472  0.0000000  0.0000000
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
## elapsed 
##   9.993
```

```r
sum(nimtimevec[1:6], na.rm = TRUE)
```

```
## [1] 22.08
```

```r
nimtimevec[6]
```

```
## [1] 1.063
```

Efficiency (Net time in a sense) <br />


```r
samples <- as.matrix(CBoutMCMC$mvSamples)

head(samples)
```

```
##            beta   effpropI  effpropS reporting
## [1,] 0.02000000 0.10177476 0.8000000 0.5000000
## [2,] 0.02000000 0.17117041 0.8344718 0.4494027
## [3,] 0.02000000 0.27383622 0.7354812 0.5960751
## [4,] 0.02000000 0.26997867 0.7354812 0.5559008
## [5,] 0.02000000 0.02263745 0.7487252 0.5268280
## [6,] 0.01683664 0.27080943 0.8114301 0.6138359
```

```r
jags_eff <- effectiveSize(as.mcmc.list(as.mcmc(cbjags))) / nimtimevec[1]
nim_eff <- effectiveSize(as.mcmc.list(as.mcmc(samples))) / nimtimevec[6]

jags_eff
```

```
##      beta  deviance  effpropI  effpropS reporting 
##  423.4051  784.8785  510.2223  304.2819  474.7667
```

```r
nim_eff
```

```
##      beta  effpropI  effpropS reporting 
## 115.56311 136.24855  79.25381 205.84336
```


![plot of chunk unnamed-chunk-29](figure/unnamed-chunk-29-1.png) ![plot of chunk unnamed-chunk-29](figure/unnamed-chunk-29-2.png) ![plot of chunk unnamed-chunk-29](figure/unnamed-chunk-29-3.png) 

Save these points for later


```r
  def_effS <- samples[ , 'effpropS']
  def_effI <- samples[ , 'effpropI']
```

Look at the correlation in the chains


```r
  acf(samples[, "beta"])
```

![plot of chunk unnamed-chunk-31](figure/unnamed-chunk-31-1.png) 

```r
  acf(samples[, "reporting"])
```

![plot of chunk unnamed-chunk-31](figure/unnamed-chunk-31-2.png) 

```r
  acf(samples[, "effpropS"])
```

![plot of chunk unnamed-chunk-31](figure/unnamed-chunk-31-3.png) 

```r
  acf(samples[, "effpropI"])
```

![plot of chunk unnamed-chunk-31](figure/unnamed-chunk-31-4.png) 

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
CBoutSpec$setThin(30)
```

```
## thin = 30: reporting, effpropS, effpropI, beta
```


```r
CBoutMCMC <- buildMCMC(CBoutSpec)
```


```r
CBoutMCMC <- compileNimble(CBoutMCMC, project  = CBout, resetFunctions = TRUE)
```


```r
CBoutMCMC$run(30000)
```

```
## NULL
```

```r
samplesNew <- as.matrix(CBoutMCMC$mvSamples)
```

Check for an imporvement


```r
  par(mfrow = c(2,2))
  acf(samplesNew[, "effpropS"])
  acf(samplesNew[, "effpropI"])
  plot(samplesNew[ , 'effpropS'], type = 'l', xlab = 'iteration')
  plot(samplesNew[ , 'effpropI'], type = 'l', xlab = 'iteration')
```

![plot of chunk unnamed-chunk-38](figure/unnamed-chunk-38-1.png) 

```r
  par(mfrow = c(1,1))
  plot(samplesNew[ , 'effpropS'], samplesNew[ , 'effpropI'], pch = 20)
  points(def_effS, def_effI, pch = 20, col = "blue")
```

![plot of chunk unnamed-chunk-38](figure/unnamed-chunk-38-2.png) 

Well that didn't do anything... <br />

NIMBLE allows for specification of samplers by parameter or node by node (NIMBLE included or user created) <br />


```r
CBout <- nimbleModel(code = nimcode, 
                         name = 'CBout', 
                         constants = nimCBcon,
                         data = nimCBdata, 
                         inits = nimCBinits)
```

```
## defining model...
## building model...
## setting data and initial values...
## checking model...   (use nimbleModel(..., check = FALSE) to skip model check)
## model building finished
```

```r
CBoutC <- compileNimble(CBout)
  
CBoutSpec <- configureMCMC(CBout, print = TRUE)
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


```r
CBoutSpec$removeSamplers(c("beta", "effpropS", "effpropI", "reporting"), print = TRUE)
```

```
## [1]  slice sampler: s0,  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
## [2]  slice sampler: I[1],  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
## [3]  slice sampler: I[2],  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
## [4]  slice sampler: I[3],  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
## [5]  slice sampler: I[4],  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
## [6]  slice sampler: I[5],  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
## [7]  slice sampler: I[6],  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
## [8]  slice sampler: I[7],  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
## [9]  slice sampler: I[8],  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
## [10] slice sampler: I[9],  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
## [11] slice sampler: I[10],  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
## [12] slice sampler: I[11],  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
## [13] slice sampler: I[12],  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
```

```r
CBoutSpec$addSampler("beta", type = "slice", print = TRUE)
```

```
## [14] slice sampler: beta,  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
```

```r
CBoutSpec$addSampler("effpropS", type = "slice", print = TRUE)
```

```
## [15] slice sampler: effpropS,  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
```

```r
CBoutSpec$addSampler("effpropI", type = "slice", print = TRUE)
```

```
## [16] slice sampler: effpropI,  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
```

```r
CBoutSpec$addSampler("reporting", type = "slice", print = TRUE)
```

```
## [17] slice sampler: reporting,  adaptive: TRUE,  adaptInterval: 200,  sliceWidth: 1,  sliceMaxSteps: 100
```


```r
CBoutMCMC <- buildMCMC(CBoutSpec)
CBoutMCMC <- compileNimble(CBoutMCMC, project  = CBout, resetFunctions = TRUE)
```


```r
nimtimevec[7] <- system.time(CBoutMCMC$run(30000))[3]
samplesblock <- as.matrix(CBoutMCMC$mvSamples)
nim_eff <- effectiveSize(as.mcmc.list(as.mcmc(samplesblock))) / nimtimevec[7]
nim_eff
```

```
##      beta  effpropI  effpropS reporting 
##  153.9522  160.8200  126.2699  265.1520
```


```r
  par(mfrow = c(1,1))
  plot(samplesblock[ , 'effpropS'], samplesblock[ , 'effpropI'], pch = 20)
```

![plot of chunk unnamed-chunk-43](figure/unnamed-chunk-43-1.png) 

<br />
<br />

##### <a name="1.3"> 1.3 Compare the JAGS and NIMBLE results </a>

We can also compare the NIMBLE model simultaneously with the JAGS model using MCMCsuite() <br />

Be warned: running this code with "makePlot = TRUE" will produce about 6-8 graphs which will all pop up in separate windows! <br />


```r
nimcb <- MCMCsuite(code = nimcode,
                   data = nimCBdata,
                   inits = nimCBinits,
                   constants = nimCBcon,
                   MCMCs = c("jags", "nimble"),
                   monitors = c("beta", "reporting", "effpropS", "effpropI"),
                   niter = 12000,
                   calculateEfficiency = TRUE,
                   makePlot = FALSE,
                   savePlot = FALSE)
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
##    Graph Size: 83
## 
## Initializing model
## 
##   |                                                          |                                                  |   0%  |                                                          |+                                                 |   2%  |                                                          |++                                                |   4%  |                                                          |+++                                               |   6%  |                                                          |++++                                              |   8%  |                                                          |+++++                                             |  10%  |                                                          |++++++                                            |  12%  |                                                          |+++++++                                           |  14%  |                                                          |++++++++                                          |  16%  |                                                          |+++++++++                                         |  18%  |                                                          |++++++++++                                        |  20%  |                                                          |+++++++++++                                       |  22%  |                                                          |++++++++++++                                      |  24%  |                                                          |+++++++++++++                                     |  26%  |                                                          |++++++++++++++                                    |  28%  |                                                          |+++++++++++++++                                   |  30%  |                                                          |++++++++++++++++                                  |  32%  |                                                          |+++++++++++++++++                                 |  34%  |                                                          |++++++++++++++++++                                |  36%  |                                                          |+++++++++++++++++++                               |  38%  |                                                          |++++++++++++++++++++                              |  40%  |                                                          |+++++++++++++++++++++                             |  42%  |                                                          |++++++++++++++++++++++                            |  44%  |                                                          |+++++++++++++++++++++++                           |  46%  |                                                          |++++++++++++++++++++++++                          |  48%  |                                                          |+++++++++++++++++++++++++                         |  50%  |                                                          |++++++++++++++++++++++++++                        |  52%  |                                                          |+++++++++++++++++++++++++++                       |  54%  |                                                          |++++++++++++++++++++++++++++                      |  56%  |                                                          |+++++++++++++++++++++++++++++                     |  58%  |                                                          |++++++++++++++++++++++++++++++                    |  60%  |                                                          |+++++++++++++++++++++++++++++++                   |  62%  |                                                          |++++++++++++++++++++++++++++++++                  |  64%  |                                                          |+++++++++++++++++++++++++++++++++                 |  66%  |                                                          |++++++++++++++++++++++++++++++++++                |  68%  |                                                          |+++++++++++++++++++++++++++++++++++               |  70%  |                                                          |++++++++++++++++++++++++++++++++++++              |  72%  |                                                          |+++++++++++++++++++++++++++++++++++++             |  74%  |                                                          |++++++++++++++++++++++++++++++++++++++            |  76%  |                                                          |+++++++++++++++++++++++++++++++++++++++           |  78%  |                                                          |++++++++++++++++++++++++++++++++++++++++          |  80%  |                                                          |+++++++++++++++++++++++++++++++++++++++++         |  82%  |                                                          |++++++++++++++++++++++++++++++++++++++++++        |  84%  |                                                          |+++++++++++++++++++++++++++++++++++++++++++       |  86%  |                                                          |++++++++++++++++++++++++++++++++++++++++++++      |  88%  |                                                          |+++++++++++++++++++++++++++++++++++++++++++++     |  90%  |                                                          |++++++++++++++++++++++++++++++++++++++++++++++    |  92%  |                                                          |+++++++++++++++++++++++++++++++++++++++++++++++   |  94%  |                                                          |++++++++++++++++++++++++++++++++++++++++++++++++  |  96%  |                                                          |+++++++++++++++++++++++++++++++++++++++++++++++++ |  98%  |                                                          |++++++++++++++++++++++++++++++++++++++++++++++++++| 100%
##   |                                                          |                                                  |   0%  |                                                          |*                                                 |   2%  |                                                          |**                                                |   4%  |                                                          |***                                               |   6%  |                                                          |****                                              |   8%  |                                                          |*****                                             |  10%  |                                                          |******                                            |  12%  |                                                          |*******                                           |  14%  |                                                          |********                                          |  16%  |                                                          |*********                                         |  18%  |                                                          |**********                                        |  20%  |                                                          |***********                                       |  22%  |                                                          |************                                      |  24%  |                                                          |*************                                     |  26%  |                                                          |**************                                    |  28%  |                                                          |***************                                   |  30%  |                                                          |****************                                  |  32%  |                                                          |*****************                                 |  34%  |                                                          |******************                                |  36%  |                                                          |*******************                               |  38%  |                                                          |********************                              |  40%  |                                                          |*********************                             |  42%  |                                                          |**********************                            |  44%  |                                                          |***********************                           |  46%  |                                                          |************************                          |  48%  |                                                          |*************************                         |  50%  |                                                          |**************************                        |  52%  |                                                          |***************************                       |  54%  |                                                          |****************************                      |  56%  |                                                          |*****************************                     |  58%  |                                                          |******************************                    |  60%  |                                                          |*******************************                   |  62%  |                                                          |********************************                  |  64%  |                                                          |*********************************                 |  66%  |                                                          |**********************************                |  68%  |                                                          |***********************************               |  70%  |                                                          |************************************              |  72%  |                                                          |*************************************             |  74%  |                                                          |**************************************            |  76%  |                                                          |***************************************           |  78%  |                                                          |****************************************          |  80%  |                                                          |*****************************************         |  82%  |                                                          |******************************************        |  84%  |                                                          |*******************************************       |  86%  |                                                          |********************************************      |  88%  |                                                          |*********************************************     |  90%  |                                                          |**********************************************    |  92%  |                                                          |***********************************************   |  94%  |                                                          |************************************************  |  96%  |                                                          |************************************************* |  98%  |                                                          |**************************************************| 100%
```

```r
  nimcb$summary
```

```
## , , beta
## 
##              mean     median          sd   CI95_low   CI95_upp     n
## jags   0.02180766 0.01991883 0.007928213 0.01208427 0.04406548 10000
## nimble 0.02238331 0.02026432 0.008585741 0.01212697 0.04593279 10000
##             ess efficiency
## jags   147.9149   43.11131
## nimble  83.1905   68.63903
## 
## , , reporting
## 
##             mean    median        sd  CI95_low  CI95_upp     n      ess
## jags   0.5125007 0.4909599 0.1346891 0.3059361 0.8269606 10000 324.9068
## nimble 0.5291161 0.5031207 0.1402128 0.3107321 0.8428592 10000 223.0523
##        efficiency
## jags      94.6974
## nimble   184.0366
## 
## , , effpropS
## 
##             mean    median        sd  CI95_low  CI95_upp     n       ess
## jags   0.8053624 0.8518873 0.1434363 0.4461674 0.9719240 10000 125.33224
## nimble 0.7917268 0.8326756 0.1502838 0.4371907 0.9729178 10000  52.59819
##        efficiency
## jags     36.52936
## nimble   43.39784
## 
## , , effpropI
## 
##             mean    median        sd  CI95_low  CI95_upp     n      ess
## jags   0.3860855 0.3214929 0.2740225 0.0330848 0.9536429 10000 288.1000
## nimble 0.3646788 0.2788137 0.2803558 0.0250384 0.9535620 10000 118.3843
##        efficiency
## jags     83.96969
## nimble   97.67679
```

```r
  nimcb$efficiency
```

```
## $min
##     jags   nimble 
## 36.52936 43.39784 
## 
## $mean
##     jags   nimble 
## 64.57694 98.43756
```

```r
  nimcb$timing
```

```
##           jags         nimble nimble_compile 
##          3.431          1.212         17.819
```

MCMCsuite allows for convenient specification of MCMC runs <br />

For example, we may want to run a bit longer, introduce some burn-in, thinning and also compare a adaptive block sampler <br />


```r
nimcb <- MCMCsuite(code = nimcode,
                   data = nimCBdata,
                   inits = nimCBinits,
                   constants = nimCBcon,
                   MCMCs = c("jags", "nimble", "autoBlock", "nimble_RW"),
                   monitors = c("beta", "reporting", "effpropS", "effpropI"),
                   niter = 12000,
                   burnin = 1000,
                #   thin = 10,
                   calculateEfficiency = TRUE,
                   makePlot = FALSE,
                   savePlot = FALSE)
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
##    Graph Size: 83
## 
## Initializing model
## 
##   |                                                          |                                                  |   0%  |                                                          |+                                                 |   2%  |                                                          |++                                                |   4%  |                                                          |+++                                               |   6%  |                                                          |++++                                              |   8%  |                                                          |+++++                                             |  10%  |                                                          |++++++                                            |  12%  |                                                          |+++++++                                           |  14%  |                                                          |++++++++                                          |  16%  |                                                          |+++++++++                                         |  18%  |                                                          |++++++++++                                        |  20%  |                                                          |+++++++++++                                       |  22%  |                                                          |++++++++++++                                      |  24%  |                                                          |+++++++++++++                                     |  26%  |                                                          |++++++++++++++                                    |  28%  |                                                          |+++++++++++++++                                   |  30%  |                                                          |++++++++++++++++                                  |  32%  |                                                          |+++++++++++++++++                                 |  34%  |                                                          |++++++++++++++++++                                |  36%  |                                                          |+++++++++++++++++++                               |  38%  |                                                          |++++++++++++++++++++                              |  40%  |                                                          |+++++++++++++++++++++                             |  42%  |                                                          |++++++++++++++++++++++                            |  44%  |                                                          |+++++++++++++++++++++++                           |  46%  |                                                          |++++++++++++++++++++++++                          |  48%  |                                                          |+++++++++++++++++++++++++                         |  50%  |                                                          |++++++++++++++++++++++++++                        |  52%  |                                                          |+++++++++++++++++++++++++++                       |  54%  |                                                          |++++++++++++++++++++++++++++                      |  56%  |                                                          |+++++++++++++++++++++++++++++                     |  58%  |                                                          |++++++++++++++++++++++++++++++                    |  60%  |                                                          |+++++++++++++++++++++++++++++++                   |  62%  |                                                          |++++++++++++++++++++++++++++++++                  |  64%  |                                                          |+++++++++++++++++++++++++++++++++                 |  66%  |                                                          |++++++++++++++++++++++++++++++++++                |  68%  |                                                          |+++++++++++++++++++++++++++++++++++               |  70%  |                                                          |++++++++++++++++++++++++++++++++++++              |  72%  |                                                          |+++++++++++++++++++++++++++++++++++++             |  74%  |                                                          |++++++++++++++++++++++++++++++++++++++            |  76%  |                                                          |+++++++++++++++++++++++++++++++++++++++           |  78%  |                                                          |++++++++++++++++++++++++++++++++++++++++          |  80%  |                                                          |+++++++++++++++++++++++++++++++++++++++++         |  82%  |                                                          |++++++++++++++++++++++++++++++++++++++++++        |  84%  |                                                          |+++++++++++++++++++++++++++++++++++++++++++       |  86%  |                                                          |++++++++++++++++++++++++++++++++++++++++++++      |  88%  |                                                          |+++++++++++++++++++++++++++++++++++++++++++++     |  90%  |                                                          |++++++++++++++++++++++++++++++++++++++++++++++    |  92%  |                                                          |+++++++++++++++++++++++++++++++++++++++++++++++   |  94%  |                                                          |++++++++++++++++++++++++++++++++++++++++++++++++  |  96%  |                                                          |+++++++++++++++++++++++++++++++++++++++++++++++++ |  98%  |                                                          |++++++++++++++++++++++++++++++++++++++++++++++++++| 100%
##   |                                                          |                                                  |   0%  |                                                          |*                                                 |   2%  |                                                          |**                                                |   4%  |                                                          |***                                               |   6%  |                                                          |****                                              |   8%  |                                                          |*****                                             |  10%  |                                                          |******                                            |  12%  |                                                          |*******                                           |  14%  |                                                          |********                                          |  16%  |                                                          |*********                                         |  18%  |                                                          |**********                                        |  20%  |                                                          |***********                                       |  22%  |                                                          |************                                      |  24%  |                                                          |*************                                     |  26%  |                                                          |**************                                    |  28%  |                                                          |***************                                   |  30%  |                                                          |****************                                  |  32%  |                                                          |*****************                                 |  34%  |                                                          |******************                                |  36%  |                                                          |*******************                               |  38%  |                                                          |********************                              |  40%  |                                                          |*********************                             |  42%  |                                                          |**********************                            |  44%  |                                                          |***********************                           |  46%  |                                                          |************************                          |  48%  |                                                          |*************************                         |  50%  |                                                          |**************************                        |  52%  |                                                          |***************************                       |  54%  |                                                          |****************************                      |  56%  |                                                          |*****************************                     |  58%  |                                                          |******************************                    |  60%  |                                                          |*******************************                   |  62%  |                                                          |********************************                  |  64%  |                                                          |*********************************                 |  66%  |                                                          |**********************************                |  68%  |                                                          |***********************************               |  70%  |                                                          |************************************              |  72%  |                                                          |*************************************             |  74%  |                                                          |**************************************            |  76%  |                                                          |***************************************           |  78%  |                                                          |****************************************          |  80%  |                                                          |*****************************************         |  82%  |                                                          |******************************************        |  84%  |                                                          |*******************************************       |  86%  |                                                          |********************************************      |  88%  |                                                          |*********************************************     |  90%  |                                                          |**********************************************    |  92%  |                                                          |***********************************************   |  94%  |                                                          |************************************************  |  96%  |                                                          |************************************************* |  98%  |                                                          |**************************************************| 100%
## 
## Auto-Blocking summary:
##            mcmc     node     S    C Efficiency
## 1   All Blocked effpropS  8.31 1.12       7.41
## 2    All Scalar       s0 72.83 1.03      70.74
## 3       Default       s0 72.83 1.01      72.43
## 4 Auto-Blocking       s0 72.83 0.97      74.81
## 
## Auto-Blocking converged on all scalar (univariate) sampling
```

```r
  nimcb$summary
```

```
## , , beta
## 
##                 mean     median          sd   CI95_low   CI95_upp     n
## jags      0.02231988 0.02031498 0.008418395 0.01236743 0.04640706 11000
## nimble    0.02326376 0.02142373 0.008277899 0.01270738 0.04529219 11000
## autoBlock 0.02223389 0.02005801 0.008438087 0.01216501 0.04680976 11000
## nimble_RW 0.02150700 0.01996704 0.006958702 0.01215994 0.03994221 11000
##                 ess efficiency
## jags      210.45438   59.19954
## nimble    135.42591  112.47999
## autoBlock  79.04899   65.92910
## nimble_RW 205.95218  176.17809
## 
## , , reporting
## 
##                mean    median        sd  CI95_low  CI95_upp     n      ess
## jags      0.5212569 0.4973404 0.1407582 0.3112950 0.8449849 11000 378.2831
## nimble    0.5329994 0.5199607 0.1360280 0.3148980 0.8296261 11000 236.1914
## autoBlock 0.5119445 0.4902637 0.1369659 0.3064950 0.8396076 11000 234.9167
## nimble_RW 0.5217788 0.5046228 0.1349471 0.3102448 0.8156944 11000 253.4517
##           efficiency
## jags        106.4088
## nimble      196.1723
## autoBlock   195.9272
## nimble_RW   216.8107
## 
## , , effpropS
## 
##                mean    median        sd  CI95_low  CI95_upp     n
## jags      0.7961615 0.8396050 0.1464926 0.4345009 0.9698803 11000
## nimble    0.7703934 0.7981826 0.1530485 0.4560266 0.9687040 11000
## autoBlock 0.8083018 0.8543280 0.1459840 0.4368252 0.9728792 11000
## nimble_RW 0.8039048 0.8491852 0.1389703 0.4762293 0.9671822 11000
##                 ess efficiency
## jags      179.48605   50.48834
## nimble     77.29572   64.19910
## autoBlock  66.72764   55.65274
## nimble_RW  79.77536   68.24239
## 
## , , effpropI
## 
##                mean    median        sd   CI95_low  CI95_upp     n
## jags      0.3621702 0.2973445 0.2658787 0.02906131 0.9418680 11000
## nimble    0.3320219 0.2334860 0.2714097 0.02644870 0.9429288 11000
## autoBlock 0.3918723 0.3311183 0.2816921 0.03272275 0.9575249 11000
## nimble_RW 0.3716978 0.3006341 0.2717469 0.02703861 0.9353198 11000
##                ess efficiency
## jags      352.3157   99.10428
## nimble    105.4101   87.54992
## autoBlock 146.2721  121.99506
## nimble_RW 164.0498  140.33342
```

```r
  nimcb$efficiency
```

```
## $min
##      jags    nimble autoBlock nimble_RW 
##  50.48834  64.19910  55.65274  68.24239 
## 
## $mean
##      jags    nimble autoBlock nimble_RW 
##  78.80023 115.10032 109.87602 150.39116
```

```r
  nimcb$timing
```

```
##           jags         nimble      autoBlock      nimble_RW nimble_compile 
##          3.555          1.204          1.199          1.169         20.538
```

MCMCsuite can also be used to compare models written in STAN or... which we will see next week <br />

<br />
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
```

```
## setting data and initial values...
## checking model...   (use nimbleModel(..., check = FALSE) to skip model check)
```

```r
CBMiss$resetData()
CBDataNew <- nimCBdata
CBDataNew$obs[c(1, 3)] <- NA
CBMiss$setData(CBDataNew)
CBMissSpec <- configureMCMC(CBMiss)
CBMissSpec$addMonitors(c("obs", "beta", "effpropS", "effpropI", "reporting"))
```

```
## thin = 1: reporting, effpropS, effpropI, beta, obs
```

```r
CBMissMCMC <- buildMCMC(CBMissSpec)
CBCobj <- compileNimble(CBMiss, CBMissMCMC)
niter <- 1000
set.seed(0)
CBCobj$CBMissMCMC$run(niter)
```

```
## NULL
```

```r
samples <- as.matrix(CBCobj$CBMissMCMC$mvSamples)
out <- rbind(head(samples), tail(samples))
out
```

```
##               beta  effpropI  effpropS obs[1] obs[2] obs[3] obs[4] obs[5]
##         0.02000000 0.2000000 0.8000000      2      5      6      4      5
##         0.02000000 0.2000000 0.8000000      3      5      8      4      5
##         0.02000000 0.2000000 0.8000000      3      5      7      4      5
##         0.02000000 0.2000000 0.8274753      3      5      3      4      5
##         0.02000000 0.2000000 0.8448710      1      5      6      4      5
##         0.02000000 0.2000000 0.8448710      2      5      2      4      5
## [995,]  0.01430577 0.3728769 0.9059062      2      5      4      4      5
## [996,]  0.01430577 0.3728769 0.9059062      1      5      5      4      5
## [997,]  0.01430577 0.2934961 0.9059062      3      5      8      4      5
## [998,]  0.01430577 0.2934961 0.8973163      4      5      6      4      5
## [999,]  0.01430577 0.3886819 0.8973163      5      5      9      4      5
## [1000,] 0.01430577 0.3507792 0.8476990      3      5      7      4      5
##         obs[6] obs[7] obs[8] obs[9] obs[10] obs[11] obs[12] reporting
##              4      2      2      0       1       0       0 0.5000000
##              4      2      2      0       1       0       0 0.5000000
##              4      2      2      0       1       0       0 0.5000000
##              4      2      2      0       1       0       0 0.5253829
##              4      2      2      0       1       0       0 0.5253829
##              4      2      2      0       1       0       0 0.5253829
## [995,]       4      2      2      0       1       0       0 0.6150413
## [996,]       4      2      2      0       1       0       0 0.6150413
## [997,]       4      2      2      0       1       0       0 0.6150413
## [998,]       4      2      2      0       1       0       0 0.6150413
## [999,]       4      2      2      0       1       0       0 0.6150413
## [1000,]      4      2      2      0       1       0       0 0.6489087
```

**Multiple instances of the same model** <br />
Sometimes it is useful to have more than one copy of the same model. For example, nimbleFunctions are often bound to a particular model as a result of setup code.

```r
simpleCode <- nimbleCode({
for(i in 1:N) x[i] ~ dnorm(0, 1) })
## Return the model definition only, not a built model
simpleModelDefinition <- nimbleModel(simpleCode, constants = list(N = 10),
                                     returnDef = TRUE, check = FALSE)
```

```
## defining model...
```

```r
## Make one instance of the model
simpleModelCopy1 <- simpleModelDefinition$newModel(check = FALSE) ## Make another instance from the same definition
simpleModelCopy2 <- simpleModelDefinition$newModel(check = FALSE) ## Ask simpleModelCopy2 for another copy of itself
simpleModelCopy3 <- simpleModelCopy2$newModel(check = FALSE)
```
