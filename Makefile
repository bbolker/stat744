# Stats 744
# https://bbolker.github.io/stat744
# https://github.com/bbolker/stat744

## pages
BRANCH = gh-pages

target = Makefile
-include target.mk

##################################################################

Sources += Makefile .ignore README.md sub.mk LICENSE.md
include sub.mk

######################################################################

## html

Sources += $(wildcard *.html)
Sources += $(wildcard *.handouts.pdf)
Sources += $(wildcard *.final.pdf)

Sources += $(wildcard *.R)
Sources += $(wildcard *.Rmd)

Sources += $(wildcard data/*)

######################################################################

-include $(ms)/git.mk
-include $(ms)/visual.mk

