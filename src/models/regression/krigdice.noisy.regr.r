#' @include learnerR.r
roxygen()
#' @include wrapped.model.r
roxygen()
#' @include train.learner.r
roxygen()
#' @include pred.learner.r
roxygen()


setClass(
  "regr.km.noisy", 
  contains = c("rlearner.regr")
)


setMethod(
  f = "initialize",
  signature = signature("regr.km.noisy"),
  def = function(.Object) {
    
    desc = new("learner.desc.regr",
      missings = FALSE,
      numerics = TRUE,
      factors = FALSE,
      characters = FALSE,
      weights = FALSE
    )
    
    callNextMethod(.Object, label="Krig", pack="DiceKriging", desc=desc)
  }
)

#' @rdname train.learner

setMethod(
  f = "train.learner",
  signature = signature(
    .learner="regr.km.noisy", 
    .targetvar="character", 
    .data="data.frame", 
    .data.desc="data.desc", 
    .task.desc="task.desc", 
    .weights="numeric", 
    .costs="missing" 
  ),
  
  def = function(.learner, .targetvar, .data, .data.desc, .task.desc, .weights, .costs,  ...) {
    y = .data[,.targetvar]
    .data[,.targetvar]=NULL
    m = km(design=.data, response=y, nugget.estim=TRUE, ...)
    m = km(design=.data, response=y, nugget.estim=FALSE, 
      coef.trend=m@trend.coef, coef.var=m@covariance@sd2, coef.cov=m@covariance@range.val)   
  }
)

#' @rdname pred.learner

setMethod(
  f = "pred.learner",
  signature = signature(
    .learner = "regr.km.noisy", 
    .model = "wrapped.model", 
    .newdata = "data.frame", 
    .type = "missing" 
  ),
  
  def = function(.learner, .model, .newdata, .type, ...) {
    p = predict(.model["learner.model"], newdata=.newdata, type="SK", se.compute=FALSE, ...)
    return(p$mean) 
  }
) 
