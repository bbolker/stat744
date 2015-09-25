sched.html: sched.rmd0 macros.gpp sched.csv topics.csv
	echo "library(knitr); knit('sched.rmd0')"  | R --slave
	gpp -H -DHTML=1 --include macros.gpp sched.txt > sched.md
	echo "library(rmarkdown); render('sched.md')"  | R --slave

%.rmd: %.rmd0 macros.gpp
	gpp -H -DPDF=1 --include macros.gpp $*.rmd0  > $*.rmd

## sudo apt-get install littler
## %.pdf: %.rmd
##	r -e "library(rmarkdown); render(\"$*.rmd\")"

%.pdf: %.rmd
	echo "library(rmarkdown); render(\"$*.rmd\")" | R --slave

## https://github.com/aasgreen/NSERC-Application-Latex-Template

%.html: %.rmd
	echo "library(rmarkdown); render(\"$*.rmd\")" | R --slave

