library(ggplot2)
theme_set(theme_bw(base_size=18))

library(Hmisc)

data("OrchardSprays")
base <- ggplot(OrchardSprays,aes(x=treatment,y=decrease))
lbase <- base +  scale_y_log10()

print(bar <- base
    +  stat_summary(fun.data=mean_cl_normal,geom="bar",colour="gray")
    +  stat_summary(fun.data=mean_cl_normal,geom="errorbar",width=0.5)
)

print(bar +  scale_y_log10())

print(lbase 
	+ stat_summary(fun.data=mean_cl_normal,geom="pointrange")
)

print(lbase 
	+ stat_summary(fun.data=mean_sdl,geom="pointrange")
)

print(base 
	+ stat_summary(fun.data=mean_sdl,geom="pointrange")
)

print(lbase + geom_point())

## Hybrid of data and inference; is it good?
##print(lrange + geom_point(color="blue", alpha=0.3))
print(lbase + geom_boxplot())
print(lbase + geom_violin())
