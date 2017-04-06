##################################################
# Startup
##################################################

# Include libraries
library(readr)
library(tidyr)
library(dplyr)
library(pryr)
 # library(plyr)
library(knitr)
library(stringr)
library(ggplot2)

setwd('/Users/elmerleezy/Google Drive/Wagner/Semester 4/Applied Stats & Econo II/Prob Sets/PS3')

##################################################
### Problem 2
##################################################

library(readxl)
weo <- read_excel("P2dataexcelcopy.xlsx", sheet = 'weoreptc (5)')
names(weo) <- names(weo) %>% str_to_lower() %>% make.names(unique = TRUE, allow_ = T)

## Import and Clean Data
weo_2 <- weo %>%
	mutate(variable = subject.descriptor, value = X2016) %>%
	select(country,variable,value) %>%
	tidyr::spread(variable,value)

names(weo_2) <- names(weo_2) %>% str_to_lower() %>% make.names(unique = TRUE, allow_ = T)

weo_3 <- weo_2 %>%
	mutate(gen_lend_borrow_net = general.government.net.lending.borrowing,       
		   gen_gov_rev = general.government.revenue,                      
		   gen_str_bal = general.government.structural.balance,        
		   gdp_growth = gross.domestic.product..constant.prices,    
		   gns= gross.national.savings,                         
		   output_gap = output.gap.in.percent.of.potential.gdp,         
		   libor_six_mon = six.month.london.interbank.offered.rate..libor., 
		   export_vol_change = volume.of.exports.of.goods.and.services) %>%
	dplyr::select(country,gen_lend_borrow_net, gen_gov_rev, gen_str_bal, gdp_growth, gns, output_gap, libor_six_mon, export_vol_change)%>%
  filter(!is.na(country),!is.na(gen_str_bal)) %>%
  mutate(gen_str_bal_2 = ifelse(gen_str_bal > 0,1,0))

#####################
## Problem 2.1 
#####################
library(stargazer)

## Run regression
weo.probit <- glm(gen_str_bal_2 ~ export_vol_change + gdp_growth + gen_lend_borrow_net + gen_gov_rev + libor_six_mon + output_gap + gns, family = binomial(link = "probit"), data = weo_3)
weo.probit_2 <- glm(gen_str_bal_2 ~ export_vol_change + gdp_growth + gen_lend_borrow_net + gen_gov_rev + output_gap + gns, family = binomial(link = "probit"), data = weo_3)
weo.probit_3 <- glm(gen_str_bal_2 ~ export_vol_change + gdp_growth + gen_lend_borrow_net + gen_gov_rev + gns, family = binomial(link = "probit"), data = weo_3)
## Table the result
summary(weo.probit)
summary(weo.probit_2)
summary(weo.probit_3)
stargazer(weo.probit,type="text")
stargazer(weo.probit_2,type="text")
stargazer(weo.probit_3,type="text")

## Comment: 
	# The table is outputed by the stargazer function, together with the standard deviations
	# The t-ratio is the estimate of the coefficients devided by their mean. 

#####################
## Problem 2.2
#####################

## Comment: 
	# From the above two regression results, we can see that excluding six month libor rate and Output gap 
	# in percent of potential GDP has significantly improve the explanatory power of the model. 
	# This can be seen from the increased p-values of other variables once excluding these two, and the increased 
	# AIC, from 4 to 14 to 32. This might because that these two vairables have too many missing values
	# We then try to exclude change in volume of exports of goods and services, which is the least significant from last regression: 
	weo.probit_4 <- glm(gen_str_bal_2 ~ gdp_growth + gen_lend_borrow_net + gen_gov_rev + gns, family = binomial(link = "probit"), data = weo_3)
	summary(weo.probit_4)
	# but then we can see that the AIC is 30 now,lower than before.So we may conclude that there are no variables we want to exclude for now

	# For variables that we want to include, since our dependent variable is general government structural balance
	# since we only have export, we may consider import as well. Also we may want to include savings cause that might have 
	# implications for government investment and expenditure. 

#####################
## Problem 2.3 - 2.4
#####################
install.packages("mfx") 
library(mfx)

weo.probitmfx <- probitmfx(formula = gen_str_bal_2 ~ export_vol_change + gdp_growth + gen_lend_borrow_net + gen_gov_rev + gns, atmean=FALSE, data = weo_3)
weo.probitmfx

## Comment: 
	# From the regression output of probitmfx, we may observe that the marginal effects of gdp growth on the probability of deterioration of 
	# government budget is -0.0355904. Note we've specified that atmean=FALSE, this is saying that the we calculates the average partial effects.

	# The standard error is given by: 0.0432227 as in the output of the regression.

#####################
## Problem 2.5
#####################

weo_4 <- weo_3 %>% mutate(euro = ifelse(country =="Czech Republic"|country =="Iceland",1,ifelse(is.na(output_gap),0,ifelse(country == "Korea" | country == "Japan" | country == "Australia"|country == "Canada",0,1))))

weo.probitmfx_2 <- probitmfx(formula = gen_str_bal_2 ~ export_vol_change + gdp_growth + gen_lend_borrow_net + gen_gov_rev + gns + euro, atmean=FALSE, data = weo_4)
weo.probitmfx_2

## Comment: 
	# From the regression output, we can see that the marginal effects of being a EU country on the probability of deterioration of 
	# government budget is 0.0899108. And this also the average partial effects.

##################################################
### Problem 3
##################################################

## Import Data
crime <- read.table("crime.txt")

