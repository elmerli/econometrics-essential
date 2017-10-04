capture log close
log using "sample_matching", text replace
/****************************************************************************
Program Name:   sample_matching.do
Author:         Zongyang Li
Date Created:   06 Dec 2016
Project:        Propensity Score Matching
****************************************************************************/

clear all
clear matrix
macro drop _all
set more off, perm
set maxvar 10000

cd "C:/Users/zongyangli/aem/sample_matching"

* ssc install nnmatch
* ssc install psmatch2
* ssc install teffects

********************************************************************************
* Create Summary Statistics Table, Do t-test
*****

qui{
	capture program drop make_table
	program define make_table
		syntax varlist(numeric)
		
			matrix table1 = J(4, 8, .)
			matrix colnames table1 = `varlist'
			matrix rownames table1 = trt_mean comp_mean diff_mean diff_se

			local i = 1
			foreach var in `varlist' {

				qui ttest `var', by(treat)
				
				matrix table1[1, `i'] = round(r(mu_2), 0.01)
				matrix table1[2, `i'] = round(r(mu_1), 0.01)
				matrix table1[3, `i'] = round(r(mu_1)-r(mu_2), 0.01)
				matrix table1[4, `i'] = round(r(se), 0.01)
				
				local i = `i'+1
			}

			matrix list table1
	end
}


use "nsw_dw.dta", clear

keep if data_id == "Dehejia-Wahba Sample"

make_table age education black hispanic nodegree married re74 re75

/*
                 age  education      black   hispanic   nodegree    married       re74       re75
 trt_mean      25.82      10.35        .84        .06        .71        .19    2095.57    1532.06
comp_mean      25.05      10.09        .83        .11        .83        .15    2107.03    1266.91
diff_mean       -.76       -.26       -.02        .05        .13       -.04      11.45    -265.15
  diff_se        .68        .17        .04        .03        .04        .04     516.48     303.16
*/

use "nsw_dw.dta", clear

drop if data_id == "Dehejia-Wahba Sample" & treat == 0

make_table age education black hispanic nodegree married re74 re75

/*
                 age  education      black   hispanic   nodegree    married       re74       re75
 trt_mean      25.82      10.35        .84        .06        .71        .19    2095.57    1532.06
comp_mean      34.85      12.12        .25        .03        .31        .87   19428.75   19063.34
diff_mean       9.03       1.77       -.59       -.03        -.4        .68   17333.17   17531.28
  diff_se        .78        .23        .03        .01        .04        .03     990.69    1001.91
*/


********************************************************************************
* Direct Matching with Graph showing Matching Results
******


use "nsw_dw.dta", clear

drop if data_id == "Dehejia-Wahba Sample" & treat == 0

* Prep data sets for mergin back in after matching procedure
* create id and index vars to match on
gen id = _n
gen index = _n

* rename variables to accomdate wide format created by matching
preserve
rename * *_1m
rename id_1m id
save "treat", replace
restore

preserve
rename * *_0m
rename index_0m index
save "comparison", replace
restore


nnmatch re78 treat re74 re75, keep(match_info) replace

/*
----------+----------------------------------------------------------------
     re78 |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
----------+----------------------------------------------------------------
     SATE |  -10475.37   3936.875    -2.66   0.008     -18191.5   -2759.233
----------+----------------------------------------------------------------
*/



use "match_info", clear

keep if treat == 1

* merge back in other covariates dropped in matching process
merge m:1 id using "treat", ///
	keepusing(age_1m education_1m black_1m hispanic_1m married_1m nodegree_1m) ///
	keep(master match) nogen

merge m:1 index using "comparison", ///
	keepusing(age_0m education_0m black_0m hispanic_0m married_0m nodegree_0m) ///
	keep(master match) nogen

* get one row per observation (from tie matches)
collapse (mean) re74_* re75_* education_* index, by(id)

* check quality of matching for re74
twoway (scatter re74_0m re74_1m) (lfit re74_0m re74_1m) || ///
	function y = x, ra(re74_0m) clpat(dash)
graph export "plot1.png", replace

reg re74_0m re74_1m
	* R-squared     =  0.9977

* check quality of matching for re74
twoway (scatter re75_0m re75_1m) (lfit re75_0m re75_1m)  || ///
	function y = x, ra(re75_0m) clpat(dash)
graph export "plot2.png", replace

reg re75_0m re75_1m
	* R-squared     =  0.9929

	
********************************************************************************
* Check Matching Balance with Graph
******

* check balance of education treatment and matched comparison
twoway (scatter education_0m education_1m) (lfit education_0m education_1m) || ///
	function y = x, ra(education_0m) clpat(dash)
graph export "plot3.png", replace

ttest education_1m ==  education_0m
	* mean(diff) -.9477146   (se) .2238233


********************************************************************************
* Propensity Score Matching with Graph
*******

use "nsw_dw.dta", clear

drop if data_id == "Dehejia-Wahba Sample" & treat == 0

gen re74_sq = re74 ^ 2
gen re75_sq = re75 ^ 2

local covariates "education black hispanic married re74 re75 re74_sq re75_sq"

nnmatch re78 treat `covariates', keep(match_info2) replace

*        re78 |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
*-------------+----------------------------------------------------------------
*        SATE |  -11653.45   3990.061    -2.92   0.003    -19473.83   -3833.078


use "match_info2", clear

keep if treat == 1

* merge back in other covariates dropped in matching process
merge m:1 id using "treat", keepusing(age nodegree_1m) keep(master match) nogen

merge m:1 index using "comparison", keepusing(age nodegree_0m) keep(master match) nogen

drop re74 re75 re74_sq re75_sq
local collapse_vars = "treat re78_* age_* education_* black_* hispanic_* nodegree_* married_* re74_* re75_* km index dist"

collapse (mean) `collapse_vars', by(id) 

local vars "age education black hispanic nodegree married re74 re75"

matrix table1 = J(3, 8, .)
matrix colnames table1 = `vars'
matrix rownames table1 = trt_mean comp_mean diff_se

matrix list table1 

local i = 1
foreach var in `vars' {

	qui ttest `var'_0m == `var'_1m
	
	matrix table1[1, `i'] = round(r(mu_2), 0.01)
	matrix table1[2, `i'] = round(r(mu_1), 0.01)
	matrix table1[3, `i'] = round(r(se), 0.01)
	
	local i = `i'+1
}

* Assess the quality of the matches for each covariate
matrix list table1

*              age  education  black  hispanic  nodegree  married     re74     re75
* trt_mean   25.82      10.35    .84       .06       .71      .19  2095.57  1532.06
*comp_mean   29.34       10.3    .84       .06       .71      .19  2521.42  1712.76
*  diff_se     .82        .03      0         0         0        0   113.68   114.88

ttest re78_1 == re78_0

*        |      Mean  Std. Err. 
* re78_1 |  6349.144   578.4229   
* re78_0 |  4951.368    557.107   
*--------+----------------------
*  diff  | 1397.775     777.192

* Ha: mean(diff) != 0  
* Pr(|T| > |t|) = 0.0737 



use "nsw_dw.dta", clear
keep if data_id == "Dehejia-Wahba Sample"
ttest re78, by(treat) 

* Experimental treatment effect estimate
/* --------------------------------------
------------------------------------------------------------------------------
   Group |     Obs        Mean    Std. Err.   Std. Dev.   [95% Conf. Interval]
---------+--------------------------------------------------------------------
 Control |     260    4554.801    340.0931    5483.836    3885.102    5224.501
 Treated |     185    6349.144    578.4229    7867.402    5207.949    7490.338
---------+--------------------------------------------------------------------
    diff |           -1794.342    632.8534                -3038.11   -550.5745
------------------------------------------------------------------------------

 Ha: diff != 0 
 Pr(|T| > |t|) = 0.0048 
 
*/
 
********************************************************************************
* Test Matching Validity
******

use "nsw_dw.dta", clear

drop if data_id == "Dehejia-Wahba Sample" & treat == 0

gen re74_sq = re74 ^ 2
gen re75_sq = re75 ^ 2

local spec_5_vars "education black hispanic married re74 re75 re74_sq re75_sq"

qui logit treat `spec_5_vars'

predict p_score

save "spec_5", replace

psgraph, t(treat) p(p_score)
graph export "plot4.png", replace

* randomize sort of dataset so ties are matched at random
set seed 20161206
gen u = uniform()
sort u

psmatch2 treat, pscore(p_score) outcome(re78) neighbor(1) ate

local covariates "age education black hispanic nodegree married re74 re75"

pstest `covariates'

************************************************************
************************************************************
********************    END PROGRAM    *********************
************************************************************
************************************************************

log close

