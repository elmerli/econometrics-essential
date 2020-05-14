function obj = X_GMM_obj1(theta, Cst)
global beta

%% Unpack estimates
data_ikt=Cst.data_ikt;
tuple=Cst.tuple;
M=Cst.M;
g_bar=Cst.g_bar;
inversion=Cst.inversion;
W=Cst.W;
%% Fixed point iteration and solve for continuation value function v^c
gamma = theta(1:2);
%sigma = theta(3);
sigma = 1;

if inversion==0
    % Initialize guess for v^c
    v0 = zeros(size(tuple,1),1);

    % Stopping criterion 
    epsilon = 1e-5;

    % Start with a value of difference greater than epsilon
    diff = epsilon + 10;

    % Initialize v to be equal to initial guess
    v_new = v0;
 
    i = 0; % iteration counter
    while diff > epsilon
        % Reset v to v_new
        v = v_new;

        % Calcualte g
        %g = exp(-(beta*v - tuple*gamma)./sigma);

        % Calculate v_new
        v_new = M*(beta.*v + sigma.*g_bar);

        % calculate difference using sup norm
        diff = max(abs(v_new-v));

        i = i+1;
        %fprintf('Iteration %d\n', i);
        %         if i>10000 
        %             break 
        %         end
    end
    %fprintf('End of Iteration\n');
    
else
    % WARNING: the computation order c*A\B= (c*A)\B
    v_new= (eye(length(tuple))-beta*M)\(M*g_bar)*sigma;
end
    
% Calculate g_hat
v = v_new;
g_hat = exp(-(beta*v - tuple*gamma)./sigma);

% Calculate weighted moment    
% m1 = mean(  g_hat(data_ikt.Omega_idx)-g_bar(data_ikt.Omega_idx) );
% m2 = mean( (g_hat(data_ikt.Omega_idx)-g_bar(data_ikt.Omega_idx)).*data_ikt.a );
% m3 = mean( (g_hat(data_ikt.Omega_idx)-g_bar(data_ikt.Omega_idx)).*data_ikt.s );
% m4 = mean( (g_hat(data_ikt.Omega_idx)-g_bar(data_ikt.Omega_idx)).*(data_ikt.s==1).*(data_ikt.a==1) );

% Equivalently
m1= Cst.obs'*(g_hat- g_bar)./sum(Cst.obs);
m2= [ 0; 0; Cst.obs(3:4)]'*(g_hat- g_bar)./sum(Cst.obs);
m3= [ 0; Cst.obs(2); 0; Cst.obs(4)]'*(g_hat- g_bar)./sum(Cst.obs);
%m4= [ 0; 0; 0; Cst.obs(4)]'*(g_hat- g_bar)./sum(Cst.obs);

%m = [m1 m2 m3 m4];
m= [m1 m2 m3];

obj = m*eye(size(m,1))*m';
end
