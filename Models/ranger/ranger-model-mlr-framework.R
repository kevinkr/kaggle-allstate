# Allstate Kaggle competition
# Start: 10-13-16
library(dplyr)
library(data.table)
#load packages
options(scipen=999) # remove scientific notation

#Load data
train <- fread("Data/Raw/train.csv", stringsAsFactors=FALSE, header = TRUE)
test <- fread("Data/Raw/test.csv", stringsAsFactors=FALSE, header = TRUE)

# Drop cont columns 1, 6, 10, 11
train <- subset(train, select =-c(cont1,cont6,cont11,cont10))
test <- subset(test, select =-c(cont1,cont6,cont11,cont10))
# Harmonize factors
#set test loss to NA
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
#train$loss <- log(train$loss + 1)
rm(fullSet)

cat.var <- names(train)[which(sapply(train, is.factor))]
test.cat.var <- names(test)[which(sapply(test, is.factor))]

# manually adjust factors after reviewing boxplot
levels(train$cat98)[levels(train$cat98)=="D"] <- "A"
levels(train$cat109)[levels(train$cat109)=="BD"] <- "T"
levels(train$cat110)[levels(train$cat110)=="DJ"] <- "AR"
levels(train$cat111)[levels(train$cat111)=="O"] <- "M"
levels(train$cat112)[levels(train$cat112)=="AY"] <- "AA"
levels(train$cat112)[levels(train$cat112)=="X"] <- "M"
levels(train$cat112)[levels(train$cat112)=="C"] <- "G"
levels(train$cat113)[levels(train$cat113)=="AO"] <- "J"
levels(train$cat115)[levels(train$cat115)=="N"] <- "K"
levels(train$cat116)[levels(train$cat116)=="LO"] <- "MD"
levels(train$cat116)[levels(train$cat116)=="EL"] <- "GI"
levels(train$cat116)[levels(train$cat116)=="BP"] <- "FB"
levels(train$cat116)[levels(train$cat116)=="JW"] <- "AC"
levels(train$cat116)[levels(train$cat116)=="HN"] <- "L"


levels(test$cat98)[levels(test$cat98)=="D"] <- "A"
levels(test$cat109)[levels(test$cat109)=="BD"] <- "T"
levels(test$cat110)[levels(test$cat110)=="DJ"] <- "AR"
levels(test$cat111)[levels(test$cat111)=="O"] <- "M"
levels(test$cat112)[levels(test$cat112)=="AY"] <- "AA"
levels(test$cat112)[levels(test$cat112)=="X"] <- "M"
levels(test$cat112)[levels(test$cat112)=="C"] <- "G"
levels(test$cat113)[levels(test$cat113)=="AO"] <- "J"
levels(test$cat115)[levels(test$cat115)=="N"] <- "K"
levels(test$cat116)[levels(test$cat116)=="LO"] <- "MD"
levels(test$cat116)[levels(test$cat116)=="EL"] <- "GI"
levels(test$cat116)[levels(test$cat116)=="BP"] <- "FB"
levels(test$cat116)[levels(test$cat116)=="JW"] <- "AC"
levels(test$cat116)[levels(test$cat116)=="HN"] <- "L"

# Harmonize factors
#set test loss to NA
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
#train$loss <- log(train$loss + 1)
rm(fullSet)

######
# category reduction fucntion
######
# inputs category name, cutoff value
reduce_cats <- function(cat.name, cutoff.val) {
  prop.table <- sort(prop.table(table(train[[cat.name]])), decreasing = T)
  #return(proptable)
  weak.prop.table <- prop.table < cutoff.val
  #return(weak.prop.table)
  # grab the names
  weak.prop.names <- names(prop.table[prop.table < cutoff.val])
  return(weak.prop.names)
}

############full loop attempt
for (n in cat.var) {
  #print(n)
  # call function to return category names for reduction, number is cutoff val
  #weak.prop.names <- reduce_cats(cat.name, 0.01)
  weak.prop.names <- reduce_cats(n, 0.01)
  # filter data set by categories that are in the weak prop names vector using %in% search'
  # first convert to character
  train[[n]] <- as.character(train[[n]])
  train[train[[n]] %in% weak.prop.names, n] <- "OTHER"
  train[[n]] <- as.factor(train[[n]])
}


####
# test version
#####
reduce_cats <- function(cat.name, cutoff.val) {
  prop.table <- sort(prop.table(table(test[[cat.name]])), decreasing = T)
  #return(proptable)
  weak.prop.table <- prop.table < cutoff.val
  #return(weak.prop.table)
  # grab the names
  weak.prop.names <- names(prop.table[prop.table < cutoff.val])
  return(weak.prop.names)
}

############full loop attempt
for (n in test.cat.var) {
  #print(n)
  # call function to return category names for reduction, number is cutoff val
  #weak.prop.names <- reduce_cats(cat.name, 0.01)
  weak.prop.names <- reduce_cats(n, 0.01)
  # filter data set by categories that are in the weak prop names vector using %in% search'
  # first convert to character
  test[[n]] <- as.character(test[[n]])
  test[test[[n]] %in% weak.prop.names, n] <- "OTHER"
  test[[n]] <- as.factor(test[[n]])
}

# Harmonize factors
#set test loss to NA
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
train$loss = log(train$loss + 200)
rm(fullSet)

##########################################
# Create split train set . . . RF, not splitting
set.seed(212312)

##########mlr
library(mlr)
library(mlbench)
regr.task = makeRegrTask(id = "trainreg", data = train, target = "loss", weights = NULL, blocking = NULL, fixup.data = "warn", check.data = FALSE)

learner <- makeLearner("regr.ranger")

## This is how you could do hyperparameter tuning with random search
# 1) Define the set of parameters you want to tune (here we use only 'obj_par')
ps <- makeParamSet(makeIntegerParam("mtry", 3, 11),
                   makeIntegerLearnerParam(id = "num.trees", lower = 1L, default = 500L),
                   makeIntegerLearnerParam(id = "min.node.size", lower = 1L, default = 5L),
                   makeLogicalLearnerParam(id = "respect.unordered.factors", default = TRUE),
                   makeDiscreteLearnerParam(id = "importance", values = c("none", "impurity", "permutation"), default = "impurity", tunable = FALSE)
                   )

# Choose resampling strategy and define grid
rdesc <- makeResampleDesc("CV", iters = 5)

# Extract the variable importance in a regression tree
r = resample("regr.ranger", regr.task, rdesc,
             extract = function(x) x$learner.model$variable.importance)
$r$extract



# Tune
res = tuneParams(learner, regr.task, rdesc, par.set = ps,
                 control = makeTuneControlGrid())

# Train on entire dataset (using best hyperparameters)
lrn = setHyperPars(makeLearner("regr.ranger"), par.vals = res$x)
mod = train(lrn, regr.task)


# caluclate performance 
n = getTaskSize(regr.task)
# do I need to do the next two steps if using CV
#mod = train(lrn, task = regr.task, subset = seq(1, n, 2))
pred = predict(mod, task = regr.task, subset = seq(2, n, 2))
pred
performance(pred, measures = list(mse, medse, mae))
summary(pred)

## Train the learner
#mod = train("regr.ranger", regr.task, subset = train)
#mod



# predict on new data
predict = predict(mod, newdata = test)
predict

loss <- as.data.frame(predict)
#loss <- exp(loss)
#loss <- exp(as.data.frame(predict)-1)
solution <- data.frame(id = test$id, "loss" = loss)
colnames(solution) <- c("id","loss")

# Write the solution to file
write.csv(solution, file = 'Submissions/mlr-ranger-v7-112116.csv', row.names = F)

