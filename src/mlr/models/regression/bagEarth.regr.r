#' @include learnerR.r
roxygen()
#' @include RegrTask.R
roxygen()

setClass(
		"regr.bagEarth", 
		contains = c("rlearner.regr")
)


setMethod(
		f = "initialize",
		signature = signature("regr.bagEarth"),
		def = function(.Object) {
			
			desc = c(
					missings = FALSE,
					numerics = TRUE,
					factors = TRUE,
					weights = FALSE
			)
			
			callNextMethod(.Object, pack="caret", desc=desc)
		}
)

#' @rdname trainLearner

setMethod(
		f = "trainLearner",
		signature = signature(
				.learner="regr.bagEarth", 
				.task="RegrTask", .subset="integer" 
		),
		
		def = function(.learner, .task, .subset,  ...) {
			f = .task["formula"]
			bagEarth(f, data=get.data(.task, .subset), ...)
		}
)

#' @rdname predictLearner

setMethod(
		f = "predictLearner",
		signature = signature(
				.learner = "regr.bagEarth", 
				.model = "WrappedModel", 
				.newdata = "data.frame", 
				.type = "missing" 
		),
		
		def = function(.learner, .model, .newdata, .type, ...) {
			predict.bagEarth(.model@learner.model, newdata=.newdata)
		}
)



