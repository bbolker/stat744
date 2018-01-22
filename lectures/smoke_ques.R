library(ggplot2)
theme_set(theme_bw(base_size=18))

## What is the relationship between smoking and lung capacity
## Why doesn't varwidth play nicely with dodge?
print(ggplot(smoke, aes(x=smoke, y=fev, color=sex))
	## + geom_boxplot(varwidth=TRUE, position="dodge")
	+ geom_boxplot(position="dodge")
)

print(ggplot(smoke, aes(x=smoke, y=fev))
	+ geom_boxplot(varwidth=TRUE)
)

## Who are the smoke people?
print(ggplot(smoke, aes(x=smoke, y=age))
	+ geom_boxplot(varwidth=TRUE)
)


