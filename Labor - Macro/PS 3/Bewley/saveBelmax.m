function [x, ap,ev,c] = saveBelmax(cold,fspace,glob,iter)

c=cold;

switch fspace.sol
case 'bi'

  %---  Bisection begin: solve for x
  
  % this should be within a routine
  
  a = .01*ones(glob.ns,1);
  b = (1+glob.r)*glob.s(:,1)+glob.mpl*exp(glob.s(:,2))-glob.amin;   % can't drive assets below 0
  
  tol=1e-8;
  
  fa=euler_error(a,c,fspace,glob,'solve');
  fb=euler_error(b,c,fspace,glob,'solve');
  
  x=zeros(glob.ns,1);
  
  %initialize
  dx = 0.5*(b - a);
  x = a + dx;                       %  start midpoint
  sb=sign(fb);
  dx = sb.*dx;                         
  
    while any(abs(dx)>tol)
      dx = 0.5*dx;
      x = x - sign(euler_error(x,c,fspace,glob,'solve')).*dx;   
    end
  
  x(fb>=0)=b(fb>=0);
  
  
  if (any((b-x)>max(glob.s(:,1))) & glob.bel_print)
    formatSpec = '\t aprime is greater than amax at iter %3i';
    tmp_str = sprintf(formatSpec,iter);
    disp(tmp_str)
  end
  
  
  %---  Bisection end
   
  if (glob.slower) 
    % approximate marginal product and expected value. then don't have 
    % to worry about constraint binding/not binding.
  
    c(:,1)=funfitxy(fspace,glob.s,x.^(-glob.gamma));
    ev = euler_cont(x,c,fspace,glob);
    c(:,2) = funfitxy(fspace,glob.s,ev);
  
  else
  
    ap = (1+glob.r).*glob.s(:,1) + glob.mpl.*exp(glob.s(:,2));
    c(:,1)=fspace.PhiAY\(x.^(-glob.gamma));
    ev = euler_cont(x,c,fspace,glob);
    c(:,2)=fspace.PhiAY\ev;
    c(:,3) = funfitxy(fspace,glob.s,ap);
  
  end

% =====

case 'egm'
  
  ap_tmp = fspace.PhiAY*c(:,3);
  xp_tmp = -ap_tmp + (1+glob.r).*glob.s(:,1) + glob.mpl.*exp(glob.s(:,2));

  xprime = repmat(reshape(xp_tmp,glob.anum,glob.ynum),[glob.ynum,1]);
  xprime = xprime.^(-glob.gamma);

  xtmp = (1+glob.r).*glob.beta.*(sum(xprime.*fspace.yPPbig,2));
  xtmp = xtmp.^(-1/glob.gamma);

  anow = (xtmp + glob.s(:,1)-glob.mpl.*exp(glob.s(:,2)))./(1+glob.r);
  anow = reshape(anow,glob.anum,glob.ynum);

  ap_i = glob.agrid;

  new_ap = zeros(glob.anum,glob.ynum);

  for ii=1:glob.ynum
    tmp = sum(anow(:,ii)<0);
    anow_i = anow(:,ii);

    tmp_fspace = fundef({'spli', anow_i,0,1});
    tmp_c = funfitxy(tmp_fspace,anow_i,ap_i);
    % Here is the smoothing step: use information where a is less 
    % than amin. Hm, okay!

    tmp_Phi = funbas(tmp_fspace,glob.agrid);
    new_ap(:,ii)  = max(tmp_Phi*tmp_c,0);
    
  end
  
  ap = new_ap(:);
  x = - ap + (1+glob.r).*glob.s(:,1) + glob.mpl.*exp(glob.s(:,2));
  c(:,1)=fspace.PhiAY\(x.^(-glob.gamma));
  ev = euler_cont(x,c,fspace,glob);
  c(:,2)=fspace.PhiAY\ev;
  c(:,3) = funfitxy(fspace,glob.s,ap);

end

%Compute moments of asset distribution, capital distribution.
