function [fval] = GetTech(glob,flag)

Kd = ( (glob.alf .* glob.tfp .* glob.expymean.^(1-glob.alf) )/...
  (glob.r+glob.depr) ).^(1/(1-glob.alf));

switch flag

  case 'Kd'
  
  fval=Kd;
  
  case 'mpl'
  
  fval = (1-glob.alf) .* glob.tfp .* (Kd.^glob.alf) .* (glob.expymean.^(-glob.alf));

end
