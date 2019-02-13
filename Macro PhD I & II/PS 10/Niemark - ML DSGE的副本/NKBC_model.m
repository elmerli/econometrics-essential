function [T,R,eu] = NKBC_model(tau,beta,theta,phi_pi,phi_y,varphi, alpha, eps,rho_v,rho_a,rho_z,rho_u,sigma_v,sigma_a,sigma_z,sigma_u)

% % Calibration
% tau       = 2;  % Since I am using sigma for the standard deviaion of the shocks, I am using tau to denote the CRRA parameter.  
% beta      = 0.95; % discount factor
% theta     = 2/3; % degree of price stickiness
% phi_pi    = 1.5; % taylor rule parameter
% phi_y     = 0.5/4; % taylor rule parameter
% varphi    = 0.25; %inverse of elastiicity of labor supply
% alpha     = 1/3; %production function parameter
% eps       = 6; % elasticity of substitution between goods i and j in the consumption basket
% rho_v     = 0.5; %persistence parameter
% rho_a     = 0.9; %persistence parameter
% sigma_v   = 0.25; %standard deviation
% sigma_a   = 1.16; %standard deviation

% -------------------------------------------------------------------------
% Solving a linear rational expectations model through the method of
% undetermined coefficients
% -------------------------------------------------------------------------
% 
% v(1) = sigma_v;
% a(1) = sigma_a;
% for i = 2:12
%     v(i) = rho_v*v(i-1);
% end

% % coefficients obtained from the solution
psi_yna = (1+varphi)/(tau*(1-alpha)+varphi+alpha);
kappa   = (1/theta-1)*(1-beta*theta)*((1-alpha)/(1-alpha+alpha*eps))*(tau+((varphi+alpha)/(1-alpha)));

% -------------------------------------------------------------------------
% Solving a linear rational expectations model using gensys
% -------------------------------------------------------------------------

% Creating coefficient matrices for gensys
Gamma0 = [1 0 (tau^(-1)) (-tau^(-1)) 0 0 0 0 -1 (-tau^(-1));
          -kappa 1 zeros(1,5) -1 0 -beta;
          -phi_y -phi_pi 1 0 -1 zeros(1,5);
          zeros(1,3) 1 0 tau*psi_yna*(1-rho_a) (1-rho_z) 0 0 0;
          zeros(1,4) 1 zeros(1,5);
          zeros(1,5) 1 0 0 0 0;
          zeros(1,6) 1 0 0 0;
          zeros(1,7) 1 0 0;
          1 zeros(1,9);
          0 1 zeros(1,8)];
      
Gamma1 = [zeros(4,10);
          zeros(1,4) rho_v zeros(1,5);
          zeros(1,5) rho_a zeros(1,4);
          zeros(1,6) rho_z zeros(1,3);
          zeros(1,7) rho_u zeros(1,2);
          zeros(1,8) 1 0;
          zeros(1,9) 1];
Psi    = [zeros(4,4);
          eye(4);
          zeros(2,4)];
Pi     = [zeros(8,2);
          eye(2)];      
C      = zeros(10,1);

% Solving the model using gensys - before you use the gensys function, make
% sure you have the functions qzdiv and qzswitch functions in the current folder you are
% working in. Both of these functions are available from Chris Sims webpage
[T,c,R,fmat,fwt,ywt,gev,eu,loose]=gensys(Gamma0,Gamma1,C,Psi,Pi);

