#############################################################################
# Program Name:   PS 3.R
# Author:         Elmer Li
#############################################################################

setwd("/Users/zongyangli/Google Drive/Cornell PhD/3rd Semester/Labor Seminar/PS/PS 3/")
set.seed(2357)

package_list <- c("glmnet", "rpart", "randomForest", "grf")
if(length(package_list)) install.packages(package_list)

library(glmnet)
library(rpart)
library(randomForest)
library(tidyverse)

##################################################
# Q2 OLS vs. Ridge vs. LASSO
##################################################

# Set up data
	y <- as.matrix(rnorm(500,0,100))
	y[1,1] = 0

	x <- matrix(0,500,499)
	for (i in 2:500) {
	  x[i,i-1] = 1
	}

# OLS regression
	ols <- lm(y~x)
	summary(ols)
	b_ols <- ols$coefficients
	plot(y,b_ols)

# Ridge regression
	ridge_all <- glmnet(x, y, alpha = 0)
	ridge_all
	summary(ridge_all)
	coef(ridge_all, s=10)

	# cross-validated ridge
		ridge <- cv.glmnet(x, y, alpha = 0)
		plot(ridge)
		ridge$lambda.min
		b_ridge <- coef(ridge, s = "lambda.min")
		plot(y,b_ols)
		points(y, b_ridge, col = "red")

# LASSO regression
	lasso <- cv.glmnet(x, y, alpha = 1)
	plot(lasso)
	lasso$lambda.min
	b_lasso <- coef(lasso, s = "lambda.min")
	plot(y,b_ols)
	points(y,b_lasso, col = "blue")


##################################################
# Q3 LASSO in MS (2017)
##################################################

########################################################################
## Load and prepare data

setwd("/Users/zongyangli/Google Drive/Cornell PhD/3rd Semester/Labor Seminar/PS/PS 3/")
basedata <- readRDS(file=paste0("ahs2011forjep.rdata"))

# subtract from dataframe
	localahs <- basedata$df # the data matrix
	Y <- localahs[,"LOGVALUE"] # the Y variable
	thisrhs <- paste(basedata$vars,collapse=" + ") # specify the RHV

# tranlate all var into dummies
	X <- model.matrix(as.formula(paste("LOGVALUE", thisrhs, sep = " ~ ")),localahs)


########################################################################
## Select & fix tuning parameter

# pick the training sample
	set.seed(2357)
	firstsubsample <- sample(nrow(localahs),nrow(localahs)/10)

# run LASSO
	library(glmnet)
	firstlasso <- glmnet(X[firstsubsample,],Y[firstsubsample]) # there are 89 lambdas from this LASSO

# compute MSE, select lambda
	# select lambda
	losses <- apply(predict(firstlasso,newx=X[-firstsubsample,]),2, function(Yhat) mean((Yhat - Y[-firstsubsample])^2)) 
	      	# apply: 2 apply to column. Yhat produced by the prediction on each of 89 lambda. function of Yhat - let Yhat minus the true Y
	lambda <- firstlasso$lambda[which.min(losses)]
	# plot(log(firstlasso$lambda),losses)

	# calculate MSE
		# MSE for validation
		losses_valid1 <- apply(predict(firstlasso,newx=X[-firstsubsample,],s=lambda),2, function(Yhat) mean((Yhat - Y[-firstsubsample])^2)) 
		R_sq_valid1 = 1 - (losses_valid1/var(Y[-firstsubsample]))
		# MSE for training
		losses_train1 <- apply(predict(firstlasso,newx=X[firstsubsample,],s=lambda),2, function(Yhat) mean((Yhat - Y[firstsubsample])^2)) 
	  	R_sq_train1 = 1 - (losses_train1/var(Y[firstsubsample]))
	# compare	
		R_sq_train1 - R_sq_valid1 # R square of training always greater than validation



########################################################################
## Replicate cv.glmnet

# run LASSO, get all lambda
	lasso_full <- glmnet(X,Y) 
	lambdas <- lasso_full$lambda

# calculate MSE, 10-fold validation
	I <- length(unique(localahs$lassofolds))
	MSE <- matrix(0,nrow=length(lambdas),ncol=I+1)
	# iterate across 10 folds
	for(i in 1:I) {
		thissubsample <- localahs$lassofolds == i
		thislasso <- glmnet(X[!thissubsample,],Y[!thissubsample])
		thislosses <- apply(predict(thislasso,newx=X[-thissubsample,], s=lambdas),2,function(Yhat) mean((Yhat - Y[-thissubsample])^2))
		MSE[,i] = thislosses
	}

# calculate avg MSE, pick lambda
	MSE[,11] <- rowMeans(MSE[,1:10])
	lambda_manual = lambdas[which.min(MSE[,11])]

# use cv.glmnet package
	lasso_full2 <- cv.glmnet(X,Y)
	lambda_glmnet = lasso_full2$lambda.min

	print(paste0("lambda_manual: ",lambda_manual," lambda_glmnet: ",lambda_glmnet))


