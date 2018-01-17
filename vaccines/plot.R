library(ggplot2)
theme_set(theme_bw())

print(summary(dat))

print(ggplot(dat, aes(year, cases, color=disease))
	+ geom_line()
	+ geom_point()
	+ scale_y_log10()
)
