******************************************************************************
******************************************************************************
*****
*****     Replication
*****
******************************************************************************
******************************************************************************


*******************
*  Startup
*******************

clear all
set more off
cd "/Users/elmerleezy/Google Drive/Wagner/3rd Semester/Advan Empirical Method/Problem Sets/Replication/Data"
use "usa_00005.dta", clear

gen miss_sample = 1 if missing(race) | missing(sex) | missing(age) | missing(agemarr) | missing(bpl) | missing(marrno) | missing(chborn)

***** mothers

bysort serial : egen num_adults = total(age >= 18)
bysort serial : egen num_children = total(age < 18)
bysort serial : egen num_head_65p = total(pernum == 1 & age >= 65)
gen inc_index = (num_adults + (0.7 * num_children)) ^ 0.7
gen hhincome_ad = hhincome / inc_index

keep if race == 1 
keep if sex == 2
keep if age >= 21 & age <= 40
keep if agemarr >=17 & agemarr <= 26
keep if bpl <= 120
keep if marrno >= 1 & marrno <= 6
keep if chborn >= 2 & chborn <= 13
keep if nchild >= 1
drop if marst ==5 
drop if marst ==6 
keep if qage == 0
keep if qchborn == 0
keep if qmarrno == 0
keep if qmarst == 0
keep if qagemarr == 0
keep if qrelate == 0
keep if qsex == 0
keep if qbirth == 0

save mothers

***** children
use "usa_00005.dta", clear
* keep serial pernum momloc age sex birthquarter 

keep if momloc != 0
* calculate number of children in a hh
bysort serial momloc: gen num_children_hh = _N 
* keep only the oldest child
gen age_qrt = age-0.1*birthqtr
bysort serial momloc (age): keep if _n==_N 
*bysort serial momloc: egen age_max = max(age)

*bysort serial momloc (age): gen same_age = _N 
*bysort serial momloc: gen same_quarter = birthqtr - birthqtr[_n-1] 

* drop the twins: 
* drop if serial == serial[_n-1] & momloc == momloc[_n-1]

* find the number of twins
*bysort serial momloc: gen rank = _n
*drop if rank ==2
save children, replace

use children
tostring serial, gen(serial2)
tostring momloc, gen(momloc2)

gen id = serial2 + momloc2
bysort id: gen rank = _n
	* result 8 rank==2, so this means that the children file has twins; our previous method works
 * gen id = serial*100 + pernum
 * kids still too many - check ther age max
 * next twins

* check max 
bysort id: egen age_max = max(age)
	*bysort id: gen twin1 = 1 if child_age!=age_max
	* - seems all to be max
	
* check twins - should I reshape first? - Reshape
  * may need to rename first
  
rename age child_age
rename sex child_sex
rename qage child_qage
rename qagemarr child_qagemarr
rename qchborn child_qchborn
rename qmarrno child_qmarrno
rename qmarst child_qmarst
rename qrelate child_qrelate
rename qsex child_qsex
rename qbirthmo child_qbirthmo
rename age_max child_age_max
save, replace

use children
keep id serial momloc rank child_age child_sex child_qage child_qagemarr child_qchborn child_qmarrno child_qmarst child_qrelate child_qsex child_qbirthmo num_children_hh child_age_max
reshape wide serial momloc child_age child_sex child_qage child_qagemarr child_qchborn child_qmarrno child_qmarst child_qrelate child_qsex child_qbirthmo num_children_hh child_age_max, i(id) j(rank)
tostring id, replace
save children_rshp,replace

* next: first merge then delete twins

use mothers
tostring serial, gen(serial2)
tostring pernum, gen(pernum2)
gen id = serial2 + pernum2
save, replace 

use mothers
drop serial2 
merge 1:1 id using children_rshp 
	/* key variable id is str9 in master but float in using data
	
	* result says id doesn't uniquely identify
	duplicates list id
	* find: the scientific number; try - turn into character
tostring id, generate(id2)
	duplicates list id2
	* still duplicates, happens in large numbers
	* maybe create new momloc
	*gen momloc_2 = pernum*/
save mother_child, replace
drop if serial2 != .
keep if _merge == 3
drop serial2 momloc2 child_age2 child_sex2 child_qage2 child_qagemarr2 child_qchborn2 child_qmarrno2 child_qmarst2 child_qrelate2 child_qsex2 child_qbirthmo2 num_children_hh2 child_age_max2 _merge
save, replace
keep if child_qage1 == 0 
keep if child_qsex1 == 0
* keep if child_qmarrno1 == 0
	*keep if child_qbirthmo1 == 0
	*keep if child_qrelate1 == 0 | child_qrelate1 == .
* See other qs
	* table child_qage1
	* table child_qage1
	* table child_qrelate1
	* table child_qsex1
	* table child_qbirthmo1

save, replace

******************************************
** Table 1 **
******************************************
use mother_child

 ** coloum 1
gen mar_end = (marst == 3|marst == 4| marrno == 2)
rename child_sex1 child_sex1_old 
gen child_sex1 = child_sex1_old
replace child_sex1 = 0 if child_sex1_old ==1
replace child_sex1 = 1 if child_sex1_old ==2
	* chborn seems not right
rename chborn chborn_old
gen chborn = chborn_old - 1
gen age_frsb = age - child_age1
gen edu_yrs = higrade - 3
replace edu_yrs = 0 if higrade < 4
gen urban = .
replace urban = 0 if metarea == 0
replace urban = 1 if metarea != 0

