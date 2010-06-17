#' @include control.varsel.r
roxygen()

#' @exportClass randomvarsel.control
#' @rdname randomvarsel.control 

setClass(
		"randomvarsel.control",
		contains = c("varsel.control"),
		representation = representation(
				method = "character",
				prob = "numeric"
		)
)

#' Constructor.
setMethod(
		f = "initialize",
		signature = signature("randomvarsel.control"),
		def = function(.Object, minimize, tune.threshold, thresholds, maxit, max.vars, method, prob) {
			.Object = callNextMethod(.Object, minimize, tune.threshold, thresholds, maxit=maxit)
			.Object@method = method 			
			.Object@prob = prob 			
			return(.Object)
		}
)


#' Control structure for random variable selection. 
#' 
#' @param minimize [logical] \cr 
#'       Minimize performance measure? Default is TRUE.
#' @param maxit [integer] \cr 
#'       Maximal number of variable sets to evaluate. Default is 100.
#' @param tune.threshold [logical] \cr 
#'		Perform empirical thresholding? Default is FALSE. Only supported for binary classification and you have to set predict.type to "prob" for this in make.learner. 
#' @param thresholds [numeric] \cr 
#'		Number of thresholds to try in tuning. Predicted probabilities are sorted and divided into groups of equal size. Default is 10. 		        
#' 		    
#' @return Control structure.
#' @exportMethod randomvarsel.control
#' @rdname randomvarsel.control 
#' @title Control structure for random variable selection. 


setGeneric(
		name = "randomvarsel.control",
		def = function(minimize, tune.threshold, thresholds, maxit, method, prob) {
			if (missing(minimize))
				minimize=TRUE
			if (missing(tune.threshold))
				tune.threshold=FALSE
			if (missing(thresholds))
				thresholds=10
			if (is.numeric(thresholds))
				thresholds = as.integer(thresholds)
			if (missing(maxit))
				maxit = 100
			if (is.numeric(maxit))
				maxit = as.integer(maxit)
			if (missing(method))
				method = binomial
			if (missing(prob))
				prob = 0.5
			standardGeneric("randomvarsel.control")
		}
)



setMethod(
		f = "randomvarsel.control",
		signature = signature(minimize="logical", tune.threshold="logical", thresholds="integer", 
				maxit="integer", method="character", prob="numeric"),
		def = function(minimize, tune.threshold, thresholds, maxit, method, prob) {
			new("randomvarsel.control", minimize=minimize, tune.threshold=tune.threshold, thresholds=thresholds, 
					maxit=maxit, max.vars=max.vars, method=method, prob=prob)
		}
)



