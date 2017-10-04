******************************************************************************
******************************************************************************
*****
*****     AEM PS 1
*****
******************************************************************************
******************************************************************************

*******************
*  Startup
*******************

clear all
cd "/Users/elmerleezy/Google Drive/Wagner/第三学期/Advan Empirical Method/Problem Sets/PS1"
* cd "C:\Users\zyl220\Downloads"
use "Thornton HIV Testing Data.dta", clear
drop if hiv2004==. | hiv2004==-1| any==. | age==. | zone==. | got==. | male==. | site==.| under==. | over==.

******************************************
** Part I:  Summary Statistics **
******************************************

* 1: 
sum age male hiv2004

* 2: 
sum age male hiv2004 educ2004 timeshadsex_s hadsex12 eversex usecondom tb thinktreat a8 land2004 if any ==1
sum age male hiv2004 educ2004 timeshadsex_s hadsex12 eversex usecondom tb thinktreat a8 land2004 if any ==0

sum age male hiv2004 educ2004 timeshadsex_s hadsex12 eversex usecondom tb thinktreat a8 land2004 if under ==1
sum age male hiv2004 educ2004 timeshadsex_s hadsex12 eversex usecondom tb thinktreat a8 land2004 if over ==1

* 3
ttest age, by (any)
ttest hiv2004, by (any)
ttest mar, by (any)

ttest age, by (under)
ttest hiv2004, by (under)
ttest mar, by (under)

******************************************
** Part II:  Analysis Using Graphs **
******************************************

* 4
graph bar got, over(any) ///
ytitle("Percentage Learning HIV Results") b1title("Effects of receiving some incentive") scheme(s1mono) blabel(bar, position(outside))

graph bar got, over(Ti) ///
ytitle("Percentage Learning HIV Results") b1title("Effects of total amount of incentive") scheme(s1mono)

******************************************
** Part III:  Linear Analysis **
******************************************

* 6
regress got any, robust
regress got any age male educ2004 mar, robust

* 7 
* Using ANOVA Test
anova got any 
* Using Difference of Mean
gen got1 =(got==1)  
gen got0 =(got==0) 
gen gotdiff = got1-got0

regress gotdiff any, robust
regress gotdiff any age male educ2004 mar, robust

* 8
regress got tinc, robust
regress got tinc age male educ2004 mar, robust

* 9


******************************************
** Part IV:  Conditional (Heterogeneous) 
** Treatment Effects **
******************************************

* 10
gen anymale = any*male
regress got any male anymale, robust
test any = anymale = 0

* 11
gen anyedu = any*educ2004
regress got any educ2004 anyedu, robust
test any = anyedu = 0 

******************************************
** Part V:  Policy Implication **
******************************************

* 12
* 13

******************************************
** Part VI:  A Random Sub-Sample **
******************************************

* 14 & 15

bsample 1000
regress got any, robust

use "Thornton HIV Testing Data.dta", clear
drop if hiv2004==. | hiv2004==-1| any==. | age==. | zone==. | got==. | male==. | site==.| under==. | over==.

******************************************
** Part VII: Choosing Sample Size **
******************************************

* 16 
/*tab any if numcond ==1
power twomeans 0.2727 0.7273, power(0.8)
power twomeans 0.2727 0.7273, power(0.9)*/

sum numcond
sum numcond if any==1
sum numcond if any==0

sampsi 0.879 1, sd1(1.879923) sd2(1.90743) power(.8) alpha(.05)
sampsi 0.879 1, sd1(1.879923) sd2(1.90743) power(.9) alpha(.05)

* 17
loneway numcond villnum

sampsi 0.879 1, sd1(1.879923) sd2(1.90743) power(.8) alpha(.05)
sampclus, rho(0.05156) obsclus(40)

sampsi 0.879 1, sd1(1.879923) sd2(1.90743) power(.9) alpha(.05)
sampclus, rho(0.05156) obsclus(40)


* 18

program define myprog1
drop _all
use "Thornton HIV Testing Data.dta", clear
drop if hiv2004==. | hiv2004==-1| any==. | age==. | zone==. | got==. | male==. | site==.| under==. | over==.
gen got1 =(got==1)  
gen got0 =(got==0) 
gen gotdiff = got1-got0
reg gotdiff any, r
end 

simulate _b _se, reps(100): myprog1

/* sharpnull : all equal






