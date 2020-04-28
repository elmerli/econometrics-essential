%%
%      AEM 7500  PS #3
%      Tianli Xia
%      Feb 9, 2020
%
clc;
clear all;
cd 'C:\Users\13695\Dropbox\AEM7500 Problem Sets'


%%% Finite Horizon Dynamic Programming
%% Part I: Initialize Parameters
N_s = 30; % number of states
N_u = 30; % number of actions
rho     = 0.05;
beta    = 1/(1+rho); % discount factor
a       = 48.05;
b       = 3;

T       = 4; 
N_periods = T+1;


% Initialize state variable vector
%   and control variable vector
%   sidenote: we will use i, j ,k to denote the indices for s_i, s_j, and u
K = (1:1:N_s)';
u = (1:1:N_u)';

% Initialize transition matrix array 
%    M(s_i, s_j, u)  = Pr(s_j | s_i, u)
M = zeros(N_s, N_s, N_u);

% Initialize value function
%   note: now there is one value function associated with each period t.
%   Each column is the value function for that period
v_t = zeros(N_s, N_periods);

% Initialize optimal policy
%   note: since the value function depends on t, the optimal oplicy
%   function is also now contigent on t
u_opt_index = zeros(N_u, N_periods);
u_opt = zeros(N_u, N_periods);

% Initialize per-period payoff pi(s_i,u)
pi_mat = zeros(N_s, N_u);

%% Part II: Set up functions / Fill in matrix components
% Fill in transition matrix
%   a) First note that in this problem, the path for the capital stock is
%   deterministic, i.e., conditional on the action u (in this problem, it
%   is also the capital next period K'), we know for sure what the next 
%   period state K' is.
%   b) Specifically, if u takes the k-th action (i.e, the next period state 
%   goes to the k-th state), then the next period state variable takes the
%   k-th value for sure.
%   c) Besides, as our grid of the capital stock takes values from 1 to 30,
%   we can check all values are feasible & satisfy the constraint [0, F(K)+K]
for k=1:N_u
    M(k,:,:)=eye(N_s);
end

% Fill in per-period payoff pi(s_i,u)

    pi_mat = log( (a+1)*K - b/2*K.^2  - u' );



% Initialize value function matrix v_mat (function of state s and action u)
%   (and continuation value matrix vc_mat)
%   note: for each time t. since we just optimize over v_mat vc_mat, it
%   essentially serves as obj. functions. We don't index it by time but
%   let it change by period.
v_mat  = zeros(N_s, N_u);
vc_mat = zeros(N_s, N_u);


% Value funciton of time T
[v_t(:, N_periods), u_opt_index(:, N_periods)]= max(pi_mat, [], 2); %still have 1 unit leftover
u_opt(:, N_periods)=u(u_opt_index(:, N_periods));
%v_t(:, N_periods) = log( (a+1)*K - b/2*K.^2 );

%% Part III: Value function iteration and Solve by backward iteration
for t = (N_periods-1) : -1 : 1

    % continuation value matrix:
        %   continuation values (rows) 
        %   conditional on different actions (cols)
        %   each column is a continuation value function
    for k = 1:N_u
        vc_mat(:,k) = M(:,:,k) * v_t(:,t+1);
    end
    
    % value function matrix
    v_mat = pi_mat + beta * vc_mat;
    
    % value function and policy function (index) in period t
    %   by optimally choosing u
    [v_new, u_index] = max(v_mat,[],2);
    
    % Store in value function in v_t matrix and u_opt matrix
    v_t(:,t) = v_new;
    u_opt_index(:,t) = u_index;
    u_opt(:,t)= u(u_index);
    
end


xlswrite('K_v_u_opt_finite1.xlsx',[K,v_t],'vt','A1')
xlswrite('K_v_u_opt_finite2.xlsx',[K,u_opt],'ut','A1')

%% Part IV: Solve for trajectories for Kt and Ct
% Simulation parameters
K0 = 5; % initial capital stock

% Inialize the trajectories
Kt = zeros(N_periods+1,1);
Ct = zeros(N_periods,1);

% Compute the tracjectory for the capital
Kt(1) = K0;
for t=2:N_periods+1
    kkk=(K==Kt(t-1)); % find which state (index) it is for the previous period capital
    u_t=u_opt(:,t-1);
    Kt(t)=u_t(kkk); % store the choice (i.e., the next period state)
end

% Compute the tracjectory for consumption
%   by Ct = F(Kt) + Kt -Kt+1
for t=1:N_periods
    Ct(t)=(a+1)*Kt(t)-b/2*Kt(t)^2-Kt(t+1);
end

% Plot the trajectory
plot(0:T+1,Kt);   
    xlabel('t')
    ylabel('K_t    ','Rotation',0)
print('Xia_Tianli_PS3_P1_2_Kt','-dpng')       

figure;
plot(0:T,Ct);   
    xlabel('t')
    ylabel('C_t    ','Rotation',0)
print('Xia_Tianli_PS3_P1_2_Ct','-dpng')    
