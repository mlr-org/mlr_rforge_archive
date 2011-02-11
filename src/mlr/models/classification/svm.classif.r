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
		"classif.svm", 
		contains = c("rlearner.classif")
)


setMethod(
		f = "initialize",
		signature = signature("classif.svm"),
		def = function(.Object) {
			
			desc = c(
					oneclass = FALSE,
					twoclass = TRUE,
					multiclass = TRUE,
					missings = FALSE,
					doubles = TRUE,
					factors = TRUE,
					prob = TRUE,
					decision = FALSE,
					weights = FALSE,
					costs = FALSE 
			)
			
      par.set = makeParameterSet(
        makeDiscreteLearnerParameter(id="type", default="C-classification", vals=c("C-classification", "nu-classification")),
        makeNumericLearnerParameter(id="cost",  default=1, lower=0, requires=expression(type=="C-classification")),
        makeNumericLearnerParameter(id="nu", default=0.5, requires=expression(type=="nu-classification")),
        makeDiscreteLearnerParameter(id="kernel", default="radial", vals=c("linear", "polynomial", "radial", "sigmoid")),
        makeIntegerLearnerParameter(id="degree", default=3L, lower=1L, requires=expression(kernel=="polynomial")),
        makeNumericLearnerParameter(id="coef0", default=0, requires=expression(kernel=="polynomial" || kernel=="sigmoid")),
        makeNumericLearnerParameter(id="gamma", lower=0, requires=expression(kernel!="linear")),
        makeNumericLearnerParameter(id="tolerance", default=0.001, lower=0),
        makeLogicalLearnerParameter(id="shrinking", default=TRUE),
        makeNumericLearnerParameter(id="cachesize", default=40L, flags=list(optimize=FALSE))
      )
      
			callNextMethod(.Object, pack="e1071", desc=desc, par.set=par.set)
		}
)

#' @rdname trainLearner

setMethod(
		f = "trainLearner",
		signature = signature(
				.learner="classif.svm", 
				.task="ClassifTask", .subset="integer" 
		),
		
		def = function(.learner, .task, .subset,  ...) {
			f = .task["formula"]
			svm(f, data=get.data(.task, .subset), probability=.learner["predict.type"] == "prob", ...)
		}
)

#' @rdname predictLearner

setMethod(
		f = "predictLearner",
		signature = signature(
				.learner = "classif.svm", 
				.model = "WrappedModel", 
				.newdata = "data.frame", 
				.type = "character" 
		),
		
		def = function(.learner, .model, .newdata, .type, ...) {
			if(.type=="response") {
				p = predict(.model["learner.model"], newdata=.newdata, ...)
			} else {
				p = predict(.model["learner.model"], newdata=.newdata, probability=TRUE, ...)
				p = attr(p, "probabilities")
			}
			return(p)
		}
)	


