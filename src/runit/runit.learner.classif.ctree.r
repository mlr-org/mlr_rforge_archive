test.ctree <- function() {
	
	parset.list <- list(
			list(),
			list(minsplit=10, mincriterion= 0.005),
			list(minsplit=50, mincriterion=0.05),
			list(minsplit=50, mincriterion=0.999),
			list(minsplit=1, mincriterion=0.0005)
	)
	
	old.predicts.list = list()
	old.probs.list = list()
	
	for (i in 1:length(parset.list)) {
		parset <- parset.list[[i]]
		ctrl = do.call(ctree_control, parset)
		set.seed(debug.seed)
		m = ctree(formula=multiclass.formula, data=multiclass.train, control=ctrl)
		p  <- predict(m, newdata=multiclass.test, type="class")
		p2 <- Reduce(rbind, treeresponse(m, newdata=multiclass.test, type="prob"))
		rownames(p2) = NULL
		colnames(p2) = levels(multiclass.df[,multiclass.target])
		old.predicts.list[[i]] <- p
		old.probs.list[[i]] <- p2
	}
	
#	simple.test.parsets("classif.ctree", multiclass.df, multiclass.target, multiclass.train.inds, old.predicts.list, parset.list)
	prob.test.parsets  ("classif.ctree", multiclass.df, multiclass.target, multiclass.train.inds, old.probs.list, parset.list)
#	
#	tt <- "ctree"
#	tp <- function(model, newdata) predict(model, newdata, type="class")
#	
#	cv.test.parsets("classif.ctree", multiclass.df, multiclass.target, tune.train=tt, tune.predict=tp, parset.list=parset.list)
	
}




