function [theta_hat, fval, g_hat, v_hat] = X_estimation(data)
beta=0.9;

T_periods = max(data.t)+1;    % # of periods
T = max(data.t);
K = max(data.k);    % # of markets

%% Part II: Construct I_ikt, i=a or i=b
I_A = [data.inst_A(2:end);-99] - data.inst_A;  % generate lead variables and take the difference
I_A(data.inst_A==1) = -99; % make the subsequent decisions unavailable
I_A(data.t==T)      = -99; % fix the last period decision 


I_B = [data.inst_B(2:end);-99] - data.inst_B;
I_B(data.inst_B==1) = -99; 
I_B(data.t==T)      = -99; 


%% Part III: Construct a_kt; Drop observations when both cities have installed 
a = data.inst_A + data.inst_B;

% Assume perfect panel
% drop observations
data.a= a;
data.I_A= I_A;
data.I_B= I_B;
data(a==2,:)=[];

%% Part IV: Estimate the transition matrix

% possible tuples/combinations of state variables
tuple = unique([data.a data.s],'rows');
% Export possible tuples

% indexing the tuples in the dataset
Omega_idx=zeros(size(tuple,1),1);
for k=1:length(tuple)
   Omega_idx(data.a==tuple(k,1) & data.s==tuple(k,2)) = k;
end
data.Omega_idx=Omega_idx;

% indexing the next period tuple in the dataset
data.Omega_idx_next = Omega_idx(2:end);

mkt_index=unique(data.k);
for k0=1:length(mkt_index)
    k=mkt_index(k0);    % for each market
    data.Omega_idx_next(data.k==k & data.t==max(data.t(data.k==k)))=-99;
end

% reshape the data as long format by apending A and B (since the stata
%   variables Omega are shared in common)
data_ikt=[data(:,[1:3 6 9:10]);data(:,[1:3 6 9:10])];   % other common variables are the same for A & B
data_ikt.i = [ones(length(data),1);ones(length(data),1)*2];     % index i for A or B
data_ikt.I = [data.I_A; data.I_B];  % investment decisions for A & B

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data_ikt= data_ikt(data_ikt.I~=-99,:); % CONTROVERISIAL
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


%% Part V: Estimate g_bar
g_bar = zeros(size(tuple,1),1); % Initialize
for i=1:size(tuple,1)
    g_bar(i) = sum(data_ikt.Omega_idx==i & data_ikt.I==1) ...
              /sum(data_ikt.Omega_idx==i);
end

% Pack estimates from step1 in order to carry into GMM obj func
Cst.data_ikt=data_ikt;
Cst.tuple=tuple;
Cst.M=M;
Cst.g_bar=g_bar;
Cst.inversion=1;
Cst.Minv=(eye(length(tuple))-beta*M)\(M*g_bar);
tuple_temp = tuple(:,1)*10+ tuple(:,2);
state_temp = data_ikt.a*10+ data_ikt.s;
Cst.obs= sum(state_temp==tuple_temp')' ;
%% Step 2: Estimate parameters using GMM
theta0 = -abs(rand(2,1));
Cst.W=eye(4);
maxit = 1e3;
tol_mmts = 1e-7;
tol_paras = 1e-7;
max_fun_evals = 1e6;
options = optimset( 'Display', 'off', ...
                    'MaxIter', maxit, ...
                    'TolFun', tol_mmts, ...
                    'TolX', tol_paras, ...
                    'MaxFunEvals', max_fun_evals); 
%objfun = @(theta) X_GMM_obj1(theta,Cst);
objfun2 = @(theta) X_GMM_obj2(theta,Cst);

[theta_hat, fval] = fminunc(objfun2, theta0, options);
%sigma=theta_hat(3);
sigma= 1;
gamma= [theta_hat(1); theta_hat(2)];
v_new= sigma*Cst.Minv;
g_hat= exp(-(beta*v_new - tuple*gamma)./sigma);
v_hat= sigma*Cst.Minv;

% Cst.W= X_GMM_w(theta_hat, Cst);
% objfun = @(theta) X_GMM_obj1(theta,Cst);
% [theta_hat, fval] = fminunc(objfun, theta0, options)
end
