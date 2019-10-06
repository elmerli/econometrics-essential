function [out1] = menufunc(flag,x,glob,sfine)

switch flag

case 'f1'
  out1 = x.^(-glob.gamma);

case 'g1'
  a   = glob.s(:,1);
  y   = glob.mpl*exp(glob.s(:,2));
  aprime = (1+glob.r)*a+y-x;

  out1 = [aprime, glob.s(:,2)];

case 'g1fine'

  a   = sfine(:,1);
  y   = glob.mpl*exp(sfine(:,2));
  aprime = (1+glob.r)*a+y-x;

  out1 = [aprime, sfine(:,2)];

case 'g2'

  a   = glob.s(:,1);
  y   = glob.mpl*exp(glob.s(:,2));
  aprime = (1+glob.r)*a+y-x;

  out1 = [aprime, rho*glob.s(:,2)];


end

