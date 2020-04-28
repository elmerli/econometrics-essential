
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Program Name:   PS4.m
% Author:         Elmer Li
% Date Created:   04.12
% Project:        Resource economics
% Input:          
% Output:         
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all; clc;
cd '/Users/zongyangli/Google Drive/Cornell PhD/4th Semester/Resource economics/PS/PS 4'

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
		for j=1:N_sw
			for k=1:N_sr
				sigma_w_nu(i,j,k) = sum(a_w(i)==data(:,1) & s_w(j)==data(:,3) & s_r(k)==data(:,4)); 
				sigma_w_de(i,j,k) = sum(                    s_w(j)==data(:,3) & s_r(k)==data(:,4)); 
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
	N_theta = Cst.N_theta
	% actions and states
	Cst.a_r = a_r; Cst.a_w = a_w; 
	Cst.s_r = s_r; Cst.s_w = s_w;

% GMM estimate
	theta0 = rand(6,1); 
	

%% Form choice probabilities
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Form phi
phi_r = zeros(N_theta,N_ar,N_aw,N_sr); 

for i=1:N_ar
	for j=1:N_aw
		for k=1:N_sr
			if a_r(i) == 0 
				phi_r(5,i,j,k) = a_w(j); 
			else 
				phi_r(1,i,j,k) = a_r(i); 
				phi_r(2,i,j,k) = a_r(i)*a_w(j); 
				phi_r(4,i,j,k) = (2-a_r(i))*s_r(k); 
			end
        end
    end
end
phi_w = phi_r; % same because symmetric states & actions


%% Choice probabilities
sigma_r_phi = zeros(N_ar,N_sr,N_sw);
sigma_r_phi_nu = zeros(N_ar,N_sr,N_sw);
sigma_r_phi_de = zeros(N_ar,N_sr,N_sw);
sigma_w_phi = zeros(N_aw,N_sr,N_sw);
sigma_w_phi_nu = zeros(N_aw,N_sr,N_sw);
sigma_w_phi_de = zeros(N_sr,N_sw);


for k = 1:N_sw
    for j =1:N_sr            
    	for i = 1:N_ar  
        	sigma_r_phi_nu(i,j,k) = exp(phi_r(:,i,j,k)'*theta0);
        end
    	sigma_r_phi_de(:,j,k) = sum(sigma_r_phi_nu(1:3,j,k)); 
    end
end
sigma_r_phi = sigma_r_phi_nu./sigma_r_phi_de; 

for k = 1:N_sw
    for j =1:N_sr            
    	for i = 1:N_aw  
        	sigma_w_phi_nu(i,j,k) = exp(phi_w(:,i,j,k)'*theta0);
        end
    	sigma_w_phi_de(:,j,k) = sum(sigma_w_phi_nu(1:3,j,k)); 
    end
end
sigma_w_phi = sigma_w_phi_nu./sigma_w_phi_de; 


%% Form moment condition
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
%% Stack probabilities by looping through t,i,a_i; 
sigma_R = zeros(T,N_ar); % game by action matrix for R
sigma_W = zeros(T,N_aw); % game by action matrix for W

for t= 1:T
    for i = 1:N_ar
        a_R_value = a_r(i);
        s_R_value = data(t,3);
        j = s_R_value+1;
        s_W_value = data(t,4);
        k = s_W_value+1;
        
        sigma_R(t,i) = sigma_r_phi(i,j,k);
    end
end

for t= 1:T
    for i = 1:N_aw
        a_W_value = a_w(i);
        s_R_value = data(t,3);
        j = s_R_value+1;
        s_W_value = data(t,4);
        k = s_W_value+1;
        
        sigma_W(t,i) = sigma_w_phi(i,j,k);
    end
end

%% data vector 
yt_r = zeros(T,N_ar);
yt_w = zeros(T,N_aw);

for t= 1:T
    for i = 1:N_ar
    	yt_r(t,i) = (a_r(i)==data(t,1)); 
    end
end

for t= 1:T
    for i = 1:N_aw
    	yt_w(t,i) = (a_w(i)==data(t,2)); 
    end
end


%% moment condition & form objective
sigma_vec = [sigma_R sigma_W]; 
yt_vec = [yt_r yt_w]; 
diff_all = yt_vec - sigma_vec; 
mom1 = [diff_all(:,2:3) diff_all(:,5:6)]; 
mom2 = diff_all(:,1).*[data(:,3:4)]; 
mom3 = diff_all(:,4).*[data(:,3:4)]; 
diff = [mom1 mom2 mom3]; 
mean_diff = mean(diff,1); 
% objective
w= eye(8);
obj = mean_diff*w*mean_diff';












