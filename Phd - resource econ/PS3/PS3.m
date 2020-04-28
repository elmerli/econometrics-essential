
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Program Name:   PS3.m
% Author:         Elmer Li
% Date Created:   03.12
% Project:        Resource economics
% Input:          
% Output:         
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Initialize paramters and functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


clear all; clc;

%% 1. Deterministic - infinite
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Initialize paramters and functions
% prameters
    rho = 0.05; % discount rate
    beta = 1/(1+rho); % discount factor
    a = 48.05; % production function parameter
    b = 3; % production function parameter
    num_k = 30;   % size of grid
    k_max = 30;  % upper bound for capital
    k_min = 1;  % lower bound for capital
    k_grid = linspace(k_min,k_max,num_k)'; % create grid for captial 
        % this is the grid for both state and control variable
    crit = 1;   % Initialize convergence criterion
    tol = 0.01; % Convergence tolerance

% funcitons
    val_fun = zeros(num_k,1); % value function vector
    val_temp = zeros(num_k,1);  % temporary value function vector-to store last value function
    pi_mat = zeros(num_k,num_k); % initialize per-period pay-off
    M_det = zeros(num_k,num_k,num_k); % initialize transition matrix
    func_k = @(k1)  a*k1 - (b/2)*k1^2; % initialize production function

