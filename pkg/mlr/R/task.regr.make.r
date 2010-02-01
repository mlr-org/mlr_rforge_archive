#' @include task.regr.r
roxygen()

#' \code{make.regr.task} defines a regression task for a learner and a data set and is the starting point 
#' for further steps like training, predicting new data, resampling and tuning.
#' 
#' \code{make.regr.task} already performs quite a few tasks: It tries to load required package for the 
#' learner, sets up the learner to deal with a regression problem, gathers information about the features 
#' of the data set and the method, and compares whether they are compatible 
#' (e.g. some methods might not handle NAs or factors). It also might perform some data conversions 
#' in the data.frame, like coverting integer features to numerics, but will generally  
#' warn about this.
#' 
#' List of supported learning algorithms. The naming conventions are to add the package name as a prefix if
#' a learner is implemented in different packages and the suffix ".regr" if it can handle more than a
#' regression task.  
#' 
#' \itemize{ 
#' 		\item{\code{\linkS4class{stats.lm}}}{ Simple linear regression from stats package}
#' 		\item{\code{\linkS4class{penalized.ridge}}}{ Ridge regression from penalized package}
#' 		\item{\code{\linkS4class{penalized.lasso}}}{ Lasso regression from penalized package}
#' 		\item{\code{\linkS4class{kknn.regr}}}{ K-Nearest-Neigbor regression from kknn package}
#' 		\item{\code{\linkS4class{gbm.regr}}}{ Gradient boosting machine from gbm package}
#' 		\item{\code{\linkS4class{blackboost.regr}}}{ Gradient boosting with regression trees from mboost package}
#' }
#' 
#' @param name [\code{\link{character}}] \cr
#'   	  Name of task / data set to be used string representations later on. Default is empty string.
#' @param target [\code{\link{character}}] \cr
#'        Name of the target variable.
#' @param formula [\code{\link{formula}}] \cr
#'        Instead of specifying the target, you can use the formula interface. 
#'        If you are using just a subset of the variables of transformations of the variables, this will built a new internal 
#'        data frame by calling \code{\link{model.frame}}.
#' @param data [\code{\link{data.frame}}] \cr
#'   	  A data frame containing the variables in the model.
#' @param excluded [\code{\link{character}}]
#'        Names of inputs, which should be generally disregarded, e.g. IDs, etc. Default is zero-length vector. 
#' @param weights [\code{\link{numeric}}] \cr
#'        An optional vector of weights to be used in the fitting process. Default is a weight of 1 for every case.
#' 
#' @return An object of class \code{\linkS4class{regr.task}}.
#' 
#' @export
#' @rdname make.regr.task
#' 
#' @usage make.regr.task(name, data, target, formula, excluded, weights)
#'
#' @examples
#' library(mlbench)
#' data(BostonHousing)
#' # define a regression for the data set BostonHousing
#' rt <- make.regr.task(data = BostonHousing, target = "medv")
#' 
#' @seealso \code{\linkS4class{regr.task}}
#' 
#' @title Contruct regression task


setGeneric(
		name = "make.regr.task",
		def = function(name, data, target, formula, excluded, weights) {
#			if (is.character(learner))
#				learner <- new(learner)
#			if (!is(learner, "wrapped.learner.regr"))
#				stop("Trying to constuct a regr.task from a non regression learner: ", class(learner))
			if(missing(name))
				name=""
			if (missing(excluded))
				excluded <- character(0)
			if (missing(weights))
				weights <- rep(1, nrow(data))
			standardGeneric("make.regr.task")
		}
)

#' @export


setMethod(
		f = "make.regr.task",
		signature = signature(
				name = "character",
				data = "data.frame", 
				target = "character",
				formula = "missing",
				excluded = "character",
				weights = "numeric" 
		),
		
		def = function(name, data, target, excluded, weights) {
			ct <- new("regr.task", name=name, target=target, data=data, excluded=excluded, weights=weights)
			return(ct)
		}
)


#' @export

setMethod(
		f = "make.regr.task",
		signature = signature(
				target = "missing",
				formula = "formula",
				data = "data.frame", 
				excluded = "character",
				weights = "numeric" 
		),
		
		def = function(name, data, formula, excluded, weights) {
			data2 <- model.frame(formula, data=data)
			target <- as.character(formula)[2]
			ct <- new("regr.task", name=name, target=target, data=data2, excluded=excluded, weights=weights)
			return(ct)
		}
)



