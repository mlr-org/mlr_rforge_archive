#' @include task.learn.r
roxygen()

#' Given a \code{\linkS4class{learn.task}}, creates a model for the learning machine 
#' which can be used for predictions on new data. 
#'
#' @param learner [\code{\linkS4class{wrapped.learner}} or string]\cr 
#'        Learning algorithm. See learners.  
#' @param task [\code{\linkS4class{learn.task}}]\cr 
#'        Specifies learning task.   
#' @param subset [\code{\link{integer}}] \cr 
#'        An index vector specifying the training cases to be used for fitting. By default the complete dataset is used. 
#' @param vars [\code{\link{character}}] \cr
#'       Vector of variable names to use in training the model. Default is to use all variables, except the excluded in the task.
#' @param type [string] \cr
#'        Classification: "response" | "prob" | "decision", specifying the type to predict later.
#' 		  Default is "response". Very rarely you have to set this during training as well, as the fitted models differ.	 
#'
#' @return An object of class \code{\linkS4class{wrapped.model}}. 
#'
#' @export
#'
#' @usage train(learner, task, subset, vars, type)  
#'
#' @seealso \code{\link{predict}} 
#' 
#' @title Training a learning algorithm.
#' @rdname train

setGeneric(
		name = "train",
		def = function(learner, task, subset, vars, type) {
			if (is.character(learner))
				learner <- make.learner(learner, task)
			if (missing(subset))
				subset <- 1:task["size"]
			if (missing(vars))
				vars <- task["input.names"]
			if (length(vars) == 0)
				vars <- character(0)
			if (missing(type))
				type = "response"
			standardGeneric("train")
		}
)


train.task2 <- function(learner, task, subset, vars, type, extra.train.pars, model.class, novars.class, check.fct) {

	if(learner@learner.pack != "mlr" && !require(learner@learner.pack, character.only=TRUE)) {
		stop(paste("Learner", learner@learner.name, "could not be constructed! package", learner.pack, "missing!"))
	}
	
	check.result <- check.fct(task, learner)
	if (check.result$msg != "") {
		stop(check.result$msg)
	}
	
	wl <- learner
	tn <- task["target.name"]
	parset = wl@train.fct.pars
	# reduce data to subset and selected vars
	data.subset <- task["data", subset, select=c(vars, tn), drop=F]
	ws <- task["weights"][subset]
	
	logger.debug("mlr train:", wl@learner.name, "with pars:")
	logger.debug(parset)
	logger.debug("on", length(subset), "examples:")
	logger.debug(subset)
	
	# no vars? then use no vars model
	if (length(vars) == 0) {
		wl = new(novars.class)
	}
	
	# make pars list for train call
	pars = list(.wrapped.learner=wl, .target=tn, .data=data.subset, .weights=ws)
	if (is(task, "classif.task"))
		pars$.type = type
	
	pars <- c(pars, extra.train.pars, wl@train.fct.pars)
	# let hyperparamters overwrite pars
	for (i in seq(1, along=parset)) {
		pn <- names(parset)[i] 
		pars[pn] <- parset[i]
	}
	
	# set the seed
	if(!is.null(.mlr.local$debug.seed)) {
		set.seed(.mlr.local$debug.seed)
		warning("DEBUG SEED USED! REALLY SURE YOU WANT THIS?")
	}
	
	st = system.time({
		or <- capture.output(
			learner.model <- try(do.call(train.learner, pars), silent=TRUE)
		)
	})
	logger.debug(or)
	time.train = st[3]
	
	# if error happened we use a failure model
	if(is(learner.model, "try-error")) {
		msg <- as.character(learner.model)
		warning("Could not train the learner: ", msg)	
		learner.model <- new("learner.failure", msg=msg)
		time.train = as.numeric(NA)
	} 

	pars = list(model.class, wrapped.learner = wl, learner.model = learner.model, 
			data.desc=task@data.desc, task.desc=task@task.desc, subset=subset, parset=parset, vars=vars,
			time = time.train
	)
	do.call("new", pars)
}
	

#' @export
setMethod(
		f = "train",
		
		signature = signature(
				learner="wrapped.learner.classif", 
				task="classif.task", 
				subset="numeric", 
				vars="character",
				type="character"
		),
		
		def = function(learner, task, subset, vars, type) {
			extra.train.pars = list(.costs = task["costs"])
			train.task2(learner, task, subset, vars, type, 
					extra.train.pars, "wrapped.model.classif", "novars.classif",
					check.task.learner.classif
			)
		}
)

#' @export
setMethod(
		f = "train",
		
		signature = signature(
				learner="wrapped.learner.regr", 
				task="regr.task", 
				subset="numeric", 
				vars="character",
				type="character"				
		),
		
		def = function(learner, task, subset, vars, type) {
			extra.train.pars = list()
			train.task2(learner, task, subset, vars, type, 
					extra.train.pars, "wrapped.model.regr", "novars.regr",
					check.task.learner
			)
		}
)

