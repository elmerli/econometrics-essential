%% Question 1 and 2 
tol = .001; % tolerance
N = 100000; % grid size
T = 600;    % time periods

alpha = 0.33;   % labor share
delta = 0.05;   % depreciation of capital
sigma = 0.8;    % CRRA
beta = .98;     % discount factor
A = 1;          % technology

k = zeros(1,T+1);   % initial k path vector
c = zeros(1,T+1);   % initial c path vector

kstar = ((alpha*beta*A)/(1-beta+beta*delta))^(1/(1-alpha)); % k steady state 
cstar =  A*kstar^alpha+(1-delta)*kstar-kstar;   % c steady state 

k0 = 0.85*kstar; % starting k value

lb_k = 0.85*kstar;   % lower bound of k axis
ub_k = 1.35*kstar;   % upper bound of k axis

lb_c = 0.85*cstar;   % lower bound of c axis
ub_c = 1.15*cstar;   % lower bound of c axis

axis_k = lb_k : (ub_k-lb_k)/(N-1) : ub_k;   % k axis
axis_c = lb_c : (ub_c-lb_c)/(N-1) : ub_c;   % c axis

diff_ss = 1;   % initialize tolerance criteria
ite = 1;    % initialize iteration

while (diff_ss>tol && ite<=length(axis_c))
    k(1) = k0;  % set starting k0
    c(1) = axis_c(ite); % pick c0
    for t = 1:T
        k(t+1) = A*k(t)^alpha+(1-delta)*k(t)-c(t); % compute k(t+1)
        c(t+1) = c(t)*(beta*alpha*A*k(t+1)^(alpha-1)+beta*(1-delta))^(1/sigma); %compute c(t+1)
        diff_ss = max(abs(kstar-k(t+1)),abs(cstar-c(t+1)));    % deviation from steady state
        if diff_ss<=tol
            % if close to steady state stop algorithm
            k = k(1:t+1); % cut path after convergences
            c = c(1:t+1); % cut path after convergences
            break
        else
            continue
        end
    end
    ite = ite + 1;  % update iteration
end

u = gradient(k);    % compute k gradient of steady path
v = gradient(c);    % compute c gradient of steady path

loci_k = A*axis_k.^alpha - delta*axis_k;    % compute k loci
loci_c = axis_k.^alpha +(1-delta)*axis_k-kstar; % compute c loci

[K,C]= meshgrid(lb_k : (ub_k-lb_k)/(10-1) : ub_k,lb_c : (ub_c-lb_c)/(10-1) : ub_c);  % create (k,c) grid

% plot steady path, phase diagram, and locus
figure(1)
quiver(k,c,u,v,0)
axis([lb_k ub_k lb_c ub_c])
xlabel('k') % x-axis label
ylabel('c') % y-axis label
hold on
plot(axis_k,loci_k)
plot(axis_k,loci_c)
legend('Transition Path', 'K Locus','C Locus')
hold off
print -depsc fig1.eps

fprintf('Question 1 \nStarting - K : %f \nSteady state - K : %f \nSteady state - C : %f \nConvergence time : %d.\n\n',k0,kstar,cstar,t);

kstar_old = kstar;  % store original k steady state
cstar_old = cstar;  % store original c steady state
k_old = k;  % store transition path for k
c_old = c;  % store transition path for c
u_old = u;  % store transition path for k
v_old = v;  % store transition path for c

%% Question 3
tol = .001; % tolerance
N = 100000; % grid size
T = 600;    % time periods

alpha = 0.33;   % labor share
delta = 0.05;   % depreciation of capital
sigma = 0.8;    % CRRA
beta = .95;     % discount factor - more impatient agents, lower B value 
A = 1;          % technology

k = zeros(1,T+1);   % initial k path vector
c = zeros(1,T+1);   % initial c path vector

kstar = ((alpha*beta*A)/(1-beta+beta*delta))^(1/(1-alpha)); % k steady state 
cstar =  A*kstar^alpha+(1-delta)*kstar-kstar;   % c steady state 

k0 = 0.85*kstar; % starting k value

lb_k = 0.85*kstar;   % lower bound of k axis
ub_k = 1.35*kstar;   % upper bound of k axis

lb_c = 0.85*cstar;   % lower bound of c axis
ub_c = 1.15*cstar;   % lower bound of c axis

axis_k = lb_k : (ub_k-lb_k)/(N-1) : ub_k;   % k axis
axis_c = lb_c : (ub_c-lb_c)/(N-1) : ub_c;   % c axis

diff_ss = 1;   % initialize tolerance criteria
ite = 1;    % initialize iteration

while (diff_ss>tol && ite<=length(axis_c))
    k(1) = k0;  % set starting k0
    c(1) = axis_c(ite); % pick c0
    for t = 1:T
        k(t+1) = A*k(t)^alpha+(1-delta)*k(t)-c(t); % compute k(t+1)
        c(t+1) = c(t)*(beta*alpha*A*k(t+1)^(alpha-1)+beta*(1-delta))^(1/sigma); %compute c(t+1)
        diff_ss = max(abs(kstar-k(t+1)),abs(cstar-c(t+1)));    % deviation from steady state
        if diff_ss<=tol
            % if close to steady state stop algorithm
            k = k(1:t+1); % cut path after convergences
            c = c(1:t+1); % cut path after convergences
            break
        else
            continue
        end
    end
    ite = ite + 1;  % update iteration
