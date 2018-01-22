library(ggplot2)

summary(sunspots)

plot(sunspots, main = "sunspots data", xlab = "Year"
	, ylab = "Monthly sunspot numbers"
	, asp=1
)

plot(sunspots, main = "sunspots data", xlab = "Year"
	, ylab = "Monthly sunspot numbers"
	, asp=0.2
)
