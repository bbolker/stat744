library(broom)
library(dotwhisker)

library(ggplot2)
theme_set(theme_bw(base_size=18))

library(dplyr)

summary(smoke)
full <- lm(fev ~ age + height + sex + smoking, data=smoke)

print(summary(full))

print(
	dwplot(full)
	+ geom_vline(xintercept=0,lty=2)
	+ ggtitle("Regression coefficients")
)

stdsmoke <- (smoke
	%>% transmute(fev = fev/sd(fev)
		, age = age/sd(age)
		, height = height/sd(height)
		, sex = as.numeric(as.factor(sex))
		, sex = sex/sd(sex)
		, smoking = as.numeric(as.factor(smoking))
		, smoking = smoking/sd(smoking)
	)
)

std <- lm(smoke$fev ~ age + height + sex + smoking, data=stdsmoke)

print(
	dwplot(std)
	+ geom_vline(xintercept=0,lty=2)
	+ ggtitle("Standardized effect on lung capacity (L/s)")
)

partial <- lm(fev ~ age + height + sex + smoking, data=stdsmoke)

print(
	dwplot(partial)
	+ geom_vline(xintercept=0,lty=2)
	+ ggtitle("Partial correlations with lung capacity")
)

