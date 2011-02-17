

test.ResamplePrediction = function() {
  rin1 = makeResampleInstance(makeResampleDesc("bs", iters=4), task=multiclass.task)  
  rin2 = makeResampleInstance(makeResampleDesc("CV", iters=7), task=multiclass.task)  
  rin3 = makeResampleInstance(makeResampleDesc("subsample", iters=2), task=multiclass.task)  
  
	p1 = resample("classif.lda", multiclass.task, rin1)$pred       
	p2 = resample("classif.lda", multiclass.task, rin2)$pred       
	p3 = resample("classif.lda", multiclass.task, rin3)$pred       
	
	inds = Reduce(c, rin1@test.inds)
	y = targets(multiclass.task)[inds]
	checkEquals(p1@df$id, inds)
	checkEquals(p1@df$truth, y)
  inds = Reduce(c, rin2@test.inds)
  y = targets(multiclass.task)[inds]
	checkEquals(p2@df$id, inds)
	checkEquals(p2@df$truth, y)
  inds = Reduce(c, rin3@test.inds)
  y = targets(multiclass.task)[inds]
	checkEquals(p3@df$id, inds)
	checkEquals(p3@df$truth, y)
}



