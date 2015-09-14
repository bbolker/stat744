%.pdf: %.Rnw
	echo "library(knitr); knit2pdf(\"$*.rmd\")" | R --slave

%.rmd: %.rmd0 macros.gpp
	gpp -H --include macros.gpp $*.rmd0  > $*.rmd

## sudo apt-get install littler
## %.pdf: %.rmd
##	r -e "library(rmarkdown); render(\"$*.rmd\")"

%.pdf: %.rmd
	echo "library(rmarkdown); render(\"$*.rmd\")" | R --slave

## https://github.com/aasgreen/NSERC-Application-Latex-Template


