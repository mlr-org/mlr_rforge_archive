test.tune <- function() {
  cp = c(0.05, 0.9)
  minsplit = 1:3 
  b1 = makeParameterSet(makeDiscreteParameter("cp", vals=cp), makeDiscreteParameter("minsplit", vals=minsplit))
	ctrl = grid.control()
	folds = 3
	
	tr <- tune.rpart(formula=multiclass.formula, data=multiclass.df, cp=cp, minsplit=minsplit,
			tunecontrol = tune.control(sampling = "cross", cross = folds))  
	
	cv.instance <- e1071.cv.to.mlr.cv(tr)
	
	tr2 <- tune("classif.rpart", multiclass.task, cv.instance, par.set=b1, control=ctrl)
  pp = as.data.frame(tr2@path)
  
	# todo test scale with tune.e1071 and scaled grid!
	
	for(i in 1:nrow(tr$performances)) {
		cp <- tr$performances[i,"cp"]
		ms <- tr$performances[i,"minsplit"]
		j <- which(pp$cp == cp & pp$minsplit == ms )
		checkEqualsNumeric(tr$performances[i,"error"], pp[j,"mmce.test.mean"])    
		checkEqualsNumeric(tr$performances[i,"dispersion"], pp[j,"mmce.test.sd"])    
	}
	
	# check multiple measures
	ms = c("acc", "mmce", "time.fit") 
	tr2 = tune("classif.rpart", multiclass.task, cv.instance, control=ctrl)
	
	
	# check grid and scale
	control = grid.control(ranges=list(C=-1:1, sigma=-1:1), trafo=function(x)10^x)
	tune("classif.ksvm", multiclass.task, cv.instance, control=control)
	
  # check order of constraints and start in control objects
  x = optim.control(start=c(a=11,b=12,c=13), lower=c(b=22, c=23, a=21), upper=c(c=33,b=32,a=31))
  checkEquals(x["start"][["a"]],  11, checkNames=FALSE)  
  checkEquals(x["start"][["b"]],  12, checkNames=FALSE)  
  checkEquals(x["start"][["c"]],  13, checkNames=FALSE)  
  checkEquals(x["lower"]["a"], 21, checkNames=FALSE)  
  checkEquals(x["lower"]["b"], 22, checkNames=FALSE)  
  checkEquals(x["lower"]["c"], 23, checkNames=FALSE)  
  checkEquals(x["upper"]["a"], 31, checkNames=FALSE)  
  checkEquals(x["upper"]["b"], 32, checkNames=FALSE)  
  checkEquals(x["upper"]["c"], 33, checkNames=FALSE)  
  
  x = cmaes.control(start=c(a=11,b=12,c=13), lower=c(b=22, c=23, a=21), upper=c(c=33,b=32,a=31))
  checkEquals(x["start"][["a"]], 11, checkNames=FALSE)  
  checkEquals(x["start"][["b"]], 12, checkNames=FALSE)  
  checkEquals(x["start"][["c"]], 13, checkNames=FALSE)  
  checkEquals(x["lower"]["a"], 21, checkNames=FALSE)  
  checkEquals(x["lower"]["b"], 22, checkNames=FALSE)  
  checkEquals(x["lower"]["c"], 23, checkNames=FALSE)  
  checkEquals(x["upper"]["a"], 31, checkNames=FALSE)  
  checkEquals(x["upper"]["b"], 32, checkNames=FALSE)  
  checkEquals(x["upper"]["c"], 33, checkNames=FALSE)  
  
	# tune wrapper
	res = make.res.desc("cv", iters=2)
	ranges = list(minsplit=seq(3,10,2))
	wl = make.tune.wrapper("classif.rpart", resampling=res, control=grid.control(ranges=ranges))
	m = train(wl,  multiclass.task)
	# todo check opt. parameter is same as with tune
	
	
	#tune chain
	wl = make.learner("classif.rpart", minsplit=10, cp=0.01, predict.type="prob")
	
  f1 = function(data, targetvar, args) {
    set.seed(1)
    v = sample(setdiff(colnames(data), targetvar), args$n)
    list(data=data[, c(v, targetvar), drop=FALSE], control=list(vars=v))
  }
  f2 = function(data, targetvar, args, control) {
    data[, control$vars, drop=FALSE]
	}
	wl = make.preproc.wrapper(wl, train=f1, predict=f2, args=list(n=3))
  
	r = list(minsplit=c(3,30), n=c(1,60))
	ctrl = grid.control(ranges=r)
	tr = tune(wl, binaryclass.task, res, control=ctrl)
  checkTrue(!any(is.na(tr["perf"])))
  checkEquals(tr["par"]$n, 60)
  
	# nelder mead with optim
	ctrl = optim.control(start=c(C=0, sigma=0), maxit=10, trafo=function(x) 2^x)
	tr = tune("classif.ksvm", binaryclass.task, res, control=ctrl)
	
	# SA with optim
	ctrl = optim.control(start=c(C=0, sigma=0), maxit=10, method="SANN", trafo=function(x) 2^x)
	tr = tune("classif.ksvm", binaryclass.task, res, control=ctrl)
	
	
	# BFGS with optim
	ctrl = optim.control(start=c(C=1, sigma=1), maxit=5, lower=0.5, upper=2, method="L-BFGS-B")
	tr = tune("classif.ksvm", binaryclass.task, res, control=ctrl)
	
	
	# cmaes with optim
	
  	
}

test.tune.cmaes = function() {
  res = make.res.desc("cv", iters=2)
  b1 = makeParameterSet(
    makeNumericParameter("cp", lower=0.001, upper=1), 
    makeIntegerParameter("minsplit", lower=1, upper=10)
  )
  
  b1 = makeParameterSet(
    makeNumericParameter("C", trafo=function(x) 2^x), 
    makeNumericParameter("sigma", trafo=function(x) 2^x) 
  )
  b2 = makeParameterSet(
    makeNumericParameter("C", trafo=function(x) 2^x), 
    makeDiscreteParameter("kernel", vals=c("rbfdot", "polydot"))
  )
  
  ctrl1 = cmaes.control(start=c(C=0, sigma=0), maxit=5)
  tr1 = tune("classif.ksvm", multiclass.task, res, control=ctrl1)
  
  ctrl = diceoptim.control()
  
  ctrl1 = cmaes.control(start=c(C=0), maxit=5)
  checkException(tune("classif.ksvm", multiclass.task, cv.instance, par.set=b1, control=ctrl2))
  checkException(tune("classif.ksvm", multiclass.task, cv.instance, par.set=b1, control=ctrl2))
} 



test.tune.diceoptim = function() {
  res = make.res.desc("cv", iters=2)
  b1 = makeParameterSet(makeNumericParameter("cp", lower=0.001, upper=1), makeIntegerParameter("minsplit", lower=1, upper=10))
  
  ctrl = diceoptim.control()
  
  tr1 = tune("classif.rpart", multiclass.task, cv.instance, control=ctrl)
  
  b2 = makeParameterSet(makeNumericParameter("cp", lower=0.001, upper=1), makeIntegerParameter("minsplit", lower=1, upper=10))
  checkException(tune("classif.rpart", multiclass.task, cv.instance, control=ctrl))
  
} 
  

