%.html: %.rmd
	Rscript -e "rmarkdown::render(\"$<\")"

%.pdf: %.Rmd
	Rscript -e "rmarkdown::render(\"$<\")"

