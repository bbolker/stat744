library(pgmm)    ## for olives data
library(skimr)   ## for text-based summaries
library(ggplot2); theme_set(theme_bw())
library(GGally)   ## pairs plots etc.
library(corrplot) ## correlation plots
library(dplyr)    ## data manipulation
library(readr)    ## read CSV files
library(agridat)  ## agricultural data sets

data(olive)

## looking for stuff ...
## library("sos")
## findFn("barley")
## ?RSiteSearch
## help.search("barley")

library(agridat)

## order data and factor-ize year
ff <- (fisher.barley
  %>% mutate(gen=reorder(gen,yield),
             env=reorder(env,yield),
             year=factor(year))
  %>% arrange(gen,env)
)

gg0 <- (ggplot(ff,
               aes(x=env,y=yield,colour=year,group=year))
  ## geom_boxplot(aes(x=gen,y=yield,fill=factor(year)))
  + geom_point()+geom_line()
  + facet_wrap(~gen,nrow=1)
)
print(gg0)

## I might prefer this in a horizontal layout.
##  coord_flip() doesn't interact well with faceting
gg0_h <- (ggplot(ff,
               aes(y=env,x=yield,colour=year,group=year))
        ## geom_boxplot(aes(x=gen,y=yield,fill=factor(year)))
        + geom_point()+geom_path()
        + facet_wrap(~gen,nrow=1)
        + theme(panel.spacing=grid::unit(0,"lines"))
        + coord_fixed(ratio=20)
)
print(gg0_h)

## maybe use ncol=1, coord_fixed(ratio=1/20)?
## then yields would be aligned along the same
##  axis (but a tall skinny plot might not
##  be convenient)

## could do this to calculate mean differences
## in yield, order env by yield_diff - but it's
## starting to be too much work to call it
## 'exploratory'
ff_sum <-
  (ff
    %>% tidyr::spread(year,yield)
    %>% mutate(yield_diff=`1932`-`1931`)
    %>% group_by(env)
    %>% summarise(yield_diff=mean(yield_diff))
    %>% arrange(yield_diff)
  )
  

###

library(pgmm)
data(olive)

## restore names to data set 
olive_regions <-
  read_csv("olive_regions.csv")

olive2 <- 
  (full_join(olive_regions,olive,
      by=c("region_num" = "Region",
           "area_num" = "Area"))  
  %>% select(-c(region_num,area_num))
  %>% mutate(region=factor(region),
             area=factor(area))
  )

colvec <- c("red","blue","goldenrod")
panel.density <- function(x, ...)
{
  usr <- par("usr"); on.exit(par(usr))
  par(usr = c(usr[1:2], 0, 1.5) )
  h <- lapply(split(x,olive2$region),
              density)
  ## browser()
  for (i in 1:length(h)) {
    lines(h[[i]]$x,h[[i]]$y/max(h[[i]]$y),col=colvec[i])
  }
}

num_cols <- 3:ncol(olive2)

pairs(olive2[,num_cols],gap=0,
      cex=0.5,
      col=colvec[olive2$region],
      diag.panel=panel.density)

## this took significant hacking to get the way I wanted it!
## haven't adjusted the panels above the diagonal, yet ...
library(GGally)
## https://stackoverflow.com/questions/37889222/change-colors-in-ggpairs-now-that-params-is-deprecated
ggp1 <- ggpairs(olive2,
        lower=list(continuous= function(data,mapping,...) {
          ggally_points(data,mapping,...,
                        size=1) +
          scale_colour_brewer(palette="Dark2")
        }),
        diag = list(continuous=function(data,mapping,...) {
          ggplot(data,mapping) +
            geom_density(...) +
            scale_colour_brewer(palette="Dark2")
        }),
        columns=num_cols,
        mapping=aes(colour=region))
## https://github.com/ggobi/ggally/issues/14
theme_set(theme_bw()+
            theme(panel.spacing=grid::unit(0,"lines")))
print(ggp1)

library(corrplot)
corrplot(cor(olive2[,1:8]),method="ellipse")
corrplot.mixed(cor(olive2[,1:8]))

## 
library(ggmosaic)
## https://cran.r-project.org/web/packages/ggmosaic/vignettes/ggmosaic.html


data(Titanic)
titanic <- as.data.frame(Titanic)
titanic$Survived <- factor(titanic$Survived, levels=c("Yes", "No"))

ggplot(data=titanic) +
    geom_mosaic(aes(weight=Freq, x=product(Class, Age), fill=Survived))

ggplot(data=titanic) +
   geom_mosaic(aes(weight=Freq, x=product(Class, Age,Sex),
                   fill=Survived))



