#' Optimizes the variables for a classification or regression problem by choosing a variable selection wrapper approach.
#' Allows for different optimization methods, such as forward search or a genetic algorithm.
#' You can select such an algorithm (and its settings)
#' by passing a corresponding control object. For a complete list of implemented algorithms look at the 
#' subclasses of [\code{\linkS4class{varsel.control}}].
#'
#' All algorithms operate on a 0-1-bit encoding of candidate solutions. Per default a single bit corresponds
#' to a single feature, but you are able to change this by using the arguments \code{bit.names} 
#' and \code{bits.to.features}. Thus allowing you to switch on whole groups of features with a single bit.  
#' 
#' @param learner [\code{\linkS4class{Learner}} or string]\cr 
#'   Learning algorithm. See \code{\link{learners}}.  
#' @param task [\code{\linkS4class{LearnTask}}] \cr
#'   Learning task.   
#' @param resampling [\code{\linkS4class{ResampleInstance}}] or [\code{\linkS4class{ResampleDesc}}]\cr
#'   Resampling strategy to evaluate feature sets. If you pass a description, 
#'   it is instantiated once at the beginning by default, so all feature sets are evaluated on the same training/test sets.
#'   If you want to change that behaviour, look at the control object.  
#' @param control [see \code{\link{varsel.control}}]
#'   Control object for search method. Also selects the optimization algorithm for feature selection. 
#' @param measures [list of \code{\linkS4class{Measure}}]\cr
#'   Performance measures to evaluate. The first measure, aggregated by the first aggregation function is optimized during selection, others are simply evaluated.  
#' @param bit.names [character]\cr
#'   Names of bits encoding the solutions. Also defines the total number of bits in the encoding.
#'   Per default these are the feature names of the task.    
#' @param bits.to.features [function(x, task)]\cr
#'   Function which transforms an integer-0-1 vector into a character vector of selected features. 
#'   Per default a value of 1 in the ith bit selects the ith feature to be in the candidate solution.      
#' @param log.fun [function(learner, task, resampling, measure, par.set, control, opt.path, x, y)]\cr
#'   Called after every hyperparameter evaluation. Default is to print performance via mlr logger. 
#' 
#' @return \code{\linkS4class{opt.result}}.
#' 
#' @export
#' @seealso \code{\link{makeVarselWrapper}} 
#' @title Variable selection.

varsel <- function(learner, task, resampling, control, measures, bit.names, bits.to.features, log.fun) {
  if (is.character(learner))
    learner <- makeLearner(learner)
  if (is(resampling, "ResampleDesc") && control@same.resampling.instance)
    resampling = makeResampleInstance(resampling, task=task)
  if (missing(measures))
    measures = default.measures(task)
  if (is(measures, "Measure"))
    measures = list(measures)   
  if (missing(bit.names))
    bit.names = getFeatureNames(task)
  if (missing(bits.to.features))
    bits.to.features = function(x, task) binary.to.vars(x, getFeatureNames(task)) 
  if (missing(log.fun))
    log.fun = log.fun.varsel
  
	cl = as.character(class(control))
	
	sel.func = switch(cl,
			sequential.control = varsel.seq,
			randomvarsel.control = varsel.random,
      exhvarsel.control = varsel.exhaustive,
      stop(paste("Feature selection algorithm for", cl, "does not exist!"))
	)

	if (missing(control)) {
		stop("You have to pass a control object!")
	}
  opt.path = makeOptPathFromMeasures(bit.names, measures)
  sel.func(learner, task, resampling, measures, bit.names, bits.to.features, control, opt.path, log.fun)
}
