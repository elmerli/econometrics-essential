
# https://www.r-bloggers.com/fitting-a-neural-network-in-r-neuralnet-package/

rm(list=ls())
cat("/014")
setwd("/Users/zongyangli/Google Drive/Wagner/Semester 4/Applied Stats & Econo II/Prob Sets/PS3")
set.seed(500) # 

library(MASS)
data <- Boston

# first check no datapoint is missing

apply(data,2,function(x) sum(is.na(x)))

# We proceed by randomly splitting the data into a train and a test set, then we fit a linear regression model 
# and test it on the test set. Note that I am using the gml() function instead of the lm() this will become 
# useful later when cross validating the linear model.

index <- sample(1:nrow(data),round(0.75*nrow(data))) # The sample(x,size) function simply outputs a vector of the specified size of randomly selected samples from the vector x. By default the sampling is without replacement: index is essentially a random vector of indeces.
train <- data[index,]
test <- data[-index,]
# we use gls
lm.fit <- glm(medv~.,data=train) # period model is everthing
summary(lm.fit)
pr.lm <- predict(lm.fit,test)
MSE.lm <- sum((pr.lm - test$medv)^2)/nrow(test) # since we are dealing wit reg problem, we are going to the MSE as a measure of how much our prediction are far away


##################################################
# Prepare Data
##################################################

# Normalize your data before training a neural network
	# here use min-max method and scale the data in the interval [0,1]. Usually scaling in the intervals [0,1] or [-1,1] tends to give better results.
maxs=apply(data,2,max)
mins=apply(data,2,min)
scaled = as.data.frame(scale(data,center = mins, scale= maxs-mins))

train_ = scaled[index,]
test_ = scaled[-index,]

##################################################
# Parameters
##################################################

# Layer: usually one hider layer is enought, 
# Num of neurons: useually 2/3 of the input size
# Here use: 13:5:3:1, output with one year becasue of regression

install.packages("neuralnet")
library(neuralnet)

n=names(train_)
f=as.formula(paste("medv ~"), paste(n[!n %in% "medv"], collapse = " + ")) 
	# The formula y~. is not accepted in the neuralnet() function. First write the formula and then pass it as an argument in the fitting function.

nn=neuralnet(f, data=train_, hidden=c(5,3), linear.output=T)
plot(nn)



##################################################
# PPredicting medv using the neural network
##################################################

pr.nn <- compute(nn,test_[,1:13])

pr.nn_ <- pr.nn$net.result*(max(data$medv)-min(data$medv))+min(data$medv)
test.r <- (test_$medv)*(max(data$medv)-min(data$medv))+min(data$medv)

MSE.nn <- sum((test.r - pr.nn_)^2)/nrow(test_)
we then compare the two MSEs

print(paste(MSE.lm,MSE.nn))


par(mfrow=c(1,2))

plot(test$medv,pr.nn_,col='red',main='Real vs predicted NN',pch=18,cex=0.7)
abline(0,1,lwd=2)
legend('bottomright',legend='NN',pch=18,col='red', bty='n')

plot(test$medv,pr.lm,col='blue',main='Real vs predicted lm',pch=18, cex=0.7)
abline(0,1,lwd=2)
legend('bottomright',legend='LM',pch=18,col='blue', bty='n', cex=.95)





pbar <- create_progress_bar('text') # progress bar
pbar$init(k) # initial value of progress bar

for(i in 1:k){
    index <- sample(1:nrow(data),round(0.9*nrow(data)))
    train.cv <- scaled[index,]
    test.cv <- scaled[-index,]
    
    nn <- neuralnet(f,data=train.cv,hidden=c(5,2),linear.output=T)
    
    pr.nn <- compute(nn,test.cv[,1:13]) # raw forcast
    pr.nn <- pr.nn$net.result*(max(data$medv)-min(data$medv))+min(data$medv) # forcast regularized 
    
    test.cv.r <- (test.cv$medv)*(max(data$medv)-min(data$medv))+min(data$medv)
    
    cv.error[i] <- sum((test.cv.r - pr.nn)^2)/nrow(test.cv)
    
    pbar$step()
}


cv.error # cross validation error



###PROBLEM III
#Creating function for misclassification rate
#from stat.rutgers.edu/~yhung/Stat586/LDA/some%20examples%20in%20R.doc
rm(misclassification.rate)
misclassification.rate=function(tab){
  num1=sum(diag(tab))
  denom1=sum(tab)
  signif(1-num1/denom1,3)
}

##Loading and preparing the data
crime = na.omit(read.table("crime.txt"))
attach(crime)
#Creating categorical variable
acr = mean(crime$V3)
crime$crmcat = ifelse(crime$V3>acr, c("above"), c("below"))

#Separating data into train (1972 data) and test (1978 data)
train = subset(crime, V6<1)
test = subset(crime, V6>0)

##1. LDA, assuming the predictors in the question refer 
##to those of the linear model in PS2 (clear up rates for 2 years). 
#Fitting LDA on the training data
lda1 = lda(crmcat~V4+V5, data=train)
#Predicting on test data
prdlda = predict(lda1, newdata = test)$class
#Table of misclassifications
tab = table(prdlda, test$crmcat)
#Misclassification rate
misclassification.rate(tab)
#LDA has a 24.5% misclassification rate

##2. Now with QDA
qda1 = qda(crmcat~V4+V5, data=train)
#Predicting
prdqda = predict(qda1, newdata = test)$class
tab2 = table(prdqda, test$crmcat)
#Misclassification rate
misclassification.rate(tab2)
#QDA has a misclassifiaction rate of 18.9%, so it performed better than LDA.

##3. Now KNN. I choose K=19 based on 15 repeats of 10-fold cross validation, 
#following example in:
#http://stats.stackexchange.com/questions/31579/what-is-the-optimal-k-for-the-k-nearest-neighbour-classifier-on-the-iris-dat 
model <- train(
  cat~V6+V4+V5, 
  data=crime, 
  method='knn',
  tuneGrid=expand.grid(.k=1:25),
  metric='Accuracy',
  trControl=trainControl(
    method='repeatedcv', 
    number=10, 
    repeats=15))
model
plot(model)
#Plot shows that accuracy is highest at k=19, so I choose that to fit kNN:

#Choosing numeric columns for kNN (won't run with non-numeric)
knntest = test[,1:8]
knntrain = train[,1:8]
#Creating labels for cl argument of knn function
test_labels = test[,13]
#Fitting kNN
kNN = knn(train = knntrain, test = knntest, cl = test_labels, k=19)
#Calculating proportion of correct classifications
#(following example in https://rstudio-pubs-static.s3.amazonaws.com/123438_3b9052ed40ec4cd2854b72d1aa154df9.html)
100*sum(test_labels == kNN)/100
#kNN correctly classifies 41% of observations, which is less than LDA and QDA. 
#from the three methods, QDA had the best results.




