##################################################
# Prepare
##################################################

library(tidyr)
library(dplyr)
library(knitr)
library(tidyverse)
library(readxl)
require(quantmod)
install.packages('quantmod')

##################################################
# II
##################################################

setwd('/Users/elmerleezy/Google Drive/Wagner/Semester 4/Applied Stats & Econo II/Prob Sets/PS4')
setwd("C:/Users/zyl220/Downloads")

paribas <- read_excel("C:/Users/zyl220/Downloads/paribas.xlsx", sheet = "Hoja1")

paribas_1 <- paribas %>%
	mutate(return = Delt(price))

paribas$return = diff(paribas$price)/paribas$price

paribas$return = Delt(paribas$price)
