#' @include task.learn.r
roxygen()

#' General description object for a classification experiment.   
#' Instantiate it by using its factory method.
#' 
#' @slot costs Matrix of misclassification costs. Default is zero-one loss. 
#' 
#' @exportClass classif.task
#' @title classif.task
#' @seealso make.regr.task 


setClass(
		"classif.task",
		contains = c("learn.task"),
		representation = representation(
				costs = "matrix"
		)
)



#---------------- constructor---- -----------------------------------------------------

#' Constructor.
#' @title classif.task constructor

setMethod(
		f = "initialize",
		signature = signature("classif.task"),
		def = function(.Object, name, target, data, excluded, weights, costs) {
			
			
			if (missing(data))
				return(.Object)
			
			.Object@costs <- costs
			
			.Object = callNextMethod(.Object, name=name, data=data, weights=weights, target=target, excluded=excluded, prep.fct=prep.classif.data)
			# costs are set to default after data prep
			if (identical(dim(.Object@costs), c(0L,0L))) {
				n <- .Object["class.nr"]
				.Object@costs <- matrix(1,n,n) - diag(1,n)
			}
			return(.Object)
		}
)

#' Getter.
#' @param x classif.task object
#' @param i [character]
#' \describe{
#'   \item{class.levels}{All possible class values.}
#'   \item{class.nr}{Number of different classes.}
#' }
#' @rdname getter,classif.task-method
#' @aliases classif.task.getter getter,classif.task-method
#' @seealso \code{\link{getter,learn.task-method}}
#' @title Getter for classif.task

setMethod(
		f = "[",
		signature = signature("classif.task"),
		def = function(x,i,j,...,drop) {

			if (i == "class.levels") {
				return(levels(x["targets"]))
			}
			if (i == "class.nr") {
				return(length(levels(x["targets"])))
			}
			# otherwise drop gets lost. bug in S4
			callNextMethod(x,i,j,...,drop=drop)
		}
)


#' Conversion to string.
setMethod(
		f = "to.string",
		signature = signature("classif.task"),
		def = function(x) {
			return(
					paste(
							"Classification problem ", x@name, "\n",
							to.string(x@data.desc),
							"Classes:", x["class.nr"],
							paste(capture.output(table(x["targets"])), collapse="\n"),
							"\n",
							sep=""
					)
			)
		}
)


