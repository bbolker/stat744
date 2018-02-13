## TO DO

## guides(colour=guide_legend(reverse=TRUE))
## get better control of directlabels
##    text size
## superscripts in y-axis labels?

## load packages ...
library(readr)
library(dplyr)
library(ggplot2)
theme_set(theme_bw(base_size=20))
library(directlabels)

## get data
dd <- (read_csv(input_files[[1]])
    ## drop redundant variables
    %>% select(-c(Domain,Element,Item))
    ## modify variables
    %>% mutate(fYear=factor(Year),
               value_ktons=Value/1e3,
       ## reverse-order by mean value
       Country=reorder(Country,-Value)
    )
)

gg1 <- (ggplot(dd,aes(x=Year,y=Value/1000,
               colour=Country
               ## explicit group mapping:
               ## needed *if* using fYear
               ## group=Country
               )
          )
  + geom_line() 
  + scale_x_continuous(
      breaks=seq(1995,2005,by=2)
  )
  + scale_y_log10()
  + labs(y="kilotons of bananas") 
 ## see RColorBrewer::display.brewer.all() for choices,
 ##   especially which ones allow >= 10 levels
+ scale_colour_brewer(palette="Paired")
    
)

direct.label(gg1
             + expand_limits(x=2010), ## extra space on right side
             "last.bumpup"  ## specify label position
)

## can also use theme_set(theme_classic())
##   to change the theme for all subsequent
##   plots

