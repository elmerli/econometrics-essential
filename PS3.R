
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







