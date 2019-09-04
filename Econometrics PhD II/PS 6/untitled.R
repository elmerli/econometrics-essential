
#############################################################################
# Program Name:   Metrics II PS6.R
# Location:      
# Author:         
# Date Created:   
#############################################################################

# library("glmnet")
 # library("mvtnorm") 

# Parameters
n  <- 100
N  <- 200
B  <- 10
b <- c(1,rep((n)^(-0.5), n-1))
mse0 <- rep(0, B)
mse1 <- rep(0, B)
mse2 <- rep(0, B)
k   <- 0
l   <- 0

for (i in 1:B){
  # Sample
  x  <- matrix(rnorm(N*n), nrow=N, ncol=n)
  y  <- x %*% b + rnorm(N)
  
  # Split data into train (2/3) and test (1/3) sets
  train_rows <- sample(1:N, .66*N)
  x.train    <- x[train_rows, ]
  x.test     <- x[-train_rows, ]
  y.train    <- y[train_rows]
  y.test     <- y[-train_rows]
  
  # Fit models 
  fit.ols   <- lm(y.train ~ x.train)
  
  fit.lasso <- glmnet(x.train, y.train, family="gaussian", alpha=1)
  
  fit.ridge <- glmnet(x.train, y.train, family="gaussian", alpha=0)
  
  # Comparison
  par(mfrow=c(1,2))
  plot(fit.lasso, xvar="lambda")
  plot(fit.ridge, xvar="lambda")
  yhat2  <- predict(fit.ridge, s=fit.ridge$lambda.1se, newx=x.test)
  yhat1  <- predict(fit.lasso, s=fit.lasso$lambda.1se, newx=x.test)
  yhat0  <- cbind(rep(1, N - length(train_rows)), x.test) %*% coef(fit.ols)
  
  mse2[i]   <- mean((y.test - yhat2)^2)
  mse1[i]   <- mean((y.test - yhat1)^2)
  mse0[i]   <- mean((y.test - yhat0)^2)
  k         <- k + (mse1[i] < mse0[i])
  l         <- l + (mse1[i] < mse2[i])
}