end

u = gradient(k);    % compute k gradient of steady path
v = gradient(c);    % compute c gradient of steady path

loci_k = A*axis_k.^alpha - delta*axis_k;    % compute k loci
loci_c = axis_k.^alpha +(1-delta)*axis_k-kstar; % compute c loci

[K,C]= meshgrid(lb_k : (ub_k-lb_k)/(10-1) : ub_k,lb_c : (ub_c-lb_c)/(10-1) : ub_c);  % create (k,c) grid

% plot steady path, phase diagram, and locus
figure(1)
quiver(k,c,u,v,0)
axis([lb_k ub_k lb_c ub_c])
xlabel('k') % x-axis label
ylabel('c') % y-axis label
hold on
plot(axis_k,loci_k)
plot(axis_k,loci_c)
legend('Transition Path', 'K Locus','C Locus')
hold off
print -depsc fig2.eps

fprintf('Question 3 \nStarting - K : %f \nSteady state - K : %f \nSteady state - C : %f \nConvergence time : %d.\n\n',k0,kstar,cstar,t);

kstar_old = kstar;  % store original k steady state
cstar_old = cstar;  % store original c steady state
k_old = k;  % store transition path for k
c_old = c;  % store transition path for c
u_old = u;  % store transition path for k
v_old = v;  % store transition path for c


%% Question 4
tol = .001; % tolerance
N = 100000; % grid size
T = 600;    % time periods

alpha = 0.33;   % labor share
delta = 0.05;   % depreciation of capital
sigma = 0.8;    % CRRA
beta = .95;     % discount factor - more impatient agents, lower B value 
A = 1.01;          % technology

k = zeros(1,T+1);   % initial k path vector
c = zeros(1,T+1);   % initial c path vector

kstar = ((alpha*beta*A)/(1-beta+beta*delta))^(1/(1-alpha)); % k steady state 
cstar =  A*kstar^alpha+(1-delta)*kstar-kstar;   % c steady state 

k0 = 0.85*kstar; % starting k value

lb_k = 0.85*kstar;   % lower bound of k axis
ub_k = 1.35*kstar;   % upper bound of k axis

lb_c = 0.85*cstar;   % lower bound of c axis
ub_c = 1.15*cstar;   % lower bound of c axis

axis_k = lb_k : (ub_k-lb_k)/(N-1) : ub_k;   % k axis
axis_c = lb_c : (ub_c-lb_c)/(N-1) : ub_c;   % c axis

diff_ss = 1;   % initialize tolerance criteria
ite = 1;    % initialize iteration

while (diff_ss>tol && ite<=length(axis_c))
    k(1) = k0;  % set starting k0
    c(1) = axis_c(ite); % pick c0
    for t = 1:T
        k(t+1) = A*k(t)^alpha+(1-delta)*k(t)-c(t); % compute k(t+1)
        c(t+1) = c(t)*(beta*alpha*A*k(t+1)^(alpha-1)+beta*(1-delta))^(1/sigma); %compute c(t+1)
        diff_ss = max(abs(kstar-k(t+1)),abs(cstar-c(t+1)));    % deviation from steady state
        if diff_ss<=tol
            % if close to steady state stop algorithm
            k = k(1:t+1); % cut path after convergences
            c = c(1:t+1); % cut path after convergences
            break
        else
            continue
        end
    end
    ite = ite + 1;  % update iteration
end

u = gradient(k);    % compute k gradient of steady path
v = gradient(c);    % compute c gradient of steady path

loci_k = A*axis_k.^alpha - delta*axis_k;    % compute k loci
loci_c = axis_k.^alpha +(1-delta)*axis_k-kstar; % compute c loci

[K,C]= meshgrid(lb_k : (ub_k-lb_k)/(10-1) : ub_k,lb_c : (ub_c-lb_c)/(10-1) : ub_c);  % create (k,c) grid

% plot steady path, phase diagram, and locus
figure(1)
quiver(k,c,u,v,0)
axis([lb_k ub_k lb_c ub_c])
xlabel('k') % x-axis label
ylabel('c') % y-axis label
hold on
plot(axis_k,loci_k)
plot(axis_k,loci_c)
legend('Transition Path', 'K Locus','C Locus')
hold off
print -depsc fig3.eps

fprintf('Question 4 \nStarting - K : %f \nSteady state - K : %f \nSteady state - C : %f \nConvergence time : %d.\n\n',k0,kstar,cstar,t);

kstar_old = kstar;  % store original k steady state
cstar_old = cstar;  % store original c steady state
k_old = k;  % store transition path for k
c_old = c;  % store transition path for c
u_old = u;  % store transition path for k
v_old = v;  % store transition path for c


%%Question 5 

%%Question 6
