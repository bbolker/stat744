library(ggplot2)
theme_set(theme_bw(base_size=18))

library(Hmisc)

data("OrchardSprays")
base <- ggplot(OrchardSprays,aes(x=treatment,y=decrease))
lbase <- base +  scale_y_log10()

## Bar charts, lin and log
print(bar <- base
    +  stat_summary(fun.data=mean_cl_normal,geom="bar",colour="gray")
    +  stat_summary(fun.data=mean_cl_normal,geom="errorbar",width=0.5)
)

print(bar +  scale_y_log10())

## pointrange is similar to error bar; these are are the non-dynamite analogues of the above
print(base 
	+ stat_summary(fun.data=mean_cl_normal,geom="pointrange")
)

print(lbase 
	+ stat_summary(fun.data=mean_cl_normal,geom="pointrange")
)

## Now we have just sds, I guess
print(lbase 
	+ stat_summary(fun.data=mean_sdl,geom="pointrange")
)

print(base 
	+ stat_summary(fun.data=mean_sdl,geom="pointrange")
)

print(lbase + geom_point())
print(lbase + geom_boxplot())
print(lbase + geom_violin())

## Old idea, oldly suppressed as well
## Hybrid of data and inference; is it good?
##print(lrange + geom_point(color="blue", alpha=0.3))
