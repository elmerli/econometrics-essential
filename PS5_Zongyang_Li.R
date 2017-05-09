##################################################
# Prepare
##################################################

install.packages('PerformanceAnalytics')
install.packages('quantmod')
install.packages('rugarch')
install.packages('car')
install.packages('FinTS')

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

##################################################
# II
##################################################

setwd('/Users/elmerleezy/Google Drive/Wagner/Semester 4/Applied Stats & Econo II/Prob Sets/PS4')
setwd("C:/Users/zyl220/Downloads")

paribas <- read_excel("C:/Users/zyl220/Downloads/paribas.xlsx", sheet = "Hoja1")
paribas <- as.matrix(paribas)

paribas$date2 <- as.Date(paribas$date)
paribas = na.omit(xts(paribas$price, order.by = paribas$date2))

returns = na.omit(periodReturn(paribas, period = 'daily', leading = F))
min(returns)

# paribas_1 <- paribas %>% mutate(return = Delt(V1)) %>% dplyr::select(return) %>% dplyr::filter(!is.na(return))


##  Estimate GARCH(1,1)

# specify GARCH(1,1) model with only constant in mean equation
garch11.spec = ugarchspec(variance.model = list(garchOrder=c(1,1)), 
                          mean.model = list(armaOrder=c(0,0)))
paribas.garch11.fit = ugarchfit(spec=garch11.spec, data=returns,
                             solver.control=list(trace = 1))                          
class(paribas.garch11.fit)
slotNames(paribas.garch11.fit)
names(paribas.garch11.fit@fit)
names(paribas.garch11.fit@model)

# show garch fit
paribas.garch11.fit

paribas$return = diff(paribas$price)/paribas$price

paribas$return = Delt(paribas$price)
