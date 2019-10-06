function[sd,ar,corrmat,w_y_average,w_y_cy]=evaluate(y_sim,w_sim,u_sim,v_sim,th_sim)

% HP filter
[t_y,c_y]=hpfilter(y_sim,1600);
[t_w,c_w]=hpfilter(w_sim,1600);
[t_u,c_u]=hpfilter(u_sim,1600);
[t_v,c_v]=hpfilter(v_sim,1600);
[t_th,c_th]=hpfilter(th_sim,1600);

% Standard deviation
sigma_y = std(c_y);
sigma_w = std(c_w);
sigma_u = std(c_u);
sigma_v = std(c_v);
sigma_th = std(c_th);
sd=[sigma_u sigma_v sigma_th sigma_y];

% Autocorrelation
temp=autocorr(c_y,1);
ar_y=temp(2);
temp=autocorr(c_w,1);
ar_w=temp(2);
temp=autocorr(c_u,1);
ar_u=temp(2);
temp=autocorr(c_v,1);
ar_v=temp(2);
temp=autocorr(c_th,1);
ar_th=temp(2);
ar=[ar_u ar_v ar_th ar_y];

% Correlation matrix
temp = corrcoef(u_sim,u_sim);
corrmat(1,1) = temp(1,2);
temp = corrcoef(u_sim,v_sim);
corrmat(1,2) = temp(1,2);
temp = corrcoef(u_sim,th_sim);
corrmat(1,3) = temp(1,2);
temp = corrcoef(u_sim,y_sim);
corrmat(1,4) = temp(1,2);

temp = corrcoef(v_sim,v_sim);
corrmat(2,2) = temp(1,2);
temp = corrcoef(v_sim,th_sim);
corrmat(2,3) = temp(1,2);
temp = corrcoef(v_sim,y_sim);
corrmat(2,4) = temp(1,2);

temp = corrcoef(th_sim,th_sim);
corrmat(3,3) = temp(1,2);
temp = corrcoef(th_sim,y_sim);
corrmat(3,4) = temp(1,2);

temp = corrcoef(y_sim,y_sim);
corrmat(4,4) = temp(1,2);

% Hagedorn and Manovskii Calibration
w_y = w_sim./y_sim;
w_y_average = mean(w_y);
w_y_cy=regress(c_w,c_y);