##################################################
# Q4 Regression Trees & Random Forest
##################################################

va <- read.csv("/Users/zongyangli/Google Drive/Cornell PhD/3rd Semester/Labor Seminar/PS/PS 2/va.csv")

## Regression tree
	
	set.seed(2357)
# specify model, sample & r2 function
	model <- as.formula(inc ~ math0 + lang0)
	train_va <- sample(nrow(va),nrow(va)/2)
	r2 <- function(y,yhat){
		r2 = cor(y,yhat)^2; return(r2)
	}
	
# regression tree & R2
	tree1 <- rpart(model,va[train_va,])
	plot(tree1); text(tree1, cex = 0.8)
	
	tree_train_hat <- predict(tree1, va[train_va,])
	tree_valid_hat <- predict(tree1, va[-train_va,])
	r2(tree_train_hat,va[train_va,"inc"]) %>% print()
	r2(tree_valid_hat,va[-train_va,"inc"]) %>% print()

# Tree pruning
	tree2 <- rpart(model,va[train_va,], cp = 0.01)
	plot(tree2); text(tree2, cex = 0.8)
	
# try diff cp parameter
	R2 <- matrix(0,nrow=100,ncol=2)
	for(i in 1:100) {
		tree <- rpart(model,va[train_va,], cp = (i/1000))
		tree_train_hat <- predict(tree, va[train_va,])
		tree_valid_hat <- predict(tree, va[-train_va,])
		R2[i,1] = r2(tree_train_hat,va[train_va,"inc"])
		R2[i,2] = r2(tree_valid_hat,va[-train_va,"inc"])
	}
	# plot R2
	plot(R2[,1],R2[,2], pch = 9, ylim=c(0,0.5), xlim=c(0,0.7),)
	abline(coef = c(0,1), col = "dark red")
	
# g. pruning - find cp minimizing error
	tree3 <- rpart(model,va[train_va,],cp=0.0001)
	printcp(tree3); which.min(tree3$cptable[,"xerror"]); cp_min = tree3$cptable[67,"CP"]
	
# k. re-estimation
	tree4 <- rpart(model,va[train_va,], cp = cp_min)
	tree_train_hat <- predict(tree4, va[train_va,]); 
	tree_valid_hat <- predict(tree4, va[-train_va,])
	r2(tree_train_hat,va[train_va,"inc"]) %>% print()
	r2(tree_valid_hat,va[-train_va,"inc"]) %>% print()


## Random forest

#run regression, check results
	rf <- randomForest(model, data = va[train_va,], importance=TRUE)
	rf; varImpPlot(rf)

# compute R2
	rf_train_hat <- predict(rf, va[train_va,])
	rf_valid_hat <- predict(rf, va[-train_va,])
	r2(rf_train_hat,va[train_va,"inc"]) %>% print() # 0.5568
	r2(rf_valid_hat,va[-train_va,"inc"]) %>% print() # 0.365

# try diff ntree parameter
	R2_rf <- matrix(0,nrow=13,ncol=1)
	for(i in 0:12) {
		rf1 = randomForest(model, data = va[train_va,], importance=TRUE, ntree = 2^i)
		rf_valid_hat <- predict(rf1, va[-train_va,])
		R2_rf[i,1] = r2(rf_valid_hat,va[-train_va,"inc"]) %>% print()
	} # 0.2877927 0.3204152 0.3438068 0.3555668 0.3539979 0.3635074 0.363689 0.3654504 0.3640022 0.3645096 0.3650106 0.3655636 0.3652653


##################################################
# Q5: Heterogeneous treatment effect
##################################################

rd <- read.csv("/Users/zongyangli/Google Drive/Cornell PhD/3rd Semester/Labor Seminar/PS/PS 1/rd.csv", header = T)
library(grf)

## Standard regression 
	ols <- lm(grad_any ~ admit_flag + test + cutoff + admit_flag:test + admit_flag:cutoff, rd)
	summary(ols)

## Calsual forest
	cov_forest <- data.matrix(rd[,c("test","cutoff")])
	forest <- causal_forest(cov_forest, rd$grad_any, rd$admit_flag)
		print(forest)

# examine the results
	grid <- matrix(0,nrow=19,ncol=2)
	grid[,1] = quantile(rd$test, probs = seq(0.05, 0.95, 0.05))
	grid[,2] = median(rd$cutoff)

	# predict and plot
	estimates = predict(forest,grid,estimate.variance=TRUE)
	grad_hat = estimates$predictions
    grad_hat_se = sqrt(estimates$variance.estimates)

    plot(grid[,1],grad_hat, ylim=c(-0.5,0.5), xlim=c(0,500), pch =16)
    lines(grid[,1],grad_hat + 1.96*grad_hat_se, col = "blue", lty=2)
    lines(grid[,1],grad_hat - 1.96*grad_hat_se, col = "blue", lty=2)
    
















  