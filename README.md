Materials for a course in parameter estimation for (nonlinear) stochastic dynamical systems.   Fall 2015.

Everything below is tentative/subject to modification.

**Schedule**: Monday/Thursday 14:30-16:00, Hamilton Hall 207.

**Course goal/plan**: broad practical survey of methods for estimating parameters from nonlinear stochastic dynamical systems, focused on ecological/evolutionary/epidemiological examples. Most classes will consist of student presentations/worked exercises on specific methods.

**Background**: fluency in statistical computation in (preferably) R or another programming language; basic understanding of maximum likelihood/Bayesian estimation methods (e.g., up through chapter 6-7 in Bolker *Ecological Models and Data*).

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

* `BUGS` and derivatives
* Stan
* NIMBLE
* adaptive differentiation/Laplace approximation tools (AD Model Builder, Template Model Builder)
* `pomp`

Sources
===========

* Casella and Robert
* Doucet *et al.*
* Bolker *Ecological Models and Data* chapter 11
