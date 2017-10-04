******************************************************************************
******************************************************************************
*****
*****     AEM PS 3
*****
******************************************************************************
******************************************************************************


*******************
*  Startup
*******************

clear all
set more off
cd "/Users/elmerleezy/Google Drive/Wagner/第三学期/Advan Empirical Method/Problem Sets/PS3"
use "PS 3 - Clark.dta", clear

******************************************
** Question 2 **
******************************************

***Linear

regress dpass vote, r
	capture drop dpass_*
	predict dpass_hat
	label var dpass_hat "linear predict"
	label var dpass "Difference in passrate"
twoway (scatter dpass vote, ms(o) mc(gs4) msize(small)) (line dpass_hat vote,lcolor(purple)), title("Linear Fit of Regression") 
	
***quadratic

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

graph twoway (scatter dpass vote, ms(o) mc(gs4) msize(small)) ///
(line dpass_hat vote, sort lcolor (purple)) ///
(line dpass_hat_p vote, sort lcolor (gs4) lpattern(dash)) ///
(line dpass_hat_m vote, sort lcolor (gs4) lpattern(dash)), xline(50, lcolor(red)) ///
 title("Quadratic Fit with +/- One SE", color(gs0)) legend(off)


* NOT successful using win=1 or 0, generate many lines for unknown reason
/*graph twoway (scatter dpass vote, ms(o) mc(gs4) msize(small)) ///
(line dpass_hat vote if win==1, lcolor (purple)) ///
(line dpass_hat vote if win==0, lcolor (purple)) ///
(line dpass_hat_p vote if win==1, lcolor (gs4) lpattern(dash)) ///
(line dpass_hat_p vote if win==0, lcolor (gs4) lpattern(dash)) ///
(line dpass_hat_m vote if win==1, lcolor (gs4) lpattern(dash)) ///
(line dpass_hat_m vote if win==0, lcolor (gs4) lpattern(dash)), xline(50, lcolor(red)) legend(off)  title("Quadratic fit", color(gs0)) */

* Don't use qfit here, use line instead
/*graph twoway (scatter dpass vote, ms(o) mc(gs4) msize(small)) ///
(qfit dpass_hat vote if win==1, lcolor (purple)) ///
(qfit dpass_hat vote if win==0, lcolor (purple)) ///
(qfit dpass_hat_p vote if win==1, lcolor (gs4) lpattern(dash)) ///
(qfit dpass_hat_p vote if win==0, lcolor (gs4) lpattern(dash)) ///
(qfit dpass_hat_m vote if win==1, lcolor (gs4) lpattern(dash)) ///
(qfit dpass_hat_m vote if win==0, lcolor (gs4) lpattern(dash)), xline(50, lcolor(red)) legend(off)  title("Quadratic fit", color(gs0))  
*/
 
***Cubic fit  

 gen vote3 = vote^3
 gen vote3_win = vote3*win
 gen vote3_lose = vote3*(1-win)
 
 regress dpass vote vote2 vote_win vote_lose vote2_win vote2_lose vote3 vote3_win vote3_lose,r
	capture drop dpass_*
	predict dpass_hat
	predict dpass_se, stdp

	gen dpass_hat_p=dpass_hat+2*dpass_se
	gen dpass_hat_m=dpass_hat-2*dpass_se

graph twoway (scatter dpass vote, ms(o) mc(gs4) msize(small)) ///
(line dpass_hat vote, sort lcolor (purple)) ///
(line dpass_hat_p vote, sort lcolor (gs4) lpattern(dash)) ///
(line dpass_hat_m vote, sort lcolor (gs4) lpattern(dash)), xline(50, lcolor(red)) ///
 title("Cubit Fit with +/- One SE", color(gs0)) legend(off)

* For cubic fit, don't use lpoly, since its local 
/*graph twoway (scatter dpass vote, ms(o) mc(gs4) msize(small)) ///
(lpoly dpass_hat vote if win==1, lcolor (purple)) ///
(lpoly dpass_hat vote if win==0, lcolor (purple)) ///
(lpoly dpass_hat_p vote if win==1, lcolor (gs4) lpattern(dash)) ///
(lpoly dpass_hat_p vote if win==0, lcolor (gs4) lpattern(dash)) ///
(lpoly dpass_hat_m vote if win==1, lcolor (gs4) lpattern(dash)) ///
(lpoly dpass_hat_m vote if win==0, lcolor (gs4) lpattern(dash)), xline(50, lcolor(red)) legend(off)*/


 * polynomial fit
graph twoway (scatter dpass vote, ms(o) mc(gs4) msize(small)) ///
(lpolyci dpass vote if win==1, level(48.47) lcolor (purple)) ///
(lpolyci dpass vote if win==0, level(48.47) lcolor (purple)), xline(50, lcolor(red)) ///
 title("Polynomial Fit with +/- One SE", color(gs0)) legend(off)


******************************************
** Question 3 **
******************************************


capture gen d=vote-50
capture gen d2=d^2
capture gen d_win = d*win
capture gen d2_win=d2*win
capture gen d_lose = d*(1-win)
capture gen d2_lose = d2*(1-win)
capture gen d3 = d^3
capture gen d3_win = d3*win
capture gen d3_lose = d3*(1-win)

