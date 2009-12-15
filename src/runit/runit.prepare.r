ints <- as.integer(c(1,2,3))
chars <- c("bli", "bla", "blub")

test.dataset <- data.frame(ints,chars)


test.prepare <- function(){ 
		data = test.dataset
		desc1 <- make.data.desc(data = test.dataset, target = "ints")
		desc2 <- make.data.desc(data = test.dataset, target = "chars")

		ints2nums <- prep.data(data = test.dataset, target = "ints", data.desc = desc1, 
				ints.as.nums = TRUE, ints.as.factors=FALSE, chars.as.factors = TRUE)
		checkTrue(is.numeric(ints2nums[,1]))
		
#		ints2factors <- prep.data(data = test.dataset, target.col = "ints", data.desc = desc1, 
#				ints.as.nums = FALSE, ints.as.factors=TRUE, chars.as.factors = TRUE)
#		print(str(ints2factors[,1]))
#		checkTrue(is.factor(ints2factors[,1]))
		
		chars2factors <- prep.data(data = test.dataset, target = "chars", data.desc = desc2, 
				ints.as.nums = FALSE, ints.as.factors=TRUE, chars.as.factors = TRUE)
		checkTrue(is.factor(chars2factors[,1]))

}
