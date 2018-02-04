## par(ps=20)
library(coefplot2)
library(dplyr)

summary(smoke)
full <- lm(fev ~ age + height + sex + smoking, data=smoke)

coefplot2(full)

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

print(stdsmoke)

std <- lm(smoke$fev ~ age + height + sex + smoking, data=stdsmoke)
coefplot2(std, main="Standardized effect on fev (L/s)")

partial <- lm(fev ~ age + height + sex + smoking, data=stdsmoke)
coefplot2(partial, main="Partial correlations with fev")

