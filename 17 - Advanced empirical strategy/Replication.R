setwd ("/Users/elmerleezy/Google Drive/Wagner/????????????/Advan Empirical Method/Problem Sets/Replication/Data")


# set up useful functions 
`%S%` <- function(x, y) {
  paste0(x, y)
}

`%notin%` <- Negate(`%in%`)

# include libraries

package_list <- c("readr", "tidyr", "dplyr","pryr","plyr", "knitr", "stringr", "ggplot2","tidyverse","haven")
new_packages <- package_list[package_list %notin% installed.packages()[,"Package"]]
if(length(new_packages)) install.packages(new_packages)

library(readr)
library(tidyr)
library(dplyr)
library(pryr)
 # library(plyr)
library(knitr)
library(stringr)
# library(ggplot2)
library(tidyverse)
library(haven)

a<-read_dta('usa_00005.dta')

count.missing<-data.frame(sapply(a, function(x) sum(is.na(x))))

main_sample <- a %>%
	filter(race ==1,sex == 2 ,age >= 21 & age <= 40,agemarr >=17 & agemarr <= 26 ,bpl < 110 ,marrno >= 1 ,chborn >= 2)


