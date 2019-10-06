%%
%%%% Bineet Mishra %%%%
%%%% Macroeconomics 7440 PS3  %%%%

clc;
clear all;
close all;

%% Problem 3
% Parameters
b3=0.7;                  % value of nonmarket activity
alpha=0.5;              % matching function elasticity
sigma_m=0.139;          % matching function efficiency
beta=0.99^(1/13);       % discount factor
delta=.0081;            % separation probability
rho_y=0.9895;           % labor productivity autoregressive parameter
sigma_y=0.0034;         % labor productivity standard deviation
theta_ss=1;             % tightness parameter steady state
n_y=7;                  % grid points of y
n_bi=10^3*13;           % burn-in sample
n_s=10^4*13;            % generate stats for next period
n_sim=n_bi+n_s;         % simulation period
%y_sim0=zeros(n_sim,1);  % productivity
%w_sim0=zeros(n_sim,1);  % wages
%u_sim0=zeros(n_sim,1);  % unemployment
%v_sim0=zeros(n_sim,1);  % vacanies
%th_sim0=zeros(n_sim,1); % market tightness
theta0=0.5*ones(1,n_y); % initial market tightness
c0=0;

% state space of y and the probability matrix 
[y,P] = rouwenhorst(rho_y,sigma_y,n_y);
y=exp(y);

% steady state value of p and q
p_theta_ss=min(sigma_m*theta_ss^(1-alpha),1);
q_theta_ss=min(sigma_m*theta_ss^(-alpha),1);

% Global variable
global parameter_y parameter_P parameter_ny parameter_alpha parameter_beta...
       parameter_delta parameter_sigmam parameter_thetass parameter_q_theta_ss...
       parameter_theta0 parameter_c0 parameter_nsim parameter_nbi
parameter_y=y;
parameter_P=P;
parameter_ny=n_y;
parameter_y=y;
parameter_P=P;
parameter_alpha=alpha;
parameter_beta=beta;
parameter_delta=delta;
parameter_sigmam=sigma_m;
parameter_thetass=theta_ss;
parameter_q_theta_ss=q_theta_ss;
parameter_theta0=theta0;
parameter_c0=c0;
n_sim1=10000;
n_bi1=500;
parameter_nsim=n_sim1;
parameter_nbi=n_bi1;

% Steady state value of c
gamma3=0.5;

c_ss=beta*(1-gamma)*q_theta_ss*(-b/(1-beta*(1-delta+gamma*p_theta_ss)));

%c_ss=beta*(1-gamma)*q_theta_ss*(-b/(1-beta*(1-delta)+beta*gamma*p_theta_ss));
c_res= @(c) evalcss(b3,gamma3,c,beta,delta,theta_ss,q_theta_ss);
c_ss3 = fsolve(c_res,c0);


% Compute theta
f=@(th)sysnleq(th,y,P,b3,gamma3,alpha,sigma_m,beta,delta,c_ss3,n_y);
theta3=fsolve(f,theta0);

% Simulate the data
[y_sim,w_sim,u_sim,v_sim,th_sim]=simul(y,P,n_y,c_ss3,b3,gamma3,alpha,delta,...
                                       q_theta_ss,sigma_m,theta3,n_sim);
                                   
% Post burn-in period
y_sim=y_sim(n_bi+1:end);   
w_sim=w_sim(n_bi+1:end);   
u_sim=u_sim(n_bi+1:end);   
v_sim=v_sim(n_bi+1:end);   
th_sim=th_sim(n_bi+1:end);
n_sim_T = 1:n_s;
plot(n_sim_T,y_sim);

% Evaluate the statistics
[sd3,ar3,corrmat3,w_y_average3,w_y_cy3]= evaluate(y_sim,w_sim,u_sim,...
                                                  v_sim,th_sim);




%% Problem 4

% Steady state value of c
b4=0.95;
gamma4=0.05;
c_res= @(c) evalcss(b4,gamma4,c,beta,delta,theta_ss,q_theta_ss);
c_ss4 = fsolve(c_res,c0);

% Compute theta
f=@(th)sysnleq(th,y,P,b4,gamma4,alpha,sigma_m,beta,delta,c_ss4,n_y);
theta4=fsolve(f,theta0);

% Simulate the data
[y_sim,w_sim,u_sim,v_sim,th_sim]=simul(y,P,n_y,c_ss4,b4,gamma4,alpha,delta,...
                                       q_theta_ss,sigma_m,theta4,n_sim);

% Post burn-in period
y_sim=y_sim(n_bi+1:end);   
w_sim=w_sim(n_bi+1:end);   
u_sim=u_sim(n_bi+1:end);   
v_sim=v_sim(n_bi+1:end);   
th_sim=th_sim(n_bi+1:end);

% Evaluate the statistics
[sd4,ar4,corrmat4,w_y_average4,w_y_cy4]= evaluate(y_sim,w_sim,u_sim,...
                                                  v_sim,th_sim);
                                              
 %% 5 Nelder-Mead method to determine b and gamma

% Initial values, max and min
parameters0 = [0.5;0.5];
parametersmin = [0;0];
parametersmax = [10;1];


% Get the optimal parameter values
parametersf = neldmead_bounds(@evalbg,parameters0,parametersmin,parametersmax);
b_ned= parametersf(1);
gamma_ned= parametersf(2);

c_res= @(c) evalcss(b_ned,gamma_ned,c,beta,delta,theta_ss,q_theta_ss);
c_ss5 = fsolve(c_res,c0);


% Compute theta
f=@(th)sysnleq(th,y,P,b_ned,gamma_ned,alpha,sigma_m,beta,delta,c_ss5,n_y);
theta5=fsolve(f,theta0);

% Simulate the data
[y_sim,w_sim,u_sim,v_sim,th_sim]=simul(y,P,n_y,c_ss5,b_ned,gamma_ned,alpha,delta,...
                                       q_theta_ss,sigma_m,theta5,n_sim);

% Post burn-in period
y_sim=y_sim(n_bi+1:end);   
w_sim=w_sim(n_bi+1:end);   
u_sim=u_sim(n_bi+1:end);   
v_sim=v_sim(n_bi+1:end);   
th_sim=th_sim(n_bi+1:end);

% Evaluate the statistics
[sd5,ar5,corrmat5,w_y_average5,w_y_cy5]= evaluate(y_sim,w_sim,u_sim,...
                                                  v_sim,th_sim);
 













