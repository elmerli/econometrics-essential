capture log close
log using "ps2", text replace
/****************************************************************************
Program Name:   ps2.do
Location:       GitHub\aem\ps2
Author:         Maxwell Austensen
Date Created:   31 Oct 2016
Project:        Problem Set 2 - Instrumental Variables
Class:        	Advanced Empirical Methods
****************************************************************************/

clear all
clear matrix
macro drop _all
set more off, perm
set maxvar 10000

global root "C:\Users\austensen\Box Sync\aem"


* Part 1
*********

sysuse auto, clear
ivreg price (mpg = displacement),first

qui {
	reg mpg displacement
	matrix coefficients = e(b)
	scalar b = coefficients[1,1]

	sum mpg, d
	scalar mpg_sd = r(sd)

	sum displacement, d
	scalar dis_sd = r(sd)
}
di (b * dis_sd)/mpg_sd


* Set up data
**************

use "$root\ps2\generateddata_20120221_sub.dta", clear

#delimit ;
rename 
	(NIC_io
	Total_worker
	Yearly_gva_production_real
	lnYearly_gva
	labor_reg_besley_flex2
	manufacturing_total
	allmanufacturing
	manshare)
	(nic_io
	workers_total
	gva_yearly
	gva_ln_yearly
	labor_reg
	manu_total
	manu_all
	manu_share);

keep 
	nic_io
	workers_total
	gva_yearly
	gva_ln_yearly
	labor_reg
	manu_total
	state
	round
	post
	labor_manu
	manu_post
	manu_post_share
	labor_manu_share
	manu_all
	manu_share;

#delimit cr;

* Part 2
*********
qui{
	matrix sum_full = J(2, 5, .)
	matrix colnames sum_full = gva_ln_yearly labor_reg manu_all manu_total manu_share
	matrix rownames sum_full = mean sd

	matrix sum_57 = sum_full
	matrix sum_63 = sum_full

	local sum_vars gva_ln_yearly labor_reg manu_all manu_total manu_share
	local i 1
	foreach var in `sum_vars' {
		sum `var'
		matrix sum_full[1,`i'] = r(mean)
		matrix sum_full[2,`i'] = r(sd)

		sum `var' if round==57
		matrix sum_57[1,`i'] = r(mean)
		matrix sum_57[2,`i'] = r(sd)

		sum `var' if round==63
		matrix sum_63[1,`i'] = r(mean)
		matrix sum_63[2,`i'] = r(sd)

		local i `i'+1
	}
}

di "Summary stats - Full Sample"
matrix list sum_full

di "Summary stats - Round 57"
matrix list sum_57

di "Summary stats - Round 63"
matrix list sum_63



qui{
	sum gva_yearly if round==57
	scalar mean_57 = r(mean)

	sum gva_yearly if round==63
	scalar mean_63 = r(mean)
}

di "Growth in GVA, round 57 to 63 = "(mean_63 - mean_57)/ mean_57

qui{
	sum workers_total if round==57
	scalar mean_57 = r(mean)

	sum workers_total if round==63
	scalar mean_63 = r(mean)
}

di "Growth in employees, round 57 to 63 = "(mean_63 - mean_57) / mean_57


* Part 3
*********
eststo clear

* a
eststo: reg gva_ln_yearly labor_reg if round==57

* b
eststo: reg gva_ln_yearly labor_reg if round==63

* c

gen round_63 = 1 if round==63
recode round_63 missing = 0

eststo: reg gva_ln_yearly labor_reg round_63

* d

gen labor_reg_round_63 = 1 if labor_reg==1 & round==63
recode labor_reg_round_63 missing = 0

eststo: reg gva_ln_yearly labor_reg round_63 labor_reg_round_63

* e
eststo: xi: reg gva_ln_yearly labor_reg round_63 i.state i.nic_io


eststo: xi: reg gva_ln_yearly labor_reg round_63 labor_reg_round_63 i.state i.nic_io


esttab


* Part 4
*********

eststo clear

eststo: reg gva_ln_yearly manu_all manu_post post

* a
eststo: reg gva_ln_yearly manu_all manu_post post labor_reg

* b
gen labor_reg_post = labor_reg * post

eststo: reg gva_ln_yearly manu_all manu_post post labor_reg labor_reg_post

* c
eststo: xi: reg gva_ln_yearly manu_all manu_post post labor_reg labor_reg_post i.state i.nic_io

esttab


* Part 5
*********

eststo clear
* a
eststo: ivreg gva_ln_yearly (manu_all = labor_reg), first robust

* b
eststo: xi: ivreg gva_ln_yearly (manu_all = labor_reg) i.state, first robust

* c
eststo: xi: ivreg gva_ln_yearly labor_reg manu_all post (manu_post = labor_reg_post) i.state i.nic_io, first robust

esttab 

xi: ivreg2 gva_ln_yearly labor_reg manu_all post (manu_post = labor_reg_post) i.state i.nic_io, first robust


* d

* (see write up)


************************************************************
************************************************************
********************    END PROGRAM    *********************
************************************************************
************************************************************
log close
