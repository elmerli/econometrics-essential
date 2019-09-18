%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Program Name:   PS3 - Elmer Zongyang Li.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Question 2-3
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear; clc; 

% data & parameters
    rho = 0.005;    
    cps2002 = load('cps2002.txt'); 
    dat = cps2002; 
    dat(:,1) = dat(:,1) ./100; % change the scale of data
    [N, ~] = size(dat); 
    Nu = sum(dat(:,2)>0); % num of unemployed - use >0 to count #
    Ne = N - Nu; % num of employed
    wage = dat(dat(:,1)>0,1); % the wages of the employed
    rwage = min(wage); % empirical minimum of the wages

% optimization by calling loglike function

    % initialize the parameter of interest (mu, sigma, lambda, delta)
    theta0 = [rwage,1,1,1]; 
    lb = [0,0,-Inf,-Inf];
    ub = [Inf,Inf,Inf,Inf];
    % optmizaiton
    [theta1,fval,exitflag,output,lagrange,grad,hessian1] = fmincon(@(theta) loglike(theta, dat, "logn"),theta0,[],[],[],[],lb,ub); 

% estimation results
    mu_hat = theta1(1); 
    sigma_hat = theta1(2); 
    lambda1 = theta1(3); 
    delta1 = theta1(4); 
    % the standard error
    err1 = sqrt(diag(inv(hessian1))); 
    % the social benefit
        % in last homework, there are two unknowns, w_prime & w_hat. Now, only one unknown, so don't need to solve
    intgrand1 = @(w) (w-rwage).*lognpdf(w,mu_hat,sigma_hat);
    b_1 = rwage-lambda1/(rho+delta1)*integral(@(w)intgrand1(w),rwage,max(wage));


% plot figures
    figure(1)
    histogram(wage(wage(:)>0),60,'Normalization','pdf')
    hold on
    x = 0:0.01:max(wage); 
    y = lognpdf(x,mu_hat,sigma_hat); 
    plot(x,y,'--','LineWidth',1)
    title ('Lognormal distribution')
    legend( 'Actual wage dist' , 'Estimated wage dist') 
    xlabel('Wage, (in hundreds)')
    print('plot_lognormal_wage','-dpng')


%% Question 4 - change dist
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% initialize the parameter of interest (mu, sigma, lambda, delta)
    theta0 = [rwage,1,1]; 
    lb = [0,0,0];
    ub = [Inf,1,1];
    % optmizaiton
    [theta2,fval,exitflag,output,lagrange,grad,hessian2] = fmincon(@(theta) loglike(theta, dat, "exp"),theta0,[],[],[],[],lb,ub); 

% estimation results
    alpha_hat = theta2(1); 
    lambda2 = theta2(2); 
    delta2 = theta2(3); 
    % the standard error
    err2 = sqrt(diag(inv(hessian2))); 
    % the social benefit
        % in last homework, there are two unknowns, w_prime & w_hat. Now, only one unknown, so don't need to solve
    intgrand2 = @(w) (w-rwage).*alpha_hat.*exp(-alpha_hat*w);
    b_2 = rwage-lambda2/(rho+delta2)*integral(intgrand2,rwage,max(wage));


% plot figures
    figure(2)
    histogram(wage(wage(:)>0),60,'Normalization','pdf')
    hold on
    x = 0:0.01:max(wage); 
    y = alpha_hat*exp(-alpha_hat*x); 
    plot(x,y,'--','LineWidth',1)
    title ('Negative exponential distribution')
    legend( 'Actual wage dist' , 'Estimated wage dist') 
    xlabel('Wage, (in hundreds)')
    print('plot_neg_exponential_wage','-dpng')

% quantile comparison
    q = [0.1 0.25 0.5 0.75 0.9]; 
    N=length(dat);
    dat_sort=sort(dat(:,1)); 
    dat_sort(round(N.*q))' % the round(N.*q) gives numbr position of the quantiles; then this returns the data values of quantiles
    logninv(q,mu_hat,sigma_hat) % inverse cdf decides a value x such that the probability of X ≤ x is greater than or equal to p.
    expinv(q,1/alpha_hat)


%% Question 5 - Mm ratio
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% data
    Mm_dat = mean(wage)/rwage; 
% lognormal distribution
    eta_1 = b_1/mean(wage); 
    Mm_log = (lambda1+rho+delta1)/(eta_1*(rho+delta1)+lambda1); 
% neg-exp distribution
    eta_2 = b_2/mean(wage); 
    Mm_exp = (lambda2+rho+delta2)/(eta_2*(rho+delta2)+lambda2); 


%% Question 6
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    Unemp_hat = 1/(lambda1*(1−logncdf(rwage,mu_hat,sigma_hat))); 
    Unemp = mean(dat(dat(:,2)>0,2));
    Unemp_hat/Unemp








