library(ggplot2)
theme_set(theme_bw())

print(summary(dat))

print(ggplot(dat, aes(year, cases, color=disease))
	+ geom_line()
	+ scale_y_log10()
	+ geom_point(data=vacc, size=3)
	+ scale_color_brewer()
)
