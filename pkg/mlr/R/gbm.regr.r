#' @include learnerR.r
roxygen()


setClass(
		"regr.gbm", 
		contains = c("rlearner.regr")
)


	

setMethod(
		f = "initialize",
		signature = signature("regr.gbm"),
		def = function(.Object) {
			
			desc = new("regr.props",
					supports.missings = TRUE,
					supports.numerics = TRUE,
					supports.factors = TRUE,
					supports.characters = FALSE,
					supports.weights = TRUE
			)
			
			callNextMethod(.Object, label="GBM", pack="gbm", props=desc, 
					parset.train=list(distribution = "gaussian"))
		}
)

#' @rdname train.learner

setMethod(
		f = "train.learner",
		signature = signature(
				.learner="regr.gbm", 
				.targetvar="character", 
				.data="data.frame", 
				.data.desc="data.desc", 
				.task.desc="task.desc", 
				.weights="numeric", 
				.costs="missing" 
		),
		
		def = function(.learner, .targetvar, .data, .data.desc, .task.desc, .weights, .costs,  ...) {
			f = as.formula(paste(.targetvar, "~."))
			gbm(f, data=.data, weights=.weights, keep.data=FALSE, ...)
		}
)

#' @rdname pred.learner

setMethod(
		f = "pred.learner",
		signature = signature(
				.learner = "regr.gbm", 
				.model = "wrapped.model", 
				.newdata = "data.frame", 
				.type = "missing" 
		),
		
		def = function(.learner, .model, .newdata, .type, ...) {
			m <- .model["learner.model"]
			predict(m, newdata=.newdata, n.trees=length(m$trees), ...)
		}
)	






