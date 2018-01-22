library(ggplot2)
theme_set(theme_bw(base_size=18))

## What is the relationship between smoking and lung capacity
print(ggplot(smoke, aes(x=smoke, y=fev, color=sex))
	## + geom_boxplot(varwidth=TRUE, position="dodge")
	+ geom_boxplot(position="dodge")
)

print(ggplot(smoke, aes(x=smoke, y=fev))
	+ geom_boxplot(varwidth=TRUE)
	+ geom_boxplot(position="dodge")
)

## Who are the smoke people?
print(ggplot(smoke, aes(x=smoke, y=age))
	+ geom_boxplot(varwidth=TRUE)
)


