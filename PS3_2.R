##################################################
# Startup
##################################################

# set up useful functions 
`%S%` <- function(x, y) {
  paste0(x, y)
}

`%notin%` <- Negate(`%in%`)

# include libraries
library(readr)
library(tidyr)
library(dplyr)
library(pryr)
 # library(plyr)
library(knitr)
library(stringr)
library(ggplot2)

setwd('/Users/elmerleezy/Google Drive/Wagner/Semester 4/Applied Stats & Econo II/Prob Sets/PS3')
crime <- read.table("crime.txt")

##################################################
### Problem 3
##################################################

crime_1 <- crime %>%
  mutate(district = V1, year = V2, crime = V3, clrprc1 = V4, clrprc2 = V5, d78 = V6, avgclr = V7, lcrime = V8, clcrime = V9, cavgclr = V10, cclrprc1 = V11, cclrprc2 = V12) %>%
  select(district,year,crime,clrprc1,clrprc2,d78,avgclr,lcrime,clcrime,cavgclr,cclrprc1,cclrprc2) %>%
  mutate(crime_mean = mean(crime, na.rm = T), crime_compare = ifelse(crime > crime_mean, 1, 0))

#####################
## Problem 3.1 - LDA
#####################

library(MASS)
crime.lda <- lda(crime_compare ~ d78+clrprc1+clrprc2, data=crime_1, na.action="na.omit", CV=TRUE)
crime.lda # show result

#####################
## Problem 3.2 - QDA
#####################

crime.qda <- qda(crime_compare ~ d78+clrprc1+clrprc2, data=crime_1, na.action="na.omit", CV=TRUE)

# Compare - method 1: the build in cross-validation function in LDA and QDA
table(crime_1$crime_compare, crime.lda$class, dnn = c('Actual Group','Predicted Group'))
table(crime_1$crime_compare, crime.qda$class, dnn = c('Actual Group','Predicted Group'))

# Compare - method 2: manul cross validation and compare MSE

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
MSE.knn <- sum((test$crime_compare - pr.knn_class)^2)/nrow(test)

# try to find the minimum MSE
MSE.knn <- rep(0, 10)
k <- 1:10
for(x in k){
	pr.knn <- knn(train,test,train$crime_compare, k = x)
	pr.knn_class <- as.integer(pr.knn)
	MSE.knn[x] <- sum((test$crime_compare - pr.knn_class)^2)/nrow(test)
}

plot(k, MSE.knn, type = 'b')
	# so the MSE is still minimized at k=1

print(paste(MSE.lda,MSE.qda,MSE.knn))


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
smoke_preg.probit <- glm(smokes ~ motheduc + lfaminc, family = binomial(link = "probit"), data = smoke_1)

install.packages("mfx") #Do this only once
library(mfx)

p_edu16 <- smoke_preg.probit$coeff[1] + smoke_preg.probit$coeff[3]*mean(smoke_1$lfaminc) + smoke_preg.probit$coeff[2]*16
p_edu12 <- smoke_preg.probit$coeff[1] + smoke_preg.probit$coeff[3]*mean(smoke_1$lfaminc) + smoke_preg.probit$coeff[2]*12

p_edu16 - p_edu12




