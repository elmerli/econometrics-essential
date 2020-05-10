function obj=gmm_ps5(theta,par)
% program to be used for gmm estimate

% unpack matrixes and parameters
	g_emp = par.g_emp;
	g_dem = par.g_dem;
    M = par.M; 
	omega = par.omega; 
    beta = par.beta; 
	sigma = theta(1); 
	gamma1 = theta(2); 
	gamma2 = theta(3); 
	gamma = [gamma1 gamma2]';

% calculate value function and g_hat
	I = eye(4); 
	val_fun = @(sigma) ((sigma*g_emp)\(I-beta*M))'; % notice here is mrdevide
	g_hat = exp(-(beta*val_fun(sigma)-omega*gamma)/sigma); 

% moment conditions and objective
	mom1 = (g_hat - g_emp).*g_dem;
	mom2 = (g_hat - g_emp).*omega(:,1);
	mom3 = (g_hat - g_emp).*omega(:,2);

	diff = [mom1 mom2 mom3]; 
	diff_mean = mean(diff,1); % mean by column
	w= eye(3); % 3 moments, equal weighted
	obj = diff_mean*w*diff_mean';










