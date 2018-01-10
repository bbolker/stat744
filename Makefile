# Stats 744
# https://github.com/bbolker/stat744
# https://bbolker.github.io/stat744

target = Makefile
-include target.mk

##################################################################

Sources += Makefile .gitignore README.md sub.mk LICENSE.md
include sub.mk

######################################################################

## Notes

Sources += TODO.md

######################################################################

Sources += $(wildcard */*.rmd)

%.pdf: %.rmd
	echo "library(rmarkdown); render(\"$*.rmd\")" | R --slave

%.html: %.rmd
	echo "library(rmarkdown); render(\"$*.rmd\")" | R --slave

######################################################################

-include $(ms)/git.mk
-include $(ms)/visual.mk
