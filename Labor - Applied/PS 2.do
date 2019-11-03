/****************************************************************************
Econ7420 PS 2
Author: Elmer Li    
****************************************************************************/
	clear all
	global data /Users/zongyangli/Google Drive/Cornell PhD/3rd Semester/Labor Seminar/PS/PS 2
	global work /Users/zongyangli/Google Drive/Cornell PhD/3rd Semester/Labor Seminar/PS/PS 2

********************************************************************************
* DD
*****

* import data
	cd "$data"
	insheet using va.csv, comma

* Q1 some checks
	duplicates report ind // 140 teachers

* Q2 math value added
	* a. standardize test scores
		foreach score in lang0 math0 lang1 math1 grit1 {
			bysort year: egen mean_`score' = mean(`score')
			bysort year: egen sd_`score' = sd(`score')
			bysort year: gen `score'_zs = (`score'-mean_`score')/sd_`score'
				drop mean_`score' sd_`score'
		}
	* b. caculate residual
		* gen individual char
			bysort teacher year: egen mean_lang0_zs_ty = mean(lang0_zs)
			bysort teacher year: egen mean_math0_zs_ty = mean(math0_zs)
				foreach score in lang0_zs math0_zs mean_lang0_zs_ty mean_math0_zs_ty {
					gen `score'_3 = `score'^3
				}
			* year FE
			levelsof year
			foreach y in `r(levels)' {
				gen y_`y' = year==`y' // gen year dummies
			}
		* residualize
			local person_char "lang0_zs_3 math0_zs_3 mean_lang0_zs_ty_3 mean_math0_zs_ty_3"
			areg math1_zs `person_char' (y_1-y_3), absorb(teacher)
			predict math1_zs_resid, residuals 

	* c. collapse data
		bysort teacher year: gen num_students = _N
		collapse (mean) math1_zs_resid num_students, by (teacher year)

	* e. compute gamma
		* calcualte autocovariance
			by teacher: gen math1_zs_resid_lag1 = math1_zs_resid[_n + 1]
			by teacher: gen math1_zs_resid_lag2 = math1_zs_resid[_n + 2]
			by teacher: gen math1_zs_resid_lag3 = math1_zs_resid[_n + 3]

			correlate math1_zs_resid math1_zs_resid [aweight=num_students], covariance
				global cov_math1_lag0 = r(cov_12)
			correlate math1_zs_resid math1_zs_resid_lag1 [aweight=num_students], covariance
				global cov_math1_lag1 = r(cov_12)
			correlate math1_zs_resid math1_zs_resid_lag2 [aweight=num_students], covariance
				global cov_math1_lag2 = r(cov_12)
			correlate math1_zs_resid math1_zs_resid_lag3 [aweight=num_students], covariance
				global cov_math1_lag3 = r(cov_12)
		* form gamma
			matrix gamma0 = ($cov_math1_lag1 \ $cov_math1_lag2 \ $cov_math1_lag3)
			matrix gamma1 = ($cov_math1_lag1 \ $cov_math1_lag1 \ $cov_math1_lag2)
			matrix gamma2 = ($cov_math1_lag2 \ $cov_math1_lag1 \ $cov_math1_lag1)
			matrix gamma3 = ($cov_math1_lag3 \ $cov_math1_lag2 \ $cov_math1_lag1)

	* f. reshape data
		drop math1_zs_resid_lag1 math1_zs_resid_lag2 math1_zs_resid_lag3
		reshape wide num_students math1_zs_resid, i(teacher) j(year)

	* g. compute VA using matrix
		* compute A matrix
			mkmat math1_zs_resid1 math1_zs_resid2 math1_zs_resid3, matrix(A0)
			mkmat math1_zs_resid0 math1_zs_resid2 math1_zs_resid3, matrix(A1)
			mkmat math1_zs_resid0 math1_zs_resid1 math1_zs_resid3, matrix(A2)
			mkmat math1_zs_resid0 math1_zs_resid1 math1_zs_resid2, matrix(A3)
		* compute sigma	
			correlate math1_zs_resid1 math1_zs_resid2 math1_zs_resid3, covariance
				matrix sigma_inv0 = inv(r(C))
			correlate math1_zs_resid0 math1_zs_resid2 math1_zs_resid3, covariance
				matrix sigma_inv1 = inv(r(C))
			correlate math1_zs_resid0 math1_zs_resid1 math1_zs_resid3, covariance
				matrix sigma_inv2 = inv(r(C))
			correlate math1_zs_resid0 math1_zs_resid1 math1_zs_resid2, covariance
				matrix sigma_inv3 = inv(r(C))
		* multiply to get mu, save as variable
			forvalues t = 0(1)3{
				matrix mu`t' = ((sigma_inv`t'*gamma`t')'*A`t'')'
				svmat mu`t'
			} 
			rename (mu01-mu31) (mu0 mu1 mu2 mu3)

	* h. compute VA using OLS
		reg math1_zs_resid0 math1_zs_resid1 math1_zs_resid2 math1_zs_resid3 [aweight=num_students0], robust
			predict mu_ols0
		reg math1_zs_resid1 math1_zs_resid0 math1_zs_resid2 math1_zs_resid3 [aweight=num_students1], robust
			predict mu_ols1
		reg math1_zs_resid2 math1_zs_resid0 math1_zs_resid1 math1_zs_resid3 [aweight=num_students2], robust
			predict mu_ols2
		reg math1_zs_resid3 math1_zs_resid0 math1_zs_resid1 math1_zs_resid2 [aweight=num_students3], robust
			predict mu_ols3

	* i. reshape and check
		reshape long math1_zs_resid num_students mu mu_ols, i(teacher) j(year)
			correlate math1_zs_resid mu mu_ols



		




************************************************************
************************************************************
********************    END PROGRAM    *********************
************************************************************
************************************************************

log close


