# if you have AIC, want to minimize it

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

cat("/014")

install.packages('')

install.packages("quantmod") 
install.packages("xts")
install.packages("tseries")
install.packages("dynlm")

library(quantmod) 
library(xts)
library(tseries)
library(dynlm)

# Part 1
getSymbols("INDPRO",src="FRED")
summary()
plot(INDPRO$INDPRO)
# time index
INDPRO$t <- c(1:dim(INDPRO)[1])
# log output
INDPRO$LPRO <- log(INDPRO$INDPRO)
	# lag for 15 periods


# Part 2 Info criterion

AIC <- NULL
BIC <- NULL

fit <- lm(LPRO ~ t + LLPRO + DLPRO + DLPRO1, data=INDPRO)
AIC[1] <- AIC(fit)
BIC[1] <- BIC(fit)

fit <- lm(LPRO ~ t + LLPRO + DLPRO + DLPRO1 + DLPRO1, data=INDPRO)
AIC[2] <- AIC(fit)
BIC[2] <- BIC(fit)
	# Do this for another 15 years

plot(AIC, type="1")
lines(BIC, col="blue")
abline(h=min(AIC),col="red")
abline(h=min(BIC),col="red") # 27'

	# the best model of 10 lags

# Part 3 - Dickey and Fuller

fit <- lm(LPRO ~ t + LLPRO + DLPRO + DLPRO1 + DLPRO1 + ... + DLPRO10, data=INDPRO)
summary(fit)

DF = summary(fit)$coefficient[3,1]/summary(fit)$coefficient[3,2] # -2.5983 can't reject null of unit root - stationary

adf.test(INDPRO$LPRO)


## (VI)

library(reshape)

# Part 1 - Data
getSymbols("CPIAUCSL",src="FRED")

CPIAUCSL <- rename(CPIAUCSL,c("CPIAUCSL" = "CPI"))
summary(CPIAUCSL)
plot(CPIAUCSL$CPI)
	# lag the variables
CPIAUCSL <- na.omit(CPIAUCSL)
CPIAUCSL <- CPIAUCSL["1974-01-01/"]
CPIAUCSL$t <- c(1:dim(CPIAUCSL)[1])
CPIAUCSL$CPI <- log(CPIAUCSL$CPI)

# use for loop for AIC, BIC, 8 is the optimal DF = -2.0177

fit <- lm(D.CPI ~ t + L.CPI + D.CPI1 + D.CPI2 + D.CPI3 + ... + + D.CPI8, data=CPIAUCSL)
DF = summary(fit)$coefficient[3,1]/summary(fit)$coefficient[3,2] 










