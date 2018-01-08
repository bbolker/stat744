# Stats 744
# https://github.com/bbolker/stat744
# https://bbolker.github.io/stat744

target = Makefile
-include target.mk

##################################################################

Sources += Makefile .gitignore README.md sub.mk LICENSE.md
include sub.mk

######################################################################

## Processing rmd files

%.rmd: %.rmd0 macros.gpp
	gpp -H --include macros.gpp $*.rmd0  > $*.rmd

%.pdf: %.rmd
	echo "library(rmarkdown); render(\"$*.rmd\")" | R --slave

## https://github.com/aasgreen/NSERC-Application-Latex-Template

%.html: %.rmd
	echo "library(rmarkdown); render(\"$*.rmd\")" | R --slave

######################################################################

-include $(ms)/git.mk
-include $(ms)/visual.mk

