function [resid] = GetZP(theta_in,hprod_in, gamm_in, cc_in)
global alf sigm bet rr sep yrho ysig vfSS jfSS thetaSS ygrid yPP ynn

theta_in=real(theta_in);
VF = GetVF(theta_in);
ygrid_tmp=ygrid;
if (size(theta_in,2)~=1), ygrid_tmp = repmat(ygrid,1,size(theta_in,2));, end
RHS = (1-gamm_in).*(ygrid_tmp - hprod_in) ...
  - gamm_in*cc_in.*theta_in + (1-sep)*cc_in./VF;
RHS = bet.*yPP*RHS;
LHS = cc_in./VF;
FF = LHS-RHS;

% Note: this is a complementarity problem! See Miranda and Fackler 
% for notes on ways of approaching these
resid = FF + theta_in - sqrt(FF.^2 + theta_in.^2);

  
