%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Program Name:   PS3 - Elmer Zongyang Li.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Question 2-3
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close all
clear
clc

set(groot,'defaultAxesTickLabelInterpreter','latex');
set(groot,'defaultLegendInterpreter','latex');
set(groot,'defaultTextInterpreter','latex');
%%
rho_e = 0.06;
rho_h = 0.04;
ell   = 0.5;

% The Steady States
kappa = 1/((1-ell) * (rho_e-rho_h)/rho_h+1);
eta_s = kappa * (1-ell);
q_s   = (2*kappa-kappa.^2)./(eta_s * (rho_e-rho_h)+rho_h);

%% Solve for the inner loop
options = optimoptions('fsolve','Display','none');
% x(1) is kappa, x(2) is q

eta_span = linspace(0.01,0.99,99);
kappa_span_case1 = ones('like',eta_span); % Original case
kappa_span_case2 = ones('like',eta_span); % Extension -- steady state capital price in collateral constraint

for i = 1:99
    eta_t = eta_span(i);
    F_obj = @(x) [(2 * x(1) - x(1).^2)./(eta_t * (rho_e-rho_h)+rho_h)-x(2);1-x(1)*(1-ell * q_s/x(2))./eta_t];
    x0    = [eta_t/(1-ell);20];
    x_sol = fsolve(F_obj,x0,options);
    kappa_span_case2(i) = x_sol(1);
end

kappa_span_case1 = eta_span /(1-ell);
% impose the short selling constraint on capital
kappa_span_case1(kappa_span_case1>=1) = 1;
kappa_span_case2(kappa_span_case2>=1) = 1;

q_span_case1 = (2*kappa_span_case1-kappa_span_case1.^2)./(eta_span * (rho_e-rho_h)+rho_h);
q_span_case2 = (2*kappa_span_case2-kappa_span_case2.^2)./(eta_span * (rho_e-rho_h)+rho_h);
mu_eta_geo_case1 = (1-eta_span).*(-(rho_e-rho_h) + ((1-kappa_span_case1)./q_span_case1).* kappa_span_case1./eta_span);
mu_eta_geo_case2 = (1-eta_span).*(-(rho_e-rho_h) + ((1-kappa_span_case2)./q_span_case2).* kappa_span_case2./eta_span);

%% Plot the solution
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
plot((eta_span),kappa_span_case2./eta_span,LineWidth=1);
xlabel('$\eta$');
ylabel('$\theta_t^{e,K}$',FontSize=14)
ylim([0.0,5.0])

legend('$q_t$-constraint','$q^*$-constraint',Location='northeast')
legend boxoff

subplot(2,2,2);hold on
box on
plot((eta_span),(1-kappa_span_case1)./q_span_case1,LineWidth=1);
plot((eta_span),(1-kappa_span_case2)./q_span_case2,LineWidth=1);
xlabel('$\eta$');
ylabel('$r_t^{K,e}-r_t^{K,h}$',FontSize=14)
ylim([0.0,0.1])

legend('$q_t$-constraint','$q^*$-constraint',Location='northeast')
legend boxoff

subplot(2,2,3);hold on
box on
plot((eta_span),q_span_case1,LineWidth=1);
plot((eta_span),q_span_case2,LineWidth=1);
xlabel('$\eta$');

ylabel('$q_t$',FontSize=14)
legend('$q_t$-constraint','$q^*$-constraint',Location='northeast')
legend boxoff

subplot(2,2,4);hold on
box on
plot(eta_span,mu_eta_geo_case1,LineWidth=1);
plot(eta_span,mu_eta_geo_case2,LineWidth=1);
xlabel('$\eta$');
yline(0,LineStyle="--",LineWidth=1,Color='k');
ylim([-0.02,0.1])

ylabel('$\mu^{\eta}_{t}$',FontSize=14)
legend('$q_t$-constraint','$q^*$-constraint',Location='northeast')
legend boxoff
exportgraphics(gcf,'lec31_KMdynamics_mu_eta_extension.pdf')






