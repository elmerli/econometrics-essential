/****************************************************************************
Econ7420 PS 1
Author: Elmer Li    
****************************************************************************/
	clear all
	global data /Users/zongyangli/Google Drive/Cornell PhD/3rd Semester/Labor Seminar/PS/PS 1
	global work /Users/zongyangli/Google Drive/Cornell PhD/3rd Semester/Labor Seminar/PS/PS 1

********************************************************************************
* DD
*****

* import data
	cd "$data"
	insheet using dd.csv, comma

* Q1.1 some checks
	// indvidual level data (unique)
	tab city // 31 states, 1245 cities
	tab state cb_year // state 22 and 31 pass statewide law, both in 1989
	tab city if state != 22 & state != 31 & cb_year != 0

* Q1.2 state level analysis
	* a. compare states
		gen treat = state == 22 | state == 31
		preserve
			* draw line graph showing average wage overtime
			collapse (mean) wage, by (treat year)
			graph twoway (line wage year if treat==0, msymbol(Oh)) (line wage year if treat==1, msymbol(Oh)), ///
				legend (label(1 "other states") label(2 "states 22 & 31")) ///
				title("Treated vs control states average wage overtime")
				graph export "Q1_2-a.png", replace
		restore

	* b. DD regression
		levelsof year
		foreach y in `r(levels)' {
			gen y_`y' = year==`y' // gen year dummies
		}
		gen post_state = y_1989 == y_1989 == 1 // both 89 & 90 are post period
		areg wage c.treat#c.post_state (y_1981-y_1988), absorb(state)
			outreg2 using DD_state_basic.xls,replace ctitle(state FE)  dec(3) pdec(3)

	* c. compare coefficients
		egen state_year = group(state year)
		areg wage c.treat#c.post_state (y_1981-y_1988), absorb(state) vce(cluster state)
			outreg2 using DD_state.xls,replace ctitle(state FE cls state)  dec(4) pdec(4)
		areg wage c.treat#c.post_state (y_1981-y_1988), absorb(state) vce(cluster state_year)
			outreg2 using DD_state.xls,append ctitle(state FE cls state_year)  dec(4) pdec(4)
		areg wage c.treat#c.post_state (y_1981-y_1988), absorb(state) vce(cluster city)
			outreg2 using DD_state.xls,append ctitle(state FE cls city)  dec(4) pdec(4)
		areg wage c.treat#c.post_state (y_1981-y_1988), absorb(city) vce(cluster state)
			outreg2 using DD_state.xls,append ctitle(city FE cls state)  dec(4) pdec(4)
		areg wage c.treat#c.post_state (y_1981-y_1988), absorb(city) vce(cluster city)
			outreg2 using DD_state.xls,append ctitle(city FE cls city)  dec(4) pdec(4)

	save dd_state, replace

