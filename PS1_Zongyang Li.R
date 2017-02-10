##################################################
# Startup
##################################################

package_list <- c("tidyr", "dplyr","tidyverse","readxl","gmm")
`%notin%` <- Negate(`%in%`)
new_packages <- package_list[package_list %notin% installed.packages()[,"Package"]]
if(length(new_packages)) install.packages(new_packages)

library(tidyr)
library(dplyr)
library(readxl)
library(gmm)
library(sandwich)

##################################################
# Q4
##################################################

## Read data
	klein_data<-read_excel("/Users/elmerleezy/Google Drive/Wagner/Semester 4/Applied Stats & Econo II/Prob Sets/PS1/klein_data.xls", sheet = "klein_data")

## Set new variables
	klein_data <- klein_data %>% mutate(wpg = Wp*G, Pl = lag(P,1)) 
	klein_datal = klein_data[-1,]

## Run the gmm model
	attach(klein_datal) # aviods doing $ all the time

	gmm1 = gmm(C ~ P + Pl + wpg, ~ I + K + GNP + Wg, wmatrix = "optimal")
	summary(gmm1)

## Calculate estimated variance of coefficients
  # var1 = (gmm1$residuals)*length(gmm1$residuals)/length(gmm1$residuals) - length(gmm1$coefficients) # n/n-k * residuals
	var1 = gmm1$vcov

## Calculate estimated variance of residuals
	var_res = t(gmm1$residuals)%*%gmm1$residuals/(length(gmm1$residuals)-length(gmm1$coefficients)) # %*% is multiple of matrix


## ANSWER: 

# For the estimation of the residual variance, we can see from the value of var_res, 
# which gives us the result: 15.42452

#For significance test, we can read from the summary of our gmm estimator - gmm1; 
#from the table we can see from the result of the t-test statistic that the coefficients
#for P, wpg and intercept are all very small to make them all statistically significant 
#at 1% level. For Pl, the test result shows the significance at 10% level. 

# The J-test statistics gives us the result of whether the moment conditions hold; 
# It test the null hypothesis that E(g)=0, based on the scoring funtion together with optimal weighting
# The p-value of the test 0.04462 shows that it rejects the null at 5% significance. 
# This result indicates that it is very likely that the moment conditions won't hold. 


##################################################
# Q5
##################################################

## Read data
	data1<-read_excel("/Users/elmerleezy/Google Drive/Wagner/Semester 4/Applied Stats & Econo II/Prob Sets/PS1/FormattedData.xlsx", sheet = "Sheet3")
	data1 <- data1[,c(1:13)]

## Use gcnq gcsq to infer for the consumption -> sum them and then devide to get the C_t+1/C_t in the model
	data1$C.ret = rowSums(data1[c('gcnq','gcsq')])/c(NA,rowSums(data1[c('gcnq','gcsq')]))[-dim(data1)[1]]

## Indicate the assets that to be used in the moment conditions
	test.assets = c('govb','corp','tbill','vwr','ewr')
	# Sets Beta to 1
	BBeta = 1 
	# Collects the useful variables
	mtx = as.matrix(data1[-1,c(test.assets,'C.ret')])

## Set up the  matrix is then used to build the q sample moment conditions
g = function(gam,mtx){
  1 - BBeta*(1+mtx[,c(1,length(test.assets))])*mtx[,length(test.assets)+1]^-gam # mtx[,length(test.assets)+1] is the consumption component in the equation
}

## Run the gmm model
	gmm2 = gmm(g,mtx,t0=300,optfct='optimize',lower=0,upper=1000)
	summary(gmm2)

## COMMENT
# We get a theta of 491.0527 from first step and about 523 from second step, 
# and from it's t-test statistic we can see that the coefficients of 
# theta is statistically significant at 1% level. 

# For J-test of if moment conditions hold, we get a p-value of 0.23588, for which shows
# that we fail to reject that E(g)=0, which indicates that the moment conditions hold 


## Use only vwr and tbill as test assets, run the gmm model again
	test.assets = c('tbill','vwr')
	mtx = as.matrix(data1[-1,c(test.assets,'C.ret')])

	g2 = function(gam,mtx){
	  1 - BBeta*(1+mtx[,c(1,length(test.assets))])*mtx[,length(test.assets)+1]^-gam # mtx[,length(test.assets)+1] is the consumption component in the equation
	}

	gmm3 = gmm(g,mtx,t0=300,optfct='optimize',lower=0,upper=1000)
	summary(gmm3)

## COMMENT
# We get the coefficient of theta of 502.9353 from first step and about 611 from second step, 
# and from it's t-test statistic we can see that the coefficients of 
# theta is statistically significant at any conventional level. 

# For J-test of if moment conditions hold, we get a p-value extremely small, which makes us
# unable to reject that the null hypothesis that E(g)=0, a indication that the moment conditions doesn't hold 







