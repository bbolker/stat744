
## BMB ideas for exploratory data analysis

* define/contrast
     * 'nonparametric' (flexible functional forms for the mean, *or* algorithmic smoothing that doesn't have a simple closed-form mathematical expression: little concern for easily interpretable parameters), e.g. loess or spline/additive model: regression splines especially good here because you don't have to muck around choosing number of knots
        * `geom_smooth(method="gam")` vs. `geom_smooth(method="loess")`: see `?geom_smooth`: loess is "less parametric" but expensive ($O(n^2)$ in memory), so `ggplot` uses loess by default when n<1000. I sometimes find it "too wiggly", gam is a little more constrained. gam is also nice because you can pick a family/link function (e.g. `method.args=list(family="binomial")`)
	 * 'robust': limits influence of extreme values (e.g. mean-absolute-deviation rather than least squares, M-estimators [influence function]). Can use `MASS::rlm` (for linear fits) or, apparently, `family="symmetric"` in `loess` call.  There's also a `lowess` function similar to loess ... haven't tried it.

* quick graphical summary methods:
    * pairs plots: `GGally::ggpairs` is pretty fancy [but slow!], shows a lot of info.  (plain old `pairs(.,gap=0)` is OK, use `pch="."` for big data sets) Maybe look at `ggduo()` too?
	* univariate/marginal plots: can melt/gather data, esp if there's a single response, and show primary response variable on y axis vs all different x vals (I think there was an example that I skipped over in one of my earlier sets of R code). Hard to switch plot types between categorical/

Don't know if it's worth getting into `rggobi` (high-dimensional exploration) -- also don't know if it requires finicky external stuff to install (see http://www.ggobi.org/rggobi/) http://www.ggobi.org/rggobi/introduction.pdf
(`ggobi(stormtracks)` is worth looking at)

* also try `skimr` package (good for *univariate*, in-console summaries)
