%.pdf: %.Rnw
	echo "library(knitr); knit2pdf(\"$*.rmd\")" | R --slave

%.rmd: %.rmd0 macros.gpp
	gpp -H --include macros.gpp $*.rmd0  > $*.rmd

## littler is in principle nicer than "| R --slave",
## but actually more trouble than it's worth
## sudo apt-get install littler
## %.pdf: %.rmd
##	r -e "library(rmarkdown); render(\"$*.rmd\")"

%.pdf: %.rmd
	echo "library(rmarkdown); render(\"$*.rmd\")" | R --slave



