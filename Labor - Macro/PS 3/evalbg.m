function res_nel = evalbg(param)

% Elasticity and wage share from data
param_data = [0.449 0.97];

% Elasticity and wage share from calibration
b = param(1);
gamma = param(2);

[n_y,y,P,alpha,beta,delta,sigma_m,theta_ss,q_theta_ss,c0,theta0,n_sim,n_bi]=callparam();
c_res= @(c) evalcss(b,gamma,c,beta,delta,theta_ss,q_theta_ss);
c_ss5 = fsolve(c_res,c0);

% Compute theta
f=@(th)sysnleq(th,y,P,b,gamma,alpha,sigma_m,beta,delta,c_ss5,n_y);
theta5=fsolve(f,theta0);

% Simulate the data
[y_sim,w_sim,u_sim,v_sim,th_sim]=simul(y,P,n_y,c_ss5,b,gamma,alpha,delta,...
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


%res_nel = ((w_y_cy5-param_data(1))/param_data(1))^2 + ((w_y_average5-param_data(2))/param_data(2))^2;
res_nel = ((w_y_cy5-param_data(1)))^2 + ((w_y_average5-param_data(2)))^2;