---
title: "Approximate Bayesian Computation Lab"
author: "Kai Liu & Kavitha N."
date: "October 21, 2015"
output: pdf_document
---

# Preliminaries

There are two packages are available in R to implement approximate bayesian computations -- `abc` and `EasyABC`.


First, load the packages:


```r
library("abc")
library("EasyABC")
library("abc.data") ## load data package; automatically installed with abc
```


# abc


```r
data(musigma2)
data(human)
stat.voight
```

```
##              pi TajD.m TajD.v
## hausa   0.00110  -0.20   0.55
## italian 0.00085   0.28   1.19
## chinese 0.00079   0.18   1.08
```

```r
## ?stat.voight
par(mfcol = c(1,3), mar=c(5,3,4,.5)) 
boxplot(stat.3pops.sim[,"pi"]~models, main="Mean nucleotide diversity") 
boxplot(stat.3pops.sim[,"TajD.m"]~models, main="Mean Tajima's D") 
boxplot(stat.3pops.sim[,"TajD.v"]~models, main="Var in Tajima's D")
```

![plot of chunk abcpackage](figure/abcpackage-1.png) 

```r
cv.modsel <- cv4postpr(models, stat.3pops.sim, nval=5, tol=.01, method="mnlogistic") 
```

```
## Warning: There are 3 models but only 1 for which simulations have been accepted.
## No regression is performed, method is set to rejection.
## Consider increasing the tolerance rate.TRUE
```

```r
s <- summary(cv.modsel)
```

```
## Confusion matrix based on 5 samples for each model.
## 
## $tol0.01
##       bott const exp
## bott     3     2   0
## const    0     4   1
## exp      0     1   4
## 
## 
## Mean model posterior probabilities (mnlogistic)
## 
## $tol0.01
##         bott  const    exp
## bott  0.6331 0.3279 0.0390
## const 0.2551 0.6350 0.1100
## exp   0.0198 0.2416 0.7386
```

```r
plot(cv.modsel, names.arg=c("Bottleneck", "Constant", "Exponential"))
modsel.ha <- postpr(stat.voight["hausa",], 
                    models, stat.3pops.sim, 
                    tol=.05, method="mnlogistic") 
modsel.it <- postpr(stat.voight["italian",], 
                    models, stat.3pops.sim, 
                    tol=.05, method="mnlogistic") 
modsel.ch <- postpr(stat.voight["chinese",], 
                    models, stat.3pops.sim, 
                    tol=.05, method="mnlogistic") 
summary(modsel.ha)
```

```
## Call: 
## postpr(target = stat.voight["hausa", ], index = models, sumstat = stat.3pops.sim, 
##     tol = 0.05, method = "mnlogistic")
## Data:
##  postpr.out$values (7500 posterior samples)
## Models a priori:
##  bott, const, exp
## Models a posteriori:
##  bott, const, exp
## 
## Proportion of accepted simulations (rejection):
##   bott  const    exp 
## 0.0199 0.3132 0.6669 
## 
## Bayes factors:
##          bott   const     exp
## bott   1.0000  0.0634  0.0298
## const 15.7651  1.0000  0.4696
## exp   33.5705  2.1294  1.0000
## 
## 
## Posterior model probabilities (mnlogistic):
##   bott  const    exp 
## 0.0164 0.3591 0.6245 
## 
## Bayes factors:
##          bott   const     exp
## bott   1.0000  0.0456  0.0262
## const 21.9360  1.0000  0.5751
## exp   38.1446  1.7389  1.0000
```

```r
summary(modsel.it)
```

```
## Call: 
## postpr(target = stat.voight["italian", ], index = models, sumstat = stat.3pops.sim, 
##     tol = 0.05, method = "mnlogistic")
## Data:
##  postpr.out$values (7500 posterior samples)
## Models a priori:
##  bott, const, exp
## Models a posteriori:
##  bott, const, exp
## 
## Proportion of accepted simulations (rejection):
##   bott  const    exp 
## 0.8487 0.1509 0.0004 
## 
## Bayes factors:
##            bott     const       exp
## bott     1.0000    5.6228 2121.6667
## const    0.1778    1.0000  377.3333
## exp      0.0005    0.0027    1.0000
## 
## 
## Posterior model probabilities (mnlogistic):
##   bott  const    exp 
## 0.9369 0.0628 0.0004 
## 
## Bayes factors:
##            bott     const       exp
## bott     1.0000   14.9246 2508.9790
## const    0.0670    1.0000  168.1105
## exp      0.0004    0.0059    1.0000
```

```r
summary(modsel.ch)
```

