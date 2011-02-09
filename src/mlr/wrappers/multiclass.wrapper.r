#' @include base.wrapper.r
roxygen()


#' Wrapper class for learners to handle multi-class problems. 
#' 
#' @exportClass multiclass.wrapper
#' @title Wrapper class for learners to handle multi-class problems.
setClass(
        "multiclass.wrapper",   
        contains = c("base.wrapper")
)

#' @rdname multiclass.wrapper-class

setMethod(
        f = "[",
        signature = signature("multiclass.wrapper"),
        def = function(x,i,j,...,drop) {
            if (i == "multiclass")
                return(TRUE)
            if (i == "prob")
                return(FALSE)
            if (i == "decision")
                return(FALSE)
            if (i == "codematrix")
                return(x@codematrix)
            callNextMethod()
        }
)

#' Fuses a base learner with a multi-class method. Creates a learner object, which can be
#' used like any other learner object. This way learners which can only handle binary classification 
#' will be able to handle multi-class problems too.
#'
#' @param learner [\code{\linkS4class{learner}} or string]\cr 
#'   Learning algorithm. See \code{\link{learners}}.  
#' @param method [string | function] \cr
#'   "onevsone" or "onevsrest". Default is "onevsrest".
#'   You can also pass a function, with signature \code{function(task)}
#'   returns a ECOC codematrix with entries +1,-1,0. 
#'   Columns define new binary problems, rows correspond to classes 
#'   (rows must be named). 0 means class is not included in binary problem.   
#' 
#' @return \code{\linkS4class{learner}}.
#' 
#' @title Fuse learner with multiclass method.
#' @export

make.multiclass.wrapper = function(learner, mcw.method="onevsrest") {
  if (is.character(learner))
    learner = make.learner(learner)
  ps = makeParameterSet(
    makeDiscreteLearnerParameter(id="mcw.method", vals=c("onevsone", "onevsrest"), default="onevsrest"),
    makeFunctionLearnerParameter(id="mcw.custom")
  )
  w = new("multiclass.wrapper", learner=learner, par.set=ps)
  if (is.function(mcw.method)) {
    if (any(names(formals(mcw.method)) != c("task")))
      stop("Arguments in multiclass codematrix function have to be: task")   
    set.hyper.pars(w, mcw.custom=mcw.method)
  } else {
    set.hyper.pars(w, mcw.method=mcw.method)
  }
}


#' @rdname train.learner

setMethod(
  f = "train.learner",
  signature = signature(
    .learner="multiclass.wrapper", 
    .task="ClassifTask", .subset="integer" 
  ),
  
  def = function(.learner, .task, .subset,  ...) {
    pvs = .learner["par.vals", head=TRUE]
    
    .task = subset(.task, .subset)
    tn = .task["target"]
    levs = .task["class.levels"]
    d = .task["data"]
    y = .task["targets"]
        
    if (is.null(pvs$mcw.custom)) { 
      meth = switch(pvs$mcw.method,
        onevsrest = cm.onevsrest,
        onevsone = cm.onevsone
      )
    } else{
      meth= pvs$mcw.custom
    }
    # build codematrix
    cm = meth(.task)
    if (!setequal(rownames(cm), levs))
      stop("Rownames of codematrix must be class levels!")
    if (!all(cm == 1 | cm == -1 | cm == 0))
      stop("Codematrix must only contain: -1,0,+1!")
    x = multi.to.binary(y, cm)
    
    # now fit models
    k = length(x$row.inds) 
    models = list()
    for (i in 1:k) {
      data2 = d[x$row.inds[[i]], ]
      data2[, tn] = x$targets[[i]] 
      ct = change.data(.task, data2)
      models[[i]] = train(.learner@learner, ct)
    }
    # store cm as last el.
    models[[i+1]] = cm 
    return(models)
  }
)

#' @rdname pred.learner

setMethod(
  f = "pred.learner",
  signature = signature(
    .learner = "multiclass.wrapper", 
    .model = "wrapped.model", 
    .newdata = "data.frame", 
    .type = "character" 
  ),
  
  def = function(.learner, .model, .newdata, .type, ...) {
    models = .model["learner.model"]
    cm = models[[length(models)]]
    k = length(models)-1
    p = matrix(0, nrow(.newdata), ncol=k)
    # we use hamming decoding here
    for (i in 1:k) {
      m = models[[i]]
      p[,i] = as.integer(as.character(predict(m, newdata=.newdata, ...)["response"]))
    }
    rns = rownames(cm)
    y = apply(p, 1, function(v) {
        # todo: break ties
        #j = which.min(apply(cm, 1, function(z) sum(abs(z - v))))
        d <- apply(cm, 1, function(z) sum(abs(z - v)))
        j <- which(d == min(d))
        j <- sample(rep(j,2), size = 1)
        rns[j]
      })
    as.factor(y)
  }
)   




# Function for Multi to Binary Problem Conversion
multi.to.binary = function(target, codematrix){
    
    if (any(is.na(codematrix)) ) {
        stop("Code matrix contains missing values!")
    }
    levs <- levels(target)
    no.class <- length(levs)
    rns = rownames(codematrix)
    if (is.null(rns) || !setequal(rns, levs)) {
        stop("Rownames of code matrix have to be the class levels!")
    }
    
    binary.targets = as.data.frame(codematrix[target,])
    row.inds = lapply(binary.targets, function(v) which(v != 0))
    names(row.inds) = NULL
    targets = Map(function(y, i) factor(y[i]),
            binary.targets, row.inds)
    
    return(list(row.inds=row.inds, targets=targets))
}

cm.onevsrest = function(task) {
    n = task["class.nr"]
    cm = matrix(-1, n, n)
    diag(cm) = 1
    rownames(cm) = task["class.levels"]
    return(cm)
} 

cm.onevsone = function(task) {
    n = task["class.nr"]
    cm = matrix(0, n, choose(n, 2))
    combs = combn(n, 2)
    for (i in 1:ncol(combs)) {
        j = combs[,i]
        cm[j, i] = c(1, -1) 
    }
    rownames(cm) = task["class.levels"]
    return(cm)
} 

