
## admin directory of stat744

######################################################################

## Hooks

current: target
target = Makefile
-include target.mk

###################################################################

# stuff

Sources += Makefile .ignore README.md upstuff.mk LICENSE.md

Sources += $(wildcard *.rmd)

## Change Drop with untracked local.mk (called automatically from upstuff.mk)
Drop = ~/Dropbox

-include upstuff.mk
# -include $(ms)/perl.def
# -include $(ms)/newtalk.def
# -include $(ms)/repos.def

######################################################################

## Content

%.html: %.rmd
	Rscript -e "rmarkdown::render(\"$<\")"

## Simplified rule, not tested
Sources += sched.csv
sched.html: sched.csv

%.pdf: %.rmd
	Rscript -e "rmarkdown::render(\"$<\")"

######################################################################

-include $(ms)/visual.mk
-include $(ms)/git.mk

# -include $(ms)/texdeps.mk
# -include $(ms)/newtalk.mk

# -include $(ms)/modules.mk

# -include $(ms)/webpix.mk
# -include $(ms)/wrapR.mk

