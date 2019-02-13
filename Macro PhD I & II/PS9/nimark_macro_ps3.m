Question (1-4) 
%% Housekeeping
close all;
clear all;

%-------------------------------------------------------------------------
% Solving a linear rational expectations model using gensys
% -------------------------------------------------------------------------
% Calibration
sigma = 2; %CRRA parameter
beta = 0.99; %discount factor
phi = 3; %inverse elasticity of labor supply 
eps = 5; %elasticity of substitution between goods 
phi_pi = 1.5 %taylor rule parameter 
phi_y = 0.5; %taylor rule parameter 
theta = 0.75; %degree of price stickiness
alpha = 0.3; %production function parameter
rho_a = 0.95; %persistence parameter
rho_v = 0; %persistence parameter 
rho_z = 0.5; %persistence parameter 
rho_u = 0.8; %persistence parameter 
sigma_a = 1; %std deviation of a
sigma_v = 0.05; %std deviation of v 
sigma_z = 1; %std deviation of z 
sigma_u = 1; %std dev of u 

%compute the coefficients
rho = -log(beta); 
lambda = (1-theta)*(1-beta*theta)*(1-alpha)/(theta*(1-alpha+alpha*eps)); 
kappa = lambda*(sigma + (phi+alpha)/(1-alpha)); 
psi_ya = (1+phi)/(sigma*(1-alpha)+phi+alpha); 
 
% Creating coefficient matrices for gensys
Gamma0 = [kappa -kappa 0 0 0 0 0 0 -1 0 0;
    0 -kappa 1 0 0 0 0 0 -1 0 -beta;
    0 1 0 -1/sigma 1/sigma 0 0 0 0 -1 -1/sigma;
    -phi_y 0 -phi_pi 0 1 -1 -phi_y*psi_ya 0 0 0 0;
    0 0 0 1 0 0 sigma*(1-rho_a)*psi_ya -(1-rho_z) 0 0 0;
    0 0 0 0 0 1 0 0 0 0 0;
    0 0 0 0 0 0 1 0 0 0 0;
    0 0 0 0 0 0 0 1 0 0 0;
    0 0 0 0 0 0 0 0 1 0 0;
    0 1 0 0 0 0 0 0 0 0 0;
    0 0 1 0 0 0 0 0 0 0 0];
 
Gamma1 = [0 0 0 0 0 0 0 0 0 0 0;
          0 0 0 0 0 0 0 0 0 0 0;
          0 0 0 0 0 0 0 0 0 0 0;
          0 0 0 0 0 0 0 0 0 0 0;
          0 0 0 0 0 0 0 0 0 0 0;
          0 0 0 0 0 rho_v 0 0 0 0 0;
          0 0 0 0 0 0 rho_a 0 0 0 0;
          0 0 0 0 0 0 0 rho_z 0 0 0;
          0 0 0 0 0 0 0 0 rho_u 0 0;
          0 0 0 0 0 0 0 0 0 1 0;
          0 0 0 0 0 0 0 0 0 0 1];
 
Psi = [ 0 0 0 0 0 1 0 0 0 0 0;
        0 0 0 0 0 0 1 0 0 0 0;
        0 0 0 0 0 0 0 1 0 0 0;
        0 0 0 0 0 0 0 0 1 0 0;]';
 
Pi = [0 0 0 0 0 0 0 0 0 1 0;
      0 0 0 0 0 0 0 0 0 0 1]';
 
Cons = [0 0 0 0 0 0 0 0 0 0 0]';
 
% Solve New Keynesian Model
[A,~,R,~,~,~,~,eu,~]=gensys(Gamma0,Gamma1,Cons,Psi,Pi);
 
C = R*[sigma_v 0 0 0;
       0 sigma_a 0 0;
       0 0 sigma_z 0;
       0 0 0 sigma_u];
 
 
% Set up measurement matrix Z(t) = D*X(t)
 D = [0 0 1 0 0 0 0 0 0 0 0; % inflation
        1 0 0 0 0 0 0 0 0 0 0; % output
        0 0 0 0 0 0 psi_ya 0 0 0 0;  % output gap
        0 0 0 0 1 0 0 0 0 0 0;  % nominal interest rate
        1/(1-alpha) 0 0 0 0 0 -(1-psi_ya)/(1-alpha) 0 0 0 0]; % labor
    
time = 0:200;   % set time horizon
X(:,1)= zeros(11,1); % starting value for states
 
error = randn(4,size(time,2)); % generate epsilon
 
% Compute state space model recursively
for t=1:size(time,2)-1
    X(:,t+1)=A*X(:,t)+C*error(:,t+1); % X(t+1) = A*X(t) + C*eps(t+1)
    Z(:,t+1)= D*X(:,t+1);   % Z(t+1) = D*X(t+1)
end
 