* social econ stat
 * non-woman income
 gen nonwife_hhinc = hhincome - inctot 
 gen wages = incwage
 * calculate poverty status
	gen poverty_hh=0
	replace poverty_hh=1.72*hhincome-6310 if num_adults==1 & num_children==0 
	replace poverty_hh=1.72*hhincome-8547 if num_adults==1 & num_children==1 
	replace poverty_hh=1.72*hhincome-9990 if num_adults==1 & num_children==2 
	replace poverty_hh=1.72*hhincome-12619 if num_adults==1 & num_children==3 
	replace poverty_hh=1.72*hhincome-14572 if num_adults==1 & num_children==4 
	replace poverty_hh=1.72*hhincome-16259 if num_adults==1 & num_children==5 
	replace poverty_hh=1.72*hhincome-17828 if num_adults==1 & num_children>=6 
	replace poverty_hh=1.72*hhincome-8303 if num_adults==2 & num_children==0 
	replace poverty_hh=1.72*hhincome-9981 if num_adults==2 & num_children==1 
	replace poverty_hh=1.72*hhincome-12575 if num_adults==2 & num_children==2 
	replace poverty_hh=1.72*hhincome-14798 if num_adults==2 & num_children==3 
	replace poverty_hh=1.72*hhincome-16569 if num_adults==2 & num_children==4 
	replace poverty_hh=1.72*hhincome-18558 if num_adults==2 & num_children==5 
	replace poverty_hh=1.72*hhincome-20403 if num_adults==2 & num_children>=6 
	replace poverty_hh=1.72*hhincome-9699 if num_adults==3 & num_children==0 
	replace poverty_hh=1.72*hhincome-12999 if num_adults==3 & num_children==1 
	replace poverty_hh=1.72*hhincome-15169 if num_adults==3 & num_children==2 
	replace poverty_hh=1.72*hhincome-17092 if num_adults==3 & num_children==3 
	replace poverty_hh=1.72*hhincome-19224 if num_adults==3 & num_children==4 
	replace poverty_hh=1.72*hhincome-21084 if num_adults==3 & num_children==5 
	replace poverty_hh=1.72*hhincome-25089 if num_adults==3 & num_children>=6 
	replace poverty_hh=1.72*hhincome-12790 if num_adults==4 & num_children==0 
	replace poverty_hh=1.72*hhincome-15648 if num_adults==4 & num_children==1 
	replace poverty_hh=1.72*hhincome-17444 if num_adults==4 & num_children==2 
	replace poverty_hh=1.72*hhincome-19794 if num_adults==4 & num_children==3 
	replace poverty_hh=1.72*hhincome-21738 if num_adults==4 & num_children==4 
	replace poverty_hh=1.72*hhincome-25719 if num_adults==4 & num_children>=5 
	replace poverty_hh=1.72*hhincome-15424 if num_adults==5 & num_children==0 
	replace poverty_hh=1.72*hhincome-17811 if num_adults==5 & num_children==1 
	replace poverty_hh=1.72*hhincome-20101 if num_adults==5 & num_children==2 
	replace poverty_hh=1.72*hhincome-22253 if num_adults==5 & num_children==3 
	replace poverty_hh=1.72*hhincome-26415 if num_adults==5 & num_children>=4 
	replace poverty_hh=1.72*hhincome-17740 if num_adults==6 & num_children==0 
	replace poverty_hh=1.72*hhincome-20540 if num_adults==6 & num_children==1 
	replace poverty_hh=1.72*hhincome-22617 if num_adults==6 & num_children==2 
	replace poverty_hh=1.72*hhincome-26921 if num_adults==6 & num_children>=3 
	replace poverty_hh=1.72*hhincome-20412 if num_adults==7 & num_children==0 
	replace poverty_hh=1.72*hhincome-23031 if num_adults==7 & num_children==1 
	replace poverty_hh=1.72*hhincome-27229 if num_adults==7 & num_children>=2 
	replace poverty_hh=1.72*hhincome-22830 if num_adults==8 & num_children==0 
	replace poverty_hh=1.72*hhincome-27596 if num_adults==8 & num_children>=1 
	replace poverty_hh=1.72*hhincome-27463 if num_adults>=9 & num_children>=0 
	gen poor_hhinc = (poverty_hh < 0)
	sum poor_hhinc
	drop poverty_hh 
save, replace


set matsize 10000
set more off 
outreg2 using table1.xls, replace sum(log) keep(mar_end agemarr child_sex1 chborn age_frsb age edu_yrs urban hhincome_ad poor_hhinc nonwife_hhinc inctot wages) eqkeep(N mean sd) 

 ** coloum 2
gen sample_b = (chborn == num_children & child_age1 < 18 & child_qrelate1 == 0 & child_qbirthmo1 == 0)
table  sample_b

 ** coloum 3
gen mar_len = age - agemarr
gen chborn_len = mar_len - child_age1

gen sample_c = (chborn_len <= 5 & child_qagemarr1 == 0 & child_qchborn1 == 0 & child_qmarrno1 == 0 & child_qmarst1 == 0)
drop qage qagemarr qchborn qmarrno qmarst qrelate qsex qbirthmo miss_sample child_qage1 child_qagemarr1 child_qchborn1 child_qmarrno1 child_qmarst1 child_qrelate1 child_qsex1 child_qbirthmo1
table sample_c sample_b

