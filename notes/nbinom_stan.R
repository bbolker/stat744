mcode <-
"data {
    int<lower=0> N; // number of data points
    real x[N];    // predictor variable
    int y[N];     // response
   }
parameters {
    // need to put upper/lower bounds on parameters
    //  ... otherwise chain wanders off to outer space
    real <lower=-3,upper=3> a;
    real <lower=-5,upper=5> b;
}
model {
    vector[N] eta;
    // would like to make this vectorized, 
    //   but this way works ...
    for (n in 1:N) {
       eta[n] <- exp(a+b*x[n]);
       y[n] ~ neg_binomial_2(1.0,eta[n]);
    }
}
"

N <- 20
set.seed(101)
x <- rnorm(N)
y <- rnbinom(N,mu=1,size=exp(1+0.5*x))
library("rstan")
options(mc.cores = parallel::detectCores())
## all default options: runs
s1 <- stan(model_code=mcode,data=list(x=x,y=y,N=N),iter=20000,seed=1001)
pairs(s1,gap=0)
smat <- do.call(cbind,extract(s1,c("a","b")))
pairs(smat,pch=".",gap=0,col=adjustcolor("black",alpha=0.5))
write.csv(smat,row.names=FALSE,file="stan_out.csv")
emdbook::HPDregionplot(smat,prob=0.99)
cov2cor(var(smat))
sqrt(diag(var(smat)))
