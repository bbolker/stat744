Particle filtering II
========================================================
author: Ben Bolker
date: 22 October
transition:fade

Parameter estimation
========================================================

- Like the Kalman filter, filtering is only the first step
- (maybe enough for some applications)
- would also like to be able to **estimate parameters**
- ideas from Kalman filter
   - can integrate *dynamical* parameters into update step
   - still need to optimize over variance parameter
- how do we estimate parameters for the PF?

Particle MCMC
====================================

- combine filtering with MCMC on the parameters
- various different ways to implement the combination of PF and MCMC ("pseudo-marginal", "particle marginal Metropolis-Hastings" (notes from Darren Wilkinson:[1](https://darrenjw.wordpress.com/2011/05/17/the-particle-marginal-metropolis-hastings-pmmh-particle-mcmc-algorithm/
), [2](https://darrenjw.wordpress.com/2011/05/15/mcmc-monte-carlo-likelihood-estimation-and-the-bootstrap-particle-filter/)))

Particle marginal Metropolis-Hastings (PMMH)
===============

- sample a new value $\theta^*$ from proposal distribution $f(\theta^*|\theta)$
- run the bootstrap filter with $\theta^*$
- sample *one* trajectory using the final set of weights
- M-H step: accept with probability
$$
A = \frac{\hat p_{\theta^*}(y_{1:T}) p(\theta^*) f(\theta|\theta^*)}{\hat p_{\theta}(y_{1:T}) p(\theta) f(\theta^*|\theta)}
$$

Iterated filtering: the idea
==================

- incorporate parameters in the filtering process
- each particle gets its own parameter vector
- jointly sampling high-probability trajectories and parameter sets
- perturb parameter sets between observation steps
- run joint filter repeatedly, reducing perturbation size at each pass
- *Bayesian map*; related to *data cloning* because we are running the particles through the data many times

Iterated filtering: the process
==================
![](MIF2A.png)

Iterated filtering, part 2
==================
![](MIF2B.png)

Iterated filtering: practical considerations
===================

- need to run many, many simulations:  
usually means writing them in C/C++  
(`pomp` "Csnippets", `Rcpp`)
- *particle exhaustion*: how many particles are needed?
- tuning:
    - how many particles?
    - parallel runs?
    - *cooling schedule* (cf. *simulated annealing*)
    
Practical stuff, cont'd
========

- convergence diagnostics
- rough, multimodal surfaces; multiple chains, etc etc
- MLE approach, so need profiling for confidence intervals
- "plug & play" property: only need to define dynamical process and observation likelihood model

MIF vs PF
===================

From Ionides *et al.* 2015:

![](MIF2_1.png)

A=IF1, B=IF2, C=PMCMC, D=densities from 8 PMCMC chains
