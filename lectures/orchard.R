library(ggplot2)
theme_set(theme_bw(base_size=18))

library(Hmisc)

data("OrchardSprays")
base <- ggplot(OrchardSprays,aes(x=treatment,y=decrease))

print(bar <- base
    +  stat_summary(fun.data=mean_cl_normal,geom="bar",colour="gray")
    +  stat_summary(fun.data=mean_cl_normal,geom="errorbar",width=0.5)
)

print(bar +  scale_y_log10())
