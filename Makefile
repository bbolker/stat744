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
Sources += admin/sched.csv

######################################################################

clonedirs += pages

rmd += $(wildcard */*.rmd)
Sources += $(rmd)
Ignore += $(rmd:rmd=html)

%.html: admin/%.html
	$(copy)

## Chaining to pages not working. Don't panic

# Seems OK for distribution pdfs now
pages/%.final.pdf: lectures/%.final.pdf
	$(copy)
pages/%.handouts.pdf: lectures/%.handouts.pdf
	$(copy)

sched.html.pages:

lectures/%.handouts.pdf lectures/%.final.pdf:
	cd lectures && $(MAKE) $(notdir $@)

pages/%.html: lectures/%.rmd
	cd lectures && $(MAKE) $*.html
	cp lectures/$*.html $@

pages/%.html: admin/%.rmd
	cd admin && $(MAKE) $*.html
	cp admin/$*.html $@

pages/sched.html: admin/sched.csv

######################################################################

Sources += rmd.mk
-include rmd.mk
-include $(ms)/git.mk
-include $(ms)/visual.mk
