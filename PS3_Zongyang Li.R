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
  dplyr::mutate(district = V1, year = V2, crime = V3, clrprc1 = V4, clrprc2 = V5, d78 = V6, avgclr = V7, lcrime = V8, clcrime = V9, cavgclr = V10, cclrprc1 = V11, cclrprc2 = V12) %>%
  dplyr::select(district,year,crime,clrprc1,clrprc2,d78,avgclr,lcrime,clcrime,cavgclr,cclrprc1,cclrprc2) %>%
  dplyr::mutate(crime_mean = mean(crime, na.rm = T), crime_compare = ifelse(crime > crime_mean, 1, 0))

train = subset(crime_1, d78<1)
test = subset(crime_1, d78>0)

#####################
## Problem 3.1 - LDA
#####################

library(MASS)
crime.lda <- lda(crime_compare ~ clrprc1+clrprc2, data=train, na.action="na.omit")
pr.lda <- predict(crime.lda,newdata = test) 
## Show result as a table
table(train$crime_compare, pr.lda$class, dnn = c('Actual','Predicted LDA')) 

#####################
## Problem 3.2 - QDA
#####################

crime.qda <- qda(crime_compare ~ clrprc1+clrprc2, data=train, na.action="na.omit")

## Compare - Method 1: the build in cross-validation function in LDA and QDA

crime.lda_cv <- lda(crime_compare ~ clrprc1+clrprc2, data=train, na.action="na.omit",CV = TRUE)
crime.qda_cv <- qda(crime_compare ~ clrprc1+clrprc2, data=train, na.action="na.omit",CV = TRUE)
	# cmt: CV=TRUE generates leave-one-out cross validation.
table(train$crime_compare, crime.lda_cv$class, dnn = c('Actual Group','Predicted LDA'))
table(train$crime_compare, crime.qda_cv$class, dnn = c('Actual Group','Predicted QDA'))

## Comment: 
	# from the ouput table we can see very obviously that QDA did a better job at predicting since there are
	# more groups predicted right by QDA. 

## Compare - Method 2: manul cross validation and compare MSE

# build train and test datasets
	# index <- sample(1:nrow(crime_1),round(0.75*nrow(crime_1))) 
	# train <- crime_1[index,]
	# test <- crime_1[-index,]
# fit model
	# crime.lda_2 <- lda(crime_compare ~ clrprc1+clrprc2+d78, data=train, na.action="na.omit")
	# crime.qda_2 <- qda(crime_compare ~ clrprc1+clrprc2+d78, data=train, na.action="na.omit")
# predict on test dataset
		# pr.lda <- predict(crime.lda_2,test[,4:6])
		# pr.qda <- predict(crime.qda_2,test[,4:6])
	pr.qda <- predict(crime.qda,newdata = test)
	# turn result to integer
	pr.lda_class <- as.integer(pr.lda$class)
	pr.qda_class <- as.integer(pr.qda$class)
# caculate MSE
MSE.lda <- sum((test$crime_compare - pr.lda_class)^2)/nrow(test)
MSE.qda <- sum((test$crime_compare - pr.qda_class)^2)/nrow(test)

print(paste(MSE.lda,MSE.qda))

## Comment: 
	# From the result of MSE - 1.21 for LDA and 1.11 for QDA we may conclude that QDA performs better


#####################
## Problem 3.3 - kNN
#####################

set.seed(100)
library(class)

# build train and test datasets
knntrain <- train[,c(4:5,14)]
knntest <- test[,c(4:5,14)]
# fit model, predict and see MSE
pr.knn <- knn(knntrain,knntest,knntrain$crime_compare, k = 1)
table(pr.knn,knntest$crime_compare)
pr.knn_class <- as.integer(pr.knn)
MSE.knn_0 <- sum((knntest$crime_compare - pr.knn_class)^2)/nrow(knntest)
MSE.knn_0

# try to find the minimum MSE
MSE.knn <- rep(0, 20)
k <- 1:20
for(x in k){
	pr.knn <- knn(knntrain,knntest,knntrain$crime_compare, k = x)
	pr.knn_class <- as.integer(pr.knn)
	MSE.knn[x] <- sum((knntest$crime_compare - pr.knn_class)^2)/nrow(knntest)
}
plot(k, MSE.knn, type = 'b')
## Comment: From the plotted graph we can see that the MSE is minimized at k=9, so we choose k=9 in this case

pr.knn <- knn(knntrain,knntest,knntrain$crime_compare, k = 9)
table(pr.knn,knntest$crime_compare)
pr.knn_class <- as.integer(pr.knn)
MSE.knn <- sum((knntest$crime_compare - pr.knn_class)^2)/nrow(knntest)
MSE.knn

print(paste(MSE.lda,MSE.qda,MSE.knn))
## Comment: we can see that the MSE for kNN with k set at 1 is 1.19, which less than LDA but more than QDA


##################################################
### Problem 5
##################################################

smoke <- read.table("smoke.txt")

smoke_1 <- smoke %>%
	dplyr::mutate(faminc = V1, cigtax = V2, cigprice = V3, bwght = V4, fatheduc = V5, motheduc = V6, parity = V7, male = V8, white = V9, cigs = V10, lbwght = V11, bwghtlbs = V12, packs = V13, lfaminc = V14) %>%
	dplyr::select(faminc, cigtax, cigprice, bwght, fatheduc, motheduc, parity, male, white, cigs, lbwght, bwghtlbs, packs, lfaminc) %>%
	dplyr::mutate(smokes = ifelse(cigs>0,1,0), motheduc = as.integer(motheduc))

#####################
## Problem 5.1
#####################

# first run regression
smoke_preg.probit <- glm(smokes ~ motheduc + lfaminc, family = binomial(link = "probit"), data = smoke_1)
# create two new datasets with faminc at the mean and different education years
smoke_16 <- smoke_1 %>% mutate(lfaminc = mean(lfaminc, na.rm = T), motheduc = 16)
smoke_12 <- smoke_1 %>% mutate(lfaminc = mean(lfaminc, na.rm = T), motheduc = 12)
# predict the dependent
p_edu16 <- predict(smoke_preg.probit,smoke_16)
p_edu12 <- predict(smoke_preg.probit,smoke_16)

mean(p_edu16 - p_edu12) # result: -0.05189609

## Comment: the estimated difference in possiblity of smoking is 5.1 percentage points less for a woman 
	# with 16 years of education and 12 years

#####################
## Problem 5.2
#####################

summary(smoke_preg.probit)

## Comment: 
	# faminc is not very likely to be exogeneous in this equation since there are factors that impact both income level 
	# and smoking, such as previous health habits(eating habits etc.) which will influcence both one's income and possibility to smoke

	# motheredu isn't likely to be exogeneous since education is so correlated to income and there is likely to be other
	# unobservables that might influence both motheredu and smoke

#####################
## Problem 5.3
#####################

install.packages('systemfit')

form1 <- smokes ~ motheduc
form2 <- smokes ~ motheduc + lfaminc
inst <- ~ male + white
system <- list(form1, form2)

## perform the estimations
fit2sls <- systemfit( system, "2SLS", inst = inst, data = smoke_1 )
fit3sls <- systemfit( system, "3SLS", inst = inst, data = smoke_1 )

## perform the Hausman test
h <- hausman.systemfit( fit2sls, fit3sls )
print( h )

## Comment: 
	# from the p-value of the Huasman test statistic - 0.78 is higher than any standard, we fail reject the null hypothesis that log-faminc in exogeneous

