#' @include learnerR.r
roxygen()
#' @include WrappedModel.R
roxygen()
#' @include trainLearner.r
roxygen()
#' @include predictLearner.r
roxygen()
#' @include ClassifTask.R
roxygen()


setClass(
		"classif.lvq1", 
		contains = c("rlearner.classif")
)


setMethod(
		f = "initialize",
		signature = signature("classif.lvq1"),
		def = function(.Object) {
			
			desc = c(
					oneclass = FALSE,
					twoclass = TRUE,
					multiclass = TRUE,
					missings = FALSE,
					doubles = TRUE,
					factors = TRUE,
					prob = FALSE,
					decision = FALSE,
					weights = FALSE,
					costs = FALSE
			)
			
			callNextMethod(.Object, pack="class", desc=desc)
		}
)

#' @rdname trainLearner

setMethod(
		f = "trainLearner",
		signature = signature(
				.learner="classif.lvq1", 
				.task="ClassifTask", .subset="integer" 
		),
		
		def = function(.learner, .task, .subset,  ...) {
      d = get.data(.task, .subset, target.extra=TRUE)
			cdbk.args = insert(list(), list(...), c("size", "k", "prior"))
			cdbk.args$x = d$data
			cdbk.args$cl = d$target 
			codebk = do.call(lvqinit, cdbk.args)  

			lvq.args = insert(list(), list(...), c("niter", "alpha"))
			lvq.args$x = d$data 
			lvq.args$cl = d$target 
			lvq.args$codebk = codebk 
			do.call(lvq1, lvq.args)  
		}
)

#' @rdname predictLearner

setMethod(
		f = "predictLearner",
		signature = signature(
				.learner = "classif.lvq1", 
				.model = "WrappedModel", 
				.newdata = "data.frame", 
				.type = "character" 
		),
		
		def = function(.learner, .model, .newdata, .type, ...) {
			lvqtest(.model["learner.model"], test=.newdata, ...)
		}
)	






