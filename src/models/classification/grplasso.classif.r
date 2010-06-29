#' @include learnerR.r
roxygen()
#' @include wrapped.model.r
roxygen()
#' @include train.learner.r
roxygen()
#' @include pred.learner.r
roxygen()


setClass(
		"classif.grplasso", 
		contains = c("rlearner.classif")
)


setMethod(
		f = "initialize",
		signature = signature("classif.grplasso"),
		def = function(.Object) {
			
			desc = new("learner.desc.classif",
					oneclass = FALSE,
					twoclass = TRUE,
					multiclass = FALSE,
					missings = FALSE,
					numerics = TRUE,
					factors = FALSE,
					characters = FALSE,
					probs = TRUE,
					decision = FALSE,
					weights = TRUE,
					costs = FALSE
			)
			
			callNextMethod(.Object, label="grplasso", pack="grplasso", desc=desc)
		}
)

#' @rdname train.learner

setMethod(
		f = "train.learner",
		signature = signature(
				.learner="classif.grplasso", 
				.targetvar="character", 
				.data="data.frame", 
				.data.desc="data.desc", 
				.task.desc="task.desc", 
				.weights="numeric", 
				.costs="matrix" 
		),
		
		def = function(.learner, .targetvar, .data, .data.desc, .task.desc, .weights, .costs,  ...) {
			f = as.formula(paste(.targetvar, "~."))
			grplasso(f, data=.data, weights=.weights, ...)
		}
)

#' @rdname pred.learner

setMethod(
		f = "pred.learner",
		signature = signature(
				.learner = "classif.grplasso", 
				.model = "wrapped.model", 
				.newdata = "data.frame", 
				.type = "character" 
		),
		
		def = function(.learner, .model, .newdata, .type, ...) {
			p <- predict(.model["learner.model"], newdata=.newdata, ...)
			if(.type=="prob")
				return(p$class)
			else
				return(p$posterior)
		}
)	






