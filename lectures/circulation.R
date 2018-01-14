library(ggplot2)
theme_set(theme_bw(base_size=18))

library(Hmisc)

circ <- read.csv(input_files[[1]])

base <- (ggplot(circ, aes(x=Year,y=Circulation))
	+ ylab("Circulation (thousands)")
)

print(bars <- base + stat_summary(fun.data=mean_cl_normal,geom="bar"))

print(bars + scale_y_continuous(limits=c(3000, NA), oob=scales::squish))

print(base + geom_line() + geom_point())
