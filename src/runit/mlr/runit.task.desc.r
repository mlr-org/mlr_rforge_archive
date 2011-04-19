
test.task.desc <- function() {
	ct = makeClassifTask(target="Class", binaryclass.df, id="mytask", positive="M", exclude="V1")
	checkEquals(ct@desc@id, "mytask")	
	checkEquals(ct@desc@positive, "M")	
	checkEquals(ct@desc@negative, "R")

	ct = makeClassifTask(target="Species", multiclass.df, id="mytask2")
	checkEquals(ct@desc@id, "mytask2")	
	checkTrue(is.na(ct@desc@positive))
	checkTrue(is.na(ct@desc@negative))
	
	rt = makeRegrTask(target="medv", regr.df, id="mytask3") 
	checkEquals(rt@desc@id, "mytask3")	
	checkTrue(is.na(rt@desc@positive))
	checkTrue(is.na(rt@desc@negative))
  
  checkEquals(multiclass.task["size"], 150) 
  checkEquals(multiclass.task["dim"], 4)  
  checkEquals(multiclass.task@desc@n.feat["numerics"], 4, checkNames=FALSE)  
  checkEquals(multiclass.task@desc@n.feat["integers"], 0, checkNames=FALSE)  
  checkEquals(multiclass.task@desc@n.feat["factors"], 0, checkNames=FALSE)  
  checkEquals(multiclass.task@desc@n.feat["logicals"], 0, checkNames=FALSE)  
  checkEquals(multiclass.task@desc@n.feat["characters"], 0, checkNames=FALSE)  
  checkEquals(multiclass.task["has.missing"], F)  
  checkEquals(multiclass.task@desc@type, "classif") 
  checkEquals(getClassLevels(multiclass.task), c("setosa", "versicolor", "virginica"))  
  checkEquals(length(getClassLevels(multiclass.task)), 3) 
  checkEquals(multiclass.task["class.dist"], c(setosa=50, versicolor=50, virginica=50)) 
  
  # check missing values
  df = multiclass.df
  df[1,1] = as.numeric(NA)
  ct = makeClassifTask(target="Species", data=df)
  checkEquals(ct["has.missing"], T) 
  
  ct = makeClassifTask(target=binaryclass.target, data=binaryclass.df, exclude="V1")
  checkEquals(ct["size"], 208)  
  checkEquals(ct["dim"], 59)  
  checkEquals(ct@desc@n.feat["numerics"], 59, checkNames=FALSE)  
  checkEquals(ct@desc@n.feat["integers"], 0, checkNames=FALSE)  
  checkEquals(ct@desc@n.feat["factors"], 0, checkNames=FALSE)  
  checkEquals(ct@desc@n.feat["logicals"], 0, checkNames=FALSE)  
  checkEquals(ct@desc@n.feat["characters"], 0, checkNames=FALSE)  
  checkEquals(ct@desc@has.missing, F) 
  checkEquals(ct@desc@type, "classif")  
  checkEquals(getClassLevels(ct), c("M", "R"))  
  checkEquals(length(getClassLevels(ct)), 2)  
  checkEquals(ct["class.dist"], c(M=111, R=97)) 
  
  checkEquals(regr.task["size"], 506) 
  checkEquals(regr.task["dim"], 13) 
  checkEquals(regr.task@desc@n.feat["numerics"], 12, checkNames=FALSE)  
  checkEquals(regr.task@desc@n.feat["integers"], 0, checkNames=FALSE)  
  checkEquals(regr.task@desc@n.feat["factors"], 1, checkNames=FALSE)  
  checkEquals(regr.task@desc@n.feat["logicals"], 0, checkNames=FALSE)  
  checkEquals(regr.task@desc@n.feat["characters"], 0, checkNames=FALSE)  
  checkEquals(regr.task["has.missing"], F)  
  checkEquals(regr.task@desc@type, "regr")  
  checkException(getClassLevels(regr.task))
  checkTrue(is.na(regr.task["class.dist"])) 
}