```
## Call: 
## postpr(target = stat.voight["chinese", ], index = models, sumstat = stat.3pops.sim, 
##     tol = 0.05, method = "mnlogistic")
## Data:
##  postpr.out$values (7500 posterior samples)
## Models a priori:
##  bott, const, exp
## Models a posteriori:
##  bott, const, exp
## 
## Proportion of accepted simulations (rejection):
##   bott  const    exp 
## 0.6837 0.3159 0.0004 
## 
## Bayes factors:
##            bott     const       exp
## bott     1.0000    2.1646 1709.3333
## const    0.4620    1.0000  789.6667
## exp      0.0006    0.0013    1.0000
## 
## 
## Posterior model probabilities (mnlogistic):
##   bott  const    exp 
## 0.7610 0.2389 0.0001 
## 
## Bayes factors:
##             bott      const        exp
## bott      1.0000     3.1853 10840.7807
## const     0.3139     1.0000  3403.3749
## exp       0.0001     0.0003     1.0000
```

```r
res.gfit.bott=gfit(target=stat.voight["italian",], 
                   sumstat=stat.3pops.sim[models=="bott",],
                   statistic=mean, nb.replicate=100) 
plot(res.gfit.bott, main="Histogram under H0")

 res.gfit.exp=gfit(target=stat.voight["italian",], 
                   sumstat=stat.3pops.sim[models=="exp",], 
                   statistic=mean, nb.replicate=100) 
 res.gfit.const=gfit(target=stat.voight["italian",], 
                     sumstat=stat.3pops.sim[models=="const",], 
                     statistic=mean, nb.replicate=100) 
 summary(res.gfit.bott)
```

```
## $pvalue
## [1] 0.62
## 
## $s.dist.sim
##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
##   1.620   1.909   2.135   2.230   2.439   4.210 
## 
## $dist.obs
## [1] 1.997769
```

```r
 summary(res.gfit.exp)
```

```
## $pvalue
## [1] 0
## 
## $s.dist.sim
##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
##   1.588   1.841   2.021   2.199   2.387   4.373 
## 
## $dist.obs
## [1] 5.181088
```

```r
 summary(res.gfit.const)
```

```
## $pvalue
## [1] 0
## 
## $s.dist.sim
##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
##   1.526   1.753   2.028   2.076   2.313   3.225 
## 
## $dist.obs
## [1] 3.610239
```

```r
 gfitpca(target=stat.voight["italian",], 
         sumstat=stat.3pops.sim, index=models, cprob=.1)
```

![plot of chunk abcpackage](figure/abcpackage-2.png) 

```r
  require(abc.data) 
 data(ppc) 
 mylabels <- c("Mean nucleotide diversity","Mean Tajima's D", "Var Tajima's D") 
 par(mfrow = c(3,1), mar=c(5,2,4,0))
 for (i in c(1:3)){
   hist(post.bott[,i],breaks=40, xlab=mylabels[i], main="") 
   abline(v = stat.voight["italian", i], col = 2) 
 }
```

![plot of chunk abcpackage](figure/abcpackage-3.png) 

```r
 stat.italy.sim <- subset(stat.3pops.sim, subset=models=="bott") 
 head(stat.italy.sim)
```

```
##                  pi      TajD.m    TajD.v
## 110002 0.0010531112 0.057649360 1.3024486
## 210000 0.0012026666 0.342608757 1.1042096
## 310000 0.0008920002 0.247601809 0.9147642
## 410002 0.0015328889 0.470767633 1.5339313
## 51002  0.0008988888 0.008920568 1.0751214
## 61002  0.0019851108 0.208063980 0.8684532
```

```r
 head(par.italy.sim)
```

```
##          Ne        a duration    start
## 1 14621.380 28.58894 5428.309 40421.04
## 2 13098.281 18.65774 5081.701 43255.28
## 3  7936.504 12.00553 3369.698 50781.08
## 4 17823.659 42.57813 7857.355 46397.16
## 5 12294.555 23.60331 6633.745 58208.44
## 6 25626.369 40.09893 7067.745 50385.51
```

```r
  cv.res.rej <- cv4abc(data.frame(Na=par.italy.sim[,"Ne"]),
                       stat.italy.sim, nval=10,  
                       tols=c(.005,.01, 0.05), method="rejection") 
  cv.res.reg <- cv4abc(data.frame(Na=par.italy.sim[,"Ne"]), 
                       stat.italy.sim, nval=10,  
                       tols=c(.005,.01, 0.05), method="loclinear") 
 summary(cv.res.rej)
```

```
## Prediction error based on a cross-validation sample of 10
```

```
##               Na
## 0.005 0.05287698
## 0.01  0.05474539
## 0.05  0.06086638
```

```r
 summary(cv.res.reg)
```

```
## Prediction error based on a cross-validation sample of 10
```

```
##               Na
## 0.005 0.02512382
## 0.01  0.02508822
## 0.05  0.02358313
```

