function fval = euler(x,c,fspace,s,e,w)

global beta r ro gamma yPP ygrid

ns=size(s,1);
a=s(:,1);
y=exp(s(:,2));
aprime=(1+r)*a+y-x;
fval=x.^(-gamma);
as=ns/length(ygrid);

for i=1:length(ygrid)
  cprime=funeval(c,fspace,[aprime,ygrid(i)*ones(ns,1)]);
  for j=1:length(ygrid)
    ypp(1+(j-1)*as:j*as,1)=yPP(j,i);
  end 
    fval=fval-beta*(1+r)*ypp.*cprime.^(-gamma); 
end
