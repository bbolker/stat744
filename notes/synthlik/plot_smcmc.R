.plot.smcmc <- function(x, trans = NULL, addPlot1 = NULL, addPlot2 = NULL,
                        interactive=FALSE, ...)
{

  pfun <- function(msg,prompt=TRUE) {
      if (interactive) {
          if (prompt)
              readline(prompt = "Press <Enter> to see the next plot...")
          cat(msg,"\n")
      }
  }
    cat("modified .plot.smcmc\n")
    if(!is(x, "smcmc")) stop("object has to be of class \"smcmc\" ")
    chains <- x@chains
    colnames(chains) <- names(x@param)
  
  oldPar <- par(no.readonly = TRUE)
  
  if(nrow(chains) > 0 )
  {
      pfun("Plotting the MCMC chains",prompt=FALSE)
      synlik:::.plotIter(chains, trans, type = "line", addPlot = addPlot1, ...)
    
      pfun("The posterior densities")
      synlik:::.plotIter(chains, trans, type = "hist", addPlot = addPlot2, ...)

      pfun("Plotting the log-likelihood chain")
      par(mfrow = c(1, 1))
      plot(1:nrow(chains), x@llkChain, xlab = "Iteration",
         ylab = "Log-likelihood", main = "Log-likelihood chain", type = 'l', ...)
  }

  pfun("Plotting correlation structure of the posterior sample")
  synlik:::.plotMatrix(cor(chains), title = "Posterior correlations", xLabels = names(x@param), yLabels = names(x@param), 
              scaleLab = "Correlation", correl = TRUE, ...)

  if (interactive()) {
      readline(prompt = "Press <Enter> to see the next plot...")
  }
  
  par(oldPar)
  
  invisible( callNextMethod(x) )
}



##########
#' @name plot-smcmc
#' 
#' @title Method for plotting an object of class \code{smcmc}.
#' 
#' @param x An object of class \code{smcmc}.
#' @param trans Name list or vector containing names of transforms for some parameters (ex: \code{list("par1" = "exp", "par2" = "log")}).
#'              The transformations will be applied before plotting.
#' @param addPlot1 Name of additional plotting function that will be call after the MCMC chain have been plotted. It has
#'                 to have prototype \code{fun(nam, ...)} where \code{nam} will be the parameter name. See "examples".
#' @param addPlot2 Name of additional plotting function that will be call after the histograms have been plotted. It has
#'                 to have prototype \code{fun(nam, ...)} where \code{nam} will be the parameter name. See "examples".
#' @param ... additional arguments to be passed to the plotting functions.
#'
#' @return NULL
#' 
#' @seealso \code{\link{smcmc-class}}, \code{\link{plot}}.
#' @aliases plot,smcmc,missing-method
#' @examples
#' data(ricker_smcmc)
#' 
#' # Functions for additional annotations (true parameters)
#' addline1 <- function(parNam, ...){ 
#'                abline(h = exp(ricker_smcmc@@param[parNam]), lwd = 2, lty = 2, col = 3) 
#'                }
#' addline2 <- function(parNam, ...){ 
#'                abline(v = exp(ricker_smcmc@@param[parNam]), lwd = 2, lty = 2, col = 3)
#'                }
#' 
#' # Transformations (exponentials)
#' trans <- rep("exp", 3)
#' names(trans) <- names(ricker_smcmc@@param)
#' 
#' plot(ricker_smcmc, 
#'      trans = trans,
#'      addPlot1 = "addline1", 
#'      addPlot2 = "addline2")
#' @rdname plot-smcmc
#'
#'
setMethod("plot",
          signature = signature(x = "smcmc", y = "missing"),
          definition = .plot.smcmc)





