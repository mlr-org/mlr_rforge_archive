tune.grid <- function(learner, task, resampling, measures, par.set, control, opt.path, log.fun) {
  if (!all(sapply(par.set@pars, function(x) x@type %in% c("discrete", "logical"))))
    stop("Grid search can only be applied to discrete and logical parameters!")
  # todo: should we really do this? or allow both possibilities? what about wrapper?
  # convert to instance so all pars are evaluated on the same splits
  if (is(resampling, "resample.desc")) 
    resampling = make.res.instance(resampling, task=task)
  # drop names from par.set
  vals = values(par.set, only.names=TRUE) 
  
  grid = expand.grid(vals, KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE) 
  vals = lapply(seq(length=nrow(grid)), function(i) as.list(grid[i,,drop=FALSE]))
  vals = lapply(vals, function(val) par.valnames.to.vals(val, par.set))
  eval.states(learner, task, resampling, measures, par.set, control, opt.path, vals)
  e = getBestElement(op.path, measureAggrNames(measures[[1]])[1])
  new("opt.result", learner, control, e$x, e$y, opt.path)
}




