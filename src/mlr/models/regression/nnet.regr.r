#' @include learnerR.r
roxygen()
#' @include WrappedModel.R
roxygen()
#' @include trainLearner.R
roxygen()
#' @include predictLearner.R
roxygen()
#' @include RegrTask.R
roxygen()


setClass(
    "regr.nnet", 
    contains = c("rlearner.regr")
)


setMethod(
    f = "initialize",
    signature = signature("regr.nnet"),
    def = function(.Object) {
      
      setProperties(.Object,
          missings = FALSE,
          numerics = TRUE,
          factors = TRUE,
          weights = TRUE
      )
      
      par.set = makeParameterSet(
        makeIntegerLearnerParameter(id="size", default=3L, lower=0, pass.default=TRUE),
        makeIntegerLearnerParameter(id="maxit", default=100L, lower=1L)
      )
      
      .Object = callNextMethod(.Object, pack="nnet", par.set=par.set)
    }
)

#' @rdname trainLearner

setMethod(
    f = "trainLearner",
    signature = signature(
        .learner="regr.nnet", 
        .task="RegrTask", .subset="integer" 
    ),
    
    def = function(.learner, .task, .subset,  ...) {
      f = .task["formula"]
      if (.task["has.weights"])
        nnet(f, data=get.data(.task, .subset), linout=T, weights=.task@weights[.subset], ...)
      else  
        nnet(f, data=get.data(.task, .subset), linout=T, ...)
    }
)

#' @rdname predictLearner

setMethod(
    f = "predictLearner",
    signature = signature(
        .learner = "regr.nnet", 
        .model = "WrappedModel", 
        .newdata = "data.frame", 
        .type = "missing" 
    ),
    
    def = function(.learner, .model, .newdata, .type, ...) {
      predict(.model@learner.model, newdata=.newdata, ...)[,1]
    }
) 
