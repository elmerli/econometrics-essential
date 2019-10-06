function [Kdiff,glob,fspace,c] = GetAssetSupply(glob,fspace)


% ---
% Declare function space, given all else.
% ---

anum_in = 50;
ynum_in = 7;
amult_in = 100;

%sol_flag_in = 'bi';
sol_flag_in = 'egm';
[fspace, glob] = GetFspace(glob,anum_in,ynum_in,amult_in,sol_flag_in,'all');
glob.mpl = GetTech(glob,'mpl');
glob.Kd = GetTech(glob,'Kd');
glob.agrid_too_small = 0;

c = zeros(glob.ns,3); % preallocate coefficients

% guess that keep constant assets
x = glob.r/(1+glob.r)*glob.s(:,1)+exp(glob.s(:,2));
c(:,1)=funfitxy(fspace,glob.s,x.^(-glob.gamma));                   
ev = euler_cont(x,c,fspace,glob);
c(:,2)=funfitxy(fspace,glob.s,ev);

ap = glob.s(:,1)./(1+glob.r);
c(:,3)=funfitxy(fspace,glob.s,ap);


for it=1:400

  cold=c;
  xold=x;
  
  [x,ap,ev,c] = saveBelmax(cold,fspace,glob,it);
  
  if glob.bel_print, fprintf('%4i %6.2e\n',[it,norm(c-cold)]), end;
  if norm((c(:,1)-cold(:,1)))<1e-7, break, end

end

glob.bel_iter = it;


b = (1+glob.r)*glob.s(:,1)+glob.mpl*exp(glob.s(:,2))-glob.amin;
if (any((b-x)>max(glob.s(:,1))))
  glob.agrid_to_small = 1;
end

nf = [1000,glob.ynum];

[lambda, sfine, apfine, glob] = GetLambda(glob,fspace,c,nf);

Kdiff = (glob.Kd-glob.Ks)/(0.5*(glob.Kd+glob.Ks));

end
