
% Macro PS 3
% Zongyang(Elmer) Li
% Content: 
	% Value function iteration (recursive formulation)

    
clear

%% Question 1
clear; 
%***************************
%* Parameters 

A = 1
alpha = 0.33
a = 0.33
beta = 0.98
sigma = 0.05

c_ss = 1.638 % steady state value
k_ss = 10.031 % steady state value
k_0 = 0.85*k_ss; % initialize k be 85% of the steady state value
tol = 0.1
T = 600
N = 10000

% indicate the range of shooting
c_lo = 0.2*c_ss;
c_hi = 1.15*c_ss;
k_lo = 0.2*k_ss;
k_hi = 1.15*k_ss;

ite = 1;
dist_ss = tol + 1; % initial value of distand

k_grid = k_lo : (k_hi - k_lo)/(N-1) : k_hi; 
c_grid = c_lo : (c_hi - c_lo)/(N-1) : c_hi; 

%***************************
%* Iteration

    % note that the iteration is based on the value of c
    % this is grid-by-grid search
while (dist_ss > tol && ite < length(c_grid));
% c(1) = (c_lo + c_hi)/2;
c(1) = c_grid(ite);
k(1) = k_0; 
    for t = 1:T-1;
        k(t+1) = A*k(t)^alpha + (1-sigma)*k(t) - c(t);
        c(t+1) = c(t)*(beta*alpha*A*k(t+1)^(alpha-1) + beta*(1-sigma))^(1/sigma);
        dist_ss = max(abs(k(t+1) - k_ss),abs(c(t+1) - c_ss));  
        if dist_ss < tol
           c = c(1:t+1); % save the path of c
           k = k(1:t+1); % save the path of k
           fprintf('job done \n'); 
            break 
        else
            continue 
        end
    end
ite = ite + 1;
end

%***************************
%* Compute locus
loci_k = A*k_grid.^alpha - sigma*k_grid;    % compute k loci
loci_c = k_grid.^alpha +(1-sigma)*k_grid-k_ss; % compute c loci


%***************************
%* Graph
u = gradient(k);    % k gradient of steady path
v = gradient(c); 
figure(1)
quiver(k,c,u,v,0)
axis([k_lo k_hi c_lo c_hi])
xlabel('k') % x-axis label
ylabel('c') % y-axis label
hold on
plot(k_grid, loci_k)
plot(k_grid, loci_c)
hold off

%% Question 2
clear; 
%***************************
%* Parameters 

A = 1
alpha = 0.33
a = 0.33
beta = 0.9
sigma = 0.05

c_ss = 1.638 % steady state value
k_ss = 10.031 % steady state value
k_0 = 0.85*k_ss; % initialize k be 85% of the steady state value
tol = 0.5
T = 600
N = 10000

% indicate the range of shooting
c_lo = 0.2*c_ss;
c_hi = 1.5*c_ss;
k_lo = 0.2*k_ss;
k_hi = 1.5*k_ss;

ite = 1;
dist_ss = tol + 1; % initial value of distand

k_grid = k_lo : (k_hi - k_lo)/(N-1) : k_hi; 
c_grid = c_lo : (c_hi - c_lo)/(N-1) : c_hi; 

%***************************
%* Iteration

    % note that the iteration is based on the value of c
    % this is grid-by-grid search
while (dist_ss > tol && ite < length(c_grid));
% c(1) = (c_lo + c_hi)/2;
c(1) = c_grid(ite);
k(1) = k_0; 
    for t = 1:T-1;
        k(t+1) = A*k(t)^alpha + (1-sigma)*k(t) - c(t);
        c(t+1) = c(t)*(beta*alpha*A*k(t+1)^(alpha-1) + beta*(1-sigma))^(1/sigma);
        dist_ss = max(abs(k(t+1) - k_ss),abs(c(t+1) - c_ss));  
        if dist_ss < tol
           c = c(1:t+1); % save the path of c
           k = k(1:t+1); % save the path of k
           fprintf('job done \n'); 
            break 
        else
            continue 
        end
    end
ite = ite + 1;
end

%***************************
%* Compute locus
loci_k = A*k_grid.^alpha - sigma*k_grid;    % compute k loci
loci_c = k_grid.^alpha +(1-sigma)*k_grid-k_ss; % compute c loci


%***************************
%* Graph
u = gradient(k);    % k gradient of steady path
v = gradient(c); 
figure(1)
quiver(k,c,u,v,0)
axis([k_lo k_hi c_lo c_hi])
xlabel('k') % x-axis label
ylabel('c') % y-axis label
hold on
plot(k_grid, loci_k)
plot(k_grid, loci_c)
hold off




