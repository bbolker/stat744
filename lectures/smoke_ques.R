library(ggplot2)
theme_set(theme_bw(base_size=18))

## What is the relationship between smoking and lung capacity
## Why doesn't varwidth play nicely with dodge?
print(ggplot(smoke, aes(x=smoking, y=fev, color=sex))
	## + geom_boxplot(varwidth=TRUE, position="dodge")
	+ geom_boxplot(position="dodge")
	+ ylab("Lung capacity")
)

print(ggplot(smoke, aes(x=smoking, y=fev))
	+ geom_boxplot(varwidth=TRUE)
	+ ylab("Lung capacity")
)

## Who are the smoke people?
print(ggplot(smoke, aes(x=smoking, y=age))
	+ geom_boxplot(varwidth=TRUE)
	+ ylab("Lung capacity")
)


