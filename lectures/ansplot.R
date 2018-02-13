library(ggplot2)
theme_set(theme_bw(base_size=18))

print(concept <- ggplot(anst, aes(x, y))
	## + geom_point()
	+ geom_smooth(method=lm, fullrange=TRUE)
	+ facet_wrap(~set)
)

print(concept + geom_point())
