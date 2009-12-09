#' Base class for description of resampling algorithms.
#' A description of a resampling algorithm contains all necessary information to provide a resampling.instance, 
#' when given the size of the data set.
#' @slot instance.class S4 class name of the corresponding resample.instance
#' @slot name Name of this resampling algorithm
#' @slot iters Number of iterations
#' @exportClass resample.desc 
#' @title resample.desc

# todo validation for size
setClass(
		"resample.desc",                                                     
		representation = representation(
				instance.class="character", 
				name="character", 
				iters="numeric"
		)
)


#----------------- getter ---------------------------------------------------------

#' Getter.
#' @param x resample.desc object
#' @param i 
#' \describe{
#' 	\item{instance.class}{S4 class name of the corresponding resample.instance}
#' 	\item{name}{Name of this resampling algorithm}
#' 	\item{iters}{Number of iterations}
#' } 
#' @rdname getter,resample.desc-method
#' @aliases resample.desk.getter getter,resample.desc-method
#' @title Getter for resample.desc

setMethod(
		f = "[",
		signature = signature("resample.desc"),
		def = function(x,i,j,...,drop) {
			#if nothing special return slot
			return(
					eval(substitute("@"(x, slot), list(slot=i)))
			)
		}
)

