#' @include object.r
roxygen()

#' Description object for task, encapsulates basic statistics without having to store the complete data set.
#' 
#' Getter.\cr
#' 
#' \describe{
#'  \item{id [string]}{Id string of task.}
#'  \item{is.classif [boolean]}{Classification task?}
#'  \item{is.regr [boolean]}{Regression task?}
#'  \item{target [string]}{Name of target variable.}
#'  \item{formula [formula]}{Formula of form: target~.}
#'  \item{size [integer]}{Number of cases.}
#'  \item{dim [integer]}{Number of covariates.}
#'  \item{n.feat [integer]}{Number of covariates, named vector with entries: 'double', 'fact', 'int', 'char', 'log'.}
#'  \item{has.missing [boolean]}{Are missing values present?}
#'  \item{has.inf [boolean]}{Are infinite numerical values present?}
#'  \item{class.levels [character]}{Class labels. NA if not classification.}
#'  \item{class.nr [integer]}{Number of classes. NA if not classification.}
#'  \item{class.dist [integer]}{Class distribution. Named vector. NA if not classification.}
#'  \item{is.binary [boolean]}{Binary classification? NA if not classification.}
#'  \item{has.weights [boolean]}{Are weights available in task for covariates?}
#'  \item{has.blocking [boolean]}{Is blocking available in task for observations?}
#'  \item{costs [matrix]}{Cost matrix, of dimension (0,0) if not available.}
#'  \item{positive [string]}{Positive class label for binary classification, NA else.}
#'  \item{negative [string]}{Negative class label for binary classification, NA else.}
#' }
#' 
#' @exportClass task.desc
#' @seealso \code{\linkS4class{LearnTask}}
#' @title Description object for task. 

setClass(
		"task.desc",
		contains = c("object"),
		representation = representation(
				task.class = "character",
        id = "character",
        target = "character",
        size = "integer",
        n.feat = "integer",
        class.dist = "integer",
        has.missing = "logical",
        has.inf = "logical",
        has.weights = "logical",
        has.blocking = "logical",
        costs = "matrix",
        positive = "character" 
		)
)

#' Constructor.
setMethod(
  f = "initialize",
  signature = signature("task.desc"),
  def = function(.Object, data, target, task.class, id, has.weights, has.blocking, costs, positive) {
    .Object@task.class = task.class
    .Object@id = id
    i = which(colnames(data) %in% c(target))
    .Object@target = target 
    .Object@size = nrow(data)
    y = data[, target]
    .Object@n.feat = c(
      double = sum(sapply(data, is.double)) - is.double(y), 
      int  = sum(sapply(data, is.integer)) - is.integer(y),
      fact = sum(sapply(data, is.factor)) - is.factor(y),
      char = sum(sapply(data, is.character)) - is.character(y),
      log = sum(sapply(data, is.logical)) - is.logical(y)
    )
    .Object@has.missing = any(is.na(data))
    .Object@has.inf = any(is.infinite(data))
    if(is.factor(y))
      .Object@class.dist = {tab=table(y);cl=as.integer(tab); names(cl)=names(tab);cl}
    else
      .Object@class.dist = as.integer(NA)
    
    .Object@has.weights = has.weights
    .Object@has.blocking = has.blocking
    .Object@costs = costs
    .Object@positive = positive
    return(.Object)
  }
)

#' @rdname task.desc-class
setMethod(
		f = "[",
		signature = signature("task.desc"),
		def = function(x,i,j,...,drop) {
      if (i == "is.classif")
				return(x@task.class == "ClassifTask")
			if (i == "is.regr")
				return(x@task.class == "RegrTask")
      if (i == "formula") {
        return(as.formula(paste(x["target"], "~.")))
      }
      if (i == "dim") 
        return(sum(x@n.feat))
      if (i == "class.levels") 
        if(x["is.classif"]) return(names(x["class.dist"])) else return(as.character(NA))
      if (i == "class.nr") 
        if(x["is.classif"]) return(length(x["class.dist"])) else return(as.integer(NA))
      if (i == "is.binary") 
        if(x["is.classif"]) return(x["class.nr"] == 2) else return(as.logical(NA))
      if (i == "negative") 
        if(x["is.classif"] && x["is.binary"]) 
          return(setdiff(x["class.levels"], x["positive"])) 
        else 
          return(as.character(NA))
      if (i == "has.costs") 
        if(x["is.classif"]) return(all(dim(x@costs)!=0)) else return(as.logical(NA))
      
			callNextMethod()
		}
)