save, replace

 * export
keep if sample_b == 1
set more off
outreg2 using table1.xls, append sum(log) keep(mar_end agemarr child_sex1 chborn age_frsb age edu_yrs urban hhincome_ad poor_hhinc nonwife_hhinc inctot wages) eqkeep(N mean sd) 

keep if sample_c == 1
set more off
outreg2 using table1.xls, append sum(log) keep(mar_end agemarr child_sex1 chborn age_frsb age edu_yrs urban hhincome_ad poor_hhinc nonwife_hhinc inctot wages) eqkeep(N mean sd) 

******************************************
** Table 2 **
******************************************
clear all 
use mother_child
keep if sample_b == 1 & sample_c == 1
gen age_2 = age*age
gen edu_yrs_2 = edu_yrs^2
gen agemarr_2 = agemarr^2
gen age_frsb_2 = age_frsb^2

gen edu_age = edu_yrs*age
gen edu_agemarr = edu_yrs*agemarr
gen edu_age_frsb = edu_yrs*age_frsb
save mother_child_reg, replace
	
	** Unadjusted: 

reg mar_end child_sex1 age age_frsb agemarr edu_yrs
test child_sex1 
outreg2 using table2a.doc, replace adds(F-test, r(F), Prob > F, `r(p)') ctitle(Unadjusted Full)

reg mar_end child_sex1 age age_frsb agemarr edu_yrs if edu_yrs < 12
test child_sex1 
outreg2 using table2a.doc, append adds(F-test, r(F), Prob > F, `r(p)') ctitle(Unadjusted edu_yrs < 12)

reg mar_end child_sex1 age age_frsb agemarr edu_yrs if edu_yrs == 12
test child_sex1 
outreg2 using table2a.doc, append adds(F-test, r(F), Prob > F, `r(p)') ctitle(Unadjusted edu_yrs == 12)

reg mar_end child_sex1 age age_frsb agemarr edu_yrs if edu_yrs > 12 & edu_yrs < 16
test child_sex1 
outreg2 using table2a.doc, append adds(F-test, r(F), Prob > F, `r(p)') ctitle(Unadjusted edu_yrs>12&< 16)

reg mar_end child_sex1 age age_frsb agemarr edu_yrs if edu_yrs >= 16
test child_sex1 
outreg2 using table2a.doc, append adds(F-test, r(F), Prob > F, `r(p)') ctitle(Unadjusted edu_yrs >= 16)

reg mar_end child_sex1 age age_frsb agemarr edu_yrs if agemarr < 20
test child_sex1 
outreg2 using table2a.doc, append adds(F-test, r(F), Prob > F, `r(p)') ctitle(Unadjusted agemarr < 20)

reg mar_end child_sex1 age age_frsb agemarr edu_yrs if agemarr >= 20
test child_sex1 
outreg2 using table2a.doc, append adds(F-test, r(F), Prob > F, `r(p)') ctitle(Unadjusted agemarr >= 20)

reg mar_end child_sex1 age age_frsb agemarr edu_yrs if age_frsb < 22
test child_sex1 
outreg2 using table2a.doc, append adds(F-test, r(F), Prob > F, `r(p)') ctitle(Unadjusted age_frsb < 22)

reg mar_end child_sex1 age age_frsb agemarr edu_yrs if age_frsb >= 22
test child_sex1 
outreg2 using table2a.doc, append adds(F-test, r(F), Prob > F, `r(p)') ctitle(Unadjusted age_frsb >= 22)

	** adjusted

reg mar_end child_sex1 age age_frsb agemarr edu_yrs age_2 edu_yrs_2 agemarr_2 age_frsb_2 edu_age edu_agemarr edu_age_frsb urban
test child_sex1 
outreg2 using table2b.doc, replace adds(F-test, r(F), Prob > F, `r(p)') ctitle(Adjusted Full)

reg mar_end child_sex1 age age_frsb agemarr edu_yrs age_2 edu_yrs_2 agemarr_2 age_frsb_2 edu_age edu_agemarr edu_age_frsb urban if edu_yrs < 12
test child_sex1 
outreg2 using table2b.doc, append adds(F-test, r(F), Prob > F, `r(p)') ctitle(Adjusted edu_yrs < 12)

reg mar_end child_sex1 age age_frsb agemarr edu_yrs age_2 edu_yrs_2 agemarr_2 age_frsb_2 edu_age edu_agemarr edu_age_frsb urban if edu_yrs == 12
test child_sex1 
outreg2 using table2b.doc, append adds(F-test, r(F), Prob > F, `r(p)') ctitle(Adjusted edu_yrs == 12)

reg mar_end child_sex1 age age_frsb agemarr edu_yrs age_2 edu_yrs_2 agemarr_2 age_frsb_2 edu_age edu_agemarr edu_age_frsb urban if edu_yrs > 12 & edu_yrs < 16
test child_sex1 
outreg2 using table2b.doc, append adds(F-test, r(F), Prob > F, `r(p)') ctitle(Adjusted edu_yrs>12&< 16)

reg mar_end child_sex1 age age_frsb agemarr edu_yrs age_2 edu_yrs_2 agemarr_2 age_frsb_2 edu_age edu_agemarr edu_age_frsb urban if edu_yrs >= 16
test child_sex1 
outreg2 using table2b.doc, append adds(F-test, r(F), Prob > F, `r(p)') ctitle(Adjusted edu_yrs >= 16)

reg mar_end child_sex1 age age_frsb agemarr edu_yrs age_2 edu_yrs_2 agemarr_2 age_frsb_2 edu_age edu_agemarr edu_age_frsb urban if agemarr < 20
test child_sex1 
outreg2 using table2b.doc, append adds(F-test, r(F), Prob > F, `r(p)') ctitle(Adjusted agemarr < 20)

reg mar_end child_sex1 age age_frsb agemarr edu_yrs age_2 edu_yrs_2 agemarr_2 age_frsb_2 edu_age edu_agemarr edu_age_frsb urban if agemarr >= 20
test child_sex1 
outreg2 using table2b.doc, append adds(F-test, r(F), Prob > F, `r(p)') ctitle(Adjusted agemarr >= 20)

reg mar_end child_sex1 age age_frsb agemarr edu_yrs age_2 edu_yrs_2 agemarr_2 age_frsb_2 edu_age edu_agemarr edu_age_frsb urban if age_frsb < 22
test child_sex1 
outreg2 using table2b.doc, append adds(F-test, r(F), Prob > F, `r(p)') ctitle(Adjusted age_frsb < 22)

reg mar_end child_sex1 age age_frsb agemarr edu_yrs age_2 edu_yrs_2 agemarr_2 age_frsb_2 edu_age edu_agemarr edu_age_frsb urban if age_frsb >= 22
test child_sex1 
outreg2 using table2b.doc, append adds(F-test, r(F), Prob > F, `r(p)') ctitle(Adjusted age_frsb >= 22)

******************************************
** Table 3 **
******************************************
use mother_child_reg

set matsize 10000
set more off
bysort mar_end: outreg2 using table3.xls, replace sum(log) keep(mar_end agemarr child_sex1 chborn age_frsb age edu_yrs urban) eqkeep(N mean sd) 
set more off
bysort child_sex1: outreg2 using table3.xls, append sum(log) keep(mar_end agemarr child_sex1 chborn age_frsb age edu_yrs urban) eqkeep(N mean sd) 

reg agemarr mar_end, robust 
reg child_sex1 mar_end, robust 
reg chborn mar_end, robust 
reg age_frsb mar_end, robust 
reg age mar_end, robust 
reg edu_yrs mar_end, robust 
reg urban mar_end, robust

reg mar_end child_sex1, robust 
reg agemarr child_sex1, robust 
reg chborn child_sex1, robust 
reg age_frsb child_sex1, robust 
reg age child_sex1, robust 
reg edu_yrs child_sex1, robust 
reg urban child_sex1, robust

******************************************
** Table 4 **
******************************************

* column 1
gen wk_forpay = (empstat == 1)
set matsize 10000
set more off
xi: qui regress hhincome_ad mar_end age agemarr age_frsb edu_yrs age_2 agemarr_2 age_frsb_2 edu_yrs_2 edu_age edu_agemarr edu_age_frsb urban i.bpl i.statefip
outreg2 using table4.xls, replace ctitle(OLS-hhincome_ad) keep(mar_end)
qui regress poor_hhinc mar_end age agemarr age_frsb edu_yrs age_2 agemarr_2 age_frsb_2 edu_yrs_2 edu_age edu_agemarr edu_age_frsb urban _Istatefip_* _Ibpl_*
outreg2 using table4.xls, append ctitle(OLS-poor_hhinc) keep(mar_end)
qui regress nonwife_hhinc mar_end age agemarr age_frsb edu_yrs age_2 agemarr_2 age_frsb_2 edu_yrs_2 edu_age edu_agemarr edu_age_frsb urban _Istatefip_* _Ibpl_*
outreg2 using table4.xls, append ctitle(OLS-nonwife_hhinc) keep(mar_end)
qui regress inctot mar_end age agemarr age_frsb edu_yrs age_2 agemarr_2 age_frsb_2 edu_yrs_2 edu_age edu_agemarr edu_age_frsb urban _Istatefip_* _Ibpl_*
outreg2 using table4.xls, append ctitle(OLS-inctot) keep(mar_end)
qui regress wages mar_end age agemarr age_frsb edu_yrs age_2 agemarr_2 age_frsb_2 edu_yrs_2 edu_age edu_agemarr edu_age_frsb urban _Istatefip_* _Ibpl_*
outreg2 using table4.xls, append ctitle(OLS-annual earning) keep(mar_end)
qui regress wk_forpay mar_end age agemarr age_frsb edu_yrs age_2 agemarr_2 age_frsb_2 edu_yrs_2 edu_age edu_agemarr edu_age_frsb urban _Istatefip_* _Ibpl_*
outreg2 using table4.xls, append ctitle(OLS-wk_forpay) keep(mar_end)
qui regress WKSWORK1 mar_end age agemarr age_frsb edu_yrs age_2 agemarr_2 age_frsb_2 edu_yrs_2 edu_age edu_agemarr edu_age_frsb urban _Istatefip_* _Ibpl_*
outreg2 using table4.xls, append ctitle(OLS-WKSWORK1) keep(mar_end)
qui regress uhrswork mar_end age agemarr age_frsb edu_yrs age_2 agemarr_2 age_frsb_2 edu_yrs_2 edu_age edu_agemarr edu_age_frsb urban _Istatefip_* _Ibpl_*
outreg2 using table4.xls, append ctitle(OLS-uhrswork) keep(mar_end)

* column 2
* instrumental variable method:

/* ivreg2 lnYearly_gva (allmanufacturing=labor_reg) i.state2, first robust
ivreg2 hhincome_ad (mar_end = child_sex1) age agemarr age_frsb edu_yrs age_2 agemarr_2 age_frsb_2 edu_yrs_2 edu_age edu_agemarr edu_age_frsb urban _Istatefip_* _Ibpl_*, first robust */
	set more off
	qui ivreg hhincome_ad (mar_end = child_sex1), r
	outreg2 using table4.xls, append ctitle(WALD-hhincome_ad) keep(mar_end)
	qui ivreg poor_hhinc (mar_end = child_sex1), r
	outreg2 using table4.xls, append ctitle(WALD-poor_hhinc) keep(mar_end)	
	qui ivreg nonwife_hhinc (mar_end = child_sex1), r
	outreg2 using table4.xls, append ctitle(WALD-nonwife_hhinc) keep(mar_end)
	qui ivreg inctot (mar_end = child_sex1), r
	outreg2 using table4.xls, append ctitle(WALD-inctot) keep(mar_end)
	qui ivreg wages (mar_end = child_sex1), r
	outreg2 using table4.xls, append ctitle(WALD-annual earning) keep(mar_end)
	qui ivreg wk_forpay (mar_end = child_sex1), r
	outreg2 using table4.xls, append ctitle(WALD-wk_forpay) keep(mar_end)
	qui ivreg WKSWORK1 (mar_end = child_sex1), r
	outreg2 using table4.xls, append ctitle(WALD-WKSWORK1) keep(mar_end)
	qui ivreg uhrswork (mar_end = child_sex1), r
	outreg2 using table4.xls, append ctitle(WALD-uhrswork) keep(mar_end)
	* or alternatively 
	/*set more off
	reg mar_end child_sex1 
	predict mar_end_pd
	reg hhincome_ad mar_end_pd */

* column 3
set more off	
qui reg mar_end child_sex1 age agemarr age_frsb edu_yrs age_2 agemarr_2 age_frsb_2 edu_yrs_2 edu_age edu_agemarr edu_age_frsb urban _Istatefip_* _Ibpl_*
test child_sex1
predict mar_end_pd

qui reg hhincome_ad mar_end_pd age agemarr age_frsb edu_yrs age_2 agemarr_2 age_frsb_2 edu_yrs_2 edu_age edu_agemarr edu_age_frsb urban _Istatefip_* _Ibpl_*
outreg2 using table4.xls, append ctitle(TSLS-hhincome_ad) keep(mar_end_pd)
qui reg poor_hhinc mar_end_pd age agemarr age_frsb edu_yrs age_2 agemarr_2 age_frsb_2 edu_yrs_2 edu_age edu_agemarr edu_age_frsb urban _Istatefip_* _Ibpl_*
outreg2 using table4.xls, append ctitle(TSLS-poor_hhinc) keep(mar_end_pd)
qui reg nonwife_hhinc mar_end_pd age agemarr age_frsb edu_yrs age_2 agemarr_2 age_frsb_2 edu_yrs_2 edu_age edu_agemarr edu_age_frsb urban _Istatefip_* _Ibpl_*
outreg2 using table4.xls, append ctitle(TSLS-nonwife_hhinc) keep(mar_end_pd)
qui reg inctot mar_end_pd age agemarr age_frsb edu_yrs age_2 agemarr_2 age_frsb_2 edu_yrs_2 edu_age edu_agemarr edu_age_frsb urban _Istatefip_* _Ibpl_*
outreg2 using table4.xls, append ctitle(TSLS-inctot) keep(mar_end_pd)
qui reg wages mar_end_pd age agemarr age_frsb edu_yrs age_2 agemarr_2 age_frsb_2 edu_yrs_2 edu_age edu_agemarr edu_age_frsb urban _Istatefip_* _Ibpl_*
outreg2 using table4.xls, append ctitle(TSLS-annualearn) keep(mar_end_pd)
qui reg wk_forpay mar_end_pd age agemarr age_frsb edu_yrs age_2 agemarr_2 age_frsb_2 edu_yrs_2 edu_age edu_agemarr edu_age_frsb urban _Istatefip_* _Ibpl_*
outreg2 using table4.xls, append ctitle(TSLS-wk_forpay) keep(mar_end_pd)
qui reg WKSWORK1 mar_end_pd age agemarr age_frsb edu_yrs age_2 agemarr_2 age_frsb_2 edu_yrs_2 edu_age edu_agemarr edu_age_frsb urban _Istatefip_* _Ibpl_*
outreg2 using table4.xls, append ctitle(TSLS-WKSWORK1) keep(mar_end_pd)
qui reg uhrswork mar_end_pd age agemarr age_frsb edu_yrs age_2 agemarr_2 age_frsb_2 edu_yrs_2 edu_age edu_agemarr edu_age_frsb urban _Istatefip_* _Ibpl_*
outreg2 using table4.xls, append ctitle(TSLS-uhrswork) keep(mar_end_pd)


* column 4
gen mar_stat =(marst == 1 & marrno == 2| marst == 2 & marrno == 2)

set matsize 10000
set more off	
drop mar_end_pd
qui reg mar_end child_sex1 age agemarr age_frsb edu_yrs age_2 agemarr_2 age_frsb_2 edu_yrs_2 edu_age edu_agemarr edu_age_frsb urban chborn mar_stat _Istatefip_* _Ibpl_* 
predict mar_end_pd

qui reg hhincome_ad mar_end_pd age agemarr age_frsb edu_yrs age_2 agemarr_2 age_frsb_2 edu_yrs_2 edu_age edu_agemarr edu_age_frsb urban chborn mar_stat _Istatefip_* _Ibpl_*
outreg2 using table4.xls, append ctitle(TSLS2-hhincome_ad) keep(mar_end_pd)
qui reg poor_hhinc mar_end_pd age agemarr age_frsb edu_yrs age_2 agemarr_2 age_frsb_2 edu_yrs_2 edu_age edu_agemarr edu_age_frsb urban chborn mar_stat _Istatefip_* _Ibpl_*
outreg2 using table4.xls, append ctitle(TSLS2-poor_hhinc) keep(mar_end_pd)
qui reg nonwife_hhinc mar_end_pd age agemarr age_frsb edu_yrs age_2 agemarr_2 age_frsb_2 edu_yrs_2 edu_age edu_agemarr edu_age_frsb urban chborn mar_stat _Istatefip_* _Ibpl_*
outreg2 using table4.xls, append ctitle(TSLS2-nonwife_hhinc) keep(mar_end_pd)
qui reg inctot mar_end_pd age agemarr age_frsb edu_yrs age_2 agemarr_2 age_frsb_2 edu_yrs_2 edu_age edu_agemarr edu_age_frsb urban chborn mar_stat _Istatefip_* _Ibpl_*
outreg2 using table4.xls, append ctitle(TSLS2-inctot) keep(mar_end_pd)
qui reg wages mar_end_pd age agemarr age_frsb edu_yrs age_2 agemarr_2 age_frsb_2 edu_yrs_2 edu_age edu_agemarr edu_age_frsb urban chborn mar_stat _Istatefip_* _Ibpl_*
outreg2 using table4.xls, append ctitle(TSLS2-annualearn) keep(mar_end_pd)
qui reg wk_forpay mar_end_pd age agemarr age_frsb edu_yrs age_2 agemarr_2 age_frsb_2 edu_yrs_2 edu_age edu_agemarr edu_age_frsb urban chborn mar_stat _Istatefip_* _Ibpl_*
outreg2 using table4.xls, append ctitle(TSLS2-wk_forpay) keep(mar_end_pd)
qui reg WKSWORK1 mar_end_pd age agemarr age_frsb edu_yrs age_2 agemarr_2 age_frsb_2 edu_yrs_2 edu_age edu_agemarr edu_age_frsb urban chborn mar_stat _Istatefip_* _Ibpl_*
outreg2 using table4.xls, append ctitle(TSLS2-WKSWORK1) keep(mar_end_pd)
qui reg uhrswork mar_end_pd age agemarr age_frsb edu_yrs age_2 agemarr_2 age_frsb_2 edu_yrs_2 edu_age edu_agemarr edu_age_frsb urban chborn mar_stat _Istatefip_* _Ibpl_*
outreg2 using table4.xls, append ctitle(TSLS2-uhrswork) keep(mar_end_pd)

******************************************
** Table 5 **
******************************************

* test: reg hhincome_ad mar_end_pd age agemarr age_frsb edu_yrs age_2 agemarr_2 age_frsb_2 edu_yrs_2 edu_age edu_agemarr edu_age_frsb urban chborn mar_stat _Istatefip_* _Ibpl_*

* OLS
set matsize 10000
set more off
qui regress hhincome_ad mar_end age agemarr age_frsb edu_yrs age_2 agemarr_2 age_frsb_2 edu_yrs_2 edu_age edu_agemarr edu_age_frsb urban _Istatefip_* _Ibpl_*  if child_age1 < 12
outreg2 using table5.xls, replace ctitle(OLS(<12)-hhincome_ad) keep(mar_end)
qui regress poor_hhinc mar_end age agemarr age_frsb edu_yrs age_2 agemarr_2 age_frsb_2 edu_yrs_2 edu_age edu_agemarr edu_age_frsb urban _Istatefip_* _Ibpl_* if child_age1 < 12 
outreg2 using table5.xls, append ctitle(OLS(<12)-poor_hhinc) keep(mar_end)
qui regress nonwife_hhinc mar_end age agemarr age_frsb edu_yrs age_2 agemarr_2 age_frsb_2 edu_yrs_2 edu_age edu_agemarr edu_age_frsb urban _Istatefip_* _Ibpl_* if child_age1 < 12 
outreg2 using table5.xls, append ctitle(OLS(<12)-nonwife_hhinc) keep(mar_end)
qui regress inctot mar_end age agemarr age_frsb edu_yrs age_2 agemarr_2 age_frsb_2 edu_yrs_2 edu_age edu_agemarr edu_age_frsb urban _Istatefip_* _Ibpl_* if child_age1 < 12 
outreg2 using table5.xls, append ctitle(OLS(<12)-inctot) keep(mar_end)
qui regress wages mar_end age agemarr age_frsb edu_yrs age_2 agemarr_2 age_frsb_2 edu_yrs_2 edu_age edu_agemarr edu_age_frsb urban _Istatefip_* _Ibpl_* if child_age1 < 12 
outreg2 using table5.xls, append ctitle(OLS(<12)-annual earning) keep(mar_end)
qui regress wk_forpay mar_end age agemarr age_frsb edu_yrs age_2 agemarr_2 age_frsb_2 edu_yrs_2 edu_age edu_agemarr edu_age_frsb urban _Istatefip_* _Ibpl_* if child_age1 < 12 
outreg2 using table5.xls, append ctitle(OLS(<12)-wk_forpay) keep(mar_end)
qui regress WKSWORK1 mar_end age agemarr age_frsb edu_yrs age_2 agemarr_2 age_frsb_2 edu_yrs_2 edu_age edu_agemarr edu_age_frsb urban _Istatefip_* _Ibpl_* if child_age1 < 12 
outreg2 using table5.xls, append ctitle(OLS(<12)-WKSWORK1) keep(mar_end)
qui regress uhrswork mar_end age agemarr age_frsb edu_yrs age_2 agemarr_2 age_frsb_2 edu_yrs_2 edu_age edu_agemarr edu_age_frsb urban _Istatefip_* _Ibpl_* if child_age1 < 12 
outreg2 using table5.xls, append ctitle(OLS(<12)-uhrswork) keep(mar_end)

set more off
qui regress hhincome_ad mar_end age agemarr age_frsb edu_yrs age_2 agemarr_2 age_frsb_2 edu_yrs_2 edu_age edu_agemarr edu_age_frsb urban _Istatefip_* _Ibpl_*  if child_age1 >=12
outreg2 using table5.xls, append ctitle(OLS(>=12)-hhincome_ad) keep(mar_end)
qui regress poor_hhinc mar_end age agemarr age_frsb edu_yrs age_2 agemarr_2 age_frsb_2 edu_yrs_2 edu_age edu_agemarr edu_age_frsb urban _Istatefip_* _Ibpl_* if child_age1 >=12 
outreg2 using table5.xls, append ctitle(OLS(>=12)-poor_hhinc) keep(mar_end)
qui regress nonwife_hhinc mar_end age agemarr age_frsb edu_yrs age_2 agemarr_2 age_frsb_2 edu_yrs_2 edu_age edu_agemarr edu_age_frsb urban _Istatefip_* _Ibpl_* if child_age1 >=12 
outreg2 using table5.xls, append ctitle(OLS(>=12)-nonwife_hhinc) keep(mar_end)
qui regress inctot mar_end age agemarr age_frsb edu_yrs age_2 agemarr_2 age_frsb_2 edu_yrs_2 edu_age edu_agemarr edu_age_frsb urban _Istatefip_* _Ibpl_* if child_age1 >=12 
outreg2 using table5.xls, append ctitle(OLS(>=12)-inctot) keep(mar_end)
qui regress wages mar_end age agemarr age_frsb edu_yrs age_2 agemarr_2 age_frsb_2 edu_yrs_2 edu_age edu_agemarr edu_age_frsb urban _Istatefip_* _Ibpl_* if child_age1 >=12 
outreg2 using table5.xls, append ctitle(OLS(>=12)-annual earning) keep(mar_end)
qui regress wk_forpay mar_end age agemarr age_frsb edu_yrs age_2 agemarr_2 age_frsb_2 edu_yrs_2 edu_age edu_agemarr edu_age_frsb urban _Istatefip_* _Ibpl_* if child_age1 >=12 
outreg2 using table5.xls, append ctitle(OLS(>=12)-wk_forpay) keep(mar_end)
qui regress WKSWORK1 mar_end age agemarr age_frsb edu_yrs age_2 agemarr_2 age_frsb_2 edu_yrs_2 edu_age edu_agemarr edu_age_frsb urban _Istatefip_* _Ibpl_* if child_age1 >=12 
outreg2 using table5.xls, append ctitle(OLS(>=12)-WKSWORK1) keep(mar_end)
qui regress uhrswork mar_end age agemarr age_frsb edu_yrs age_2 agemarr_2 age_frsb_2 edu_yrs_2 edu_age edu_agemarr edu_age_frsb urban _Istatefip_* _Ibpl_* if child_age1 >=12 
outreg2 using table5.xls, append ctitle(OLS(>=12)-uhrswork) keep(mar_end)

* TSLS
set more off
drop mar_end_pd
qui reg mar_end child_sex1 age agemarr age_frsb edu_yrs age_2 agemarr_2 age_frsb_2 edu_yrs_2 edu_age edu_agemarr edu_age_frsb urban _Istatefip_* _Ibpl_* if child_age1 <12
test child_sex1
predict mar_end_pd

qui reg hhincome_ad mar_end_pd age agemarr age_frsb edu_yrs age_2 agemarr_2 age_frsb_2 edu_yrs_2 edu_age edu_agemarr edu_age_frsb urban _Istatefip_* _Ibpl_* if child_age1 <12
outreg2 using table5.xls, append ctitle(TSLS(<12)-hhincome_ad) keep(mar_end_pd)
qui reg poor_hhinc mar_end_pd age agemarr age_frsb edu_yrs age_2 agemarr_2 age_frsb_2 edu_yrs_2 edu_age edu_agemarr edu_age_frsb urban _Istatefip_* _Ibpl_* if child_age1 <12
outreg2 using table5.xls, append ctitle(TSLS(<12)-poor_hhinc) keep(mar_end_pd)
qui reg nonwife_hhinc mar_end_pd age agemarr age_frsb edu_yrs age_2 agemarr_2 age_frsb_2 edu_yrs_2 edu_age edu_agemarr edu_age_frsb urban _Istatefip_* _Ibpl_* if child_age1 <12
outreg2 using table5.xls, append ctitle(TSLS(<12)-nonwife_hhinc) keep(mar_end_pd)
qui reg inctot mar_end_pd age agemarr age_frsb edu_yrs age_2 agemarr_2 age_frsb_2 edu_yrs_2 edu_age edu_agemarr edu_age_frsb urban _Istatefip_* _Ibpl_* if child_age1 <12
outreg2 using table5.xls, append ctitle(TSLS(<12)-inctot) keep(mar_end_pd)
qui reg wages mar_end_pd age agemarr age_frsb edu_yrs age_2 agemarr_2 age_frsb_2 edu_yrs_2 edu_age edu_agemarr edu_age_frsb urban _Istatefip_* _Ibpl_* if child_age1 <12
outreg2 using table5.xls, append ctitle(TSLS(<12)-annualearn) keep(mar_end_pd)
qui reg wk_forpay mar_end_pd age agemarr age_frsb edu_yrs age_2 agemarr_2 age_frsb_2 edu_yrs_2 edu_age edu_agemarr edu_age_frsb urban _Istatefip_* _Ibpl_* if child_age1 <12
outreg2 using table5.xls, append ctitle(TSLS(<12)-wk_forpay) keep(mar_end_pd)
qui reg WKSWORK1 mar_end_pd age agemarr age_frsb edu_yrs age_2 agemarr_2 age_frsb_2 edu_yrs_2 edu_age edu_agemarr edu_age_frsb urban _Istatefip_* _Ibpl_* if child_age1 <12
outreg2 using table5.xls, append ctitle(TSLS(<12)-WKSWORK1) keep(mar_end_pd)
qui reg uhrswork mar_end_pd age agemarr age_frsb edu_yrs age_2 agemarr_2 age_frsb_2 edu_yrs_2 edu_age edu_agemarr edu_age_frsb urban _Istatefip_* _Ibpl_* if child_age1 <12
outreg2 using table5.xls, append ctitle(TSLS(<12)-uhrswork) keep(mar_end_pd)

set more off
drop mar_end_pd
qui reg mar_end child_sex1 age agemarr age_frsb edu_yrs age_2 agemarr_2 age_frsb_2 edu_yrs_2 edu_age edu_agemarr edu_age_frsb urban _Istatefip_* _Ibpl_* if child_age1 >=12
test child_sex1
predict mar_end_pd

qui reg hhincome_ad mar_end_pd age agemarr age_frsb edu_yrs age_2 agemarr_2 age_frsb_2 edu_yrs_2 edu_age edu_agemarr edu_age_frsb urban _Istatefip_* _Ibpl_* if child_age1 >=12
outreg2 using table5.xls, append ctitle(TSLS(>=12)-hhincome_ad) keep(mar_end_pd)
qui reg poor_hhinc mar_end_pd age agemarr age_frsb edu_yrs age_2 agemarr_2 age_frsb_2 edu_yrs_2 edu_age edu_agemarr edu_age_frsb urban _Istatefip_* _Ibpl_* if child_age1 >=12
outreg2 using table5.xls, append ctitle(TSLS(>=12)-poor_hhinc) keep(mar_end_pd)
qui reg nonwife_hhinc mar_end_pd age agemarr age_frsb edu_yrs age_2 agemarr_2 age_frsb_2 edu_yrs_2 edu_age edu_agemarr edu_age_frsb urban _Istatefip_* _Ibpl_* if child_age1 >=12
outreg2 using table5.xls, append ctitle(TSLS(>=12)-nonwife_hhinc) keep(mar_end_pd)
qui reg inctot mar_end_pd age agemarr age_frsb edu_yrs age_2 agemarr_2 age_frsb_2 edu_yrs_2 edu_age edu_agemarr edu_age_frsb urban _Istatefip_* _Ibpl_* if child_age1 >=12
outreg2 using table5.xls, append ctitle(TSLS(>=12)-inctot) keep(mar_end_pd)
qui reg wages mar_end_pd age agemarr age_frsb edu_yrs age_2 agemarr_2 age_frsb_2 edu_yrs_2 edu_age edu_agemarr edu_age_frsb urban _Istatefip_* _Ibpl_* if child_age1 >=12
outreg2 using table5.xls, append ctitle(TSLS(>=12)-annualearn) keep(mar_end_pd)
qui reg wk_forpay mar_end_pd age agemarr age_frsb edu_yrs age_2 agemarr_2 age_frsb_2 edu_yrs_2 edu_age edu_agemarr edu_age_frsb urban _Istatefip_* _Ibpl_* if child_age1 >=12
outreg2 using table5.xls, append ctitle(TSLS(>=12)-wk_forpay) keep(mar_end_pd)
qui reg WKSWORK1 mar_end_pd age agemarr age_frsb edu_yrs age_2 agemarr_2 age_frsb_2 edu_yrs_2 edu_age edu_agemarr edu_age_frsb urban _Istatefip_* _Ibpl_* if child_age1 >=12
outreg2 using table5.xls, append ctitle(TSLS(>=12)-WKSWORK1) keep(mar_end_pd)
qui reg uhrswork mar_end_pd age agemarr age_frsb edu_yrs age_2 agemarr_2 age_frsb_2 edu_yrs_2 edu_age edu_agemarr edu_age_frsb urban _Istatefip_* _Ibpl_* if child_age1 >=12
outreg2 using table5.xls, append ctitle(TSLS(>=12)-uhrswork) keep(mar_end_pd)

save final, replace

