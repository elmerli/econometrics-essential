
capture program drop value_added
program value_added
	
	* residualize
		local person_char "lang0_zs_3 math0_zs_3 mean_lang0_zs_ty_3 mean_math0_zs_ty_3"
		areg `1' `person_char' (y_1-y_3) `2', absorb(teacher)
		predict `1'_resid, dresiduals 

	* collapse data
		bysort teacher year: gen num_students = _N
		collapse (mean) `1'_resid num_students, by (teacher year)

	* compute gamma
		* calcualte autocovariance
			by teacher: gen `1'_resid_lag1 = `1'_resid[_n + 1]
			by teacher: gen `1'_resid_lag2 = `1'_resid[_n + 2]
			by teacher: gen `1'_resid_lag3 = `1'_resid[_n + 3]

			correlate `1'_resid `1'_resid [aweight=num_students], covariance
				global cov_lag0 = r(cov_12)
			correlate `1'_resid `1'_resid_lag1 [aweight=num_students], covariance
				global cov_lag1 = r(cov_12)
			correlate `1'_resid `1'_resid_lag2 [aweight=num_students], covariance
				global cov_lag2 = r(cov_12)
			correlate `1'_resid `1'_resid_lag3 [aweight=num_students], covariance
				global cov_lag3 = r(cov_12)
		* form gamma
			matrix gamma0 = ($cov_lag1 \ $cov_lag2 \ $cov_lag3)
			matrix gamma1 = ($cov_lag1 \ $cov_lag1 \ $cov_lag2)
			matrix gamma2 = ($cov_lag2 \ $cov_lag1 \ $cov_lag1)
			matrix gamma3 = ($cov_lag3 \ $cov_lag2 \ $cov_lag1)

	* reshape data
		drop `1'_resid_lag1 `1'_resid_lag2 `1'_resid_lag3
		reshape wide num_students `1'_resid, i(teacher) j(year)

	* compute VA using matrix
		* compute A matrix
			mkmat `1'_resid1 `1'_resid2 `1'_resid3, matrix(A0)
			mkmat `1'_resid0 `1'_resid2 `1'_resid3, matrix(A1)
			mkmat `1'_resid0 `1'_resid1 `1'_resid3, matrix(A2)
			mkmat `1'_resid0 `1'_resid1 `1'_resid2, matrix(A3)
		* compute sigma	
			correlate `1'_resid1 `1'_resid2 `1'_resid3, covariance
				matrix sigma_inv0 = inv(r(C))
			correlate `1'_resid0 `1'_resid2 `1'_resid3, covariance
				matrix sigma_inv1 = inv(r(C))
			correlate `1'_resid0 `1'_resid1 `1'_resid3, covariance
				matrix sigma_inv2 = inv(r(C))
			correlate `1'_resid0 `1'_resid1 `1'_resid2, covariance
				matrix sigma_inv3 = inv(r(C))
		* multiply to get mu, save as variable
			forvalues t = 0(1)3{
				matrix mu`t' = ((sigma_inv`t'*gamma`t')'*A`t'')'
				svmat mu`t'
			} 
			rename (mu01-mu31) (mu0 mu1 mu2 mu3)

	* reshape and check
		reshape long `1'_resid num_students mu, i(teacher) j(year)
			rename mu mu_`1'`2'

end

