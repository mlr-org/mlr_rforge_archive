##' @include learnerR.r
#roxygen()
##' @include WrappedModel.R
#roxygen()
##' @include trainLearner.R
#roxygen()
##' @include predictLearner.R
#roxygen()
#
#
#setClass(
#		"classif.hda", 
#		contains = c("rlearner.classif")
#)
#
#
#setMethod(
#		f = "initialize",
#		signature = signature("classif.hda"),
#		def = function(.Object) {
#			
#			desc = c(
#					oneclass = FALSE,
#					twoclass = TRUE,
#					multiclass = TRUE,
#					missings = FALSE,
#					doubles = TRUE,
#					factors = FALSE,
#					characters = FALSE,
#					prob = TRUE,
#					decision = FALSE,
#					weights = FALSE,
#					costs = FALSE
#			)
#			
#			callNextMethod(.Object, pack="hda", desc=desc)
#		}
#)
#
##' @rdname trainLearner
#
#setMethod(
#		f = "trainLearner",
#		signature = signature(
#				.learner="classif.hda", 
#				.task="ClassifTask", .subset="integer" 
#		),
#		
#		def = function(.learner, .task, .subset,  ...) {
#			f = .task["formula"]
#			hda(f, data=get.data(.task, .subset), crule=TRUE, ...)
#		}
#)
#
##' @rdname predictLearner
#
#setMethod(
#		f = "predictLearner",
#		signature = signature(
#				.learner = "classif.hda", 
#				.model = "WrappedModel", 
#				.newdata = "data.frame", 
#				.type = "character" 
#		),
#		
#		#todo wie neue daten vorhersagen?
#		def = function(.learner, .model, .newdata, .type, ...) {
#			.type = ifelse(.type=="response", "class", "raw")
#			m = .model["learner.model"]
#			predict(m$naivebayes, m$hda.scores, newdata=.newdata, type=.type, ...)
#		}
#)	
#
#
#
