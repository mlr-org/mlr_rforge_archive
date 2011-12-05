#' @include learnerR.r
roxygen()
#' @include RegrTask.R
roxygen()


setClass(
		"regr.ridge", 
		contains = c("rlearner.regr")
)


setMethod(
		f = "initialize",
		signature = signature("regr.ridge"),
		def = function(.Object) {
      par.set = makeParamSet(
        makeNumericLearnerParam(id="lambda2", default=0, lower=0)
      )

      .Object = callNextMethod(.Object, pack="penalized", par.set=par.set)
      
      setProperties(.Object,
        missings = TRUE,
        numerics = TRUE,
        factors = TRUE,
        se.fit = FALSE,
        weights = FALSE
      )
		}
)



#' @rdname trainLearner


setMethod(
		f = "trainLearner",
		signature = signature(
				.learner="regr.ridge", 
				.task="RegrTask", .subset="integer" 
		),
		
		def = function(.learner, .task, .subset, ...) {
      f = getFormula(.task)
      penalized(f, data=getData(.task, .subset), ...)
    }
)


#' @rdname predictLearner

setMethod(
		f = "predictLearner",
		signature = signature(
				.learner = "regr.ridge", 
				.model = "WrappedModel", 
				.newdata = "data.frame" 
		),
		
		def = function(.learner, .model, .newdata, ...) {
			m <- .model@learner.model
			.newdata[, .model@task.desc@target] <- 0
			predict(m, data=.newdata,  ...)[,"mu"]
		}
)	

