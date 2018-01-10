
## ASAP

## For Monday 15 Jan

* BMB absent!
* lecture on principles
* BMB rules for complex data: some possibly useful stuff from a previous data viz presentation

----

### Data presentation scales with data size

* **small** show all points, possibly dodged/jittered, with some summary statistics: dotplot, beeswarm. Simple trends (linear/GLM)
* **medium** boxplots, loess, histograms, GAM (or linear regression)
* **large** modern nonparametrics: violin plots, hexbin plots, kernel densities: computational burden, and display overlapping problems, relevant
* combinations or overlays where appropriate (beanplot; rugs+scatterplot)

### Rules of thumb

* (Continuous) response on the $y$-axis, most salient (continuous) predictor on the $x$-axis
* Put most salient comparisons within the same subplot (distinguished by color/shape), and nearby within the subplot when grouping bars/points
* Facet rows > facet columns
* Use transparency to include important but potentially distracting detail
* Do category levels need to be *identified* or just *distinguished*? (Direct labeling)
* Order categorical variables meaningfully
* Think about whether to display *population variation* (standard deviations, boxplots) or *estimation uncertainty* (standard errors, mean $\pm$ 2 SE, boxplot notches)
* Try to match graphics to statistical analysis, but not at all costs
* Choose colors carefully (`RColorBrewer`/[ColorBrewer](colorbrewer2.org/), [IWantHue](http://tools.medialab.sciences-po.fr/iwanthue/): respect dichromats and B&W printouts

-------


* scheduling: Alex J. busy Thurs 1 PM, Fri 9 AM
  * Alex B.: Monday 2:30-3:30 and Wednesdays 8:30-10:30.
  * Mu He: Tues 1:30
  * 6A03/time series: 10:30 Monday?

* code on [GitHub](https://github.com/jrauser/writing/tree/master/how_humans_see_data)

* Put in a low-burden makestuff framework
     * markup shortcut for R packages? (e.g. <#Rpkg #1> -> https://cran.r-project.org/web/packages/#1
	 * auto-generate bib products (bib2xhtml or similar)

* Github infrastructure (collecting student repos)

* Start HW early (more structured than 708)
     * HW ideas:
	       * reshape/modify some data
	       * find a graph; recreate it, then fix/change it
		   * convert a table of numbers to a graph
		   * fit a model and diagnose it

* Similar courses:
    * Andrew Heiss [data visualization](https://datavizf17.classes.andrewheiss.com) ([syllabus](https://datavizf17.classes.andrewheiss.com/syllabus/), [final projects](https://datavizf17.classes.andrewheiss.com/final-projects/)
    * Andrew Gelman: [statistical communication and graphics](http://andrewgelman.com/2015/10/02/syllabus-for-my-course-on-communicating-data-and-statistics/)
    * CSE 707, [Visualization and 3D Rendering](https://computational.mcmaster.ca/graduate-studies/courses.html):
          > This course will provide an introduction to the use of graphics to visualize research data (grids, meshes, particles) in two and three dimensions. It will cover algorithms (surface drawing, transparency), real time visualization, post processing (including large data sets) and generating animations and movies. It will introduce OpenGL as a low-level mechanism to access hardware graphic acceleration as well as other popular toolkits such as vtk and provide experience with visualization tools built on these foundations.

* more topics:
    * pedantry: pie charts, dual-axis charts, dynamite plots, 3d bar charts ... @drum_yet_2017, @drang_drum_2017
    * what is Bill Cleveland doing now? http://deltarho.org/; `datadr`, `trelliscope` packages
