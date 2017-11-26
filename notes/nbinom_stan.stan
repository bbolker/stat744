data {
    int<lower=0> N; // number of data points
    real x[J];    // predictor variable
    int y[J];     // response
   }
parameters {
    real a;
    real b;
}
//transformed parameters {
//    vector[J] eta;
//
//   eta <- exp(a+b*x);
//}
model {
    y ~ neg_binomial_2(1.0,eta)
}
