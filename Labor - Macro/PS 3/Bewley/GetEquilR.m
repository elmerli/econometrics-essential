function [rx,glob] = GetEquilR(glob)

ra = 0;
rb = inv(glob.beta)-1;

tic

glob.r = ra;
[fa,glob] = GetAssetSupply(glob);
formatSpec= 'r is %9.6e, excess demand is %9.6f (%9.6f), with %5i bel iterations (agrid too small %1i)\n';
tmp_str=sprintf(formatSpec,ra,fa,glob.Kd-glob.Ks,glob.bel_iter,glob.agrid_too_small);
disp('Left endpoint:')
disp(tmp_str)

glob.r = rb;
[fb,glob] = GetAssetSupply(glob);
formatSpec= 'r is %9.6e, excess demand is %9.6f (%9.6f), with %5i bel iterations (agrid too small %1i)\n';
tmp_str=sprintf(formatSpec,rb,fb,glob.Kd-glob.Ks,glob.bel_iter,glob.agrid_too_small);
disp('Right endpoint:')
disp(tmp_str)

if sign(fa)*sign(fb)==sign(1), pause, end

s = sign(fa);
rx = 0.5*(ra+rb);
dx = 0.5*(rb-ra);

glob.r = rx;
[fx, glob] = GetAssetSupply(glob);

while (all([dx>1D-7; abs(fx)>1D-5]))
%while (dx>1D-7)

  glob.r = rx;
  [fx,glob,fspace,c] = GetAssetSupply(glob);

  dx = 0.5*dx;

  formatSpec= 'r is %9.6e, dx is %9.6e, excess demand is %9.6f (%9.6f), Kd is %9.6f, Ks is %9.6f, with %5i bel iterations (agrid too small %1i)\n';
  tmp_str=sprintf(formatSpec,rx,dx,fx,glob.Kd-glob.Ks,glob.Kd,glob.Ks,glob.bel_iter,glob.agrid_too_small);
  disp(tmp_str)

  if s == sign(fx)
    rx = rx+dx;
  else
    rx = rx-dx;
  end

end

fprintf('r is %9.6e\n',rx)

fprintf('it took %9.6f minutes \n',toc/60)
