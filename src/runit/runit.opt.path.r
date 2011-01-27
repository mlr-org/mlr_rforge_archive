test.opt.path <- function() {
  op = new("opt.path", x.names=c("x1", "x2"), y.names=c("y1", "y2"), minimize=c(TRUE, FALSE))
  add.path.el(op, list(x1=1, x2="a"), c(y1=1, y2=4))
  add.path.el(op, list(x1=2, x2="a"), c(y1=3, y2=2))
  checkEquals(op@env$dob, 1:2)
  
  x = as.list(op)
  checkTrue(is.list(x))
  checkEquals(length(x), 2)
  checkTrue(is.list(x[[1]]))
  checkTrue(is.list(x[[2]]))
  checkEquals(length(x[[1]]$x), 2)
  checkEquals(length(x[[1]]$y), 2)
  checkEquals(length(x[[2]]$x), 2)
  checkEquals(length(x[[2]]$y), 2)

  x = as.data.frame(op)
  checkTrue(is.data.frame(x))
  checkEquals(nrow(x), 2)
  checkEquals(ncol(x), 6)
  
  op2 = subset(op, dob=1)
  checkEquals(length(op@env$path), 2)
  checkEquals(length(op2@env$path), 1)
  checkEquals(op2@env$path[[1]], op@env$path[[1]])

  op2 = subset(op, dob=2)
  checkEquals(length(op@env$path), 2)
  checkEquals(length(op2@env$path), 1)
  checkEquals(op2@env$path[[1]], op@env$path[[2]])
  
  checkEquals(getBestElement(op, y.name="y1", dobs=1:2), op@env$path[[1]])
  checkEquals(getBestElement(op, y.name="y2", dobs=1:2), op@env$path[[1]])
  checkEquals(getBestElement(op, y.name="y1", dobs=1), op@env$path[[1]])
  checkEquals(getBestElement(op, y.name="y2", dobs=1), op@env$path[[1]])
  checkEquals(getBestElement(op, y.name="y1", dobs=2), op@env$path[[2]])
  checkEquals(getBestElement(op, y.name="y2", dobs=2), op@env$path[[2]])
}  