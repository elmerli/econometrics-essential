
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


%% Structural estimation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Non-parametric estimation for M, g and V_c

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
	g = g_num./g_dem; 	 
	data(N_kt+1,:) = [];














