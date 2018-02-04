
%.pdf: %.rmd
	echo "library(rmarkdown); render(\"$*.rmd\")" | R --slave

%.html: %.rmd
	echo "library(rmarkdown); render(\"$*.rmd\")" | R --slave

