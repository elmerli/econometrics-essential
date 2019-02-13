###############################################################################
## Get Data from FRED
###############################################################################

source("/Users/zongyangli/Documents/Github/R-Key-functions/Start up.R")
install.packages('quantmod')
library(quantmod)

# Get the data

getSymbols('PCE', src = "FRED") # personal consumption expenditure 
getSymbols('GDP', src = "FRED") # GDP
getSymbols('GPDI', src = "FRED") # Gross private domestic investment
getSymbols('GEXPND', src = "FRED") # Government current expenditure

getSymbols('DPCERE1Q156NBEA', src = "FRED") # Consumption/GDP
getSymbols('A006RE1Q156NBEA', src = "FRED") # Private Investment/GDP
getSymbols('A822RE1A156NBEA', src = "FRED") # Gov expenditure + Private Investment/GDP
getSymbols('LABSHPUSA156NRUG', src = "FRED") # Share of labor compensation in GDP

getSymbols('A939RX0Q048SBEA', src = "FRED") # GDP per capita
getSymbols('A794RC0Q052SBEA', src = "FRED") # Personal consuption per capita
getSymbols('UNRATE', src = "FRED") # Unemployment rate
getSymbols('UEMPMEAN', src = "FRED") # Duration of Unemployment

