
library(ggplot2)
theme_set(theme_bw(base_size=18))
library(dplyr)

base <- ggplot(fake, aes(x, y))

print(scatter <- base 
	+ geom_point(alpha=1)
	+ ylim(c(-2, 12))
)

uni <- lm(y ~ x, data=fake)
pointPred <- as_data_frame(predict(uni, interval="confidence"))
termPred <- predict(uni, interval="confidence", type="terms")

print(pp <- scatter 
	+ geom_line(aes(y=pointPred$fit))
	+ geom_line(aes(y=pointPred$lwr), lty=2)
	+ geom_line(aes(y=pointPred$upr), lty=2)
)

print(tp <- scatter 
	+ geom_line(aes(y=termPred$fit+mean(y)))
	+ geom_line(aes(y=termPred$lwr+mean(y)), lty=2)
	+ geom_line(aes(y=termPred$upr+mean(y)), lty=2)
)

print(pp
	+ geom_line(aes(y=termPred$fit+mean(y)))
	+ geom_line(aes(y=termPred$lwr+mean(y)), lty=2)
	+ geom_line(aes(y=termPred$upr+mean(y)), lty=2)
)

print(termPred)
