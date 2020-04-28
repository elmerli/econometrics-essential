%%
%      AEM 7500  PS #4
%      Tianli Xia
%      April 8th, 2020
%
profile on
profile viewer
clc;
clear all;
cd 'C:\Users\13695\Dropbox\AEM7500 Problem Sets\Xia_Tianli_PS4'

%% Part I: Import Data
[data, varname, ~] = xlsread('AEM7500_PS4_data_spring2020.xlsx');
% a_r, a_w, s_r, s_w

%% Part II: Initialize Parameters and Arrays
% constants
N_ar = length(unique(data(:,1)));
N_aw = length(unique(data(:,2)));
N_sr = length(unique(data(:,3)));
N_sw = length(unique(data(:,4)));
T = size(data,1);

% initialize the values of the actions and states
a_r = (1:N_ar)-1;
a_w = (1:N_aw)-1;
s_r = (1:N_sr)-1;
s_w = (1:N_sw)-1;

% initialize sigma arrays
sigma_r = zeros(N_ar, N_sr, N_sw);
sigma_r_nu = zeros(N_ar, N_sr, N_sw);
sigma_r_de = zeros(N_ar, N_sr, N_sw);

sigma_w = zeros(N_aw, N_sr, N_sw);
sigma_w_nu = zeros(N_aw, N_sr, N_sw);
sigma_w_de = zeros(N_aw, N_sr, N_sw);

%% Part III: Form the Numerator and Denominator of Sigma Array
% sigma_r
for i=1:N_ar
    for j=1:N_sr
        for k=1:N_sw
        sigma_r_nu(i,j,k)=sum( a_r(i)==data(:,1) & s_r(j)==data(:,3) & s_w(k)==data(:,4) ); 
        sigma_r_de(i,j,k)=sum(                     s_r(j)==data(:,3) & s_w(k)==data(:,4) );
        end
    end      
end
sigma_r = sigma_r_nu ./ sigma_r_de;

    % results check
    sum(sum(sum(sigma_r_nu))) % should sum up to T=374
    sum(sigma_r,1) % sum over the first dimension, all the actions, the prob should be 1


    %------------------------------------------------------------
    % or another way to create the counts of different actions and
    % states combinations
    ar_sr_sw = combvec(a_r, s_r, s_w)'; % all the possible combinations of ai, si, sj
    sigma_r_nu_reshaped=zeros(N_ar*N_sr*N_sw,1);
    for t=1:T
        sigma_r_nu_reshaped = sigma_r_nu_reshaped + (sum(...
            ar_sr_sw==ones(N_ar*N_sr*N_sw,1)*[data(t,1) data(t,3) data(t,4)]...
                                    , 2)==3);
    end
    sum(sum(sum( sigma_r_nu==reshape(sigma_r_nu_reshaped,[3 3 3]) ))) % test whether identical across all 27 components
    %------------------------------------------------------------
    
 % sigma_w
for i=1:N_aw
    for j=1:N_sr
        for k=1:N_sw
        sigma_w_nu(i,j,k)=sum( a_w(i)==data(:,2) & s_r(j)==data(:,3) & s_w(k)==data(:,4) ); 
        sigma_w_de(i,j,k)=sum(                     s_r(j)==data(:,3) & s_w(k)==data(:,4) );
        end
    end      
end
sigma_w = sigma_w_nu ./ sigma_w_de;
    % results check
    sum(sum(sum(sigma_w_nu))) % should sum up to T=374
    sum(sigma_w,1) % sum over the first dimension, all the actions, the prob should be 1
    
%% Part IV: Report the Results
ar_sr_sw = combvec(a_r, s_r, s_w)';
aw_sw_sr = combvec(a_w, s_r, s_w)';
xlswrite('sigma_r_choice_prob.xlsx',["a_r", "s_r", "s_w", "prob"],'sigma_r','A1')
xlswrite('sigma_r_choice_prob.xlsx',[ar_sr_sw, reshape(sigma_r, [], 1)],'sigma_r','A2')

xlswrite('sigma_w_choice_prob.xlsx',["a_r", "s_r", "s_w", "prob"],'sigma_w','A1')
xlswrite('sigma_w_choice_prob.xlsx',[aw_sw_sr, reshape(sigma_w, [], 1)],'sigma_w','A2')

%% Part V: GMM Initialize Parameters
% (pack them into struct that can be carried over into functions)
% constants that do not change over the estimation procedure
Cst.N_ar = N_ar;
Cst.N_aw = N_aw;
Cst.N_sr = N_sr;
Cst.N_sw = N_sw;
Cst.T = size(data,1);

% the values of the actions and states
Cst.a_r = (1:Cst.N_ar)-1;
Cst.a_w = (1:Cst.N_aw)-1;
Cst.s_r = (1:Cst.N_sr)-1;
Cst.s_w = (1:Cst.N_sw)-1;


%% Part VI: GMM estimation
% Carry out GMM estimation procedure and check multi-start initial guess
THETA= ["beta0"; "beta1r"; "beta2"; "beta3r"; "beta1w"; "beta3w"];

global flag_bootstrap efficient_gmm
flag_bootstrap=0;
efficient_gmm=0;
theta0 = rand(6,1);    % initial guess
[theta_hat1, obj_val1, ~] = X_estimation_gmm(Cst,data,theta0);

