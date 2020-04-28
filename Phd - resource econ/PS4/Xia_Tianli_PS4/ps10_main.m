%%
%      AEM 7500  PS #10
%      Binglin Wang
%      Apr 2, 2019
%
clc;
clear all;
cd '/Users/air/Dropbox/Sping 2019/AEM7500/PS10'
%cd 'C:/Dropbox/Sping 2019/AEM7500/PS10'
%cd 'U:/Matlab/AEM7500 PS10'

global flag_bootstrap

%% Part I: Import Data
data = dataset('file','./AEM7500_PS9-11_data_spring2019.csv', 'Delimiter',',',...
    'ReadVarNames',true);

%% Part II: Initialize Parameters
% (pack them into struct that can be carried over into functions)
% constants that do not change over the estimation procedure
Cst.N_ar = 3;
Cst.N_aw = 3;
Cst.N_sr = 3;
Cst.N_sw = 3;
Cst.T = size(data,1);

% the values of the actions and states
Cst.a_r = (1:Cst.N_ar)-1;
Cst.a_w = (1:Cst.N_aw)-1;
Cst.s_r = (1:Cst.N_sr)-1;
Cst.s_w = (1:Cst.N_sw)-1;


%% Part II: GMM estimation
% Carry out GMM estimation procedure and check multi-start initial guess
flag_bootstrap=0;
theta0 = [0 0 0; 0 0 0]';    % initial guess
[theta_hat, obj_val, exit_flag] = WF1_estimation(Cst,data,theta0);

display(theta_hat)
display(obj_val)
display(exit_flag)

%% Part III: Bootstrap the standard errors
% Note that the purpose here is to calculate the s.d. of all the estimation
%   procedure but not to check the robustness of how the initial guess
%   affects the parameter estimates from the optimization routine.
%   Therefore, for each iteration, we use the same initial guess of theta.
flag_bootstrap=1;
rng('default')
N_bootstrap=100;
T=Cst.T;
data_raw=data;
theta_hat_bootstrap=zeros(N_bootstrap,size(theta0,1)*size(theta0,2));

tic
for b=1:N_bootstrap
    % Resample the data
    b_index=ceil(T*rand(1,T));  % resampled bootstrap index
    data=data_raw(b_index,:);   % bootstrap data set
    % Estimate parameters using GMM for each B-sample
    fprintf('bootstrap # %d \n', b); 
    [theta_hat, ~, ~] = WF1_estimation(Cst,data,theta0);
    % Store results in a matrix
    theta_hat_bootstrap(b,:)=[theta_hat(:,1)' theta_hat(:,2)'];
end

save theta_bootstrap theta_hat_bootstrap

% Calculate the mean estimate and bootstrap standard error
mean(theta_hat_bootstrap)
std(theta_hat_bootstrap)
    % should be the same as the following
    m=(theta_hat_bootstrap-ones(N_bootstrap,1)*mean(theta_hat_bootstrap));
    sqrt( 1/(N_bootstrap-1)*diag(m'*m) )
    
display(mean(theta_hat_bootstrap)./std(theta_hat_bootstrap))  % t-stats

% Report the result
mu_b=mean(theta_hat_bootstrap);
ncols=3;    % number of cols for the subplots
n_para=size(theta0,1)*size(theta0,2);
for p=1:n_para
    subplot(n_para/ncols, ncols, p); % p-ncols*(ceil(p/ncols)-1)
    % plot the distribution of the bootstrap estimates for each theta
    histogram(theta_hat_bootstrap(:,p))
    xlabel(['theta' num2str(p)])
    ylabel('Frequency')
    hold on
    % plot the mean of the bootstrap estimates of each theta
    plot([mu_b(p) mu_b(p)],[0 200],'--r')
end


%% Code: for test or debug use
% check the bootstrap resampling indices
    %sum((1:T)'*ones(1,T)==ones(T,1)*ceil(T*rand(1,T))); % should be all ones
    %sum((1:T)'*ones(1,T)==ones(T,1)*ceil(T*rand(1,T)),2); % to see how many times each index appears