function obj=GMM_obj(theta,Cst,data)
%   This program is called by the main script to carry out the GMM
%   estimation of the parameters. 


%% Unpack data & parameters
N_ar = Cst.N_ar;
N_aw = Cst.N_aw;
N_sr = Cst.N_sr;
N_sw = Cst.N_sw;
T= Cst.T;
N_theta = Cst.N_theta; 

a_r = Cst.a_r;
a_w = Cst.a_w;
s_r = Cst.s_r;
s_w = Cst.s_w;


%% Estimate non-parametrically ex-ante choice probabilities
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% initialize sigma arrays
sigma_r = zeros(N_ar, N_sr, N_sw);
sigma_w = zeros(N_aw, N_sr, N_sw);

% sigma_r
for i=1:N_ar
    for j=1:N_sr
        for k=1:N_sw
        sigma_r(i,j,k)= ...
            sum( a_r(i)==data(:,1) & s_r(j)==data(:,3) & s_w(k)==data(:,4) )... 
           /sum(                     s_r(j)==data(:,3) & s_w(k)==data(:,4) );
        end
    end      
end

% sigma_w
for i=1:N_aw
    for j=1:N_sr
        for k=1:N_sw
        sigma_w(i,j,k)= ...
            sum( a_w(i)==data(:,2) & s_r(j)==data(:,3) & s_w(k)==data(:,4) )...
           /sum(                    s_r(j)==data(:,3) & s_w(k)==data(:,4));
        end
    end      
end


%% Form choice probabilities
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Form phi
phi_r = zeros(N_theta,N_ar,N_sr,N_sw); 
phi_w = zeros(N_theta,N_aw,N_sr,N_sw); 

% phi_r
for i=1:N_ar
    for j=1:N_aw
        for sr=1:N_sr
            for sw=1:N_sw
                if a_r(i) == 0 
                    phi_r(5,i,sr,sw) = phi_r(5,i,sr,sw) - a_w(j)*(sigma_w(j,sr,sw)); % accumulative
                else 
                    phi_r(1,i,sr,sw) = -a_r(i); 
                    phi_r(2,i,sr,sw) = phi_r(2,i,sr,sw) - a_r(i)*a_w(j)*(sigma_w(j,sr,sw)); 
                    phi_r(4,i,sr,sw) = -(2-a_r(i))*s_r(sr); 
                end
            end
        end
    end
end

% phi_w
for j=1:N_aw
    for i=1:N_ar
        for sr=1:N_sr
            for sw=1:N_sw
                if a_w(j) == 0 
                    phi_w(6,j,sr,sw) = phi_w(6,j,sr,sw) - a_r(i)*(sigma_r(i,sr,sw));
                else 
                    phi_w(1,j,sr,sw) = -a_w(j);
                    phi_w(3,j,sr,sw) = phi_w(3,j,sr,sw) - a_r(i)*a_w(j)*(sigma_r(i,sr,sw));
                    phi_w(4,j,sr,sw) = -(2-a_w(j))*s_w(sw);
                end
            end
        end
    end
end


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
            sigma_r_phi_nu(i,j,k) = exp(phi_r(:,i,j,k)'*theta);
        end
        sigma_r_phi_de(:,j,k) = sum(sigma_r_phi_nu(1:3,j,k)); 
    end
end
sigma_r_phi = sigma_r_phi_nu./sigma_r_phi_de; 

for k = 1:N_sw
    for j =1:N_sr            
        for i = 1:N_aw  
            sigma_w_phi_nu(i,j,k) = exp(phi_w(:,i,j,k)'*theta);
        end
        sigma_w_phi_de(:,j,k) = sum(sigma_w_phi_nu(1:3,j,k)); 
    end
end
sigma_w_phi = sigma_w_phi_nu./sigma_w_phi_de; 


%% Form moment condition & objective
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

% objective - MLE
f= -sum(log(sigma_vec(:)).*yt_vec(:));





