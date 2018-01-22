set.seed(1001)
dd <- data.frame(x=rnorm(1000),
                 f=sample(letters[1:5],size=1000,replace=TRUE))

## summarise by hand:
library(dplyr)
(dd
    %>% group_by(f)
    %>% summarise(mean=mean(x),n=length(x))
) -> dd_sum

ggplot(dd_sum)+
    geom_rect(aes(xmin=as.numeric(f)-0.2*drop(scale(n)),
                  xmax=as.numeric(f)+0.2*drop(scale(n)),
                  ymin=0,
                  ymax=mean))+
    scale_x_continuous(breaks=1:length(levels(dd_sum$f)),
                       labels=levels(dd_sum$f))

## could use geom_tile but geom_tile uses x, y, width, and height;
## we would like to split the difference (ymin=0, ymax=, x, width)

## this might be better:

ggplot(dd_sum) +
    geom_segment(aes(x=f,xend=f,y=0,yend=mean,size=n),colour="darkgray")+
    scale_size_continuous(range=c(5,20),guide=FALSE)
