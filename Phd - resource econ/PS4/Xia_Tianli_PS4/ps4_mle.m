%%
%      AEM 7500  PS #4
%      Tianli Xia
%      April 8th, 2020
%
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


%% Part VI: MLE estimation
THETA= ["beta0"; "beta1r"; "beta2"; "beta3r"; "beta1w"; "beta3w"];

global flag_bootstrap
flag_bootstrap=0;
theta0 = randn(6,1);    % initial guess
[theta_hat1, obj_val1, ~] = X_estimation_mle(Cst,data,theta0);



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
    [theta_hat, ~, ~] = X_estimation_mle(Cst,data,theta0);
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
    xlswrite('mle_bootstrap', [THETA, mean(theta_hat_bootstrap,2), std(theta_hat_bootstrap,0,2)], 2 )        
    
% nonpara_bootstrap
    ci= quantile(theta_hat_bootstrap, [.05 .95], 2)
    xlswrite('mle_bootstrap', [THETA, mean(theta_hat_bootstrap,2),ci ], 3  )
    


% Report the result
mu_b=mean(theta_hat_bootstrap,2);
ncols=3;    % number of cols for the subplots
n_para=size(theta0,1)*size(theta0,2);
for p=1:n_para
    subplot(n_para/ncols, ncols, p); % p-ncols*(ceil(p/ncols)-1)
    % plot the distribution of the bootstrap estimates for each theta
    histogram(theta_hat_bootstrap(p,:))
    xlabel(['theta' num2str(p)])
    ylabel('Frequency')
    hold on
    % plot the mean of the bootstrap estimates of each theta
    plot([mu_b(p) mu_b(p)],[0 50],'--r')
end
print('Bootstrap_efficient_mle','-dpng', '-r600')      


