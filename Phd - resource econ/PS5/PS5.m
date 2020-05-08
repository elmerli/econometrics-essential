
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

% I_ikt matrix - long formats
	I_a = zeros(N_kt,1); 

	for i = 1:N_k
		for j = 1:N_t
			if data((i-1)*N_t + j, 4) == 1
				I_a((i-1)*N_t + j - 1,1) = 1; 
	       	end
		end 
	end
	for i = 1:N_k
		for j = 1:N_t
	       	if data((i-1)*N_t + j, 4) == 1
	       		I_a((i-1)*N_t + j,1) = -99; 
	       	end
		end 
	end

% I_ikt matrix - matrix formats
% I_a
	I_a = zeros(N_k,N_t); 
	for i = 1:N_k
		for j = 1:N_t
			if data((i-1)*N_t + j, 4) == 1 && j>=2
				I_a(i,j-1) = 1; 
            end
		end 
    end
    for i = 1:N_k
		for j = 1:N_t
	       	if data((i-1)*N_t + j, 4) == 1
	       		I_a(i,j) = -99; 
	       	end
		end 
	end
	I_a(:,16) = -99; 

% I_b
	I_b = zeros(N_k,N_t); 
	for i = 1:N_k
		for j = 1:N_t
			if data((i-1)*N_t + j, 5) == 1 && j>=2
				I_b(i,j-1) = 1; 
            end
		end 
    end
    for i = 1:N_k
		for j = 1:N_t
	       	if data((i-1)*N_t + j, 5) == 1
	       		I_b(i,j) = -99; 
	       	end
		end 
	end
	I_b(:,16) = -99; 


% form abatement matrix
	a_mat =  zeros(N_k,N_t); 
	for i = 1:N_k
		for j = 1:N_t
			a_mat(i,j) = data((i-1)*N_t+j,4) + data((i-1)*N_t+j,5);   
		end 
	end

% delete observations
	data_cl = data; 
	data_cl(:,6) = data_cl(:,4) + data_cl(:,5);
	for i = 1:N_k
		for j = 1:N_t
			if data_cl((i-1)*N_t + j, 6) == 2 && j>=2
				 data_cl((i-1)*N_t + j-1, 6) = 2; % revise so that prior year shows when both cities install
	       	end
		end 
	end
	toDelete = data_cl(:,6)==2; 
	data_cl(toDelete,:) = []; 

% form state matrix
	N_a = max(a(:)) + 1; 
	s = (0:1); 
	a = (0:2); 
	k = (1:N_k); 
	t = (0:N_t-1); 
	
	omega = zeros(N_a*N_s,2,N_t,N_k); 
	for k_i = 1:N_k
		for t_i = 1:N_t
			for s_i = 1: N_s
				for a_i = 1: N_a
					omega((s_i-1)*N_a+a_i,1,t_i,k_i) = a(a_i); 
					omega((s_i-1)*N_a+a_i,2,t_i,k_i) = s(s_i); 
				end 
			end
		end 
	end 


%% Structural estimation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Non-parametric estimation for M, g and V_c

% transition matrix 


% policy function
g = zeros(N_a*N_s); 
			g((s_i-1)*N_a+a_i,1,t_i,k_i) = ...

	for s_i = 1: N_s
		for a_i = 1: N_a
			for k_i = 1:N_k
	            sum(data(:,1) & s_r(j)==data(:,3) & s_w(k)==data(:,4) )... 
				/sum( s_r(j)==data(:,3) & s_w(k)==data(:,4) );

		end 
	end











