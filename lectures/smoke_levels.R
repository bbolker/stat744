library(ggplot2)
theme_set(theme_bw(base_size=18))

colorA <- 0.7
lLev <- 0.01
hLev <- 0.01
nLev <- 100
nLev <- 3
numBins <- 10

## Age vs fev

af <- (ggplot(smoke, aes(x=age, y=fev))
	+ ylab("Lung capacity")
)

afl <- (af
	+ stat_density_2d(aes(fill=..level..)
		, geom = "polygon"
		, bins=numBins
	)
)

print(afl)
print (afl <- afl + scale_fill_gradient(low="#F0F0FF", high="#131393"))

print(afl + geom_density_2d(color="black"))

print(af + aes(color=sex) + geom_density_2d())

## If we could get a decent color ramp…
# , alpha=colorA
# + geom_density_2d(color="black")

# Nor stat_density_2d nor scale_fill_gradient seems to take breaks=
# , breaks = seq(lLev, hLev, length.out=nLev)

# bins= works, but produces horrible pictures (pushes the low density too low)

library(hexbin)

print(afh <- af + geom_hex(binwidth=c(1,0.4)))
print (afh + scale_fill_gradient(low="#F0F0FF", high="#131393"))

