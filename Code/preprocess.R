# Allstate Kaggle competition
# Start: 10-13-16

#load packages
source("Code/packages.R")

#Load data
train <- fread("Data/Raw/train.csv", stringsAsFactors=FALSE, header = TRUE)
test <- fread("Data/Raw/test.csv", stringsAsFactors=FALSE, header = TRUE)

#printing some missing data
sum(is.na(train[,]))
sum(is.na(test[,]))

summary(train)
summary(test)

#Combine training and test datasets for feature engineering
allstate.combined <- rbind(test, train)
str(allstate.combined)

#Rename and create local data frame for simplicity
data<- tbl_df (allstate.combined)

#Examine data
str(train, list.len = 999) 
str(test, list.len = 999) 
str(data, list.len = 999) 

# Create lists of column names
cat.var <- names(train)[which(sapply(train, is.character))]
num.var <- names(train)[which(sapply(train, is.numeric))]
num.var <- setdiff(num.var, c("id", "loss"))


train.cat <- train[,.SD,.SDcols = cat.var]
train.num <- train[, .SD, .SDcols = num.var]


###################
# Plot functions
###################
plotBox <- function(data_in, i, lab) {
  data <- data.frame(x=data_in[[i]], y=lab)
  p <- ggplot(data=data, aes(x=x, y=y)) +geom_boxplot()+ xlab(colnames(data_in)[i]) + theme_light() + 
    ylab("log(loss)") + theme(axis.text.x = element_text(angle = 90, hjust =1))
  return (p)
}

doPlots <- function(data_in, fun, ii, lab, ncol=3) {
  pp <- list()
  for (i in ii) {
    p <- fun(data_in=data_in, i=i, lab=lab)
    pp <- c(pp, list(p))
  }
  do.call("grid.arrange", c(pp, ncol=ncol))
}


plotScatter <- function(data_in, i, lab){
  data <- data.frame(x=data_in[[i]], y = lab)
  p <- ggplot(data= data, aes(x = x, y=y)) + geom_point(size=1, alpha=0.3)+ geom_smooth(method = lm) +
    xlab(paste0(colnames(data_in)[i], '\n', 'R-Squared: ', round(cor(data_in[[i]], lab, use = 'complete.obs'), 2)))+
    ylab("log(loss)") + theme_light()
  return(suppressWarnings(p))
} 

plotDen <- function(data_in, i, lab){
  data <- data.frame(x=data_in[[i]], y=lab)
  p <- ggplot(data= data) + geom_density(aes(x = x), size = 1,alpha = 1.0) +
    xlab(paste0((colnames(data_in)[i]), '\n', 'Skewness: ',round(skewness(data_in[[i]], na.rm = TRUE), 2))) +
    theme_light() 
  return(p)
}


#######################
# Plot categories
#######################

doPlots(train.cat, fun = plotBox, ii =1:12, lab=log(train$loss), ncol = 3)
doPlots(train.cat, fun = plotBox, ii =13:24, lab=log(train$loss), ncol = 3)
doPlots(train.cat, fun = plotBox, ii =25:36, lab=log(train$loss), ncol = 3)
doPlots(train.cat, fun = plotBox, ii =37:48, lab=log(train$loss), ncol = 3)
doPlots(train.cat, fun = plotBox, ii =49:60, lab=log(train$loss), ncol = 3)
doPlots(train.cat, fun = plotBox, ii =61:72, lab=log(train$loss), ncol = 3)
doPlots(train.cat, fun = plotBox, ii =73:84, lab=log(train$loss), ncol = 3)
doPlots(train.cat, fun = plotBox, ii =85:96, lab=log(train$loss), ncol = 3)
doPlots(train.cat, fun = plotBox, ii =97:108, lab=log(train$loss), ncol = 3)
doPlots(train.cat, fun = plotBox, ii =109:116, lab=log(train$loss), ncol = 3)

########################
# continuous density plot
doPlots(train.num, fun = plotDen, ii =1:6, lab=log(train$loss), ncol = 3)
doPlots(train.num, fun = plotDen, ii =7:14, lab=log(train$loss), ncol = 3)

#continuous scatterplot
doPlots(train.num, fun = plotScatter, ii =1:6, lab=log(train$loss), ncol = 3)
doPlots(train.num, fun = plotScatter, ii =7:14, lab=log(train$loss), ncol = 3)

# Examine counts of factors in categories
train.cat.factored <- train.cat %>% mutate_each(funs(factor), starts_with("cat"))


