clc
clear;

diary DMP_partial.txt


% define globals
global alf sigm bet rr sep yrho ysig vfSS jfSS thetaSS ygrid yPP ynn ...
  giter burnin nsim zsims

% start from same place
rng('default')

% Assign parameter values
alf  = 0.5; % Not shimer
sigm = 0.139; % HM equal to job finding rate
bet  = 0.99^(1/13); % HM
rr   = (1/bet)-1;
sep  = 0.0081; % HM
yrho = 0.9895; % HM
ysig = 0.0034; % HM
ynn  = 15;
giter = 0;
burnin = 13*10^3;
nsim = 13*10^4;

% steady state
thetaSS = 1.0;
vfSS    = GetVF(thetaSS);
jfSS    = GetJF(thetaSS);

% labor productivity
[ygrid yPP] = rouwen(yrho,ysig,ynn);
ygrid       = exp(ygrid)';

% Use same z draw for each simulation
yinit = ceil(ynn/2);
zsims = ddpsimul(yPP,yinit,burnin+nsim,0);
zsims = zsims(2:end);

tic

%% Fist caliberation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

bb1   = 0.7;
gam1  = 0.5;

% Get theta and cc
[theta1, cc1, err1] = GetTheta(bb1, gam1);

% Simulate: input theta
[stats1]  = GetStats(theta1,bb1,gam1,cc1);
time1 = toc;

fprintf('\n')
fprintf('First calibration \n')
fprintf('\n')
fprintf('Time to solve and simulate: %9.4f seconds \n', time1);
fprintf('\n')
fprintf('Wage elasticity: %.4f \n', stats1.elast)
fprintf('Wage share: %.4f \n', stats1.wshare)
fprintf('\n')
fprintf('Standard deviations of u, v, theta, y \n')
fprintf('%6.4f  %6.4f  %6.4f  %6.4f \n', [stats1.sigu, stats1.sigv stats1.sigt, stats1.sigy])
fprintf('\n')
fprintf('Autocorrelations of u, v, theta, y \n')
fprintf('%6.4f  %6.4f  %6.4f  %6.4f \n', [stats1.rhou, stats1.rhov stats1.rhot, stats1.rhoy])
fprintf('\n')
fprintf('Correlation matrix \n')
for row=1:4
  fprintf('%6.4f  %6.4f  %6.4f  %6.4f \n', stats1.corrmat(row,1:4))
end
fprintf('\n')
fprintf('\n')
fprintf('------------------------------------')
fprintf('\n')


% Second Calibration
bb2   = 0.955;
bb2   = 0.940;
gam2  = 0.05;

tic
% Get theta and cc
[theta2, cc2, err2] = GetTheta(bb2, gam2);

% Simulate: input theta
[stats2]  = GetStats(theta2,bb2,gam2,cc2);
time2 = toc;
fprintf('\n')
fprintf('Second calibration \n')
fprintf('\n')
fprintf('Time to solve and simulate: %9.4f seconds \n', time2);
fprintf('\n')
fprintf('Wage elasticity: %.4f \n', stats2.elast)
fprintf('Wage share: %.5f \n', stats2.wshare)
fprintf('\n')
fprintf('Standard deviations of u, v, theta, y \n')
fprintf('%6.4f  %6.4f  %6.4f  %6.4f \n', [stats2.sigu, stats2.sigv stats2.sigt, stats2.sigy])
fprintf('\n')
fprintf('Autocorrelations of u, v, theta, y \n')
fprintf('%6.4f  %6.4f  %6.4f  %6.4f \n', [stats2.rhou, stats2.rhov stats2.rhot, stats2.rhoy])
fprintf('\n')
fprintf('Correlation matrix \n')
for row=1:4
  fprintf('%6.4f  %6.4f  %6.4f  %6.4f \n', stats2.corrmat(row,1:4))
end
fprintf('\n')
fprintf('\n')
fprintf('------------------------------------')


diary off
