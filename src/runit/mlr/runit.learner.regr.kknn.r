
test.knn.regr <- function() {
  library(kknn)
	parset.list <- list(
			list(),
			list(k=1),
			list(k=4),
			list(k=10)
	)
	
	old.predicts.list = list()
	
	for (i in 1:length(parset.list)) {
		
		parset <- parset.list[[i]]
		pars <- list(formula=regr.formula, train=regr.train, test=regr.test)
		pars <- c(pars, parset)
		set.seed(debug.seed)
		m <- do.call(kknn, pars)
		p <- predict(m, newdata=regr.test)
		old.predicts.list[[i]] <- p
	}
	
	simple.test.parsets("regr.kknn", regr.df, regr.target, regr.train.inds, old.predicts.list, parset.list)
	
	tt <- function (formula, data, k=7) {
		return(list(formula=formula, data=data, k=k))
	}
	tp <- function(model, newdata) {
		kknn(model$formula, train=model$data, test=newdata, k=model$k)$fitted
	}
	
	cv.test.parsets("regr.kknn", regr.df, regr.target, tune.train=tt, tune.predict=tp, parset.list=parset.list)
}
