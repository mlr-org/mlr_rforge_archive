#' @include wrapped.model.r
roxygen()

#' Mainly for internal use. Predicts new data with wrapped.model. 
#' You have to implement this method if you want to add another learner to this package. 
#' @param .learner [\code{\link{wrapped.learner}}] \cr  
#'        Wrapped learner from this package. 
#' @param .model [\code{\link{character}}] \cr
#' 		  Model produced by training. 
#' @param .newdata [\code{\link{data.frame}}] \cr
#' 		  New data to predict.
#' @param type [\code{\link{character}}] \cr 
#' 		  Specifies the type of predictions - either probability ("prob") or class ("class").
#' 		  Ignore this if it is not classification or the learner does not support probabilities.	 
#' @param ...
#' 		  Additional parameters, which need to be passed to the underlying train function.
#' 		    
#' @return Model of the underlying learner.
#' 
#' @export
#' @rdname predict.learner
#' @title Internal prediction method for learner. 

setGeneric(
		name = "predict.learner",
		def = function(.learner, .model, .newdata, .type, ...) {
			standardGeneric("predict.learner")
		}
)


