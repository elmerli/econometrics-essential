function obj=gmm_ps5(theta,par)
% program to be used for gmm estimate
% unpack parameters
	g_dem = par.g_dem; 
	g_emp = par.g_emp; 
	M = par.M; 
    beta = par.beta; 
    omega = par.omega; 
	% sigma = theta(1); 
	sigma = 1; 
	gamma1 = theta(1); 
	gamma2 = theta(2); 
	gamma = [gamma1 gamma2]';

% calculate value function and g_hat
	I = eye(4); 
	val_fun = @(sigma) ((I-beta*M)\(sigma*M*g_emp)); % notice here is mrdevide
	g_hat = exp(-(beta*val_fun(sigma)-omega*gamma)./sigma); 

% moment conditions and objective
	mom1 = (g_hat - g_emp).*g_dem;
	mom2 = (g_hat - g_emp).*omega(:,1);
	mom3 = (g_hat - g_emp).*omega(:,2);
	% the last two moment conditions assume the state var is exogeneous
	% since there are 4 state tuples, can use each of it that g_hat = g_emp to have 4 moment conditions (check tianli's second set of mmts)

	diff = [mom1 mom2 mom3]; 
	diff_mean = mean(diff,1); % mean by column
	w= eye(3); % 3 moments, equal weighted
	% obj = diff_mean*w*diff_mean';
	obj = mom1'*eye(4)*mom1;










