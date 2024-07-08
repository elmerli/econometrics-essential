function F = PS3_sde(x, eta, a_e, a_h, rho_e, rho_h, phi, sigma, q_last)
    % [x(1), x(2), x(3)] = [q, kappa, sigma_q]
    iota = (x(1)-1)/phi;
    q_prime = (eta==0)*((-x(1)*rho_e + x(1)*rho_h) / (-1/phi - (eta * rho_e + (1-eta) * rho_h) - x(3))) + ...
              (eta>0)*((x(1)-q_last)/0.0001);
    % Equations
    F1 = (x(2)*a_e) + (1-x(2))*a_h - iota - x(1)*(eta*rho_e + (1-eta)*rho_h);
    F2 = q_prime*(x(2)-eta)*(sigma+x(3)) - x(3)*x(1); 
    F3 = (a_e-a_h) - x(1)*(x(2)-eta)*(sigma+x(3))^2 / (1-eta)*eta;
    F = [F1; F2; F3]; % output vector F
end