******************************************************************************
******************************************************************************
*****
*****     AEM PS 2
*****
******************************************************************************
******************************************************************************

* ivregress (2SLS) 

*******************
*  Startup
*******************

clear all
set more off

******************************************
** Part I: **
******************************************

* 1.
 
sysuse auto
ivreg2 price (mpg=displacement),first robust

* 2. 

cd "/Users/elmerleezy/Google Drive/Wagner/第三学期/Advan Empirical Method/Problem Sets/PS2"
* cd "C:\Users\zyl220\Downloads"
use "generateddata_20120221_sub.dta", clear

sum lnYearly_gva labor_reg allmanufacturing manufacturing_total manshare 
* outreg2 using x.doc, replace sum(log) keep(lnYearly_gva)

sum lnYearly_gva labor_reg allmanufacturing manufacturing_total manshare if post==0
sum lnYearly_gva labor_reg allmanufacturing manufacturing_total manshare if post==1

* Rajeev: So when I ask you to compute the growth rate, I'm asking you to compute the growth rate over rounds,  across all firms in each cross-section.

tabstat Yearly_gva_production_real, by (post)

tabstat Total_worker, by (post)

* 3. 

* a. 
* reg Yearly_gva_production_real labor_reg if post==0, robust
reg lnYearly_gva labor_reg if post==0, robust
outreg2 using myreg.doc, replace ctitle(round57)

* b. 
reg lnYearly_gva labor_reg if post==1, robust
outreg2 using myreg.doc, append ctitle(round63)

* c. 
reg lnYearly_gva labor_reg post, robust
outreg2 using myreg.doc, append ctitle(full+round63)

* d. 
gen labpost = labor_reg*post
reg lnYearly_gva labor_reg post labpost, robust
test labor_reg = labpost = 0
outreg2 using myreg.doc, append ctitle(full+round63+labpost) addtext(F-statistic, 0.0000)


* e. 
** c
xi: reg lnYearly_gva labor_reg post i.state i.NIC_io, robust
outreg2 using myreg.doc, append ctitle(fixed effects)


* 4. 

reg lnYearly_gva allmanufacturing manu_post post, robust
test allmanufacturing = manu_post = 0
outreg2 using myreg2.doc, replace ctitle(Main) addtext(F-statistic, 0.0000)


**a
reg lnYearly_gva allmanufacturing manu_post post labor_reg, robust
test allmanufacturing = manu_post = 0
outreg2 using myreg2.doc, append ctitle(labor_reg) addtext(F-statistic, 0.0000)


**b
reg lnYearly_gva allmanufacturing manu_post post labor_reg labpost, robust
test allmanufacturing = manu_post = 0
test labor_reg = labpost = 0
outreg2 using myreg2.doc, append ctitle(labor_reg labpost) addtext(F-statistic, 0.0000)

**c
xi: reg lnYearly_gva allmanufacturing manu_post post labor_reg labpost i.state i.NIC_io, robust
test allmanufacturing = manu_post = 0
test labor_reg = labpost = 0
outreg2 using myreg2.doc, append ctitle(fixed effects) addtext(F-statistic, 0.0003 0.0000)

* 5.
** a
ivreg2 lnYearly_gva (allmanu=labor_reg),first robust
outreg2 using myreg3.doc, replace ctitle(IV:labor_reg) 


** b
* xi: reg allmanu labor_reg i.state, first robust

xi: ivreg2 lnYearly_gva (allmanufacturing=labor_reg) i.state2, first robust
outreg2 using myreg3.doc, append ctitle(IV:labor_reg, fixed effects) 

** c
xi: ivreg2 lnYearly_gva (manu_post=labpost) labor_reg allmanufacturing post i.state i.NIC_io, first robust
outreg2 using myreg3.doc, append ctitle(IV:manu_post, fixed effects, full) 

* plausibility IV

corr labor_reg lnYearly_gva post allmanufacturing NIC_io state2
corr labpost lnYearly_gva labor_reg post allmanufacturing NIC_io state2



