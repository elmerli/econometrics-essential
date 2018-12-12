%% Value Function Iteration
clear, clc;

%% Set parameters
nk = 500;	% Size of grid
ns = 7;
dev = 3;

delta = 0.1;	% Depreciation rate
alpha = 0.3;    % Capital share of income
beta = 0.96;     % Discount factor
rho = 0.96;     % Discount factor

phi = 0.98; % AR coefficient
sig_y = sqrt(.1); % Standard deviation of y_t







%% Markov (Tauchen)

N = 10000;  % Number of simulation

sample = ones(N,3); % Initialize mean, std, autocorr. placeholder

[prob, state_grid] = tauchen(ns, phi, sig_y ,dev); % Transition matrix
for i = 1:N 
chain = markovchain(prob, 1000, 4); % Generate Markov chain
chain = state_grid(chain); % Map markov chain to state values

acf = autocorr(chain,1); % Compute autocorrelation

sample(i,:) = [mean(chain),std(chain), acf(2)]; % Store values
end

mean(sample) % Compute average of mean, std, autocorr.


%% Value function
k_max = 5;	% Upper bound
k_min = 1;	% Lower bound
k_grid = linspace(k_min,k_max,nk)';	% Create grid

% Compute value/policy function
[val_fun, pol_fun] = bellman( k_grid, state_grid, alpha, beta, delta, prob);





%% Data
url = 'https://fred.stlouisfed.org/';
c = fred(url);

GDP = fetch(c,'GDPC1'); % Fetch GDP from FRED
CON = fetch(c,'PCECC96');   % Fetch consumption from FRED
INV = fetch(c,'GPDIC1');    % Fetch investment from FRED

gdp_data = log(GDP.Data(:,2));  % Log of GDP
c_data = log(CON.Data(:,2));    % Log of consumption
i_data = log(INV.Data(:,2));    % Log of investment

[~,gdp_data] = hpfilter(gdp_data,1600); % Extract cyclical component of GDP
[~,i_data] = hpfilter(i_data,1600); % Extract cyclical component of C
[~,c_data] = hpfilter(c_data,1600); % Extract cyclical component of I






%% Simulation
T = size(c_data,1)+1;   % Set size of Markov Chain to match data

y_sim = markovchain(prob, T, 4);    % Generate Markov chain

k_sim = ones(T,1);  % Initialize capital vector
k_sim(1) = round(nk/2); % Set starting value to the middle of grid

for t = 2:T
    k_sim(t)= pol_fun(k_sim(t-1),y_sim(t-1));   % Compute k' from k
end

y_sim = state_grid(y_sim); % Map markov chain to state values
k_sim = k_grid(k_sim);  % Map markov chain to capital values

gdp_sim = exp(y_sim).* k_sim.^alpha;    % Compute GDP
gdp_sim = gdp_sim(1:end-1); % Drop last value

i_sim= k_sim(2:end) -(1-delta)*k_sim(1:end-1);  % Compute investment

c_sim = gdp_sim - i_sim;    % Compute consumption

c_sim = log(c_sim); % Log of c
i_sim = log(i_sim); % Log of i
gdp_sim = log(gdp_sim); % Log of GDP

c_sim = c_sim-mean(c_sim);  % Detrend c
i_sim = i_sim- mean(i_sim); % Detrend i
gdp_sim = gdp_sim - mean(gdp_sim);  % Detrend GDP

std_sim = std([c_sim,gdp_sim,i_sim]) % Compute standard value of simulation
std_data = std([c_data,gdp_data,i_data]) % Compute standard value of data
corr(c_sim,c_data)  % Compute the correlation for consumption
corr(gdp_sim,gdp_data)  % Compute the correlation for GDP
corr(i_sim,i_data)  % Compute the correlation for investment






%% Plot figures
% Value function
figure
plot(k_grid,val_fun) 

xlabel('k')
ylabel('v(k)')
legend('-3\sigma','-2\sigma','-1\sigma','Policy function','+1\sigma','+2\sigma','+3\sigma', 'Location', 'best')

print('plot_value','-dpng')

% Policy function
figure
plot(k_grid,k_grid(pol_fun))
axis equal
hold on
plot(k_grid,k_grid, '--b')

xlabel('k')
ylabel('g(k)')
legend('-3\sigma','-2\sigma','-1\sigma','Policy function','+1\sigma','+2\sigma','+3\sigma','45 degree', 'Location', 'best')

print('plot_policy','-dpng')

% Markov
figure
subplot(1,3,1); histogram(sample(:,1)); title('Mean');
subplot(1,3,2); histogram(sample(:,2)); title('Standard Deviation');
subplot(1,3,3); histogram(sample(:,3)); title('Autocorrelation');

print('plot_markov','-dpng')

% Simulation
figure
plot(GDP.Data(:,1),[c_sim,gdp_sim,i_sim])
hold on
plot(GDP.Data(:,1),[c_data,gdp_data,i_data], '--')

