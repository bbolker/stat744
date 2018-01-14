library(ggplot2)
theme_set(theme_bw())

timeRange <- c(1950, 2000)

print(base <- (ggplot(gis, aes(Year, Temp))
	+ geom_point()
	+ geom_line()
	+ xlim(timeRange)
))

print(stretch <- base + ylim(c(0, 20)))

print(plain <- (stretch + theme(panel.grid = element_blank())))

print(secret <- plain + xlab("") + ylab(""))