reg dpass win if d>-35 & d<35,r
outreg2 win d using myreg1.doc, replace se excel ctitle(+/- 35% binary) 
reg dpass win d if d>-35 & d<35,r 
outreg2 win d using myreg1.doc, append se excel ctitle(+/- 35% linear) 
reg dpass win d d_win d2_win d_lose d2_lose if d>-35 & d<35,r 
outreg2 using myreg1.doc, append se excel ctitle(+/- 35% quadratic) 
reg dpass win d d_win d2_win d_lose d2_lose d3_win d3_lose if d>-35 & d<35,r 
outreg2 using myreg1.doc, append se excel ctitle(+/- 35% cubic) 

reg dpass win if d>-10 & d<10,r
outreg2 win d using myreg1.doc, append se excel ctitle(+/- 10% binary) 
reg dpass win d if d>-10 & d<10,r 
outreg2 win d using myreg1.doc, append se excel ctitle(+/- 10% linear) 
reg dpass win d d_win d2_win d_lose d2_lose if d>-10 & d<10,r 
outreg2 using myreg1.doc, append se excel ctitle(+/- 10% quadratic) 
reg dpass win d d_win d2_win d_lose d2_lose d3_win d3_lose if d>-10 & d<10,r 
outreg2 using myreg1.doc, append se excel ctitle(+/- 10% cubic) 

reg dpass win if d>-5 & d<5,r
outreg2 win d using myreg1.doc, append se excel ctitle(+/- 5% binary) 
reg dpass win d if d>-5 & d<5,r 
outreg2 win d using myreg1.doc, append se excel ctitle(+/- 5% linear) 
reg dpass win d d_win d2_win d_lose d2_lose if d>-5 & d<5,r 
outreg2 using myreg1.doc, append se excel ctitle(+/- 5% quadratic) 
reg dpass win d d_win d2_win d_lose d2_lose d3_win d3_lose if d>-5 & d<5,r 
outreg2 using myreg1.doc, append se excel ctitle(+/- 5% cubic) 

* add br noaster for outreg2: outreg2 win d using myreg1.doc, br noaster replace se excel ctitle(+/- 35% binary) 
* will make there no p-value in the table 

* 4
reg passrate2 win if d>-35 & d<35,r
outreg2 win d using myreg2.doc, replace se excel ctitle(+/- 35% binary) 
reg passrate2 win d if d>-35 & d<35,r 
outreg2 win d using myreg2.doc, append se excel ctitle(+/- 35% linear) 
reg passrate2 win d d_win d2_win d_lose d2_lose if d>-35 & d<35,r 
outreg2 using myreg2.doc, append se excel ctitle(+/- 35% quadratic) 
reg passrate2 win d d_win d2_win d_lose d2_lose d3_win d3_lose if d>-35 & d<35,r 
outreg2 using myreg2.doc, append se excel ctitle(+/- 35% cubic) 

reg passrate2 win if d>-10 & d<10,r
outreg2 win d using myreg2.doc, append se excel ctitle(+/- 10% binary) 
reg passrate2 win d if d>-10 & d<10,r 
outreg2 win d using myreg2.doc, append se excel ctitle(+/- 10% linear) 
reg passrate2 win d d_win d2_win d_lose d2_lose if d>-10 & d<10,r 
outreg2 using myreg2.doc, append se excel ctitle(+/- 10% quadratic) 
reg passrate2 win d d_win d2_win d_lose d2_lose d3_win d3_lose if d>-10 & d<10,r 
outreg2 using myreg2.doc, append se excel ctitle(+/- 10% cubic) 

reg passrate2 win if d>-5 & d<5,r
outreg2 win d using myreg2.doc, append se excel ctitle(+/- 5% binary) 
reg passrate2 win d if d>-5 & d<5,r 
outreg2 win d using myreg2.doc, append se excel ctitle(+/- 5% linear) 
reg passrate2 win d d_win d2_win d_lose d2_lose if d>-5 & d<5,r 
outreg2 using myreg2.doc, append se excel ctitle(+/- 5% quadratic) 
reg passrate2 win d d_win d2_win d_lose d2_lose d3_win d3_lose if d>-5 & d<5,r 
outreg2 using myreg2.doc, append se excel ctitle(+/- 5% cubic) 


reg passrate2 win if vote>=15 & vote <=85, r

rd dpass d, gr mbw(100) line(xline(0,lcolor(black))) z0(0)
rd passrate2 d, gr mbw(100) line(xline(0,lcolor(black))) z0(0)
 * lwald estimator 

 * 5

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
	
graph twoway (scatter passrate0 vote, ms(o) mc(gs4) msize(small)) ///
(line p0_hat vote if vote>=40 & vote <=60, sort lcolor (purple)) ///
(line p0_hat_p vote if vote>=40 & vote <=60, sort lcolor (gs4) lpattern(dash)) ///
(line p0_hat_m vote if vote>=40 & vote <=60, sort lcolor (gs4) lpattern(dash)), xline(50, lcolor(red)) legend(off)  title("Passrate0", color(gs0))  


* 6
graph twoway (histogram d if d<0)(histogram d if d>=0),xline(0,lcolor(red))
DCdensity d, breakpoint(0) generate(Xj Yj r0 fhat se_fhat)
capture drop Yj Xj r0 fhat se_fhat
DCdensity win, breakpoint(0) generate(Xj Yj r0 fhat se_fhat)

* 7 

rd dpass d, mbw(75(5)125) bdep ox

* standard error doen't change much












