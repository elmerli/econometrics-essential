******************************************************************************
******************************************************************************
*****
*****     AEM PS 5
*****
******************************************************************************
******************************************************************************


*******************
*  Startup
*******************

clear all
set more off
cd "/Users/elmerleezy/Google Drive/Wagner/第三学期/Advan Empirical Method/Problem Sets/PS5"
use "DinD_ex.dta", clear

** 1
ttest fte if nj==1, by(after)
ttest fte if nj==0, by(after)

** 2
reg dfte nj
reg dfte nj, robust

** 3
reg fte nj after njafter
reg fte nj after njafter, robust

** 4
reg fte nj after njafter, cluster(sheet)

** 5

xtreg fte nj after njafter, i(sheet) fe robust

** 8
use "safesave_slim_data.dta", clear
 * first create scatter plot
gen post = 1 if monthyear>=200002
replace post = 0 if post ==.

bysort trend: egen GE_pre=mean(loanbal) if TIKA == 0 & post ==0 
bysort trend: egen GE_post = mean(loanbal) if TIKA == 0 & post ==1
bysort trend: egen TIKA_pre = mean(loanbal) if TIKA == 1 & post ==0
bysort trend: egen TIKA_post = mean(loanbal) if TIKA == 1 & post ==1
bysort trend: egen average_GE = mean(loanbal) if TIKA == 0 
bysort trend: egen average_TIKA = mean(loanbal) if TIKA == 1 

twoway connected average_TIKA average_GE trend || lfit GE_pre trend || lfit TIKA_pre trend || lfit GE_post trend || lfit TIKA_post trend

 * test the parallel assumption
keep if monthyear <= 200002
* gen trend_2 = trend*trend
* gen trend_tika = trend*TIKA
* gen trend_2_tika = trend_2*TIKA
 * test if in regression
keep if TIKA == 0
regress loanbal trend, robust

use "safesave_slim_data.dta", clear
keep if monthyear < 200002
keep if TIKA == 1
regress loanbal trend, robust


 * see the trend of control group pre-post
use "safesave_slim_data.dta", clear
keep if TIKA == 0
gen post = 1 if monthyear>=200002
replace post = 0 if post ==.
regress loanbal trend if post ==0
regress loanbal trend if post ==1
regress loanbal trend post

 * add covariates
use "safesave_slim_data.dta", clear
keep if monthyear < 200001

gen monyr_2 = monthyear*monthyear
gen monyr_tika = monthyear*TIKA
gen monyr_2_tika = monyr_2*TIKA
regress loanbal monthyear monyr_2 monyr_tika monyr_2_tika tinpr nage, robust

use "safesave_slim_data.dta", clear
keep if monthyear <= 200002
gen trend_2 = trend*trend
gen trend_tika = trend*TIKA
gen trend_2_tika = trend_2*TIKA

regress loanbal trend  trend_tika, robust
regress loanbal trend  trend_tika tinpr nage, robust



