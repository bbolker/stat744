library(dplyr)
library(ggplot2); theme_set(theme_bw())
## unpack time series: c() removes extraneous structure
dd <- data.frame(date=c(time(sunspot.month)),
                 spots=c(sunspot.month)) %>%
    mutate(smooth=smooth.spline(spots)$y,  ## smooth
           ## find local minima
           local_minima = lag(smooth) > smooth & lead(smooth) > smooth,
           ## identify how many local minima have occurred up to time t
           period=cumsum(!is.na(local_minima) & local_minima)) %>%
    group_by(period) %>%
    ## compute sequences within period
    mutate(period_step=seq(n())) %>%
    ungroup  ## apparently ggplot2 doesn't connect groups (???)


## 
ggplot(dd,aes(date,spots))+geom_point(colour="gray") +
    geom_line(aes(y=smooth),colour="red")+
    ## period indicator, scaled
    geom_line(aes(y=period*5),colour="blue")

## could also add vertical lines ...

## plot data by period
ggplot(dd,aes(period_step,spots,group=period))+
    geom_line(alpha=0.5)

