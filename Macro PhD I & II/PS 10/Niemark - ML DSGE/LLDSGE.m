function [LL]=LLDSGE(THETA)
global Z

tau       = THETA(1);  % Since I am using sigma for the standard deviaion of the shocks, I am using tau to denote the CRRA parameter.
beta      = THETA(2); % discount factor
theta     = THETA(3); % degree of price stickiness
phi_pi    = THETA(4); % taylor rule parameter
phi_y     = THETA(5); % taylor rule parameter
varphi    = THETA(6); %inverse of elastiicity of labor supply
alpha     = THETA(7); %production function parameter
eps       = THETA(8); % elasticity of substitution between goods i and j in the consumption basket
rho_v     = THETA(9); %persistence parameter
rho_a     = THETA(10); %persistence parameter
rho_z     = THETA(11); %persistence parameter
rho_u     = THETA(12); %persistence parameter
sigma_v   = THETA(13); %standard deviation
sigma_a   = THETA(14); %standard deviation
sigma_z   = THETA(15); %standard deviation
sigma_u   = THETA(16); %standard deviation

[T,R,eu] = NKBC_model(tau,beta,theta,phi_pi,phi_y,varphi,alpha,eps,rho_v,rho_a,rho_z,rho_u,sigma_v,sigma_a,sigma_z,sigma_u);
psi_yna = (1+varphi)/(tau*(1-alpha)+varphi+alpha);
kappa   = (1/theta-1)*(1-beta*theta)*((1-alpha)/(1-alpha+alpha*eps))*(tau+((varphi+alpha)/(1-alpha)));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Put model in state space form
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
A=T;
C = R*[sigma_v 0 0 0;
       0 sigma_a 0 0;
       0 0 sigma_z 0;
       0 0 0 sigma_u];

D=[1,0,0,0,0,psi_yna,0,0,(1/kappa),0;%Output
    0,1,0,0,0,0,0,0,0,0;%Inflation
    0,0,1,0,0,0,0,0,0,0;%Interest rate
    1/(1-alpha),0,0,0,0,-(1 - psi_yna),0,0,0,0;];%Hours worked
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set initial values for Kalman filter etc
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
T=length(Z);
LL=0;
P= dlyap(A,C*C');%Initial uncertainty equal to unconditional variance of state
Xfilt=zeros(10,1); %initial value for the filtered state.
CC=C*C';
RR=zeros(4,4);
RR(3:4,3:4)=eye(2)*.001;

%Compute recursive likelihood using the Kalman filter
for tt=1:T
    a=Z(1:4,tt)-D*Xfilt;%These are the innovations (i.e. Ztilde)
    Omega=D*P*D'+RR;
    Omegainv=eye(4)/(Omega);
    K=P*D'*Omegainv;
    Xfilt=A*Xfilt+A*K*a;
    P = A*(P-P*D'*Omegainv*D*P)*A' + CC;
    LL = LL - 0.5*(log(det(Omega)) + a'*Omegainv*a);
end
if min(eu)==0
    LL=-9e+200;
end
if imag(LL)~=0
    LL=-9e+200;
end

LL=-LL;%Because simulated annealing is minimizing
