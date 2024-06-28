%*************************************************************************
% PS1
% Elmer Zongyang Li
%*************************************************************************


clear;
clc;

%% Initialize parameters
rho_e = 0.02;    % Expert sector discount rate
rho_h = 0.05;    % Household sector discount rate
a_e = 1;         % Productivity of expert sector
% a_h = 0.02;      % Productivity of household sector
delta = 0.04;    % Depreciation rate
phi = 0.5;       % Investment adjustment cost parameter
ell = 0.5;       % Collateral constraint parameter

% The Steady States
kappa = (rho_h*phi + (1-ell)*(rho_e-rho_h))/(phi*(1-ell)*(rho_e-rho_h) + rho_h*phi+1);
eta_s = kappa * (1-ell);
q_s   = (a_e*kappa*phi + 1)/(rho_h*phi + 1); % only true for SS
iota_s = (q_s - 1) / phi;; % only true for SS



%% Solve for q binding
%-------------------------------------------%

eta_span = linspace(0.01,0.99,99);
kappa_span_case1 = eta_span /(1-ell);
kappa_span_case1(kappa_span_case1>=1) = 1; % short selling constraint on capital
q_span_case1 = ones('like',eta_span); % Extension -- steady state capital price in collateral constraint
iota_span_case1 = ones('like',eta_span); % Extension -- steady state capital price in collateral constraint

% solve q and iota
options = optimoptions('fsolve', 'Display', 'iter');
x0 = [q_s; iota_s]; % initial guess
for i = 1:99
    eta_t = eta_span(i);
    kappa_t = kappa_span_case1(i);
    x_sol = fsolve(@(x) eqm_q_iota(x, rho_e, rho_h, a_e, delta, phi, ell, eta_t, kappa_t), x0, options);
    q_span_case1(i) = x_sol(1);
    iota_span_case1(i) = x_sol(2);
end
mu_eta_geo_case1 = (1-eta_span).*(-(rho_e-rho_h) + ((1-kappa_span_case1)./q_span_case1).* kappa_span_case1./eta_span);


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
plot((eta_span),kappa_span_case1./eta_span,LineWidth=1);
% plot((eta_span),kappa_span_case2./eta_span,LineWidth=1);
xlabel('$\eta$');
ylabel('$\theta_t^{e,K}$',FontSize=14)
% ylim([0.0,5.0])
legend('$\theta_t^{e,K}$') % legend('$q_t$-constraint','$q^*$-constraint',Location='northeast')
legend boxoff


subplot(2,2,2);hold on
box on
plot((eta_span),(1-kappa_span_case1)./q_span_case1,LineWidth=1);
% plot((eta_span),(1-kappa_span_case2)./q_span_case2,LineWidth=1);
xlabel('$\eta$');
ylabel('$r_t^{K,e}-r_t^{K,h}$',FontSize=14)
% ylim([0.0,0.1])
legend('$r_t^{K,e}-r_t^{K,h}$'); % legend('$q_t$-constraint','$q^*$-constraint',Location='northeast')
legend boxoff


subplot(2,2,3);hold on
box on
plot((eta_span),q_span_case1,LineWidth=1);
% plot((eta_span),q_span_case2,LineWidth=1);
xlabel('$\eta$');
ylabel('$q_t$',FontSize=14)
legend('$q_t$'); % legend('$q_t$-constraint','$q^*$-constraint',Location='northeast')
legend boxoff


subplot(2,2,4);hold on
box on
plot(eta_span,mu_eta_geo_case1,LineWidth=1);
% plot(eta_span,mu_eta_geo_case2,LineWidth=1);
xlabel('$\eta$');
yline(0,LineStyle="--",LineWidth=1,Color='k');
% ylim([-0.02,0.1])
ylabel('$\mu^{\eta}_{t}$',FontSize=14)
legend('$\mu^{\eta}_{t}$'); % legend('$q_t$-constraint','$q^*$-constraint',Location='northeast')
legend boxoff


exportgraphics(gcf,'PS1_elmer.pdf')


