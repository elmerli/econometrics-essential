
% Macro PS 3
% Zongyang(Elmer) Li
% Content: 
	% Value function iteration (recursive formulation)

    
clear

%% Iteration Parameters
del_t = 1
A = 1
alpha = 0.33
a = 0.33
beta = 0.98
sigma = 0.05

c_ss = 1.638
k_ss = 10.031
k(1) = 0.85*k_ss % initialize k be 85% of the steady state value
tol = 0.5 
T = 20
I = 600 

c_lo = 0;
c_hi = A*k(1)^alpha;
i = 0;
dist_k = tol + 1;
dist_c = tol + 1;


while (i < I) & (dist_k > tol | dist_c > tol);
c(1) = (c_lo + c_hi)/2;
    for t = 1:T-1;
        k(t+1) = del_t*(A*k(t)^alpha - (1-sigma)*k(t) - c(t)) + k(t);
        c(t+1) = del_t*beta*c(t)*(alpha*A*k(t)^(alpha-1) + (1-sigma)) + c(t);
        if c(t+1) > A*k(t+1)^alpha
           c(t+1) = A*k(t+1)^alpha;
        elseif c(t+1) < 0 
               c(t+1) = 0;
        end
    end
    if k(T) > k_ss & c(T) < c_ss
        c_lo = c(1);
        elseif k(T) < k_ss & c(T) < c_ss
        c_hi = c(1);
        elseif k(T) < k_ss & c(T) > c_ss
        c_hi = c(1);
    end
dist_k = abs(k(T) - k(T-1));
dist_c = abs(c(T) - c(T-1));
i = i + 1;
end




%% Value function parameters
alpha = 0.3; 
beta=0.6;
sigma = 0.75; 
K=0.001:0.001:0.2;            % grid over captial stock
[rk,dimK]=size(K); % measure the dimension of grid
val_temp=ones(dimK,1); % initialize the value function matrix
pol_fun=ones(dimK,1); % Initialize policy function vector

%% Iteration Parameter
threshold= 10^(-6); % Tolerance level in the loop
error=1; 
iter=0;     % displays iteration number



while error > threshold    % iteration of the Bellman equation
   aux=-inf*ones(dimK); % matrix of all possible values of consumption; initialize this to negative inf (with no consumption, log unitility = neg inf)
   for ik=1:dimK           % loop over all state variable K
       for ik2=1:dimK   % loop over all control variable K'
           aux(ik,ik2)=log( K(ik)^alpha + (1-sigma)*K(ik) - K(ik2) ) + beta*val_temp(ik2);
       end
       [val_fun,pol_fun]=max(aux,[],2);
   end  % Note: these two loops do not fill in entirely the aux matrix
        % The size of cake next period has to be lower than the current one.
   error = max(abs(val_fun-val_temp)); % Calculate error
   val_temp = val_fun;  % Update value function
   % val_temp(:,iter+1)=max(aux,[],2);  % take the max value over vij ignoring the missing values
   iter = iter + 1; 

end


%% Plot Graph
% optimal consumption
figure(1)
plot(K,val_temp);
xlabel('State Variable K');
ylabel('Value Function');

% plot optimal consumption rule as a function of cake size
figure(2)
% plot(K,[optC K'],'LineWidth',2)        % plot graph
plot(K,K(pol_fun),'LineWidth',2)        % plot graph
xlabel('State Variable K');
ylabel('Policy Function');
text(0.4,0.65,'45 deg. line','FontSize',18)   % add text to the graph
text(0.4,0.13,'Optimal Consumption','FontSize',18)



