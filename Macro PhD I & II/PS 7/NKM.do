// Variables
var pi y Y rn i m_r n a v;
varexo eps_v eps_a;
//
// Parameters
parameters beta epsilon theta sigma rho phi alpha phi_pi phi_y eta PSI_yan THETA lambda kappa rho_v rho_a LAMBDA_v LAMBDA_a;
beta = 0.99;
sigma = 1;
phi = 1;
alpha = 1/3;
epsilon = 6;
eta = 4;
theta = 2/3;
phi_pi = 1.5;
phi_y = 0.5/4;
PSI_yan = (1+phi)/(sigma*(1-alpha)+phi+alpha); 
THETA = (1-alpha)/(1-alpha+alpha*epsilon); 
lambda = (1-theta)*(1-beta*theta)*THETA/theta; 
kappa = lambda*(sigma+(phi+alpha)/(1-alpha)); 
rho = 1/beta-1;
rho_v = 0.5;
rho_a = 0.9;
LAMBDA_v = 1/((1-beta*rho_v)*(sigma*(1-rho_v)+phi_y)+kappa*(phi_pi-rho_v));
LAMBDA_a = 1/((1-beta*rho_a)*(sigma*(1-rho_a)+phi_y)+kappa*(phi_pi-rho_a));
//

// 
//------------------------------------------ 
// Model 
//------------------------------------------ 
model(linear);
// Taylor-Rule
i = rho+phi_pi*pi+phi_y*y+v; // eq'n. (25), p. 50 // IS-Equation
y = y(+1)-1/sigma*(i-pi(+1)-rn); // y is output gap (22) rn=rho+sigma*PSI_yan*(a(+1)-a); // natural rate of interest (23)
Y = PSI_yan*(1-sigma*(1-rho_a)*(1-beta*rho_a)*LAMBDA_a)*a; // actual
output; 3rd eq'n from bottom, p. 54
// Phillips Curve
    pi = beta*pi(+1)+kappa*y; // (21)
// Money Demand
    m_r = y-eta*i; // ad hoc money demand; m_r = m-p
// Employment
n = (((PSI_yan-1)-sigma*PSI_yan*(1-rho_a)*(1-beta*rho_a)*LAMBDA_a)/(1- alpha))*a; // bottom p. 54
// Autoregressive Error
a = rho_a*a(-1) + eps_a; // technology shock (28)
v = rho_v*v(-1) + eps_v; // shock to i (bottom p. 50)
end;

// 
//------------------------------------------ 
// Steady State 
//------------------------------------------ 
check;
// 
//------------------------------------------ 
// Shocks 
//------------------------------------------ 
shocks;
var eps_v = 0;
var eps_a = 1;
end;
//
tech = 1;
policy = 0;

//------------------------------------------ 
// Computation 
//------------------------------------------ 
stoch_simul(irf=12); 
//stoch_simul(periods=1000,irf=12);
//
//------------------------------------------
// Plots 
//------------------------------------------
if policy==1;









