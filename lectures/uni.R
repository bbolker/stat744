library(ggplot2)
theme_set(theme_bw(base_size=18))

uni <- lm(fev ~ height, data=smoke)
pointPred <- as_data_frame(predict(uni, interval="confidence"))
termPred <- predict(uni, interval="confidence", type="terms")

base <- ggplot(smoke, aes(height, fev))

print(scatter <- base + geom_point(alpha=0.1))

print(pp <- scatter 
	+ geom_line(aes(y=pointPred$fit))
	+ geom_line(aes(y=pointPred$lwr), lty=2)
	+ geom_line(aes(y=pointPred$upr), lty=2)
)

