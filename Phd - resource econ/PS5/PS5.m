
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Program Name:   PS5.m
% Author:         Elmer Li
% Date Created:   05.04
% Project:        Resource economics
% Input:          
% Output:         
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all; clc;
cd '/Users/zongyangli/Google Drive/Academic 其他/GitHub/econometrics-essential/Phd - resource econ/PS5'

%% Set up necessary matrixes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[data, varname, ~] = xlsread('AEM7500_PS5_data_spring2020.xlsx');

% constants
	N_k = max(data(:,1)); % num of neighbors
    N_t = max(data(:,2)) + 1; % num of periods
    N_s = max(data(:,3)) + 1; % num of states
    N_kt = N_k*N_t; 
    beta = 0.9; 


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

	I_a = reshape(data(:,6), [N_t,N_k])'; % first the number of time, then the number of neighbors, then transform
	I_b = reshape(data(:,7), [N_t,N_k])';
	a_mat = reshape(data(:,8), [N_t,N_k])';


% form state matrix
	N_a = max(a_mat(:)) + 1; 
	s = (0:1); 
	a = (0:1); 
	k = (1:N_k); 
	t = (0:N_t-1); 
	
	N_as = N_a*N_s; % number of tuples
	omega = zeros(N_as,2); 
	for s_i = 1: N_s
		for a_i = 1: N_a
			omega((s_i-1)*N_a+a_i,1) = a(a_i); 
			omega((s_i-1)*N_a+a_i,2) = s(s_i); 
		end 
	end


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
    xlswrite('ps5_gmm_M', M, 1) 

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
    xlswrite('ps5_gmm_g_emp', g_emp, 1) 

% clean data
	% data_cl = data; 
	% data_cl(:,9) = data_cl(:,4) + data_cl(:,5);
	% for i = 1:N_k
	% 	for j = 1:N_t
	% 		if data_cl((i-1)*N_t + j, 9) == 2 && j>=2
	% 			 data_cl((i-1)*N_t + j-1, 9) = 2; % revise so that prior year shows when both cities install
	%        	end
	% 	end 
	% end
	% toDelete = data_cl(:,9)==2; 
	% data_cl(toDelete,:) = []; 

%% GMM estimation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% pack parameters to structure
	par.omega = omega;
	par.beta = beta;

% GMM estimate
	[theta_hat, g_hat_hat, val_fun_hat, obj_val]=estimate_ps5(par,data);
    display(theta_hat); 
    xlswrite('ps5_gmm_theta_hat', theta_hat, 1) 
    xlswrite('ps5_gmm_val_fun_hat', val_fun_hat, 2) 
    xlswrite('ps5_gmm_g_hat_hat', g_hat_hat, 3) 



%% GMM - boostrap
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

N_bootstrap=100;
theta_hat_bs=zeros(2, N_bootstrap);
g_hat_hat_bs=zeros(4, N_bootstrap);
val_fun_hat_bs=zeros(4, N_bootstrap);

% BS procedure
tic
for b=1:N_bootstrap
    % resample the data
    b_index=ceil(N_k*rand(1,N_k));  % random bootstrap index -- random gen T numbers, scale up by T
    data_bs = []; 
    for k = 1:N_k
        data0 = data(data(:,1)==b_index(k),:);
        data_bs = [data_bs; data0];   % bootstrap data set
    end  
    % estimate parameters using GMM for each sample
    fprintf('bootstrap # %d \n', b); 
	[theta_hat_bs(:,b), g_hat_hat_bs(:,b), val_fun_hat_bs(:,b)]=estimate_ps5(par,data_bs);    % store results in a matrix
end
save theta_hat_bs

% calculate std
    % Calculate the mean estimate and bootstrap standard error
    mean(theta_hat_bs,2) 
    std(theta_hat_bs,0,2)
    xlswrite('gmm_bootstrap', [mean(theta_hat_bs,2), std(theta_hat_bs,0,2)], 2 )        
    
% plot
	N_para = 2; 
	mu_b=mean(theta_hat_bs,2);
	for p=1:N_para
	    subplot(2, 1, p);
	    % plot the distribution of the bootstrap estimates for each theta
	    histogram(theta_hat_bs(p,:), 'BinWidth', 0.1)
	    xlabel(['gamma' num2str(p)])
	    ylabel('Frequency')
	    hold on
	    % plot the mean of the bootstrap estimates of each theta
	    plot([mu_b(p) mu_b(p)],[0 50],'--r')
	end
	print('gmm_bootstrap_plot','-dpng', '-r600')  









