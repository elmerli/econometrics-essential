
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Program Name:   PS4.m
% Author:         Elmer Li
% Date Created:   04.12
% Project:        Resource economics
% Input:          
% Output:         
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all; clc;
cd '/Users/zongyangli/Google Drive/Academic 其他/GitHub/econometrics-essential/Phd - resource econ/PS4'

%% Import data, initial paramters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[data, varname, ~] = xlsread('AEM7500_PS4_data_spring2020.xlsx');

% constants
	N_ar = 3; N_aw = 3; 
	N_sr = 3; N_sw = 3; 
	T = size(data,1); % this is the number of games in the data

% actions and states
	a_r = (0:2); a_w = (0:2); 
	s_r = (0:2); s_w = (0:2);

% initalize empirical prob array
	sigma_r = zeros(N_ar, N_sr, N_sw); 
	sigma_r_nu = zeros(N_ar, N_sr, N_sw); 
	sigma_r_de = zeros(N_ar, N_sr, N_sw); 

	sigma_w = zeros(N_aw, N_sw, N_sr); 
	sigma_w_nu = zeros(N_aw, N_sw, N_sr); 
	sigma_w_de = zeros(N_aw, N_sw, N_sr);


%% Form sigma array
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% for country R
	for i=1:N_ar
		for j=1:N_sr
			for k=1:N_sw
				sigma_r_nu(i,j,k) = sum(a_r(i)==data(:,1) & s_r(j)==data(:,3) & s_w(k)==data(:,4)); 
				sigma_r_de(i,j,k) = sum(                    s_r(j)==data(:,3) & s_w(k)==data(:,4)); 
			end
		end
	end 

	sigma_r = sigma_r_nu./sigma_r_de; 

% for country W
	for i=1:N_aw
		for j=1:N_sr
			for k=1:N_sw
				sigma_w_nu(i,j,k) = sum(a_w(i)==data(:,2) & s_r(j)==data(:,3) & s_w(k)==data(:,4)); 
				sigma_w_de(i,j,k) = sum(                    s_r(j)==data(:,3) & s_w(k)==data(:,4)); 
			end
		end
	end 

	sigma_w = sigma_w_nu./sigma_w_de; 

% output results
	ar_sr_sw = combvec(a_r, s_r, s_w)'; % all possible combinatios
	aw_sw_sr = combvec(a_w, s_r, s_w)';
	xlswrite('sigma_r_choice_prob.xlsx',["a_r", "s_r", "s_w", "prob"],'sigma_r','A1')
	xlswrite('sigma_r_choice_prob.xlsx',[ar_sr_sw, reshape(sigma_r, [], 1)],'sigma_r','A2')

	xlswrite('sigma_w_choice_prob.xlsx',["a_r", "s_r", "s_w", "prob"],'sigma_w','A1')
	xlswrite('sigma_w_choice_prob.xlsx',[aw_sw_sr, reshape(sigma_w, [], 1)],'sigma_w','A2')


%% GMM Estimation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% pack parameters to structure
	% constants
	Cst.N_ar = N_ar; Cst.N_aw = N_aw;
	Cst.N_sr = N_sr; Cst.N_sw = N_sw;
	Cst.T = T;
	Cst.N_theta = 6; 
    N_theta = 6; 
	% actions and states
	Cst.a_r = a_r; Cst.a_w = a_w; 
	Cst.s_r = s_r; Cst.s_w = s_w;

% GMM estimate
	% set opitions
	theta0 = rand(6,1); 
	max = 5000;
	tol_mmts = 1e-10;
	tol_paras = 1e-10;
	max_fun_evals = 5000;
	options = optimset( 'Display', 'off', ...
	                    'MaxIter', max, ...
	                    'TolFun', tol_mmts, ...
	                    'TolX', tol_paras, ...
	                    'MaxFunEvals', max_fun_evals); 

	% set objecive & optimize
	objfun = @(theta) GMM_obj(theta, Cst, data);
	[theta_hat, obj_val, exit_flag]= fminunc(objfun, theta0, options);

	display(theta_hat)
	display(obj_val)
    xlswrite('gmm_bootstrap', theta_hat, 1)        


%% GMM - boostrap
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

N_bootstrap=25;
T=Cst.T;
data_raw=data;
theta_hat_bootstrap=zeros(6, N_bootstrap);

% BS procedure
tic
for b=1:N_bootstrap
    % resample the data
    b_index=ceil(T*rand(1,T));  % random bootstrap index -- random gen T numbers, scale up by T
    data_bs=data_raw(b_index,:);   % bootstrap data set
    % estimate parameters using GMM for each sample
    fprintf('bootstrap # %d \n', b); 
    objfun = @(theta) GMM_obj(theta, Cst, data_bs);
    [theta_hat, obj_val, exit_flag]= fminunc(objfun, theta0, options);
    % store results in a matrix
    theta_hat_bootstrap(:,b)=theta_hat;
end
save theta_hat_bootstrap

% calculate std
    % Calculate the mean estimate and bootstrap standard error
    mean(theta_hat_bootstrap,2) 
    std(theta_hat_bootstrap,0,2)
    xlswrite('gmm_bootstrap2', [mean(theta_hat_bootstrap,2), std(theta_hat_bootstrap,0,2)], 2 )        
    
% plot
	mu_b=mean(theta_hat_bootstrap,2);
	for p=1:N_theta
	    subplot(2, 3, p);
	    % plot the distribution of the bootstrap estimates for each theta
	    histogram(theta_hat_bootstrap(p,:), 'BinWidth', 0.1)
	    xlabel(['theta' num2str(p)])
	    ylabel('Frequency')
	    hold on
	    % plot the mean of the bootstrap estimates of each theta
	    plot([mu_b(p) mu_b(p)],[0 50],'--r')
	end
	print('Bootstrap_gmm','-dpng', '-r600')  








