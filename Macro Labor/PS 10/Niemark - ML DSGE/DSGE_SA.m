% Set up and estimate miniture DSGE model
clc
clear all
close all
global Z
load('Z'); %load data. Order of variables: Inflation, output, interest rate, labor supply

figure(1)
subplot(2,2,1);
plot(Z(1,:),'linewidth',2);title('Output','fontsize',16);
subplot(2,2,2);
plot(Z(2,:),'linewidth',2);title('Inflation','fontsize',16)
subplot(2,2,3);
plot(Z(3,:),'linewidth',2);title('Nominal Interest Rate','fontsize',16)
subplot(2,2,4);
plot(Z(4,:),'linewidth',2);title('Labor ','fontsize',16)

% cmt: the Z is the data matrix, with rows containing output, inflation, interest rate, labor supply


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initial values of structural parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tau       = 3;  % Since I am using sigma for the standard deviaion of the shocks, I am using tau to denote the CRRA parameter.
beta      = 0.99; % discount factor
theta     = 3/4; % degree of price stickiness
phi_pi    = 1.5; % taylor rule parameter
phi_y     = 0.125; % taylor rule parameter
varphi    = 3; %inverse of elastiicity of labor supply
alpha     = 1/3; %production function parameter
eps       = 6; % elasticity of substitution between goods i and j in the consumption basket
rho_v     = 0.5; %persistence parameter
rho_a     = 0.75; %persistence parameter
rho_z = 0.5; %persistence parameter 
rho_u = 0.8; %persistence parameter 
sigma_v   = 0.02; %standard deviation
sigma_a   = (0.012^2*(1-rho_a^2))^.5; %standard deviation of innovation to a_t
sigma_z = 1; %std deviation of z 
sigma_u = 1; %std dev of u 


THETA=[tau,beta,theta,phi_pi,phi_y,varphi,alpha,eps,rho_v,rho_a,rho_z,rho_u,sigma_v,sigma_a,sigma_z,sigma_u;]';%Starting value for parameter vector
LB=[0,0,0,1,0,1,0,1,zeros(1,6)]';%Lower bound for parameter vector
UB=[10,1,1,5,5,10,1,25,1,1,10,10,10,10]';%Upper bound for parameter vector
x=THETA;

% x=THETA;
sa_t= 5;
sa_rt=.3;
sa_nt=5;
sa_ns=5;
% warning off all;

%% Simulated Annealing
[xhat]=simannb( 'LLDSGE', x, LB, UB, sa_t, sa_rt, sa_nt, sa_ns, 1); % the minimization is over the LLDSGE function

%--------------------------------------------------------------------------
thetalabel=['tau    ';'beta   ';'theta  ';'phi_pi ';'phi_y  ';'varphi ';'alpha  ';'eps    ';'rho_v  ';'rho_a  ';'rho_z  ';'rho_u  ';'sigmav ';'sigmaa ';'sigmaz ';'sigmau ';];
disp('ML estimate of THETA')
disp([thetalabel, num2str(xhat)])
%--------------------------------------------------------------------------
%% Compute recursive likelihood using the Kalman filter
a_hat = filter_gap_DSGE(xhat,Z);
% the function filter_gap_DSGE calls 'NKBC_model'
figure(2)
plot(Z(1,:),'linewidth',2);hold on;plot(a_hat,'linewidth',2)
legend('Output','Output gap')*1



%% Compute impulse responses
time = 0:10;   % set time horizon
col = T;   % start impulse matrix
for j=1:length(time)
    resp(:,:,j)=D*col; % compute observations
    col=A*col;  % compute next period states
end

for i = 1:4 % four different shocks 
    % Extract impulse responses for observations
    % Which response belong to which depend on the set up of D matrix
    resp_pi(:,i)=squeeze(resp(1,i,:));
    resp_y(:,i)=squeeze(resp(2,i,:));
    resp_i(:,i)=squeeze(resp(3,i,:));
    % resp_n(:,i)=squeeze(resp(4,i,:));
    
    % Plot Impulse Responses
    figure(i)
    subplot(1,3,1); plot(time,resp_pi(:,i),'-O'); title('Inflation'); grid on;
    subplot(1,3,2); plot(time,resp_y(:,i),'-O'); title('Output'); grid on;
    subplot(1,3,3); plot(time,resp_i(:,i),'-O'); title('Nominal Interest Rate'); grid on;
    % subplot(2,3,1); plot(time,resp_n(:,i),'-O'); title('Labor'); grid on;
end

% Print Impulse Responses - Monetary Shock
figure(1)
saveas(gcf, 'impulse_monetary.png')
% Print Impulse Responses - Productivity Shock
figure(2)
saveas(gcf, 'impulse_prod.png')
% Print Impulse Responses - Demand Shock
figure(3)
saveas(gcf, 'impulse_demand.png')
% Print Impulse Responses - Cost-push Shock
figure(4)
saveas(gcf, 'impulse_cost.png')


