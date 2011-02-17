#' @include ResampleInstance.R
#' @include CVDesc.r
roxygen()

setClass(
  "loo.instance", 
  contains = c("ResampleInstance.nonseq")
)                                                     

setMethod(
  f = "initialize",
  signature = signature("loo.instance"),
  def = function(.Object, desc, size, task) {
    callNextMethod(.Object, desc=desc, size=size, test.inds=as.list(1:size))
  }
)
