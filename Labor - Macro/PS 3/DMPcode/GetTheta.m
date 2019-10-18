function [theta cc errnorm] = GetTheta(bb_in, gam_in)
global alf sigm bet rr sep yrho ysig vfSS jfSS thetaSS ygrid yPP ynn

cc0=0;
options_cc=optimset('Display','off');
GetZPss_lambda= @(x) GetZPss(bb_in,gam_in,x);
cc  = fsolve(GetZPss_lambda,cc0,options_cc);

% Solve for theta
theta0 = ones(ynn,1);
GetZP_lambda = @(x) GetZP(x,bb_in,gam_in,cc);

options = optimset('Display','none','MaxFunEvals',100000,'Algorithm','levenberg-marquardt','tolx',1E-7);
[theta, err, eflag] = fsolve(GetZP_lambda,theta0,options);
errnorm=norm(err);
theta=real(theta);

if (eflag~=1)
  disp({'Did not converge, eflag=', eflag(1)})
end
