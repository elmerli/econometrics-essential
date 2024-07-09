%*************************************************************************
% PS3
% Elmer Zongyang Li
%*************************************************************************

clear all; clc; 
cd '/Users/zongyangli/Dropbox/Academic 其他/GitHub/econometrics-essential/24 - Macro Finance'

%% Initialize parameters
rho_e = 0.06;    % Expert sector discount rate
rho_h = 0.04;    % Household sector discount rate
a_e = 0.11;      % Productivity of expert sector
a_h = 0.03;      % Productivity of household sector
delta = 0.05;    % Depreciation rate
phi = 10;        % Investment adjustment cost parameter
sigma = 0.1;     % Fundamental capital volatility


% Grid and initialization
N = 1000;
eta = linspace(0.0001, 0.9999, N);
q = zeros(1, N); % Price of capital
sigma_q = zeros(1, N); % Volatility of q
kappa = zeros(1, N); % Capital share
chi = zeros(1, N); % Capital share


%% Solve for variables
for i = 2:N
    % Initial values
    x0 = [q(i-1); kappa(i-1); sigma_q(i-1)]; % Guess for the variables
    q_last = (i>1)*q(i-1) + (i==1)*0;
    eta_val= eta(i); 
    
    % Solve using fsolve
    options = optimoptions('fsolve', 'Display', 'off'); % Turn off fsolve display
    [x_sol, fval, exitflag] = fsolve(@(x) PS3_sde(x, eta_val, a_e, a_h, rho_e, rho_h, phi, sigma, q_last), x0, options);

    % Store solutions
    q(i) = x_sol(1);
    kappa(i) = x_sol(2);
    sigma_q(i) = x_sol(3);
    iota(i) = (q(i) - 1)/phi;
    chi(i) = kappa(i);
    
    % Stop if kappa >= 1
    if kappa(i) >= 1
        [x_sol, fval, exitflag] = fsolve(@(x) PS3_sde_normal(x, eta_val, a_e, a_h, rho_e, rho_h, phi, sigma, q_last), x0, options);
        q(i) = x_sol(1);
        sigma_q(i) = x_sol(2);
        kappa(i) = 1;
        iota(i) = (q(i) - 1)/phi;
        chi(i) = max(kappa(i), eta(i));
    end
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

subplot(2,3,1);hold on
box on
plot(eta, q, LineWidth=1);
xlabel('$\eta$');
ylabel('$q$',FontSize=14)
% ylim([0.0,5.0])
legend('$q$',Location='northeast');
legend boxoff


subplot(2,3,2);hold on
box on
plot(eta, sigma_q, LineWidth=1);
xlabel('$\eta$');
ylabel('$\sigma_q$',FontSize=14)
% ylim([0.0,0.1])
legend('$\sigma_q$',Location='northeast');
legend boxoff


subplot(2,3,3);hold on
box on
plot(eta, kappa, LineWidth=1);
xlabel('$\eta$');
ylabel('$\kappa$',FontSize=14)
legend('$\kappa$',Location='northeast');
legend boxoff


subplot(2,3,4);hold on
box on
plot(eta, iota, LineWidth=1);
xlabel('$\eta$');
yline(0,LineStyle="--", LineWidth=1,Color='k');
% ylim([-0.02,0.1])
ylabel('$\iota$',FontSize=14)
legend('$\iota$',Location='northeast');
legend boxoff

exportgraphics(gcf,'PS3_elmer.pdf')


%% Compute eta's drift & var
%****************************% 

mu_eta = (1-eta).*( ((kappa-eta).^2).*(1-2*eta)./((eta.^2).*((1-eta).^2)).*((sigma+sigma_q).^2) - (rho_e-rho_h) ); 
sigma_eta = ((kappa-eta)./eta).*(sigma+sigma_q); 

f2=figure(1);
figSize = [10 6];
set(f2, 'PaperUnits', 'inches');
set(f2, 'Units','inches');
set(f2, 'PaperSize', figSize);
set(f2, 'PaperPositionMode', 'auto');
set(f2, 'Position', [0 0 figSize(1) figSize(2)])

subplot(2,2,1);hold on
box on
plot(eta, mu_eta, LineWidth=1);
xlabel('$\eta$');
ylabel('$\mu_{\eta}$',FontSize=14)
% ylim([0.0,5.0])
legend('$\mu_{\eta}$',Location='northeast');
legend boxoff


subplot(2,2,2);hold on
box on
plot(eta, sigma_eta, LineWidth=1);
xlabel('$\eta$');
ylabel('$\sigma_{\eta}$',FontSize=14)
% ylim([0.0,0.1])
legend('$\sigma_{\eta}$',Location='northeast');
legend boxoff

exportgraphics(gcf,'PS3_elmer2.pdf')

