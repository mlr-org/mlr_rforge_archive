#' Complete benchmark experiment to compare different learning algorithms 
#' across one or more tasks w.r.t. a given resampling strategy.  
#' Experiments are paired, meaning always the same training / test sets are used for the different learners.  
 
#' @param learners [character vector | \code{\link{wrapped.learner} | list of the previous two] \cr
#' 		  Defines the learning algorithms which should be compared.
#' @param tasks [\code{\link{learn.task} | list of the previous] \cr
#'        Defines the tasks.
#' @param resampling [resampling desc | resampling instance | list of the previous two] \cr
#'        Defines the resampling strategies for the tasks.
#' @param measures [see \code{\link{measures}]
#'        Performance measures. 
#' @param type [character] \cr
#'        Classification: vector of "response" | "prob" | "decision", specifying the types to predict.
#'        Default is "response".
#' 		  Ignored for regression.	 
#' @return \code{\linkS4class{bench.result}}.
#' 
#' @usage bench.exp(learners, tasks, resampling, measures, type="response")
#' 
#' @note You can also get automatic, internal tuning by using \code{\link{make.tune.wrapper}} with your learner. 
#' 
#' @seealso \code{\link{bench.add}}, \code{\link{make.tune.wrapper}} 
#' @export 
#' @aliases bench.exp 
#' @title Benchmark experiment for multiple learners and tasks. 



bench.exp <- function(learners, tasks, resampling, measures, type="response", 
		conf.mats=TRUE, predictions=FALSE, models=FALSE, 
		tune.pars=TRUE, tune.paths=FALSE, varsel.pars=TRUE, varsel.paths=FALSE)  {
	
	if (!is.list(learners) && length(learners) == 1) {
		learners = list(learners)
	}
	if (!is.list(tasks)) {
		tasks = list(tasks)
	}
	learners = as.list(learners)
	n = length(learners)
	
	if (missing(measures))
		measures = default.measures(tasks[[1]])
	measures = make.measures(measures)
	
	
	
	#bs = array(-1, nrow=resampling["iters"], ncol=n)
	## add dim for every loss ?? hmm, those are not always the same size...
	if (length(tasks) > 1 && is(resampling, "resample.instance")) {
		stop("Cannot pass a resample.instance with more than 1 task. Use a resample.desc!")
	}
	dims = c(resampling["iters"]+1, n, length(measures))
	bs = list()
	
	learner.names = character()
	task.names = sapply(tasks, function(x) x["name"])	
	resamplings = list()
	tds = dds = rfs =  mods = cms = list()
	t.pars = t.paths = v.aprs = v.paths = list()
	
	for (j in 1:length(tasks)) {
		bs[[j]] = array(0, dim = dims)		
		task = tasks[[j]]
		if (is(resampling, "resample.desc")) {
			resamplings[[j]] = new(resampling@instance.class, resampling, task["size"])
		} else {
			resamplings[[j]] = resampling
		}		
		tuned[[j]] = as.list(rep(NA, n))
		cms[[j]] = as.list(rep(NA, n))
		if (predictions)
			rfs[[j]] = as.list(rep(NA, n))
		tds[[j]] = task@task.desc
		dds[[j]] = task@data.desc
		for (i in 1:length(learners)) {
			wl = learners[[i]]
			if (is.character(wl))
				wl = make.learner(wl)
			learner.names[i] = wl["short.name"]
			bm = benchmark(learner=wl, task=task, resampling=resamplings[[j]], measures=measures, type=type)
			rr = bm$result
			# remove tune perf
			rr = rr[, names(measures)]
			bs[[j]][,i,] = as.matrix(rr)
			if (is(wl, "tune.wrapper"))
				tuned[[j]][[i]] = bm$result
			if (predictions)
				rfs[[j]][[i]] = bm$resample.fit
			if (models)
				mods[[j]][[i]] = bm$resample.fit
			if (conf.mats) {
				if (is(task, "classif.task"))
					cms[[j]][[i]] = bm$conf
				else
					cms[[j]][[i]] = NA
			}
		}
		dimnames(bs[[j]]) = list(c(1:resampling["iters"], "combine"), learner.names, names(measures))
		names(tuned[[j]]) = learner.names
		if (predictions)
			names(rfs[[j]]) = learner.names
		if (models)
			names(mods[[j]]) = learner.names
		if (conf.mats)
			names(cms[[j]]) = learner.names
		if (tune.pars)
			names(t.pars[[j]]) = learner.names
		if (tune.paths)
			names(t.paths[[j]]) = learner.names
		if (varsel.pars)
			names(v.pars[[j]]) = learner.names
		if (varsel.paths)
			names(v.paths[[j]]) = learner.names
	}
	names(bs) = task.names
	names(tuned) = task.names
	names(cms) = task.names
	return(new("bench.result", task.descs=tds, data.descs=dds, resamplings=resamplings, perf = bs, 
					predictions=rfs, conf.mats=cms, models=mods,
					tune.pars = t.pars, tune.paths = t.paths,
					varsel.pars = v.pars, varsel.paths = v.paths
	))
}