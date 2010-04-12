test.aschar <- function() {

	ct <- make.classif.task(data=binaryclass.df, target=binaryclass.target)
	to.string(ct)
	
	rt <- make.regr.task(data=regr.df, target=regr.target)
	to.string(rt)
	
	wl = make.learner("classif.lda")
	to.string(wl)
}
