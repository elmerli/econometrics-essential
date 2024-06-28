function F = eqm_q_iota(x, rho_e, rho_h, a_e, delta, phi, ell, eta_t, kappa_t)
    q = x(1); iota = x(2);
    F(1) = iota - (q - 1) / phi; 
    F(2) = q*(eta_t * (rho_e-rho_h)+rho_h) - kappa_t*(a_e-iota) - (1-kappa_t)*(a_e*kappa_t-iota); 
end
