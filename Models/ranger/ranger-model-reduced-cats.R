# Allstate Kaggle competition
# Start: 10-13-16
library(dplyr)
library(data.table)
#load packages
options(scipen=999) # remove scientific notation

#Load data
train <- fread("Data/Raw/train.csv", stringsAsFactors=FALSE, header = TRUE)
test <- fread("Data/Raw/test.csv", stringsAsFactors=FALSE, header = TRUE)

# Harmonize factors
#set test loss to NA
test$loss <- NA
test$isTest <- rep(1,nrow(test))
train$isTest <- rep(0,nrow(train))
#bind train and test
fullSet <- rbind(test,train)
# set factor levels all full set
fullSet <- fullSet %>% mutate_each(funs(factor), starts_with("cat"))
# drop vars
fullSet <- subset(fullSet, select = -c(cont3, cont5, cont6))
fullSet <- subset(fullSet, select = -c(cat7 , cat14 , cat15 , cat16 , cat17 , cat18 , cat19 , cat20 , cat21 , cat22 , cat24 , cat28 , cat29 , cat30 , cat31 , cat32 , cat33 , cat34 , cat35 , cat39 , cat40 , cat41 , cat42 , cat43 , cat45 , cat46 , cat47 , cat48 , cat49 , cat51 , cat52 , cat54 , cat55 , cat56 , cat57 , cat58 , cat59 , cat60 , cat61 , cat62 , cat63 , cat64 , cat65 , cat66 , cat67 , cat68 , cat69 , cat70 , cat74 , cat76 , cat77 , cat78 , cat85 , cat89 , cat96 , cat102))
# set factor levels all full set
fullSet <- fullSet %>% mutate_each(funs(factor), starts_with("cat"))

# nzv (skip)
library(caret)
x <- nearZeroVar(train.cat, saveMetrics = TRUE)

x[x[,"zeroVar"] > 0, ]
x[x[,"zeroVar"] + x[, "nzv"] > 0, ]



# split back into test and train
test <- fullSet[fullSet$isTest==1,]
train <- fullSet[fullSet$isTest==0,]
# drop loss from test set
test <- subset(test, select = -c(loss))
test <- subset(test, select = -c(isTest))
train <- subset(train, select = -c(isTest))
train$loss <- log(train$loss + 1)
rm(fullSet)
##########################################
# Create split train set . . . RF, not splitting
set.seed(212312)


library(ranger)
trainSet.rf.model <-ranger(loss~.,
                            data=train, 
                            write.forest=TRUE,
                            importance = "impurity",
                            respect.unordered.factors=TRUE)




print(trainSet.rf.model)
summary(trainSet.rf.model)
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
var.imp[order(var.imp!=NA, decreasing = T),]


# Variable Importance Table
var.imp <- data.frame(importance(trainSet.rf.model, type=2))
var.imp$Variables <- row.names(var.imp)
# make row names as columns
var.imp[order(var.imp$Variables, decreasing = T),]
var.imp[order(var.imp!=NA, decreasing = T),]

varImpPlot(trainSet.rf.model)

plot(trainSet.rf.model)

# Look at tree
tree <- getTree(trainSet.rf.model, k = 1, labelVar = TRUE)
tree

losspred <- predict(trainSet.rf.model, test)
loss <- losspred$predictions
solution <- data.frame(id = test$id, loss = exp(loss) - 1)

# Write the solution to file
write.csv(solution, file = 'Submissions/ranger-v4-111016.csv', row.names = F)