% Compute model standard deviations
sig_model = sqrt(var(Z'))
 
% Plot simulated state space model
figure(4)
subplot(3,1,1)
plot(time,Z(1,:))
title('Inflation')
subplot(3,1,2)
plot(time,Z(2,:))
title('Output')
subplot(3,1,3)
plot(time,Z(3,:))
title('Nominal Interest Rate')
saveas(gcf, 'simulation.png')
 
 
 
%%Kalman filter
% Set starting values
X0 = zeros(size(A,2),1);    % set starting X
P0 = dlyap(A,C*C'); % set starting for the variance
 
% Compute the Kalman Filter
[ X_post, P_post, X_prior, Z_tilde, Omega] = kfilter(Z, A, C, D, 0, X0, P0 );
 
figure(6)
plot(Z(2,:));
hold
plot(X_post(1,:),'--'); 
legend('Output','Natural Output Level', 'Location', 'best'); grid on;
saveas(gcf, 'kalman.png')


Question (5) 
%% Housekeeping
close all;
clear all;
 
%-------------------------------------------------------------------------
% Solving a linear rational expectations model using gensys
% -------------------------------------------------------------------------
% Calibration
sigma = 2; %CRRA parameter
beta = 0.99; %discount factor
phi = 3; %inverse elasticity of labor supply 
eps = 5; %elasticity of substitution between goods 
phi_pi = 1.5 %taylor rule parameter 
phi_y = 0.5; %taylor rule parameter 
theta = 0.75; %degree of price stickiness
alpha = 0.3; %production function parameter
rho_a = 0.8; %persistence parameter
rho_v = 0.5; %persistence parameter 
rho_z = 0.7; %persistence parameter 
rho_u = 1; %persistence parameter 
sigma_a = 0.008; %std deviation of a
sigma_v = 0.01; %std deviation of v 
sigma_z = 0.03; %std deviation of z 
sigma_u = 1; %std dev of u 
 
%compute the coefficients
rho = -log(beta); 
lambda = (1-theta)*(1-beta*theta)*(1-alpha)/(theta*(1-alpha+alpha*eps)); 
kappa = lambda*(sigma + (phi+alpha)/(1-alpha)); 
psi_ya = (1+phi)/(sigma*(1-alpha)+phi+alpha); 
 
% Creating coefficient matrices for gensys
Gamma0 = [kappa -kappa 0 0 0 0 0 0 -1 0 0;
    0 -kappa 1 0 0 0 0 0 -1 0 -beta;
    0 1 0 -1/sigma 1/sigma 0 0 0 0 -1 -1/sigma;
    -phi_y 0 -phi_pi 0 1 -1 -phi_y*psi_ya 0 0 0 0;
    0 0 0 1 0 0 sigma*(1-rho_a)*psi_ya -(1-rho_z) 0 0 0;
    0 0 0 0 0 1 0 0 0 0 0;
    0 0 0 0 0 0 1 0 0 0 0;
    0 0 0 0 0 0 0 1 0 0 0;
    0 0 0 0 0 0 0 0 1 0 0;
    0 1 0 0 0 0 0 0 0 0 0;
    0 0 1 0 0 0 0 0 0 0 0];
 
Gamma1 = [0 0 0 0 0 0 0 0 0 0 0;
          0 0 0 0 0 0 0 0 0 0 0;
          0 0 0 0 0 0 0 0 0 0 0;
          0 0 0 0 0 0 0 0 0 0 0;
          0 0 0 0 0 0 0 0 0 0 0;
          0 0 0 0 0 rho_v 0 0 0 0 0;
          0 0 0 0 0 0 rho_a 0 0 0 0;
          0 0 0 0 0 0 0 rho_z 0 0 0;
          0 0 0 0 0 0 0 0 rho_u 0 0;
          0 0 0 0 0 0 0 0 0 1 0;
          0 0 0 0 0 0 0 0 0 0 1];
 
Psi = [ 0 0 0 0 0 1 0 0 0 0 0;
        0 0 0 0 0 0 1 0 0 0 0;
        0 0 0 0 0 0 0 1 0 0 0;
        0 0 0 0 0 0 0 0 1 0 0;]';
 
Pi = [0 0 0 0 0 0 0 0 0 1 0;
      0 0 0 0 0 0 0 0 0 0 1]';
 
Cons = [0 0 0 0 0 0 0 0 0 0 0]';
 
% Solve New Keynesian Model
[A,~,R,~,~,~,~,eu,~]=gensys(Gamma0,Gamma1,Cons,Psi,Pi);
 
C = R*[sigma_v 0 0 0;
       0 sigma_a 0 0;
       0 0 sigma_z 0;
       0 0 0 sigma_u];
 
% Set up measurement matrix Z(t) = D*X(t)
 D = [0 0 1 0 0 0 0 0 0 0 0; % inflation
        1 0 0 0 0 0 psi_ya 0 0 0 0; % output
%         1 0 0 0 0 0 0 0 0 0 0;  % output gap
        0 0 0 0 0 0 psi_ya 0 0 0 0; %natural output 
        0 0 0 0 1 0 0 0 0 0 0;  % nominal interest rate
        1/(1-alpha) 0 0 0 0 0 -(1-psi_ya)/(1-alpha) 0 0 0 0]; % labor
    
time = 0:200;   % set time horizon
X(:,1)= zeros(11,1); % starting value for states
 
error = randn(4,size(time,2)); % generate epsilon
 
% Compute state space model recursively
for t=1:size(time,2)-1
    X(:,t+1)=A*X(:,t)+C*error(:,t+1); % X(t+1) = A*X(t) + C*eps(t+1)
    Z(:,t+1)= D*X(:,t+1);   % Z(t+1) = D*X(t+1)
end
 
% Compute model standard deviations
sig_model = sqrt(var(Z'))
 
% Plot simulated state space model
figure(4)
subplot(3,1,1)
plot(time,Z(1,:))
title('Inflation')
subplot(3,1,2)
plot(time,Z(2,:))
title('Output')
subplot(3,1,3)
plot(time,Z(3,:))
title('Nominal Interest Rate')
saveas(gcf, 'simulation_2.png')
 
 
 
%%Kalman filter
% Set starting values
X0 = zeros(size(A,2),1);    % set starting X
P0 = dlyap(A,C*C'); % set starting for the variance
 
% Compute the Kalman Filter
[ X_post, P_post, X_prior, Z_tilde, Omega] = kfilter(Z, A, C, D, 0, X0, P0 );
 
figure(6)
plot(Z(2,:));
hold
plot(X_post(1,:),'--'); 
legend('Output','Natural Output Level', 'Location', 'best'); grid on;
saveas(gcf, 'kalman_2.png')

