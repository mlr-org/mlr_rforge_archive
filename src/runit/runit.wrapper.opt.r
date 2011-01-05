



test.opt.wrapper <- function() {
	
	outer = make.res.instance(make.res.desc("holdout"), task=multiclass.task)
  inner = make.res.desc("cv", iters=2)
	
	ranges.svm = list(kernel="rbfdot", C=c(1, 1000))
	control.svm = grid.control(ranges=ranges.svm)
	svm.tuner = make.tune.wrapper("classif.ksvm", resampling=inner, control=control.svm)
	
	m = train(svm.tuner, task=multiclass.task)
	
	or = m["opt.result"]
	checkEquals(or["par"], list(kernel="rbfdot", C=1))
	
	checkTrue(!is.null(or["perf"]))
	checkTrue(is.null(or["model"]))
	checkTrue(!is.null(or["path"]))
}