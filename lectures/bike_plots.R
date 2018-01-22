library(ggplot2)
theme_set(theme_bw(base_size=18))

base <- ggplot(bikes,aes(x=weather,y=rentals))
lbase <- base +  scale_y_log10()

print(bar <- base
    +  stat_summary(fun.data=mean_cl_normal,geom="bar",colour="gray")
)

print(barbar <- bar
    +  stat_summary(fun.data=mean_cl_normal,geom="errorbar",width=0.5)
)

print(base 
   +  stat_summary(fun.data=mean_cl_normal,geom="pointrange")
)

print(base 
   +  stat_summary(fun.data=mean_sdl,geom="pointrange")
)

print(base + geom_boxplot())
print(lbase + geom_boxplot())
print(base + geom_boxplot(varwidth=TRUE))
print(base + geom_violin())
print(lbase + geom_violin())
