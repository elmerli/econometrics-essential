
********************************************************************************
* Question 4
*****

* import data
	cd "/Users/zongyangli/Google Drive/Cornell PhD/3rd Semester/Empirical Strategy/Problem sets/"
	use kenya, clear
	label var educ_attain "follow-up education attainment"
	label var math "follow-up whether math score"
	label var cognitive "follow-up whether cognitive score"
	label var vocab "follow-up whether vocab score"

* 4a) descriptives & ttest by groups
	ssc install asdoc
	* summary statistics
	asdoc sum grade winn01 winn02 age01 test00 test01 test02 educ_attain in_school math cognitive vocab, stat(N mean sd p50) by(treat) replace save(sum_stat.doc)
	* t-test
	asdoc ttest grade, by(treat) replace save(t_stat.doc)
	foreach var of varlist winn01 winn02 age01 test00 test01 test02 educ_attain in_school math cognitive vocab {
		asdoc ttest `var', by(treat) rowappend save(t_stat.doc)
	}

	
* 4b) regression & scater plot

* regression 

	* baseline
	reg test01 treat if c1 == 1, robust
	outreg2 using Regression.xls,append ctitle(baseline c1)  dec(3) pdec(3)
	reg test02 treat if c1 == 0, robust
	outreg2 using Regression.xls,append ctitle(baseline c2)  dec(3) pdec(3)
	
	* control pre-treatment test score
	reg test01 treat test00 if c1 == 1, robust
	outreg2 using Regression.xls,append ctitle(control pre-test c1)  dec(3) pdec(3)
	reg test02 treat test00 if c1 == 0, robust
	outreg2 using Regression.xls,append ctitle(control pre-test c2)  dec(3) pdec(3)

	* regress on difference
	gen test01_diff = test01 - test00
	gen test02_diff = test02 - test00
	
	reg test01_diff treat if c1 == 1, robust
	outreg2 using Regression.xls,append ctitle(reg diff c1)  dec(3) pdec(3)
	reg test02_diff treat if c1 == 0, robust
	outreg2 using Regression.xls,append ctitle(reg diff c2)  dec(3) pdec(3)

	* another method: residualization

	* scatter plot	
		* set scheme uncluttered, permanent
		* 01 cohort
		graph twoway (scatter test01 test00 if c1==1 & treat == 0, msymbol(Oh)) (scatter test01 test00 if c1==1 & treat == 1, msymbol(d)), ///
			legend (label(1 "control group") label(2 "treatment group")) ///
			title("Pre/after-treatment test score") ///
			subtitle("cohort 1")
			graph export "test_pre_after_c1.png", replace
		* 02 cohort
		graph twoway (scatter test02 test00  if c1==0 & treat == 0, msymbol(Oh)) (scatter test02 test00 if c1==0 & treat == 1, msymbol(d)), ///
			legend (label(1 "control group") label(2 "treatment group")) ///
			title("Pre/after-treatment test score") ///
			subtitle("cohort 2")
			graph export "test_pre_after_c2.png", replace


* 4c) kernel density for 2000 test scores
	kdensity test00, kernel(epanechnikov) title("Epanechnikov kernel") subtitle("optimal bandwidth")
	graph export "kernel_epanechnikov_opt.png", replace
	kdensity test00, kernel(epanechnikov) bwidth(0.05) title("Epanechnikov kernel") subtitle("0.05 bandwidth")
	graph export "kernel_epanechnikov_005.png", replace
	kdensity test00, kernel(epanechnikov) bwidth(0.5) title("Epanechnikov kernel") subtitle("0.5 bandwidth")
	graph export "kernel_epanechnikov_05.png", replace
	kdensity test00, kernel(gaussian) title("Gaussian kernel")
	graph export "kernel_gaussian_opt.png", replace

* 4d) kernel density compare treat & control
    kdensity test00 if (treat == 0), plot(kdensity test00 if (treat == 1)) legend(ring(0) pos(2) label(1 "control") label(2 "treatment")) title("Epanechnikov kernel") subtitle("Treatment v.s. control, 2000")
	graph export "kernel_epanechnikov_treat_control_00.png", replace
    kdensity test01 if (treat == 0), plot(kdensity test01 if (treat == 1)) legend(ring(0) pos(2) label(1 "control") label(2 "treatment")) title("Epanechnikov kernel") subtitle("Treatment v.s. control, 2001")
	graph export "kernel_epanechnikov_treat_control_01.png", replace
    kdensity test02 if (treat == 0), plot(kdensity test02 if (treat == 1)) legend(ring(0) pos(2) label(1 "control") label(2 "treatment")) title("Epanechnikov kernel") subtitle("Treatment v.s. control, 2002")
	graph export "kernel_epanechnikov_treat_control_02.png", replace
	










