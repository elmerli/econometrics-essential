%%
%      AEM 7500  PS #3
%      Tianli Xia
%      Feb 9, 2020
%
clc;
clear all;
cd 'C:\Users\13695\Dropbox\AEM7500 Problem Sets'

%% Part I: Initialize Parameters
N_s = 30; % number of states
N_u = 30; % number of actions
rho     = 0.05;
beta    = 1/(1+rho); % discount factor
a       = 48.05;
b       = 3;

% Initialize state variable vector
%   and control variable vector
%   sidenote: we will use i, j ,k to denote the indices for s_i, s_j, and u
K = (1:1:N_s)';
u = (1:1:N_u)';

% Initialize transition matrix array 
%    M(s_i, s_j, u)  = Pr(s_j | s_i, u)
M = zeros (N_s, N_s, N_u);

% Initialize value function
v = zeros (N_s, 1);

% Initialize optimal policy
u_opt = zeros(N_u, 1);

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
    M(k,:,:)=eye(N_u);
end

% Fill in per-period payoff pi(s_i,u)

    pi_mat = log( (a+1)*K - b/2*K.^2  - u' );


% Initialize guess for v(s)
% v_0=max_u pi(s_i,u)
v   = max(pi_mat, [], 2);

%% Part III: Value function iteration and Solve for the fixed point

% Initialize stopping criterion 
epsilon = 1e-6;

% Start with a value of difference greater than epsilon
diff = epsilon + 10;

% Initialize v_new to be equal to initial guess
v_new = v;

% Initialize value function matrix v_mat (function of state s and action u)
%   (and continuation value matrix vc_mat)
v_mat = zeros(N_s, N_u);
vc_mat = zeros(N_s, N_u);

while diff > epsilon
    % reset v to v_new
    v=v_new;
    
    % continuation value matrix:
        %   continuation values (rows) 
        %   conditional on different actions (cols)
        %   each column is a continuation value function
    for k = 1:N_u
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
fprintf('It takes %d iteration to converge\n with errors %f', i, diff);

% Optimal policy function as function of state K
u_opt=u(u_index);

xlswrite('K_v_u_opt_infinite.xlsx',[K,v_new,u_opt],1,'A1')

%% Part IV: Solve for trajectories for Kt and Ct
% Simulation parameters
K0 = 5; % initial capital stock
T = 10; % length of the tracjectory

% Inialize the trajectories
Kt = zeros(T+1,1);
Ct = zeros(T,1);

% Compute the tracjectory for the capital
Kt(1) = K0;
for t=2:T+1
    kkk=(K==Kt(t-1)); % find which state (index) it is for the previous period capital
    Kt(t)=u_opt(kkk); % store the choice (i.e., the next period state)
end

% Compute the tracjectory for consumption
%   by Ct = F(Kt) + Kt -Kt+1
for t=1:T
    Ct(t)=(a+1)*Kt(t)-b/2*Kt(t)^2-Kt(t+1);
end

% Plot the trajectory
plot(0:T,Kt);   
    xlabel('t')
    ylabel('K_t    ','Rotation',0)
print('Xia_Tianli_PS3_P1_Kt','-dpng')       

figure;
plot(0:(T-1),Ct);   
    xlabel('t')
    ylabel('C_t    ','Rotation',0)
print('Xia_Tianli_PS3_P1_Ct','-dpng')    
