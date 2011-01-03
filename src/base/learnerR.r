#' @include object.r
roxygen()
#' @include learner.r
roxygen()

#' Wraps an already implemented learning method from R to make it accessible to mlr.
#'  
#' @exportClass rlearner
#' @title Base class for inducers. 

setClass(
  "rlearner",
  contains = c("learner"),
  representation = representation(
    missings="logical",
    feat="logical",
    weights="logical"
  )    
)

#' Getter.
#' @rdname rlearner-class

setMethod(
		f = "[",
		signature = signature("rlearner"),
		def = function(x,i,j,...,drop) {
			if (i == "is.classif") {
				return(is(x, "rlearner.classif"))
			}
			if (i == "is.regr") {
				return(is(x, "rlearner.regr"))
			}
      if (i == "doubles") {
        return(x@feat["doubles"])
      }
      if (i == "factors") {
        return(x@feat["factors"])
      }
			callNextMethod()
		}
)

#' Getter.
#' @rdname rlearner-class

setMethod(
  f = "[",
  signature = signature("rlearner.classif"),
  def = function(x,i,j,...,drop) {
    if (i == "prob") {
      return(x@predict["prob"])
    }
    if (i == "decision") {
      return(x@predict["decision"])
    }
    if (i == "oneclass") {
      return(x@classes["oneclass"])
    }
    if (i == "twoclass") {
      return(x@classes["twoclass"])
    }
    if (i == "multiclass") {
      return(x@classes["multiclass"])
    }
    callNextMethod()
  }
)


#---------------- constructor---- -----------------------------------------------------


#' Base class for classification learners.
#' @exportClass rlearner.classif
#' @title Base class for classification learners. 
setClass("rlearner.classif", 
  contains = c("rlearner"),
  representation = representation(
    classes="logical",
    predict="logical",
    costs="logical",
    predict.type = "character"
  )  
)

#' Constructor.
#' @title rlearner constructor
setMethod(
  f = "initialize",
  signature = signature("rlearner.classif"),
  def = function(.Object, id, pack, desc, par.descs=list(), par.vals=list()) {
    if (missing(desc))
      return(make.empty(.Object))
    if (missing(id))
      id = as.character(class(.Object))
    ns = c("doubles", "factors", "missings", "weights", "oneclass", "twoclass", "multiclass", "decision", "prob", "costs")
    if (!setequal(names(desc), ns))
      stop("Logical description of ", id, " must exactly contain: ", paste(ns, collapse=","))
    .Object@feat = c(desc["doubles"], desc["factors"])  
    .Object@weights = desc["weights"]  
    .Object@missings = desc["missings"]
    .Object@classes = c(desc["oneclass"], desc["twoclass"], desc["multiclass"])
    .Object@predict = c(desc["prob"], desc["decision"])
    .Object@costs = desc["costs"]
    .Object@predict.type = "response"
    callNextMethod(.Object, id=id, pack=pack, par.desc=par.descs, par.vals=par.vals)
  }
)


#' Base class for regression learners.
#' @exportClass rlearner.regr
#' @title Base class for regression learners. 
setClass("rlearner.regr", contains = c("rlearner"))

#' Constructor.
#' @title rlearner constructor
setMethod(
  f = "initialize",
  signature = signature("rlearner.regr"),
  def = function(.Object, id, pack, desc, par.descs=list(), par.vals=list()) {
    if (missing(desc))
      return(make.empty(.Object))
    if (missing(id))
      id = as.character(class(.Object))
    ns = c("doubles", "factors", "missings", "weights") 
    if (!setequal(names(desc), ns))
    stop("Logical description of ", id, " must exactly contain: ", paste(ns, collapse=","))
    .Object@feat = c(desc["doubles"], desc["factors"])  
    .Object@weights = desc["weights"]  
    .Object@missings = desc["missings"]
    callNextMethod(.Object, id=id, pack=pack, par.desc=par.descs, par.vals=par.vals)
  }
)

#' @rdname to.string
setMethod(f = "to.string",
  signature = signature("rlearner.classif"),
  def = function(x) {
    hps = x["par.vals"]
    hps.ns = names(hps)
    hps = Map(function(n, v) hyper.par.val.to.name(n,v,x), hps.ns, hps)
    hps = paste(hps.ns, hps, sep="=", collapse=" ")
    pack = paste(x["pack"], collapse=",")
    return(paste(
        "Classification learner id=", x["id"], " from package ", pack, "\n",
        "Class: ", class(x), "\n",
        "Predict-Type: ", x["predict.type"], "\n",
        "Hyperparameters: ", hps, "\n\n",
        "Supported features Doubles:", x["doubles"], " Factors:", x["factors"], "\n",
        "Supports missings: ", x["missings"], "\n", 
        "Supports weights: ", x["weights"], "\n", 
        "Supports classes: ", paste(c("one", "two", "multi")[x@classes], collapse=","), "\n",
        "Supports probabilities: ", x["prob"], "\n", 
        "Supports decision values: ", x["decision"], "\n", 
        "Supports costs: ", x["costs"], "\n", 
        sep =""					
      ))
})

#' @rdname to.string
setMethod(f = "to.string",
  signature = signature("rlearner.regr"),
  def = function(x) {
    hps = x["par.vals"]
    hps.ns = names(hps)
    hps = Map(function(n, v) hyper.par.val.to.name(n,v,x), hps.ns, hps)
    hps = paste(hps.ns, hps, sep="=", collapse=" ")
    pack = paste(x["pack"], collapse=",")
    return(paste(
        "Regression learner id=", x["id"], " from package ", pack, "\n",
        "Class: ", class(x), "\n",
        "Hyperparameters: ", hps, "\n\n",
        "Supported features Doubles:", x["doubles"], " Factors:", x["factors"], "\n",
        "Supports missings: ", x["missings"], "\n", 
        "Supports weights: ", x["weights"], "\n", 
        sep =""					
      ))
  })



