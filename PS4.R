##################################################
# Startup
##################################################

# Install useful functions
install.packages("quantmod") 
install.packages("xts")
install.packages("tseries")
install.packages("dynlm")

`%S%` <- function(x, y) {
  paste0(x, y)
}
# Include libraries
library(readr)
library(tidyr)
library(dplyr)
library(pryr)
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

# Lag difference in lag output
INDPRO <- data.frame(INDPRO)
for(i in 1:15) {
  DLPROlag <- 'DLPRO' %S% i
  INDPRO[[DLPROlag]] <- lag(INDPRO$DLPRO,i)
}

# Info criterion & Run regressions with different lags 
fit01 <- lm(LPRO ~ t + LLPRO + DLPRO + DLPRO1, data=INDPRO)
var <- paste0(colnames(INDPRO[,3:5]),sep = " + ")
fit01 <- lm(LPRO ~  paste0(colnames(INDPRO[,3:5]), sep = " + ") t, data=INDPRO)

colnames(INDPRO[,2:5])
paste0(colnames(INDPRO[,2:5]), sep = " + ")

fit02 <- lm(LPRO ~ t + LLPRO + DLPRO + DLPRO1 + DLPRO2, data=INDPRO)
fit03 <- lm(LPRO ~ t + LLPRO + DLPRO + DLPRO1 + DLPRO2 + DLPRO3, data=INDPRO)

AIC <- NULL
BIC <- NULL

for(i in 1:3) {
  fit <- 'fit' %S% i
  INDPRO[[DLPROlag]] <- lag(INDPRO$DLPRO,i)
}


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