```r
  par(mfrow=c(1,2), mar=c(5,3,4,.5), cex=.8) 
  plot(cv.res.rej, caption="Rejection") 
 plot(cv.res.reg, caption="Local linear regression")
```

![plot of chunk abcpackage](figure/abcpackage-4.png) 

```r
  res <- abc(target=stat.voight["italian",], 
             param=data.frame(Na=par.italy.sim[, "Ne"]), 
             sumstat=stat.italy.sim, tol=0.05, 
             transf=c("log"), method="neuralnet")
```

```
## 12345678910
## 12345678910
```

```r
 res
```

```
## Call:
## abc(target = stat.voight["italian", ], param = data.frame(Na = par.italy.sim[, 
##     "Ne"]), sumstat = stat.italy.sim, tol = 0.05, method = "neuralnet", 
##     transf = c("log"))
## Method:
## Non-linear regression via neural networks
## with correction for heteroscedasticity
## 
## Parameters:
## Na
## 
## Statistics:
## pi, TajD.m, TajD.v
## 
## Total number of simulations 50000 
## 
## Number of accepted simulations:  2500
```

```r
 summary(res)
```

```
## Call: 
## abc(target = stat.voight["italian", ], param = data.frame(Na = par.italy.sim[, 
##     "Ne"]), sumstat = stat.italy.sim, tol = 0.05, method = "neuralnet", 
##     transf = c("log"))
## Data:
##  abc.out$adj.values (2500 posterior samples)
## Weights:
##  abc.out$weights
## 
##                               Na
## Min.:                   7449.707
## Weighted 2.5 % Perc.:   8674.862
## Weighted Median:       11389.507
## Weighted Mean:         11695.192
## Weighted Mode:         10975.070
## Weighted 97.5 % Perc.: 15970.046
## Max.:                  20962.844
```

```r
par(mfrow=c(2,1),cex=.8) 
 hist(res)
 plot(res, param=par.italy.sim[, "Ne"])
```

![plot of chunk abcpackage](figure/abcpackage-5.png) ![plot of chunk abcpackage](figure/abcpackage-6.png) 

# EasyABC

## Model

Let's consider a stochastic individual-based model to demonstrate how `EasyABC` can be used. This model is drawn from Jabot (2010), representing the stochastic dynamics of an ecological community. 

Each species in the community are given by a local competitive ability as determined by a filtering function of one quantitative trait $t$: $F(t)=1+A\exp\bigg(\frac{-(t-h)^2}{2\sigma^2}\bigg)$. At each time step, one individual drawn at random dies in a local community of size $J$. It is replaced either by an immigrant from the regional pool with probability $\frac{I}{I+J-1}$ or by the descendant of a local individual. Parameter $I$ measures the amount of immigration from the regional pool into the local community. The probability that the replacing individual is of species $i$ is proportional to the abundance of this species in the local community multiplied by its local competitive ability $F_i$. Here, the parameters of interest are $I,h,A,\sigma$ and the local community size $J$ is fixed at 500. The summary statistics are species richness of the community, Shannon's index, the mean of the trait value among individuals and the skewness of the trait value distribution. The model is a built-in model in this package.

## ABC schemes

There are 4 types of schemes available in `EasyABC`: standard rejection algorithm, sequential schemes, coupled to MCMC sequential schemes and a Simulated Annealing algorithm, implemented by `ABC_rejection(), ABC_sequential(), ABC_mcmc()` and `SABC()`, respectively.

All these functions require a model used to generate data and return a set of summary statistics, prior distributions, summary statistics from the observed data. 

In our example, we have summary statistics of the observed data 

```r
sum_stat_obs <- c(richness=100,shannon=2.5,meantrait=20,skewness=30000)
```
and assume prior distributions 

```r
trait_prior <- list(c("unif",3,5),
                   c("unif",-2.3,1.6),
                   c("unif",-25,125),
                   c("unif",-.7,3.2))
```


First, let's look at the abc rejection algorithm. 

```r
set.seed(9)
(ABC_rej <- ABC_rejection(model=trait_model, prior=trait_prior,nb_simul=100,
                         summary_stat_target=sum_stat_obs,tol=.1,
                         use_seed=TRUE))
```