###########
# Categories
##############
# number of categories per variable
cats = apply(train.cat, 2, function(x) nlevels(as.factor(x)))
cats







######################################################################
# Not useful in this case with so many variables
# correspondence (see http://gastonsanchez.com/how-to/2012/10/13/MCA-in-R/)
cats = apply(train.cat.factored[,110:116], 2, function(x) nlevels(as.factor(x)))
mca1 = MCA(train.cat.factored[,110:116], graph = FALSE)

# data frame with variable coordinates
mca1_vars_df = data.frame(mca1$var$coord, Variable = rep(names(cats), cats))

# data frame with observation coordinates
mca1_obs_df = data.frame(mca1$ind$coord)

# plot of variable categories
ggplot(data=mca1_vars_df, 
       aes(x = Dim.1, y = Dim.2, label = rownames(mca1_vars_df))) +
  geom_hline(yintercept = 0, colour = "gray70") +
  geom_vline(xintercept = 0, colour = "gray70") +
  geom_text(aes(colour=Variable)) +
  ggtitle("MCA plot of variables using R package FactoMineR")
#####################################################################


# Piechart of categorical
pie(table(train.cat$cat100))

barplot(table(train.cat$cat101))

library(gmodels)
CrossTable(train$cat1,train$cat2, prop.t=FALSE,prop.r=FALSE,prop.c=FALSE)

#distribution of variables per cateogry
lapply(train.cat, table)

#display counts of category
ggp <- ggplot(train.cat,aes(x=cat109))
ggp + geom_bar()

library(plyr)
apply(train.cat, 2, count)

#Examine proportions
mosaicplot(cat1 ~cat4, data = train.cat, col = c('lightskyblue2', 'tomato'))

mosaicplot(table(traincat$cat1, traincat$cat2), col = TRUE, las = 2, cex.axis = 0.8, shade=TRUE)


# 3-Way Frequency Table
mytable <- xtabs(~cat1+cat2, data=train.cat)
ftable(mytable) # print table 
summary(mytable) # chi-square test of indepedenc





########################
# Examine continuous variables
########################
plot(train$loss)
hist(log(train$loss),100)

ggplot(train) + geom_histogram(mapping=aes(x=log(loss)))

summary(train$loss)


# describe various statistics
describe(train$loss)

###############################################
# Analyze outliers
##############################################
#consider outlier cutoff
# upper outer fence: Q3 + 3*IQ
upper.outer.fence <- quantile(train$loss,0.75) + 3*(quantile(train$loss,0.75)-quantile(train$loss,0.25))
length(which(train$loss > upper.outer.fence))

#lower inner fence
# Q1-1.5(IQR)
lower.inner.fence <- quantile(train$loss,0.25) - 1.5*(quantile(train$loss,0.75)-quantile(train$loss,0.25))
length(which(train$loss < lower.inner.fence))
# Value is 0, lower fence outside lowest value(0)

# consider analysis of outliers
# based on https://www.kaggle.com/kb3gjt/allstate-claims-severity/allstateeda1
outliers <- train[train$loss > upper.outer.fence,]
outlier.index <- which(train$loss > upper.outer.fence)
notoutliers <- train[-outlier.index]

outliers.cat <- outliers[,.SD,.SDcols = cat.var]
outliers.num <- outliers[, .SD, .SDcols = num.var]

plot(outliers$loss)
hist(log(outliers$loss),100)

plot(notoutliers$loss)
hist(log(notoutliers$loss),100)

# Plots for outliers
doPlots(outliers.cat, fun = plotBox, ii =1:12, lab=log(outliers$loss), ncol = 3)
doPlots(outliers.cat, fun = plotBox, ii =13:24, lab=log(outliers$loss), ncol = 3)
doPlots(outliers.cat, fun = plotBox, ii =25:36, lab=log(outliers$loss), ncol = 3)
doPlots(outliers.cat, fun = plotBox, ii =37:48, lab=log(outliers$loss), ncol = 3)
doPlots(outliers.cat, fun = plotBox, ii =49:60, lab=log(outliers$loss), ncol = 3)
doPlots(outliers.cat, fun = plotBox, ii =61:72, lab=log(outliers$loss), ncol = 3)
doPlots(outliers.cat, fun = plotBox, ii =73:84, lab=log(outliers$loss), ncol = 3)
doPlots(outliers.cat, fun = plotBox, ii =85:96, lab=log(outliers$loss), ncol = 3)
doPlots(outliers.cat, fun = plotBox, ii =97:108, lab=log(outliers$loss), ncol = 3)
doPlots(outliers.cat, fun = plotBox, ii =109:116, lab=log(outliers$loss), ncol = 3)

