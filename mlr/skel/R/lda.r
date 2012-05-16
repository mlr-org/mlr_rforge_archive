makeLearner.classif.lda = function() {
  makeRLearner(
    package = "MASS",
    par.set = makeParamSet(
  			makeDiscreteLearnerParam(id="method", default="moment", values=c("moment", "mle", "mve", "t")),
  			makeNumericLearnerParam(id="nu", lower=2, requires=expression(method=="t")),
        makeNumericLearnerParam(id="tol", default=1.0e-4, lower=0)
    ), 
    twoclass=TRUE, 
    multiclass = TRUE, 
    numerics = TRUE, 
    factors = TRUE, 
    prob = TRUE
  )
}
		
trainLearner.classif.lda = function(.learner, .task, .subset,  ...) {
	f = getFormula(.task)
	lda(f, data=getData(.task, .subset), ...)
}
	
predictLearner.classif.lda = function(.learner, .model, .newdata, ...) {
	p = predict(.model@learner.model, newdata=.newdata, ...)
	if(.learner@predict.type == "response")
		return(p$class)
	else
		return(p$posterior)
}

