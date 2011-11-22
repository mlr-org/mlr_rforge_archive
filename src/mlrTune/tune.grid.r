tune.grid <- function(learner, task, resampling, measures, par.set, control, opt.path, log.fun) {
  # drop names from par.set
  vals = values(par.set, only.names=TRUE) 
  grid = expand.grid(vals, KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE)
  vals = lapply(seq(length=nrow(grid)), function(i) as.list(grid[i,,drop=FALSE]))
  vals = lapply(vals, function(val) par.valnames.to.vals(val, par.set))
  evalOptimizationStates(learner, task, resampling, measures, par.set, NULL, control, opt.path, log.fun, vals, dobs=1L, eols=1L)

  i = getOptPathBestIndex(opt.path, measureAggrName(measures[[1]]), ties="random")
  e = getOptPathEl(opt.path, i)
  new("OptResult", learner, control, e$x, e$y, opt.path)
}




