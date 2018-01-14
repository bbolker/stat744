
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

## Global temperature
Sources += $(wildcard *.R)
Ignore += temps.csv
temps.csv:
	wget -O $@ https://datahub.io/core/global-temp/r/annual.csv

temps.Rout: temps.csv temps.R
temppix.Rout: temps.Rout temppix.R

Sources += circulation.csv
circulation.Rout: circulation.csv circulation.R

## Orchard
orchard.Rout: orchard.R

######################################################################

## Dushoff talk

## Too scared to try to make a slick .html talk 2018 Jan 14 (Sun), so I'm going to see if I can make a slick pdf talk using old technology

## makestuff/newtalk.md
## makestuff/newtalk.mk

scales.draft.pdf: scales.txt

## Should be in webpix
Sources += ClevelandHierarchyR.png steel_production.png

Ignore += local.txt.format

######################################################################

-include $(ms)/visual.mk
-include $(ms)/git.mk

-include $(ms)/texdeps.mk
-include $(ms)/newtalk.mk

# -include $(ms)/modules.mk

# -include $(ms)/webpix.mk
-include $(ms)/wrapR.mk

