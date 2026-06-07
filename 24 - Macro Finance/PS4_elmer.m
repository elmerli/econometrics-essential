%*************************************************************************
% PS4
% Elmer Zongyang Li
%*************************************************************************

clear all; clc; 
cd '/Users/zongyangli/Dropbox/Academic 其他/GitHub/econometrics-essential/24 - Macro Finance'

%% Initialize parameters
a = 0.2;
phi = 1;
rho = 0.01;
delta = 0.05;
sigma_ss = 0.2;
b = 0.05;
nu = 0.02;
alpha = 2 * b * sigma_ss / nu^2;
beta = 2 * b / nu^2;
sigma_grid = linspace(0, 2 * sigma_ss, 1000); % up to 3 times the steady-state

M = build_M(sigma_grid', (b*(sigma_ss-sigma_grid))', (nu * sqrt(sigma_grid))');


%% Solve for variables



delta_t = 0.01;
iter = 2; 
% max_iter = 1000;
max_iter = length(sigma_grid);
tol = 1e-16;

% Initial guess for v
% v = ones(length(sigma_grid), 1);

v = sigma_grid(2);

% Value function iteration
while (iter <= max_iter) && (diff_v > tol);
    v_new = ((1 + rho * delta_t) * eye(length(sigma_grid)) - delta_t * M) \ (delta_t * build_u(v, M, rho) + v);
    diff_v = sum(sum(abs(v_new - v))); 
    iter = iter + 1; 
    v = sigma_grid(iter);
    display(['iteration', num2str(iter),' Error function: ', num2str(diff_v)])
end



%% Plot results
%****************************% 

set(groot,'defaultAxesTickLabelInterpreter','latex');
set(groot,'defaultLegendInterpreter','latex');
set(groot,'defaultTextInterpreter','latex');

f=figure(1);
figSize = [10 6];
set(f, 'PaperUnits', 'inches');
set(f, 'Units','inches');
set(f, 'PaperSize', figSize);
set(f, 'PaperPositionMode', 'auto');
set(f, 'Position', [0 0 figSize(1) figSize(2)])

subplot(2,2,1);hold on
box on
plot(eta, q, LineWidth=1);
xlabel('$\eta$');
ylabel('$q$',FontSize=14)
% ylim([0.0,5.0])
legend('$q$',Location='northwest');
legend boxoff


subplot(2,2,2);hold on
box on
plot(eta, sigma_q, LineWidth=1);
xlabel('$\eta$');
ylabel('$\sigma_q$',FontSize=14)
% ylim([0.0,0.1])
legend('$\sigma_q$',Location='northwest');
legend boxoff


subplot(2,2,3);hold on
box on
plot(eta, kappa, LineWidth=1);
xlabel('$\eta$');
ylabel('$\kappa$',FontSize=14)
legend('$\kappa$',Location='northwest');
legend boxoff


subplot(2,2,4);hold on
box on
plot(eta, iota, LineWidth=1);
xlabel('$\eta$');
yline(0,LineStyle="--", LineWidth=1,Color='k');
% ylim([-0.02,0.1])
ylabel('$\iota$',FontSize=14)
legend('$\iota$',Location='northwest');
legend boxoff

exportgraphics(gcf,'PS3_elmer.pdf')

