%%
%      AEM 7500 PS #5
%      Tianli Xia
%      April 30, 2020
%
clc;
clear all;
cd '/Users/zongyangli/Google Drive/Academic 其他/GitHub/econometrics-essential/Phd - resource econ/PS5/Xia_Tianli_PS5'

%% Part I: Import Data
[raw, varname, ~] = xlsread('AEM7500_PS5_data_spring2020.xlsx');
k= raw(:,1);
t= raw(:,2);
s= raw(:,3);
inst_A= raw(:,4);
inst_B= raw(:,5);
data=dataset(k,t,s,inst_A,inst_B);

T_periods = max(data.t)+1;    % # of periods
T = max(data.t);
K = max(data.k);    % # of markets

%% Part II: Construct I_ikt, i=a or i=b
I_A = [data.inst_A(2:end);-99] - data.inst_A;  % generate lead variables and take the difference
I_A(data.inst_A==1) = -99; % make the subsequent decisions unavailable
I_A(data.t==T)      = -99; % fix the last period decision 
I_A_1= sum(reshape(I_A,T_periods,K)==0); % calculate when I_A first takes value of 1


I_B = [data.inst_B(2:end);-99] - data.inst_B;
I_B(data.inst_B==1) = -99; 
I_B(data.t==T)      = -99; 
I_B_1= sum(reshape(I_B,T_periods,K)==0); 

% report the results
% xlswrite('I_A.xlsx',reshape(I_A,T_periods,K),'I_A','B2');
% xlswrite('I_B.xlsx',reshape(I_B,T_periods,K),'I_B','B2');

%% Part III: Construct a_kt; Drop observations when both cities have installed 
a = data.inst_A + data.inst_B;

% Assume perfect panel
a_mat=reshape(a,T_periods,K);
a_2= T_periods- sum(a_mat==2, 1);

a_mat(a_mat==2)=NaN;
% xlswrite('a.xlsx',a_mat,'a','B2');

% drop observations
data.a= a;
data.I_A= I_A;
data.I_B= I_B;
data(a==2,:)=[];
raw(a==2,:)=[];
%% Part IV: Estimate the transition matrix

% possible tuples/combinations of state variables
tuple = unique([data.a data.s],'rows');
% Export possible tuples
xlswrite('tuple.xlsx',tuple,'tuple','A2'); 

% indexing the tuples in the dataset
Omega_idx=zeros(size(tuple,1),1);
for k=1:length(tuple)
   Omega_idx(data.a==tuple(k,1) & data.s==tuple(k,2)) = k;
end
data.Omega_idx=Omega_idx;

% indexing the next period tuple in the dataset
data.Omega_idx_next = Omega_idx(2:end);

for k=1:K
    data.Omega_idx_next(data.k==k & data.t==max(data.t(data.k==k)))=-99;
end


% reshape the data as long format by apending A and B (since the stata
%   variables Omega are shared in common)
data_ikt=[data(:,[1:3 6 9:10]);data(:,[1:3 6 9:10])];   % other common variables are the same for A & B
data_ikt.i = [ones(length(data),1);ones(length(data),1)*2];     % index i for A or B
data_ikt.I = [data.I_A; data.I_B];  % investment decisions for A & B

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data_ikt= data_ikt(data_ikt.I~=-99,:); % DROP FIRMS AFTER MAKING DECISIONS 
% CONTROVERISIAL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

M=zeros(size(tuple,1),size(tuple,1));
% construct the transition matrix by element
for r=1:size(tuple,1)
    denom = sum(data_ikt.I==0 & data_ikt.Omega_idx==r);
    for c=1:size(tuple,1)
    M(r,c)= sum(data_ikt.I==0 & data_ikt.Omega_idx==r & data_ikt.Omega_idx_next==c)...
                /denom;
    end
end

% xlswrite('M.xlsx',["00" "01" "10" "11"],'M','B1'); 
% xlswrite('M.xlsx',["00"; "01"; "10"; "11"],'M','A2'); 
% xlswrite('M.xlsx',M,'M','B2'); 

%% Part V: Estimate g_bar
g_bar = zeros(size(tuple,1),1); % Initialize
for i=1:size(tuple,1)
    g_bar(i) = sum(data_ikt.Omega_idx==i & data_ikt.I==1) ...
              /sum(data_ikt.Omega_idx==i);
end
% xlswrite('g_bar.xlsx',["a=0,s=0"; "a=0,s=1"; "a=1,s=0"; "a=1,s=1"],'g_bar','A2'); 
% xlswrite('g_bar.xlsx',g_bar,'g_bar','B2'); 



%% Part VI: Estimation
global beta
beta=0.9;
[raw, varname, ~] = xlsread('AEM7500_PS5_data_spring2020.xlsx');
k= raw(:,1);
t= raw(:,2);
s= raw(:,3);
inst_A= raw(:,4);
inst_B= raw(:,5);
data=dataset(k,t,s,inst_A,inst_B);

[theta_hat, fval, ghat, vhat]= X_estimation(data)

%% Part V: bootstrap
rng('default')
N_bootstrap=100;
K = length(unique(data.k)); % Number of markets
data_raw=data;
theta_hat_bootstrap=zeros(N_bootstrap,2);

tic
for b=1:N_bootstrap
    data_temp=[];
    % Resample the data
    b_index=ceil(K*rand(1,K));  % resampled bootstrap index (for markets)
    for k0 = 1:K
        data0 = data_raw(data_raw.k==b_index(k0),:);
        data_temp = [data_temp; data0];   % bootstrap data set
    end  
    % Estimate parameters using GMM for each B-sample
    %   and Store results in a matrix
    fprintf('bootstrap # %d \n', b); 
    [theta_hat_bootstrap(:,b), fval(b), ghat(:,b), vhat(:,b)]= X_estimation(data_temp);

end

save theta_bootstrap theta_hat_bootstrap

THETA=["gamma1"; "gamma2"];
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
ncols=1;    % number of cols for the subplots
n_para=2;
for p=1:n_para
    subplot(n_para/ncols, ncols, p); % p-ncols*(ceil(p/ncols)-1)
    % plot the distribution of the bootstrap estimates for each theta
    histogram(theta_hat_bootstrap(p,:), 'BinWidth', 0.1)
    xlabel(['gamma' num2str(p)])
    ylabel('Frequency')
    hold on
    % plot the mean of the bootstrap estimates of each theta
    plot([mu_b(p) mu_b(p)],[0 50],'--r')
end
print('Bootstrap_1s_gmm','-dpng', '-r600')      





