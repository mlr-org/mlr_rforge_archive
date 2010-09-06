#' @include control.tune.r
roxygen()

#' @exportClass myspo.control
#' @rdname myspo.control 

setClass(
  "myspo.control",
  contains = c("tune.control"),
  representation = representation(
    meta.learner = "learner",
    constr.learner = "learner",
    init.des.points = "integer",
    seq.des.points = "integer",
    seq.loops = "integer"
  )
)

setMethod(
  f = "initialize",
  signature = signature("myspo.control"),
  def = function(.Object, minimize, tune.threshold, thresholds, path, par.descs, scale, 
    meta.learner, init.des.points, seq.des.points, seq.loops,...) {
    if (missing(minimize))
      return(.Object)
    .Object@meta.learner = meta.learner
    .Object@init.des.points = init.des.points
    .Object@seq.des.points = seq.des.points
    .Object@seq.loops = seq.loops
    .Object = callNextMethod(.Object=.Object, minimize, tune.threshold, thresholds, path, start=list(), par.descs, scale, ...)
    return(.Object)
  }
)

#' Control structure for CMA-ES tuning. 
#' 
#' @param minimize [logical] \cr 
#'       Minimize performance measure? Default is TRUE. 
#' @param tune.threshold [logical] \cr 
#'       Perform empirical thresholding? Default is FALSE. Only supported for binary classification and you have to set predict.type to "prob" for this in make.learner. 
#' @param thresholds [numeric] \cr 
#'    Number of thresholds to try in tuning. Predicted probabilities are sorted and divided into groups of equal size. Default is 10.             
#' @param path [boolean]\cr
#'        Should optimization path be saved?
#' @param start [numeric] \cr
#'    Named vector of initial values.
#' @param lower [numeric] \cr
#'    Named vector of lower boundary constraints. Default is -Inf. 
#' @param upper [numeric] \cr
#'    Named vector of upper boundary constraints. Default is Inf. 
#' @param scale [\code{\link{function}}] \cr 
#'    A function to scale the hyperparameters. E.g. maybe you want to optimize in some log-space.
#'    Has to take a vector and return a scaled one. Default is identity function.
#' @param ... Further control parameters passed to the \code{control} argument of \code{\link[myspo]{myspo}}.
#'        
#' @return Control structure for tuning.
#' @exportMethod myspo.control
#' @rdname myspo.control 
#' @title Control for CMA-ES tuning. 


setGeneric(
  name = "myspo.control",
  def = function(minimize, tune.threshold, thresholds, path, par.descs, scale, 
    meta.learner, init.des.points, seq.des.points, seq.loops, ...) {
    if (missing(minimize))
      minimize=TRUE
    if (missing(tune.threshold))
      tune.threshold=FALSE
    if (missing(thresholds))
      thresholds=10
    if (is.numeric(thresholds))
      thresholds = as.integer(thresholds)
    if (missing(path))
      path = FALSE
    if (missing(scale))
      scale=identity
    if (missing(meta.learner))
      meta.learner="regr.rpart"
    if (is.character(meta.learner))
      meta.learner = make.learner(meta.learner)
    if (missing(init.des.points))
      init.des.points = 5L
    if (missing(seq.des.points))
      seq.des.points = 5L
    if (missing(seq.loops))
      seq.loops = 5L
    standardGeneric("myspo.control")
  }
)


#' @rdname myspo.control 

setMethod(
  f = "myspo.control",
  signature = signature(minimize="logical", tune.threshold="logical", thresholds="integer", path="logical", par.descs="list", scale="function",
    meta.learner="learner", init.des.points="integer", seq.des.points="integer", seq.loops="integer"),
  def = function(minimize, tune.threshold, thresholds, path, par.descs, scale,
    meta.learner, init.des.points, seq.des.points, seq.loops, ...) {
    new("myspo.control", minimize=minimize, tune.threshold=tune.threshold, thresholds=thresholds, path=path,
      par.descs=par.descs, scale=scale, 
      meta.learner=meta.learner, init.des.points=init.des.points, seq.des.points=seq.des.points, seq.loops=seq.loops, ...)
  }
)