crime_1 <- crime %>%
  mutate(district = V1, year = V2, crime = V3, clrprc1 = V4, clrprc2 = V5, d78 = V6, avgclr = V7, lcrime = V8, clcrime = V9, cavgclr = V10, cclrprc1 = V11, cclrprc2 = V12) %>%
  select(district,year,crime,clrprc1,clrprc2,d78,avgclr,lcrime,clcrime,cavgclr,cclrprc1,cclrprc2) %>%
  mutate(crime_mean = mean(crime, na.rm = T), crime_compare = ifelse(crime > crime_mean, 1, 0))

#####################
## Problem 3.1 - LDA
#####################

library(MASS)
crime.lda <- lda(crime_compare ~ d78+clrprc1+clrprc2, data=crime_1, na.action="na.omit", CV=TRUE)
	# cmt: The code above performs an LDA. CV=TRUE generates leave-one-out cross validation.
crime.lda # show result
## Show result as a table
table(crime_1$crime_compare, crime.lda$class , dnn = c('Actual','Predicted LDA')) 

#####################
## Problem 3.2 - QDA
#####################

crime.qda <- qda(crime_compare ~ d78+clrprc1+clrprc2, data=crime_1, na.action="na.omit", CV=TRUE)

## Compare - Method 1: the build in cross-validation function in LDA and QDA
table(crime_1$crime_compare, crime.lda$class, dnn = c('Actual Group','Predicted LDA'))
table(crime_1$crime_compare, crime.qda$class, dnn = c('Actual Group','Predicted QDA'))

## Comment: 
	# from the ouput table we can see very obviously that QDA did a better job at predicting since there are
	# more groups predicted right by QDA. 

## Compare - Method 2: manul cross validation and compare MSE

# build train and test datasets
index <- sample(1:nrow(crime_1),round(0.75*nrow(crime_1))) 
train <- crime_1[index,]
test <- crime_1[-index,]
# fit model
crime.lda_2 <- lda(crime_compare ~ clrprc1+clrprc2+d78, data=train, na.action="na.omit")
crime.qda_2 <- qda(crime_compare ~ clrprc1+clrprc2+d78, data=train, na.action="na.omit")
# predict on test dataset
pr.lda <- predict(crime.lda_2,test[,4:6])
pr.qda <- predict(crime.qda_2,test[,4:6])
	# turn result to integer
	pr.lda_class <- as.integer(pr.lda$class)
	pr.qda_class <- as.integer(pr.qda$class)
# caculate MSE
MSE.lda <- sum((test$crime_compare - pr.lda_class)^2)/nrow(test)
MSE.qda <- sum((test$crime_compare - pr.qda_class)^2)/nrow(test)

print(paste(MSE.lda,MSE.qda))

## Comment: 
	# From the result of MSE - 1.54 for LDA and 1.46 for QDA we may conclude that QDA performs better


#####################
## Problem 3.3 - kNN
#####################

set.seed(100)
library(class)

# build train and test datasets
train <- crime_1[index,c(4:6,14)]
test <- crime_1[-index,c(4:6,14)]
# fit model, predict and see MSE
pr.knn <- knn(train,test,train$crime_compare, k = 1)
table(pr.knn,test$crime_compare)
pr.knn_class <- as.integer(pr.knn)
MSE.knn_0 <- sum((test$crime_compare - pr.knn_class)^2)/nrow(test)
MSE.knn_0

# try to find the minimum MSE
MSE.knn <- rep(0, 10)
k <- 1:10
for(x in k){
	pr.knn <- knn(train,test,train$crime_compare, k = x)
	pr.knn_class <- as.integer(pr.knn)
	MSE.knn[x] <- sum((test$crime_compare - pr.knn_class)^2)/nrow(test)
}
plot(k, MSE.knn, type = 'b')
## Comment: From the plotted graph we can see that the MSE is still minimized at k=1, so we choose k=1 in this case

print(paste(MSE.lda,MSE.qda,MSE.knn_0))
## Comment: we can see that the MSE for kNN with k set at 1 is 1.27, which is much less that of LDA and QDA


##################################################
### Problem 5
##################################################

smoke <- read.table("smoke.txt")

smoke_1 <- smoke %>%
	dplyr::mutate(faminc = V1, cigtax = V2, cigprice = V3, bwght = V4, fatheduc = V5, motheduc = V6, parity = V7, male = V8, white = V9, cigs = V10, lbwght = V11, bwghtlbs = V12, packs = V13, lfaminc = V14) %>%
	dplyr::select(faminc, cigtax, cigprice, bwght, fatheduc, motheduc, parity, male, white, cigs, lbwght, bwghtlbs, packs, lfaminc) %>%
	dplyr::mutate(smokes = ifelse(cigs>0,1,0), motheduc = as.integer(motheduc))

smoke_16 <- smoke_1 %>% mutate(lfaminc = mean(lfaminc, na.rm = T), motheduc = 16)
smoke_12 <- smoke_1 %>% mutate(lfaminc = mean(lfaminc, na.rm = T), motheduc = 12)

  
#####################
## Problem 5.1
#####################
smoke_preg.probit <- glm(smokes ~ motheduc + lfaminc, family = binomial(link = "probit"), data = smoke_1)

p_edu16 <- smoke_preg.probit$coeff[1] + smoke_preg.probit$coeff[3]*mean(smoke_1$lfaminc) + smoke_preg.probit$coeff[2]*16
p_edu12 <- smoke_preg.probit$coeff[1] + smoke_preg.probit$coeff[3]*mean(smoke_1$lfaminc) + smoke_preg.probit$coeff[2]*12

p_edu16 <- predict(smoke_preg.probit,smoke_16)
p_edu12 <- predict(smoke_preg.probit,smoke_16)

mean(p_edu16 - p_edu12)




