%.html: %.Rmd
	Rscript -e "rmarkdown::render(\"$<\")"

sched.html: sched.Rmd sched.csv
	Rscript -e "rmarkdown::render(\"$<\")"

%.pdf: %.Rmd
	Rscript -e "rmarkdown::render(\"$<\")"