efficient_gmm=1;
[theta_hat2, obj_val2, ~] = X_estimation_gmm(Cst,data,theta0);
xlswrite('gmm_bootstrap', [THETA, theta_hat1, theta_hat2], 1 )        
xlswrite('gmm_bootstrap', [obj_val1, obj_val2], 1, 'B7' )

%% Part VII: Bootstrap the standard errors
% Note that the purpose here is to calculate the s.d. of all the estimation
%   procedure but not to check the robustness of how the initial guess
%   affects the parameter estimates from the optimization routine.
%   Therefore, for each iteration, we use the same initial guess of theta.
flag_bootstrap=1;
rng('default')
N_bootstrap=100;
T=Cst.T;
data_raw=data;
theta_hat_bootstrap=zeros(size(theta0,1)*size(theta0,2), N_bootstrap);

tic
for b=1:N_bootstrap
    % Resample the data
    b_index=ceil(T*rand(1,T));  % resampled bootstrap index
    data=data_raw(b_index,:);   % bootstrap data set
    % Estimate parameters using GMM for each B-sample
    fprintf('bootstrap # %d \n', b); 
    [theta_hat, ~, ~] = X_estimation_gmm(Cst,data,theta0);
    % Store results in a matrix
    theta_hat_bootstrap(:,b)=theta_hat;
end

save theta_bootstrap theta_hat_bootstrap

% para_bootstrap
    % Calculate the mean estimate and bootstrap standard error
    mean(theta_hat_bootstrap,2)
    std(theta_hat_bootstrap,0,2)
        % should be the same as the following
%         m=(theta_hat_bootstrap-ones(N_bootstrap,1)*mean(theta_hat_bootstrap));
%         sqrt( 1/(N_bootstrap-1)*diag(m'*m) )
    xlswrite('gmm_bootstrap', [THETA, mean(theta_hat_bootstrap,2), std(theta_hat_bootstrap,0,2)], 2 )        
    
% nonpara_bootstrap
    ci= quantile(theta_hat_bootstrap, [.05 .95], 2)
    xlswrite('gmm_bootstrap', [THETA, mean(theta_hat_bootstrap,2),ci ], 3  )
    


% Report the result
mu_b=mean(theta_hat_bootstrap,2);
ncols=3;    % number of cols for the subplots
n_para=size(theta0,1)*size(theta0,2);
for p=1:n_para
    subplot(n_para/ncols, ncols, p); % p-ncols*(ceil(p/ncols)-1)
    % plot the distribution of the bootstrap estimates for each theta
    histogram(theta_hat_bootstrap(p,:), 'BinWidth', 0.1)
    xlabel(['theta' num2str(p)])
    ylabel('Frequency')
    hold on
    % plot the mean of the bootstrap estimates of each theta
    plot([mu_b(p) mu_b(p)],[0 50],'--r')
end
print('Bootstrap_efficient_gmm','-dpng', '-r600')      


%% Part VII: Bootstrap the standard errors
% Note that the purpose here is to calculate the s.d. of all the estimation
%   procedure but not to check the robustness of how the initial guess
%   affects the parameter estimates from the optimization routine.
%   Therefore, for each iteration, we use the same initial guess of theta.
flag_bootstrap=1;
efficient_gmm=0;
rng('default')
N_bootstrap=100;
T=Cst.T;
data_raw=data;
theta_hat_bootstrap=zeros(size(theta0,1)*size(theta0,2), N_bootstrap);

tic
for b=1:N_bootstrap
    % Resample the data
    b_index=ceil(T*rand(1,T));  % resampled bootstrap index
    data=data_raw(b_index,:);   % bootstrap data set
    % Estimate parameters using GMM for each B-sample
    fprintf('bootstrap # %d \n', b); 
    [theta_hat, ~, ~] = X_estimation_gmm(Cst,data,theta0);
    % Store results in a matrix
    theta_hat_bootstrap(:,b)=theta_hat;
end

save theta_bootstrap theta_hat_bootstrap

% para_bootstrap
    % Calculate the mean estimate and bootstrap standard error
    mean(theta_hat_bootstrap,2)
    std(theta_hat_bootstrap,0,2)
    xlswrite('gmm_bootstrap_1s', [THETA, mean(theta_hat_bootstrap,2), std(theta_hat_bootstrap,0,2)], 2 )        
    
% nonpara_bootstrap
    ci= quantile(theta_hat_bootstrap, [.05 .95], 2)
    xlswrite('gmm_bootstrap_1s', [THETA, mean(theta_hat_bootstrap,2),ci ], 3  )
    


% Report the result
mu_b=mean(theta_hat_bootstrap,2);
ncols=3;    % number of cols for the subplots
n_para=size(theta0,1)*size(theta0,2);
for p=1:n_para
    subplot(n_para/ncols, ncols, p); % p-ncols*(ceil(p/ncols)-1)
    % plot the distribution of the bootstrap estimates for each theta
    histogram(theta_hat_bootstrap(p,:), 'BinWidth', 0.1)
    xlabel(['theta' num2str(p)])
    ylabel('Frequency')
    hold on
    % plot the mean of the bootstrap estimates of each theta
    plot([mu_b(p) mu_b(p)],[0 50],'--r')
end
print('Bootstrap_1s_gmm','-dpng', '-r600')      

