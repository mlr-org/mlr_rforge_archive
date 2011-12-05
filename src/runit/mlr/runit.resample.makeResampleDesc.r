test.resample.description.instance = function(){
  desc1 = makeResampleDesc("CV", predict="test", iters=2)
  checkEquals(desc1@iters, 2)
  checkEquals(desc1@predict, "test")
  checkError(makeResampleDesc("Foo", predict="test", iters=2), "Argument method must be any of")
  checkError(makeResampleDesc("CV", predict="Foo", iters=2), "Argument predict must be any of")
}