########################
# continuous density plot
doPlots(outliers.num, fun = plotDen, ii =1:6, lab=log(outliers$loss), ncol = 3)
doPlots(outliers.num, fun = plotDen, ii =7:14, lab=log(outliers$loss), ncol = 3)

#continuous scatterplot
doPlots(outliers.num, fun = plotScatter, ii =1:6, lab=log(outliers$loss), ncol = 3)
doPlots(outliers.num, fun = plotScatter, ii =7:14, lab=log(outliers$loss), ncol = 3)



#######################
# Not outliers
notoutliers <- train[-outlier.index]

notoutliers.cat <- notoutliers[,.SD,.SDcols = cat.var]
notoutliers.num <- notoutliers[, .SD, .SDcols = num.var]


# Plots for nonoutliers
doPlots(notoutliers.cat, fun = plotBox, ii =1:12, lab=log(notoutliers$loss), ncol = 3)
doPlots(notoutliers.cat, fun = plotBox, ii =13:24, lab=log(notoutliers$loss), ncol = 3)
doPlots(notoutliers.cat, fun = plotBox, ii =25:36, lab=log(notoutliers$loss), ncol = 3)
doPlots(notoutliers.cat, fun = plotBox, ii =37:48, lab=log(notoutliers$loss), ncol = 3)
doPlots(notoutliers.cat, fun = plotBox, ii =49:60, lab=log(notoutliers$loss), ncol = 3)
doPlots(notoutliers.cat, fun = plotBox, ii =61:72, lab=log(notoutliers$loss), ncol = 3)
doPlots(notoutliers.cat, fun = plotBox, ii =73:84, lab=log(notoutliers$loss), ncol = 3)
doPlots(notoutliers.cat, fun = plotBox, ii =85:96, lab=log(notoutliers$loss), ncol = 3)
doPlots(notoutliers.cat, fun = plotBox, ii =97:108, lab=log(notoutliers$loss), ncol = 3)
doPlots(notoutliers.cat, fun = plotBox, ii =109:116, lab=log(notoutliers$loss), ncol = 3)

########################
# continuous density plot
doPlots(notoutliers.num, fun = plotDen, ii =1:6, lab=log(notoutliers$loss), ncol = 3)
doPlots(notoutliers.num, fun = plotDen, ii =7:14, lab=log(notoutliers$loss), ncol = 3)

#continuous scatterplot
doPlots(notoutliers.num, fun = plotScatter, ii =1:6, lab=log(notoutliers$loss), ncol = 3)
doPlots(notoutliers.num, fun = plotScatter, ii =7:14, lab=log(notoutliers$loss), ncol = 3)


summary(outliers$loss)
plot(outliers$loss)
hist(log(outliers$loss),100)


# factorize variables
train <- train %>% mutate_each(funs(factor), starts_with("cat"))

# create vectors to hold correlation values against loss
cc <- rep(0,132)
cco <- rep(0,132)
for (i in 1:131) cc[i] <- cor(train$loss,as.numeric(train[,i]))
for (i in 1:131) cco[i] <- cor(outliers$loss,
                               as.numeric(outliers[,i]))


# capture standard deviations
sdo <- rep(0,132)
for (i in 1:132) sdo[i] <- sd(as.numeric(outliers[,i]))
which(sdo==0)
# 16 22 23 57 63 64 71

# plot the correlations
plot(cc)
points(cco, col="red")

which(abs(cc)>0.3)

which(abs(cco)>0.3)


#################################################
## re-run with spearman's method ####################
#####################################
# create vectors to hold correlation values against loss
ccs <- rep(0,132)
ccso <- rep(0,132)
for (i in 1:131) ccs[i] <- cor(train$loss,as.numeric(train[,i]), method = "spearman")
for (i in 1:131) ccso[i] <- cor(outliers$loss,
                               as.numeric(outliers[,i]), method = "spearman")

# plot the correlations
plot(ccs)
points(ccso, col="red")



#########################
#Examine continuous variables
##########################
describe(train.num)

# Correlations
correlations <- cor(train.num)
corrplot(correlations, method="square", order="hclust")

# view plot of continuous variables
boxplot(train.num, main ="Test Data Continuos Vars")


ggplot(train) + geom_histogram(mapping=aes(x=cont1))

plot(train$loss,exp(train.num$cont1))
plot(train$loss,train.num$cont1)