* Q1.3 city level analysis 
	drop if state == 22 | state == 31

	* a. DD regression
		gen treat_city = cb_year != 0 // if cb_year is not empty, meaning the city has passed law at some pt
		gen post_city = year > cb_year // the year greater than cb_year is post period
		save dd_city, replace
		areg wage c.treat_city#c.post_city (y_1981-y_1990), absorb(city) vce(cluster city)
			outreg2 using DD_city_basic.xls,replace ctitle(city FE cls city)  dec(3) pdec(3)

	* b. graph average wage for different cb_year
		* tabulate cb_year, generate(cb_year)
		collapse (mean) wage, by (cb_year year)
		graph twoway (line wage year if cb_year==0) (line wage year if cb_year==1986) (line wage year if cb_year==1987) (line wage year if cb_year==1988) (line wage year if cb_year==1989), ///
			legend (label(1 "cities w/ no law") label(2 "cities w/ 1986 law") label(3 "cities w/ 1987 law") label(4 "cities w/ 1988 law") label(5 "cities w/ 1989 law")) ///
			title("Average wage overtime") ///
			subtitle("cities with different years passing law")
			graph export "Q1_3-b.png", replace
	
	* c. event study
	use dd_city, clear
		
		* c.II treatment years
		gen t = year - cb_year
		forvalues t = 0(1)4 {
			gen trt_p`t' = t == `t'
			}
		forvalues t = -9(1)-1 {
			local k = abs(`t')
			gen trt_m`k' = t == `t'
			}
		* check - OK
			// gen treat_city_post = treat_city==post_city==1
			// gen treat_city_post_2 = trt_p1+trt_p2+trt_p3+trt_p4
			// gen treat_city_post_check = treat_city_post_2 - treat_city_post

		* c.III DD regression - event study
		areg wage trt_m9 trt_m8 trt_m7 trt_m6 trt_m5 trt_m4 trt_m3 trt_m2 trt_p0 trt_p1 trt_p2 trt_p3 trt_p4 (y_1981-y_1990), absorb(city) vce(cluster city)
			outreg2 using DD_city_event_std.xls,replace ctitle(city FE cls city)  dec(3) pdec(3)
		
		* c.IV plot graph
			* save coefficients & std err
				gen beta = . 
				gen se = . 
					forvalues t = 0(1)4 {
						replace beta = _b[trt_p`t'] if t == `t'
						replace se = _se[trt_p`t'] if t == `t'
						}
					forvalues t = -9(1)-2 {
						local k = abs(`t')
						replace beta = _b[trt_m`k'] if t == `t'
						replace se = _se[trt_m`k'] if t == `t'
						}
				gen ci_low = beta - 1.96*se
				gen ci_high = beta + 1.96*se
			* collapse data & draw graph
				collapse (mean) beta se ci_low ci_high, by (t)
					drop if t > 4 | t == -1
					label var t "years to policy implementation"
					label var beta "coefficient"
				graph twoway (scatter beta t, connect(direct)) (rcap ci_low ci_high t), ///
					legend (label(1 "coefficients") label(2 "confidence interval")) ///
					title("Event study - bargaining law")
					graph export "Q1_3-c.png", replace

		* c.V add linear trend in control
		use dd_city, clear
		areg wage c.treat_city#c.post_city (y_1981-y_1990) i.state#c.year, absorb(city) vce(cluster city) // understanding of linear trend: specific state, across years
			outreg2 using DD_city_basic.xls, append ctitle(city FE cls city linear trend)  dec(3) pdec(3)


********************************************************************************
* RD
*****

* import data
	clear
	insheet using rd.csv, comma

* Q2.1 Choice of running variable
	bysort major: sum cutoff // quite lot variation in cutoff conditional on major across years
	bysort year: sum test // around 5000-7000 students per year

	* create useful variables
		gen score = test - cutoff
		bysort year major: egen rank_raw = rank(test) // gen raw rank
		gen score_abs = abs(score) // distance from cutoff
		bysort year major: egen rank_abs = rank(score_abs), track // calculate ranking based on distance to cutoff
		gen rank_cut = rank_raw if rank_abs == 1 // use the nearest rank as the base to be deducted
		bysort year major: egen rank_base = max(rank_cut) // fill the values
		gen rank = rank_raw - rank_base
		drop rank_* score_*
		save rd, replace

	* make density histogram
		histogram score if abs(rank) <= 50, width(2) density normal normopts(lpattern(longdash)) kdensity kdenopts(lcolor(yellow)) ///
			title("Density of score")
			graph export "Q2_1-b1.png", replace
		histogram rank if abs(rank) <= 50, width(2) density normal normopts(lpattern(longdash)) kdensity kdenopts(lcolor(yellow)) ///
			title("Density of rank")
			graph export "Q2_1-b2.png", replace

* Q2.2 RD bandwidth
	* a. select bandwith
		foreach Y in "admit_flag" "enrol_flag" "enrol_any" "grad_flag" "grad_any" {
			rdbwselect `Y' rank, c(0)
		}
	
* Q2.3 RD graph
	use rd, clear
	drop if abs(rank) >= 50
	egen bin = cut(rank), at(-50,-40,-30,-20,-10,0,10,20,30,40,50)
	* a & b. graph for enrol_any
		* polynomial regression
		foreach Y in  "admit_flag" "enrol_flag" "enrol_any" "grad_flag" "grad_any" {
			lpoly `Y' rank if rank >= 0, at(rank) degree(1) gen(pred_above_`Y') nograph
				replace pred_above_`Y' = . if rank < 0
			lpoly `Y' rank if rank <= 0, at(rank) degree(1) gen(pred_below_`Y') nograph
				replace pred_below_`Y' = . if rank > 0
			* collapse & graph
			preserve
				collapse (mean) `Y' pred_*, by (bin)
				graph twoway (scatter `Y' bin) (line pred_below_`Y' bin) (line pred_above_`Y' bin), ///
					legend (label(1 "average `Y'") label(2 "predicted(below)") label(3 "predicted(above)")) ///
					xline(0, lcolor(red)) ///
					xtitle("Ranking distance to cutoff") ///
					title("Regression dicountinuity - `Y'")
					graph export "Q2_3-`Y'.png", replace
			restore
		}

* Q2.4 RD regression
	use rd, clear
	gen rank_ge0 = rank >= 0
	* a. base 
		lpoly grad_any rank if rank >= 0, bw(25) at(rank) degree(1)
		reg grad_any rank_ge0 rank c.rank_ge0#c.rank if abs(rank) <= 25, robust // robust std error
			outreg2 using RD.xls, replace ctitle(base robust)  dec(3) pdec(3)		
		reg grad_any rank_ge0 rank c.rank_ge0#c.rank if abs(rank) <= 25, vce(cluster rank) // cluster std error at rank level	
			outreg2 using RD.xls, append ctitle(base cluster rank)  dec(3) pdec(3)		

	* b. add interactions
		reg grad_any rank_ge0 rank c.rank_ge0#c.rank i.major#i.year if abs(rank) <= 25, vce(cluster rank)
			outreg2 using RD.xls, append ctitle(add major*year)  dec(3) pdec(3)		
		reg grad_any rank_ge0 rank c.rank_ge0#c.rank i.major#i.year#c.rank if abs(rank) <= 25, vce(cluster rank) 
			outreg2 using RD.xls, append ctitle(add rank*major*year)  dec(3) pdec(3)

	* c. different specifications
		* create polynomials
			forvalues power = 2(1)6{
				gen rank_`power' = rank^`power'
			}
		*regressions
			foreach bdwith in "12" "25" "50" "2000" {
				reg grad_any rank_ge0 rank c.rank_ge0#c.rank if abs(rank) <= `bdwith', vce(cluster rank)
					outreg2 using RD_`bdwith'.xls, replace ctitle(RD `bdwith' spline 1)  dec(3) pdec(3)		
				reg grad_any rank_ge0 rank c.rank_ge0#c.rank c.rank_ge0#c.rank_2 if abs(rank) <= `bdwith', vce(cluster rank)
					outreg2 using RD_`bdwith'.xls, append ctitle(RD `bdwith' spline 2)  dec(3) pdec(3)		
				reg grad_any rank_ge0 rank c.rank_ge0#c.rank c.rank_ge0#c.rank_2 c.rank_ge0#c.rank_3 if abs(rank) <= `bdwith', vce(cluster rank)
					outreg2 using RD_`bdwith'.xls, append ctitle(RD `bdwith' spline 3)  dec(3) pdec(3)		
				reg grad_any rank_ge0 rank c.rank_ge0#c.rank c.rank_ge0#c.rank_2 c.rank_ge0#c.rank_3 c.rank_ge0#c.rank_4 if abs(rank) <= `bdwith', vce(cluster rank)
					outreg2 using RD_`bdwith'.xls, append ctitle(RD `bdwith' spline 4)  dec(3) pdec(3)		
				reg grad_any rank_ge0 rank c.rank_ge0#c.rank c.rank_ge0#c.rank_2 c.rank_ge0#c.rank_3 c.rank_ge0#c.rank_4 c.rank_ge0#c.rank_5 if abs(rank) <= `bdwith', vce(cluster rank)
					outreg2 using RD_`bdwith'.xls, append ctitle(RD `bdwith' spline 5)  dec(3) pdec(3)		
				reg grad_any rank_ge0 rank c.rank_ge0#c.rank c.rank_ge0#c.rank_2 c.rank_ge0#c.rank_3 c.rank_ge0#c.rank_4 c.rank_ge0#c.rank_5 c.rank_ge0#c.rank_6 if abs(rank) <= `bdwith', vce(cluster rank)
					outreg2 using RD_`bdwith'.xls, append ctitle(RD `bdwith' spline 6)  dec(3) pdec(3)		
			}	










************************************************************
************************************************************
********************    END PROGRAM    *********************
************************************************************
************************************************************

log close


