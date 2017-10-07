##################################################
# Startup
##################################################

package_list <- c('plm','lmtest','car',"tidyr","dplyr")
`%notin%` <- Negate(`%in%`)
new_packages <- package_list[package_list %notin% installed.packages()[,"Package"]]
if(length(new_packages)) install.packages(new_packages)

library(tidyr)
library(dplyr)

setwd("/Users/elmerleezy/Google Drive/Wagner/Semester 4/Applied Stats & Econo II/Prob Sets/PS2")

######################################################################
# Q1
######################################################################

### Input data
mydata <- read.table("crime.txt")
mydata <- mydata %>% 
  mutate(district = V1, year = V2, crime = V3, clrprc1 = V4, clrprc2 = V5, d78 = V6, avgclr = V7, lcrime = V8, clcrime = V9, cavgclr = V10, cclrprc1 = V11, cclrprc2 = V12) %>%
  select(district,year,crime,clrprc1,clrprc2,d78,avgclr,lcrime,clcrime,cavgclr,cclrprc1,cclrprc2)

attach(mydata)
##################################################
### Pooled OLS
##################################################

reg1 = lm(lcrime ~ d78+clrprc1+clrprc2)
summary(reg1)

# test for serial correlation
library(car)
dwt(reg1)

## Comment: 

# The coefficients of the clear-up rate of two years: -0.018495 and -0.017388, with their p-values at 0.000721
# and 0.001845, thus they both appear to be very statistically significant with clrprc1 more significant
# than clrprc1. The size of the coefficients appear to be relatively small compared with their residuals. 

# The Durbin Watson test static for the autocorrelation in residuals is 1.223298, and the p-value is 0
# Since the test static is different from 2 and the p-value is very small, we reject the null hypothesis
# and conclude that there is autocorrelation

##################################################
### Fixed Effects
##################################################

library(plm)
reg2 = plm(lcrime ~ d78+clrprc1+clrprc2, data = mydata, model = "within")
summary(reg2)

## Comment: 
# With the fixed-effects model, the coefficients on the clear-up rate of both years become much smaller
# with clrprc1 of -0.0040475 and clrprc2 of -0.0131966; clrprc1 appear to be statistically not significant
# anymore and clrprc2 significant only at 5%. 
# The residuals from this model appear to be very small and also have very small variance, thus there isn't 
# likely to be serial correlation. 

# Run bp test - obtain herterskadasticity
library(lmtest)
bptest(reg2)

## Comment: 
# From the Breusch-Pagan test p-value is 0.9434, which is very big. Thus we fail to reject the null 
# hypothesis that there is no herterskadasticity. 

##################################################
### Random Effects
##################################################

reg3 = plm(lcrime ~ d78+clrprc1+clrprc2, data = mydata, model = "random")
summary(reg3)

phtest(reg2, reg3)

## Comment: 
# Using random effects, the coefficients of clrprc1 becomes significant again, at 15% level
# Using Hausman test between the fixed and random effects model, the p-value is 0.007003
# Thus we reject the null hypothesis and conclude that there is statistically significant difference between 
# these two models and the random effect is relatively strong. 


##################################################
### Test Hypothesis
##################################################

# linear hypothesis: clrprc1=clrprc2
linearHypothesis(reg2,'clrprc1=clrprc2')

## Comment: 
# Since the p-value from the test is 0.283, we fail to reject the hypothesis that the two co-efficients 
# appear to be similar to each other. 
# To have a more parimonious model, we may use the variable avgclr, which is the average of the clear-up
# of these two years to be the right hand variable. 

######################################################################
# Q4-3
######################################################################

## Plot 3-d Mean for beta distribution
	a <- seq(0,10,length=20)
	b <- seq(0,10,length=20)
	f =function(a,b){
		(49+a)/(77+a+b)
	}
	beta_mean=outer(a,b,f)

persp(a,b,beta_mean,
      theta=10,phi=10,expand=0.8,col='orange2',xlab='a',ylab ='b',zlab='beta_mean')