% fill in per-priod pay-off
    % i is the state (k), j is the control (k')
    for k=1:num_k 
        for k_p = 1:num_k
            pi_mat(k,k_p) = log(func_k(k_grid(k)) + k_grid(k) - k_grid(k_p)); 
        end
    end

% fill in transition matrix
    for k=1:num_k 
        for k_p = 1:num_k
            if func_k(k_grid(k)) + k_grid(k) - k_grid(k_p) > 0 
                M_det(k,k_p,k_p) = 1; 
            else 
                M_det(k,k_p,k_p) = 0;
            end 
        end
    end

% initial guess for value function
    val_temp = max(pi_mat, [], 2); % max value for each row (state)



%% Value function iteration
% Solve for fixed point
    while crit>tol
        % initialize value function matrix - function of states & actions
        val_mat = zeros(num_k,num_k); 
        % calculate value function matrix
        for k_p = 1:num_k   
            val_mat(:,k_p) = pi_mat(:,k_p) + beta*M_det(:,:,k_p)*val_temp; 
        end
        % for each state k, find action k_p that maximizes val_mat(k,:)
        [val_fun,k_p_index] = max(val_mat, [], 2);
        % update convergence criterion and value funciton
        crit = max(abs(val_fun-val_temp)); 
        val_temp = val_fun;
    end

% get table of value and policy function
    opt1 = [k_grid,val_fun,k_grid(k_p_index)]; 
    xlswrite("PS3.xls",opt1,1)

% calcluate optimum k and consuption starting k_0 =5, draw graph  
    k_0 = 5; % initial value for k
    T = 10; % check 100 periods
    k_t(1,1) = k_0; 
    for t=1:T+1
        for k = 1:num_k
            if k_t(t,1) == opt1(k,1)
                k_t(t+1,1) = opt1(k,3); 
                C_t(t,1) = func_k(k_t(t,1)) + k_t(t,1) - k_t(t+1,1); 
            end 
        end
    end

    figure
    subplot(1,2,1); plot(0:T, C_t(1:T+1), 'linewidth',2); title('Optimal C(t)'); xlabel('Time t'); ylabel('Consumption C(t)'); 
    subplot(1,2,2); plot(0:T, k_t(1:T+1), 'linewidth',2); title('Optimal k(t)'); xlabel('Time t'); ylabel('Capital k(t)'); 
    print('Deterministic_inf','-dpng')


%% 2. Deterministic - finite
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear val_fun val_temp val_mat pi_mat optimum consumption k_p k_p_index k_0 T k_t C_t;

%% Initialize parameters & functions
    T = 4; % the last periods
    n_periods = T + 1; % number of periods
    last_period = n_periods; % number for last period
    val_fun = zeros(num_k,n_periods); % value function vector
    k_p_index = zeros(num_k,n_periods); % the index matrix of the control var - k_p
    pi_mat = zeros(num_k,num_k); % initialize per-period pay-off

% fill in per-priod pay-off
    % i is the state (k), j is the control (k')
    for k=1:num_k 
        for k_p = 1:num_k
            pi_mat(k,k_p) = log(func_k(k_grid(k)) + k_grid(k) - k_grid(k_p)); 
        end
    end

% value function in last period
    [val_fun(:,last_period),k_p_index(:,last_period)] = max(pi_mat, [], 2);


%% Backward iteration

% Calculate value function backwards
    for t = T:-1:1
        % initialize value function matrix - function of states & actions
        val_mat = zeros(num_k,num_k); 
        % calculate value function matrix
        for k_p = 1:num_k   
            val_mat(:,k_p) = pi_mat(:,k_p) + beta*M_det(:,:,k_p)*val_fun(:,t+1); 
        end
        % for each state k, find action k_p that maximizes val_mat(k,:)
        [val_fun(:,t),k_p_index(:,t)] = max(val_mat, [], 2);
    end

% get table of value and policy function
    opt2 = [k_grid,val_fun,k_grid(k_p_index)]; 
    xlswrite("PS3_q2.xls",opt2,2)

% calcluate optimum k and consuption starting k_0 =5, draw graph  
    k_0 = 5; % initial value for k
    T = 4; % check 100 periods
    k_t(1,1) = k_0; 
    for t=1:T+1
        for k = 1:num_k
            if k_t(t,1) == opt2(k,1)
                k_t(t+1,1) = opt2(k,t+6); 
                C_t(t,1) = func_k(k_t(t,1)) + k_t(t,1) - k_t(t+1,1); 
            end 
        end
    end

    figure
    subplot(1,2,1); plot(0:T, C_t(1:T+1), 'linewidth',2); title('Optimal C(t)'); xlabel('Time t'); ylabel('Consumption C(t)'); 
    subplot(1,2,2); plot(0:T+1, k_t(1:T+2), 'linewidth',2); title('Optimal k(t)'); xlabel('Time t'); ylabel('Capital k(t)'); 
    print('Deterministic_fin','-dpng')



%% 3. Stochastic - infinite
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Initialize paramters and functions

% prameters
    b = 2; % update b
    num_I = 28; % size of control grid
    I_max = 29;  % upper bound for capital
    I_min = 2;  % lower bound for capital
    I_grid = linspace(I_min,I_max,num_I)'; % create grid for captial 

% funcitons
    val_fun = zeros(num_k,1); % value function vector
    val_temp = zeros(num_k,1);  % temporary value function vector-to store last value function
    pi_mat = zeros(num_k,num_I); % initialize per-period pay-off
    M_sto = zeros(num_k,num_k,num_I); % initialize transition matrix
    func_k = @(k1)  a*k1 - (b/2)*k1^2; % initialize production function

% fill in per-priod pay-off
    for k=1:num_k
        for I = 1:num_I
            pi_mat(k,I) = log(func_k(k_grid(k)) + k_grid(k) - I_grid(I)); 
        end
    end

% initial guess for value function
    val_temp = max(pi_mat, [], 2); % max value for each row (state)

% fill in transition matrix
    for k=1:num_k 
        for I = 1:num_I
            if func_k(k_grid(k)) + k_grid(k) - I_grid(I) - 1 > 0 % worst case consuption grt 0
                M_sto(k,I_grid(I)-1,I) = 0.25; M_sto(k,I_grid(I),I) = 0.45; M_sto(k,I_grid(I)+1,I) = 0.3; 
            else 
                M_sto(k,I_grid(I)-1,I) = 0; M_sto(k,I_grid(I),I) = 0; M_sto(k,I_grid(I)+1,I) = 0; 
            end 
        end 
    end 


%% Value function iteration

% Solve for fixed point
    i = 0; 
    while crit>tol
        % initialize value function matrix - function of states & actions
        val_mat = zeros(num_k,num_I); 
        % calculate value function matrix
        for I = 1:num_I   
            val_mat(:,I) = pi_mat(:,I) + beta*M_sto(:,:,I)*val_temp; 
        end
        % for each state k, find action k_p that maximizes val_mat(k,:)
        [val_fun,I_index] = max(val_mat, [], 2);
        % update convergence criterion and value funciton
        crit = max(abs(val_fun-val_temp)); 
        val_temp = val_fun;
        i = i + 1; 
    end
    fprintf('It takes %d iteration to converge\n', i);

% get table of value and policy function
    I_opt = I_grid(I_index); 
    opt3 = [k_grid,val_fun,I_opt]; 
    xlswrite("PS3_q3.xls",opt3)

%% simulation exercise
    k_0 = 5; % initial value for k
    T = 10; % check 10 periods
    num_sim = 5; % number of simulation

    k_t = zeros(T+1,num_sim); % initialize capital trajectory
    C_t = zeros(T,num_sim); % initialize consumption trajectory
    I_t = zeros(T,num_sim); % initialize investment trajectory
 
    rand_mat = rand(T,num_sim); % random matrix within (0,1) interval
    eps = -1*(rand_mat<=0.25) + 0*(rand_mat>0.25 & rand_mat<=0.75) + 1*(rand_mat>0.75); 

    k_t(1,:) = k_0; 
    for s=1:num_sim
        for t=2:T+1
            kk = (k_t(t-1,s)==opt3(:,1)); % find out the state for pervious period capital
            I_t(t-1,s) = I_opt(kk); % optimal investment in t-1
            k_t(t,s) = I_t(t-1,s) + eps(t-1,s); % k prime is I + eps, depending on the realization of epsilon according to simulation
        end
    end 

   C_t = (a+1)*k_t(1:T,:) - b/2*k_t(1:T,:).^2 - I_t; % calculate consuption

% draw graph
    figure
    subplot(2,2,1); plot(0:T, k_t); title('Capital');xlabel('t'); ylabel('k(t)'); axis([0 T+1 0 30])
    subplot(2,2,2); plot(0:T-1, I_t); title('Investment');xlabel('t'); ylabel('I(t)'); axis([0 T 0 30])
    subplot(2,2,3); plot(0:T-1, C_t); title('Consumption');xlabel('t'); ylabel('C(t)'); 
    subplot(2,2,4); plot(0:T-1, eps); title('\epsilon_t');xlabel('t'); ylabel('\epsilon(t)'); axis([0 T -2 2])
    print('Stochastic_inf','-dpng')


%% 4. Stochastic - finite
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear val_fun val_temp val_mat pi_mat optimum consumption k_p k_p_index k_0 T k_t C_t;

%% Initialize parameters & functions
    b = 2; % update b
    num_I = 28; % size of control grid
    I_max = 29;  % upper bound for capital
    I_min = 2;  % lower bound for capital
    I_grid = linspace(I_min,I_max,num_I)'; % create grid for captial 
    T = 4; % the last periods
    n_periods = T + 1; % number of periods
    last_period = n_periods; % number for last period
    val_fun = zeros(num_k,n_periods); % value function vector
    I_index = zeros(num_k,n_periods); % the index matrix of the control var - I
    pi_mat = zeros(num_k,num_I); % initialize per-period pay-off

% fill in per-priod pay-off
    % i is the state (k), j is the control (k')
    for k=1:num_k 
        for I = 1:num_I
            pi_mat(k,I) = log(func_k(k_grid(k)) + k_grid(k) - I_grid(I)); 
        end
    end

% value function in last period
    [val_fun(:,last_period),I_index(:,last_period)] = max(pi_mat, [], 2);


%% Backward iteration
% Calculate value function backwards
    for t = T:-1:1
        % initialize value function matrix - function of states & actions
        val_mat = zeros(num_k,num_I); 
        % calculate value function matrix
        for I = 1:num_I   
            val_mat(:,I) = pi_mat(:,I) + beta*M_sto(:,:,I)*val_fun(:,t+1); 
        end
        % for each state k, find action k_p that maximizes val_mat(k,:)
        [val_fun(:,t),I_index(:,t)] = max(val_mat, [], 2);
    end

% get table of value and policy function
    I_opt = I_grid(I_index); 
    opt4 = [k_grid,val_fun,I_grid(I_index)]; 
    xlswrite("PS3_q4.xlsx",opt4)

%% simulation exercise
    k_0 = 5; % initial value for k
    num_sim = 5; % number of simulation

    k_t = zeros(T+1,num_sim); % initialize capital trajectory
    C_t = zeros(T,num_sim); % initialize consumption trajectory
    I_t = zeros(T,num_sim); % initialize investment trajectory
 
    rand_mat = rand(T,num_sim); % random matrix within (0,1) interval
    eps = -1*(rand_mat<=0.25) + 0*(rand_mat>0.25 & rand_mat<=0.75) + 1*(rand_mat>0.75); 

    k_t(1,:) = k_0; 
    for s=1:num_sim
        for t=2:T+1
            kk = (k_t(t-1,s)==opt4(:,1)); % find out the state for pervious period capital
            I_t(t-1,s) = I_opt(kk,t-1); % optimal investment in t-1
            k_t(t,s) = I_t(t-1,s) + eps(t-1,s); % k prime is I + eps, depending on the realization of epsilon according to simulation
        end
    end 

   C_t = (a+1)*k_t(1:T,:) - b/2*k_t(1:T,:).^2 - I_t; % calculate consuption

% draw graph
    figure
    subplot(2,2,1); plot(0:T, k_t); title('Capital');xlabel('t'); ylabel('k(t)'); axis([0 T+1 0 30])
    subplot(2,2,2); plot(0:T-1, I_t); title('Investment');xlabel('t'); ylabel('I(t)'); axis([0 T 0 30])
    subplot(2,2,3); plot(0:T-1, C_t); title('Consumption');xlabel('t'); ylabel('C(t)'); 
    subplot(2,2,4); plot(0:T-1, eps); title('\epsilon_t');xlabel('t'); ylabel('\epsilon(t)'); axis([0 T -2 2])
    print('Stochastic_fin','-dpng')



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%    END PROGRAM    %%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