```
## $param
##           [,1]       [,2]       [,3]        [,4]
##  [1,] 3.443203 -2.2054878   6.067853  0.14136084
##  [2,] 4.025082  0.7987833  -1.574728  0.04390927
##  [3,] 4.298096  0.9562522   5.929186 -0.22679304
##  [4,] 4.920236  0.5652761  18.788669  0.22884513
##  [5,] 4.221460  1.0181108  -7.818319  2.77775992
##  [6,] 3.555287 -1.9756224   4.499501  2.25331504
##  [7,] 4.578879 -0.4494255   9.807345 -0.18367680
##  [8,] 4.468684  0.2788487   8.046597  0.36940514
##  [9,] 4.733991  1.0632640  11.948136  0.97694971
## [10,] 4.286998  1.5845963 -24.536332  2.69545417
## 
## $stats
##       [,1]     [,2]    [,3]     [,4]
##  [1,]   68 2.864373 33.0070 24250.34
##  [2,]   77 1.523352 12.4892 36114.16
##  [3,]   72 1.916359 13.5280 23673.86
##  [4,]  123 3.441161 29.2958 22165.77
##  [5,]   92 2.695370  7.4828 20098.59
##  [6,]   76 3.181871 23.6530 30104.14
##  [7,]  125 2.694780 25.1790 23808.99
##  [8,]  113 2.777789 21.1614 27930.82
##  [9,]  116 3.218911 19.9760 21025.62
## [10,]   95 2.231885 14.4554 32660.25
## 
## $weights
##  [1] 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1
## 
## $stats_normalization
## [1]    42.828665     1.177572    23.618121 15176.184404
## 
## $nsim
## [1] 100
## 
## $nrec
## [1] 10
## 
## $computime
## [1] 21.50674
```


```r
trDens <- function(pr,n=100000) {
    lapply(pr,
           function(x)
               do.call(paste0("r",x[1]),
                       as.list(c(n,as.numeric(x[2:3])))))
}
par(mfrow=c(2,2))
mapply(function(x,y) {
           plot(density(x)); lines(density(y),col=2);
           rug(y,col=2)
       },
       trDens(trait_prior),
       split(ABC_rej$stats,col(ABC_rej$stats)))
```

```
## Warning in rug(y, col = 2): some values will be clipped
```

```
## Warning in rug(y, col = 2): some values will be clipped
```

```
## Warning in rug(y, col = 2): some values will be clipped
```

![plot of chunk unnamed-chunk-1](figure/unnamed-chunk-1-1.png) 

```
##       [,1]     [,2]    [,3]     [,4]
##  [1,]   68 1.523352  7.4828 20098.59
##  [2,]   72 1.916359 12.4892 21025.62
##  [3,]   76 2.231885 13.5280 22165.77
##  [4,]   77 2.694780 14.4554 23673.86
##  [5,]   92 2.695370 19.9760 23808.99
##  [6,]   95 2.777789 21.1614 24250.34
##  [7,]  113 2.864373 23.6530 27930.82
##  [8,]  116 3.181871 25.1790 30104.14
##  [9,]  123 3.218911 29.2958 32660.25
## [10,]  125 3.441161 33.0070 36114.16
```

Here, the `tol` is the percentage of simulations that are nearest the
observed summary statistics. The model must be a R function, taking a
vector of model parameter values as arguments and return a vector of
summary statistics. The available prior distribution are uniform,
normal, lognormal and exponential.





ABC rejection algorithm is computationally inefficient.


The idea of ABC-MCMC is to perform a Metropolis-Hastings algorithm to
explore e parameter space, and in replacing the step of likelihood
ratio computation by simulations of the model.


```r
ABC_Marjoram_original<-ABC_mcmc(method = "Marjoram_original",
                                model = trait_model,
                                prior = trait_prior,
                                summary_stat_target = sum_stat_obs,
                                n_rec=10, use_seed=T,dist_max=0.2)
```

```
## [1] "Warning: summary statistics are normalized by default through a division by the target summary statistics - it may not be appropriate to your case."
## [1] "Consider providing normalization constants for each summary statistics in the option 'tab_normalization' or using the method 'Marjoram' which automatically determines these constants."
## [1] "Warning: default values for proposal distributions are used - they may not be appropriate to your case."
## [1] "Consider providing proposal range constants for each parameter in the option 'proposal_range' or using the method 'Marjoram' which automatically determines these constants."
```

```r
ABC_Marjoram_original
```

```
## $param
##           [,1]       [,2]      [,3]        [,4]
##  [1,] 4.025625 -0.5086612  3.512861 -0.20074989
##  [2,] 4.060393 -0.6725875 -0.334210 -0.09272831
##  [3,] 4.052283 -0.8706419  3.467696  0.05373258
##  [4,] 4.097529 -0.6730886  3.095251  0.34470678
##  [5,] 4.175267 -0.5518192 12.210223  0.08984576
##  [6,] 4.202368 -0.6079223  5.959094  0.27025277
##  [7,] 4.147041 -0.5023525  6.526645  0.26261344
##  [8,] 4.013795 -0.5853917 10.066829  0.36941001
##  [9,] 3.957147 -0.5356250 -1.371229  0.36205109
## [10,] 3.956110 -0.6483162  1.555759  0.34795058
## 
## $stats
##       [,1]     [,2]    [,3]     [,4]
##  [1,]   93 2.655477 22.5962 28696.59
##  [2,]   91 2.249648 15.7756 31020.88
##  [3,]   87 2.816062 23.0922 29703.51
##  [4,]   88 2.374516 16.6820 27661.34
##  [5,]   80 2.144095 24.5394 28417.54
##  [6,]   87 2.352776 21.8610 34762.47
##  [7,]   91 1.900495 17.9042 27231.73
##  [8,]   98 2.857272 20.5572 26153.60
##  [9,]   79 2.381935 14.5616 33066.88
## [10,]   82 2.653784 15.6178 34191.11
## 
## $dist
##  [1] 0.02750595 0.06390009 0.05688516 0.05051924 0.11456477 0.05422758
##  [7] 0.08510074 0.03803781 0.13072161 0.10371021
## 
## $stats_normalization
## [1]   100.0     2.5    20.0 30000.0
## 
## $epsilon
## [1] 0.1307216
## 
## $nsim
## [1] 105
## 
## $n_between_sampling
## [1] 10
## 
## $computime
## [1] 14.3223
```



