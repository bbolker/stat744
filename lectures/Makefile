
######################################################################

## Hooks

current: target
target = Makefile
-include target.mk

###################################################################

# stuff

Sources += Makefile .ignore README.md upstuff.mk LICENSE.md

## Change Drop with untracked local.mk (called automatically from substuff.mk)
Drop = ~/Dropbox

-include upstuff.mk
-include $(ms)/perl.def
-include $(ms)/newtalk.def
# -include $(ms)/repos.def

######################################################################

## Directories

# clonedirs += clone
clone:
	git clone https://github.com/Bio3SS/$@.git

# mdirs += test
test:
	git submodule add -b master https://github.com/Bio3SS/$@

# pushdir = web/materials

## repodirs have auto-making rules from modules.mk
## mdirs are used by recursive git rules
repodirs += $(specdirs)
mdirs = $(specdirs)

######################################################################

# List
Sources += jd.txt

######################################################################

## Content

rmd = $(wildcard *.rmd)
Sources += $(rmd)
Ignore += $(rmd:.rmd=html)

ggplot_ex.html: ggplot_ex.rmd

intro.html: intro.rmd

principles_1.html: principles_1.rmd

%.html: %.rmd
	Rscript -e "rmarkdown::render(\"$<\")"

######################################################################

## Data

## Temporarily doing this here for a lecture tomorrow
## 2018 Jan 14 (Sun)
## Does not run (data not here)
bananas.Rout: bananas.R

######################################################################

## Dushoff talk

## Too scared to try to make a slick .html talk 2018 Jan 14 (Sun), so I'm going to see if I can make a slick pdf talk using old technology

## makestuff/newtalk.md
## makestuff/newtalk.mk

Sources += $(wildcard *.step)

Sources += scales.txt
scales.draft.pdf: scales.txt
scales.final.pdf: scales.txt
scales.handouts.pdf: scales.txt

## Orchard
orchard.Rout: orchard.R

## Global temperature
Sources += $(wildcard *.R)
Ignore += temps.csv
temps.csv:
	wget -O $@ https://datahub.io/core/global-temp/r/annual.csv

temps.Rout: temps.csv temps.R
temppix.Rout: temps.Rout temppix.R

Sources += circulation.csv
circulation.Rout: circulation.csv circulation.R


## Still not ahead, so I am going to do the same thing again

Sources += explore.txt
explore.html: explore.step
explore.draft.pdf: explore.txt
explore.final.pdf: explore.txt
explore.handouts.pdf: explore.txt

git_cache/bikes.zip:
	wget -O $@ https://archive.ics.uci.edu/ml/machine-learning-databases/00275/Bike-Sharing-Dataset.zip

Ignore += day.csv hour.csv
hour.csv: slow/bikes.zip
	unzip $< $@

bikes.Rout: hour.csv bike_weather.csv bikes.R
Sources += bike_weather.csv

bike_plots.Rout: bikes.Rout bike_plots.R

## Smoking data from http://biostat.mc.vanderbilt.edu/wiki/Main/DataSets
git_cache/fev.csv: 
	wget -O $@ "http://biostat.mc.vanderbilt.edu/wiki/pub/Main/DataSets/FEV.csv"

smoke.Rout: slow/fev.csv smoke.R

## Show the confounding
smoke_ques.Rout: smoke.Rout smoke_ques.R

## fev vs. age fits
smoke_plots.Rout: smoke.Rout smoke_plots.R

## Level plots (a mess)
smoke_levels.Rout: smoke.Rout smoke_levels.R

## sunspots (banking)
sunspots.Rout: sunspots.R

## irises (multivariate, ggpairs?)
iris.Rout: iris.R

######################################################################

Sources += copy.tex

## Should be in webpix
Sources += ClevelandHierarchyR.png steel_production.png

Ignore += local.txt.format

######################################################################

-include $(ms)/visual.mk
-include $(ms)/git.mk

-include $(ms)/texdeps.mk
-include $(ms)/newtalk.mk
-include $(ms)/cache.mk

# -include $(ms)/modules.mk

-include $(ms)/webpix.mk
-include $(ms)/wrapR.mk

