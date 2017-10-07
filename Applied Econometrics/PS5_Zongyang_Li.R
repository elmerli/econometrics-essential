##################################################
# Prepare
##################################################

install.packages('PerformanceAnalytics')
install.packages('quantmod')
install.packages('rugarch')
install.packages('car')
install.packages('FinTS')
install.packages("tsDyn")

library(tidyr)
library(dplyr)
library(knitr)
library(tidyverse)
library(readxl)
library(PerformanceAnalytics)
library(quantmod)
library(rugarch)
library(car)
library(FinTS)
library(tsDyn)

##################################################
# II
##################################################

setwd('/Users/elmerleezy/Google Drive/Wagner/Semester 4/Applied Stats & Econo II/Prob Sets/PS4')
setwd("C:/Users/zyl220/Downloads")

# Read Data
paribas <- read_excel("C:/Users/zyl220/Downloads/paribas.xlsx", sheet = "Hoja1")
# Standardise date
paribas$date2 <- as.Date(paribas$date)
paribas = na.omit(xts(paribas$price, order.by = paribas$date2))

##########################
## 1
##########################
# Calculate returns
returns = na.omit(periodReturn(paribas, period = 'daily', leading = F))
min(returns)
summary(returns)

## Comment: 
	# There seem to be no terrible error except for about 50 missing values
	# From the summary statistics, we can see the max return is 0.2076996, min is -0.1724534, mean is 0.0004842 
	# which all makes sense

##########################
## 2
##########################

# Specify GARCH(1,1) model 
garch11.spec = ugarchspec(variance.model = list(garchOrder=c(1,1)), mean.model = list(armaOrder=c(0,0))) # Estimate GARCH(1,1) model
paribas.garch11.fit = ugarchfit(spec=garch11.spec, data=returns, solver.control=list(trace = 1))
## Calculate anualized volatility
plot.ts(sqrt(252)*sigma(paribas.garch11.fit), ylab="Anualized Volatility", col="blue") # sigma(t) = conditional volatility

##########################
## 3
##########################

# Show GARCH fit summary - See Weighted Ljung-Box Test on Standardized Residuals
paribas.garch11.fit
# Plot residuals 
plot.ts(residuals(paribas.garch11.fit), ylab="e(t)", col="blue")
abline(h=0)

## Comment: 
	# The Ljung-Box Test is for autocorrelation. From the p-value: 0.691167, we fail to reject 
	# the null hypothesis that there is no autocorrelation
	# From the plot of the residuals we see that there is no evidence of heteroskedasticity

##########################
## 4
##########################

# See GARCH(2,1) model 
garch11.spec = ugarchspec(variance.model = list(garchOrder=c(2,1)), mean.model = list(armaOrder=c(0,0))) 
paribas.garch21.fit = ugarchfit(spec=garch11.spec, data=returns, solver.control=list(trace = 1)) 
paribas.garch21.fit

# See GARCH(1,2) model 
garch11.spec = ugarchspec(variance.model = list(garchOrder=c(1,2)), mean.model = list(armaOrder=c(0,0)))
paribas.garch12.fit = ugarchfit(spec=garch11.spec, data=returns, solver.control=list(trace = 1))  
paribas.garch12.fit

## Comment: 
	# The AIC for GARCH(1,1) is -4.9799, for GARCH(2,1) is -4.9794, for GARCH(1,2) is -4.9795
	# Even though GARCH(1,1) is only a little better than the other two based on AIC, 
	# we consider it to be better specified

##################################################
# III
##################################################

##Getting data
getSymbols("GS1", src = "FRED")
GS1 <- GS1["1968-10-01/2015-10-01"]
getSymbols("GS10", src = "FRED")
GS10 <- GS10["1968-10-01/2015-10-01"]

##########################
## 1
##########################

# Detest Cointegration with Johansen Test
test_johansen = ca.jo(data.frame(GS1,GS10),type="trace", K=3, ecdet="none", spec="longrun")
summary(test_johansen)

## Comment: 
	# The Johansen test static for r = 0 is 26.01, higher than all the critial values at 1% 5% and 10%
	# then we conclude that there is a cointegration of these 2 time series

##########################
## 2 & 3
##########################

threshold <- GS10-GS1
setarTest(GS1,m=1,thDelay = 0:threshold)
setarTest(GS10,m=1,thDelay = 0:threshold)

## Comment: 
	# There is likely to be a thresold but no evidence of thresold cointegration