Wegmann et al.(2009) proposed a number of improvements by perform a calibration step so that the algorithm automatically determines the tolerance threshold, the scaling of the summary statistics and the scaling of the jumps in the parameter space during the MCMC. 


```r
ABC_Marjoram<-ABC_mcmc(method = "Marjoram", model=trait_model,
                       prior=trait_prior,summary_stat_target=sum_stat_obs,
                       n_rec=10,n_calibration=10,tolerance_quantile=0.2,
                       use_seed=T)
ABC_Marjoram
```

```
## $param
##           [,1]      [,2]     [,3]      [,4]
##  [1,] 4.615622 0.4821922 20.72179 1.4471800
##  [2,] 4.858034 0.3773646 20.14239 1.2804924
##  [3,] 4.265507 0.1908620 19.34228 1.3340515
##  [4,] 4.252422 0.3632274 17.06490 0.8723625
##  [5,] 4.872401 1.0818826 16.85947 0.7524166
##  [6,] 4.209656 1.1617568 15.01359 0.6259889
##  [7,] 4.176102 1.2172701 15.11159 0.7525155
##  [8,] 4.148964 0.5954615 16.45801 1.0667842
##  [9,] 4.223933 0.4551259 17.94384 1.3183029
## [10,] 3.824752 0.1685043 18.50001 1.5392957
## 
## $stats
##       [,1]     [,2]    [,3]     [,4]
##  [1,]  124 3.490041 27.7756 13397.28
##  [2,]  149 3.760674 30.7078 19471.04
##  [3,]   87 3.279558 24.8134 14598.54
##  [4,]   90 2.605515 22.3526 13483.51
##  [5,]  120 3.562350 23.7848 18195.86
##  [6,]   75 2.143451 20.1010 18500.26
##  [7,]   70 2.543757 19.5084 13830.77
##  [8,]   82 1.912106 22.3266 15745.87
##  [9,]   94 3.130851 24.9802 14886.62
## [10,]   80 2.666293 22.8688 11631.12
## 
## $dist
##  [1] 6.608215 5.739778 5.078051 4.851108 4.082625 2.799517 5.051461
##  [8] 4.163199 4.607176 6.174634
## 
## $stats_normalization
## [1]   42.8324903    0.9098068   14.0770866 7574.1255731
## 
## $epsilon
## [1] 6.608215
## 
## $nsim
## [1] 101
## 
## $n_between_sampling
## [1] 10
## 
## $computime
## [1] 13.18047
```



Wegmann et al.(2009) also proposed additional modification, among which a partial least squares transformation of the summary statistics.


```r
ABC_Wegmann <-ABC_mcmc(method="Wegmann",model=trait_model,
                       prior=trait_prior,summary_stat_target=sum_stat_obs,
                       n_rec=10,n_calibration=10,
                       tolerance_quantile=.2,use_seed=T)
ABC_Wegmann
```

