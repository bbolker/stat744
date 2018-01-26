library(dplyr)
library(ggplot2)
theme_set(theme_bw())
library(GGally)

iris_measures <- (iris 
	%>% select(-Species)
)

ggpairs(iris_measures)
