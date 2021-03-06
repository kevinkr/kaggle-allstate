# Allstate Kaggle competition
# Start: 10-13-16

#load packages
source("Code/packages.R")

## load the library

par(mfrow=c(1,1))
# follow load data, cat reduction pt1, pt2

################
# test harness design
####################

#refactor levels
test$loss <- NA
test$isTest <- rep(1,nrow(test))
train$isTest <- rep(0,nrow(train))
#bind train and test
fullSet <- rbind(test,train)
# set factor levels all full set
fullSet <- fullSet %>% mutate_each(funs(factor), starts_with("cat"))
# split back into test and train
test <- fullSet[fullSet$isTest==1,]
train <- fullSet[fullSet$isTest==0,]
# drop loss from test set
test <- subset(test, select = -c(loss))
test <- subset(test, select = -c(isTest))
train <- subset(train, select = -c(isTest))
train$loss <- log(train$loss + 1)

##########################################
# Create split train set . . . RF, not splitting
set.seed(212312)


## Fit decision model to training set
trainSet.rf.model <- randomForest(loss ~ ., 
                                  data=train, 
                                  importance=TRUE, 
                                  ntree=201,
                                  nodesize = 189,
                                  mtry = 43,
                                  proximity = FALSE
                                  )
print(trainSet.rf.model)
# predictions (now to compare??)
testSet.pred <- predict(trainSet.rf.model, testSet)
RMSE.testSet <- sqrt(mean((testSet.pred-testSet$loss)^2))
MAE.rtree <- mean(abs(testSet.pred-testSet$loss))

#library(rfUtilities)
# Cross validations
#rf.cv <- rf.crossValidation(trainSet.rf.model, testSet[,1:130], p=0.10, n=10, ntree=201)
#rf.cv <- rfcv(testSet[,1:130], testSet$loss, cv.fold=10)
#with(rf.cv, plot(n.var, error.cv))


# Variable Importance Table
var.imp <- data.frame(importance(trainSet.rf.model, type=1))
var.imp$Variables <- row.names(var.imp)
# make row names as columns
var.imp[order(var.imp$Variables, decreasing = T),]
var.imp[order(var.imp, decreasing = T),]


# Variable Importance Table
var.imp <- data.frame(importance(trainSet.rf.model, type=2))
var.imp$Variables <- row.names(var.imp)
# make row names as columns
var.imp[order(var.imp$Variables, decreasing = T),]
var.imp[order(var.imp, decreasing = T),]

varImpPlot(trainSet.rf.model)

plot(trainSet.rf.model)

# Look at tree
tree <- getTree(trainSet.rf.model, k = 1, labelVar = TRUE)
tree

#sum((tree[1,6]-trainSet$loss)^2) - sum((trainSet$loss - predict(trainSet.rf.model, newdata = trainSet, 'response'))^2)
mean(trainSet.rf.model == exp(testSet$loss)


test$loss <- predict(trainSet.rf.model, test)
solution <- data.frame(id = test$id, loss = exp(test$loss) - 1)

# Write the solution to file
write.csv(solution, file = 'Submissions/rf-v5-110516.csv', row.names = F)
