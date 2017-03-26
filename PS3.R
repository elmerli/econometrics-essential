

rm(list=ls())
cat("/014")
setwd("/Users/elmerleezy/Google Drive/Wagner/Semester 4/Applied Stats & Econo II/Prob Sets/PS3")
set.seed(500) # 

library(MASS)
data=Boston

# first check no datapoint is missing

apply(data, 2, function() sum(is.na(x)))

# randomly split the data into a train and test, fit linear regresssion and test it on the test set

index = sample(1:nrow(data),round(0.75*nrow(data)))
train = data[index,]
test = data[-index,]

# we use gls

lm.fit = glm(medv~.,data=train) # period model is everthing
summary(lm.fit)
pr.lm = predict(lm.fit,test)
MSE.lm = sum((pr.lm-test$medv)^2)/nrow(test)

#### coursera machine learning

# since we are dealing wit reg problem, we are going to the MSE as a measure of how much our prediction are far away

# Data preparation
maxs=apply(data,2,max)
mins=apply(data,2,min)
scaled = as.data.frame(scale(data,center = mins, scale= maxs-mins))

train_ = scaled[index,]
test_ = scaled[-index,]

# usually one hider layer is enought, as far as the num of neurons is concerend, useually 2/3 of the input size
# 13;5;3;1

install.packages("neuralnet")
library(neuralnet)

n=names(train_)
f=as.formula(paste("medv ~"), paste(n[!n %in% "medv"], collapse = " + "))
nn=neuralnet(f,data=train_,hidden=c(5,3),linear.output=T)
plot(nn)

pr.nn = comute(nn,test_[,1:13])
pr.nn_ = pr.nn$net.result*(max(data$medv) - min(data$medv)) + min(data$medv)
test.r = (test_$medv)*(max(data$medv)- min(data$medv)) + min(data$medv)


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







