##Problem 3
#Loading data
klein <- read_excel("~/Dropbox/NYU/Spring/Econometrics/PS1/klein_data.xls")
#Setting variables
klein$wpg = klein$Wp*klein$G
klein$Pl = c(NA,klein$P[-length(klein$P)])
kleinl = klein[-1,]
#Installing packages to run gmm
install.packages("gmm")
library(sandwich)
library(gmm)
attach(kleinl)

# Runing gmm model, with optimal weighting matrix
gmm1 = gmm(C ~ P +Pl + wpg, ~I + K + GNP + Wg, wmatrix = "optimal")
summary(gmm1)
#The test E(g)=0, it's a test on the moment conditions, with null hypothesis 
#that the moment condition holds. J-test is evaluating the score function at 
#the optimal value, which has a chisq distribution. P-value OF 0.04 means reject 
#the null at the 5% significance

# Calculating estimated variance of coefficients
var1 = gmm1$vcov
var1                                                
#diagonal gives the variance of the coefficients.                                                

#Calculating estimated variance of residuals
var_res = t(gmm1$residuals)%*%gmm1$residuals/(length(gmm1$residuals)-length(gmm1$coefficients))
var_res

###Problem 4
data1 <- read_excel("~/Dropbox/NYU/Spring/Econometrics/PS1/FormattedData.xlsx")
summary(data1)
##Running gmm using instruments govb,corp,tbill,vwr,ewr
#Getting variable for asset returns
data1$C.ret = rowSums(data1[c('gcnq','gcsq')])/c(NA,rowSums(data1[c('gcnq','gcsq')]))[-dim(data1)[1]]
#Setting assets that we will put in moment conditions
test.assets=c('govb','corp','tbill','vwr','ewr')
#Setting beta to 1
BBeta = 1
#Creating matrix with test assets and returns
mtx = as.matrix(data1[-1,c(test.assets,"C.ret")])
#Defining function to obtain gamma parameter
g = function(gam,mtx){
  1 - BBeta*(1+mtx[,c(1,length(test.assets))])*mtx[,length(test.assets)+1]^-gam
}
#Running gmm model
gmm2 = gmm(g,mtx,t0=300,optfct='optimize',lower=0,upper=1000)
summary(gmm2)
#get a p-value of 0.23, so we fail to reject null that the moment condition
#holds.

##Doing the same as above but with only vwr and tbill as test assets
test.assets2=c('tbill','vwr')
mtx2 = as.matrix(data1[-1,c(test.assets2,"C.ret")])
g2 = function(gam,mtx){
  1 - BBeta*(1+mtx[,c(1,length(test.assets2))])*mtx[,length(test.assets2)+1]^-gam
}
gmm3 = gmm(g2,mtx2,t0=300,optfct='optimize',lower=0,upper=1000)
summary(gmm3)
#The estimated parameter gamma is approximately 502 in the first step, and
#610 in the second step. The standard error of gamma=610 is 0.91, giving a 
#t-statistic that confirms significance at virtually any level. 
#For the model as a whole, we get a J-test of 57.9, and a p-value extremely close
#to 0, so we reject the null hypothesis that the moment condition holds.

