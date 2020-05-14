function [theta_hat, g_hat_hat, val_fun_hat, obj_val]=estimate_ps5(par,data)
% program to be used for gmm estimate

%% data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% constants
	omega = par.omega; 
    beta = par.beta; 
    N_kt = length(data(:,1)); 
    N_s = max(data(:,3)) + 1; % num of states
% Form I_kt and abatement matrix
	data(N_kt+1,:) = data(N_kt,:); % add last row for ease of looping
	for n_kt = 1:N_kt
		% I_at
		data(n_kt,6) = data(n_kt+1,4) - data(n_kt,4); 
		if data(n_kt,4) == 1; 
			data(n_kt,6) = -99; 
        end		
		% I_bt
        data(n_kt,7) = data(n_kt+1,5) - data(n_kt,5); 
		if data(n_kt,5) == 1; 
			data(n_kt,7) = -99; 
        end
		% abatement
        data(n_kt,8) = data(n_kt,4) + data(n_kt,5); 
		if data(n_kt,8) == 2; 
			data(n_kt,8) = -99; 
        end
    end
    data(N_kt+1,:) = []; 


% form state matrix
	N_a = max(data(:,8)) + 1; 	
	N_as = N_a*N_s; % number of tuples


%% Non-parametric estimation for M, g and V_c
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% transition matrix 
	M_num = zeros(N_as,N_as); 
	M_dem = zeros(N_as,1); 
	data(N_kt+1,:) = 0; % add last row for ease of looping

	for row = 1: N_as
		for obs = 1: N_kt
			if data(obs,6) == 0 || data(obs,7) == 0
				if data(obs,8) == omega(row,1) && data(obs,3) == omega(row,2) % state in the tuple == state in the data
					M_dem(row,1) = M_dem(row,1) + 1; 
					for col = 1:N_as
						if data(obs+1,8) == omega(col,1) && data(obs+1,3) == omega(col,2)
							M_num(row,col) = M_num(row,col) + 1; 	
						end
					end
				end 
			end 
		end 
	end 
	M = M_num./M_dem; 	 

% policy function
	g_num = zeros(N_as,1); 
	g_dem = zeros(N_as,1); 

	for row = 1: N_as
		for obs = 1: N_kt
			if data(obs,8) == omega(row,1) && data(obs,3) == omega(row,2) && data(obs,6) ==0 % state in the tuple == state in the data
				g_dem(row,1) = g_dem(row,1) + 1; 
				if data(obs+1,6) ==1
					g_num(row,1) = g_num(row,1) + 1; 	
				end
			end 
		end 
		for obs = 1: N_kt
			if data(obs,8) == omega(row,1) && data(obs,3) == omega(row,2) && data(obs,7) ==0 % state in the tuple == state in the data
				g_dem(row,1) = g_dem(row,1) + 1; 
				if data(obs+1,7) ==1
					g_num(row,1) = g_num(row,1) + 1; 	
				end
			end 
		end 
	end 
	g_emp = g_num./g_dem; 	 
	data(N_kt+1,:) = [];


%% Pack parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	par.g_dem = g_dem; 
	par.g_emp = g_emp; 
	par.M = M; 


%% GMM estimate
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% set opitions
	theta0 = rand(2,1); 
	i_max = 5000;
	tol_mmts = 1e-10;
	tol_paras = 1e-10;
	max_fun_evals = 500000;
	options = optimset( 'Display', 'off', ...
	                    'MaxIter', i_max, ...
	                    'TolFun', tol_mmts, ...
	                    'TolX', tol_paras, ...
	                    'MaxFunEvals', max_fun_evals); 

	% set objecive & optimize
	objfun = @(theta) gmm_ps5(theta, par);
	[theta_hat, obj_val, exit_flag]= fminunc(objfun, theta0, options);

	% value function and policy function
	sigma_hat = 1; 
	gamma1_hat = theta_hat(1); 
	gamma2_hat = theta_hat(2); 
	gamma_hat = [gamma1_hat gamma2_hat]';

	I = eye(4); 
	val_fun_hat = ((I-beta*M)\(sigma_hat*g_emp));
	g_hat_hat = exp(-(beta*val_fun_hat-omega*gamma_hat)/sigma_hat); 



