##################################################
# Startup
##################################################

# Install useful functions
install.packages("quantmod") 
install.packages("xts")
install.packages("tseries")
install.packages("dynlm")
install.packages("reshape")

`%S%` <- function(x, y) {
  paste0(x, y)
}
# Include libraries
library(readr)
library(tidyr)
library(dplyr)
library(pryr)
library(stringr)
library(quantmod) 
library(xts)
library(tseries)
library(dynlm)

setwd('/Users/elmerleezy/Google Drive/Wagner/Semester 4/Applied Stats & Econo II/Prob Sets/PS4')

################################################
# Problem IV
################################################

# Get data
	getSymbols("INDPRO",src="FRED")
	plot(INDPRO$INDPRO) 

# Create useful variables
INDPRO$t <- c(1:dim(INDPRO)[1]) # time indicator
INDPRO$LPRO <- log(INDPRO$INDPRO) # log output
INDPRO$LLPRO <- lag(INDPRO$LPRO,1) # lag output by 1 period
INDPRO$DLPRO <- diff(INDPRO$LPRO) # difference in lag output

# Create lags of difference in log output
INDPRO <- data.frame(INDPRO)
for(i in 1:15) {
  DLPROlag <- 'DLPRO' %S% i
  INDPRO[[DLPROlag]] <- lag(INDPRO$DLPRO,i)
}

##########################
## 2
##########################
# Info criterion & Run regressions with different lags 
AIC <- NULL
BIC <- NULL

for(i in 6:20) {
	index2 = i-5
	var <- paste0(colnames(INDPRO[,6:i]), collapse = '', sep = " + ")
	formula <- str_interp("LPRO ~ LLPRO + DLPRO + ${var} t")
	fit <- lm(formula, data=INDPRO)
	AIC[index2] <- AIC(fit)
	BIC[index2] <- BIC(fit)
}
	# Graph the info criteria results
	plot(BIC, type="l")
	lines(AIC, col="blue")
	abline(h=min(AIC),col="red")
	abline(h=min(BIC),col="red") 
	# From the graph - the best model of 12 lags

## Comment: 
	# To decide the best number of lags that we will include in the model, we will use information criterion 
	# Bayesian information criterion and Akaike information criterion; These two criterion take a balance between
	# increase the likelihood by adding parameters, also penalize number of parameters included which may overfit
	# We see from the above graph result that the most optimal lags to be included is 12, since with 12 lags, BIC and AIC
	# are minimized: BIC = -82292.43; AIC = -82378.48

##########################
## 3 & 4
##########################
# Dickey - Fuller test

# Use 12 lags to build function
fit <- lm(LPRO ~ t + LLPRO + DLPRO + DLPRO1 + DLPRO2 + DLPRO3 + DLPRO4 + DLPRO5 + DLPRO6 + DLPRO7 + DLPRO8 + DLPRO9 + DLPRO10 + DLPRO11 + DLPRO12, data=INDPRO)
summary(fit)
# DF test statistic
DF = summary(fit)$coefficient[3,1]/summary(fit)$coefficient[3,2] # -2.7231 
adf.test(INDPRO$LPRO)

## Comment: 
	# From the Dickey Fuller Test statistic -2.7231 and p-value of 0.2722, we can't reject null of unit root 
	# Thus there is evidence that the output has a unit root


################################################
# Problem V
################################################

alcoa <- read.csv("arnc.csv")
alcoa$t <- c(1:dim(alcoa)[1])
alcoa$lprice <- log(alcoa$Close) # log price
alcoa$llprice <- lag(alcoa$lprice,1) # lag log price
# alcoa <- na.omit(alcoa)

# Create lags of difference in log price
alcoa <- data.frame(alcoa)
for(i in 1:10) {
  llprice_lag <- 'llprice_' %S% i
  alcoa[[llprice_lag]] <- lag(alcoa$llprice,i)
}

## Regress use 5/10 lags 

fit_5 <- lm(lprice ~ t + llprice_1 + llprice_2 + llprice_3 + llprice_4 + llprice_5, data=alcoa)
summary(fit_5)
DF_5 = summary(fit_5)$coefficient[3,1]/summary(fit_5)$coefficient[3,2] # 64.45807


fit_10 <- lm(lprice ~ t + llprice_1 + llprice_2 + llprice_3 + llprice_4 + llprice_5 + llprice_6 + llprice_7 + llprice_8 + llprice_9 + llprice_10, data=alcoa)
summary(fit_10)
DF_10 = summary(fit_10)$coefficient[3,1]/summary(fit_10)$coefficient[3,2] # 64.54117 

## Comment: 
	# From the Dickey Fuller Test statistic: 64.45807 for 5 lags of log return and 64.54117 for 10 lags 
	# these valus are greater than any of the Critical Values for the Dickey-Fuller Unit Root t-Test Statistics
	# So we reject the null and conclude that both functions are stationary and thus the return can be predicted


################################################
# Problem VI
################################################

# Get data
library(reshape)
getSymbols("CPIAUCSL",src="FRED")
summary(CPIAUCSL)
plot(CPIAUCSL$CPI)

# Generate useful variables
CPIAUCSL <- rename(CPIAUCSL,c("CPIAUCSL" = "CPI"))
CPIAUCSL <- na.omit(CPIAUCSL)
CPIAUCSL <- CPIAUCSL["1974-01-01/"]
CPIAUCSL$t <- c(1:dim(CPIAUCSL)[1])
CPIAUCSL$CPI <- log(CPIAUCSL$CPI)
CPIAUCSL$L.CPI = lag(CPIAUCSL$CPI,1)
CPIAUCSL$D.CPI = diff(CPIAUCSL$CPI,1)

# Create lags of difference in log output
CPIAUCSL <- data.frame(CPIAUCSL)
for(i in 1:15) {
  DCPIlag <- 'D.CPI' %S% i
  CPIAUCSL[[DCPIlag]] <- lag(CPIAUCSL$D.CPI,i)
}

# Calculate AIC & BIC
AIC <- NULL
BIC <- NULL

for(i in 5:19) {
	index2 = i-4
	var <- paste0(colnames(CPIAUCSL[,5:i]), collapse = '', sep = " + ")
	formula <- str_interp("D.CPI ~ L.CPI + ${var} t")
	fit <- lm(formula, data=CPIAUCSL)
	AIC[index2] <- AIC(fit)
	BIC[index2] <- BIC(fit)
}
	# Graph AIC BIC results
	plot(BIC, type="l")
	lines(AIC, col="blue")
	abline(h=min(AIC),col="red")
	abline(h=min(BIC),col="red") 
	# From the graph - the best model of 8 lags

fit <- lm(D.CPI ~ L.CPI + D.CPI1 + D.CPI2 + D.CPI3 + D.CPI4 + D.CPI5 + D.CPI6 + D.CPI7 + D.CPI8 + t, data=CPIAUCSL)
DF = summary(fit)$coefficient[3,1]/summary(fit)$coefficient[3,2]
adf.test(CPIAUCSL$CPI)

## Comment: 
	# From the Dickey Fuller Test statistic: 12.27013 we reject the null hypothesis and conclude that 
	# there is no unit root and the process is stationary 








