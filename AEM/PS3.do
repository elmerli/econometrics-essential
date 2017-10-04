capture log close
log using "sample_regression_discountinuity", text replace
/****************************************************************************
Program Name:   sample_regression_discountinuity.do
Author:         Zongyang Li
Date Created:   06 Dec 2016
Project:        Regression Discontinuity
****************************************************************************/

clear all
clear matrix
macro drop _all
set more off, perm
set maxvar 10000

cd "C:/Users/zongyangli/aem/sample_regression_discountinuity"
use "Clark.dta", clear



********************************************************************************
* Q2
*****


* Forcing Linear Fit 

regress dpass vote, r
	capture drop dpass_*
	predict dpass_hat
	label var dpass_hat "linear predict"
	label var dpass "Difference in passrate"

twoway (scatter dpass vote, ms(o) mc(gs4) msize(small)) (line dpass_hat vote,lcolor(purple)), title("Linear Fit of Regression") 
graph export "plot1.png", replace


* Forcing Qudratic Fit 

gen vote2=vote^2
gen vote_win = vote*win
gen vote2_win=vote2*win
gen vote_lose = vote*(1-win)
gen vote2_lose = vote2*(1-win)

reg dpass vote vote2 vote_win vote_lose vote2_win vote2_lose,r 
	capture drop dpass_*
	predict dpass_hat
	predict dpass_se, stdp

	gen dpass_hat_p=dpass_hat+2*dpass_se
	gen dpass_hat_m=dpass_hat-2*dpass_se


twoway (scatter dpass vote, ms(o) mc(gs4) msize(small)) ///
		(line dpass_hat vote, sort lcolor (purple)) ///
		(line dpass_hat_p vote, sort lcolor (gs4) lpattern(dash)) ///
		(line dpass_hat_m vote, sort lcolor (gs4) lpattern(dash)), xline(50, lcolor(red)) ///
 title("Quadratic Fit with +/- One SE", color(gs0)) legend(off)
 graph export "plot2.png", replace


* Forcing Cubic Fit 

 gen vote3 = vote^3
 gen vote3_win = vote3*win
 gen vote3_lose = vote3*(1-win)
 
 regress dpass vote vote2 vote_win vote_lose vote2_win vote2_lose vote3 vote3_win vote3_lose,r
	capture drop dpass_*
	predict dpass_hat
	predict dpass_se, stdp

	gen dpass_hat_p=dpass_hat+2*dpass_se
	gen dpass_hat_m=dpass_hat-2*dpass_se


twoway (scatter dpass vote, ms(o) mc(gs4) msize(small)) ///
		(line dpass_hat vote, sort lcolor (purple)) ///
		(line dpass_hat_p vote, sort lcolor (gs4) lpattern(dash)) ///
		(line dpass_hat_m vote, sort lcolor (gs4) lpattern(dash)), xline(50, lcolor(red)) ///
 title("Cubit Fit with +/- One SE", color(gs0)) legend(off)
 graph export "plot3.png", replace


		 * Extra - Polynomial fit

		twoway (scatter dpass vote, ms(o) mc(gs4) msize(small)) ///
				(lpolyci dpass vote if win==1, level(48.47) lcolor (purple)) ///
				(lpolyci dpass vote if win==0, level(48.47) lcolor (purple)), xline(50, lcolor(red)) ///
		 title("Polynomial Fit with +/- One SE", color(gs0)) legend(off)
         graph export "plot4.png", replace


********************************************************************************
* Q3
*****

capture gen d=vote-50
capture gen d2=d^2
capture gen d_win = d*win
capture gen d2_win=d2*win
capture gen d_lose = d*(1-win)
capture gen d2_lose = d2*(1-win)
capture gen d3 = d^3
capture gen d3_win = d3*win
capture gen d3_lose = d3*(1-win)


* Test for different bandwidth

qui{
	capture program drop myreg1
	program define myreg1

			forvalues i = 35 10 5 {
			qui reg dpass win if d>-`i' & d<`i',r
				outreg2 win d using myreg1.doc, replace se excel ctitle(+/- `i'% binary) 
			qui reg dpass win d if d>-`i' & d<`i',r 
				outreg2 win d using myreg1.doc, append se excel ctitle(+/- `i'% linear) 
			qui reg dpass win d d_win d2_win d_lose d2_lose if d>-`i' & d<`i',r 
				outreg2 using myreg1.doc, append se excel ctitle(+/- `i'% quadratic) 
			qui reg dpass win d d_win d2_win d_lose d2_lose d3_win d3_lose if d>-`i' & d<`i',r 
				outreg2 using myreg1.doc, append se excel ctitle(+/- `i'% cubic) 
					}

	end
}


********************************************************************************
* Q4 
*****

* Change dependent variable
reg passrate0 win, r
outreg2 using myreg3.doc, replace ctitle(passrate0 full sample) 

predict p0_hat
	predict p0_se, stdp

	gen p0_hat_p=p0_hat+2*p0_se
	gen p0_hat_m=p0_hat-2*p0_se

reg passrate0 win if vote>=40 & vote <=60, r
outreg2 using myreg3.doc, append ctitle(passrate0 (40,60)) 

capture drop p0_*
predict p0_hat
	predict p0_se, stdp
	gen p0_hat_p=p0_hat+2*p0_se
	gen p0_hat_m=p0_hat-2*p0_se
	
twoway (scatter passrate0 vote, ms(o) mc(gs4) msize(small)) ///
		(line p0_hat vote if vote>=40 & vote <=60, sort lcolor (purple)) ///
		(line p0_hat_p vote if vote>=40 & vote <=60, sort lcolor (gs4) lpattern(dash)) ///
		(line p0_hat_m vote if vote>=40 & vote <=60, sort lcolor (gs4) lpattern(dash)), xline(50, lcolor(red)) legend(off)  title("Passrate0", color(gs0))  
graph export "plot5.png", replace


* Plot Density
twoway (histogram d if d<0)(histogram d if d>=0),xline(0,lcolor(red))
DCdensity d, breakpoint(0) generate(Xj Yj r0 fhat se_fhat)
capture drop Yj Xj r0 fhat se_fhat
DCdensity win, breakpoint(0) generate(Xj Yj r0 fhat se_fhat)


************************************************************
************************************************************
********************    END PROGRAM    *********************
************************************************************
************************************************************

log close









