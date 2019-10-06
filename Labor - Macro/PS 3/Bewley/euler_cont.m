function fval = euler_cont(x,c,fspace,glob,sfine)

if (nargin<=4)
  a = glob.s(:,1);
  y = glob.mpl.*exp(glob.s(:,2));
  
  fval = zeros(glob.ns,1);
  if nargout>1
    PhiLHS = zeros(glob.ns,glob.ns)
  end
  
  ypp = zeros(glob.ns,1);
  for i=1:glob.ynum
  
    if (glob.slower)

      uprime=funeval(c(:,1),fspace,[a,glob.ygrid(i)*ones(glob.ns,1)]);

      for j=1:glob.ynum
        ypp(1+(j-1)*glob.anum:j*glob.anum,1)=glob.yPP(j,i);
      end

      fval=fval+glob.beta*(1+glob.r)*ypp.*uprime;
  
    else
  
      uprime=fspace.PhiAYp(i).phi*c(:,1);
      fval=fval+glob.beta*(1+glob.r)*uprime;

    end

    if nargout>1
      PhiLHS = fspace.PhiAYp(i) + PhiLHS;
    end
  
  end

else

  % nargout>1 doesn't make sense

  nsf = length(x);
  afine = sfine(:,1);
  yfine = glob.mpl*exp(sfine(:,2));
  apfine = yfine+(1+glob.r)*afine-x;
  apfine(apfine<0) = 0; %should be very, very small, only at a few places
  
  fval = zeros(nsf,1);
  
  ypp = zeros(nsf,1);
  as = nsf/glob.ynum; %assuming that ynum stays the same

  for i=1:glob.ynum
  
    uprime=(funeval(c(:,1),fspace,[apfine,glob.ygrid(i)*ones(nsf,1)]));%.^(-glob.gamma);

    for j=1:glob.ynum
      ypp(1+(j-1)*glob.anum:j*glob.anum,1)=glob.yPP(j,i);
    end

    fval=fval+glob.beta*(1+glob.r)*ypp.*uprime;
  
  end

end