datetick('x')
legend('C - Simulation', 'GDP - Simulation','I - Simulation','C - Data','GDP - Data','I - Data', 'Location', 'best')
print('plot_sim','-dpng')



%%
function [prob, state_grid] = tauchen(ns, phi, sig_y ,dev)
%markovchain Discretize AR(1) process
%   [prob, cum_prob, state_grid] = tauchen(ns, phi, sig_y ,dev) returns
%   prob, transition matrix,
%   cum_prob, cummulative distribution
%   state_grid, value of states

state_grid = linspace(-dev*sig_y,dev*sig_y,ns)';    % Set state grid
d = mean(diff(state_grid));
% Compute y^j_t+1 - rho y^i_t
state_change = repmat(state_grid,1,ns)'  - phi*repmat(state_grid,1,ns);

sig_eps = sig_y*sqrt(1-phi^2);
prob = zeros(ns,ns);    % Initialize transition matrix
% Compute transition matrix according to Tauchen (1986)
prob(:,1) = cdf('norm',state_change(:,1)+d/2,0,sig_eps);
prob(:,end) = 1- cdf('norm',state_change(:,end) - d/2,0,sig_eps);
prob(:,2:end-1) = cdf('norm',state_change(:,2:end-1)+d/2,0,sig_eps)-cdf('norm',state_change(:,2:end-1)-d/2,0,sig_eps);

end







function [val_fun, pol_fun] = bellman( k_grid, state_grid, alpha, beta, delta, prob)
% bellman Value Function Iteration with log utility
%   [val_fun, pol_fun] = bellman( k_grid, state_grid, alpha, beta, delta, prob) returns 
%   val_fun, value function and pol_fun, policy function

crit = 1;	% Initialize convergence criterion
tol = 1e-6;	% Convergence tolerance

%% Grid
nk = size(k_grid,1);
ns = size(state_grid,1);
% Create grid

% Empty
val_temp = zeros(nk,ns);  % Initialize temporary value function vector
val_fun = zeros(nk,ns);	% Initialize value function vector
pol_fun = zeros(nk,ns);	% Initialize policy function vector


%% Value function iteration
while crit>tol ;
    % Iterate on k
    for j = 1:ns
    for i=1:nk   
        c = exp(state_grid(j))* k_grid(i)^alpha + (1-delta)*k_grid(i) - k_grid; % Compute consumption for kt
        utility_c = log(c); % Compute utility for every ct
        utility_c(c<=0) = -Inf;	% Set utility to -Inf for c<=0
        [val_fun(i,j),pol_fun(i,j)] = max(utility_c + beta* val_temp*prob(j,:)');   % Solve Bellman equation
    end
    end
    crit = max(abs(val_fun-val_temp));  % Compute convergence criterion
    val_temp = val_fun;	% Update value function
end

end



function [chain] = markovchain(prob, T, start)
%markovchain Generate Markov chain
%   [chain] = markovchain(prob, T, start) returns chain, Markov chain.

chain = ones(T,1);  % Initialize Markov Chain
chain(1)= start;    % Set starting value

cum_prob = cumsum(prob,2);  % Compute cumulative distribution

% Generate Markov Chain using random numbers uniformly distributed
for t = 2:T
    chain(t)=find(cum_prob(chain(t-1),:)>rand(),1);
end

end


function [Gl, TM, CDF, sz] = markovprob(mue, p, s, N, m)
% markovprob - function
%% Arguments:
% mue = intercept of AR(1) process;
% p = slope coeff. of AR(1) process;
% s = std. dev. of residuals in AR(1) process;
% N = # of grid points for the ‘z’ variable;
% m = Density of the grid for ‘z’ variable;
%% CODE:
sz = s / ((1-p^2)^(1/2)); % Std. Dev. of z.
zmin = -m * sz + mue/(1-p);
zmax = m * sz + mue/(1-p);
z = linspace(zmin,zmax,N); % Grid Points
%% Transition Matrix:
TM = zeros(N,N); % Transition Matrix
w = z(N) - z(N-1);
for j = 1:N;
TM(j,1) = cdf('norm',(z(1)+w/2-mue-p*z(j))/s,0,1);
TM(j,N) = 1 - cdf('norm',(z(N)-w/2-mue-p*z(j))/s,0,1);
for k = 2:N-1;
TM(j,k) = cdf('norm',(z(k)+w/2-mue-p*z(j))/s,0,1)-cdf('norm',(z(k)-w/2-mue-p*z(j))/s,0,1);
end
end
%% Cumulative Distribution Function:
CDF = cumsum(TM,2);
%% Invariant Distribution:
%% Grids:
Gl = exp(z');
fprintf('If we have a lognormal var. (log(z)) in AR(1) process, \n');
fprintf('To make the interval finer at the lower end and coarser at the upper end.\n');

end 