```
## $param
##           [,1]         [,2]       [,3]       [,4]
##  [1,] 4.499155  1.297495945  6.9337986 -0.1865008
##  [2,] 4.763208 -0.004513408 19.3713014  0.5281145
##  [3,] 4.369882  0.888541300 17.2874349  0.6496941
##  [4,] 4.573950 -0.638742870  8.6766369  1.6039398
##  [5,] 4.377385 -0.159468757 -2.5409458  1.0230333
##  [6,] 4.629016  0.442592959 -1.0195019  0.8268515
##  [7,] 3.894131  0.569551755 -0.2617154  0.7005020
##  [8,] 3.825115 -0.572013717  1.0902283  0.9734237
##  [9,] 3.249709 -1.599537512 20.1621843  2.2640173
## [10,] 3.318184 -2.268249540 37.7931055  2.3260240
## 
## $stats
##       [,1]      [,2]    [,3]     [,4]
##  [1,]   87 2.1988895 13.9530 20278.38
##  [2,]  142 3.5341083 32.6886 20247.10
##  [3,]   91 3.0377016 22.5946 12053.47
##  [4,]  137 3.7648802 23.9038 23709.75
##  [5,]  100 2.3545653 14.7514 38244.56
##  [6,]  115 2.2675691 15.2374 35331.59
##  [7,]   50 0.8873868  5.6206 22184.64
##  [8,]   63 1.7362153 10.1964 25664.53
##  [9,]   69 3.1626620 30.8766 13763.13
## [10,]   75 3.5898031 47.2268 14384.18
## 
## $dist
##  [1] 1.5852053 2.8203886 3.6053214 1.9484549 1.1852823 0.5716259 4.8698573
##  [8] 1.8660223 3.7016035 5.4920808
## 
## $epsilon
## [1] 5.492081
## 
## $nsim
## [1] 101
## 
## $n_between_sampling
## [1] 10
## 
## $min_stats
## [1]     37.0000000      0.7696222     13.9530000 -43919.4383705
## 
## $max_stats
## [1]   173.000000     4.683112    80.327000 20278.376398
## 
## $lambda
## [1] -0.6060606  1.8181818  0.6060606  3.0303030
## 
## $geometric_mean
## [1] 1.410288 1.570134 1.497598 1.595027
## 
## $boxcox_mean
## [1] 0.5175572 0.5518913 0.5504631 0.4668778
## 
## $boxcox_sd
## [1] 0.3340018 0.3475313 0.2727437 0.2503313
## 
## $pls_transform
##            [,1]       [,2]       [,3]       [,4]
## [1,] -0.4441504 -0.5019130 -0.5443392  0.5077051
## [2,]  0.6241037  0.4952579 -0.4023782  0.4913720
## [3,]  0.4786942 -0.6912106 -0.2361821 -0.5043231
## [4,]  0.2305260 -0.3319468  0.6762211  0.6159497
## 
## $n_component
## [1] 4
## 
## $computime
## [1] 14.94008
```




Sequential algorithms aim at reducing the required number of simulations to reach a given quality of the posterior approximation. The underlying idea is to spend more time in the areas of the parameter space where simulation are frequently close to the target. Sequential algorithms consist in a first step of standard rejection ABC, followed by a number of steps where the sampling of the parameter space is the accepted parameter values in the previous iteration. There are 4 algorithms to perform sequential sampling schemes for ABC. Sequential sampling schemes have been shown to be more efficient than standard rejection-based procedures.



```r
ABC_Beaumont <- ABC_sequential(method="Beaumont", model=trait_model,
                               prior=trait_prior,nb_simul=10,
                               summary_stat_target=sum_stat_obs,
                               tolerance=c(8,5),use_seed=T)
ABC_Beaumont
```

```
## $param
##           [,1]       [,2]       [,3]       [,4]
##  [1,] 3.631665  0.3047942   2.333054  0.8683726
##  [2,] 4.120178  0.5722036  34.310406  1.6198185
##  [3,] 4.023458 -0.1185683  30.896169 -0.2581104
##  [4,] 4.629390 -0.2119455  -4.354964  1.8241002
##  [5,] 3.956036  0.5319058  -2.575405  1.0811903
##  [6,] 3.429980  0.3450022  -4.779742  2.0866940
##  [7,] 3.646171 -0.4381166   9.133693  0.1237754
##  [8,] 3.790101  0.6332963  16.549546 -0.5897978
##  [9,] 4.222762 -0.6231360 -10.032341  3.1297445
## [10,] 4.342668 -1.1884012   4.840433  2.2356512
## 
## $stats
##       [,1]     [,2]    [,3]      [,4]
##  [1,]   45 1.856191  6.9888 19590.294
##  [2,]   82 2.826173 36.7856  5687.265
##  [3,]   75 1.992921 33.9450  6726.180
##  [4,]  129 3.370104 24.0724 29623.988
##  [5,]   73 1.304912  9.6024 33035.901
##  [6,]   51 1.864548  5.3566 16695.770
##  [7,]   46 1.023688 15.1060 16040.207
##  [8,]   55 1.395521 20.4886 12695.128
##  [9,]  124 4.268797 24.0238 26542.147
## [10,]  129 4.330309 27.5042 18698.135
## 
## $weights
##  [1] 0.08283108 0.06699719 0.06578545 0.11977259 0.09204063 0.11473926
##  [7] 0.08034671 0.07902864 0.18170518 0.11675325
## 
## $stats_normalization
## [1]    47.001182     1.484152    18.500006 13041.975634
## 
## $epsilon
## [1] 4.49342
## 
## $nsim
## [1] 58
## 
## $computime
## [1] 12.5303
```
This method is in fact the ABC population Monte Carlo algorithm.


