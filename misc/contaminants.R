##
if (FALSE) devtools::install_github("tdhock/directlabels")
dd <- read.csv("POCIS_Raw_McCallum.csv")
dn <- read.csv("drugnames.csv")

library(ggplot2);theme_set(theme_bw())
library(tidyr)
library(dplyr)
library(directlabels)
ddm <- gather(dd,species,conc,-(MetCode:Site))  %>%
    mutate(species=reorder(species,conc)) %>%
    full_join(dn,by=c("species"="abbr"))

## there aren't any color palettes in ColorBrewer with enough
## values; download from http://tools.medialab.sciences-po.fr/iwanthue/

pal <- scan(textConnection("#367D97 #DB452E #6982E0 #99C82B
#D66EDC #5AC747 #CE4398
#50C283 #DA3B67 #4C8A39
#8E5FB1 #ABB139 #C798DB #D8A133 #63B1DF #D9731D #6974A6
#787626 #DF74A2 #33A59A
#DA764A #9B5C84 #9D5C2A #C4595A"),what="character")

g0 <- ggplot(ddm,aes(x=Site,y=conc,colour=drugname))+geom_point(alpha=0.5)+
    scale_y_continuous(trans="log1p",breaks=c(1,10,100,1000))+
    stat_summary(fun.y=mean,geom="line",aes(group=species))+
    scale_colour_manual(values=pal)+
    facet_wrap(~drugcat,ncol=3)+
    scale_x_discrete(expand=c(0.5,0))+
    theme(panel.margin=grid::unit(0,"lines"))

g1 <- direct.label(g0,"last.qp")
## TO DO
ggsave("contaminants.pdf",plot=g1,width=8,height=8)

dd <- read.csv("POCIS_Raw_McCallum.csv")
ddm <- mutate(dd,food=CFN+SUC, antibiotic=TMP+SMZ, antiseizure=CBZ, analgesic=ACM, antiinflam=IBP+NPX, lipidreg=GEM, antibacterial=TCS, hormone=E1+E2+ADS+TST, antidepressants=FLX+CIT+dm.SRT+n.dm.VLF+SRT+o.dm.VLF+VLF, betablocker=ATN+MTP+PPN)
ddm1<- select(ddm, MetCode:Site, food:betablocker)
ddm2 <- gather(ddm1,species,conc,-(MetCode:Site))  %>%
    mutate(species=reorder(species,conc))
ggplot(ddm2,aes(x=Site,y=conc,colour=species))+geom_point(alpha=0.5)+
    scale_y_log10()+
    stat_summary(fun.y=mean,geom="line",aes(group=species))+
    guides(col = guide_legend(reverse = TRUE))
