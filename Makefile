# Stats 744
# https://github.com/bbolker/stat744
# https://bbolker.github.io/stat744

target = Makefile
-include target.mk

##################################################################

Sources += Makefile .ignore .gitignore README.md sub.mk LICENSE.md
include sub.mk

######################################################################

## Notes

Sources += admin/outline.rmd TODO.md

######################################################################

clonedirs += pages

rmd += $(wildcard */*.rmd)
Sources += $(rmd)
Ignore += $(rmd:rmd=html)

%.pdf: %.rmd
	echo "library(rmarkdown); render(\"$*.rmd\")" | R --slave

%.html: %.rmd
	echo "library(rmarkdown); render(\"$*.rmd\")" | R --slave

%.html: admin/%.html
	$(copy)

## Chaining to pages not working. Don't panic

# Seems OK for distribution pdfs now
pages/%.final.pdf: lectures/%.final.pdf
	$(copy)
pages/%.handouts.pdf: lectures/%.handouts.pdf
	$(copy)

######################################################################

-include $(ms)/git.mk
-include $(ms)/visual.mk
