%%
%      AEM 7500  PS #3
%      Tianli Xia
%      Feb 9, 2020
%
clc;
clear all;
% cd 'C:\Users\13695\Dropbox\AEM7500 Problem Sets'


%%% Infinite Horizon Dynamic Programming
%% Part I: Initialize Parameters
N_s = 30; % number of states
N_u = 28; % number of actions
rho     = 0.05;
beta    = 1/(1+rho); % discount factor
a       = 48.05;
b       = 2; 

% Initialize state variable vector
%   and control variable vector
%   sidenote: we will use i, j ,k to denote the indices for s_i, s_j, and u
K = (1:1:N_s)';
u = (2:1:29)';

% Initialize transition matrix array 
%    M(s_i, s_j, u)  = Pr(s_j | s_i, u)
M = zeros(N_s, N_s, N_u);

% Initialize value function
v = zeros(N_s, 1);

% Initialize optimal policy
u_opt = zeros(N_s, 1);

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

    pi_mat = log( (a+1)*K - b/2*K.^2  - u' );


% Initialize guess for v(s)
% v_0=max_u pi(s_i,u)
v   = max(pi_mat, [], 2);

% Initialize stopping criterion 
epsilon = 1e-6;

% Start with a value of difference greater than epsilon
diff = epsilon + 10;

% Initialize v_new to be equal to initial guess
v_new = v;

% Initialize value function matrix v_mat (function of state s and action u)
%   (and continuation value matrix vc_mat)
v_mat  = zeros(N_s, N_u);
vc_mat = zeros(N_s, N_u);

%% Part III: Value function iteration and Solve for the fixed point
i = 0;  % iteration clock
while diff > epsilon
    % reset v to v_new
    v=v_new;
    
    % continuation value matrix:
        %   continuation values (rows) 
        %   conditional on different actions (cols)
        %   each column is a continuation value function
    for k = 1: N_u
        vc_mat(:,k) = M(:,:,k) * v;
    end
    
    % value function matrix
    v_mat = pi_mat + beta * vc_mat;
    
    % value function by optimally choosing u
    [v_new, u_index] = max(v_mat,[],2);
    
    % calculate the distant using sup norm
    diff = max(abs(v_new-v));
    
    i = i+1;
end
fprintf('It takes %d iteration to converge\n', i);

% Optimal policy function as function of state K
u_opt=u(u_index);

xlswrite('K_v_u_opt_sto_inf.xlsx',[K,v_new,u_opt],1,'A1')

%% Part IV: Solve for trajectories for Kt and Ct
% Simulation parameters
K0 = 5; % initial capital stock
T = 10; % length of the tracjectory
N_sim = 5; % # of simulations

% Inialize the trajectories
Kt = zeros(T+1,N_sim);
Ct = zeros(T,N_sim);
It = zeros(T,N_sim);  % control

% Initialize random shocks
rand_vec = rand(T,N_sim);  % generate a random vector
eps = -1*(rand_vec<=.25) + 0*(rand_vec>.25 & rand_vec<=0.7) + 1*(rand_vec>.7);


Kt(1,:) = K0;

for s=1:N_sim
    % Compute the tracjectory for the capital

    for t=2:T+1
        kkk=(K==Kt(t-1,s)); % find which state it is for the previous period capital
        It(t-1,s)=u_opt(kkk); % store the optimal choice in t-1
        Kt(t,s) = It(t-1,s) + eps(t-1,s); % the realization of the next period t state
                                  % depends on the choice and the random shock
    end
end

% Compute the tracjectory for consumption
%   by Ct = F(Kt) + Kt - It
Ct = (a+1)*Kt(1:T,:) - b/2*Kt(1:T,:).^2 - It;

% Plot the trajectory

    subplot(2,2,1);
    plot(0:T,Kt);   
        xlabel('t')
        ylabel('K_t         ','Rotation',0)
        axis([0 T 0 30])

    subplot(2,2,2);
    plot(0:(T-1),Ct);   
        xlabel('t')
        ylabel('C_t         ','Rotation',0)
    
    subplot(2,2,3);
    plot(0:(T-1),It);   
        xlabel('t')
        ylabel('I_t         ','Rotation',0)
        axis([0 T 0 30])        
        
    subplot(2,2,4);
    plot(0:(T-1),eps);   
        xlabel('t')
        ylabel('\epsilon_t      ','Rotation',0)
        axis([0 T -2 2])
        
    print('Xia_Tianli_PS3_P2','-dpng')         


