% Title: AEM 7500 Proble Set 4: Sinppet of Code for Nonparametric Estimate
% Author: Mengwei Lin
% Date: Apr 28, 2020

%% Question 3)

cd '/Users/zongyangli/Dropbox/Academic 其他/GitHub/econometrics-essential/Phd - resource econ/PS4'

clc 
clear all
close all
% Import the excel
data_array=table2array(readtable('AEM7500_PS4_data_spring2020.xlsx'));

% Initilize the number of actions, states and games
num_a_i = 3;
num_a_j = 3;
num_s_i = 3;
num_s_j = 3;
% the number of games is equal to total observations we have
T = max(size(data_array(:,1))); 

% Initialize vectors holding values of action and state variables
a_i_values_vec=zeros(num_a_i,1);
a_j_values_vec=zeros(num_a_j,1);
s_i_values_vec=zeros(num_s_i,1);
s_j_values_vec=zeros(num_s_j,1);

% Fill in vectors holding values of action and state variables
a_i_values_vec=(0:num_a_i-1)';
a_j_values_vec=(0:num_a_j-1)';
s_i_values_vec=(0:num_s_i-1)';
s_j_values_vec=(0:num_s_j-1)';

% Form numerator/denominator of sigma_array_i: Country Red
sigma_i_numerator_array=zeros(num_a_i,num_s_i,num_s_j);
sigma_i_denominator_array=zeros(num_a_i,num_s_i,num_s_j);
% If we have values equal to zero, we might want to consider initializing
% values equal to negative 999.
for t=1:T
    for a_i_index=1:num_a_i
        for s_i_index=1:num_s_i
            for s_j_index=1:num_s_j
                a_i_value = a_i_values_vec(a_i_index,1);
                s_i_value = s_i_values_vec(s_i_index,1);
                s_j_value = s_j_values_vec(s_j_index,1);
                if ((data_array(t,1)==a_i_value)&... %form the numerator
                        (data_array(t,3)==s_i_value) &...
                        (data_array(t,4)==s_j_value))
                 sigma_i_numerator_array(a_i_index,s_i_index,s_j_index)=...
                  sigma_i_numerator_array(a_i_index,s_i_index,s_j_index)+1;
                end
                if ((data_array(t,3)==s_i_value) &... %form the denominator
                        (data_array(t,4)==s_j_value))
               sigma_i_denominator_array(a_i_index,s_i_index,s_j_index)=...
                sigma_i_denominator_array(a_i_index,s_i_index,s_j_index)+1;
                end
            end
        end
    end
end
sigma_i_array=sigma_i_numerator_array./sigma_i_denominator_array;
% generate a talbe with choice probabilities for Country Red
Table_Red=zeros(num_a_i*num_s_i*num_s_j,4);
index=1;
for s_j_index=1:num_s_j
    for s_i_index=1:num_s_i
        for a_i_index=1:num_a_i
           Table_Red(index,1)=a_i_values_vec(a_i_index,1);
           Table_Red(index,2)=s_i_values_vec(s_i_index,1);
           Table_Red(index,3)=s_j_values_vec(s_j_index,1);
           Table_Red(index,4)=sigma_i_array(a_i_index,s_i_index,s_j_index);
           index=index+1;
        end
    end
end
xlswrite('PS4_Q3_Red.xls', Table_Red)

% Form numerator/denominator of sigma_array_j: Country White
sigma_j_numerator_array=zeros(num_a_j,num_s_i,num_s_j);
sigma_j_denominator_array=zeros(num_a_j,num_s_i,num_s_j);
% If we have values equal to zero, we might want to consider initializing
% values equal to negative 999.
for t=1:T
    for a_j_index=1:num_a_j
        for s_i_index=1:num_s_i
            for s_j_index=1:num_s_j
                a_j_value = a_j_values_vec(a_j_index,1);
                s_i_value = s_i_values_vec(s_i_index,1);
                s_j_value = s_j_values_vec(s_j_index,1);
                if ((data_array(t,2)==a_j_value)&... % form the numerator
                        (data_array(t,3)==s_i_value) &...
                        (data_array(t,4)==s_j_value))
                    sigma_j_numerator_array(a_j_index,s_i_index,s_j_index)=...
                        sigma_j_numerator_array(a_j_index,s_i_index,s_j_index)+1;
                end
                if ((data_array(t,3)==s_i_value) &... % form the denominator
                        (data_array(t,4)==s_j_value))
                    sigma_j_denominator_array(a_j_index,s_i_index,s_j_index)=...
                        sigma_j_denominator_array(a_j_index,s_i_index,s_j_index)+1;
                end
            end
        end
    end
end
sigma_j_array=sigma_j_numerator_array./sigma_j_denominator_array;
% generate a talbe with choice probabilities for Country White
Table_White=zeros(num_a_j*num_s_i*num_s_j,4);
index=1;
for s_j_index=1:num_s_j
    for s_i_index=1:num_s_i
        for a_j_index=1:num_a_j
            Table_White(index,1)=a_j_values_vec(a_j_index,1);
            Table_White(index,2)=s_i_values_vec(s_i_index,1);
            Table_White(index,3)=s_j_values_vec(s_j_index,1);
            Table_White(index,4)=sigma_j_array(a_j_index,s_i_index,s_j_index);
            index=index+1;
        end
    end