```r
ABC_Drovandi<-ABC_sequential(method="Drovandi", model=trait_model, prior=trait_prior,nb_simul=10, summary_stat_target=sum_stat_obs, tolerance_tab=3, c=.7,use_seed=TRUE)
ABC_Drovandi
```

```
## $param
##           [,1]       [,2]      [,3]        [,4]
##  [1,] 3.854884 -0.7812884  9.338832  2.24261870
##  [2,] 4.050994 -0.5394405 10.032290  1.77737673
##  [3,] 3.253083 -2.1719168 13.179415  1.38913108
##  [4,] 4.429776  1.3403544  4.036977  0.34979695
##  [5,] 3.202462 -0.9339994  8.254531  2.63185106
##  [6,] 3.646928  0.3063793 10.657075  2.10787517
##  [7,] 4.501514  0.6187295  5.059859 -0.02888015
##  [8,] 4.542435  0.3681093  7.185874  2.36680941
##  [9,] 3.773672 -0.1832858  3.665842 -0.30499737
## [10,] 3.733383 -0.5277339  5.307766  1.85764571
## 
## $stats
##       [,1]     [,2]    [,3]     [,4]
##  [1,]   95 3.119349 18.8538 20849.04
##  [2,]   76 2.693976 16.8724 19749.50
##  [3,]   69 3.003047 26.0116 24865.22
##  [4,]   84 2.392082 12.4274 31277.51
##  [5,]   50 2.285524 14.8084 19514.36
##  [6,]   64 2.797367 15.4942 16477.50
##  [7,]   95 1.866312 14.7108 25364.24
##  [8,]  114 4.021674 14.9030 20651.70
##  [9,]   64 1.674043 11.1628 25934.66
## [10,]   68 3.025428 12.7308 17421.92
## 
## $weights
##  [1] 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1
## 
## $stats_normalization
## [1]    47.773699     1.107001    19.974629 12835.418051
## 
## $epsilon
## [1] 2.570942
## 
## $nsim
## [1] 40
## 
## $computime
## [1] 6.289309
```


```r
ABC_Delmoral<-ABC_sequential(method="Delmoral",model=trait_model,
                             prior=trait_prior,
                             nb_simul =10, summary_stat_target=sum_stat_obs,
                             alpha=.5,
                             tolerance=3,use_seed=T)
ABC_Delmoral
```

```
## $param
##           [,1]       [,2]      [,3]       [,4]
##  [1,] 4.172234  1.1422448 10.537537 -0.5223025
##  [2,] 4.384958  1.0438269 13.838054  0.4753563
##  [3,] 3.858966 -0.5697480  2.279365  1.1587094
##  [4,] 3.654147 -1.2513668  8.269732  0.3925723
##  [5,] 4.411712 -0.4052618  2.935974  1.4582950
##  [6,] 4.411712 -0.4052618  2.935974  1.4582950
##  [7,] 4.172234  1.1422448 10.537537 -0.5223025
##  [8,] 4.411712 -0.4052618  2.935974  1.4582950
##  [9,] 4.487768  0.4515080 17.380318  0.4013202
## [10,] 4.411712 -0.4052618  2.935974  1.4582950
## 
## $stats
##       [,1]     [,2]    [,3]     [,4]
##  [1,]   67 1.315733 17.1822 20146.43
##  [2,]   91 2.717681 20.5250 18248.84
##  [3,]   61 2.099537 10.7416 25034.71
##  [4,]   64 2.333708 19.7966 28177.38
##  [5,]  107 3.583932 18.8048 38072.16
##  [6,]  107 3.583932 18.8048 38072.16
##  [7,]   67 1.315733 17.1822 20146.43
##  [8,]  107 3.583932 18.8048 38072.16
##  [9,]   92 2.367365 25.2964 17639.27
## [10,]  107 3.583932 18.8048 38072.16
## 
## $weights
##  [1] 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1
## 
## $stats_normalization
## [1]   62.115037    1.207333   18.519262 9459.269362
## 
## $epsilon
## [1] 2.352663
## 
## $nsim
## [1] 43
## 
## $computime
## [1] 8.366469
```
This is an adaptive sequential Monte Carlo method.



```r
ABC_Lenormand <- ABC_sequential(method="Lenormand",model=trait_model,
                                prior=trait_prior,nb_simul=10,
                                summary_stat_target=sum_stat_obs,
                                p_acc_min=.4,
                                use_seed=T)
ABC_Lenormand
```

