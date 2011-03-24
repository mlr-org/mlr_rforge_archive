test.logicreg.regr = function() {
  library(LogicReg)
  set.seed(1)
  mydata = as.data.frame(matrix(rbinom(100*5, 1, 0.5), 100, 5))
  mydata$y = rnorm(100)
  rt = makeRegrTask(target="y", data=mydata)

  parset.list1 = list(
    list(seed=debug.seed, type=2),
    list(seed=debug.seed, type=2, ntrees=1, tree.control=logreg.tree.control(treesize=3, minmass=5))
  )
  parset.list2 = list(
    list(seed=debug.seed),
    list(seed=debug.seed, ntrees=1L, treesize=3L, minmass=5L)
  )
  
  old.predicts.list = list()
  
  for (i in 1:length(parset.list1)) {
    parset = parset.list1[[i]]
    pars = list(resp=mydata$y[1:60], bin=mydata[1:60, 1:5], select=1L)
    pars = c(pars, parset)
    set.seed(debug.seed)
    m = do.call(logreg, pars)
    m <<- m
    set.seed(debug.seed)
    p = predict(m, newbin=mydata[61:100, 1:5])
    old.predicts.list[[i]] = p
  }
  
  simple.test.parsets("regr.logicreg", mydata, "y", 1:60, old.predicts.list, parset.list2)
}