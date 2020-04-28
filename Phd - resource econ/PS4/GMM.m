function [theta_hat, obj_val, exit_flag] = GMM(Cst,data,theta0)
%   This program is called by the main script to carry out the GMM
%   estimation of the parameters. 


%% Unpack data & parameters
N_ar = Cst.N_ar;
N_aw = Cst.N_aw;
N_sr = Cst.N_sr;
N_sw = Cst.N_sw;
T= Cst.T;

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


for i=1:N_aw
    for j=1:N_sr
        for k=1:N_sw
        sigma_w(i,j,k)= ...
            sum( a_w(i)==data(:,2) & s_r(j)==data(:,3) & s_w(k)==data(:,4) )...
           /sum(                    s_r(j)==data(:,3) & s_w(k)==data(:,4));
        end
    end      
end


%% Part II: Second step - Estimate parameters using GMM
% Pack sigma arrays estimated in step 1 in order to carry over into GMM obj function
% Set up optimization routine
% initial guess theta0 was already specified in the main script and passed into the
%   argument of this function.

max = 5000;
tol_mmts = 1e-10;
tol_paras = 1e-10;
max_fun_evals = 5000;
options = optimset( 'Display', 'off', ...
                    'MaxIter', max, ...
                    'TolFun', tol_mmts, ...
                    'TolX', tol_paras, ...
                    'MaxFunEvals', max_fun_evals); 
w= eye(8);

objfun = @(theta) X_GMM_obj(theta, Cst, data, xx, sr, sw, w);

disp("Efficient GMM: first stage")
[theta_hat, obj_val, exit_flag]= fminunc(objfun, theta0, options);

display(theta_hat)
display(obj_val)
if efficient_gmm==1
    disp("Efficient GMM: second stage")
    w= X_GMM_w(theta_hat, Cst, data, xx, sr, sw);
    objfun = @(theta) X_GMM_obj(theta, Cst, data, xx, sr, sw, w);
    [theta_hat, obj_val, exit_flag]= fminunc(objfun, theta0, options);
display(theta_hat)
display(obj_val)

end

