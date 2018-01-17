
## vaccine directory of stat744
## Work on chart from http://www.sciencemag.org/news/2017/04/here-s-visual-proof-why-vaccines-do-more-good-harm

######################################################################

## Hooks

current: target
target = Makefile
-include target.mk

###################################################################

# stuff

Sources += Makefile .ignore README.md upstuff.mk LICENSE.md

## Change Drop with untracked local.mk (called automatically from upstuff.mk)
Drop = ~/Dropbox

-include upstuff.mk
# -include $(ms)/perl.def
# -include $(ms)/newtalk.def
# -include $(ms)/repos.def

######################################################################

## Content

git_cache/data.csv: 
	wget -O $@ "http://sciencestatic.aws.aaas.org.s3.amazonaws.com/article-resources/vaccine-war/vaccine_data_online.csv"
	perl -pi -e"s//\\n/g" $@

Sources += $(wildcard *.R)

read.Rout: slow/data.csv read.R
plot.Rout: read.Rout plot.R

######################################################################

-include $(ms)/cache.mk
# -include $(ms)/texdeps.mk
# -include $(ms)/newtalk.mk

# -include $(ms)/modules.mk

# -include $(ms)/webpix.mk
-include $(ms)/wrapR.mk

-include $(ms)/visual.mk
-include $(ms)/git.mk
