clear;
%clc;


% Declare parameters - would be outcome of calibration
glob.beta      = 0.980;
glob.ro        = 0.9923;
glob.se        = 0.0983;
glob.gamma     = 1.0;
glob.alf       = 0.36;
glob.depr      = 0.025;
glob.bel_print = 1;
glob.slower    = 0;
glob.r         = 0.04-glob.depr;
glob.tfp       = 1.00;

% ---
% Declare function space, given all else.
% ---
anum_in = 50;
ynum_in = 7;
amult_in = 40;
sol_flag_in = 'egm';
%sol_flag_in = 'bi';
[fspace, glob] = GetFspace(glob,anum_in,ynum_in,amult_in,sol_flag_in,'all');
glob.Kd = GetTech(glob,'Kd');
glob.agrid_too_small = 0;


c = zeros(glob.ns,3); % preallocate coefficients

% guess that keep constant assets
x = glob.r/(1+glob.r)*glob.s(:,1)+glob.mpl.*exp(glob.s(:,2));
c(:,1)=funfitxy(fspace,glob.s,x.^(-glob.gamma));                   
ev = euler_cont(x,c,fspace,glob);
c(:,2)=funfitxy(fspace,glob.s,ev);
ap = glob.s(:,1)./(1+glob.r);
c(:,3)=funfitxy(fspace,glob.s,ap);


tic;

for it=1:900

  cold=c;
  xold=x;
  apold = ap;
  
  [x,ap,ev,c] = saveBelmax(cold,fspace,glob,it);

    if glob.bel_print, fprintf('%4i %6.2e\n',[it,norm(c-cold)]), end;
  switch fspace.sol
  case 'bi'
    if norm(x-xold)./norm(x)<1e-7, break, end
  case 'egm'
    if norm(ap-apold)./norm(ap)<1e-7, break, end
  end

end

toc

switch fspace.sol
case 'bi'
  c(:,3) = funfitxy(fspace,glob.s,x);
case 'egm'
  c(:,1) = funfitxy(fspace,glob.s,x.^(-glob.gamma));
  ev = euler_cont(x,c,fspace,glob);
  c(:,2)=fspace.PhiAY\ev;
 
end

% get other coefficients


% collect info about solution
glob.bel_iter = it;

b = (1+glob.r)*glob.s(:,1)+glob.mpl*exp(glob.s(:,2))-glob.amin;
if (any((b-x)>max(glob.s(:,1))))
  glob.agrid_to_small = 1;
end

cx = funfitxy(fspace,glob.s,x);

% Look at euler equation error
nf = [1000,glob.ynum];
[lambda, sfine, apfine, glob] = GetLambda(glob,fspace,c,nf);
sfine = gridmake(nodeunif(glob.n(1)*2,glob.smin(1),glob.smax(1)),glob.ygrid);
xfine=funeval(cx,fspace,sfine);
constr = ((1+glob.r)*sfine(:,1)+glob.mpl*exp(sfine(:,2))-xfine>.01);
eerror = -euler_error(xfine,c,fspace,glob,'sfine',sfine) + xfine.^(-glob.gamma);
eerror = 1-((eerror.^(-1/glob.gamma))./xfine);

disp('mean and max errors')
disp(sum(abs(eerror(constr==1).*lambda(constr==1))))
disp(max(abs(eerror(constr==1))))

