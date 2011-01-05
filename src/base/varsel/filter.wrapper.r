
#' Wrapper class for learners to filter variables. Experimental. Can currently 
#' only filter to manually selected variables. 
#' 
#' @exportClass filter.wrapper
#' @title Wrapper class for learners to filter variables.

#' @exportClass filter.wrapper
setClass(
		"filter.wrapper",
		contains = c("base.wrapper"),
		representation = representation(
		)
)


#' Fuses a base learner with a filter method. Creates a learner object, which can be
#' used like any other learner object. 
#' Internally Uses \code{\link{varfilter}} before every model fit. 
#' 
#' Look at package FSelector for details on the filter algorithms. 
#' 
#' @param learner [\code{\linkS4class{learner}} or string]\cr 
#'   Learning algorithm. See \code{\link{learners}}.  
#' @param fw.method [string] \cr
#'   Filter method. Available are:
#'   linear.correlation, rank.correlation, information.gain, gain.ratio, symmetrical.uncertainty, chi.squared, random.forest.importance, relief, oneR
#' @param fw.threshold [single double] \cr
#'   Only features whose importance value exceed this are selected.  
#' 
#' @return \code{\linkS4class{learner}}.
#' 
#' @title Fuse learner with filter method.
#' @export
make.filter.wrapper = function(learner, fw.method="information.gain", fw.threshold) {
  # todo check that for some the inputs have to be all num. or accept error in train and NA in predict?
  pds = list(
    new("par.desc.disc", par.name="fw.method",
      vals=c("linear.correlation", "rank.correlation", "information.gain", "gain.ratio", 
        "symmetrical.uncertainty", "chi.squared", "random.forest.importance", "relief", "oneR")),
    new("par.desc.double", par.name="fw.threshold")
  )
	w = new("filter.wrapper", learner=learner, pack="FSelector", par.descs=pds, par.vals=list(fw.threshold=fw.threshold))
}



#' @rdname train.learner
setMethod(
		f = "train.learner",
    signature = signature(
      .learner="filter.wrapper", 
      .task="learn.task", .subset="integer"
    ),
		
		def = function(.learner, .task, .subset,  ...) {
      .task = subset(.task, subset=.subset)  
      tn = .task["target"]
      args = list(...)
      vars = varfilter(.task, args$fw.method, args$fw.threshold)$vars
      if (length(vars) > 0) {
        .task = subset(.task, vars=vars)  
        # !we have already subsetted!
			  m = callNextMethod(.learner, .task, 1:.task["size"], ...)
      } else {
        # !we have already subsetted!
        m = new("novars", targets=.task["targets"], task.desc=.task["desc"])
      }
      # set the vars as attribute, so we can extract it later 
      attr(m, "filter.result") = vars
      return(m)
		}
)

#' @rdname pred.learner

setMethod(
  f = "pred.learner",
  signature = signature(
    .learner = "filter.wrapper", 
    .model = "wrapped.model", 
    .newdata = "data.frame", 
    .type = "character" 
  ),
  
  def = function(.learner, .model, .newdata, .type, ...) {
    vars = .model["vars"] 
    .newdata = .newdata[, vars, drop=FALSE]  
    callNextMethod(.learner, .model, .newdata, .type, ...)
  }
) 

