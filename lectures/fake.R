set.seed(22222)

# Use an odd number for len if you want to see convergence at the center point
len <- 11
level <- 0.05
noise <- 4
 
x <- 1:len
y <- x+rnorm(length(x), sd=noise)
 
fake <- data.frame(x=x, y=y)

