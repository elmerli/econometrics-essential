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
N_u = 28; % number of actions
rho     = 0.05;
beta    = 1/(1+rho); % discount factor
a       = 48.05;
b       = 2;

T       = 4; 
N_periods = T+1;


% Initialize state variable vector
%   and control variable vector
%   sidenote: we will use i, j ,k to denote the indices for s_i, s_j, and u
K = (1:1:N_s)';
u = (2:1:29)';

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
u_opt_index = zeros(N_s, N_periods);
u_opt = zeros(N_s, N_periods);

% Initialize per-period payoff pi(s_i,u)
pi_mat = zeros(N_s, N_u);

%% Part II: Set up functions / Fill in matrix components
% Fill in transition matrix
%   The way of filling in this way, please refer to the write-up

for k=1:N_u
    id=( K==(u(k)-1) ); % find the index for state s.t. K_t+1 = I_t - 1
    M(:,id,k) = 0.25*ones(N_s,1);
    
    id=( K== u(k) ); % find the index for state s.t. K_t+1 = I_t
    M(:,id,k) = 0.45*ones(N_s,1);
    
    id=( K==(u(k)+1) ); % find the index for state s.t. K_t+1 = I_t + 1
    M(:,id,k) = 0.3*ones(N_s,1);
end

% Fill in per-period payoff pi(s_i,u)
for k = 1:N_u
    pi_mat(:,k) = log( (a+1)*K - b/2*K.^2  - u(k) );
end


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


xlswrite('K_v_u_opt_sto_finite1.xlsx',[K,v_t],'vt','A1')
xlswrite('K_v_u_opt_sto_finite2.xlsx',[K,u_opt],'ut','A1')

%% Part IV: Solve for trajectories for Kt and Ct
% Simulation parameters
K0 = 5; % initial capital stock
N_sim = 5; % # of simulations

% Inialize the trajectories
Kt = zeros(N_periods+1,N_sim);
Ct = zeros(N_periods,N_sim);
It = zeros(N_periods,N_sim);  % control

% Initialize random shocks
rand_vec = rand(N_periods,N_sim);   % generate a random vector
eps = -1*(rand_vec<=.25) + 0*(rand_vec>.25 & rand_vec<=0.7) + 1*(rand_vec>.7);


Kt(1,:) = K0;

for s=1:N_sim
    % Compute the tracjectory for the capital

    for t=2:N_periods+1
        kkk=(K==Kt(t-1,s)); % find which state it is for the previous period capital
        It(t-1,s)=u_opt(kkk,t-1); % store the optimal choice in t-1
        Kt(t,s) = It(t-1,s) + eps(t-1,s); % the realization of the next period t state
                                  % depends on the choice and the random shock
    end
end

% Compute the tracjectory for consumption
%   by Ct = F(Kt) + Kt - It
Ct = (a+1)*Kt(1:N_periods,:) - b/2*Kt(1:N_periods,:).^2 - It;

% Plot the trajectory
    subplot(2,2,1);
    plot(0:5,Kt);   
        xlabel('t')
        ylabel('K_t         ','Rotation',0)
        axis([0 T 0 30])

    subplot(2,2,2);
    plot(0:4,Ct);   
        xlabel('t')
        ylabel('C_t         ','Rotation',0)
    
    subplot(2,2,3);
    plot(0:4,It);   
        xlabel('t')
        ylabel('I_t         ','Rotation',0)
        axis([0 T 0 30])        
        
    subplot(2,2,4);
    plot(0:4,eps);   
        xlabel('t')
        ylabel('\epsilon_t      ','Rotation',0)
        axis([0 T -2 2])
        
    print('Xia_Tianli_PS3_P2_2','-dpng')      