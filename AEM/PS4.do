******************************************************************************
******************************************************************************
*****
*****     AEM PS 4
*****
******************************************************************************
******************************************************************************


*******************
*  Startup
*******************

clear all
set more off
cd "/Users/zongyangli/Google Drive/Wagner/第三学期/Advan Empirical Method/Problem Sets/PS4"
use "nsw_dw.dta", clear

** 1
 * sum statistics 
keep if data_id == "Dehejia-Wahba Sample" & treat == 1
outreg2 using sum1.xls, replace sum(log) eqkeep(N mean sd)

use nsw_dw, clear
keep if data_id == "Dehejia-Wahba Sample" & treat == 0
outreg2 using sum1.xls, append sum(log) eqkeep(N mean sd)

use nsw_dw, clear
drop if data_id == "Dehejia-Wahba Sample" 
outreg2 using sum1.xls, append sum(log) eqkeep(N mean sd)

 * test mean differences
use nsw_dw, clear
keep if data_id == "Dehejia-Wahba Sample" 
save exp_var

 * need to use ttest to test all the variables.
use exp_var, clear
foreach var of varlist age education black hispanic married nodegree re74 re75 re78 {
di "`var'"
ttest `var', by(treat)
}

use nsw_dw, clear
drop if data_id == "Dehejia-Wahba Sample" & treat == 0
save nonexp_var 

use nonexp_var, clear
foreach var of varlist age education black hispanic married nodegree re74 re75 re78 {
di "`var'"
ttest `var', by(treat)
}

* Other method: used an ID to indicate the exact situation
** 2

use nonexp_var, clear
nnmatch re78 treat re74 re75 ,pop m(1) keep(mt_74_psid) tc(att) replace

use exp_var, clear
nnmatch re78 treat re74 re75 ,pop m(1) keep(mt_74) tc(att) replace

* graph for nonexp_var
use mt_74_psid, clear
keep if treat==1
collapse treat re78 re74 re75 km km_prime index dist re78_0 re78_1 re74_0m re75_0m re74_1m re75_1m, by(id)

twoway (scatter re74_1m id, ms(O) mc(red) msize(small)) 
(scatter re74_0m id, ms(O) mc(blue) msize(small))
graph export "test.png", replace
twoway (scatter re74_1m re74_0m, ms(O) mc(red) msize(small))

twoway (scatter re75_1m id, ms(O) mc(red) msize(small)) (scatter re75_0m id, ms(O) mc(blue) msize(small))
twoway (scatter re75_1m re75_0m, ms(O) mc(red) msize(small))

* graph for exp_var
use mt_74, clear
keep if treat==1
collapse treat re78 re74 re75 km km_prime index dist re78_0 re78_1 re74_0m re75_0m re74_1m re75_1m, by(id)

twoway (scatter re74_1m id, ms(O) mc(red) msize(small)) (scatter re74_0m id, ms(O) mc(blue) msize(small))
twoway (scatter re74_1m re74_0m, ms(O) mc(red) msize(small))

twoway (scatter re75_1m id, ms(O) mc(red) msize(small)) (scatter re75_0m id, ms(O) mc(blue) msize(small))
twoway (scatter re75_1m re75_0m, ms(O) mc(red) msize(small))


* twoway (scatter re78_1 id, ms(O) mc(red) msize(small)) (scatter re78_0 id, ms(O) mc(blue) msize(small))

** 3

use nsw_dw, clear
capture gen ndex = _n
capture gen id = _n
save nsw_dw, replace

use mt_74_psid, clear
keep if treat==1
* collapse id treat re78 re74 re75 km km_prime dist re78_0 re78_1 re74_0m re75_0m re74_1m re75_1m, by(index)
merge m:1 index using nsw_dw, keepusing(education)
drop if _merge != 3
drop _merge
rename education education_control

merge m:1 id using nsw_dw, keepusing(education)
drop if _merge != 3
drop _merge
rename education education_treatment

collapse index education_treatment education_control treat re78 re74 re75 km km_prime dist re78_0 re78_1 re74_0m re75_0m re74_1m re75_1m, by(id)
save mt_74_psid_education

twoway (scatter education_control id, ms(O) mc(red) msize(small)) (scatter education_treatment id, ms(O) mc(blue) msize(small))
twoway (scatter education_treatment education_control, ms(O) mc(red) msize(small)) 

sum education_control
sum education_treatment
ttest education_control == education_treatment


** 4
use nonexp_var, clear
capture gen re74_2 = re74*re74
capture gen re75_2 = re75*re75
save nonexp_var, replace

nnmatch re78 treat re74 re75 education black hispanic married re74_2 re75_2, pop m(1) keep(mt_nonex_78_all) tc(att) replace
use mt_nonex_78_all, clear
collapse treat re78 re74 re75 education black hispanic married re74_2 re75_2 km km_prime index dist re78_0 re78_1 re74_0m re75_0m education_0m black_0m hispanic_0m married_0m re74_2_0m re75_2_0m re74_1m re75_1m education_1m black_1m hispanic_1m married_1m re74_2_1m re75_2_1m, by(id)
keep if treat==1

ttest re74_0m == re74_1m 
ttest re75_0m == re75_1m 
ttest education_0m == education_1m 
ttest black_0m == black_1m 
ttest hispanic_0m == hispanic_1m 
ttest married_0m == married_1m 
ttest re74_2_0m == re74_2_1m 
ttest re75_2_0m == re75_2_1m

use exp_var, clear
capture gen re74_2 = re74*re74
capture gen re75_2 = re74*re74
save exp_var, replace

nnmatch re78 treat re74 re75 education black hispanic married re74_2 re75_2, pop m(1) keep(mt_ex_78_all) tc(att) replace

** 5
use nonexp_var, clear
psmatch2 treat education married black hispanic re74 re75 re74_2 re75_2, out(re78) logit ate neighbor(1)
pstest age education black hispanic married nodegree re74 re75 re74_2 re75_2, t(treat) mw(_weight) graph
psgraph

** 6
use exp_var, clear
gen age_2 = age*age
save exp_var, replace

psmatch2 treat education married black hispanic re74 re75 re74_2 re75_2, out(re78) logit ate neighbor(1)

* baseline experimental treatment effect:
reg re78 treat age age_2 education nodegree black hispanic re74 re75, robust
ttest re78, by(treat) 

** 7
use nonexp_var, clear
gen age_2 = age*age
gen re74_3 = re74^3
gen edu_2 = education*education
gen age_3 = age^3
gen nodg_black = nodegree*black
gen nodg_mar = nodegree*married
gen nodg_age = nodegree*age

gen re74_nodg = re74*nodegree
gen re75_nodg = re74*nodegree
gen re74_black = re74*black
gen re74_edu = re74*education
gen re74_mar = re74*married
gen re75_black = re75*black
gen re75_edu = re75*education
gen re75_mar = re75*married
gen edu_mar = education*married
gen black_education = black*education
gen black_mar = black*married

gen re74_hispanic = re74*hispanic
gen re75_hispanic = re75*hispanic

save nonexp_var, replace

psmatch2 treat age age_2 education edu_2 married nodegree black hispanic re74 re75 re74_2 re75_2 re74_3 age_3, out(re78) logit ate neighbor(1)

* psmatch2 treat age age_2 education edu_2 married nodegree black hispanic re74 re75 re74_2 re75_2 re74_3 nodg_black, out(re78) logit ate neighbor(1)
* psmatch2 treat age age_2 education edu_2 married nodegree black hispanic re74 re75 re74_2 re75_2 re74_3 re74_nodg, out(re78) logit ate neighbor(1)
* psmatch2 treat age age_2 education edu_2 married nodegree black hispanic re74 re75 re74_2 re75_2 re74_3 re74_nodg re74_mar re75_mar edu_mar re74_black age_3, out (re78) logit ate neighbor(1)
* psmatch2 treat age age_2 education edu_2 married nodegree black hispanic re74 re75 re74_2 re75_2 re74_3 nodg_age, out (re78) logit ate neighbor(1)

pstest age education black hispanic married nodegree re74 re75 re74_2 re75_2, t(treat) mw(_weight) graph
pstest age age_2 education edu_2 married nodegree black hispanic re74 re75 re74_2 re75_2 re74_3 age_3, t(treat) mw(_weight) graph
psgraph


** 8 
use nonexp_var, clear
 * use Q5 specification
logit treat education married black hispanic re74 re75 re74_2 re75_2
predict ps_score_q5

/*gen inver_ps_q5 = ((treat-ps_score_q5)/(ps_score_q5*(1-ps_score_q5))) gen ate_inver_ps_q5 = re78*inver_ps_q5 sum ate_inver_ps_q5*/

egen pr_t = mean(treat)
gen effect_inver_ps_q5 = (1/pr_t)*re78*((treat-ps_score_q5)/(1-ps_score_q5))
sum effect_inver_ps_q5

 * use Q7 specification

logit treat age age_2 education edu_2 married nodegree black hispanic re74 re75 re74_2 re75_2 re74_3 age_3
predict ps_score_q7

/*gen inver_ps_q7 = ((treat-ps_score_q7)/(ps_score_q7*(1-ps_score_q7))) gen ate_inver_ps_q7 = re78*inver_ps_q7 sum ate_inver_ps_q7*/

egen pr_t_2 = mean(treat)
gen effect_inver_ps_q7 = (1/pr_t_2)*re78*((treat-ps_score_q7)/(1-ps_score_q7))
sum effect_inver_ps_q7
