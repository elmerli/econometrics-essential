clear;
clc;

addpath('/Users/zongyangli/Documents/MATLAB/SupportPackages/compecon2011/CEtools')

global beta r ro se gamma yPP ygrid
% note: using globals is bad practice! use structures instead


% declare parameters

beta=0.90;
r=0.92/beta-1; % in bewlly model, this is how r is calculated
ro=0.70; % the coefficient of AR(1) process
se=0.1;
gamma=2;
k=11;  % nodes for the distribution of income shocks; the numbr of pints want to find out

% output: transition dynamics, specific pints (of income, asset process)
% two state space (income, asset), kartesian product
[e,w]=rouwenhorst(ro,se,k); % Rouwenhorst method
yPP=w;
ygrid=e';

% Bounds for state space 
ymin=min(e);
ymax=max(e);

amin = 0;                        % no borrowing
amax = 10*exp(ymax);             % guess an upper bound on a, check later that do not exceed it


% Declare function space to approximate a'(a,y)

n=[25,k]; % numbr of nodes in the state space
% now uniform grid, when we calculate, may not app policy function -- spline
% if not converging, spline, more dense 

% Lower and higher bound for the state space (a,y)
smin=[amin,ymin];
smax=[amax,ymax];

scale=1/2;
fspace=fundef({'spli',  nodeunif(n(1),(smin(1)-amin+.01).^scale,(smax(1)-amin+.01).^scale).^(1/scale)+amin-.01,0,3},...
              {'spli',ygrid,0,1});           
           
grid=funnode(fspace);
s=gridmake(grid); %collection of  states (all a with y1... all a with y2... and so on)
ns=length(s);

c=funfitxy(fspace,s,r/(1+r)*s(:,1)+exp(s(:,2)));    %guess that keep constant assets; evalulate the optimal consumption; initial guess, keep updating


tic
for it=1:101
cnew=c;
solve;      
c=funfitxy(fspace,s,x);

fprintf('%4i %6.2e\n',[it,norm(c-cnew)]);
if norm(c-cnew)<1e-7, break, end
end
toc
pause


%% Plot 
sfine=gridmake(nodeunif(n(1)*2,smin(1),smax(1)),ygrid);
xfine=funeval(c,fspace,sfine);
disp('mean and max errors')
disp(mean(abs(euler(xfine,c,fspace,sfine,e,w).*((1+r)*sfine(:,1)+exp(sfine(:,2))-xfine>amin+.01))))
disp(max(abs(euler(xfine,c,fspace,sfine,e,w).*((1+r)*sfine(:,1)+exp(sfine(:,2))-xfine>amin+.01))))

set(gca,'fontsize',8)
close all
figure(1)
subplot(2,1,1)
sfine=gridmake(nodeunif(n(1)*4,smin(1),smax(1)),0); %ygrid(floor(k/2)+2));
xfine=funeval(c,fspace,sfine);
plot(sfine(:,1),xfine)
xlabel({'$a$'},'Interpreter','latex')
ylabel({'$x(a,\bar{y})$'},'Interpreter','latex')
title({'Consumption policy function, $y=\bar{y}$'},'Interpreter','latex')
set(gca,'FontSize',8);

subplot(2,1,2)
sfine=gridmake(0,nodeunif(n(2)*4,smin(2),smax(2)));
xfine=funeval(c,fspace,sfine);
plot(exp(sfine(:,2)),xfine)
xlabel('$e^{y}$','Interpreter','latex')
ylabel('$x(0,y)$','Interpreter','latex')
title({'Consumption policy function, $a=0$'},'Interpreter','latex')
set(gca,'FontSize',8);

figure(2)
subplot(2,1,1)
sfine=gridmake(nodeunif(n(1)*4,smin(1),smax(1)),0);
xfine=funeval(c,fspace,sfine);
plot(sfine(:,1),(1+r)*sfine(:,1)+exp(sfine(:,2))-xfine)
xlabel('$a$','Interpreter','latex')
ylabel('$a^{\prime}(a,\bar{y})$','Interpreter','latex')
title({'Savings policy function, $y=\bar{y}$'},'Interpreter','latex')
set(gca,'FontSize',8);

subplot(2,1,2)
sfine=gridmake(0,nodeunif(n(2)*4,smin(2),smax(2)));
xfine=funeval(c,fspace,sfine);
plot(exp(sfine(:,2)),(1+r)*sfine(:,1)+exp(sfine(:,2))-xfine)
xlabel('$e^y$','Interpreter','latex')
ylabel('$a^{\prime}(0,\bar{y})$','Interpreter','latex')
title({'Savings policy function, $a=0$'},'Interpreter','latex')
set(gca,'FontSize',8);
