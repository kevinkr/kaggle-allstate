# Allstate Kaggle competition
# Start: 10-13-16

#load packages
source("Code/packages.R")
source("Code/1-load data.R")
source("Code/2-plot functions.R")

#Examine data
str(train, list.len = 999) 
str(test, list.len = 999) 

# Create lists of column names
cat.var <- names(train)[which(sapply(train, is.factor))]
test.cat.var <- names(test)[which(sapply(test, is.factor))]
num.var <- names(train)[which(sapply(train, is.numeric))]
num.var <- setdiff(num.var, c("id", "loss"))

train.cat <- train[,.SD,.SDcols = cat.var]
train.cat <- train[,1:116]
test.cat <- test[,1:116]
train.num <- train[, .SD, .SDcols = num.var]


######################################
# Reduction in categories by similarity
#######################################
# calculate the mean of the loss for the category
cat116.means <- aggregate(loss~cat116, data=train, FUN = mean)
# sort it
cat116.sorted <- cat116.means[order(cat116.means$loss),]
# append the diff to the new df
cat116.sorted$diff <- c(NA,cat116.sorted[2:nrow(cat116.sorted), "loss"] - cat116.sorted[1:(nrow(cat116.sorted)-1), "loss"])

# see MD and LO
# 25     MD 3162.817   7.0214635
# 24     LO 3162.963   0.1462991

subset <- train[train$cat116 %in% c("MD", "LO"),]
subset$cat116 <- as.character(subset$cat116)
subset$cat116 <- as.factor(subset$cat116)
str(subset$cat116)
par(mfrow=c(1,1))
boxplot(log(loss)~cat116, data=subset)

# train version

sorted_mean <- function(cat.name) {
  #print(cat.name)
  cat.means <- aggregate(train$loss, list(train[[cat.name]]), mean)
  cat.means.sorted <- cat.means[order(cat.means$x),]
  cat.means.sorted$category <- cat.name
  cat.means.sorted$diff <- c(NA,cat.means.sorted[2:nrow(cat.means.sorted), "x"] 
                             - cat.means.sorted[1:(nrow(cat.means.sorted)-1), "x"])
  return(cat.means.sorted)
}

results_df <- NULL

for (n in cat.var) {
  #print(n)
  #print(sorted_mean(n))
  #sorted.results <- sorted_mean(n)
  results_df <- rbind(results_df, sorted_mean(n))
  
}

# remove NA's
row.has.na <- apply(results_df, 1, function(x){any(is.na(x))})
sum(row.has.na)
results_df <- results_df[!row.has.na,]

# convert column to numeric
results_df$diff <- as.numeric(results_df$diff,  na.rm = TRUE)

# create index of means < 1
index_list <- which(results_df$diff<1)

# Create reference table for combining (manually)
testdf <- NULL
for (n in index_list) {
  print(results_df[n-1,])
  print(results_df[n,])
  testdf <- rbind(testdf,results_df[n-1,])
  testdf <- rbind(testdf,results_df[n,])
}

write.table(testdf, "testdf.txt", sep="\t")

# boxplot analysis
subset <- train[train$cat98 %in% c("A", "D"),]
#subset$cat116 <- as.character(subset$cat116)
#subset$cat116 <- as.factor(subset$cat116)
#str(subset$cat116)
par(mfrow=c(1,1))
boxplot(log(loss)~cat98, data=subset)

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

  # call function to return category names for reduction, number is cutoff val
  #weak.prop.names <- reduce_cats(cat.name, 0.01)
  #weak.prop.names <- reduce_cats(n, 0.01)
  # filter data set by categories that are in the weak prop names vector using %in% search'
  # first convert to character
  #train[[n]] <- as.character(train[[n]])
  #train[train[[n]] %in% weak.prop.names, n] <- "OTHER"
  #train[[n]] <- as.factor(train[[n]])













#similar plots...combine buckets
#transform(mydata, newvar=paste(gender, country))






# # MCA analysis
# # see http://www.sthda.com/english/wiki/multiple-correspondence-analysis-essentials-interpretation-and-application-to-investigate-the-associations-between-categories-of-multiple-qualitative-variables-r-software-and-data-mining
# res.mca <- MCA(train.cat, graph = FALSE)
# 
# summary(res.mca, nb.dec = 2, ncp = 2)
# 
# fviz_screeplot(res.mca)
# 
# par(mfrow=c(1,1))
# plot(res.mca)
# 
# var <- get_mca_var(res.mca)
# plot(res.mca, choix = "var")
# head(round(var$contrib,2))
# categories <- rownames(var$coord)
# library("corrplot")
# corrplot(var$contrib, is.corr = FALSE)
# # Contributions of variables on Dim.1
# fviz_contrib(res.mca, choice = "var", axes = 1)
# 
# 
# 
# 
# # contingency analysis
# library(gplots)
# dt <- as.table(as.matrix(train.cat))
# balloonplot(t(dt), main ="cats", xlab ="", ylab="",
#             label = FALSE, show.margins = FALSE)
