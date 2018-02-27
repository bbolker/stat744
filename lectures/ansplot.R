library(ggplot2)
theme_set(theme_bw(base_size=18))

library(plotly)

print(concept <- ggplot(anst, aes(x=x, y=y, obs=obs))
	+ geom_smooth(method=lm, fullrange=TRUE)
	+ facet_wrap(~set)
)

print(concept + geom_point())

ggp <- ggplotly(concept + geom_point()
	, tooltip = c("obs", "x", "y")
)
htmlwidgets::saveWidget(as_widget(ggp), "anscombe.html")
