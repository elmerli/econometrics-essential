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

	* f. reshape data
		drop math1_zs_resid_lag1 math1_zs_resid_lag2 math1_zs_resid_lag3
		reshape wide num_students math1_zs_resid, i(teacher) j(year)

	* g. compute VA using matrix
		* compute A matrix
			mkmat math1_zs_resid1 math1_zs_resid2 math1_zs_resid3, matrix(A_0)
			mkmat math1_zs_resid0 math1_zs_resid2 math1_zs_resid3, matrix(A_1)
			mkmat math1_zs_resid0 math1_zs_resid1 math1_zs_resid3, matrix(A_2)
			mkmat math1_zs_resid0 math1_zs_resid1 math1_zs_resid2, matrix(A_3)
		* compute sigma	
			correlate math1_zs_resid1 math1_zs_resid2 math1_zs_resid3, covariance
				matrix sigma_inv0 = inv(r(C))

				matrix var_cov = r(C)
				global cov_math1_00 = var_cov[1,1]
				global cov_math1_01 = var_cov[2,1]
				global cov_math1_02 = var_cov[3,1]
				global cov_math1_03 = var_cov[4,1]
				global cov_math1_11 = var_cov[2,2]
				global cov_math1_12 = var_cov[3,2]
				global cov_math1_13 = var_cov[4,2]
				global cov_math1_22 = var_cov[3,3]
				global cov_math1_23 = var_cov[4,3]
				global cov_math1_33 = var_cov[4,4]

			matrix sigma0 = ($cov_math1_11,$cov_math1_12,$cov_math1_13 \ $cov_math1_12, $cov_math1_22, $cov_math1_23 \ $cov_math1_13, $cov_math1_23, $cov_math1_33)
			 matrix sigma_inv0 = inv(sigma0)
			matrix sigma1 = ($cov_math1_00,$cov_math1_02,$cov_math1_03 \ $cov_math1_02, $cov_math1_22, $cov_math1_23 \ $cov_math1_03, $cov_math1_23, $cov_math1_33)
			 gen sigma_inv1 = inv(sigma1)
			matrix sigma2 = ($cov_math1_00,$cov_math1_01,$cov_math1_03 \ $cov_math1_01, $cov_math1_11, $cov_math1_13 \ $cov_math1_03, $cov_math1_13, $cov_math1_33)
			 gen sigma_inv2 = inv(sigma2)
			matrix sigma3 = ($cov_math1_00,$cov_math1_01,$cov_math1_02 \ $cov_math1_01, $cov_math1_11, $cov_math1_12 \ $cov_math1_02, $cov_math1_12, $cov_math1_22)
			 gen sigma_inv3 = inv(sigma3)
		


		




************************************************************
************************************************************
********************    END PROGRAM    *********************
************************************************************
************************************************************

log close


