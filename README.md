Materials for a course in parameter estimation for (nonlinear) stochastic dynamical systems.   Fall 2015.

Everything below is tentative/subject to modification.

**Schedule**: Monday/Thursday 14:30-16:00, Hamilton Hall 207.  (This will certainly conflict with some schedules; priority for rescheduling will be given in the order: course organizer > enrolled students > postdocs and unenrolled students > other faculty.)

**Course goal/plan**: A broad, practically oriented survey of methods for estimating parameters from (nonlinear stochastic) dynamical systems, focused on ecological/evolutionary/epidemiological examples. Most classes will consist of student presentations/worked exercises on specific methods.

**Background**: Fluency in statistical computation in (preferably) R or another programming language; basic understanding of maximum likelihood/Bayesian estimation methods (e.g., chapters 6-7 in Bolker [Ecological Models and Data](http://ms.mcmaster.ca/~bolker/emdbook/)).

Topics
==========

* Trajectory/gradient matching
* Markov chain Monte Carlo, especially
   * Gibbs sampling
   * Hamiltonian MCMC
* Filtering techniques
   * Kalman, extended K., ensemble K.
   * Particle/Sequential Monte Carlo/iterated filtering; particle MCMC
* Importance (re)sampling
* Probe-matching/synthetic likelihood
* Approximate Bayesian computation

Software tools
============

* [BUGS](http://www.mrc-bsu.cam.ac.uk/software/bugs/) and derivatives ([JAGS](http://mcmc-jags.sourceforge.net/) etc.)
* [Stan](mc-stan.org) (or see [here!](https://www.youtube.com/watch?v=pWow8Qe1snQ))
* [NIMBLE](http://r-nimble.org/)
* adaptive differentiation/Laplace approximation tools ([AD Model Builder](http://www.admb-project.org/), [Template Model Builder](https://github.com/kaskr/adcomp))
* [pomp](http://kingaa.github.io/pomp/)


Sources
===========

(as with this entire document, these are initial/tentative ideas)

* Robert and Casella (*MC Statistical Methods* and/or *MC methods with R*)
* Doucet *et al.* (*Intro to sequential MC*)
* Bolker *Ecological Models and Data* chapter 11
