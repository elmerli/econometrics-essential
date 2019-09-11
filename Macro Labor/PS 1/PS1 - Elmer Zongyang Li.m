%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Program Name:   PS3 - Elmer Zongyang Li.m
% Location:       /Users/zongyangli/Documents/Github/econometrics-essential/Macro Labor/PS 1/PS3 - Elmer Zongyang Li.m
% Author:         
% Date Created:   
% Project:        
% Input:          
% Output:         
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%% Question 2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% clear; clc; 
% parameters 
    c = 4.0; 
    mu = log(5.0); 
    sigma = 0.5; 
    beta = 0.95; 

% set up functions
    % the integral
    g = @(w_hat) (integral(@(w_prime) ((w_prime - w_hat).*lognpdf(w_prime,mu,sigma)),w_hat,1000));
    % fun = @(x) (x(2)/(1-x(2))*g(x(1)) + c - x(1)); % I was trying to calculate beta
    fun = @(x) (beta/(1-beta)*g(x) + c - x); 

% solve the functions
    % x0 = [0,0]; 
    x = fsolve(fun,0)


%% Question 3
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
% set up wage grid
    B = 100; 
    W=0:0.005:B;
    [rk,N]=size(W); % measure the dimension of grid

% create probability variable
    for i = 1:N
        if i == 1
            p(i) = logncdf(W(i)+0.0025,mu,sigma);
        elseif i > 1 & i <= (N-1)
            p(i) = logncdf(W(i)+0.0025,mu,sigma) - logncdf(W(i)-0.0025,mu,sigma);
        else
            p(i) = logncdf(W(i)-0.0025,mu,sigma);
        end
    end

% calcualte the value function for accepting/rejecting
    
    % initialize values
    val_acpt = zeros(N,1);
    val_rjct = zeros(N,1);
    v0 = zeros(N,1);
    crit = 10; % initialize criterion
    tol = 1e-10; % tolerance

    % value function iteration
    wage_int = @(w_prime) (integral(@(w_prime) (w_prime/(1-beta)).*lognpdf(w_prime,mu,sigma),0,B)); % set up the integral
    
    while crit>tol;
        for i = 1:N 
        % accept
            val_acpt(i) = W(i)/(1-beta); 
        % reject
            val_rjct(i) = c + beta*wage_int(v0(i)*p(i)); % instead using wage value, use wage * prob
            val_max(i) = max(val_acpt(i),val_rjct(i)); 
        % update criterion
            crit  = norm(val_max-v0);
            v0 = val_max; 
        end
    end

%% plot figures
    figure; hold on
    l1 = plot(W,val_acpt); M1 = 'Accept wage';
    l2 = plot(W,val_rjct); M2 = 'Reject wage';
    l3 = plot(W,v0, 'b--o'); M3 = 'Value';
    legend([l1;l2;l3], M1, M2, M3)
    text(5,100,'\leftarrow Reservation wage')
    xlabel('Wage')
    ylabel('Value')
    print('plot_reservation_wage','-dpng')



