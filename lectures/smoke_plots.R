library(ggplot2)
theme_set(theme_bw(base_size=18))

point_alpha <- 0.4

## Age vs fev

af <- (ggplot(smoke, aes(x=age, y=fev))
	+ ylab("Lung capacity")
)

print(af + geom_point()) 
print(af + geom_point(alpha=point_alpha)) 
print(af + geom_count(alpha=point_alpha)) ## Dumb!
print(afp <- af + geom_count(alpha=point_alpha) + scale_size_area())

print(aflp <- afp + geom_smooth(method=loess))

print(afls <- aflp + aes(color=smoking))
print(afls + facet_wrap(~sex) + theme(legend.position="none"))

## Is there a way to do this? Does it mess up the loess?
## print(afb <- af + geom_boxplot(group=age) + geom_smooth(method="loess"))

## rlm

library(splines)
library(MASS)

afr <- af + geom_smooth(method=rlm, formula=y~ns(x,3))
print(afrp <- afr + geom_count(alpha=point_alpha) + scale_size_area())

afrs <- afrp + aes(color=smoking)

## Replot so we can put side-by-side
print(afls + theme(legend.position="none") + ggtitle("loess"))
print(afrs + theme(legend.position="none") + ggtitle("rlm plus ns(3)"))
