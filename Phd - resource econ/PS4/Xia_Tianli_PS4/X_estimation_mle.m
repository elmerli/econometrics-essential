function [theta_hat, obj_val, exit_flag] = X_estimation_mle(Cst,data,theta0)
%   AEM 7500  PS #4 sub-program 1
%   This program is called by the main script to carry out the GMM
%   estimation of the parameters. If not used by boostrap, it also
%   automatically test the sanity of the initial guess by choosing randomly
%   multiple starting point (results stored in the .mat).
%   
%   - Function outputs: 'theta_hat' is the estimated coefficients from GMM,
%   whose size is a 3-2 matrix with each col for each player; 'obj_val' is 
%   the objective function evaluated at theta_hat, which should be close
%   to 0; 'exit_flag' is the stopping criteria for the optimizatin routine.
%   
%   - Function inputs: 'Cst' is a struct holding scalar values for
%   constants related to the game; 'data' is of the class data storing the
%   data we use for estimation; 'theta0' is the initial guess used for GMM.
%
%   Note1: the multi-start exercise will be turned off in the
%   boostraping process.
%   Note2: the initial guess used in the normal GMM routine is 1



%% Unpack data & parameters
% parameters used in this function (but not the nested funtion WF2)
N_ar = Cst.N_ar;
N_aw = Cst.N_aw;
N_sr = Cst.N_sr;
N_sw = Cst.N_sw;
T= Cst.T;

a_r = Cst.a_r;
a_w = Cst.a_w;
s_r = Cst.s_r;
s_w = Cst.s_w;

%% Part I: First step - Estimate non-parametrically ex-ante choice probabilities
%   Estimate the ex-ante choice probability (or policy function) 
%   which is then used in the GMM estimation later in order to form 
%   the moment conditions.
%   This step is repeated only if we do bootstrap to redraw our sample.

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

% Also gnerate new data: x that can be passed
sr= data(:,3);
sw= data(:,4);
% x=[a_r, a_r*a_w, (2-a_r)*s_r, aw];
x= kron(data, ones(N_ar,1));
tid= kron((1:T)', ones(N_ar,1));
action_rr= repmat((1:N_ar)'-1, T, 1);
action_ww= repmat((1:N_ar)'-1, T, 1);
action_rw=[];
for i=1:length(x)
    action_rw(i,1)= [0,1,2]*sigma_w(:,x(i,3)+1,x(i,4)+1);
end
action_wr=[];
for i=1:length(x)
    action_wr(i,1)= [0,1,2]*sigma_r(:,x(i,3)+1,x(i,4)+1);
end

xx1=-[action_rr, action_rw.*action_rr, (2-action_rr).*x(:,3).*(action_rr~=0), action_rw.*(action_rr==0)];
xx2=-[action_ww, action_wr.*action_ww, (2-action_ww).*x(:,4).*(action_ww~=0), action_wr.*(action_rr==0)];
xx= blkdiag(xx1, xx2);

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

objfun = @(theta) X_MLE(theta, Cst, data, xx, sr, sw);

disp("MLE")
[theta_hat, obj_val, exit_flag, ~, ~, hessian]= fminunc(objfun, theta0, options);

display(theta_hat)
display(obj_val)
display(sqrt(diag(hessian/T)))

end

    