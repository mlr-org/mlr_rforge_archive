#' @include control.tune.r
roxygen()

#' @exportClass cmaes.control
#' @rdname cmaes.control 

setClass(
		"cmaes.control",
		contains = c("tune.control")
)


#' Control structure for CMA-ES tuning. 
#' 
#' @param path [boolean]\cr
#'   Should optimization path be saved? Default is TRUE.
#' @param start [numeric] \cr
#'   Named vector of initial values.
#' @param ... Further control parameters passed to the \code{control} argument of \code{\link[cmaes]{cma_es}}.
#' 		    
#' @return Control structure for tuning.
#' @exportMethod cmaes.control
#' @rdname cmaes.control 
#' @title Control for CMA-ES tuning. 


setGeneric(
		name = "cmaes.control",
		def = function(path, start, ...) {
			if (missing(path))
				path = TRUE
			if (missing(start))
				stop("You have to provide a start value!")
			standardGeneric("cmaes.control")
		}
)


#' @rdname cmaes.control 

setMethod(
		f = "cmaes.control",
		signature = signature(path="logical", start="numeric"),
		def = function(path, start, lower, upper, ...) {
			new("cmaes.control", path=path,	start=as.list(start), ...)
		}
)

