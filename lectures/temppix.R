library(ggplot2)
theme_set(theme_bw(base_size=18))

timeRange <- c(1950, 2000)

print(base <- ggplot(gis, aes(Year, Temp))
	+ geom_point()
	+ geom_line()
	+ xlim(timeRange)
)

print(stretch <- base + ylim(c(0, 20)))

print(plain <- (stretch + theme(panel.grid = element_blank())))

print(secret <- plain + xlab("Time") + ylab("")
	+ theme(axis.text.x = element_blank())
)

print(ggplot(gis, aes(Year, Mean))
	+ geom_point()
	+ geom_line()
	+ xlim(timeRange)
	+ ylab("Temperature anomaly")
	+ geom_hline(yintercept=0, linetype="dashed")
	+ ylim(c(-0.3, 0.5))
)