end
xlswrite('PS4_Q3_White.xls', Table_White)


%% Question 4) GMM - b
% Step1: Form y_ikt,y_it,y_t
% generate y_it for Country Red
y_it = [];
for t=1:T
    y_ikt=zeros(num_a_i,1);
    for a_i_index=1:num_a_i
        a_i_value=a_i_values_vec(a_i_index, 1);
        if data_array(t,1)==a_i_value
            y_ikt(a_i_index,1)=1;
        end
    end
    y_it=[y_it y_ikt];
end
% generate y_jt for Country White
y_jt = [];
for t=1:T
    y_jkt=zeros(num_a_j,1);
    for a_j_index=1:num_a_j
        a_j_value=a_j_values_vec(a_j_index, 1);
        if data_array(t,2)==a_j_value
            y_jkt(a_j_index, 1)=1;
        end
    end
    y_jt=[y_jt y_jkt];
end
% generate y_t
y_t = [y_it; y_jt]; % a matrix with dimension: n(k+1)*T=2*(2+1)*374=6*374

% Step2: Initialization before the main analysis
% define number of parameters to estimate
num_betas = 6;
% initialize phi arrays for each player
phi_i = zeros(num_betas,num_a_i,num_s_i,num_s_j);
phi_j = zeros(num_betas,num_a_j,num_s_i,num_s_j);
% fill in phi array for country Red
for j=1:num_a_j % to make the index shorter, here i,j,s_i, s_j are indices
    for s_i=1:num_s_i
        for s_j=1:num_s_j
            phi_i(5,1,s_i,s_j)=phi_i(5,1,s_i,s_j)-...
                a_j_values_vec(j)*sigma_j_array(j,s_i,s_j);
        end
    end
end
for i=2:num_a_i % phi is the same for a_R=1,a_R=2
    for j=1:num_a_j 
        for s_i=1:num_s_i 
            for s_j=1:num_s_j
                phi_i(1,i,s_i,s_j)= -a_i_values_vec(i);
                phi_i(2,i,s_i,s_j)= phi_i(2,i,s_i,s_j)-a_i_values_vec(i)...
                    *a_j_values_vec(j)*sigma_j_array(j,s_i,s_j);
                phi_i(4,i,s_i,s_j)= -(2-a_i_values_vec(i))*...
                    s_i_values_vec(s_i);
            end
        end
    end
end
% fill in phi array for country White
for i=1:num_a_i % to make the index shorter, here i,j,s_i, s_j are indices
    for s_i=1:num_s_i 
        for s_j=1:num_s_j
            phi_j(6,1,s_i,s_j)= phi_j(6,1,s_i,s_j)-...
                a_i_values_vec(i)*sigma_i_array(i,s_i,s_j);
        end
    end
end
for j=2:num_a_j % phi is the same for a_W=1,a_W=2
    for i=1:num_a_i
        for s_i=1:num_s_i
            for s_j=1:num_s_j
                phi_j(1,j,s_i,s_j)= -a_j_values_vec(j);
                phi_j(3,j,s_i,s_j)= phi_j(3,j,s_i,s_j)-a_j_values_vec(j)...
                    *a_i_values_vec(i)*sigma_i_array(i,s_i,s_j);
                phi_j(4,j,s_i,s_j)= -(2-a_j_values_vec(j))*...
                    s_j_values_vec(s_j);
            end
        end
    end
end
% initialize sigma_hat_t arrays for each country
sigma_i_hat_t = zeros(num_a_i, T);
sigma_j_hat_t = zeros(num_a_j, T);
% form initial guess theta0 for theta
theta0 = zeros(num_betas,1);
theta0 = ones(num_betas,1);
% Step3: Main analysis, estimate parameters using GMM
% set options for "fminunc"
maxit= 1000;
tol_moms= 1e-5;
tol_param= 1e-5;
max_fun_evals= maxit^2;
options= optimset('display','final',...
                  'MaxIter',maxit,...
                  'TolFun',tol_moms,...
                  'TolX',tol_param,...
                  'MaxFunEvals',max_fun_evals);
% use "fminunc" to estimate parameters that minimize the weighted moments
% use the identity matrix as weight matrix and theta0 as initial guess
[theta_hat,fval] = fminunc('wtd_moms',theta0,options,phi_i,phi_j,...
    sigma_i_hat_t,sigma_j_hat_t,num_a_i,num_a_j,num_s_i,num_s_j,...
    T,num_betas,data_array,y_t)

%% Question 4) GMM - c.Bootstrap
% number of iterations
N_bootstrap=100;
% initialize array to store thetas over the different iterations
theta_bootstrap = zeros(num_betas,N_bootstrap);
% fill in theta_bootstrap with the different estimates across iterations
for n=1:N_bootstrap
    theta_bootstrap(:,n) = GMM_bootstrap(T,data_array);
end
% calculating SE from the different thetas
theta_se = std(theta_bootstrap,0,2); 

%% Question 5) MLE - b