```
## $param
##          [,1]        [,2]       [,3]        [,4]
## [1,] 4.683032  0.81660902 -0.3774548  0.35229368
## [2,] 3.689013 -1.48833307  0.9051628 -0.68639704
## [3,] 4.729780  0.92264846 -0.4626908  0.40023990
## [4,] 4.958062  1.45396937 -0.7161140  0.62670318
## [5,] 4.353716  0.09681345  0.4686537  0.05445256
## 
## $stats
##      [,1]     [,2]    [,3]     [,4]
## [1,]  104 2.280234 13.1112 34459.96
## [2,]   83 2.397633 20.1438 35536.30
## [3,]  114 2.172903 13.3518 32242.10
## [4,]   97 2.104784  9.6520 27880.86
## [5,]   88 2.183578 12.5724 35604.77
## 
## $weights
## [1] 0.433252109486733705 0.433252109486733705 0.133494474828060566
## [4] 0.000001306197326461 0.000000000001145601
## 
## $stats_normalization
## [1]    45.165867     1.082132    21.483028 15258.607377
## 
## $epsilon
## [1] 0.4105523
## 
## $nsim
## [1] 35
## 
## $computime
## [1] 5.422222
```


```r
data <- rbind(data.frame(ABC_rej$par,method="rejection"),
              data.frame(ABC_Marjoram_original$par, method="Marjoram_original"),
              data.frame(ABC_Marjoram$par,method="Marjoram"),
              data.frame(ABC_Wegmann$par,method="Wegmann"),
              data.frame(ABC_Beaumont$par,method="Beaumont"),
              data.frame(ABC_Drovandi$par,method="Drovandi"),
              data.frame(ABC_Delmoral$par,method="Delmoral"),
              data.frame(ABC_Lenormand$par,method="Lenormand")
              )
library(ggplot2)
g1<- ggplot(data) +
  geom_histogram(aes(x=X1,colour=method,fill=method),binwidth=0.1) + 
  geom_density(aes(x=X1,colour=method)) + 
  facet_wrap(~method)
g2 <- ggplot(data) +
  geom_histogram(aes(x=X2,colour=method,fill=method),binwidth=0.1) + 
  geom_density(aes(x=X2,colour=method)) + 
  facet_wrap(~method)
g3 <- ggplot(data) +
  geom_histogram(aes(x=X3,colour=method,fill=method),binwidth=0.1) + 
  geom_density(aes(x=X3,colour=method)) + 
  facet_wrap(~method)
g4 <- ggplot(data) +
  geom_histogram(aes(x=X4,colour=method,fill=method),binwidth=0.1) + 
  geom_density(aes(x=X4,colour=method)) + 
  facet_wrap(~method)
g1
```

![plot of chunk dataframe](figure/dataframe-1.png) 

```r
g2
```

![plot of chunk dataframe](figure/dataframe-2.png) 

```r
g3
```

![plot of chunk dataframe](figure/dataframe-3.png) 

```r
g4
```

![plot of chunk dataframe](figure/dataframe-4.png) 


\section{Exercise}
1. Try the socks example by the two packages

```r
sim_sock <- function(nb.mu,nb.sd,beta.a,beta.b){
# n_socks is positive and discrete, we can use Possion 
#  (problemic: mean and variance is same)
# or use negative binomal
# suppose we have a family of 4 and each person changes socks 
#  around 5 times a week, so we would have 20 
# pairs of socks, so your mean is 20*2 = 40. our sd could be 15 
prior_mu <- nb.mu
prior_sd <- nb.sd
prior_size <- prior_mu^2/(prior_sd^2-prior_mu)
n_socks <-rnbinom(1,mu=prior_mu,size=prior_size)
# proprotion of socks that are pair is Beta with a=2, b=2
prop_pairs <- rbeta(1,shape1=beta.a,shape2=beta.b)
n_pairs <- round(n_socks/2*prop_pairs)
n_odd <- n_socks-n_pairs*2
n_picked <- 11
socks <- rep(seq_len(n_pairs+n_odd),rep(c(2,1),c(n_pairs,n_odd)))
picked_socks<-sample(socks,size=min(n_picked,n_socks))
sock_counts <- table(picked_socks)
c(unique=sum(sock_counts==1),pairs=sum(sock_counts==2),nsocks=n_socks,npairs=n_pairs,nodd=n_odd,
  proppairs=prop_pairs)
}
simdata = data.frame(t(replicate(100000,sim_sock(40,15,2,2))))
```

2. Play the functions with toy model:

```r
toy_model <- function(x) {2*x+5+rnorm(1,0,0.1)}
toy_prior <- list(c("unif",0,1))
```

3. Suppose a state-space model is given by 
$N(t+1) \sim Normal(N(t) + b, \sigma_{proc}^2)$,
$N_{obs}(t) \sim Normal(N(t), \sigma_{obs}^2)$. 
The parameters of interest are $b, \sigma_{proc}^2, \sigma_{obs}^2,N(0)$.
Suppose your true parameter values are $b=3,\sigma_{proc}^2=1, \sigma_{obs}^2=1.2, N(0)=100$. Simulate a data set as your observed data and obtain the summary statistics mean and standard deviation. 
Then use the model and different prior distributions to see how different abc schemes work.
