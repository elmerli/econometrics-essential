
capture log close
log using "PS1", text replace
/****************************************************************************
Author:         Zongyang (Elmer) Li
Date Created:   2019 Feb 05
Project:        PS 1
****************************************************************************/

clear all
prog drop _all
set more off

cd "/Users/zongyangli/Documents/GitHub/econometrics-essential/Econometrics PhD II/PS1"
log using "/Users/zongyangli/Documents/GitHub/econometrics-essential/Econometrics PhD II/PS1/PS1.log", replace

/*** Import data ***/
import excel "/Users/zongyangli/Documents/GitHub/econometrics-essential/Econometrics PhD II/PS1/grilic.xls", firstrow clear /* stringcols(2 6) numericcols(7(1)85) */


********************************************************************************
* Q1 Summary Statistics
*****

ssc install asdoc
set more off
asdoc sum AGE S S80 LW LW80 KWW IQ EXPR EXPR80 MRT MRT80 MED SMSA SMSA80 RNS RNS80, stat(N mean sd) dec(1) save(sum_stat) replace
asdoc sum AGE S S80 LW LW80 KWW IQ EXPR EXPR80 MRT MRT80 MED SMSA SMSA80 RNS RNS80 if YEAR > 69, stat(N mean sd) title(After 69) save(sum_stat_69) replace
asdoc cor S IQ, title(Correlation) save(sum_stat_corr) replace


********************************************************************************
* Q2-3
*****
ssc install ivreg2

/*** Replicate Table 3.2 Hayashi ***/

* line 1 - without IQ
set more off
xi: reg LW S EXPR TENURE RNS SMSA i.YEAR MED KWW AGE MRT
outreg2 using rep_table_3.xls, replace dec(3) pdec(3)

* line 2 - with IQ
xi: reg LW S IQ EXPR TENURE RNS SMSA i.YEAR MED KWW AGE MRT
outreg2 using rep_table_3.xls, append dec(3) pdec(3)

* line 3 - instrumental variable apporach
set more off
ivreg2 LW S EXPR TENURE RNS SMSA i.YEAR (IQ=MED KWW AGE MRT S EXPR TENURE RNS SMSA i.YEAR), first
outreg2 using rep_table_3.xls, append dec(3) pdec(3)


********************************************************************************
* Q4 2SLS
*****

reg IQ MED KWW AGE MRT S EXPR TENURE RNS SMSA i.YEAR
predict IQ_hat
xi: reg LW IQ_hat S EXPR TENURE RNS SMSA i.YEAR


********************************************************************************
* Q5 2SLS with both IQ and S as endogeneous
*****

set more off
ivreg2 LW EXPR TENURE RNS SMSA i.YEAR (IQ S =MED KWW AGE MRT S EXPR TENURE RNS SMSA i.YEAR)
outreg2 using rep_table_4.xls, append dec(3) pdec(3)


********************************************************************************
* Q6 GMM estimation
*****

set more off
ivregress gmm LW EXPR TENURE RNS SMSA i.YEAR (S IQ=MED KWW MRT AGE)
estat endogenous S

********************************************************************************
* Q7
*****

ivreg2 LW EXPR TENURE RNS SMSA i.YEAR ( S IQ= MRT AGE)









