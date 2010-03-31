#' Mainly for internal use. Trains a wrapped learner on a giving training set, 
#' w.r.t. some hyperparamters, case weights and costs.
#' You have to implement this method if you want to add another learner to this package. 
#' @param .wrapped.learner [\code{\link{wrapped.learner}}] \cr  
#'        Wrapped learner from this package. 
#' @param .targetvar [\code{\link{character}}] \cr
#' 		  Name of the target variable.
#' @param .data [\code{\link{data.frame}}] \cr
#' 		  Complete training set.
#' @param weights [\code{\link{numeric}}] \cr
#' 		  Case weights, default is 1, which means every case is assigned equal weight.
#' 		  If your learner does not support this, simply ignore this argument.  
#' @param costs [\code{\link{matrix}}] \cr
#' 		  Misclassification costs, which should be used during training. 
#' 		  If your learner does not support this, simply ignore this argument.  
#' @param ...
#' 		  Additional parameters, which need to be passed to the underlying train function.
#' 		    
#' @return Model of the underlying learner.
#' @exportMethod train.learner
#' @aliases train.learner 
#' @title train.learner 

setGeneric(
		name = "train.learner",
		def = function(.wrapped.learner, .targetvar, .data, .weights, .costs, .type, ...) {
			standardGeneric("train.learner")
		}
)

